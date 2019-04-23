--[[--ldoc desc
@module SuperLottoPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SuperLottoPop = class("SuperLottoPop",PopupBase);
BehaviorExtend(SuperLottoPop);

-- 配置事件监听函数
SuperLottoPop.s_eventFuncMap = {
	-- [g_SceneEvent.SUPER_LOTTO_IS_NEXT_BUY]			= "isNextRoundBuy",
	[g_SceneEvent.SUPER_LOTTO_BOUGHT]				= "onBought",
}

SuperLottoPop.ERROR_CODE_SYSTEM_ERROR			= 0x9431;--系统错误
SuperLottoPop.ERROR_CODE_MOENY_NOT_ENOUGH		= 0x9432;--用户没钱
SuperLottoPop.ERROR_CODE_NOT_IN_SEAT			= 0x9433;--用户没坐下
SuperLottoPop.ERROR_LOTTERY_USER_NOT_ENOUGH_TWO	=	0x9434;--钱不足倍数

function SuperLottoPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("SuperLottoCtr"))
	self:init()
end

function SuperLottoPop:show()
	PopupBase.show(self)
	local pool = g_Model:getData(g_ModelCmd.LOTTO_POOL)
	if pool ~= nil then
		self:lottoPoolChange(pool)
	end
end

function SuperLottoPop:hidden()
	PopupBase.hidden(self)
end

function SuperLottoPop:init()
	self:loadLayout("creator/superLotto/superLotto.ccreator");

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')
	self.m_btnBuyNext = g_NodeUtils:seekNodeByName(self, 'btn_buy_next')
	self.m_btnRewardList = g_NodeUtils:seekNodeByName(self, 'btn_name_list')
	self.m_btnHelp = g_NodeUtils:seekNodeByName(self, 'btn_help')
	self.m_toggleAutoBuy = g_NodeUtils:seekNodeByName(self, 'toggle_auto_buy')	
	self.m_txBonusNum = g_NodeUtils:seekNodeByName(self, 'tx_bonus_num') 

	self.m_txBuyNext = g_NodeUtils:seekNodeByName(self, 'tx_buy_next')
	self.m_txDesc = g_NodeUtils:seekNodeByName(self, 'tx_desc')
	self.m_txAutoBuy = g_NodeUtils:seekNodeByName(self, 'tx_auto_buy')
	self.m_txRewardList = g_NodeUtils:seekNodeByName(self, 'tx_name_list')
	self.m_txFourKind = g_NodeUtils:seekNodeByName(self, 'desc_4_kind')
	self.m_txStraightFlush = g_NodeUtils:seekNodeByName(self, 'desc_straight_flush')
	self.m_txRoyalStraightFlush = g_NodeUtils:seekNodeByName(self, 'desc_royal_straight_flush')

	self.m_imgLogo = g_NodeUtils:seekNodeByName(self, 'logo')
	self.m_imgFourKind = g_NodeUtils:seekNodeByName(self, '4_kind')
	self.m_imgStraightFlush = g_NodeUtils:seekNodeByName(self, 'straight_flush')
	self.m_imgRoyalStraightFlush = g_NodeUtils:seekNodeByName(self, 'royal_straight_flush')
	self.m_imgCurrentBonus = g_NodeUtils:seekNodeByName(self, 'current_bonus')

	self.m_imgLogo:setTexture(switchFilePath("superLotto/logo.png"))
	self.m_imgFourKind:setTexture(switchFilePath("superLotto/four_kind.png"))
	self.m_imgStraightFlush:setTexture(switchFilePath("superLotto/straight_flush.png"))
	self.m_imgRoyalStraightFlush:setTexture(switchFilePath("superLotto/royal_straight_flush.png"))
	self.m_imgCurrentBonus:setTexture(switchFilePath("superLotto/current_bonus.png"))

	self:initString()
	self:initBtnClickEvent()

	self:setOldValue(0)
end

function SuperLottoPop:initString()
	self.m_txBuyNext:setString(GameString.get('str_superLotto_buy_next_round'))
	self.m_txAutoBuy:setString(GameString.get('str_superLotto_auto_buy'))
	self.m_txRewardList:setString(GameString.get('str_superLotto_reward_list'))

	self.m_txDesc:setElementText(0,GameString.get('str_superLotto_desc0'))
	self.m_txDesc:setElementText(1,GameString.get('str_superLotto_desc1'))
	self.m_txDesc:setElementText(2,GameString.get('str_superLotto_desc2'))
	self.m_txFourKind:setElementText(0,GameString.get('str_superLotto_get'))
	self.m_txFourKind:setElementText(2,GameString.get('str_superLotto_pool'))
	self.m_txStraightFlush:setElementText(0,GameString.get('str_superLotto_get'))
	self.m_txStraightFlush:setElementText(2,GameString.get('str_superLotto_pool'))
	self.m_txRoyalStraightFlush:setElementText(0,GameString.get('str_superLotto_get'))
	self.m_txRoyalStraightFlush:setElementText(2,GameString.get('str_superLotto_pool'))

	self.m_txFourKind:setFontSize(15)

	g_Model:watchData(g_ModelCmd.LOTTO_POOL,self, self.lottoPoolChange, false)
	g_Model:watchData(g_ModelCmd.LOTTO_IS_NEXT_BUY,self, self.isNextRoundBuy, true)
	g_Model:watchData(g_ModelCmd.LOTTO_IS_AUTO_BUY,self, self.isAutoBuyIn, true)
end

function SuperLottoPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_btnBuyNext:addClickEventListener(
		function(sender)
			self:onBtnBuyNextClick()
		end
	)
	self.m_btnHelp:addClickEventListener(
		function(sender)
			self:onBtnHelpClick()
		end
	)
	self.m_btnRewardList:addClickEventListener(
		function(sender)
			self:onBtnRewardListClick()
		end
	)
	self.m_toggleAutoBuy:addEventListener(
		function(toggle, selected)
			self:onToggleAutoBuyClick(selected == 0)
		end
	)
end

function SuperLottoPop:onBtnCloseClick()
	self:hidden()
end

function SuperLottoPop:onBtnBuyNextClick()
	local selfSeatId = import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeatId()
	if selfSeatId == -1 then    --没有坐下
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_superLotto_not_in_seat'))
		self:hidden();
		return;
	end
	g_Model:setData(g_ModelCmd.LOTTO_IS_NEXT_BUY, true);
    g_EventDispatcher:dispatch(g_SceneEvent.SUPER_LOTTO_BUY_NEXT)

    -- self:lottoPoolChange(self.m_oldValue + 2000)
end

function SuperLottoPop:onBtnHelpClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.SUPER_LOTTO_RULE_POP)
end

