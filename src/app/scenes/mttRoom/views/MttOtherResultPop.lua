--[[--ldoc desc
@module MttOtherResultPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MttOtherResultPop = class("MttOtherResultPop",PopupBase);
BehaviorExtend(MttOtherResultPop);

-- 配置事件监听函数
MttOtherResultPop.s_eventFuncMap = {
}

function MttOtherResultPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".views.MttOtherResultCtr"))
	self:init()
end

function MttOtherResultPop:hidden()
	PopupBase.hidden(self)
	g_RoomInfo.m_isShowMttMatchResult = false
	if not g_RoomInfo.m_isMttSwitchRoom  then -- 没在切换房间
		  g_EventDispatcher:dispatch(g_SceneEvent.ROOM_MTT_RESULT_POP_CLOSE) -- 显示结束弹框
	end
end

function MttOtherResultPop:show(data)
	PopupBase.show(self)
	self:initData(data)
end

function MttOtherResultPop:init()
	self:loadLayout("creator/mttRoom/layout/mttOtherResultPop.ccreator");

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')	
	self.m_btnBack = g_NodeUtils:seekNodeByName(self, 'btn_back')	
	self.m_btnOb = g_NodeUtils:seekNodeByName(self, 'btn_ob')	

	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	self.m_txRank = g_NodeUtils:seekNodeByName(self, 'tx_rank')

	self.m_imgWheatRight = g_NodeUtils:seekNodeByName(self, 'imgWheatRight')
	self.m_imgWheatLeft = g_NodeUtils:seekNodeByName(self, 'imgWheatLeft')

	self.m_txDesc1 = g_NodeUtils:seekNodeByName(self, 'tx_desc_1')
	self.m_txDesc2 = g_NodeUtils:seekNodeByName(self, 'tx_desc_2')

	self.m_txOb = g_NodeUtils:seekNodeByName(self, 'tx_ob')
	self.m_txBack = g_NodeUtils:seekNodeByName(self, 'tx_back')

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

	self.m_rewardLayout = self.m_txReward1:getParent()
	self:initString()
	self:initBtnClickEvent()
end

function MttOtherResultPop:initString()
	self.m_txTitle:setString(GameString.get('str_new_mtt_result_title'))
	self.m_txOb:setString(GameString.get('str_new_mtt_result_ob'))
	self.m_txBack:setString(GameString.get('str_new_mtt_result_back'))
	self.m_txDesc2:setString(GameString.get('str_new_mtt_result_good_luck'))
	self.m_txReward1:setString(GameString.get('str_new_mtt_get_rwward_chip'));
	self.m_txReward2:setString(GameString.get('str_new_mtt_get_rwward_by'));
	self.m_txReward3:setString(GameString.get('str_new_mtt_get_rwward_exp'));
	self.m_txReward4:setString(GameString.get('str_new_mtt_get_rwward_point'));
end

function MttOtherResultPop:initData(data)

    if data.isReward == 0 then --没有进钱圈
    	self.m_txDesc1:setVisible(true)
    	self.m_txDesc2:setVisible(true)

		self.m_txReward1:setVisible(false)
		self.m_txReward2:setVisible(false)
		self.m_txReward3:setVisible(false)
		self.m_txReward4:setVisible(false)
		self.m_txReward5:setVisible(false)

		local info = 	g_Model:getData(g_ModelCmd.NEW_MTT_APPLY_AND_REWAED_INFO);
		local rewardNum = tonumber(info.rewardNum) or 0
		local howManyToDefeat = data.ranking - rewardNum
		self.m_txDesc1:setString(g_StringLib.substitute(GameString.get('str_new_mtt_result_defeat_offset'),howManyToDefeat))
    else
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

		if data.reward ~= nil and data.reward~="" then
			self.m_txReward5:setVisible(true)
			self.m_txReward5:setString(data.reward)
		else
			self.m_txReward5:setVisible(false)
		end
    	self.m_txDesc1:setVisible(false)
    	self.m_txDesc2:setVisible(false)
    end

    self.m_rewardLayout:forceDoLayout()
    self.m_txRank:setString(g_StringLib.substitute(GameString.get("str_new_mtt_other_result_rank"),data.ranking))
end

function MttOtherResultPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_btnOb:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_btnBack:addClickEventListener(
		function(sender)
			g_RoomInfo.m_isMttMatchEnd = false
			if not g_RoomInfo.m_isMttSwitchRoom then
				  g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SNG_END_BACK_TO_LOBBY)
			end
			self:onBtnCloseClick()
		end
	)
end

function MttOtherResultPop:onBtnCloseClick()
	self:hidden()
end

function MttOtherResultPop:onCleanup()
	PopupBase.onCleanup(self)
end


return MttOtherResultPop;