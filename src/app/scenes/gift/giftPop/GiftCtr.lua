--[[--ldoc desc
@module GiftCtr
@author %s
Date   %s
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local GiftCtr = class("GiftCtr",PopupCtr);
BehaviorExtend(GiftCtr);

---配置事件监听函数
GiftCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function GiftCtr:ctor()
	PopupCtr.ctor(self);
end

function GiftCtr:show()
	PopupCtr.show(self)
end

function GiftCtr:hidden()
	PopupCtr.hidden(self)
end

function GiftCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end



return GiftCtr;