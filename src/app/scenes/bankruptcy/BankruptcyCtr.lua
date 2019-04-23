--[[--ldoc desc
@module BankruptcyCtr
@author AllenLuo
Date   2018-11-8
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BankruptcyCtr = class("BankruptcyCtr",ViewCtr);
BehaviorExtend(BankruptcyCtr);

---配置事件监听函数
BankruptcyCtr.eventFuncMap =  {
}

function BankruptcyCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function BankruptcyCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function BankruptcyCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function BankruptcyCtr:haldler(status,...)
end

return BankruptcyCtr;