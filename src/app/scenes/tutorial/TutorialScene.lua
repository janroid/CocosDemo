--[[--ldoc desc
@module TutorialScene
@author ReneYang

Date   2019-1-4
]]
local TutorialConfig = require("TutorialConfig")
local TableLight = import("app.scenes.normalRoom").TableLight
local RectTimer = import("app.common.customUI").RectTimer
local ChipManager = import("app.scenes.normalRoom").ChipManager
local NetImageView =  import("app.common.customUI").NetImageView
local DealerConfig = import("app.scenes.dealer").DealerConfig
local PropAnim = import("app.scenes.normalRoom").PropAnim:create()

local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap
local TutorialScene = class("TutorialScene",ViewScene);
BehaviorExtend(TutorialScene);

---配置事件监听函数
TutorialScene.s_eventFuncMap =  {
	[g_SceneEvent.BEGINNER_TUTORIAL_OPERATIONAL] = "doOperation";
	[g_SceneEvent.USERINFOPOP_SEND_CHIPS_SUCC]	 = "onSendChipsSucc",
	[g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC]	 = "onSendPropSucc",
	[g_SceneEvent.BEGINNER_TUTORIAL_SEND_GIFT]   = "onSendGiftSucc",
}

function TutorialScene:ctor()
	ViewScene.ctor(self)
	self:bindCtr(require("TutorialCtr"))
	self:init()
	g_Model:watchData(g_ModelCmd.DEALER_LIST, self, self.dealerDefalut, true)
	g_Model:watchData(g_ModelCmd.SELECTED_DEALER, self, self.dealerChange, false)
end

function TutorialScene:onCleanup()
	ViewScene.onCleanup(self)
	if self.m_schedules then
		for k,v in pairs(self.m_schedules) do
			if tonumber(v) then
				g_Schedule:cancel(v)
			else
				v:cancel()
			end
			v = nil
		end
	end
	ChipManager:cleanup()
	
	self:clearGuideNode()
	g_Model:clearData(g_ModelCmd.TUTORIAL_GIFT_CLICKED); 
	g_Model:unwatchData(g_ModelCmd.DEALER_LIST, self, self.dealerDefalut, true)
	g_Model:unwatchData(g_ModelCmd.SELECTED_DEALER, self, self.dealerChange, false)
end

function TutorialScene:clearGuideNode()
	if self.m_guideNode then
		self.m_guideNode:release()
		self.m_guideNode = nil
	end
end

function TutorialScene:dealerDefalut(heguanData)
	local heguanId = g_AccountInfo:getDefaultHeguan()
	if heguanData then
		for i=1,#heguanData do
			if heguanData[i].heguan_id == heguanId then
				local url =  g_AccountInfo:getCDNUrl() .. (heguanData[i].mbpic or '')
				self.m_dealer:setUrlImage(url)
				local deltaY = DealerConfig.TABLE_DELTAY[heguanId] or 0
				local size = self.m_dealerView:getContentSize()
				self.m_dealer:setPosition(cc.p(size.width/2,size.height/2+deltaY))
			end
		end
	end
end
function TutorialScene:dealerChange(heguanId)
	local heguanData = g_Model:getData(g_ModelCmd.DEALER_LIST)
	if heguanData then
		for i=1,#heguanData do
			if heguanData[i].heguan_id == heguanId then
				local url =  g_AccountInfo:getCDNUrl() .. (heguanData[i].mbpic or '')
				self.m_dealer:setUrlImage(url)
				local deltaY = DealerConfig.TABLE_DELTAY[heguanId] or 0
				local size = self.m_dealerView:getContentSize()
				self.m_dealer:setPosition(cc.p(size.width/2,size.height/2+deltaY))
			end
		end
	end
end

function TutorialScene:init()
	self.m_schedules = {} -- 装定时器的表
	self.m_root = self:loadLayout('creator/tutorial/tutorial.ccreator')
	self:addChild(self.m_root)
	self:initView()
	self:initCardType()
	self:initRules()
	self:initListener()
	self:initLogicFuncs()
end

function TutorialScene:initView()
	self.m_imgGirl = g_NodeUtils:seekNodeByName(self.m_root, "girl")
	self.m_imgDialog = g_NodeUtils:seekNodeByName(self.m_root, "bgDialog")
	self.m_labelDialog = g_NodeUtils:seekNodeByName(self.m_root, "labelDialog")

	self.m_imgBottom = g_NodeUtils:seekNodeByName(self.m_root, "bgBottom")
	self.m_cardTypeContainer = g_NodeUtils:seekNodeByName(self.m_root, "bgCardType")
	self.m_rule = g_NodeUtils:seekNodeByName(self.m_root,"bgRule")

	self.m_btnPrivious = g_NodeUtils:seekNodeByName(self.m_root, "btnPrivious")
	self.m_btnNext = g_NodeUtils:seekNodeByName(self.m_root, "btnNext")
	self.m_imgNextHighlight = g_NodeUtils:seekNodeByName(self.m_root, "imgNextHighlight")
	self.m_imgArrow = g_NodeUtils:seekNodeByName(self.m_root, "imgArrow");

	self.m_table = g_NodeUtils:seekNodeByName(self.m_root, "table")
	self.m_seatContainer = g_NodeUtils:seekNodeByName(self.m_root, "seatContainer")
	self.m_seatContainer:setLocalZOrder(1)
	
	self.m_btnFinish = g_NodeUtils:seekNodeByName(self.m_root, "btnFinish")
	self.m_labelFinish = g_NodeUtils:seekNodeByName(self.m_root, "labelFinish")
	self.m_labelFinish:setString(GameString.get("str_beginner_tutorial_complete_btn_text"))

	self.m_labelTips = g_NodeUtils:seekNodeByName(self.m_root, "tips")
	self.m_labelTips:setString(GameString.get("str_beginner_tutorial_tips"))
	
	self.m_imgOperateHighlight = g_NodeUtils:seekNodeByName(self.m_root, "imgOperateHighlight")
	self.m_btnBack = g_NodeUtils:seekNodeByName(self.m_root, "btnBack")
	self.m_betChipsNode = g_NodeUtils:seekNodeByName(self.m_root, "betChipsNode")
	g_NodeUtils:seekNodeByName(self.m_root, "btn3X"):setEnabled(false)
	g_NodeUtils:seekNodeByName(self.m_root, "btnHalfPool"):setEnabled(false)
	g_NodeUtils:seekNodeByName(self.m_root, "btnAllIn2"):setEnabled(false)
	g_NodeUtils:seekNodeByName(self.m_root, "btn0.75Pool"):setEnabled(false)

	self.m_tableLight = TableLight.new(g_NodeUtils:seekNodeByName(self.m_root, 'light'))
	self.m_tableLight:setVisible(false)

	self:initOperationBtns()
	self:initSeats()
	self:initPublicCard()
	self:initDealerView()
	self.m_bottomPosX,self.m_bottomPosY = self.m_imgBottom:getPosition()
	self.m_seatContainer:setVisible(false)
	self.m_operation:setVisible(false)
	self.m_raiseNode:setVisible(false)
	self.m_imgOperateHighlight:setVisible(false)
	ChipManager:initialize(self.m_betChipsNode)
	--self.m_imgBottom:setLocalZOrder(3)
	self.m_tx3X           	 = g_NodeUtils:seekNodeByName(self.m_root, 'tx3X')
	self.m_txAllIn2       	 = g_NodeUtils:seekNodeByName(self.m_root, 'txAllIn2')
	self.m_tx75Pool     	 = g_NodeUtils:seekNodeByName(self.m_root, 'tx0.75Pool')
	self.m_txHalfPool     	 = g_NodeUtils:seekNodeByName(self.m_root, 'txHalfPool')
	self.m_txBack       	 = g_NodeUtils:seekNodeByName(self.m_root, 'txBack')
	
	self.m_tx3X:setString(GameString.get("str_room_triple"))
	self.m_txAllIn2:setString(GameString.get("str_room_all_in"))
	self.m_tx75Pool:setString(GameString.get("str_room_three_quarter_pool"))
	self.m_txHalfPool:setString(GameString.get("str_room_half_pool"))
	self.m_txBack:setString(GameString.get("str_common_tutoria_popup_quit_btn"))

end

