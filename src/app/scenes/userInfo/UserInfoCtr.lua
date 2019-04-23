--[[--ldoc desc
@module UserInfoCtr
@author CloudKe
Date   2018-10-30
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local UserInfoCtr = class("UserInfoCtr",PopupCtr);
BehaviorExtend(UserInfoCtr);

---配置事件监听函数
UserInfoCtr.s_eventFuncMap =  {
	[g_SceneEvent.REQUEST_USER_INFO] = "requestUserInfo";
}

function UserInfoCtr:ctor()
	PopupCtr.ctor(self);
end

function UserInfoCtr:requestUserInfo()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_MAIN)
	g_HttpManager:doPost(params,self,self.onUserInfoCallBack)
end

function UserInfoCtr:onUserInfoCallBack(isSuccess, data)
	Log.d("UserInfoCtr:onUserInfoCallBack",isSuccess,data)
	if isSuccess and next(data) ~= nil then
        g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_INFO_SUCCESS,data)
    else
        Log.e("UserInfoCtr:onUserInfoCallBack", "decode json has an error occurred!");
    end
end

function UserInfoCtr:onCleanup()
	PopupCtr.onCleanup(self);
end

return UserInfoCtr;