function SuperLottoPop:onBtnRewardListClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.SUPER_LOTTO_REWARD_LIST_POP)
end

function SuperLottoPop:isNextRoundBuy(value)
	self.m_btnBuyNext:setEnabled(not value);
    self.m_txBuyNext:setString(value and GameString.get('str_superLotto_bought_next_round') or GameString.get('str_superLotto_buy_next_round'))
end

function SuperLottoPop:isAutoBuyIn(value)
	self.m_toggleAutoBuy:setSelected(value or false)
	if value then
		self.m_btnBuyNext:setEnabled(false)
	else
    	if not g_Model:getData(g_ModelCmd.LOTTO_IS_NEXT_BUY) then
    		self.m_btnBuyNext:setEnabled(true)
    	else
    		self.m_btnBuyNext:setEnabled(false)
    	end
	end
end

function SuperLottoPop:onToggleAutoBuyClick(isAuto)
    if isAuto then
    	g_EventDispatcher:dispatch(g_SceneEvent.SUPER_LOTTO_AUTO_BUY)
    	g_Model:setData(g_ModelCmd.LOTTO_IS_AUTO_BUY, true);
    else 	
    	g_EventDispatcher:dispatch(g_SceneEvent.SUPER_LOTTO_CANCEL_AUTO_BUY)
    	g_Model:setData(g_ModelCmd.LOTTO_IS_AUTO_BUY, false);
    end
end

function SuperLottoPop:onBought()
	g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_superLotto_buy_next_success"))
end

function SuperLottoPop:lottoPoolChange(newValue)

	if self.m_increaseNumEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_increaseNumEntry)
		self.m_increaseNumEntry = nil
	end

    newValue = newValue or 0;
    local start = self.m_oldValue;
    local duration = 0.75
    local currentDt = 0

    --数值增长动画
	local function callback(dt)
		currentDt = currentDt + dt
		local progress = currentDt / duration
		self:setOldValue(start + (newValue - start) * progress)
		if currentDt > duration then
			self:setOldValue(newValue)
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_increaseNumEntry)
			return
		end
	end
	self.m_increaseNumEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.02, false)
end

function SuperLottoPop:setOldValue(value)
    self.m_oldValue = math.floor(value);
    if(value - self.m_oldValue >= 0.5) then
        self.m_oldValue = self.m_oldValue + 1;
    end
    self.m_txBonusNum:setString(GameString.get('str_price_unit') .. g_MoneyUtil.skipMoney(self.m_oldValue)) 
end

function SuperLottoPop:onCleanup()
	PopupBase.onCleanup(self)
	if self.m_increaseNumEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_increaseNumEntry)
	end

	g_Model:unwatchData(g_ModelCmd.LOTTO_POOL,self, self.lottoPoolChange)
	g_Model:unwatchData(g_ModelCmd.LOTTO_IS_NEXT_BUY,self, self.isNextRoundBuy)
	g_Model:unwatchData(g_ModelCmd.LOTTO_IS_AUTO_BUY,self, self.isAutoBuyIn)
end


return SuperLottoPop;