-- 初始化 看牌、弃牌、加注操作按钮
function TutorialScene:initOperationBtns()
	self.m_operation = g_NodeUtils:seekNodeByName(self.m_root, "operation")
	--self.m_operation:setLocalZOrder(2)
	self.m_raiseNode = g_NodeUtils:seekNodeByName(self.m_root, "raiseNode")
	self.m_btnFold = g_NodeUtils:seekNodeByName(self.m_root, "btnFold")
	self.m_btnCheck = g_NodeUtils:seekNodeByName(self.m_root, "btnCheck")
	self.m_btnRaise = g_NodeUtils:seekNodeByName(self.m_root, "btnRaise")
	self.m_labelFold = g_NodeUtils:seekNodeByName(self.m_root, "txFold")
	self.m_labelCheck = g_NodeUtils:seekNodeByName(self.m_root, "txCheck")
	self.m_labelRaise = g_NodeUtils:seekNodeByName(self.m_root, "txRaise")
	self.m_labelFold:setString(GameString.get("str_room_fold"))
	self.m_labelCheck:setString(GameString.get("str_room_check"))
	self.m_labelRaise:setString(GameString.get("str_room_raise"))
	self.m_btnFold:setPressedActionEnabled(true)
	self.m_btnFold:setZoomScale(-0.04)
	self.m_btnCheck:setPressedActionEnabled(true)
	self.m_btnCheck:setZoomScale(-0.04)
	self.m_btnRaise:setPressedActionEnabled(true)
	self.m_btnRaise:setZoomScale(-0.04)

	self.m_sliderContainer   = g_NodeUtils:seekNodeByName(self.m_root, 'sliderContainer')
	self.m_txRaiseNum   	 = g_NodeUtils:seekNodeByName(self.m_root, 'raiseNum')
	self.m_btnAllIn     	 = g_NodeUtils:seekNodeByName(self.m_root, 'btnAllIn')
	self.m_raiseTipArrow 		 = g_NodeUtils:seekNodeByName(self.m_root, 'raiseTipArrow')
	--self.m_raiseTipArrow:setLocalZOrder(3)
	self.m_txRaiseNum:setString("$300")
	self:initRaiseSlider()
end

function TutorialScene:initRaiseSlider()
	self.m_raiseSlider       = ccui.Slider:create()
	self.m_raiseSlider:setContentSize(393, 32)
	self.m_raiseSlider:setPosition(10, 196)
	self.m_raiseSlider:setRotation(-90)
	self.m_sliderContainer:addChild(self.m_raiseSlider)
	self.m_raiseSlider:loadBarTexture("creator/normalRoom/img/allIn/progressBg.png")
	self.m_raiseSlider:loadSlidBallTextures("creator/normalRoom/img/allIn/progressBar.png")
	self.m_raiseSlider:loadProgressBarTexture("creator/normalRoom/img/allIn/progress.png")
end

-- 初始化座位相关
function TutorialScene:initSeats()
	local seat1 = g_NodeUtils:seekNodeByName(self.m_root, "seat1")
	local seat2 = g_NodeUtils:seekNodeByName(self.m_root, "seat2")
	local seat3 = g_NodeUtils:seekNodeByName(self.m_root, "seat5")
	local seats = {
		[1] = seat1,
		[2] = seat2,
		[3] = seat3,
	}
	self.m_seats = {}
	for k,v in pairs(seats) do
		local status = g_NodeUtils:seekNodeByName(v, "status")
		local head = g_NodeUtils:seekNodeByName(v, "head")
		local labelMoney = g_NodeUtils:seekNodeByName(v, "money")
		BehaviorExtend(head)
		head:bindBehavior(BehaviorMap.HeadIconBehavior);
		status:setString(TutorialConfig.SEAT_INIT_INFO[k].status)
		local clipPath = "creator/hall/header_bg.png"
		head:setHeadIcon(TutorialConfig.SEAT_INIT_INFO[k].head, nil, nil, clipPath)
		labelMoney:setString("$"..1000)
		local size = v:getContentSize()
		local timer = RectTimer:create(size.width, size.height)
		timer:setVisible(false)
		v:addChild(timer)
		local gift = self:initGift(k, v)
		self.m_seats[k] = {
			seatContainer = v,
			labelStatus = status,
			head = head,
			gift = gift,
			timer = timer,
			labelMoney = labelMoney,
		}
		head:setCascadeColorEnabled(true)
		
		self.m_seats[k].getView = function(self)
			return self.seatContainer
		end
		self.m_seats[k].getPosId = function(self)
			return (k == 3) and 5 or k
		end
		
	end
end

function TutorialScene:initGift(seatId, parentView)
	local giftView  = g_NodeUtils:getRootNodeInCreator('creator/normalRoom/giftView.ccreator')
	local giftBtn   = g_NodeUtils:seekNodeByName(giftView, 'giftBtn')
	local giftFront = g_NodeUtils:seekNodeByName(giftView, 'giftFront')
	local gift1     = g_NodeUtils:seekNodeByName(giftView, 'giftIcon')

	gift1:setVisible(false)

	parentView:addChild(giftView)

	BehaviorExtend(giftFront)
	giftFront:bindBehavior(BehaviorMap.GiftIconBehavior)
	giftBtn:setPressedActionEnabled(true)
	giftBtn:setName(seatId)
	giftBtn:setEnabled(false)
	giftBtn:addClickEventListener(function(sender)
		self:onBtnGiftClicked(sender)
	end)
	local gift = {
		giftView = giftView,
		giftBtn = giftBtn,
		giftFront = giftFront,
	}
	giftFront:setGift(nil,"creator/normalRoom/img/gift.png")
	local size = giftView:getContentSize()
	if seatId == 3 then
		g_NodeUtils:arrangeToLeftCenter(giftView,-size.width/2+3)
	else
		g_NodeUtils:arrangeToRightCenter(giftView,size.width/2-3)
	end
	Log.d("Reneyang 123123123", gift)
	return gift
end

function TutorialScene:onBtnGiftClicked(sender)
	self.m_giftClicked = true
	self:resetGuideAnim()
	g_Model:setData(g_ModelCmd.TUTORIAL_GIFT_CLICKED, true);    
	local seatId = tonumber(sender:getName())
	self.m_giftClickedId = seatId
	local data = {}
	data.friend = (seatId == 3) and g_AccountInfo:getId() or -1
	data.type = seatId==3 and 4 or 3 -- GiftPop.s_showType.SHOW_SEND_GIFT_ROOM 
	g_EventDispatcher:dispatch(g_SceneEvent.OPEN_GIFT_POPUP,data);
end

function TutorialScene:setSeatStatus(seatId, str)
	if self.m_seats and self.m_seats[seatId] then
		self.m_seats[seatId].labelStatus:setString(str)
	end
end

function TutorialScene:updateSeatHead(seatId, head)
	if self.m_seats and self.m_seats[seatId] then
		self.m_seats[seatId].head:setHeadIcon(head)
	end
end

-- 初始化规则提示
function TutorialScene:initRules()
	local labelGameRule = cc.Label:create()
	labelGameRule:setPosition(0,285)
	labelGameRule:setSystemFontSize(30)
	labelGameRule:setColor(cc.c3b(196,213,239))
	labelGameRule:setAnchorPoint(0,0)
	labelGameRule:setString(GameString.get("str_beginner_tutorial_poker_rule_title"))
	self.m_rule:addChild(labelGameRule)

	
	local pokerNum = CreatorRichText:create()
	pokerNum:setPosition(25,272)
	pokerNum:setFontSize(24)
	pokerNum:setAnchorPoint(0,1)
	pokerNum:setXMLData(GameString.get("str_beginner_tutorial_poker_rule_poker_num"))
	self.m_rule:addChild(pokerNum)

	local playerNum = CreatorRichText:create()
	playerNum:setPosition(25,232)
	playerNum:setFontSize(24)
	playerNum:setAnchorPoint(0,1)
	playerNum:setColor(cc.c3b(196,213,239))
	playerNum:setXMLData(GameString.get("str_beginner_tutorial_poker_rule_player_num"))
	self.m_rule:addChild(playerNum)

	
	local win = CreatorRichText:create()
	win:setPosition(0,180)
	win:setFontSize(24)
	win:setAnchorPoint(0,1)
	win:setColor(cc.c3b(196,213,239))
	win:setVerticalSpace(12)
	win:setXMLData(GameString.get("str_beginner_tutorial_poker_rule_win"))
	self.m_rule:addChild(win)
end


function TutorialScene:initDealerView()
	self.m_dealerView		 = g_NodeUtils:seekNodeByName(self.m_root, 'dealer_view')
	self.m_dealer = NetImageView:create('',"creator/normalRoom/img/dealer_default.png")
	self.m_dealerView:addChild(self.m_dealer)
	local size = self.m_dealerView:getContentSize()
	self.m_dealer:setPosition(cc.p(size.width/2,size.height/2))
	self.m_dealerView:setEnabled(false)

end
-- 初始化牌型文字
function TutorialScene:initCardType()
	for i=1,10 do
		local label = g_NodeUtils:seekNodeByName(self.m_cardTypeContainer, "label_type"..i)
		label:setString(i.."."..GameString.get("str_room_card_type")[i])
	end
end

