--[[--ldoc desc
@module DealerPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DealerPop = class("DealerPop",PopupBase);
BehaviorExtend(DealerPop);

local RoomSocketManager = import("app.net").RoomSocketManager
local SocketManager = RoomSocketManager.new()

-- 配置事件监听函数
DealerPop.s_eventFuncMap = {
}

DealerPop.s_emojiMap = {
	{index = 1, scale = 1},
	{index = 2, scale = 1},
	{index = 3, scale = 1},
	{index = 4, scale = 1},
	{index = 5, scale = 1},
	{index = 6, scale = 1},
	{index = 7, scale = 1},
	{index = 8, scale = 1},
	{index = 9, scale = 1},
	{index = 10, scale = 1},
	{index = 11, scale = 1},
	{index = 12, scale = 1},
	{index = 13, scale = 0.8},
	{index = 16, scale = 0.8, isFlip = true},
	{index = 17, scale = 0.7, isFlip = true},
	{index = 18, scale = 0.8},
	{index = 19, scale = 0.75},
	{index = 20, scale = 0.75},
}

function DealerPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("DealerCtr"))
	self:init()
end

function DealerPop:show()
	PopupBase.show(self)
	g_EventDispatcher:dispatch(g_SceneEvent.GET_USER_HDDJ_NUMBER)
end

function DealerPop:hidden()
	PopupBase.hidden(self)
end

function DealerPop:init()
	self:loadLayout("creator/dealer/dealerPop.ccreator");
	self:setShadeTransparency(true)
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_bg')

	self.m_btnChangeDealer = g_NodeUtils:seekNodeByName(self, 'btn_change_dealer')
	self.m_btnSendTips = g_NodeUtils:seekNodeByName(self, 'btn_send_tips')	

	self.m_txChangeDealer = g_NodeUtils:seekNodeByName(self, 'tx_change_dealer')
	self.m_txSendTips = g_NodeUtils:seekNodeByName(self, 'tx_send_tips')
	self.m_viewEmoji = g_NodeUtils:seekNodeByName(self, 'view_emoji')

	self:initString()
	self:initEmoji()
	self:initBtnClickEvent()
end

function DealerPop:initEmoji()
	local contentSize = self.m_viewEmoji:getContentSize()
	self.m_listView = ccui.ListView:create()
	self.m_listView:setContentSize(contentSize);
	self.m_listView:setDirection(2);
	self.m_listView:setBounceEnabled(true);
	self.m_listView:setScrollBarEnabled(false)
	self.m_viewEmoji:addChild(self.m_listView)

	for i=1, #DealerPop.s_emojiMap do
		local config = DealerPop.s_emojiMap[i]
		local btnEmoji = ccui.Button:create(string.format("creator/userInfo/propAtlas/hddj_%d.png",config.index))
		local layout = ccui.Layout:create()
		local layoutSize = cc.size(contentSize.width/3,contentSize.height)
		layout:setContentSize(layoutSize)
		layout:addChild(btnEmoji)
		if config.isFlip == true then
			btnEmoji:setFlippedX(true)
		end
		btnEmoji:setScale(config.scale)
		btnEmoji:setPosition(cc.p(layoutSize.width/2,layoutSize.height/2))
		btnEmoji:setTag(config.index)
		btnEmoji:addClickEventListener(function (sender)
			self:onBtnEmojiClick(sender)
		end)
        self.m_listView:pushBackCustomItem(layout)
	end
end

function DealerPop:initString()
	self.m_txChangeDealer:setString(GameString.get('str_dealer_change_dealer'))
	self.m_txSendTips:setString(GameString.get('str_dealer_send_tips'))

end

function DealerPop:initBtnClickEvent()
	local btnsActions = {
		{ btn = self.m_btnClose,       	cmds = self.onBtnCloseClick },      
		{ btn = self.m_btnSendTips, 	cmds = self.onBtnSendTipsClick },  
		{ btn = self.m_btnChangeDealer, cmds = self.onBtnChangeDealerClick },
	}
	for i,value in ipairs(btnsActions) do
		value.btn:addClickEventListener(function(sender)
			value.cmds(self)
		end)
	end
end

function DealerPop:onBtnCloseClick()
	self:hidden()
end

function DealerPop:onBtnSendTipsClick()
	local param = {}
    param.senderSeatId   = 1;
    param.sendChips      = 100;
    param.receiveSeatId = 10;

	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_CHIP, param)
	self:hidden()
end

function DealerPop:onBtnChangeDealerClick()
	self:hidden()
	g_PopupManager:show(g_PopupConfig.S_POPID.DEALER_CHANGE_POP)
end

function DealerPop:onBtnEmojiClick(sender)
	Log.d('onBtnEmojiClick--',sender:getTag())
	local selfSeatId = import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeatId()
	local dearSeatId = 10


	if selfSeatId == -1 then    --如果在房间里，并且没有坐下不能发送互动道具
		g_AlarmTips.getInstance():setText(GameString.get("str_room_sit_down_play_hddj")):show()
		self:hidden();
		return;
	elseif  (g_Model:getData(g_ModelCmd.USER_HDDJ_NUMBER) == nil or g_Model:getData(g_ModelCmd.USER_HDDJ_NUMBER) <= 0)  then
		g_AlertDialog.getInstance()
		:setTitle(GameString.get("tips"))
		:setContent(GameString.get("str_room_not_enough_hddj"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
		:setCenterBtnTx(GameString.get("str_common_buy"))
		:setCenterBtnFunc(function()
			g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,import("app.scenes.store").StoreConfig.STORE_POP_UP_PROPS_PAGE)
			end)
		:show()
			self:hidden();
		return
	end

	--播放动画
	local hddjData = {}
	hddjData.sendSeatId = selfSeatId-1;
	hddjData.hddjId = sender:getTag();
	hddjData.receiveSeatId = dearSeatId-1
	hddjData.uid = g_AccountInfo:getId()
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP,hddjData)
	hddjData.receiveSeatId = dearSeatId
	hddjData.sendSeatId = selfSeatId
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC, hddjData)
	self:hidden();
end

function DealerPop:onBtnSendTipsClick( ... )

	local selfSeatId = import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeatId()
	local dearSeatId = 10
	if selfSeatId == -1 then    --如果在房间里，并且没有坐下不能发送互动道具
		g_AlarmTips.getInstance():setText(GameString.get("str_dealer_sit_down_send_chips")):show()
	else	
		g_EventDispatcher:dispatch(g_SceneEvent.DEALERPOP_SEND_CHIP)
	end
	self:hidden();
	return
end

function DealerPop:onCleanup()
	PopupBase.onCleanup(self)
end


return DealerPop;