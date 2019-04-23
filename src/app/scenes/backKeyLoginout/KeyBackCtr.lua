--[[--ldoc 点击返回键的弹窗
@module KeyBackPop
@author jamesLiang

Date   2019-1-22
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local KeyBackCtr = class("KeyBackCtr",PopupCtr);
BehaviorExtend(KeyBackCtr);

---配置事件监听函数
KeyBackCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function KeyBackCtr:ctor()
	PopupCtr.ctor(self);
end

function KeyBackCtr:show()
	PopupCtr.show(self)
end

function KeyBackCtr:hidden()
	PopupCtr.hidden(self)
end

function KeyBackCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function KeyBackCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function KeyBackCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return KeyBackCtr;