--[[--ldoc desc
@module AccountUpgradeCtr
@author ReneYang
Date   2018-10-25
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AccountUpgradeCtr = class("AccountUpgradeCtr",ViewCtr);
BehaviorExtend(AccountUpgradeCtr);

---配置事件监听函数
AccountUpgradeCtr.eventFuncMap =  {
}

function AccountUpgradeCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function AccountUpgradeCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function AccountUpgradeCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function AccountUpgradeCtr:haldler(status,...)
end

return AccountUpgradeCtr;