--[[--ldoc desc
@module CardCalculatorCtr
@author %s
Date   %s
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local CardCalculatorCtr = class("CardCalculatorCtr",PopupCtr);
BehaviorExtend(CardCalculatorCtr);

---配置事件监听函数
CardCalculatorCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
}

function CardCalculatorCtr:ctor()
	PopupCtr.ctor(self);
end

function CardCalculatorCtr:show()
	PopupCtr.show(self)
end

function CardCalculatorCtr:hidden()
	PopupCtr.hidden(self)
end

function CardCalculatorCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end



return CardCalculatorCtr;