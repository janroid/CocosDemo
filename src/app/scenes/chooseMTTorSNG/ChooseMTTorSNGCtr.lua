--[[--ldoc desc
@module ChooseMTTorSNGpop
@author JamesLiang

Date   2018-12-20
]]
local PopupCtr = import("app.common.popup").PopupCtr;
local ViewCtr = import("framework.scenes").ViewCtr;

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ChooseMTTorSNGCtr = class("ChooseMTTorSNGCtr",ViewCtr);
BehaviorExtend(ChooseMTTorSNGCtr);

---配置事件监听函数
ChooseMTTorSNGCtr.s_eventFuncMap =  {
}

function ChooseMTTorSNGCtr:ctor()
	ViewCtr.ctor(self);
end

function ChooseMTTorSNGCtr:onCleanup()
	ViewCtr.onCleanup(self);
	self:unRegisterEvent()
	-- xxxxxx
end

return ChooseMTTorSNGCtr;