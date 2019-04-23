--[[--ldoc desc
@module ChooseMTTorSNGpop
@author JamesLiang

Date   2019-01-21
]]
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RoomGameReviewPopCtr = class("RoomGameReviewPopCtr",PopupCtr);
BehaviorExtend(RoomGameReviewPopCtr);

---配置事件监听函数
RoomGameReviewPopCtr.s_eventFuncMap =  {
}

function RoomGameReviewPopCtr:ctor()
	PopupCtr.ctor(self);
end

function RoomGameReviewPopCtr:onCleanup()
	PopupCtr.onCleanup(self);
	self:unRegisterEvent()
	-- xxxxxx
end

return RoomGameReviewPopCtr;