function TutorialScene:initListener()
	self.m_btnNext:addClickEventListener(function() 
		self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_DO_NEXT)
	end)
	self.m_btnBack:addClickEventListener(function()
		self:clearRectTimer()
		self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_EXIT)
	end)
	self.m_btnPrivious:addClickEventListener(function()
		self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_DO_PRIVIOUS)
	end)
	self.m_btnRaise:addClickEventListener(function()
		if self.m_raiseNode:isVisible() == false then
			self.m_raiseSlider:setPercent(12)
			self.m_raiseNode:setVisible(true)
			self:showRaiseArrowAninm()
			self.m_btnNext:setVisible(false)
			self.m_imgOperateHighlight:setVisible(false)
			self.m_imgArrow:setVisible(false)
			self.m_imgArrow:stopAllActions()
			self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
		else
			self:bet(3,780)
			self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_DO_NEXT)
		end
	end)
	self.m_btnCheck:addClickEventListener(function()
		if self.m_curStep == 6 then
			self:bet(3, 20)
		elseif self.m_curStep == 8 then
			self:check(3)
		elseif self.m_curStep == 10 then
			self:bet(3,200)
			ChipManager:gatherPrizePool({[1]= self:getPoolChips()})
		end
		self.m_imgOperateHighlight:setVisible(false)
		self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_DO_NEXT)
	end)
	self.m_btnFinish:addClickEventListener(function()
		self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_COMPLETE_LEARNING)
	end)
	self.m_raiseSlider:addEventListener(handler(self,self.onRaiseSliderTouch))
	self.m_dealerView:addClickEventListener(handler(self,self.onDealerClick))
end

function TutorialScene:clearRectTimer()
	self.m_seats = self.m_seats or {}
	for _, seat in pairs(self.m_seats) do
		seat.timer:stop()
		seat.timer:removeFromParent()
	end
end

function TutorialScene:onDealerClick()
	self.m_dealerClicked = true
	self:resetGuideAnim()
	g_PopupManager:show(g_PopupConfig.S_POPID.TUTORIAL_DEALER_POP)
end

function TutorialScene:onRaiseSliderTouch(sender, eventType)
	Log.d("TutorialScene:onRaiseSliderTouch",eventType,sender:getPercent())
	if eventType  == 0 then
		if sender:getPercent() > 88 then
			sender:setPercent(88)
		elseif sender:getPercent() < 12 then
			sender:setPercent(12)
		end
		self:updateRaiseTx()
	end
end
function TutorialScene:updateRaiseTx()
	local money = 480
	local percent = self:getRaiseSliderPercent()
	local str = tostring(300 + math.ceil(money * percent))
	self.m_txRaiseNum:setString(str)
	self.m_btnAllIn:setVisible(percent == 1)
	self.m_btnAllIn:setEnabled(false)
	if percent == 1 then
		self:stopRaiseArrowAninm()
		-- if self.m_imgArrow:isVisible() then
			self:showOperateHighlight(self.m_btnRaise)
		-- end
		self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.RAISE_ENABLE)
	else
		self:showRaiseArrowAninm()
		self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
		self.m_imgOperateHighlight:setVisible(false)
		self.m_imgArrow:setVisible(false)
		self.m_imgArrow:stopAllActions()
	end
end

function TutorialScene:getRaiseSliderPercent()
	local percent = self.m_raiseSlider:getPercent() or 12
	return tonumber(string.format("%.2f", (percent - 12) / 76))
end

-- 设置上一步、下一步按钮是否可点击
function TutorialScene:setBtnEnable(enableType)
	if enableType == TutorialConfig.BUTTON_ENABLE.PRIVIOUS_ENABLE then
		self.m_btnPrivious:setEnabled(true)
		self.m_btnNext:setEnabled(false)
	elseif enableType == TutorialConfig.BUTTON_ENABLE.NEXT_ENABLE then
		self.m_btnPrivious:setEnabled(false)
		self.m_btnNext:setEnabled(true)
	elseif enableType == TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE then
		self.m_btnPrivious:setEnabled(true)
		self.m_btnNext:setEnabled(true)
	else
		self.m_btnPrivious:setEnabled(false)
		self.m_btnNext:setEnabled(false)
	end
end
-- 设置上一步、下一步按钮是否可见
function TutorialScene:setBtnVisible(visibleType)
	if visibleType == TutorialConfig.BUTTON_VISIBLE.PRIVIOUS_VISIBLE then
		self.m_btnPrivious:setVisible(true)
		self.m_btnNext:setVisible(false)
	elseif visibleType == TutorialConfig.BUTTON_VISIBLE.NEXT_VISIBLE then
		self.m_btnPrivious:setVisible(false)
		self.m_btnNext:setVisible(true)
	elseif visibleType == TutorialConfig.BUTTON_VISIBLE.BOTH_VISIBLE then
		self.m_btnPrivious:setVisible(true)
		self.m_btnNext:setVisible(true)
	else
		self.m_btnPrivious:setVisible(false)
		self.m_btnNext:setVisible(false)
	end
end

-- 下一步按钮上的提示是否可见
function TutorialScene:setBtnNextPromptVisible(visible)
	self.m_imgNextHighlight:setVisible(visible)
	self.m_imgArrow:setVisible(visible)
end

function TutorialScene:setOperateBtnEnable(enableType)
	self.m_btnFold:setColor(cc.c3b(124,124,124))
	self.m_btnFold:setEnabled(false)
	self.m_btnCheck:setColor(cc.c3b(124,124,124))
	self.m_btnCheck:setEnabled(false)
	self.m_btnRaise:setColor(cc.c3b(124,124,124))
	self.m_btnRaise:setEnabled(false)
	if enableType == TutorialConfig.OPERATE_BTN_ENABLE.FOLD_ENABLE then
		self.m_btnFold:setEnabled(true)
		self.m_btnFold:setColor(cc.c3b(255,255,255))
	elseif enableType == TutorialConfig.OPERATE_BTN_ENABLE.CHECK_ENABLE then
		self.m_btnCheck:setEnabled(true)
		self.m_btnCheck:setColor(cc.c3b(255,255,255))
	elseif enableType == TutorialConfig.OPERATE_BTN_ENABLE.RAISE_ENABLE then
		self.m_btnRaise:setEnabled(true)
		self.m_btnRaise:setColor(cc.c3b(255,255,255))
	end
end

function TutorialScene:initLogicFuncs()
	self.m_processFunc = {
		self.step1,
		self.step2,
		self.step3,
		self.step4,
		self.step5,
		self.step6,
		self.step7,
		self.step8,
		self.step9,
		self.step10,
		self.step11,
		self.step12,
		self.step13,
		self.step14,
	}
end

function TutorialScene:hideAllCards()
	for i=1,5 do
		self:hidePublicCard(i)
	end
	self:hidePublicCardTips()
	self:hideHandCards()
end

-- 显示引导allin的向上箭头动画
function TutorialScene:showRaiseArrowAninm()
	if self.m_raiseTipArrow:getNumberOfRunningActions() > 0 then
		return
	end
	if not self.m_raiseTipArrowSize then
		self.m_raiseTipArrowSize = self.m_raiseTipArrow:getContentSize()
		local point = self.m_sliderContainer:convertToWorldSpaceAR(cc.p(0,0))
		self.m_raiseTipArrow:setPosition(cc.p(point.x-5,point.y-50))
	end
	self.m_raiseTipArrow:setVisible(true)
	local size = self.m_raiseTipArrowSize 
	local shrink = cc.ResizeTo:create(0.7,cc.size(size.width,70))
	local easeIn = cc.EaseIn:create(shrink, 0.7)
	local zoom = cc.ResizeTo:create(0.7, cc.size(size.width,size.height))
	local easeOut = cc.EaseOut:create(zoom, 0.7)
	self.m_raiseTipArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(easeIn, easeOut)))
end

function TutorialScene:stopRaiseArrowAninm()
	self.m_raiseTipArrow:setVisible(false)
	self.m_raiseTipArrow:stopAllActions()
end

-- 显示游戏规则
function TutorialScene:step1()
	-- 从第二步返回
	if self.m_lastStep == 2 then
		self:hideAllCards()
		self.m_seatContainer:setVisible(false)
	end
	
	self.m_cardTypeContainer:setVisible(false)
	self.m_rule:setVisible(true)
	self:riseBottomBgAnim()
end

-- 公共牌介绍
function TutorialScene:step2()
	-- 由第3步倒回来
	if self.m_lastStep == 3 then
		self:hideAllCards()
	end
	self.m_seatContainer:setVisible(true)
	self:dealCard()
	self:downBottomBgAnim()
end

-- 亮牌及比牌介绍
function TutorialScene:step3()
	-- 由第4步倒回来
	if self.m_lastStep == 4 then
		self.m_seatContainer:setVisible(true)
		self:downBottomBgAnim()
		-- 显示公共牌
		self:showStep2Card(true)

		-- 恢复手牌
		local index = 1
		local handCards = TutorialConfig.HANDCARD_VALUE[1]
		for j = 1,2 do
			for i = 1,3 do
				if i == 3 then
					self.m_seats[i]["handcard"..j]:setCard(handCards[index])
					self.m_seats[i]["handcard"..j]:setVisible(true)
				else
					local poker = self.m_seats[i]["handcard"..j]
					self:initHandCard(poker,handCards[index])
					local index
					if j == 1 then
						index = i
					else
						index = i+3
					end
					poker:setPosition(cc.p(self.m_handcardSmallPos[index].x,self.m_handcardSmallPos[index].y))
				end
				index = index + 1
			end
		end
	end

	-- 玩家a 玩家b翻牌
	for i=1,2 do
		local callFunc = nil
		if i == 2 then
			callFunc = function()
				self.m_imgNextHighlight:setVisible(true)
				self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
				self:showNextBtnAnim()
			end
		end
		self:openOtherHandCard(i, callFunc)
	end	

	
