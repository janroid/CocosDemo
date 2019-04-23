--[[--ldoc desc
@module SafeBoxPasswordCtr
@author MenuZhang
Date   2018-10-25
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SafeBoxPasswordCtr = class("SafeBoxPasswordCtr",PopupCtr);
BehaviorExtend(SafeBoxPasswordCtr);

---配置事件监听函数
SafeBoxPasswordCtr.s_eventFuncMap =  {

}

function SafeBoxPasswordCtr:ctor()
	PopupCtr.ctor(self)
end


---注册监听事件
function SafeBoxPasswordCtr:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        assert(self[v],"配置的回调函数不存在")
	        g_eventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function SafeBoxPasswordCtr:unRegisterEvent()
	if g_eventDispatcher then
		g_eventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

return SafeBoxPasswordCtr