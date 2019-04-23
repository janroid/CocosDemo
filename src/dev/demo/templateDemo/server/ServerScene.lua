--[[--ldoc desc
@module ServerScene
@author KuovaneWu

Date   2018-10-26
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ServerScene = class("ServerScene",ViewScene);
BehaviorExtend(ServerScene);

function ServerScene:ctor()
	self:createUI();

	self.m_root, self.m_aniManager = self:loadLayout('creator/normalRoom/roomScene.ccreator')
	self:addChild(self.m_root)
	self.m_root:addChild(self.m_aniManager)

	self.m_table         = g_NodeUtils:seekNodeByName(self.m_root, 'table')

	local func = function (  )
		print("playAnimationClip end**")
	end
	self.m_aniManager:playAnimationClip(self.m_table, "seatAnim",func)
end

function ServerScene:onCleanup()
	-- 释放资源
	-- xxxxxxxxxxxxx
end

--创建UI
function ServerScene:createUI()
	if self.mUI then
		return false;
	else
		local ViewUI = require(".ServerUI");
		self.mUI = ViewUI:create(self);
		self:add(self.mUI);--添加到当前场景 不需要主动删除
		g_NodeUtils:arrangeToCenter(self.mUI)
		return true;
	end
end

--获取UI
function ServerScene:getUI()
	return self.mUI;
end

return ServerScene;