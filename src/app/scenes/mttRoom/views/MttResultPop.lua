--[[--ldoc desc
@module MttResultPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MttResultPop = class("MttResultPop",PopupBase);
BehaviorExtend(MttResultPop);

-- local MttResultItemCell = require('.views.MttResultItemCell')

-- 配置事件监听函数
MttResultPop.s_eventFuncMap = {
}

function MttResultPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".views.MttResultCtr"))
	self:init()
end

function MttResultPop:hidden()
	PopupBase.hidden(self)
	g_RoomInfo.m_isShowMttMatchResult = false -- 没有显示 结算弹窗
	if not g_RoomInfo.m_isMttSwitchRoom  then -- 没在切换房间
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_MTT_RESULT_POP_CLOSE) -- 显示结束弹框
	end
end

function MttResultPop:show(data)
	PopupBase.show(self)
	self:initData(data)
end

function MttResultPop:init()
	self:loadLayout("creator/mttRoom/layout/mttResultPop.ccreator");

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_back')	
	self.m_btnShare = g_NodeUtils:seekNodeByName(self, 'btn_share')	

	self.m_imgTrophyGold = g_NodeUtils:seekNodeByName(self, 'trophy_gold')	
	self.m_imgTrophySilver = g_NodeUtils:seekNodeByName(self, 'trophy_silver')
	self.m_imgTrophyCopper = g_NodeUtils:seekNodeByName(self, 'trophy_copper')	

	self.m_txRank1 = g_NodeUtils:seekNodeByName(self, 'tx_1')
	self.m_txRank2 = g_NodeUtils:seekNodeByName(self, 'tx_2')
	self.m_txRank3 = g_NodeUtils:seekNodeByName(self, 'tx_3')

	self.m_imgRank =g_NodeUtils:seekNodeByName(self,'tx_rank');

	self.m_rtxDefeat = g_NodeUtils:seekNodeByName(self, 'rtx_defeat')
	self.m_txTounamentName = g_NodeUtils:seekNodeByName(self, 'tx_tounament_name')
	self.m_imgWheatRight = g_NodeUtils:seekNodeByName(self, 'imgWheatRight')
	self.m_imgWheatLeft = g_NodeUtils:seekNodeByName(self, 'imgWheatLeft')

	self.m_txShare = g_NodeUtils:seekNodeByName(self, 'tx_share')
	self.m_txBack = g_NodeUtils:seekNodeByName(self, 'tx_back')

	self.m_viewItem = g_NodeUtils:seekNodeByName(self, 'view_item')

	self.m_txReward1 = g_NodeUtils:seekNodeByName(self, 'tx_reward_1')
	self.m_txReward2 = g_NodeUtils:seekNodeByName(self, 'tx_reward_2')
	self.m_txReward3 = g_NodeUtils:seekNodeByName(self, 'tx_reward_3')
	self.m_txReward4 = g_NodeUtils:seekNodeByName(self, 'tx_reward_4')
	self.m_txReward5 = g_NodeUtils:seekNodeByName(self, 'tx_reward_5')

	self.m_txReward1Num = g_NodeUtils:seekNodeByName(self, 'tx_reward_1_num')
	self.m_txReward2Num = g_NodeUtils:seekNodeByName(self, 'tx_reward_2_num')
	self.m_txReward3Num = g_NodeUtils:seekNodeByName(self, 'tx_reward_3_num')
	self.m_txReward4Num = g_NodeUtils:seekNodeByName(self, 'tx_reward_4_num')
	-- self.m_txReward5Num = g_NodeUtils:seekNodeByName(self, 'tx_reward_5_num')

	self.m_imgRank:setTexture(switchFilePath("mtt/tx_rank.png"))

	local x,y = self.m_imgRank:getPosition()
	self.m_imgRank:setPosition(cc.p(x - g_AppManager:getAdaptiveConfig().MTTResult.RankTitlePosition,y))
	x,y = self.m_txRank1:getPosition()
	self.m_txRank1:setPosition(cc.p(x + g_AppManager:getAdaptiveConfig().MTTResult.RankTitlePosition,y))
	self.m_txRank2:setPosition(cc.p(x + g_AppManager:getAdaptiveConfig().MTTResult.RankTitlePosition,y))
	self.m_txRank3:setPosition(cc.p(x + g_AppManager:getAdaptiveConfig().MTTResult.RankTitlePosition,y))


	g_NodeUtils:convertTTFToSystemFont(self.m_txTounamentName)

	self.m_rewardLayout = self.m_txReward1:getParent()
	self.m_btnLayout = self.m_btnShare:getParent()

	self:initString()
	self:initBtnClickEvent()
end