end

-- 牌型大小提示
function TutorialScene:step4()
	self:hideAllCards()
	self.m_seatContainer:setVisible(false)
	self.m_operation:setVisible(false)
	self.m_cardTypeContainer:setVisible(true)
	self.m_rule:setVisible(false)
	self:riseBottomBgAnim()
end

-- 模拟玩家入座
function TutorialScene:step5()
	if self.m_lastStep == 6 then
		self:hideAllCards()
		ChipManager:hideAllBet()
		ChipManager:hideAllPot()
	end
	self.m_imgOperateHighlight:setVisible(false)
	self.m_seatContainer:setVisible(true)
	self.m_operation:setVisible(true)
	self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
	self:downBottomBgAnim()
end

-- 发牌并提示跟注
function TutorialScene:step6()
	if self.m_lastStep == 7 then
		ChipManager:refreshPot(1,0)
		self:hideAllCards()
		self:updatePoolChips(0)
	end
	
	self.m_operation:setVisible(true)
	self:dealCard() -- 发牌

	self:bet(1,10)
	self:bet(2,20)
	self.m_seats[1].labelStatus:setString(GameString.get("str_room_operation_type_5"))
	self.m_seats[2].labelStatus:setString(GameString.get("str_room_operation_type_6"))

	self:takeTurns(3)
end

-- 发公共牌
function TutorialScene:step7()
	if self.m_lastStep == 8 then
		for i=1,3 do
			self:hidePublicCard(i)
		end
		ChipManager:refreshBet(1,10)
		ChipManager:refreshBet(2,20)
		ChipManager:refreshBet(5,20)
		ChipManager:hideAllPot()
		self:updatePoolChips(50)
	end
	
	self.m_operation:setVisible(true)
	self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
	self.m_labelCheck:setString(GameString.get("str_room_check"))
	self.m_imgOperateHighlight:setVisible(false)
	
	self:takeTurns(1)
	-- local schedule = g_Schedule:schedulerOnce(function()
	-- 	self:bet(1,10)
	-- 	self:takeTurns(2)
	-- end,1)
	local times = 1
	local schedule = g_Schedule:schedule(function()
		if times == 1 then
			self:bet(1,10)
			self:takeTurns(2)
		else
			-- 玩家b看牌
			self:check(2)
			local publicCard = TutorialConfig.PUBLIC_CARD_VALUE[2]
			local callFunc = function()
				self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
				self:showNextBtnAnim()
			end
			for i=1,3 do
				self:showPublicCard(i,publicCard[i], (i==3 and callFunc() or nil))
			end
			ChipManager:gatherPrizePool({[1]= self:getPoolChips()})
		end
		times = times + 1
	end, 1,1,2)
	table.insert(self.m_schedules, schedule)
end

-- 看牌提示
function TutorialScene:step8()
	if self.m_lastStep == 9 then
		self:hidePublicCard(4)
		self.m_seats[3].handcard1:hideHighLight()
		self.m_seats[3].handcard2:hideHighLight()
	end
	self.m_operation:setVisible(true)
	self.m_labelCheck:setString(GameString.get("str_room_check"))
	
	self:takeTurns(1)

	local times = 1
	local schedule = g_Schedule:schedule(function()
		if times == 1 then
			self:check(1)
			self:takeTurns(2)
		else
			-- 玩家b看牌
			self:check(2)
			self:takeTurns(3)
			self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.PRIVIOUS_ENABLE)
			self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.CHECK_ENABLE)
			self:showOperateHighlight(self.m_btnCheck)
		end
		times = times + 1
	end, 1,1,2)
	table.insert(self.m_schedules, schedule)
end

-- 转牌
function TutorialScene:step9()
	if self.m_lastStep == 10 then
		ChipManager:hideAllBet()
		self:updatePoolChips(60)
		-- 玩家2恢复手牌
		local handCards = TutorialConfig.HANDCARD_VALUE[2]
		for j = 1,2 do
			local poker = self.m_seats[2]["handcard"..j]
			local index = 2
			if j ~= 1 then
				index = 5
			end
			self:initHandCard(poker,handCards[index])
			poker:setPosition(cc.p(self.m_handcardSmallPos[index].x,self.m_handcardSmallPos[index].y))
			poker:setRotation((j%2 == 0) and 15 or -5)
		end
	end
	
	self.m_operation:setVisible(true)
	self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
	self.m_labelCheck:setString(GameString.get("str_room_check"))
	self.m_imgOperateHighlight:setVisible(false)
	
	local publicCard = TutorialConfig.PUBLIC_CARD_VALUE[2]
	self:showPublicCard(4,publicCard[4], function()
		local schedule = g_Schedule:schedulerOnce(function()
			self["m_publicCard4"]:showHighLight()
			self.m_seats[3].handcard1:showHighLight()
			self.m_seats[3].handcard2:showHighLight()
			self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
			self:showNextBtnAnim()
		end,0.2)
		table.insert(self.m_schedules, schedule)
	end)
end

-- 转牌后跟注
function TutorialScene:step10()
	if self.m_lastStep == 11 then
		self:updatePoolChips(60)
		self:hidePublicCard(5)
		-- 玩家2恢复手牌
		self.m_seats[2].head:setColor(cc.c3b(255,255,255))
		local handCards = TutorialConfig.HANDCARD_VALUE[2]
		for j = 1,2 do
			local poker = self.m_seats[2]["handcard"..j]
			local index = 2
			if j ~= 1 then
				index = 5
			end
			self:initHandCard(poker,handCards[index])
			poker:setPosition(cc.p(self.m_handcardSmallPos[index].x,self.m_handcardSmallPos[index].y))
			poker:setRotation((j%2 == 0) and 15 or -5)
		end

	end
	self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.PRIVIOUS_ENABLE)
	self.m_operation:setVisible(true)
	
	self:takeTurns(1)
	local times = 1
	local schedule = g_Schedule:schedule(function()
		if times == 1 then
			self:bet(1,200)
			self:takeTurns(2)
		else
			-- 玩家b弃牌
			self:fold(2)

			self:takeTurns(3)
			self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.CHECK_ENABLE)
			self.m_labelCheck:setString(string.format(GameString.get("str_room_call"), "$200"))
			self:showOperateHighlight(self.m_btnCheck)
		end
		times = times + 1
	end, 1,1,2)
	table.insert(self.m_schedules, schedule)
end

-- 河牌
function TutorialScene:step11()
	if self.m_lastStep == 12 then
		self:updatePoolChips(460)
		self:hidePublicCard(5)
		ChipManager:hideAllBet()
		self:stopRaiseArrowAninm()
	end
	
	self.m_raiseNode:setVisible(false)
	self.m_operation:setVisible(true)
	self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
	self.m_labelCheck:setString(GameString.get("str_room_check"))
	self.m_imgOperateHighlight:setVisible(false)
	
	local publicCard = TutorialConfig.PUBLIC_CARD_VALUE[2]
	self:showPublicCard(5,publicCard[5], function()
		local schedule = g_Schedule:schedulerOnce(function()
			self["m_publicCard5"]:showHighLight()
			self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
			self:showNextBtnAnim()
		end, 0.2)
		table.insert(self.m_schedules, schedule)
	end)
	
end

-- 河牌后加注并Allin
function TutorialScene:step12()
	if self.m_lastStep == 13 then
		self:updatePoolChips(460)
		local handCards = TutorialConfig.HANDCARD_VALUE[2]
		-- 恢复玩家1的手牌
		for j = 1,2 do
			local poker = self.m_seats[1]["handcard"..j]
			local index = 1
			if j ~= 1 then
				index = 4
			end
			self:initHandCard(poker,handCards[index])
			poker:setPosition(cc.p(self.m_handcardSmallPos[index].x,self.m_handcardSmallPos[index].y))
			poker:setRotation((j%2 == 0) and 15 or -5)
		end
		-- 隐藏youwin
		if self.m_bigWinLabel then
			self.m_bigWinLabel:removeFromParent(true)
			self.m_bigWinLabel = nil
		end

		self["m_publicCard" .. 1]:hideFadeCard()
		self["m_publicCard" .. 2]:hideFadeCard()
		self["m_publicCard" .. 3]:hideHighLight()
	end
	self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.PRIVIOUS_ENABLE)
	
	self.m_operation:setVisible(true)
	
	self:takeTurns(1)
	local schedule = g_Schedule:schedulerOnce(function()
		self:bet(1,300)
		self:takeTurns(3)
		self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.RAISE_ENABLE)
		self.m_labelCheck:setString(string.format(GameString.get("str_room_call"), "$300"))
		self:showOperateHighlight(self.m_btnRaise)
	end,1)
	table.insert(self.m_schedules, schedule)
