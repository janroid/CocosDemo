--[[--ldoc desc
@module MttRankViewCell
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local MttRankViewCell = class("MttRankViewCell",cc.TableViewCell)

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap

-- 配置事件监听函数
MttRankViewCell.s_eventFuncMap = {
}

function MttRankViewCell:ctor()
	self:init()
end


function MttRankViewCell:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/mttRoom/layout/mttRankViewCell.ccreator");
	self:add(self.m_root)

	self.m_viewPlayerHead = g_NodeUtils:seekNodeByName(self,'view_player_head');
	self.m_txName = g_NodeUtils:seekNodeByName(self,'tx_name');
	self.m_txChips = g_NodeUtils:seekNodeByName(self,'tx_chips');
	self.m_txRank = g_NodeUtils:seekNodeByName(self,'tx_rank');
	self.m_iconRank1 = g_NodeUtils:seekNodeByName(self,'iconGoldCrown');
    self.m_iconRank2 = g_NodeUtils:seekNodeByName(self,'iconSilverCrown');
    self.m_iconRank3 = g_NodeUtils:seekNodeByName(self,'iconCopperCrown');

    g_NodeUtils:convertTTFToSystemFont(self.m_txName)
    BehaviorExtend(self.m_viewPlayerHead)
    self.m_viewPlayerHead:bindBehavior(BehaviorMap.HeadIconBehavior)
end

function MttRankViewCell:updateCell(data)
    if data and not g_TableLib.isEmpty(data) then
        self.m_txRank:setVisible(false)
        self.m_iconRank1:setVisible(false)
        self.m_iconRank2:setVisible(false)
        self.m_iconRank3:setVisible(false)
        if data.rank == 1 then
            self.m_iconRank1:setVisible(true)
        elseif data.rank == 2 then
            self.m_iconRank2:setVisible(true)
        elseif data.rank == 3 then
            self.m_iconRank3:setVisible(true)
        elseif data.rank > 3 then
            self.m_txRank:setVisible(true)
            self.m_txRank:setString(data.rank);
        end       
        self.m_txName:setString(data.un)
        local chipNum = tonumber(data.cp) or 0
        if chipNum < 0 then
            chipNum = 0 
        end
        self.m_txChips:setString(g_MoneyUtil.formatMoney(chipNum)) 

        local size = self.m_viewPlayerHead:getContentSize()
        self.m_viewPlayerHead:setHeadIcon(data.pic, size.width, size.height)
    end
end

function MttRankViewCell:updateRank(value)
    value = value or 0
    self.m_txRank:setVisible(false)
    self.m_iconRank1:setVisible(false)
    self.m_iconRank2:setVisible(false)
    self.m_iconRank3:setVisible(false)
    if value == 1 then
        self.m_iconRank1:setVisible(true)
    elseif value == 2 then
        self.m_iconRank2:setVisible(true)
    elseif value == 3 then
        self.m_iconRank3:setVisible(true)
    elseif value > 3 then
        self.m_txRank:setVisible(true)
        self.m_txRank:setString(value);
    end   
end

function MttRankViewCell:updateChip(value)
    local chipNum = tonumber(value) or 0
    if chipNum < 0 then
        chipNum = 0 
    end
    self.m_txChips:setString(g_MoneyUtil.formatMoney(chipNum)) 
end


return MttRankViewCell;