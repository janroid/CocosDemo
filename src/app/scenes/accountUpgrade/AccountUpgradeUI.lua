--[[--ldoc desc
@module AccountUpgradeUI
@author ReneYang

Date   2018-10-25
]]
local PopupBase = import("app.common.popup").PopupBase

local HttpCmd = import("app.config.config").HttpCmd

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AccountUpgradeUI = class("AccountUpgradeUI",PopupBase);
BehaviorExtend(AccountUpgradeUI);

function AccountUpgradeUI:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".AccountUpgradeCtr"));
	self:init();
end

function AccountUpgradeUI:onCleanup()
	PopupBase.onCleanup(self)
	if self.m_countDownEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_countDownEntry)
	end
end

function AccountUpgradeUI:init()
	self:loadLayout("creator/accountUpgrade/accountUpgrade.ccreator");

	self.m_btnBack =  g_NodeUtils:seekNodeByName(self,'btn_back') 
	self.m_btnGetVerify =  g_NodeUtils:seekNodeByName(self,'btn_get_verify')
	self.m_btnHadAccount =  g_NodeUtils:seekNodeByName(self,'btn_had_account') 
	self.m_btnUpgrade =  g_NodeUtils:seekNodeByName(self,'btn_upgrade')

	self.m_ebMail =  g_NodeUtils:seekNodeByName(self,'eb_mail') 
	self.m_ebVerify =  g_NodeUtils:seekNodeByName(self,'eb_verify') 
	self.m_ebPassword =  g_NodeUtils:seekNodeByName(self,'eb_password') 
	self.m_ebPasswordAgain =  g_NodeUtils:seekNodeByName(self,'eb_password_again')
	 
	self.m_txCountDown =  g_NodeUtils:seekNodeByName(self,'tx_count_down')
	self.m_txGetVerify =  g_NodeUtils:seekNodeByName(self,'tx_get_verify')
	self.m_txDesc =  g_NodeUtils:seekNodeByName(self,'tx_desc') 
	self.m_txHadAccount =  g_NodeUtils:seekNodeByName(self,'tx_had_account') 
	self.m_txUpgrade =  g_NodeUtils:seekNodeByName(self,'tx_upgrade')

	self.m_imgMailTick =  g_NodeUtils:seekNodeByName(self,'mail_tick') 
	self.m_imgMailCross =  g_NodeUtils:seekNodeByName(self,'mail_cross') 
	self.m_imgVerifyTick =  g_NodeUtils:seekNodeByName(self,'verify_tick') 
	self.m_imgVerifyCross =  g_NodeUtils:seekNodeByName(self,'verify_cross') 
	self.m_imgPasswordTick =  g_NodeUtils:seekNodeByName(self,'password_tick') 
	self.m_imgPasswordCross =  g_NodeUtils:seekNodeByName(self,'password_cross') 
	self.m_imgPasswordAgainTick =  g_NodeUtils:seekNodeByName(self,'password_again_tick') 
	self.m_imgPasswordAgainCross =  g_NodeUtils:seekNodeByName(self,'password_again_cross') 

	self.m_txHadAccount:setSystemFontSize(g_AppManager:getAdaptiveConfig().Login.upgradeBtnFontSize)
	self.m_txUpgrade:setSystemFontSize(g_AppManager:getAdaptiveConfig().Login.upgradeBtnFontSize)

	self:initString();
	self:initListener();
	self:initState();
end

function AccountUpgradeUI:initString()
	self.m_txGetVerify:setString(GameString.get("str_accountUpgrade_getVerifyCode"))
	self.m_txDesc:setString(GameString.get("str_accountUpgrade_desc"))
	self.m_txHadAccount:setString(GameString.get("str_accountUpgrade_hadAccount"))
	self.m_txUpgrade:setString(GameString.get("str_accountUpgrade_freeUpgrade"))

	self.m_ebMail:setPlaceHolder(GameString.get("str_accountUpgrade_mail"))
	self.m_ebVerify:setPlaceHolder(GameString.get("str_accountUpgrade_verifyCode"))
	self.m_ebPassword:setPlaceHolder(GameString.get("str_login_email_pwd"))
	self.m_ebPasswordAgain:setPlaceHolder(GameString.get("str_accountUpgrade_passwordAgain"))
end

