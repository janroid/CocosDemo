--[[--ldoc desc
@module GiftDetailePopCtr
@author %s
Date   %s
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local GiftDetailePopCtr = class("GiftDetailePopCtr",PopupCtr);
BehaviorExtend(GiftDetailePopCtr);

---配置事件监听函数
GiftDetailePopCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function GiftDetailePopCtr:ctor()
	PopupCtr.ctor(self);
end

function GiftDetailePopCtr:show()
	PopupCtr.show(self)
end

function GiftDetailePopCtr:hidden()
	PopupCtr.hidden(self)
end

function GiftDetailePopCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end



return GiftDetailePopCtr;