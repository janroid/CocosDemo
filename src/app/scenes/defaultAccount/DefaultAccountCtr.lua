--[[--ldoc desc
@module DefaultAccountCtr
@author RyanXu
Date   2018-11-2
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DefaultAccountCtr = class("DefaultAccountCtr",ViewCtr);
BehaviorExtend(DefaultAccountCtr);

---配置事件监听函数
DefaultAccountCtr.s_eventFuncMap =  {
}

function DefaultAccountCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function DefaultAccountCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function DefaultAccountCtr:updateView(data)
	-- local ui = self:getUI();
	-- if ui and ui.updateView then
	-- 	ui:updateView(data);
	-- end
end

-- UI触发的逻辑处理
function DefaultAccountCtr:haldler(status,...)
end

return DefaultAccountCtr;