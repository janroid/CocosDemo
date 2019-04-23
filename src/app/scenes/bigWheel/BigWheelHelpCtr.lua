--[[--ldoc desc
@module BigWheelHelpCtr

]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BigWheelHelpCtr = class("BigWheelHelpCtr",PopupCtr);
BehaviorExtend(BigWheelHelpCtr);

---配置事件监听函数
BigWheelHelpCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function BigWheelHelpCtr:ctor()
	PopupCtr.ctor(self);
end

function BigWheelHelpCtr:show()
	PopupCtr.show(self)
end

function BigWheelHelpCtr:hidden()
	PopupCtr.hidden(self)
end

function BigWheelHelpCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function BigWheelHelpCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function BigWheelHelpCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return BigWheelHelpCtr;