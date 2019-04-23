--[[--ldoc desc
@module ChooseMTTorSNGpop
@author JamesLiang

Date   2019-01-21
]]
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RoomGameReviewDetailCtr = class("RoomGameReviewDetailCtr",PopupCtr);
BehaviorExtend(RoomGameReviewDetailCtr);

---配置事件监听函数
RoomGameReviewDetailCtr.s_eventFuncMap =  {
}

function RoomGameReviewDetailCtr:ctor()
	PopupCtr.ctor(self);
end

function RoomGameReviewDetailCtr:onCleanup()
	PopupCtr.onCleanup(self);
	self:unRegisterEvent()
	-- xxxxxx
end

return RoomGameReviewDetailCtr;