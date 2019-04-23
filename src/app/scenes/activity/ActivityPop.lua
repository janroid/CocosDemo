--[[--ldoc 网页活动页面
@module ActivityPop
@author LoyalwindPeng

Date   2019-1-7
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ActivityPop = class("ActivityPop",PopupBase);
BehaviorExtend(ActivityPop);

local ActivityWebInfo = require("ActivityWebInfo")

-- 配置事件监听函数
ActivityPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}
ActivityPop.s_eventWebCMDMap = {
    [0] = 'onWebClose',		 		--关闭
    [1] = 'onWebPlayNow',		 	--playnow立即游戏
    [2] = 'onWebOpenShop',		 	--打开商城  data.type: 类型(chip  coalaa  vip  prop),data.stab: 商品
    [3] = 'onWebShowActWheel',		--大转盘
    [4] = 'onWebGoGameRoom',		--进普通场房间  data为房间类型  1 ~ 4(老版本功能，暂时不需要加接口)
    [5] = 'onWebGoNormalHall',		--定位到大厅普通场Tab   data 为房间类型  0 ~ 2
    [7] = 'onWebGoSNGHall',		 	--定位到sng(淘汰赛)
    [8] = 'onWebGoMTTHall',		 	--定位到mtt(锦标赛)
    [9] = 'onWebGoPromotionHall',	--定位到晋级赛(目前新版本没有)
    [10] = 'onWebOpenGift',		 	--打开礼物收集
    [11] = 'onWebOpenTicket',		--打开彩票
    [12] = 'onWebInviteFriend',		--打开邀请好友
    [14] = 'onWebOpenNewActWheel',	--新年活动打开新大转盘
    [15] = 'onWebBlindsRoom',		--按照盲注配置选房
    [17] = 'onWebDiamondWinner',	--钻石大赢家
    [18] = 'onWebOpenFansCode',		--打开粉丝页兑换码
    [19] = 'onWebOpenPenalties',	--打开点球活动
    [20] = 'onWebOpenGoldenKey',	--打开金钥匙
    [22] = 'onWebOpenTask',		 	--打开任务页
    [23] = 'onWebOpenFriendsPage',	--打开好友页面
    [24] = 'onWebCheckNextHtml',	--关闭页面,检测下一个自动html页面
    [25] = 'onWebOpenWebView',		--跳转到互动中心，追加url
    [26] = 'onWebOpenFeed',		 	--feed
    [27] = 'onWebOpenBrowser', 		--打开浏览器
}

function ActivityPop:ctor()
	PopupBase.ctor(self, true);
	self:bindCtr(require("ActivityCtr"))
	self:init()
	self.m_webInfo = {}
end

function ActivityPop:init()
	-- do something
	local bgLayout = ccui.Layout:create()
	bgLayout:setBackGroundImage("creator/common/dialog/pop_transparency_bg.png", ccui.TextureResType.localType)
	bgLayout:setContentSize(cc.size(display.width,display.height))
	bgLayout:setTouchEnabled(true)
	bgLayout:setBackGroundImageScale9Enabled(true)
	bgLayout:setVisible(false)
	self:add(bgLayout)
	self.m_bgLayout = bgLayout
end

-- 初始化webView
--@reCreate bool 是否重新创建
function ActivityPop:initWebView(reCreate)
	if self.m_webView then
		if reCreate ~= true then return  end
		self:removeChild(self.m_webView, true)
		self.m_webView = nil
	end

	local webView = ccexp.WebView:create()
	webView:setAnchorPoint(0, 0)
	webView:setBounces(false)
	webView:setVisible(false)
	webView:setBackgroundTransparent()
	if g_SystemInfo:isAndroid() then
		webView:setOnJSCallback(handler(self, self.onJSCall))
	else
		webView:setOnShouldStartLoading(handler(self, self.shouldStartLoading))
	end
	self:add(webView)
	self.m_webView = webView
end

--@webInfo ActivityWebInfo 实例对象
function ActivityPop:show(webInfo)
	PopupBase.show(self)
	if (not self:preLoad(webInfo)) or (not webInfo:getForcedDisplay())then
		self:hidden()
	end
end

function ActivityPop:hidden(stopLoading)
	PopupBase.hidden(self)
	if self.m_webView then
		self.m_webView:setVisible(false)
		if stopLoading then
			self.m_webView:stopLoading()
		end
	end
end

--- 预加载
---@webInfo ActivityWebInfo 实例对象
---@return bool
function ActivityPop:preLoad(webInfo)
	if g_SystemInfo.isWindows() then
		Log.d('WebView不支持win32模拟器')
		return false
	end
	if not self:_checkWebInfo(webInfo) then
		return false
	end

	self:_doWebViewUI(webInfo)
	self:_doWebViewLogic(webInfo)
	return true
end

function ActivityPop:_checkWebInfo(webInfo)
	assert(iskindof(webInfo, 'ActivityWebInfo'), 'webInfo 必须是 ActivityWebInfo 类型')
	
	return webInfo:getValid()
end

function ActivityPop:_doWebViewLogic(webInfo)
	self.m_webInfo = webInfo
	local reCreate = webInfo:getReCreate()
	if reCreate then
		local url = webInfo:getUrl()
		self:loadURL(url)
	else
		local callJS = webInfo:getCallJS() --页面首次加载完成时调用的js函数及参数，比如func('abc','def')
		self:evaluateJS(callJS)
		self:openWebViewCallPhp()
	end
end

function ActivityPop:_doWebViewUI(webInfo)
	-- reCreate: false 用之前的webView执行js代码; true 重新创建webView;
	-- 加载webview
	local reCreate = webInfo:getReCreate()
	-- 初始化webview
	self:initWebView(reCreate)
	-- 设置webview
	self.m_webView:setPosition(webInfo:getPosition())
	self.m_webView:setContentSize(webInfo:getSize())

	if webInfo:getForcedDisplay() then
		self.m_bgLayout:setVisible(true)
		self.m_webView:setVisible(true)
	end
end

-- 做活动数量请求，红点
function ActivityPop:openWebViewCallPhp()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.ACTIVITY_UNREAD_NUMBER)
	g_HttpManager:doPost(params, nil, function (isSuccess,data)
		if isSuccess then
			g_Model:setData(g_ModelCmd.ACTIVITY_UNREAD_NUMBER, 0)
		end
	end)
