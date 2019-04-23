local ViewBase = cc.load("mvc").ViewBase

function ViewBase:onEnter()
	if self.mCtr then
		self.mCtr:onEnter()
	end
end
function ViewBase:onExit()
	if self.mCtr then
		self.mCtr:onExit()
	end
end
function ViewBase:onEnterTransitionFinish()
	if self.mCtr then
		self.mCtr:onEnterTransitionFinish()
	end
end
function ViewBase:onExitTransitionStart()
	if self.mCtr then
		self.mCtr:onExitTransitionStart()
	end
end
function ViewBase:onCleanup()
	if self.mCtr then
		self.mCtr:onCleanup()
	end
end

---绑定控制器
function ViewBase:bindCtr(ctrClass, ...)
	if self.mCtr then
		print("already bind ViewCtr");
		return false;
	else
		if ctrClass then
			self.mCtr = ctrClass:create(self, ...);
			-- self:addChild(self.mCtr);
			return true;
		end
	end
end

---解除控制器的绑定
function ViewBase:unBindCtr()
	if self.mCtr then
		-- self:removeChild(self.mCtr,true);
		self.mCtr = nil;
	else
		print("unBindViewCtr failed");
	end
end

---注册监听事件
function ViewBase:registerEvent()
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
function ViewBase:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

---加载布局文件
function ViewBase:loadLayout(viewLayout)
	return g_NodeUtils:getRootNodeInCreator(viewLayout);
end

function ViewBase:seekNodeByName(name)
	return g_NodeUtils:seekNodeByName(self,name)
end

--- 触发逻辑处理
function ViewBase:doLogic(mEvent, ...)
	g_EventDispatcher:dispatch(mEvent, ...)
end