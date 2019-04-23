--[[--ldoc desc
@module SuperLottoRewardPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SuperLottoRewardPop = class("SuperLottoRewardPop",PopupBase);
BehaviorExtend(SuperLottoRewardPop);

-- 配置事件监听函数
SuperLottoRewardPop.s_eventFuncMap = {
}

function SuperLottoRewardPop:ctor(data)
	PopupBase.ctor(self);
	self:bindCtr(require("SuperLottoRewardCtr"))
	self:init()
end

function SuperLottoRewardPop:show(data)
	PopupBase.show(self)
	self:update(data)
end

function SuperLottoRewardPop:hidden()
	PopupBase.hidden(self)
end

function SuperLottoRewardPop:init()
	self.m_animManager = self:loadLayout("creator/superLotto/superLottoReward.ccreator");

	self.m_root = g_NodeUtils:seekNodeByName(self, 'btn_close')
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')	
	self.m_btnSure = g_NodeUtils:seekNodeByName(self, 'btn_sure')	

	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	self.m_txGetReward = g_NodeUtils:seekNodeByName(self, 'tx_get_reward')
	self.m_txPatternTitle = g_NodeUtils:seekNodeByName(self, 'tx_pattern_title')
	self.m_txRewardPercent = g_NodeUtils:seekNodeByName(self, 'tx_reward_percent')
	self.m_txRewardNum = g_NodeUtils:seekNodeByName(self,'tx_reward_num')
	self.m_txSure = g_NodeUtils:seekNodeByName(self, 'tx_sure')
	self.m_patternCardContainer = g_NodeUtils:seekNodeByName(self,"pattern_container")

	self:initString()
	-- self:initPoker()
	self:initBtnClickEvent()
end

function SuperLottoRewardPop:initString()
	self.m_txTitle:setString(GameString.get('str_superLotto_reward_title'))
	self.m_txSure:setString(GameString.get('confirm_btn'))
	self.m_txGetReward:setVisible(true)
end

function SuperLottoRewardPop:initPoker(data)
	-- Log.d('initPoker(data)',data)
	local containerSize = self.m_patternCardContainer:getContentSize()
	-- self.m_cards = {};
	local card = nil;
	local x = 2
    for i = 1, 5 do
        card = g_PokerCard:create()
		local size = card:getContentSize()
		self.m_patternCardContainer:addChild(card)
		card:setPosition(cc.p(((i-1)*(size.width*0.65)+g_AppManager:getAdaptiveConfig().SuperLotto.RewardPokerPosX),50))
		card:setCard(data.cards[i])
		-- table.insert(self.m_cards, card);
	end
end

function SuperLottoRewardPop:update(data)
 	self._rewardTimes = 0;
 	self.m_txGetReward:setString(GameString.get('str_superLotto_reward_geting'))
	self.m_txPatternTitle:setString(GameString.get('str_superLotto_reward_pattern').. GameString.get('str_room_card_type_result')[data.cardType])
	self.m_txRewardPercent:setString(string.format(GameString.get('str_superLotto_reward_percent_num'),data.percentage))
	self.m_txRewardNum:setString(g_MoneyUtil.skipMoney(data.money))
	self:initPoker(data)
	self:reward(data.rewardId)
end

function SuperLottoRewardPop:reward(rewardId)
	self._rewardTimes = self._rewardTimes + 1; 
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.SUPER_LOTTO_GET_REWARD)
	params.id = rewardId
	g_HttpManager:doPost(params,self, self.onGetReward)
end

function SuperLottoRewardPop:onGetReward(value)
    if value == nil or value == false then   
        if self._rewardTimes < 3 then
            self:reward();        
        end
    elseif(value == true) then
        self.m_txGetReward:setString(GameString.get('str_superLotto_reward_success'))
     	g_toast.createToast(GameString.get('str_superLotto_reward_success'))
    elseif(value == -5) then
     	g_toast.createToast(GameString.get('str_superLotto_reward_success'))
    end
end

function SuperLottoRewardPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_btnSure:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_root:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
end

function SuperLottoRewardPop:onBtnCloseClick()
	self:hidden()
end

function SuperLottoRewardPop:onCleanup()
	PopupBase.onCleanup(self)
end


return SuperLottoRewardPop;