end

function ActivityPop:loadURL(url)
	Log.d('loadURL', url)

	if type(url) ~= "string" or url == '' then
		Log.d("loadURL-- url无效", url)
		return 
	end

	if self.m_webView then
		self.m_webView:loadURL(url)
	end
end

function ActivityPop:evaluateJS(js)
	if type(js) ~= 'string' or js == '' then
		Log.d('evaluateJS--js无效', js)
		return
	end

	if self.m_webView then
		self.m_webView:evaluateJS('javascript:'..js)
	end
end

function ActivityPop:shouldStartLoading(webView, url)
	if g_SystemInfo:isIOS() then
		return self:shouldStartLoadingIOS(webView, url)
	else
		return self:onJSCall(webView, url)
	end
end

-- iOS webView交互处理
function ActivityPop:shouldStartLoadingIOS(webView, url)
	url = string.urldecode(url) -- 必须要解码，并且js端iframe设置的src 属性必须编码，不然会自动变成about:blank
	Log.d('shouldStartLoadingIOS', url)
	if url == "about:blank" then -- 点击空白，或者返回
		self:hidden()
		return false
	end

	local lowerurl = string.lower(url)
	if string.startsWith(lowerurl, 'objc://') then -- 协议头
		-- local urlComps = string.split(url, 'objc://')
		local funcAndParam = string.split(string.sub(url, 8), '@/') -- 函数和参数分割符
		if #funcAndParam < 2 then return false end

		if funcAndParam[1] == 'ipoker_interface' then
			local param = g_JsonUtil.decode(funcAndParam[2])
			if tonumber(param.type) == 1000 then
				local js = self.m_webInfo:getCallJS()
				if js and js ~= '' then
					self:evaluateJS(js)
				end
			elseif tonumber(param.type) == 0 then
				self:hidden()
			else
				self:onWebViewCall(param)
			end
		end
		return false
	end
	
	if string.startsWith(lowerurl, 'itms-apps://') then -- 去打开appstore
		g_AppManager:openURL(lowerurl) --AppManager:getStoreURL()
	end
	return true
end

-- 安卓 webView交互处理
function ActivityPop:onJSCall(webView, json)
	Log.d("onJSCall", json)
	local data = g_JsonUtil.decode(json)
	local type = data.type
	if tonumber(type) == 0 then
		self:hidden()
		return true
	elseif tonumber(type) == 1000 then
		local js = self.m_webInfo:getCallJS()
		if js and js ~= '' then
			self:evaluateJS(js)
		end
		Log.d("evaluateJS", js)
	else
		self:onWebViewCall(data)
	end
	return false
end

--  事件转发
function ActivityPop:onWebViewCall(param)
	Log.d("onWebViewCall", param)
	local cmd = tonumber(param.type) or 0
	local data = param.opts or {}
	local event = ActivityPop.s_eventWebCMDMap[cmd]
	if event ~= nil then
		self:doLogic(event, data)
		self:hidden()
	end
end

function ActivityPop:doLogic(event, data)
	if not self.mCtr then return end
	if type(self.mCtr[event] == 'function') then
        self.mCtr[event](self.mCtr, data)
	else
		Log.d("ActivityCtr has not function", event)
	end
end

function ActivityPop:onCleanup()
	PopupBase.onCleanup(self)
end

return ActivityPop;