--[[--ldoc desc
@module SettingCtr
@author JohnsonZhang
Date   2018-11-8
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SettingCtr = class("SettingCtr",ViewCtr);
BehaviorExtend(SettingCtr);

---配置事件监听函数
SettingCtr.s_eventFuncMap =  {
	[g_SceneEvent.SETTING_LOGOUT]		= "onLogout";
}

function SettingCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function SettingCtr:onCleanup()
	ViewCtr.onCleanup(self);
end


function SettingCtr:onLogout()
	if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
		NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_LOGOUT_FACEBOOK)
	end
	g_AccountInfo:reset()
	local loginScene = import("app.scenes.login").scene
	cc.Director:getInstance():replaceScene(loginScene:create())    

	
end

return SettingCtr;