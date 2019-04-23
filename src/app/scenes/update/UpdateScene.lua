--[[--ldoc desc
@module UpdateScene
@author LoyalwindPeng

Date   2019-1-29
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local UpdateModule = import("framework.update");
local UpdateEnum = UpdateModule.UpdateEnum;
local UpdateHelper = UpdateModule.UpdateHelper

local UpdateScene = class("UpdateScene",ViewScene);
BehaviorExtend(UpdateScene);

---配置事件监听函数
UpdateScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
}
UpdateScene.HttpCMD = {
	mod = "mobile";
	act	= "getapkinfo";
}

function UpdateScene:ctor()
	ViewScene.ctor(self)
	NativeEvent.getInstance():callNative(NativeCmd.KEY.NATIVE_CMD_ENGINE_LOADED)
	self:bindCtr(require("UpdateCtr"))
	-- 绑定热更新组件
	self:bindBehavior(UpdateModule.UpdateBehavior)
	self:becomeResponder()
	self:initUI()
end

function UpdateScene:initUI()
	-- do something
	-- 透明背景
	-- local bgLayout = ccui.Layout:create()
	-- :setBackGroundImage("creator/login/imgs/login_bg.jpg", ccui.TextureResType.localType)
	-- :setContentSize(cc.size(display.width, display.height)) -- 全屏
	-- :setTouchEnabled(true) -- 拦截事件点击
	-- :setBackGroundImageScale9Enabled(true) -- 拉伸
	-- :addTo(self)
	-- self.m_bgLayout = bgLayout

	-- 加载布局文件
	self.m_root = self:loadLayout("creator/source/updateScene.ccreator");
	self:add(self.m_root);

	self.m_bg   = g_NodeUtils:seekNodeByName(self.m_root, 'bg')
	self.m_ipadGirl = g_NodeUtils:seekNodeByName(self.m_root, 'girl_ipad')
	self.m_logo = g_NodeUtils:seekNodeByName(self.m_root, 'logo')
	self.m_logo:setOpacity(0)
	self.m_logo:setTexture(switchFilePath('login/login_logo.png'))
	self.m_logo:runAction(cc.Sequence:create(cc.DelayTime:create(0), cc.FadeTo:create(0.1, 255)))

	if display.height/display.width < 960/1280 then --宽高比小于 960/1280
		self.m_bg:setContentSize(cc.size(1280,960))
		if display.width > 1280 then --宽高比小于 720/1280
			self.m_bg:setContentSize(cc.size(display.width,960))
		end
		self.m_ipadGirl:setContentSize(cc.size(738,800))
		self.m_logo:setPosition(179,275)
	else--宽高比大于 960/1280
		self.m_bg:setContentSize(cc.size(display.width,display.height))
		self.m_logo:setPosition(179,313)
		local size = self.m_ipadGirl:getContentSize()
		self.m_ipadGirl:setContentSize(cc.size(size.height/800*738,size.height))
	end

	g_NodeUtils:arrangeToCenter(self.m_bg,0,0)
	local size1 = self.m_ipadGirl:getContentSize()
	g_NodeUtils:arrangeToBottomCenter(self.m_ipadGirl,47-(display.width-size1.width)/2,0)

	-- 创建进度条背景
	local barbg = ccui.Scale9Sprite:create("creator/source/img/res_loading_bg.png")
	:ignoreAnchorPointForPosition(true)
	:setContentSize(cc.size(400, 10))
	:addTo(self.m_root)
	:setPosition(display.width-500, 100)
	:setVisible(false)

	-- 进度条
	local progressBar = ccui.LoadingBar:create()
	:loadTexture("creator/source/img/res_loading_fg.png",ccui.TextureResType.localType)
	:setPercent(0):setContentSize(cc.size(400, 10))
	:setScale9Enabled(true)
	:ignoreAnchorPointForPosition(true)
	:setCapInsets({5,5,5,5})
	:addTo(barbg)
	:setPosition(0, 0)
	self.barbg = barbg
	self.progressBar = progressBar

	self.m_loadingTx = cc.Label:createWithSystemFont(GameString.get("str_update_loading"), nil, 22)
	barbg:addChild(self.m_loadingTx);
	g_NodeUtils:arrangeToCenter(self.m_loadingTx, 0, -25)
end

function UpdateScene:doCheckImmediately(sender)
	local luaVersion = UpdateHelper.luaVersion(g_AppManager:getRegionalID())
	local appVersion = UpdateHelper.appVersion()
	local param = {
		mod        = UpdateScene.HttpCMD.mod;
		act	       = UpdateScene.HttpCMD.act;
		luaVersion = luaVersion; --客户端脚本的版本号
		appVersion = appVersion;
		system     = (device.platform == "ios") and "ios" or "android";
		regionalID = g_AppManager:getRegionalID();
	}
	local url = g_AppManager:getUpdateUrl()
	g_Progress.getInstance():show()
	Log.d("doCheckImmediately", url)
    self:checkUpdate(url, param, handler(self, self.onCheckUpdateResponse))
end

function UpdateScene:onCheckUpdateResponse(isSuccess, data, param)
	Log.d("onCheckUpdateResponse", data, param)
	data = g_TableLib.checktable(data)
	local mbapk_info = data.mbapk_info

	g_Progress.getInstance():dismiss()
	if (not isSuccess) or next(mbapk_info) == nil then
		self:_gotoLoginScene()
		return
	end
	
	local updateInfo = UpdateModule.UpdateInfo.new(mbapk_info)
	self:prepareUpdate(updateInfo)
end

function UpdateScene:onUpdateProgress(downloadInfo, bytesReceived, totalBytesReceived, totalBytesExpected)
	local progress = 100 * totalBytesReceived/totalBytesExpected
	-- Log.d("onUpdateProgress", bytesReceived, totalBytesReceived, totalBytesExpected, progress-progress%0.1)
	self.progressBar:setPercent(progress)
end

--@desc: 更新成功的回调
--@downloadInfo:下载信息
function UpdateScene:onUpdateSuccess(downloadInfo)
	Log.d("UpdateScene:onUpdateSuccess",downloadInfo)
	if downloadInfo.mode ~= UpdateEnum.Mode.Silent then
		-- 不是静默更新，重启游戏引擎
		UpdateHelper.restart()
	else
		self:_gotoLoginScene()
    end
end

--@desc: 更新出错的回调
--@downloadInfo:下载信息
--@errorCode: 错误码枚举值 UpdateEnum.ErrorCode
--@errorCodeInternal:内部错误码
--@errorStr: 错误信息
function UpdateScene:onUpdateError(downloadInfo, errorCode, errorCodeInternal, errorStr)
	Log.d("UpdateScene:onUpdateError",downloadInfo, errorCode, errorCodeInternal, errorStr)
	-- 是强制更新，重启游戏引擎
	if downloadInfo.mode == UpdateEnum.Mode.Forced then
		UpdateHelper.restart()
	else
		self:_gotoLoginScene()
	end
end

--@desc: lua 静默更新
--@updateInfo: UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateScene:onPreparedLuaSilent(updateInfo)
	self:_gotoLoginScene()
end

--@desc: lua 可选更新
--@updateInfo: UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateScene:onPreparedLuaOptional(updateInfo)
	local description = self:_fetchUpdateDescription(updateInfo)
	if not description then return end
	-- 直接強制取消可選框
	self.barbg:setVisible(true)
	self:confirmUpdate(updateInfo)
	
	-- self:_showOptionalAlertDialog(description, function()
	-- 	self.barbg:setVisible(true)
	-- 	self:confirmUpdate(updateInfo)
	-- end)
end

--@desc: lua 强制更新
--@updateInfo: UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateScene:onPreparedLuaForced(updateInfo)
	self.barbg:setVisible(true)
end

--@desc: app 可选更新
--@updateInfo: UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateScene:onPreparedAppOptional(updateInfo)
	local description = self:_fetchUpdateDescription(updateInfo)
	if not description then return end
	self:_showOptionalAlertDialog(description, function()
		self:_gotoLoginScene()
		UpdateHelper.gotoAppStore()
	end)
end

--@desc: app 强制更新
--@updateInfo: UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateScene:onPreparedAppForced(updateInfo)
	local description = self:_fetchUpdateDescription(updateInfo)
	if not description then return end
	g_AlertDialog.getInstance()
		:setTitle(GameString.get("str_update_tips"))
		:setCloseBtnVisible(false)
		:setAutoDismiss(false)
		:setContent(description)
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
		:setCenterBtnTx(GameString.get("str_confirm_update"))
		:setCenterBtnFunc(function()
			UpdateHelper.gotoAppStore()
		end)
		:show()
end

function UpdateScene:_gotoLoginScene()
	local SceneLogin = import("app.scenes.login").scene
	
	if fix_restart_lua then
		-- 为了支持重启，这里不能直接使用runWithScene
		display.runScene(SceneLogin:create(true))
	else
		cc.Director:getInstance():replaceScene(SceneLogin:create(true))
	end
end

function UpdateScene:_fetchUpdateDescription(updateInfo)
	if iskindof(updateInfo, "UpdateInfo") then
		return updateInfo.description or "更新内容如下：..."	
	else
		self:_gotoLoginScene()
		return nil
	end
end

function UpdateScene:_showOptionalAlertDialog(description, confirmFunc)
	g_AlertDialog.getInstance()
		:setTitle(GameString.get("str_update_tips"))
		:setCloseBtnVisible(false)
		:setContent(description)
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		:setLeftBtnTx(GameString.get("str_common_cancel"))
		:setRightBtnTx(GameString.get("str_confirm_update"))
		:setLeftBtnFunc(function() self:_gotoLoginScene() end)
		:setRightBtnFunc(confirmFunc)
		:show()
end

function UpdateScene:onEnter()
	ViewScene.onEnter(self)
	self:initializeUpdate()

	if not self.m_noCheck then
		self.m_noCheck = true
		self:doCheckImmediately()
	end
end

function UpdateScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]
	self:resignResponder()
end

return UpdateScene;