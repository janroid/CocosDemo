--[[--ldoc desc
@module RewardListItem
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RewardListItem = class("RewardListItem",ccui.Layout);
BehaviorExtend(RewardListItem);
local BehaviorMap = import("app.common.behavior").BehaviorMap

-- 配置事件监听函数
RewardListItem.s_eventFuncMap = {
}

function RewardListItem:ctor()
	self:init()
end


function RewardListItem:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/superLotto/rewardListItem.ccreator");
	self:add(self.m_root)

	self:setContentSize(self.m_root:getContentSize())

	self.m_headFrame = g_NodeUtils:seekNodeByName(self, 'head_frame')	
	self.m_txWin = g_NodeUtils:seekNodeByName(self, 'tx_win')
	self.m_txName = g_NodeUtils:seekNodeByName(self, 'tx_name')
	self.m_viewPokerPattern = g_NodeUtils:seekNodeByName(self, 'view_poker_pattern')
	self.m_selfRewardBg = g_NodeUtils:seekNodeByName(self, 'self_reward_bg')

	BehaviorExtend(self.m_headFrame)
	self.m_headFrame:bindBehavior(BehaviorMap.HeadIconBehavior)
	
	self:initString()
	self:initPoker()
end

function RewardListItem:initString()
	self.m_txWin:setElementText(0,GameString.get('str_superLotto_reward_list_win'))

end

function RewardListItem:setData( data )
	if not data then
		return
	end

	self.m_selfRewardBg:setVisible(false)
	if tonumber(data.uid) == tonumber(g_AccountInfo:getId()) then
		self.m_selfRewardBg:setVisible(true)
	end

	self.m_cards[1]:setCard(data.card1)
	self.m_cards[2]:setCard(data.card2)
	self.m_cards[3]:setCard(data.card3)
	self.m_cards[4]:setCard(data.card4)
	self.m_cards[5]:setCard(data.card5)

	self.m_txWin:setElementText(1,"$" .. g_MoneyUtil.formatMoney(data.lotteryMoney))
	self.m_txName:setString(g_StringLib.limitLength(data.name, 24, 250))

	local size = self.m_headFrame:getContentSize()
	local border = 2
	self.m_headFrame:setHeadIcon(data.url, size.width - border, size.height - border)
end

function RewardListItem:initPoker()
	local containerSize = self.m_viewPokerPattern:getContentSize()
	self.m_cards = {};
	local card = nil;
	local scale = 0.7
	local x = 2
    for i = 1, 5 do
        card = g_PokerCard:create()
		card:setScale(scale);
		local size = card:getContentSize()
		self.m_viewPokerPattern:addChild(card)
		card:setPosition(cc.p((i-1)*(size.width*0.5*0.7),40))
		table.insert(self.m_cards, card);
	end
end


return RewardListItem;