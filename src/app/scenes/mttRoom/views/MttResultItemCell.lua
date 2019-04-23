--[[--ldoc desc
@module MttResultItemCell
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local MttResultItemCell = class("MttResultItemCell",cc.TableViewCell)

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap

local NetImageView = import("app.common.customUI").NetImageView

-- 配置事件监听函数
MttResultItemCell.s_eventFuncMap = {
}

function MttResultItemCell:ctor()
	self:init()
end


function MttResultItemCell:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/mttRoom/layout/mttResultItem.ccreator");
	self:add(self.m_root)

	self.m_viewImg = g_NodeUtils:seekNodeByName(self,'view_img');
	self.m_txName = g_NodeUtils:seekNodeByName(self,'tx_name');

	self.m_iconChip = g_NodeUtils:seekNodeByName(self,'chip');
	self.m_iconCoin = g_NodeUtils:seekNodeByName(self,'coin');
	self.m_iconExp = g_NodeUtils:seekNodeByName(self,'exp');

	g_NodeUtils:convertTTFToSystemFont(self.m_txName)

	self.m_netImg = NetImageView:create()
	self.m_netImg:setContentSize(self.m_viewImg:getContentSize())
	self.m_viewImg:addChild(self.m_netImg)
end

function MttResultItemCell:updateCell(data)
	self.m_iconChip:setVisible(false)
	self.m_iconCoin:setVisible(false)
	self.m_iconExp:setVisible(false)
	self.m_netImg:setVisible(false)
    if data and not g_TableLib.isEmpty(data) then
		if data.key == "chip" then
			self.m_iconChip:setVisible(true)
			self.m_txName:setString(data.value)
		elseif data.key == "coalaa" then
			self.m_iconCoin:setVisible(true)
			self.m_txName:setString(data.value)
		elseif data.key == "exp" then 
			self.m_iconExp:setVisible(true)
			self.m_txName:setString(data.value)
		elseif data.key == "score" then
			self.m_txName:setString("")
		elseif data.key == "vip" then 
			self.m_netImg:setVisible(true)
			self.m_netImg:setUrlImage(g_AccountInfo:getCDNUrl() .. 'images/1/bigfeed' ..  data.key .. ".png")
			self.m_txName:setString("")
		elseif data.key == "gift" then
			self.m_netImg:setVisible(true) 
			self.m_netImg:setUrlImage(g_AccountInfo:getCDNUrl() .. 'images/1/gift' ..  data.value .. ".png")
			self.m_txName:setString("")
		elseif data.key == "prop" then
			self.m_netImg:setVisible(true)
			self.m_txName:setString("")
		end
    end
end

return MttResultItemCell;