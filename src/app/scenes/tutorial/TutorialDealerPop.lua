local DealerPop = import("app.scenes.dealer").DealerPop

local TutorialDealerPop = class("TutorialDealerPop", DealerPop)

function TutorialDealerPop:onBtnChangeDealerClick()
	self:hidden()
	g_PopupManager:show(g_PopupConfig.S_POPID.DEALER_CHANGE_POP)
end

function TutorialDealerPop:onBtnSendTipsClick()
	local param = {}
    param.senderSeatId   = 1;
    param.sendChips      = 100;
    param.receiveSeatId = 10;

	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_CHIPS_SUCC, param)
	self:hidden()
end

function TutorialDealerPop:onBtnEmojiClick(sender)
	Log.d('onBtnEmojiClick--',sender:getTag())
	local selfSeatId = 5
	local dearSeatId = 10
	if selfSeatId == -1 then    --如果在房间里，并且没有坐下不能发送互动道具
		g_AlarmTips.getInstance():setText(GameString.get("str_room_sit_down_play_hddj")):show()
		self:hidden();
		return;
	end
	--播放动画
	local hddjData = {}
	hddjData.sendSeatId = selfSeatId-1;
	hddjData.hddjId = sender:getTag();
	hddjData.receiveSeatId = dearSeatId-1
	hddjData.uid = g_AccountInfo:getId()
	-- g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP,hddjData)
	hddjData.receiveSeatId = dearSeatId
	hddjData.sendSeatId = selfSeatId
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC, hddjData)
	self:hidden();
end

return TutorialDealerPop