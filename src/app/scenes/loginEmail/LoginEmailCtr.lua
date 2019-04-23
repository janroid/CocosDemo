--[[--ldoc desc
@module LoginEmailCtr
@author ReneYang
Date   2018-10-26
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local LoginEmailCtr = class("LoginEmailCtr",PopupCtr);
BehaviorExtend(LoginEmailCtr);

---配置事件监听函数
LoginEmailCtr.eventFuncMap =  {
}

function LoginEmailCtr:ctor(delegate)
	PopupCtr.ctor(self,delegate);
end

function LoginEmailCtr:show()
	PopupCtr.show(self)
end

function LoginEmailCtr:hidden()
	PopupCtr.hidden(self)
end

function LoginEmailCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function LoginEmailCtr:requestLogin(email, pwd)
	g_EventDispatcher:dispatch(g_SceneEvent.LOGIN_EMAIL,email, pwd)
end


return LoginEmailCtr;