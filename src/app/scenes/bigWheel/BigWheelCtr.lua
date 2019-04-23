--[[--ldoc desc
@module BigWheelCtr
@author RyanXu
Date   2018-12-12
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BigWheelCtr = class("BigWheelCtr",PopupCtr);
BehaviorExtend(BigWheelCtr);

---配置事件监听函数
BigWheelCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function BigWheelCtr:ctor()
	PopupCtr.ctor(self);
end

function BigWheelCtr:show()
	PopupCtr.show(self)
end

function BigWheelCtr:hidden()
	PopupCtr.hidden(self)
end

function BigWheelCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function BigWheelCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function BigWheelCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return BigWheelCtr;