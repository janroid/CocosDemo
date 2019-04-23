--[[--ldoc desc
@module ChangePwdCtr
@author ReneYang
Date   2018-10-31
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ChangePwdCtr = class("ChangePwdCtr",PopupCtr);
BehaviorExtend(ChangePwdCtr);

---配置事件监听函数
ChangePwdCtr.s_eventFuncMap =  {
	[g_SceneEvent.USER_INFO_MAIL_CHANGE_PWD] = "onChangePwd"
}

function ChangePwdCtr:ctor(delegate)
	PopupCtr.ctor(self,delegate);
end

function ChangePwdCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function ChangePwdCtr:onEnter()
	PopupCtr.onEnter(self);
	-- xxxxxx
end

function ChangePwdCtr:onExit()
	PopupCtr.onExit(self);
	-- xxxxxx
end

function ChangePwdCtr:onChangePwd(newPwd)
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.EMAIL_ACCOUNT_MODIFY_PASSWORD)
	params.encryptPassword1   = NativeCall.lcc_getMD5Hash(newPwd)
	params.encryptPassword2   = NativeCall.lcc_getMD5Hash(newPwd)
	self.m_newPwd = newPwd
	g_HttpManager:doPost(params,self, self.onChangePwdResponse)
end
function ChangePwdCtr:onChangePwdResponse(isSuccess, result)
	if result and tonumber(result) == 1 then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_modify_email_account_pwd_success'))
		local pwd = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_PWD, "")
		if pwd ~= "" then
			cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_PWD, self.m_newPwd)
		end
		g_PopupManager:hidden(g_PopupConfig.S_POPID.CHANGE_PWD_POP)
	else
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
	end
end
return ChangePwdCtr;