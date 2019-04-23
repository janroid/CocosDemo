--[[--ldoc desc
@module LoginScene
@author ReneYang

Date   2018-10-26
]]
local ViewScene = import("framework.scenes").ViewScene
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local LoginScene = class("LoginScene",ViewScene);
BehaviorExtend(LoginScene);

local helpType = import('app.scenes.help').ShowType

LoginScene.s_eventFuncMap =  {
	[g_SceneEvent.LOGIN_FAILED]				= "onLoginFailed",
	[g_SceneEvent.LOGIN_UPDATE_DEBUGVIEW]	= "updateDebugView",
}

function LoginScene:ctor(isFirstStart, isBlindEmailReturn)
	ViewScene.ctor(self);
	self.m_isFirstStart = isFirstStart
	self.m_isBlindEmailReturn = isBlindEmailReturn
	self:bindCtr(require("LoginCtr"), isFirstStart);
	self:init();
	g_PopupManager:clearPop(g_PopupConfig.S_POPID.HELP_POP)
end

function LoginScene:isFirstStart()
	return self.m_isFirstStart or false
end

function LoginScene:onCleanup()
	self.m_timer:cancel()
	ViewScene.onCleanup(self)
	g_PopupManager:clearPop(g_PopupConfig.S_POPID.HELP_POP)
end

function LoginScene:init()
	-- do something
	
	-- 加载布局文件
	self.m_root = self:loadLayout("creator/login/loginScene.ccreator");
	self:add(self.m_root);

	self.m_btnFB =  g_NodeUtils:seekNodeByName(self.m_root,'btnFacebook') 
	self.m_labelFB = g_NodeUtils:seekNodeByName(self.m_root,'LabelFB') 
	self.m_btnEmail =  g_NodeUtils:seekNodeByName(self.m_root,'btnEmail') 
	self.m_labelEmail = g_NodeUtils:seekNodeByName(self.m_root,'LabelEmail') 
	self.m_btnGuest =  g_NodeUtils:seekNodeByName(self.m_root,'btnGuest') 
	self.m_labelGuest = g_NodeUtils:seekNodeByName(self.m_root,'LabelGuest') 
	self.m_labelReward = g_NodeUtils:seekNodeByName(self.m_root, 'labelReward')
	self.m_labelTime = g_NodeUtils:seekNodeByName(self.m_root, 'labelTime')
	self.m_labelVersion = g_NodeUtils:seekNodeByName(self.m_root, 'labelVersion')
	self.m_labelCompany = g_NodeUtils:seekNodeByName(self.m_root, 'labelCompany')
	self.m_labelGroup = g_NodeUtils:seekNodeByName(self.m_root, 'labelGroup')
	self.m_labelCopyright = g_NodeUtils:seekNodeByName(self.m_root, 'labelCopyright')
	self.m_labelGroup2 = g_NodeUtils:seekNodeByName(self.m_root, 'labelGroup2')
	self.m_btnHelp = g_NodeUtils:seekNodeByName(self.m_root, 'btnHelp')
	self.m_labelNickName = g_NodeUtils:seekNodeByName(self.m_root, 'LabelNickName')
	self.m_debugView     = g_NodeUtils:seekNodeByName(self.m_root, 'debugView')
	
	
	self.m_loginBg = g_NodeUtils:seekNodeByName(self.m_root, 'loginBg')
	self.m_bg   = g_NodeUtils:seekNodeByName(self.m_root, 'bg')
	self.m_ipadGirl    = g_NodeUtils:seekNodeByName(self.m_root, 'girl_ipad')
	self.m_fbReward   = g_NodeUtils:seekNodeByName(self.m_root, 'fbReward')
	self.m_logo  = g_NodeUtils:seekNodeByName(self.m_root, 'logo')
	self.m_logo:setOpacity(0)
	self.m_logo:setTexture(switchFilePath("login/login_logo.png"))

	g_NodeUtils:convertTTFToSystemFont(self.m_labelNickName)

	self:updateUI()
	self:initDebugView()
	self:initString()
	self:initClickListener()
	self:setBtnEnable(true)
end

