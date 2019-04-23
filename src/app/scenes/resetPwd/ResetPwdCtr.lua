--[[--ldoc desc
@module ResetPwdCtr
@author ReneYang
Date   2018-10-29
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local ResetPwdCtr = class("ResetPwdCtr",PopupCtr);
BehaviorExtend(ResetPwdCtr);

---配置事件监听函数
ResetPwdCtr.s_eventFuncMap =  {
	[g_SceneEvent.LOGIN_RESET_PWD]   = "resetPwd"
}

function ResetPwdCtr:ctor(delegate)
	PopupCtr.ctor(self,delegate);
end

function ResetPwdCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end
function ResetPwdCtr:show()
	PopupCtr.show(self)
end

function ResetPwdCtr:hidden()
	PopupCtr.hidden(self)
end

function ResetPwdCtr:resetPwd(email)
	local mac 	   = g_SystemInfo:getMacAddr();
    local openUDID = g_SystemInfo:getOpenUDID();
    
    g_HttpManager:cancelAllRequest();
    g_HttpManager:clearDefaultParams();
    local postUrl  = g_AppManager:getSpecialCgi();
    if postUrl == "" then
        postUrl = g_AppManager:getLoginURL().."mobilespecial.php";
    end

	local deviceDetails =  g_SystemInfo:getDeviceDetails() or '';
	local key = os.date("%Y%m%d", os.time());
    local encryptDeviceInfo = g_ToolKit.rc4_encrypt(string.reverse(deviceDetails), key);

    local params = HttpCmd:getMethod(ACCOUNT_LOGIN)
    params.mobile_request 	= g_Base64.encode(mac.."_"..g_AppManager:getEncKey())
    params.mac 			= mac
    params.openUDID 		= (openUDID ~= nil) and g_Base64.encode(openUDID .. "_" .. g_AppManager:getEncKey()) or openUDID
    params.deviceId		= g_SystemInfo:getDeviceId()
    params.deviceName      = g_SystemInfo:getDeviceName()
    params.device			= g_SystemInfo:getDevice()
    params.version			= g_SystemInfo:getVersionName()
    params.platform		= (device.platform and "android" or "iphone")
    params.pay				= g_SystemInfo:getPlay()
    params.email			= email
    params.coalaaemail		= "modify"
    params.deviceDetails   = encryptDeviceInfo
    g_HttpManager:doPostWithUrl(postUrl, params, self, self.onForgetResult);
end

function ResetPwdCtr:onForgetResult(isSuccess,userObj)
    if not isSuccess or not userObj or not userObj.ret  then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"));
		g_PopupManager:hidden(g_PopupConfig.S_POPID.RESET_PWD_POP)
        return;
    end

	local tip = GameString.get("str_login_bad_network")
    if userObj.ret == 1 then --成功
        tip = GameString.get("str_forget_possword_operatr_succeed")
    elseif userObj.ret == -1 then --邮箱不正确
        tip = GameString.get("str_forget_possword_account_wrong")
    elseif userObj.ret == -2 then --一天限制操作5次
        tip = GameString.get("str_forget_possword_failse_more")
    elseif userObj.ret == -104 or userObj.ret == -105 then --重置密码失败
        tip = GameString.get("str_forget_possword_failse")
    elseif userObj.ret == -102 or userObj.ret == -103 then--用户不存在
        tip = GameString.get("str_forget_possword_user_none")
    end

	g_AlarmTips.getInstance():setTextAndShow(tip)
	g_PopupManager:hidden(g_PopupConfig.S_POPID.RESET_PWD_POP)
end

return ResetPwdCtr;