end

-- 演示玩牌结束进行比牌
function TutorialScene:step13()
	if self.m_lastStep == 14 then
		self.m_dealerClicked = false
		self.m_giftClicked = false
		self:stopGuideAnim()
		self.m_dealerView:setEnabled(false)
		self:setGiftBtnEnabled(false)
		self:updatePoolChips(460)
		ChipManager:refreshBet(1,300)
		self:addPoolChip(300)
		ChipManager:refreshBet(5,780)
		self:addPoolChip(780)

		-- 移除礼物
		for i=1,3 do
			self:updateGiftView(nil,i)
		end

		local handCards = TutorialConfig.HANDCARD_VALUE[2]
		-- 恢复玩家1的手牌
		for j = 1,2 do
			local poker = self.m_seats[1]["handcard"..j]
			local index = 1
			if j ~= 1 then
				index = 4
			end
			self:initHandCard(poker,handCards[index])
			poker:setPosition(cc.p(self.m_handcardSmallPos[index].x,self.m_handcardSmallPos[index].y))
			poker:setRotation((j%2 == 0) and 15 or -5)
		end
		
		for i = 1,5 do
			self["m_publicCard" .. i]:setVisible(true)
		end
		self["m_publicCard" .. 1]:hideFadeCard()
		self["m_publicCard" .. 2]:hideFadeCard()
		self["m_publicCard" .. 3]:hideHighLight()
		self.m_seats[3]["handcard"..1]:setVisible(true)
		self.m_seats[3]["handcard"..2]:setVisible(true)
	end
	-- self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
	self.m_raiseNode:setVisible(false)
	self.m_operation:setVisible(true)
	self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.ALL_DISABLE)
	self.m_labelCheck:setString(GameString.get("str_room_check"))
	self.m_imgOperateHighlight:setVisible(false)
	self.m_btnFinish:setVisible(false)

	self:takeTurns(1)
	local schedule1 = g_Schedule:schedulerOnce(function()
		self:bet(1,480)
	end,1)
	table.insert(self.m_schedules, schedule1)
	local schedule2 = g_Schedule:schedulerOnce(function()
		ChipManager:gatherPrizePool({[1]= self:getPoolChips()})
		-- 玩家a翻牌
		self:openOtherHandCard(1, function() 
			self["m_publicCard1"]:showFadeCard()
			self["m_publicCard2"]:showFadeCard()
			self["m_publicCard3"]:showHighLight()
			self.m_seats[1].handcard1:showFadeCard()
			self.m_seats[1].handcard2:showFadeCard()
			self:splitPotAnim()
			
		end)
	end,2.5)
	table.insert(self.m_schedules, schedule2)

end

-- 瓜分奖池动画
function TutorialScene:splitPotAnim()
	local potChips = g_NodeUtils:seekNodeByName(self.m_root, "potChip1")
	ChipManager:hideAllPot()

	local seatView = self.m_seats[3].seatContainer
	local p = seatView:getParent():convertToWorldSpace(cc.p(seatView:getPosition()))
	local tp = potChips:convertToNodeSpace(p)
	local chip = ChipManager:getChip(2020)
	local action = cc.MoveTo:create(ChipManager.MOVE_POT_DURATION, tp)
	local actionFunc = cc.CallFunc:create(function ()
		chip:removeFromParent(true)
		self.m_seats[3].labelMoney:setString("$"..2020)
		-- youwin动画
		self:showWinAnim()
		
	end)
	local sequenceAction = cc.Sequence:create(action,actionFunc)
	potChips:addChild(chip)
	chip:runAction(sequenceAction)

end
-- 提示与荷官互动及赠送玩家筹码
function TutorialScene:step14()
	self.m_guideInterval = 5
	self:guideAnim()

	self.m_dealerView:setEnabled(true)
	self:setGiftBtnEnabled(true)
	ChipManager:hideAllPot()
	self:hideAllCards()
	if self.m_bigWinLabel then
		self.m_bigWinLabel:removeFromParent(true)
		self.m_bigWinLabel = nil
	end
	self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.PRIVIOUS_ENABLE)
	self.m_operation:setVisible(false)
	self.m_imgOperateHighlight:setVisible(false)
	self.m_btnFinish:setVisible(true)
end

-- 底部背景上升动画
function TutorialScene:riseBottomBgAnim()
	local x,y = self.m_bottomPosX, self.m_bottomPosY
	local size = self.m_imgBottom:getContentSize()
	self.m_imgBottom:setPosition(x,y-size.height)
	local riseAction = cc.MoveBy:create(1,cc.p(0,size.height))
	local callAction = cc.CallFunc:create(function()
		self:onRiseBgDownAnimFinished()
	end)
	local actions = cc.Sequence:create(riseAction, callAction)
	self.m_imgBottom:runAction(actions)

end
function TutorialScene:onRiseBgDownAnimFinished()
	if self.m_curStep == 1 then
		self:setBtnVisible(TutorialConfig.BUTTON_VISIBLE.NEXT_VISIBLE)
		self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.NEXT_ENABLE)
		self:showNextBtnAnim()
	elseif self.m_curStep == 4 then -- 牌型提示
		self:setBtnVisible(TutorialConfig.BUTTON_VISIBLE.BOTH_VISIBLE)
		self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
		self:showNextBtnAnim()
	end
end
-- 底部背景下降动画
function TutorialScene:downBottomBgAnim()
	local _,y = self.m_imgBottom:getPosition()
	if(y ~= self.m_bottomPosY) then -- 底下背景未正常显示无需动画
		self:onBottomBgDownAnimFinished()
		return 
	end
	local size = self.m_imgBottom:getContentSize()
	local riseAction = cc.MoveBy:create(1,cc.p(0,-size.height))
	local callAction = cc.CallFunc:create(function()
		self:onBottomBgDownAnimFinished()
	end)
	local actions = cc.Sequence:create(riseAction, callAction)
	self.m_imgBottom:runAction(actions)
end

function TutorialScene:onBottomBgDownAnimFinished()
	if self.m_curStep == 2 then
		-- self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
		-- self:showNextBtnAnim()
	elseif self.m_curStep == 5 then -- 占位 真实逻辑不在这里
		self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
		self:showNextBtnAnim()
	end
end

-- 下一步按钮上的箭头动画
function TutorialScene:showNextBtnAnim()
	self.m_imgNextHighlight:setVisible(true)
	local x, y = self.m_imgNextHighlight:getPosition()
	self:showArrowAnim(x,y)
end

-- 箭头动画
function TutorialScene:showArrowAnim(x,y)
	self.m_imgArrow:setVisible(true)
	if self.m_imgArrow:getNumberOfRunningActions() > 0 then
		return
	end
	local size = self.m_imgArrow:getContentSize()
	self.m_imgArrow:setPosition(x,y + size.height + TutorialConfig.ARROW_ANIM_MOVE_DISTANCE)
	local downAction = cc.MoveBy:create(0.5, cc.p(0,-TutorialConfig.ARROW_ANIM_MOVE_DISTANCE))
	local riseAction = cc.MoveBy:create(0.5, cc.p(0,TutorialConfig.ARROW_ANIM_MOVE_DISTANCE))
	local actions = cc.RepeatForever:create(cc.Sequence:create(downAction, riseAction))
	self.m_imgArrow:runAction(actions)
end
-- 7 显示跟住 13 allin
function TutorialScene:doOperation(step)
	g_Model:clearData(g_ModelCmd.TUTORIAL_GIFT_CLICKED);    
	self.m_lastStep = self.m_curStep
	self.m_curStep = step
	self:refreshChips()
	self:cancalAllTimer()
	if step == 1 then
		self:setBtnVisible(TutorialConfig.BUTTON_VISIBLE.BOTH_INVISIBLE)
	elseif step == 14 then
		self:setBtnVisible(TutorialConfig.BUTTON_VISIBLE.PRIVIOUS_VISIBLE)
	else
		self:setBtnVisible(TutorialConfig.BUTTON_VISIBLE.BOTH_VISIBLE)
	end
	self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_DISENABLE)
	self.m_imgNextHighlight:setVisible(false)
	self.m_imgArrow:setVisible(false)
	self.m_imgOperateHighlight:setVisible(false)
	self.m_imgArrow:stopAllActions()
	self.m_labelDialog:setString(GameString.get("str_beginner_tutorial_msg")[step])
	local size = self.m_labelDialog:getContentSize()
	self.m_imgDialog:setContentSize(390, size.height+45)
	if self.m_processFunc and self.m_processFunc[step] then
		self.m_processFunc[step](self)
	end
end


-- 显示操作区高亮提示
function TutorialScene:showOperateHighlight(node)
	self.m_imgOperateHighlight:setVisible(true)
	local x,y = node:getPosition()
	local p = self.m_operation:convertToWorldSpace(cc.p(x,y))
	local size = self.m_imgOperateHighlight:getContentSize()
	self.m_imgOperateHighlight:setPosition(cc.p(p.x, p.y+3))
	self:showArrowAnim(p.x,p.y)
