--[[--ldoc desc
@module MTTDetailRankCell
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local MTTDetailRankCell = class("MTTDetailRankCell",cc.TableViewCell)

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap

-- 配置事件监听函数
MTTDetailRankCell.s_eventFuncMap = {
}

function MTTDetailRankCell:ctor()
	self:init()
end


function MTTDetailRankCell:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/mttLobbyScene/layout/mttDetailRankCell.ccreator");
	self:add(self.m_root)

	self.m_isCur = g_NodeUtils:seekNodeByName(self,'ix_cur');
	self.m_txRank = g_NodeUtils:seekNodeByName(self,'tx_rank_index');
	self.m_viewPlayerHeader = g_NodeUtils:seekNodeByName(self,'view_player_header');
	self.m_txPlayerName = g_NodeUtils:seekNodeByName(self,'tx_player_name');
	self.m_txCurChips = g_NodeUtils:seekNodeByName(self,'tx_cur_chips');

	self.m_iconRank1 = g_NodeUtils:seekNodeByName(self,'icon_rank_1');
	self.m_iconRank2 = g_NodeUtils:seekNodeByName(self,'icon_rank_2');
	self.m_iconRank3 = g_NodeUtils:seekNodeByName(self,'icon_rank_3');

    g_NodeUtils:convertTTFToSystemFont(self.m_txPlayerName)

    BehaviorExtend(self.m_viewPlayerHeader)
    self.m_viewPlayerHeader:bindBehavior(BehaviorMap.HeadIconBehavior)
end

function MTTDetailRankCell:updateCell(data,rank)

	if data and not g_TableLib.isEmpty(data) then
        self.m_txRank:setVisible(false)
        self.m_iconRank1:setVisible(false)
        self.m_iconRank2:setVisible(false)
        self.m_iconRank3:setVisible(false)
        local newRank = tonumber(data.rank or rank)
        if newRank == 1 then
            self.m_iconRank1:setVisible(true)
        elseif newRank == 2 then
            self.m_iconRank2:setVisible(true)
        elseif newRank == 3 then
            self.m_iconRank3:setVisible(true)
        else
        	self.m_txRank:setVisible(true)
            self.m_txRank:setString(newRank);
        end       
        self.m_txPlayerName:setString(data.un)

        if data.cp then
            self.m_txCurChips:setVisible(true)
            local chipNum = tonumber(data.cp) 
            if chipNum < 0 then
                chipNum = 0
            end
            self.m_txCurChips:setString(g_MoneyUtil.formatMoney(chipNum)) 
        else
            self.m_txCurChips:setVisible(false)
        end

        local size = self.m_viewPlayerHeader:getContentSize()
        self.m_viewPlayerHeader:setHeadIcon(data.pic, size.width, size.height)
   	end
end

return MTTDetailRankCell;