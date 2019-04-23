--[[--ldoc desc
@module RoomTaskCtr
@author %s
Date   %s
]]
local DailyTaskCtr = require("DailyTaskCtr")
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RoomTaskCtr = class("RoomTaskCtr",DailyTaskCtr);
BehaviorExtend(RoomTaskCtr);

-- ---配置事件监听函数
-- RoomTaskCtr.eventFuncMap =  {
-- 	-- ["EventKey"] = "FuncName"
-- 	-- EventKey必须定义在SceneEvent.lua中
-- 	-- 与UI的通信调用参见PopupCtr.updateView函数	
-- }

-- function RoomTaskCtr:ctor()
-- 	PopupCtr.ctor(self);
-- end

-- function RoomTaskCtr:show()
-- 	PopupCtr.show(self)
-- 	-- self:registerEvent()
-- end

-- function RoomTaskCtr:hidden()
-- 	PopupCtr.hidden(self)
-- end

-- function RoomTaskCtr:onCleanup()
-- 	PopupCtr.onCleanup(self);
-- 	-- xxxxxx
-- 	self:unRegisterEvent()
-- end

-- function RoomTaskCtr:onEnter()
-- 	PopupCtr.onEnter(self, false);
-- 	-- xxxxxx
-- end

-- function RoomTaskCtr:onExit()
-- 	PopupCtr.onCleanup(self, false);
-- 	-- xxxxxx
-- end

return RoomTaskCtr;