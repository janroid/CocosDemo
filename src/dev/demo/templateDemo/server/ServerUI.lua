--[[--ldoc desc
@module ServerUI
@author KuovaneWu

Date   2018-10-26
]]
--local ViewUI = import("framework.scenes").ViewCtr
local BehaviorExtend = import("framework.behavior").BehaviorExtend;


local ServerUI = class("ServerUI",cc.Layer);
BehaviorExtend(ServerUI);

function ServerUI:ctor()
	--ViewUI.ctor(self);
	--self:bindCtr(require(".ServerCtr"));
	self:init();
	local node = require(".ServerCtr"):create()
	self:addChild(node)

end


function ServerUI:getUI()
	return self
end


function ServerUI:onCleanup()
	self:unBindCtr();
end

function ServerUI:init()
	-- do something
	
	-- 加载布局文件
	-- local view = self:loadLayout("aa.creator");
	-- self:add(view);

	local label = cc.Label:createWithSystemFont("Server","",30)
	self:addChild(label)
	label:setPosition(0,100)

	self.m_labelStatus = cc.Label:createWithSystemFont("","",30)
	self:addChild(self.m_labelStatus)
	--g_NodeUtils:arrangeToCenter(self.m_labelStatus)
end

---刷新界面
function ServerUI:updateView(data)
	data = checktable(data);
	if data then
		self.m_labelStatus:setString(data.result)
	end
end

return ServerUI;