function LoginScene:updateUI()

	if display.height/display.width < 960/1280 then --宽高比小于 960/1280
		
		self.m_bg:setContentSize(cc.size(1280,960))

		if display.width > 1280 then --宽高比小于 720/1280
			self.m_bg:setContentSize(cc.size(display.width,960))
		end

		self.m_ipadGirl:setContentSize(cc.size(738,800))
		
		self.m_logo:setPosition(179,275)
		-- self.m_fbReward:setPosition(380,165)
		self.m_btnFB:setPosition(640,148)
		self.m_btnEmail:setPosition(640,8)
		self.m_btnGuest:setPosition(640,-132)
	else--宽高比大于 960/1280
		
		self.m_bg:setContentSize(cc.size(display.width,display.height))
		self.m_logo:setPosition(179,313)
		-- self.m_fbReward:setPosition(380,205)
		self.m_btnFB:setPosition(640,188)
		self.m_btnEmail:setPosition(640,28)
		self.m_btnGuest:setPosition(640,-132)
	
		local size = self.m_ipadGirl:getContentSize()
		self.m_ipadGirl:setContentSize(cc.size(size.height/800*738,size.height))
	end

	g_NodeUtils:arrangeToCenter(self.m_bg,0,0)
	local size1 = self.m_ipadGirl:getContentSize()
	g_NodeUtils:arrangeToBottomCenter(self.m_ipadGirl,47-(display.width-size1.width)/2,0)
end

function LoginScene:initDebugView()

	if not g_AppManager.s_isShowDebugView and not g_AppManager:isDebug() then
		self.m_debugView:setVisible(false)
        return
	end

	g_AppManager.s_isShowDebugView = true
	self.m_debugView:setVisible(true)
	self.m_toggleRelease = g_NodeUtils:seekNodeByName(self.m_root, 'toggleRelease')
	self.m_toggleDemo    = g_NodeUtils:seekNodeByName(self.m_root, 'toggleDemo')

	self.m_guidInputView = g_NodeUtils:seekNodeByName(self.m_root, 'guidInputView')
	local isDemo = cc.UserDefault:getInstance():getBoolForKey(g_UserDefaultCMD.LOGIN_IS_DEMO, true)
	local isRelese = cc.UserDefault:getInstance():getBoolForKey(g_UserDefaultCMD.LOGIN_IS_RELEASE, false)
	self.m_toggleDemo:setSelected(isDemo)
	self.m_toggleRelease:setSelected(isRelese)
end

function LoginScene:updateDebugView()

	if not g_AppManager.s_isShowDebugView and not g_AppManager:isDebug() then
        return
	end
	local isDemo   = self.m_toggleDemo:isSelected()
	local isRelese = self.m_toggleRelease:isSelected()
	
	cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.LOGIN_IS_DEMO,isDemo)
	cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.LOGIN_IS_RELEASE,isRelese)

	local pcconfig = require1("PcConfig")
	pcconfig.IS_DEMO = isDemo
	pcconfig.IS_DEBUG = not isRelese

	g_AppManager:setDemo(isDemo)
	g_AppManager:setDebug(not isRelese)
    g_AppManager:processDifferentConfig()
	g_SystemInfo:setGuid(self.m_guidInputView:getText())
end

function LoginScene:initString()
	self.m_labelFB:setString(GameString.get("str_login_fb"))
	self.m_labelEmail:setString(GameString.get("str_login_email"))
	self.m_labelGuest:setString(GameString.get("str_login_guest"))
	self.m_labelReward:setString(GameString.get("str_login_reward"))
	self.m_labelCompany:setString(GameString.get("str_login_company"))
	self.m_labelGroup:setString(GameString.get("str_login_workgroup"))
	self.m_labelCopyright:setString(GameString.get("str_login_copyright"))
	self.m_labelGroup2:setString(GameString.get("str_login_workgroup2"))
	-- local email = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL,"")
	if not g_AppManager:isDebug() and g_AppManager:isGuestBindedEmail() then --g_StringLib.trim(email, " ") ~= ""
		self.m_btnGuest:setVisible(false)
	else
		local nickname = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.GUEST_NICKNAME,"Guest")
		self.m_labelNickName:getContentSize()
		self.m_labelNickName:setString(g_StringLib.limitLength(nickname,26,220))
		if nickname == nil or nickname == "" then
			g_NodeUtils:arrangeToLeftCenter(self.m_labelGuest, 60, 0)
		end
	end
	self.m_labelTime:setString(os.date("%H:%M", os.time()))
	self.m_timer = g_Schedule:schedule(function() 
		local timeNow = os.date("%H:%M", os.time())
		if self.m_labelTime:getString() ~= timeNow  then
			self.m_labelTime:setString(os.date("%H:%M", os.time()))
		end
	end, 1)
	self.m_labelVersion:setString(g_SystemInfo:getVersionName())

	self.m_labelReward:setSystemFontSize(g_AppManager:getAdaptiveConfig().Login.rewardFontSize)