function AccountUpgradeUI:initState()
	self.m_btnGetVerify:setEnabled(false)
end

function AccountUpgradeUI:initListener()

	self.m_btnBack:addClickEventListener(
		function(sender)
			self:hidden()
		end
	)

	self.m_btnGetVerify:addClickEventListener(
		function (sender) 
			self:onBtnGetVerifyClick(sender)
		end
	)

	local function checkEditBox()
		local result = true
		if self.m_ebMail:getText()=="" or self.m_ebMail:getText()==nil then
			self.m_imgMailCross:setVisible(true)
			result = false
		end

		if not string.isRightEmail(self.m_ebMail:getText()) then
			self.m_imgMailCross:setVisible(true)
			result = false
		end

		if self.m_ebVerify:getText()=="" or self.m_ebVerify:getText()==nil then
			self.m_imgVerifyCross:setVisible(true)
			result = false 
		else
			self.m_imgVerifyTick:setVisible(true)
		end

		if self.m_ebPassword:getText()=="" or self.m_ebPassword:getText()==nil then
			self.m_imgPasswordCross:setVisible(true)
			result = false
		else
			self.m_imgPasswordTick:setVisible(true)
		end

		if self.m_ebPasswordAgain:getText()=="" or self.m_ebPasswordAgain:getText()==nil then
			self.m_imgPasswordAgainCross:setVisible(true)
			result = false
		else
			self.m_imgPasswordAgainTick:setVisible(true)
		end

		return result
	end

	self.m_btnHadAccount:addClickEventListener(
		function (sender) 
			-- checkEditBox()
			g_PopupManager:show(g_PopupConfig.S_POPID.DEFAULT_ACCOUNT_POP)
		end
	)

	self.m_btnUpgrade:addClickEventListener(
		function (sender) 
			if checkEditBox() then
				self:onCreateAccount()
			end
		end
	)

	local function ebMailEventHandler(eventType)
		if eventType == "began" then
			-- 点击编辑框,输入法显示
			-- self.m_btnGetVerify:setEnabled(false)
			self.m_imgMailTick:setVisible(false)
			self.m_imgMailCross:setVisible(false)
		elseif eventType == "ended" then
			-- 当编辑框失去焦点并且键盘消失的时候被调用
			if self.m_ebMail:getText()=="" or self.m_ebMail:getText()==nil then
				self.m_imgMailTick:setVisible(false)
				self.m_imgMailCross:setVisible(false)
				return
			end
			if string.isRightEmail(self.m_ebMail:getText()) then
				self.m_imgMailTick:setVisible(true)
				self.m_imgMailCross:setVisible(false)
				self.m_btnGetVerify:setEnabled(true)
			else
				self.m_imgMailTick:setVisible(false)
				self.m_imgMailCross:setVisible(true)
				self.m_btnGetVerify:setEnabled(false)
			end
		elseif eventType == "changed" then
			-- 输入内容改变时调用
		elseif eventType == "return" then
			-- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		end
	end
	self.m_ebMail:registerScriptEditBoxHandler(ebMailEventHandler)

	local function ebPasswordAgainEventHandler(eventType)
		if eventType == "began" then
			-- 点击编辑框,输入法显示
			self.m_imgPasswordAgainTick:setVisible(false)
			self.m_imgPasswordAgainCross:setVisible(false)
		elseif eventType == "ended" then
			-- 当编辑框失去焦点并且键盘消失的时候被调用
			if self.m_ebPassword:getText() ~= self.m_ebPasswordAgain:getText() then
				
			end
		elseif eventType == "changed" then
			-- 输入内容改变时调用
		elseif eventType == "return" then
			-- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		end
	end

	self.m_ebPasswordAgain:registerScriptEditBoxHandler(ebPasswordAgainEventHandler)

	local function ebVerifyEventHandler(eventType)
		if eventType == "began" then
			-- 点击编辑框,输入法显示
			self.m_imgVerifyTick:setVisible(false)
			self.m_imgVerifyCross:setVisible(false)
		elseif eventType == "ended" then
			-- 当编辑框失去焦点并且键盘消失的时候被调用
		elseif eventType == "changed" then
			-- 输入内容改变时调用
		elseif eventType == "return" then
			-- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		end
	end
	self.m_ebVerify:registerScriptEditBoxHandler(ebVerifyEventHandler)

	local function ebPasswordEventHandler(eventType)
		if eventType == "began" then
			-- 点击编辑框,输入法显示
			self.m_imgPasswordTick:setVisible(false)
			self.m_imgPasswordCross:setVisible(false)
		elseif eventType == "ended" then
			-- 当编辑框失去焦点并且键盘消失的时候被调用
		elseif eventType == "changed" then
			-- 输入内容改变时调用
		elseif eventType == "return" then
			-- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		end
	end
	self.m_ebPassword:registerScriptEditBoxHandler(ebPasswordEventHandler)
