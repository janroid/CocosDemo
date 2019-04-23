--[[--ldoc desc
@module SafeBoxSetPasswordCtr
@author MenuZhang
Date   2018-10-25
]]
local PopupCtr = import("app.common.popup").PopupCtr
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SafeBoxSetPasswordCtr = class("SafeBoxSetPasswordCtr",PopupCtr);
BehaviorExtend(SafeBoxSetPasswordCtr);

---配置事件监听函数
SafeBoxSetPasswordCtr.s_eventFuncMap =  {

}

function SafeBoxSetPasswordCtr:ctor()
	PopupCtr.ctor(self);
end


---注册监听事件
function SafeBoxSetPasswordCtr:registerEvent()
	if self.eventFuncMap then
	    for k,v in pairs(self.eventFuncMap) do
	        assert(self[v],"配置的回调函数不存在")
	        g_eventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function SafeBoxSetPasswordCtr:unRegisterEvent()
	if g_eventDispatcher then
		g_eventDispatcher:unRegisterAllEventByTarget(self)
	end	
end


return SafeBoxSetPasswordCtr