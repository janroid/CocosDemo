--[[--ldoc desc
@module SuperLottoCtr
@author RyanXu
Date   2018-12-24
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SuperLottoCtr = class("SuperLottoCtr",PopupCtr);
BehaviorExtend(SuperLottoCtr);

---配置事件监听函数
SuperLottoCtr.eventFuncMap =  {
}

function SuperLottoCtr:ctor()
	PopupCtr.ctor(self);
end

function SuperLottoCtr:show()
	PopupCtr.show(self)
end

function SuperLottoCtr:hidden()
	PopupCtr.hidden(self)
end

function SuperLottoCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function SuperLottoCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function SuperLottoCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return SuperLottoCtr;