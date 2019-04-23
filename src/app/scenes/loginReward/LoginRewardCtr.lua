--[[--ldoc desc
@module LoginRewardCtr
@author RyanXu
Date   2018-10-31
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local LoginRewardCtr = class("LoginRewardCtr",ViewCtr);
BehaviorExtend(LoginRewardCtr);

---配置事件监听函数
LoginRewardCtr.eventFuncMap =  {
}

function LoginRewardCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function LoginRewardCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function LoginRewardCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function LoginRewardCtr:haldler(status,...)
end

return LoginRewardCtr;