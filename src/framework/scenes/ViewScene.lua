
local SceneBase = cc.load("mvc").SceneBase;
local ViewScene = class("ViewScene",SceneBase);

-- 配置事件监听函数
ViewScene.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
}

function ViewScene:ctor(app,name)
	SceneBase.ctor(self,app,name);
	self:registerEvent();
    g_EventDispatcher:register(g_CustomEvent.EVENT_BACK,self,self.onKeyBack)
end

function ViewScene:onKeyBack()
	local runningScene = cc.Director:getInstance():getRunningScene()
    if not g_PopupManager:hasShowingPop() and self == runningScene then
       self:onEventBack()
    end
end

-- 子类复写方法
function ViewScene:onEventBack()
	cc.Director:getInstance():popScene()
end

function ViewScene:onCleanup( )
	if self.mCtr then
		self.mCtr:onCleanup()
	end
	self:unBindCtr()
end

function ViewScene:onEnter()
	if self.mCtr then
		self.mCtr:onEnter()
	end
end
function ViewScene:onExit()
	if self.mCtr then
		self.mCtr:onExit()
	end
end
function ViewScene:onEnterTransitionFinish()
	if self.mCtr then
		self.mCtr:onEnterTransitionFinish()
	end
end
function ViewScene:onExitTransitionStart()
	if self.mCtr then
		self.mCtr:onExitTransitionStart()
	end
end

---绑定控制器
function ViewScene:bindCtr(ctrClass, ...)
	if not ctrClass then
		return;
	end

	if self.mCtr then
		Log.e("ViewScene:bindCtr","already bind ViewCtr");
		return false;
	else
		if ctrClass then
			local map = {...}
			self.mCtr = ctrClass:create(self, unpack(map));
			
			return true;
		end
	end
end

---解除控制器的绑定
function ViewScene:unBindCtr()
	if self.mCtr then
		self.mCtr = nil;
	else
		Log.e("ViewScene:unBindCtr","unBindViewCtr failed");
	end
end

---注册监听事件
function ViewScene:registerEvent()
	local obj = self
	if self.s_eventFuncMap then
		for k,v in pairs(self.s_eventFuncMap) do
			assert(self[v],"配置的回调函数不存在")
			g_EventDispatcher:register(k,self,self[v],obj)
		end
	end
end

---加载布局文件
function ViewScene:loadLayout(viewLayout)
	local root,animManager = g_NodeUtils:getRootNodeInCreator(viewLayout)
	self.m_root = root
    self:add(root)

	return animManager
end

function ViewScene:seekNodeByName(view,name)
	if name then
		return g_NodeUtils:seekNodeByName(view,name)
	else
		return g_NodeUtils:seekNodeByName(self,view)
	end
end

--- 触发逻辑处理
function ViewScene:doLogic(mEvent, ...)
	g_EventDispatcher:dispatchEvent(mEvent, ...)
end

return ViewScene;