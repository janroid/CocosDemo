--[[--ldoc desc
@module DealerCtr
@author RyanXu
Date   2018-12-24
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DealerCtr = class("DealerCtr",PopupCtr);
BehaviorExtend(DealerCtr);

---配置事件监听函数
DealerCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function DealerCtr:ctor()
	PopupCtr.ctor(self);
end

function DealerCtr:show()
	PopupCtr.show(self)
end

function DealerCtr:hidden()
	PopupCtr.hidden(self)
end

function DealerCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function DealerCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function DealerCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return DealerCtr;