end

-- 灯光
function TutorialScene:lightTo(seatId, duration)
	duration = duration or 0.2
	self.m_tableLight:setVisible(true)
	local seat = self.m_seats[seatId].seatContainer
	local x,y = seat:getPosition()
	self.m_tableLight:setRotation({x = x, y = y}, duration)
end

-- 初始化牌桌上公共牌
function TutorialScene:initPublicCard()
	for i = 1, 5 do
		self["m_publicCard" .. i] = g_PokerCard:create()
		self["m_publicCard" .. i]:setVisible(false)
		self["m_publicCard" .. i]:setName("m_publicCard" .. i)
		self.m_table:addChild(self["m_publicCard" .. i])
		g_NodeUtils:arrangeToCenter(self["m_publicCard" .. i], (i -3) * (g_PokerCard.CARD_WIDTH + 10), 90)
	end
end

function TutorialScene:updatePublicCard(publicCard)
	if g_TableLib.isEmpty(publicCard) then return end
	Log.d("NormalRoomScene:updatePublicCard", publicCard)
	if type(publicCard) == "table" then
		for i = 1, #publicCard do
			self["m_publicCard" .. i]:setCard(publicCard[i])
			self["m_publicCard" .. i]:setVisible(true)
		end
	end
end

function TutorialScene:showPublicCard(index, value, callFunc)
	self["m_publicCard" .. index]:hideHighLight()
	self["m_publicCard" .. index]:setCard(value)
	self["m_publicCard" .. index]:setVisible(true)
	self["m_publicCard" .. index]:showBack()
	self["m_publicCard" .. index]:flipCardStage1(callFunc)
end

-- 第一步中显示公共牌的提示
function TutorialScene:showPublicCardTips()
	if self.m_table:getChildByName("publicTipImg1") then
		self.m_table:getChildByName("publicTipImg1"):setVisible(true)
		self.m_table:getChildByName("publicTipImg2"):setVisible(true)
		self.m_table:getChildByName("publicTipImg3"):setVisible(true)
		return
	end
	local publicCard1 = self.m_table:getChildByName("m_publicCard1")
	local x, y = publicCard1:getPosition()
	local size = publicCard1:getContentSize()
	local spaceH = 5 -- 横向距离与牌的间隔
	local height = size.height + 45
	local top = y-10
	local left = x-g_PokerCard.CARD_WIDTH/2- spaceH
	local fontSize = 20
	local fontColor = cc.c3b(255,255,255)
	local fontLineSpace = 5
	
	local imgTips1 = ccui.Scale9Sprite:create("creator/tutorial/img/tutoria_public_card_tips_frame.png")
	local w = (g_PokerCard.CARD_WIDTH+spaceH*2)*3
	imgTips1:setContentSize(cc.size(w, height))
	imgTips1:setAnchorPoint(0,0.5)
	imgTips1:setPosition(left, top)
	imgTips1:setName("publicTipImg1")
	self.m_table:addChild(imgTips1)
	left = left+w
	local label1 = cc.Label:createWithSystemFont(GameString.get("str_beginner_tutorial_public_card_tips_one"), nil, fontSize)
	label1:setTextColor(fontColor)
	label1:setAnchorPoint(0,0)
	imgTips1:addChild(label1)
	local labelSize = label1:getContentSize()
	label1:setPosition((w-labelSize.width)/2,fontLineSpace)


	local imgTips2 = ccui.Scale9Sprite:create("creator/tutorial/img/tutoria_public_card_tips_frame.png")
	w = g_PokerCard.CARD_WIDTH+spaceH*2
	imgTips2:setContentSize(cc.size(w, height))
	imgTips2:setAnchorPoint(0,0.5)
	imgTips2:setPosition(left, top)
	imgTips2:setName("publicTipImg2")
	self.m_table:addChild(imgTips2)
	left = left+w
	local label2 = cc.Label:createWithSystemFont(GameString.get("str_beginner_tutorial_public_card_tips_two"), nil, fontSize)
	label2:setTextColor(fontColor)
	label2:setAnchorPoint(0,0)
	imgTips2:addChild(label2)
	local labelSize = label2:getContentSize()
	label2:setPosition((w-labelSize.width)/2,fontLineSpace)

	local imgTips3 = ccui.Scale9Sprite:create("creator/tutorial/img/tutoria_public_card_tips_frame.png")
	w = g_PokerCard.CARD_WIDTH+spaceH*2
	imgTips3:setContentSize(cc.size(w, height))
	imgTips3:setAnchorPoint(0,0.5)
	imgTips3:setPosition(left, top)
	imgTips3:setName("publicTipImg3")
	self.m_table:addChild(imgTips3)
	local label3 = cc.Label:createWithSystemFont(GameString.get("str_beginner_tutorial_public_card_tips_three"), nil, fontSize)
	label3:setTextColor(fontColor)
	label3:setAnchorPoint(0,0)
	imgTips3:addChild(label3)
	local labelSize = label3:getContentSize()
	label3:setPosition((w-labelSize.width)/2,fontLineSpace)

end
function TutorialScene:hidePublicCardTips()
	if self.m_table:getChildByName("publicTipImg1") then
		self.m_table:getChildByName("publicTipImg1"):setVisible(false)
		self.m_table:getChildByName("publicTipImg2"):setVisible(false)
		self.m_table:getChildByName("publicTipImg3"):setVisible(false)
		return
	end
end

function TutorialScene:hidePublicCard(index)
	self["m_publicCard" .. index]:setVisible(false)
end

-- 发牌
function TutorialScene:dealCard()
	local t = 0
	local seatId = 1
	local centerX = self:convertToNodeSpace(display.center)
	local handCards = TutorialConfig.HANDCARD_VALUE[1]
	if self.m_curStep > 5 then
		handCards = TutorialConfig.HANDCARD_VALUE[2]
	end
	self.m_handcardSmallPos = {}
	for i = 1,6 do
		local cardValue = handCards[i]
		if seatId > 3 then seatId = seatId - 3 end
		local sid = seatId
		local schedule = g_Schedule:schedulerOnce(function()
			
			local poker = nil
			local seat = self.m_seats[sid]
			local seatView = seat.seatContainer
			if i == sid and self.m_seats[sid].handcard1 then
				poker = self.m_seats[sid].handcard1 
			elseif i ~= sid and self.m_seats[sid].handcard2 then
				poker = self.m_seats[sid].handcard2
			else
				poker = g_PokerCard:create()
				local sx, sy = poker:getPosition()
				TutorialConfig.HANDCARD_SMALL_POSTION[sid].x = TutorialConfig.HANDCARD_SMALL_POSTION[sid].x + sx
				TutorialConfig.HANDCARD_SMALL_POSTION[sid].y = TutorialConfig.HANDCARD_SMALL_POSTION[sid].y + sy
				seatView:addChild(poker)
			end
			
			self:initHandCard(poker,cardValue)
			
			local point = seatView:convertToNodeSpace(display.center)
			poker:setPosition(point.x+20, point.y+100)

			local size = poker:getContentSize()
			local offsetX = (i ~= sid) and (sid == 3 and size.width/3 or size.width/5) or 0
			local x = TutorialConfig.HANDCARD_SMALL_POSTION[sid].x + offsetX
			local y = TutorialConfig.HANDCARD_SMALL_POSTION[sid].y
			local curAction  = cc.MoveTo:create(0.2, cc.p( x, y))
			self.m_handcardSmallPos[i] = {
				x = x,
				y = y
			}
			local actionFunc = cc.CallFunc:create(function ()
				poker:setRotation((i ~= sid) and 15 or -5)
				if i == sid then
					self.m_seats[sid].handcard1 = poker
				else
					self.m_seats[sid].handcard2 = poker
				end
				if sid == 3 then
					poker:setScale(1)
					if i ~= sid then
						self:onDealCardFinish()
					end
				end
			end)
			local sequenceAction = cc.Sequence:create(curAction,actionFunc)
			poker:runAction(sequenceAction)
			
		end,t)
		table.insert(self.m_schedules, schedule)
		t = t + 0.2
		seatId = seatId + 1
	end
end

function TutorialScene:initHandCard(poker, cardValue)
	poker:setVisible(true)
	poker:hideHighLight()
	poker:setCard(cardValue)
	poker:showBack()
	poker:setScale(0.5)
end

function TutorialScene:onDealCardFinish()
	local mySeat = self.m_seats[3]
	mySeat.handcard1:flipCardStage1()
	mySeat.handcard2:flipCardStage1(function()
		if self.m_curStep == 2 then
			self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
			self:showNextBtnAnim()
		elseif self.m_curStep == 6 then
			self:setOperateBtnEnable(TutorialConfig.OPERATE_BTN_ENABLE.CHECK_ENABLE)
			self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.PRIVIOUS_ENABLE)
			self.m_labelCheck:setString(string.format(GameString.get("str_room_call"), "$20"))
			self:showOperateHighlight(self.m_btnCheck)
		end
	end)
	if self.m_curStep == 2 then
		
		self:showStep2Card()
	end