function MttResultPop:initString()
	self.m_rtxDefeat:setElementText(0,GameString.get('str_new_mtt_result_defeat'))
	self.m_rtxDefeat:setElementText(2,GameString.get('str_new_mtt_result_defeat_player'))
	self.m_txShare:setString(GameString.get('str_common_share'))
	self.m_txBack:setString(GameString.get('str_common_back'))
	self.m_txReward1:setString(GameString.get('str_new_mtt_get_rwward_chip'));
	self.m_txReward2:setString(GameString.get('str_new_mtt_get_rwward_by'));
	self.m_txReward3:setString(GameString.get('str_new_mtt_get_rwward_exp'));
	self.m_txReward4:setString(GameString.get('str_new_mtt_get_rwward_point'));
	-- self.m_txReward5:setString(GameString.get('str_new_mtt_get_rwward_other'));
end

function MttResultPop:initData(data)

	self.m_data = data
	Log.d('MttResultPop info',data)

	if data.chip ~= nil and tonumber(data.chip) > 0 then
		self.m_txReward1:setVisible(true)
		self.m_txReward1Num:setString(g_MoneyUtil.formatMoney(data.chip))
	else
		self.m_txReward1:setVisible(false)
	end

	if data.coalaa ~= nil and tonumber(data.coalaa) > 0 then
		self.m_txReward2:setVisible(true)
		self.m_txReward2Num:setString(tostring(data.coalaa))
	else
		self.m_txReward2:setVisible(false)
	end

	if data.exp ~= nil and tonumber(data.exp) > 0 then
		self.m_txReward3:setVisible(true)
		self.m_txReward3Num:setString(tostring(data.exp))
	else
		self.m_txReward3:setVisible(false)
	end

	if data.score ~= nil and tonumber(data.score) > 0 then
		self.m_txReward4:setVisible(true)
		self.m_txReward4Num:setString(tostring(data.score))
	else
		self.m_txReward4:setVisible(false)
	end

	if data.reward ~= nil and data.reward ~= '' then
		self.m_txReward5:setVisible(true)
		self.m_txReward5:setString(data.reward)
	else
		self.m_txReward5:setVisible(false)
	end

	if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
		self.m_btnShare:setVisible(true)
	else
		self.m_btnShare:setVisible(false)
	end

	self.m_txTounamentName:setString(data.name)
	self.m_imgTrophyGold:setVisible(false)
	self.m_imgTrophySilver:setVisible(false)
	self.m_imgTrophyCopper:setVisible(false)
	self.m_txRank1:setVisible(false)
	self.m_txRank2:setVisible(false)
	self.m_txRank3:setVisible(false)

	if data.ranking ==  1 then
		self.m_imgTrophyGold:setVisible(true)
		self.m_txRank1:setVisible(true)	
	elseif data.ranking ==  2 then
		self.m_imgTrophySilver:setVisible(true)
		self.m_txRank2:setVisible(true)
	elseif data.ranking ==  3 then
		self.m_imgTrophyCopper:setVisible(true)
		self.m_txRank3:setVisible(true)
	end 

	local info = 	g_Model:getData(g_ModelCmd.NEW_MTT_APPLY_AND_REWAED_INFO);
	local applyNum = tonumber(info.applyNum) or 0
	
	local howManyToDefeat = applyNum - data.ranking
	self.m_rtxDefeat:setElementText(1,howManyToDefeat)

	self.m_btnLayout:forceDoLayout()
	self.m_rewardLayout:forceDoLayout()
end

function MttResultPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_btnShare:addClickEventListener(
		function(sender)
			self:onBtnShareClick()
		end
	)
end

function MttResultPop:onBtnCloseClick()
	if g_RoomInfo.m_isMttMatchEnd and not g_RoomInfo.m_isMttSwitchRoom then
		g_RoomInfo.m_isMttMatchEnd = false
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SNG_END_BACK_TO_LOBBY)
	end
	self:hidden()
end

function MttResultPop:onBtnShareClick()
	if g_AccountInfo:getLoginFrom() ~= g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_other_account'))
		return
	end

	local param = g_TableLib.copyTab(GameString.get('str_social_config').matchHall)
	param.message = g_StringLib.substitute(param.message, self.m_data.ranking, self.m_data.chip)
	param.link = g_AppManager:getFBAppLink()
	NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_SHARE_FACEBOOK, param, self, self.onShareComplete)
end

function MttResultPop:onShareComplete(response)
	if response and tonumber(response.result) == 1 then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_success'))
		g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_SHARE_SUCCESS)
	elseif tonumber(response.result) == 3 then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_cancel'))
	else
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_failed'))
	end
end

function MttResultPop:onCleanup()
	PopupBase.onCleanup(self)
end


return MttResultPop;