end

function LoginScene:initClickListener()
	self.m_btnFB:addClickEventListener(
	  function (send)
			self:doLogic(g_SceneEvent.LOGIN_FACEBOOK)
			self:setBtnEnable(false)
    end
	)
	self.m_btnEmail:addClickEventListener(
		function (send)
			self:showEmailLogin()
		end  
	)
	self.m_btnGuest:addClickEventListener(
		function (send)
				self:doLogic(g_SceneEvent.LOGIN_GUEST)
				self:setBtnEnable(false)
		  end
	)

	self.m_btnHelp:addClickEventListener(
		function (send)
			g_PopupManager:show(g_PopupConfig.S_POPID.HELP_POP,helpType.showTypeLogin)
		end
	)
end

function LoginScene:showEmailLogin()
	g_PopupManager:show(g_PopupConfig.S_POPID.LOGIN_EMAIL_POP)
end

function LoginScene:setBtnEnable(enable)
	self.m_btnEmail:setEnabled(enable)
	self.m_btnFB:setEnabled(enable)
	self.m_btnGuest:setEnabled(enable)
	self.m_btnHelp:setEnabled(enable)
	
	self.m_labelFB:setColor(enable and cc.c3b(255,255,255) or cc.c3b(106,122,154))
	self.m_labelEmail:setColor(enable and cc.c3b(255,255,255) or cc.c3b(98,150,98))
	self.m_labelGuest:setColor(enable and cc.c3b(255,255,255) or cc.c3b(132,97,145))
	self.m_labelNickName:setColor(enable and cc.c3b(224,203,232) or cc.c3b(120,89,132))
end

function LoginScene:onLoginFailed()
	self:setBtnEnable(true)
end

function LoginScene:onEventBack()
	g_AlertDialog.getInstance()
		:setTitle(GameString.get("str_exit_game_title"))
		:setContent(GameString.get("str_exit_game_content"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		:setLeftBtnTx(GameString.get("str_logout_btn_cancel"))
		:setRightBtnTx(GameString.get("str_logout_btn_confirm"))
		:setRightBtnFunc(function()
			cc.Director:getInstance():endToLua()
		end)
		:show()
end

function LoginScene:onEnter()
	ViewScene.onEnter(self)
	if self.m_isBlindEmailReturn then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_blindAccount_succ"))
	end
	self:updateUI()
	self:setBtnEnable(true)
	self:showEnterAnim()
end

function LoginScene:showEnterAnim()
	
	local DelayTime = 0.1
	local Time = 0.2
	local x = 175-640
	self.m_logo:runAction(cc.Sequence:create(cc.DelayTime:create(DelayTime), cc.FadeTo:create(0.1, 255)))

	self.m_btnFB   :runAction(cc.Sequence:create(cc.DelayTime:create(DelayTime  ),cc.MoveBy:create(Time,cc.p(x,0))))
	self.m_btnEmail:runAction(cc.Sequence:create(cc.DelayTime:create(DelayTime*2),cc.MoveBy:create(Time,cc.p(x,0))))
	self.m_btnGuest:runAction(cc.Sequence:create(cc.DelayTime:create(DelayTime*3),cc.MoveBy:create(Time,cc.p(x,0))))
end

return LoginScene;