end

function TutorialScene:showStep2Card(isUpdate)
	local mySeat = self.m_seats[3]
	local publicCard = TutorialConfig.PUBLIC_CARD_VALUE[1]

	if isUpdate then
		self:updatePublicCard(publicCard)
	else
		for k,v in pairs(publicCard) do
			self:showPublicCard(k,v)
		end
	end
	self:showPublicCardTips()
	
	mySeat.handcard1:showHighLight()
	mySeat.handcard2:showHighLight()
	self["m_publicCard1"]:showHighLight()
	self["m_publicCard3"]:showHighLight()
	self["m_publicCard5"]:showHighLight()
end

function TutorialScene:hideHandCards()
	for i=1,3 do
		self.m_seats[i].handcard1:setVisible(false)
		self.m_seats[i].handcard2:setVisible(false)
	end
end

-- 接开其他玩家的牌
function TutorialScene:openOtherHandCard(seatId, callFunc)
	local scale = 0.91
	self.m_seats[seatId].handcard1:setVisible(true)
	self.m_seats[seatId].handcard2:setVisible(true)
	local x,y = self.m_seats[seatId].handcard1:getPosition()
	local offsetX1 = TutorialConfig.HANDCARD_NORMAL_POSTION.offsetX1
	local offsetY = TutorialConfig.HANDCARD_NORMAL_POSTION.offsetY
	local offsetX2 = TutorialConfig.HANDCARD_NORMAL_POSTION.offsetX2
	self.m_seats[seatId].handcard1:setPosition(x+offsetX1,y+offsetY)
	self.m_seats[seatId].handcard1:setScale(scale)
	self.m_seats[seatId].handcard1:setRotation(0)
	local x,y = self.m_seats[seatId].handcard2:getPosition()
	self.m_seats[seatId].handcard2:setScale(scale)
	self.m_seats[seatId].handcard2:setRotation(0)
	self.m_seats[seatId].handcard2:setPosition(x+offsetX2,y+offsetY)

	
	self.m_seats[seatId].handcard1:flipCardStage1()
	self.m_seats[seatId].handcard2:flipCardStage1(callFunc)
end


function TutorialScene:startTimer(seatId, time)
	local timer = self.m_seats[seatId].timer
	timer:setVisible(true)
	timer:start(function ()
		self:stopTimer(seatId)
	end,time or 10)
end

function TutorialScene:stopTimer(seatId)
	local timer = self.m_seats[seatId].timer
	timer:setVisible(false)
	timer:stop()

end

-- 玩家下注
function TutorialScene:bet(seatId, betMoney)
	self:addPoolChip(betMoney)
	-- 停止倒计时
	self:stopTimer(seatId)
	-- 下注动画
	self:addCurBetChips(seatId, betMoney)
	self:updateSeatLabelInfo(seatId)
	ChipManager:popChip(betMoney, self:getCurBetChips(seatId), self.m_seats[seatId]);      --筹码动画
	ChipManager:refreshBet(self.m_seats[seatId]:getPosId(), self:getCurBetChips(seatId));
end

function TutorialScene:updateSeatLabelInfo(seatId)
	local curMoney = self:getCurRoundChips(seatId)- self:getCurBetChips(seatId)
	self.m_seats[seatId].labelMoney:setString("$"..curMoney)
	if self.m_curStep== 13 and seatId==1 then
		self.m_seats[seatId].labelStatus:setString(GameString.get("str_room_operation_type_3"))
	else
		self.m_seats[seatId].labelStatus:setString(GameString.get("str_room_operation_type_8"))
	end
end

function TutorialScene:clearSeatLabelInfo(seatId)
	local curMoney = self:getCurRoundChips(seatId)- self:getCurBetChips(seatId)
	self.m_seats[seatId].labelMoney:setString("$"..curMoney)
	self.m_seats[seatId].labelStatus:setString(TutorialConfig.SEAT_INIT_INFO[seatId].status)
	if self.m_curStep== 7 and seatId==3 then
		self.m_seats[seatId].labelStatus:setString(GameString.get("str_room_operation_type_4"))
	elseif self.m_curStep==13 and seatId==3 then
		self.m_seats[3].labelStatus:setString(GameString.get("str_room_operation_type_3"))
	end
end

-- 玩家弃牌
function TutorialScene:fold(seatId)
	self.m_seats[seatId].labelStatus:setString(GameString.get("str_room_operation_type_2"))
	-- 停止倒计时
	self:stopTimer(seatId)
	-- 弃牌动画
	local seatView = self.m_seats[seatId].seatContainer
	self.m_seats[seatId].head:setColor(cc.c3b(165,165,165))
	local parent = seatView:getParent()
	local pSize = parent:getContentSize()
	local handcard1 = self.m_seats[seatId].handcard1
	local handcard2 = self.m_seats[seatId].handcard2

	local worldP = parent:convertToWorldSpace(cc.p(pSize.width / 2, pSize.height * 0.8 ))
	local p = seatView:convertToNodeSpace(worldP)
	local action1 = cc.MoveTo:create(0.3, p)
	local action2 = cc.MoveTo:create(0.3, p)
	local actionFunc = cc.CallFunc:create(function ()
		handcard1:setVisible(false)
		handcard2:setVisible(false)
	end)
	local sequenceAction = cc.Sequence:create(action1,actionFunc)
	handcard1:runAction(sequenceAction)
	handcard2:runAction(action2)
	-- 筹码入池动画

end

-- 玩家看牌
function TutorialScene:check(seatId)
	self.m_seats[seatId].labelStatus:setString(GameString.get("str_room_operation_type_7"))
	-- 停止倒计时
	self:stopTimer(seatId)
end

-- 轮到谁操作
function TutorialScene:takeTurns(seatId)
	if seatId > 3 then seatId = 1 end
	self:lightTo(seatId)
	self:startTimer(seatId)
end



function TutorialScene:showWinAnim()
	local seatView = self.m_seats[3].seatContainer
	local seatFrame = cc.Sprite:create("creator/normalRoom/img/win/small-win-seat-frame.png")
	seatFrame:setContentSize(128, 176)
	seatView:addChild(seatFrame)
	g_NodeUtils:arrangeToCenter(seatFrame)
	
	local winLabel = cc.Sprite:create("creator/normalRoom/img/win/small-win-label.png")
	seatView:addChild(winLabel)
	g_NodeUtils:arrangeToCenter(winLabel)
	winLabel:setScale(0.5, 0.5)
	winLabel:runAction(cc.ScaleTo:create(1.5, 1, 1))
	winLabel:runAction(cc.MoveBy:create(1.5, cc.p(0, 80)))
	winLabel:runAction(cc.Sequence:create(cc.FadeTo:create(1.5, 0.9), cc.CallFunc:create(function ()
		winLabel:removeFromParent(true)
		seatFrame:removeFromParent(true)
		self:showNextBtnAnim()
		self:setBtnEnable(TutorialConfig.BUTTON_ENABLE.BOTH_ENABLE)
	end)))

	local seatContainer = self.m_seatContainer
	self.m_bigWinLabel = cc.Sprite:create("creator/normalRoom/img/win/large-win-label.png")
	self.m_bigWinLabel:setLocalZOrder(10)
	self.m_table:addChild(self.m_bigWinLabel)
	g_NodeUtils:arrangeToTopCenter(self.m_bigWinLabel)
	local star1 = cc.Sprite:create("creator/normalRoom/img/win/small-win-spark-star.png")
	local star2 = cc.Sprite:create("creator/normalRoom/img/win/small-win-spark-star.png")
	local star3 = cc.Sprite:create("creator/normalRoom/img/win/small-win-spark-star.png")
	
	self.m_bigWinLabel:addChild(star1)
	self.m_bigWinLabel:addChild(star2)
	self.m_bigWinLabel:addChild(star3)
	star1:setPosition(55, 60)
	star2:setPosition(100, 0)
	star3:setPosition(380, 80)
	
	self.m_bigWinLabel:runAction(cc.EaseBounceOut:create(cc.MoveBy:create(0.7, cc.p(0, -100))))
end

function TutorialScene:refreshChips()
	self:refreshRouchChips()
	self:refreshBetChips()
	for i=1,3 do
		self:clearSeatLabelInfo(i)
	end

end
function TutorialScene:refreshRouchChips()
	if self.m_curStep <= 7 then
		self:setCurRoundChips(1, 1000)
		self:setCurRoundChips(2, 1000)
		self:setCurRoundChips(3, 1000)
	elseif self.m_curStep < 11 then
		self:setCurRoundChips(1, 980)
		self:setCurRoundChips(2, 980)
		self:setCurRoundChips(3, 980)
	elseif self.m_curStep <= 13 then
		self:setCurRoundChips(1, 780)
		self:setCurRoundChips(2, 980)
		self:setCurRoundChips(3, 780)
	elseif self.m_curStep == 14 then
		self:setCurRoundChips(1, 0)
		self:setCurRoundChips(2, 980)
		self:setCurRoundChips(3, 2020)
	end
