
local ViewCtr = class("ViewCtr");

---配置事件监听函数
ViewCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
}

function ViewCtr:ctor()
	self:registerEvent();
end

function ViewCtr:onCleanup()
	self._isCleanup = true
	self:unRegisterEvent();
end

function ViewCtr:onEnter()

end
function ViewCtr:onExit()

end
function ViewCtr:onEnterTransitionFinish()

end
function ViewCtr:onExitTransitionStart()

end

---注册监听事件
function ViewCtr:registerEvent()
	local obj = self
	local supers = {obj}
	while obj.super do
		supers[#supers + 1] = obj.super
		obj = obj.super
	end
	for i = #supers, 1, -1 do
		local super = supers[i]
		if super.s_eventFuncMap then
			for k,v in pairs(super.s_eventFuncMap) do
				assert(self[v],"配置的回调函数不存在")
				g_EventDispatcher:register(k,self,self[v])
			end
		end
	end
end

---取消事件监听
function ViewCtr:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

--- 调用UI函数
function ViewCtr:updateView(mEvent, ...)
	g_EventDispatcher:dispatch(mEvent, ...)
end

return ViewCtr;