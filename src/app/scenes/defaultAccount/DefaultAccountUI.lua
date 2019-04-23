--[[--ldoc desc
@module DefaultAccountUI
@author RyanXu

Date   2018-11-2
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DefaultAccountUI = class("DefaultAccountUI",PopupBase);
BehaviorExtend(DefaultAccountUI);

local HttpCmd = import("app.config.config").HttpCmd

function DefaultAccountUI:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".DefaultAccountCtr"));
	self:init();
end

function DefaultAccountUI:onCleanup()
	PopupBase.onCleanup(self)
end

function DefaultAccountUI:init()	
	-- 加载布局文件
	self:loadLayout("creator/accountUpgrade/defaultAccount.ccreator");
	
	self.m_btnClose =  g_NodeUtils:seekNodeByName(self,'btn_close') 
	self.m_btnSubmit =  g_NodeUtils:seekNodeByName(self,'btn_submit')

	self.m_ebEmail =  g_NodeUtils:seekNodeByName(self,'eb_email') 
	self.m_ebPassword =  g_NodeUtils:seekNodeByName(self,'eb_password') 

	self.m_txTitle =  g_NodeUtils:seekNodeByName(self,'tx_title')
	self.m_txTips =  g_NodeUtils:seekNodeByName(self,'tx_tips')
	self.m_txSubmit =  g_NodeUtils:seekNodeByName(self,'tx_submit')

	self.m_imgAccountWrong = g_NodeUtils:seekNodeByName(self,'img_account_wrong')
	self.m_imgPasswordWrong = g_NodeUtils:seekNodeByName(self,'img_password_wrong')

	self:initString() 
	self:initListener()
end

function DefaultAccountUI:initString()
	self.m_txTitle:setString(GameString.get("str_defaultAccount_title"))
	self.m_txTips:setString(GameString.get("str_defaultAccount_tips"))
	self.m_txSubmit:setString(GameString.get("str_defaultAccount_submit"))

	self.m_ebEmail:setPlaceHolder(GameString.get("str_login_email_account_hint"))
	self.m_ebPassword:setPlaceHolder(GameString.get("str_login_email_pwd"))
end

function DefaultAccountUI:initListener()

	self.m_btnClose:addClickEventListener(
		function(sender)
			self:hidden()
		end
	)

	self.m_btnSubmit:addClickEventListener(
		function(sender)
			self:submitDefaultAccount(sender)
		end
	)

	local function ebMailEventHandler(eventType)
		if eventType == "began" then
			self.m_imgAccountWrong:setVisible(false)
		elseif eventType == "ended" then
			-- 当编辑框失去焦点并且键盘消失的时候被调用
			if self.m_ebEmail:getText()== "" or self.m_ebEmail:getText()==nil then
				self.m_imgAccountWrong:setVisible(true)
				return
			end
			if not string.isRightEmail(self.m_ebEmail:getText()) then
				self.m_imgAccountWrong:setVisible(true)
			end
		end
	end
	self.m_ebEmail:registerScriptEditBoxHandler(ebMailEventHandler)

	local function ebPasswordAgainEventHandler(eventType)
		if eventType == "began" then
			self.m_imgPasswordWrong:setVisible(false)
		elseif eventType == "ended" then
			if self.m_ebPassword:getText() == nil or self.m_ebPassword:getText() == "" then
				self.m_imgPasswordWrong:setVisible(true)
			end
		end
	end

	self.m_ebPassword:registerScriptEditBoxHandler(ebPasswordAgainEventHandler)
end

function DefaultAccountUI:submitDefaultAccount()
	if not string.isRightEmail(self.m_ebEmail:getText()) then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_login_email_error"))
		return
	end

	if self.m_ebPassword:getText() == nil or self.m_ebPassword:getText() == "" then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_login_password_error"))
	end 

	local param = HttpCmd:getMethod(HttpCmd.s_cmds.CHECK_EMAIL)
	param.email = self.m_ebEmail:getText()
	param.encryptPassword = NativeCall.lcc_getMD5Hash(self.m_ebPassword:getText())
	g_HttpManager:doPost(param, self, self.onSetAccountSuccess, self.onSetAccountFailed);
end

function DefaultAccountUI:onSetAccountSuccess(isSuccess, response , param)
	Log.d("DefaultAccountUI:onSetAccountSuccess",isSuccess,response)
    if not isSuccess then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
    else
    	if response == 1 then
    		g_PopupManager:hiddenAllPops()
		    if DEBUG == 0 then
			    cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL,param.email)
			    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_GUEST_BINDED_EMAIL, {bindedEmail = true})
			    g_EventDispatcher:dispatch(g_SceneEvent.UPGRADE_ACCOUNT_HIDE_UPGRADE_BTN)
			    g_AppManager.m_guestBindedEmail = true
		    end
    		local SceneLogin = import("app.scenes.login").scene
    		cc.Director:getInstance():replaceScene(SceneLogin:create(nil,true))
    		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_createAccount_succ"))
    	elseif response == -1 then
    		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_login_email_error"))
    	elseif response == -2 then
    		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_login_password_error"))
    	end
    end
end

function DefaultAccountUI:onSetAccountFailed()
	g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
end

---刷新界面
function DefaultAccountUI:updateView(data)
	data = checktable(data);
end

return DefaultAccountUI;