end

function TutorialScene:refreshBetChips()
	if self.m_curStep < 7 then
		self:setCurBetChips(1, 0)
		self:setCurBetChips(2, 0)
		self:setCurBetChips(3, 0)
	elseif self.m_curStep == 7 then
		self:setCurBetChips(1, 10)
		self:setCurBetChips(2, 20)
		self:setCurBetChips(3, 20)
	elseif self.m_curStep < 11 then
		self:setCurBetChips(1, 0)
		self:setCurBetChips(2, 0)
		self:setCurBetChips(3, 0)
	elseif self.m_curStep <= 12 then
		self:setCurBetChips(1, 0)
		self:setCurBetChips(2, 0)
		self:setCurBetChips(3, 0)
	elseif self.m_curStep == 13 then
		self:setCurBetChips(1, 300)
		self:setCurBetChips(2, 0)
		self:setCurBetChips(3, 780)
	elseif self.m_curStep == 14 then
		self:setCurBetChips(1, 0)
		self:setCurBetChips(2, 0)
		self:setCurBetChips(3, 0)
	end
end
-- 获取当前这一轮对应座位上的筹码数
function TutorialScene:getCurRoundChips(seatId)
	return self.m_curRoundChips and self.m_curRoundChips[seatId] or 0
end
-- 设置当前这一轮对应座位上的筹码数
function TutorialScene:setCurRoundChips(seatId, money)
	if not self.m_curRoundChips then
		self.m_curRoundChips = {}
	end
	self.m_curRoundChips[seatId] = money
end

-- 设置当前这一轮对应座位上的下注筹码数
function TutorialScene:setCurBetChips(seatId, money)
	if not self.m_curBetChips then
		self.m_curBetChips = {}
	end
	self.m_curBetChips[seatId] =  money
end
-- 增加当前这一轮对应座位上的下注筹码数
function TutorialScene:addCurBetChips(seatId, money)
	if not self.m_curBetChips then
		self.m_curBetChips = {}
	end
	self.m_curBetChips[seatId] = (self.m_curBetChips[seatId] or 0)+ money
end
-- 获取当前这一轮对应座位上的下注筹码数
function TutorialScene:getCurBetChips(seatId)
	return self.m_curBetChips and self.m_curBetChips[seatId] or 0
end

-- 获取奖池中的筹码数
function TutorialScene:getPoolChips()
	return self.m_poolChips or 0
end
-- 增加奖池中的筹码数
function TutorialScene:addPoolChip(chip)
	self.m_poolChips = (self.m_poolChips or 0) + chip
end
function TutorialScene:updatePoolChips(chips)
	self.m_poolChips = chips
	ChipManager:refreshPot(1,self.m_poolChips)
end

function TutorialScene:cancalAllTimer()
	for i=1,3 do
		self:stopTimer(i)
	end
end

function TutorialScene:onSendChipsSucc(data)
	local fromeView = self.m_seats[3].seatContainer
	local toView = self.m_dealerView
	PropAnim:playSendChipAnim(data,self.m_table,fromeView,toView)
end

-- 发送互动道具、并播放动画
function TutorialScene:onSendPropSucc(data)
	local fromeView = self.m_seats[3].seatContainer
	local toView = self.m_dealerView
	PropAnim:playPropAnim(data,self.m_table,fromeView,toView)
end


function TutorialScene:updateGiftView(giftid, toSeatId)
	local giftFront = self.m_seats[toSeatId]["gift"].giftFront
	giftFront:removeAllChildren()
	if giftid then
		giftFront:setGift(giftid,"creator/normalRoom/img/gift.png", self, self.onLoadGiftComplete, toSeatId)
	else
		giftFront:setGift(nil,"creator/normalRoom/img/gift.png")
	end

end

function TutorialScene:onLoadGiftComplete(toSeatId)
	local giftFront = self.m_seats[toSeatId]["gift"].giftFront
	local tx,ty = giftFront:getPosition()
	local selfGiftFront = self.m_seats[3]["gift"].giftView
	local fx,fy = selfGiftFront:getPosition()
	local fPoint = self:getRelativePos(selfGiftFront,giftFront)
	local tPoint = self:getRelativePos(giftFront,giftFront)
	giftFront:setPosition(fPoint)
	local moveAction = cc.MoveTo:create(0.7,tPoint)
	giftFront:runAction(moveAction)
end

function TutorialScene:getRelativePos(fromNode,toNode)
	if fromNode and toNode then
		local point = fromNode:convertToWorldSpaceAR(cc.p(0,0))
		return toNode:convertToNodeSpace(point)
	end
	return nil
end

-- 赠送礼物成功
function TutorialScene:onSendGiftSucc(data, isBuy2Table)
	if data and data.id then
		local toUids = {self.m_giftClickedId}
		if isBuy2Table then
			toUids = {1,2,3}
		end
		for k,v in pairs(toUids) do
			self:updateGiftView(data.id, tonumber(v))
		end
	end
end

-- 设置礼物按钮是否可点击
function TutorialScene:setGiftBtnEnabled(enable)
	for i=1,3 do
		self.m_seats[i].gift.giftBtn:setEnabled(enable)
	end
end

-- 荷官功能引导动画
function TutorialScene:guideAnim()
	if self.m_dealerClicked and self.m_giftClicked then return end
	self.m_guideTimes = 1
	
	local moveDistance = 80
	self.m_guideNode = cc.Node:create()
	self.m_dealerView:addChild(self.m_guideNode)
	g_NodeUtils:arrangeToCenter(self.m_guideNode)
	self.m_guideNode:retain()	

	local point = cc.Sprite:create()
	point:setName("guidePoint")
	point:setTexture("creator/tutorial/img/tips_point.png")
	self.m_guideNode:addChild(point)
	

	local finger = cc.Sprite:create()
	finger:setName("guideFinger")
	finger:setPosition(cc.p(moveDistance, -moveDistance))
	finger:setAnchorPoint(cc.p(0.3, 1))
	finger:setTexture("creator/tutorial/img/finger.png")
	self.m_guideNode:addChild(finger)
	
	self.m_guideSchedule = g_Schedule:schedule(function(dt)
		
		if self.m_guideNode:getParent() then
			self.m_guideNode:removeFromParent(false)
		end
		if self.m_dealerClicked then --荷官点击过
			self.m_seats[1].gift.giftBtn:addChild(self.m_guideNode)
		elseif self.m_giftClicked then -- 礼物点击过
			self.m_dealerView:addChild(self.m_guideNode)
		else -- 都未被点击过
			if(self.m_guideTimes%2 == 0 ) then
				self.m_seats[1].gift.giftBtn:addChild(self.m_guideNode)
			else
				if self.m_dealerClicked ~= true then
					self.m_dealerView:addChild(self.m_guideNode)
				end
			end
		end
		g_NodeUtils:arrangeToCenter(self.m_guideNode)
		local finger = self.m_guideNode:getChildByName("guideFinger")
		local point = self.m_guideNode:getChildByName("guidePoint")
		local moveFarAction = cc.MoveBy:create(1, cc.p(moveDistance, -moveDistance))
		local moveFarCallFunc = cc.CallFunc:create(function()
			point:stopAllActions()
			point:setScale(1)
			point:setOpacity(255)
		end)
		local moveNearAction = cc.MoveBy:create(1, cc.p(-moveDistance, moveDistance))
		local moveNearCallFunc = cc.CallFunc:create(function()
			local scaleAction = cc.ScaleTo:create(0.7, 5)
			local fadeAction = cc.FadeTo:create(0.7, 0)
			local action = cc.Spawn:create(scaleAction, fadeAction)
			point:runAction(action)
		end)
		local sequenceAction = cc.Sequence:create(moveNearAction,moveNearCallFunc, moveFarAction, moveFarCallFunc)
		finger:runAction(cc.Repeat:create(sequenceAction, 2))
		self.m_guideTimes = self.m_guideTimes + 1
		if self.m_dealerClicked and self.m_giftClicked then
			self:stopGuideAnim()
			self:clearGuideNode()
			return
		end
	end, self.m_guideInterval, 1)
	table.insert(self.m_schedules, self.m_guideSchedule)
end

function TutorialScene:stopGuideAnim()
	self.m_guideSchedule:cancel()
	if self.m_guideNode and self.m_guideNode:getParent() then
		local finger = self.m_guideNode:getChildByName("guideFinger")
		local point = self.m_guideNode:getChildByName("guidePoint")
		finger:stopAllActions()
		point:stopAllActions()
		self.m_guideNode:removeFromParent(false)
	end
end
function TutorialScene:resetGuideAnim()
	self.m_guideInterval = 4
	self:stopGuideAnim()
	self:guideAnim()
end

-- 屏蔽物理返回键
function TutorialScene:onEventBack()
    return
end
return TutorialScene;