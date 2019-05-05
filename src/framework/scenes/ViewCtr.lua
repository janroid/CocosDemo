
local ViewCtr = class("ViewCtr");

---配置事件监听函数
ViewCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
}

function ViewCtr:ctor(scene)
	self:registerEvent(scene);
end

function ViewCtr:onCleanup()
	self._isCleanup = true
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
function ViewCtr:registerEvent(obj)
	if self.s_eventFuncMap then
		for k,v in pairs(self.s_eventFuncMap) do
			assert(self[v],"配置的回调函数不存在")
			g_EventDispatcher:register(k,self,self[v], obj)
		end
	end

end

return ViewCtr;