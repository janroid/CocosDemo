--[[--ldoc desc
@module LoginEmailPop
@author ReneYang

Date   2018-10-26
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local LoginEmailPop = class("LoginEmailPop",PopupBase);
BehaviorExtend(LoginEmailPop);

-- 配置事件监听函数
LoginEmailPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function LoginEmailPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".LoginEmailCtr"));
	self:init();
end

function LoginEmailPop:show()
	PopupBase.show(self)
end

function LoginEmailPop:hidden()
	PopupBase.hidden(self)
end

function LoginEmailPop:init()
	-- do something
	

	-- 加载布局文件
	self:loadLayout("creator/login/emailLoginScene.ccreator");
	

	self.m_labelTitle = g_NodeUtils:seekNodeByName(self,'labelTitle') 
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btnClose')
	self.m_labelAccount = g_NodeUtils:seekNodeByName(self,'labelAccount') 
	self.m_etAccount = g_NodeUtils:seekNodeByName(self,'editboxAccount')
	self.m_imgAccountCorrect = g_NodeUtils:seekNodeByName(self,'accountCorrect')
	self.m_labelPwd = g_NodeUtils:seekNodeByName(self,'labelPwd')
	self.m_etPwd = g_NodeUtils:seekNodeByName(self,'editboxPwd')
	self.m_imgPwdCorrect = g_NodeUtils:seekNodeByName(self,'pwdCorrect')
	self.m_checkRemPwd = g_NodeUtils:seekNodeByName(self,'toggleRememberPwd')
	self.m_labelRemPwd = g_NodeUtils:seekNodeByName(self,'labelRememberPwd')
	self.m_btnForgetPwd = g_NodeUtils:seekNodeByName(self,'btnForgetPwd')
	self.m_labelForgetPwd = g_NodeUtils:seekNodeByName(self,'labelForgetPwd')
	self.m_labelTips = g_NodeUtils:seekNodeByName(self,'labelTips')
	self.m_btnLogin = g_NodeUtils:seekNodeByName(self,'btnLogin')
	self.m_labelLogin = g_NodeUtils:seekNodeByName(self,'labelLogin')
	self.m_toggleRemPwd = g_NodeUtils:seekNodeByName(self, 'toggleRemPwd')
	self.m_btnRemPwd = g_NodeUtils:seekNodeByName(self, 'btnRemPwd')

	self.m_imgAccountCorrect:setVisible(false)
	self.m_imgPwdCorrect:setVisible(false)
	self:initString()
	self:initListener()
	self:initUI()
end

function LoginEmailPop:initUI()
	local email = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_LOGIN,"")
	if email==nil or email=="" then
		email = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL,"")
	end
	local pwd = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_PWD, "")
	local remPwd = cc.UserDefault:getInstance():getBoolForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_REMEBER_PWD, false)
	self.m_etAccount:setText(email)
	self.m_etPwd:setText(pwd)
	self.m_toggleRemPwd:setSelected(remPwd)
end

function LoginEmailPop:initString()
	self.m_labelTitle:setString(GameString.get("str_login_email_title"))
	self.m_labelAccount:setString(GameString.get("str_login_email_account"))
	self.m_labelPwd:setString(GameString.get("str_login_email_pwd"))
	self.m_labelRemPwd:setString(GameString.get("str_login_email_remember_pwd"))
	self.m_labelForgetPwd:setString(GameString.get("str_login_email_forgot_pwd"))
	self.m_labelTips:setString(GameString.get("str_login_email_content"))
	self.m_labelLogin:setString(GameString.get("str_login_email_login"))
	self.m_etAccount:setPlaceHolder(GameString.get("str_login_email_account_hint"))
	self.m_etPwd:setPlaceHolder(GameString.get("str_login_email_pwd"))
	
end

function LoginEmailPop:initListener()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:hidden()
		end
	)
	self.m_btnRemPwd:addClickEventListener(
		function (sender)
			self.m_toggleRemPwd:setSelected(not self.m_toggleRemPwd:isSelected())
		end
	)
	self.m_btnForgetPwd:addClickEventListener(
		function (sender)
			self:showForgetPwdPop()
		end
	)
	self.m_btnLogin:addClickEventListener(
		function (sender )
			local isAccountCorrect = self:judgeAccount(true)
			local isPwdCorrect = self:judgePwd(true)
			if isAccountCorrect and isPwdCorrect then
				
				local email = self.m_etAccount:getText()
				cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_REMEBER_PWD, self.m_toggleRemPwd:isSelected())
				local pwd = self.m_etPwd:getText()
				cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_LOGIN, email)
				if self.m_toggleRemPwd:isSelected() then
					cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_PWD, pwd)
				else
					cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_PWD, "")
				end
				self.mCtr:requestLogin(email, pwd)
				self:hidden()
			end
		end
	)
	self.m_etAccount:registerScriptEditBoxHandler(
		function(eventType)
			if eventType == "ended" then
				-- 当编辑框失去焦点并且键盘消失的时候被调用
				self:judgeAccount()
			end
		end
	)
	self.m_etPwd:registerScriptEditBoxHandler(
		function(eventType)
			if eventType == "ended" then
				-- 当编辑框失去焦点并且键盘消失的时候被调用
				self:judgePwd()
			end
		end
	)

end

function LoginEmailPop:judgeAccount(nilShowError)
	local emailFormatResult = g_EmailUtil.judgeEmailFormat(self.m_etAccount:getText())
	if emailFormatResult == g_EmailUtil.S_FORMAT_RESULT.STR_IS_EMPTY then
		if nilShowError then
			self.m_imgAccountCorrect:setVisible(true)
			self.m_imgAccountCorrect:setTexture("creator/common/symbol/cross.png")
		else
			self.m_imgAccountCorrect:setVisible(false)
		end
		return false
	end
	self.m_imgAccountCorrect:setVisible(true)
	if emailFormatResult ==  g_EmailUtil.S_FORMAT_RESULT.CORRECT_FORMAT then
		self.m_imgAccountCorrect:setTexture("creator/common/symbol/tick.png")
		return true
	else
		self.m_imgAccountCorrect:setTexture("creator/common/symbol/cross.png")
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_email_format_error"))
		return false
	end
	return true
end

function LoginEmailPop:judgePwd(nilShowError)
	if string.len(self.m_etPwd:getText()) == 0 then
		if nilShowError then
			self.m_imgPwdCorrect:setVisible(true)
			self.m_imgPwdCorrect:setTexture("creator/common/symbol/cross.png")
		else
			self.m_imgPwdCorrect:setVisible(false)
		end
		return false
	else
		self.m_imgPwdCorrect:setVisible(true)
		self.m_imgPwdCorrect:setTexture("creator/common/symbol/tick.png")
	end
	return true
end

function LoginEmailPop:showForgetPwdPop()
	g_PopupManager:show(g_PopupConfig.S_POPID.RESET_PWD_POP)
end


function LoginEmailPop:onCleanup()
	PopupBase.onCleanup(self)
end

return LoginEmailPop;