end

---刷新界面
function AccountUpgradeUI:updateView(data)
	data = checktable(data);
end

function AccountUpgradeUI:onBtnGetVerifyClick( sender )
 	if not string.isRightEmail(self.m_ebMail:getText()) then
 		return 
 	end

 	self.m_btnGetVerify:setVisible(false);
	self.m_txCountDown:setVisible(true);
	self.m_countIndex = 120
	self.m_countDownEntry = nil
	local function callback(dt)
		if self.m_countIndex == 0 then
			self.m_txCountDown:setString("");
			self.m_btnGetVerify:setVisible(true);
			self.m_txCountDown:setVisible(false);
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_countDownEntry)
			return
		end
		self.m_txCountDown:setString(self.m_countIndex .. "s");
		self.m_countIndex = self.m_countIndex - 1
	end
	callback()
	self.m_countDownEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 1, false)

    local param = HttpCmd:getMethod(HttpCmd.s_cmds.GET_EMAIL_VERIFY)
	param.email = self.m_ebMail:getText()
	g_HttpManager:doPost(param, self, self.onRequestVerifySuccess, self.onRequestVerifyFailed);
end

function AccountUpgradeUI:onRequestVerifySuccess(isSuccess, response)
    if not isSuccess or not g_TableLib.isTable(response) then
    	self.m_countIndex = 0
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
    else
    	if response.ret ~= 1 then
    		self.m_countIndex = 0
    		if response.ret == -1 then
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_verifyError1"))
			elseif response.ret == -2 then
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_verifyError2"))
			elseif response.ret == -3 then
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_verifyError3"))
			elseif response.ret == -4 then
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_verifyError4"))
			end
    	end
    end
end

function AccountUpgradeUI:onRequestVerifyFailed()
	g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
end

function AccountUpgradeUI:onCreateAccount()

  	local param = HttpCmd:getMethod(HttpCmd.s_cmds.BIND_EMAIL)

	param.mac = g_SystemInfo:getMacAddr()
    param.openUDID = g_SystemInfo:getOpenUDID()
    param.email = self.m_ebMail:getText()
    param.token = self.m_ebVerify:getText()
    param.isNew = 1 -- 新版邮箱验证，需要验证码
    param.encryptPassword1 = NativeCall.lcc_getMD5Hash(self.m_ebPassword:getText())
    param.encryptPassword2 = NativeCall.lcc_getMD5Hash(self.m_ebPasswordAgain:getText())

	param.field = roomRank
	g_HttpManager:doPost(param, self, self.onCreateAccountSuccess, self.onCreateAccountFailed);

	g_Progress.getInstance():show()
end

function AccountUpgradeUI:onCreateAccountSuccess(isSuccess, response, param)
	g_Progress.getInstance():dismiss()

	Log.d('onCreateAccountSuccess',isSuccess,response,param)
    if not isSuccess then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
    else
    	if response == 0 then
    		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_existAccount"))
    	elseif response == 1 then
    		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_accountUpgrade_createAccount_succ"))
    		self:hidden()
		    g_AccountInfo:setLoginFrom(g_AccountInfo.S_LOGIN_FROM.EMAIL)
		    if DEBUG == 0 then
			    cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL,param.email)
			    g_EventDispatcher:dispatch(g_SceneEvent.UPGRADE_ACCOUNT_HIDE_UPGRADE_BTN)
			    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_GUEST_BINDED_EMAIL, {bindedEmail = true})
			    g_AppManager.m_guestBindedEmail = true
		    end
    	elseif response == -1 then
    		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_login_email_error"))
    	end
    end
end

function AccountUpgradeUI:onCreateAccountFailed()
	g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
end

return AccountUpgradeUI;