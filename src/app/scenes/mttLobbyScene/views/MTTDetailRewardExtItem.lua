--[[--ldoc desc
@module MTTDetailRewardExtItem
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local MTTDetailRewardExtItem = class("MTTDetailRewardExtItem",cc.Node)

-- 配置事件监听函数
MTTDetailRewardExtItem.s_eventFuncMap = {
}

function MTTDetailRewardExtItem:ctor()
	self:init()
end


function MTTDetailRewardExtItem:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/mttLobbyScene/layout/mttDetailRewardCell.ccreator");
	self:add(self.m_root)

    local size = self.m_root:getContentSize()
    self:setContentSize(size)

	-- self.m_isCur = g_NodeUtils:seekNodeByName(self,'ix_cur');
	self.m_txRank = g_NodeUtils:seekNodeByName(self,'tx_rank');
	self.m_txReward = g_NodeUtils:seekNodeByName(self,'tx_reward');

	self.m_iconRank1 = g_NodeUtils:seekNodeByName(self,'icon_rank_1');
	self.m_iconRank2 = g_NodeUtils:seekNodeByName(self,'icon_rank_2');
	self.m_iconRank3 = g_NodeUtils:seekNodeByName(self,'icon_rank_3');
end

function MTTDetailRewardExtItem:updateCell(data)

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
        else
            self.m_txRank:setVisible(true)
            self.m_txRank:setString(data.rank);
        end        

        local str = "";
        if tonumber(data.money) ~= nil and tonumber(data.money) > 0 then
            if(str ~= "") then
                str = str .. "+";
            end
            str = str .. g_StringLib.substitute(GameString.get("str_new_mtt_detail_unit_chips"),g_MoneyUtil.formatMoney(tonumber(data.money)))
        end
        if tonumber(data.coalaa) ~= nil and tonumber(data.coalaa) > 0 then
            if(str ~= "") then
                str = str .. "+";
            end
            str = str .. g_StringLib.substitute(GameString.get("str_new_mtt_detail_unit_colaa"),tonumber(data.coalaa))
        end
        if tonumber(data.point) ~= nil and tonumber(data.point) > 0 then
            if(str ~= "") then
                str = str .. "+";
            end
            str = str .. g_StringLib.substitute(GameString.get("str_new_mtt_detail_unit_point"),tonumber(data.point))
        end
        if data.desc and data.desc ~= "" then
            if(str ~= "") then
                str = str .. "+";
            end
            str = str .. data.desc;
        end
        self.m_txReward:setString(str)
    end
end

return MTTDetailRewardExtItem;