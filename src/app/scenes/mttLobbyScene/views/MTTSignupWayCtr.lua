--[[--ldoc desc
@module MTTSignupWayCtr
@author CavanZhou
Date   2018-12-24
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MTTSignupWayCtr = class("MTTSignupWayCtr",PopupCtr);
BehaviorExtend(MTTSignupWayCtr);

---配置事件监听函数
MTTSignupWayCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function MTTSignupWayCtr:ctor()
	PopupCtr.ctor(self);
end

function MTTSignupWayCtr:show()
	PopupCtr.show(self)
end

function MTTSignupWayCtr:hidden()
	PopupCtr.hidden(self)
end

function MTTSignupWayCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function MTTSignupWayCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function MTTSignupWayCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return MTTSignupWayCtr;