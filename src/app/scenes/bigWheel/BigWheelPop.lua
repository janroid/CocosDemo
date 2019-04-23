--[[--ldoc desc
@module BigWheelPop
@author RyanXu

Date   2018-12-12
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BigWheelPop = class("BigWheelPop",PopupBase);
BehaviorExtend(BigWheelPop);

local PropItem = require('PropItem.lua')

-- 配置事件监听函数
BigWheelPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

BigWheelPop.blockBackBtn = true

function BigWheelPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("BigWheelCtr"))
	self:initUI()
	self:initString()
	self:initBtnClickEvent()

	local map = {
		g_SoundMap.effect.ButtonClick,
		g_SoundMap.effect.SlotWin
	}
	g_SoundManager:preloadEffects(map)

	self.m_retryTimes = 3
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.BIG_WHEEL_GET_PLAY_TIMES)
	g_HttpManager:doPost(params,self, self.onGetPlayTimesResponse, self.getTimesError)
end

function BigWheelPop:onCleanup()
	PopupBase.onCleanup(self)
	if self.m_wheelRunEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_wheelRunEntry)
	end
end

function BigWheelPop:show()
	PopupBase.show(self)
end

function BigWheelPop:hidden()
	PopupBase.hidden(self)
end

function BigWheelPop:initUI()
	self.m_animManager = self:loadLayout("creator/bigWheel/bigWheel.ccreator");

	self:addChild(self.m_animManager)

	self.m_circleBg = g_NodeUtils:seekNodeByName(self, 'bg_circle')
	self.m_btnStart = g_NodeUtils:seekNodeByName(self, 'start_btn') 
	self.m_imgBegin = g_NodeUtils:seekNodeByName(self, 'begin_draw')
	self.m_txAgainDraw = g_NodeUtils:seekNodeByName(self, 'tx_again_draw')
	self.m_txSubTitle = g_NodeUtils:seekNodeByName(self, 'tx_subtitle')
	self.m_txRuleTitle = g_NodeUtils:seekNodeByName(self, 'tx_rule_title')
	self.m_txRuleDesc = g_NodeUtils:seekNodeByName(self, 'tx_rule_desc')
	self.m_txRemainDraw = g_NodeUtils:seekNodeByName(self, 'tx_remain_draw')
	self.m_txRemainDrawNum = g_NodeUtils:seekNodeByName(self, 'tx_remain_draw_num')
	self.m_txLogDesc = g_NodeUtils:seekNodeByName(self, 'tx_log_title')
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')
	self.m_btnHelp = g_NodeUtils:seekNodeByName(self, "btn_help")

	self.m_viewLottery = g_NodeUtils:seekNodeByName(self, 'view_log')
	self.m_viewRule = g_NodeUtils:seekNodeByName(self, 'view_rule')
	self.m_viewLotteryLog = g_NodeUtils:seekNodeByName(self,'view_log_item')
	self.m_selectFrame = g_NodeUtils:seekNodeByName(self,'select_frame')
	self.m_circleFrame = g_NodeUtils:seekNodeByName(self,'circle_frame')

	self.m_imgTitle = g_NodeUtils:seekNodeByName(self,'title')

	self.m_imgBegin:setTexture(switchFilePath("bigWheel/begin_draw.png"))
	self.m_imgTitle:setTexture(switchFilePath("bigWheel/title.png"))

	local size = self.m_circleBg:getContentSize()
	self.m_itemArray = {}
	for i=1, 12 do
		local item = PropItem.new(i)
		item:setPosition(cc.p(size.width/2,size.height/2))
		self.m_circleBg:addChild(item)
		self.m_itemArray[i] = item
	end

end

function BigWheelPop:initString()
	self.m_txSubTitle:setString(GameString.get('str_bigWheel_subTitle'))
	self.m_txRuleTitle:setString(GameString.get('str_bigWheel_ruleTitle'))
	self.m_txRuleDesc:setString(GameString.get('str_bigWheel_ruleDesc'))
	self.m_txRemainDraw:setString(GameString.get('str_bigWheel_remain_draw'))
	self.m_txLogDesc:setString(GameString.get('str_bigWheel_logTitle'))
	self.m_txRemainDrawNum:setString("")

	self.m_txAgainDraw:setString("")
end

function BigWheelPop:initBtnClickEvent()
	self.m_btnStart:addClickEventListener(
		function(sender)
			g_SoundManager:playEffect(g_SoundMap.effect.ButtonClick)
			self:onBtnStartClick()
		end
	)
	self.m_btnStart:setEnabled(false)
	self.m_btnClose:setOpacity(155)
	self.m_btnClose:addClickEventListener(
		function(sender)
			g_SoundManager:playEffect(g_SoundMap.effect.ButtonClick)
			self:onBtnCloseClick()
		end
	)

	self.m_btnHelp:setOpacity(155)
	self.m_btnHelp:addClickEventListener(
		function(sender)
			g_SoundManager:playEffect(g_SoundMap.effect.ButtonClick)
			self:onBtnHelpClick()
		end
	)

end

function BigWheelPop:onBtnStartClick()
	self.m_btnStart:setEnabled(false)
	self.m_btnClose:setOpacity(155)
	self.m_btnHelp:setOpacity(155)

	if self:isMoneyPlay() then
		g_AlertDialog.getInstance()
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
		:setContent(string.format(GameString.get("str_bigWheel_tips_content"),g_MoneyUtil.formatMoney(self.m_drawMoney)))
		:setTitle(GameString.get("str_bigWheel_tips_title"))
		:setCenterBtnTx(GameString.get("confirm_btn"))
		:setCenterBtnFunc(function()
			self:requireMoneyPlay();
		end)
		:setCloseBtnFunc(function()
			self.m_btnStart:setEnabled(true)
			self.m_btnClose:setOpacity(255)
			self.m_btnHelp:setOpacity(255)
		end)
		:show()
	else
		self:requestPlay()
	end
end

function BigWheelPop:onBtnCloseClick()
	self:hidden()
end

function BigWheelPop:onBtnHelpClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.BIG_WHEEL_HELP_POP)
end

function BigWheelPop:requestPlay()
	self.m_btnStart:setEnabled(false)
	self.m_btnClose:setOpacity(155)
	self.m_btnHelp:setOpacity(155)

	local params = HttpCmd:getMethod(HttpCmd.s_cmds.BIG_WHEEL_PLAY)
	g_HttpManager:doPost(params,self, self.onPlayResponse)
	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, true);
end

function BigWheelPop:onPlayResponse(isSuccess, result)
	self.m_btnStart:setEnabled(true)
	self.m_btnClose:setOpacity(255)
	self.m_btnHelp:setOpacity(255)

	result = tonumber(result) or 0
    if not isSuccess or result == nil then
    	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, false);
       	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
    elseif result == 0 then
    	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, false);
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_bigWheel_no_free_play'))
    	self.m_remainTimes = 0
    	self:updateStartBtn()
    	self:updateRemainTimes()
    else
    	self.m_remainTimes = self.m_remainTimes - 1
    	self:updateStartBtn()
		self:startRunWheel(result)
		self:updateRemainTimes()
    end
end

function BigWheelPop:requireMoneyPlay()
	self.m_btnStart:setEnabled(false)
	self.m_btnClose:setOpacity(155)
	self.m_btnHelp:setOpacity(155)

	local params = HttpCmd:getMethod(HttpCmd.s_cmds.BIG_WHEEL_MONEY_PLAY)
	g_HttpManager:doPost(params,self, self.onMoneyPlayResponse)
	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, true);
end

function BigWheelPop:onMoneyPlayResponse(isSuccess, result)
	self.m_btnStart:setEnabled(true)
	self.m_btnClose:setOpacity(255)
	self.m_btnHelp:setOpacity(255)

	result = tonumber(result) or 0
    if not isSuccess or result == nil then
       	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
       	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, false);
    elseif result == -2 then
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_bigWheel_not_enought_money'))
    	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, false);
    elseif result > 0 then
    	local drawMoney = self.m_drawMoney or 3000
    	g_AccountInfo:setMoney(g_AccountInfo:getMoney() - drawMoney)
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_bigWheel_buy_success'))
    	self:startRunWheel(result)
    end
end

function BigWheelPop:startRunWheel(targetItemId)

	if self.m_wheelRunEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_wheelRunEntry)
	end

	self.m_btnStart:setEnabled(false)
	self.m_btnClose:setEnabled(false)
	self.m_btnClose:setOpacity(155)
	self.m_btnHelp:setEnabled(false)
	self.m_btnHelp:setOpacity(155)
	self.m_lastRotation = self.m_circleBg:getRotation() % 360
	self.m_circleBg:setRotation(self.m_lastRotation)

	local targetRotation
	for i=1, #self.m_itemArray do
		local item = self.m_itemArray[i]
		if item:getWinId() == targetItemId then
			targetRotation = 360 - item:getAngle()
		end
	end
	if targetRotation == nil then
		Log.d('bigWheelPop 中奖id 和 显示 不配')
		return  
	end

	self.m_wheelRunEntry = nil
	self.m_totalRotation = 360*7 + targetRotation
	self.m_totalDuration = 7.0
	self.m_duration = 0

	self.m_animManager:stopAnimationClip(self.m_circleFrame,"circleTwinkleClip")
	self.m_animManager:stopAnimationClip(self.m_selectFrame,"selectTwinkleClip")
	self.m_selectFrame:setVisible(false)
	local function wheelRun(dt)
		self.m_duration = self.m_duration + dt
		local currentPercent = self.m_duration / self.m_totalDuration

 	     if currentPercent < 0.5 then
 	     	currentPercent = 0.5*math.pow(2, 10*(2*currentPercent-1))
 	     else
 	     	currentPercent = (0.5*math.pow(2, 10*(2*(0-(currentPercent-1)) - 1)))*-1 + 1
 	     end
 
		local currentRotation = self.m_lastRotation + (self.m_totalRotation - self.m_lastRotation) * currentPercent 
		self.m_circleBg:setRotation(currentRotation)

		if self.m_duration > self.m_totalDuration then
			self.m_circleBg:setRotation(self.m_totalRotation)
			self:getTheLottery(targetItemId)
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_wheelRunEntry)
			self.m_wheelRunEntry = nil
			g_SoundManager:playEffect(g_SoundMap.effect.SlotWin)
		end
	end
	self.m_wheelRunEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(wheelRun, 0.02, false)
end

function BigWheelPop:getTimesError()
    if self.m_retryTimes > 0 then
		local params = HttpCmd:getMethod(HttpCmd.s_cmds.BIG_WHEEL_GET_PLAY_TIMES)
	    g_HttpManager.post(params, self, self.getTimesCallBack, self.getTimesError);
        self.m_retryTimes = self.m_retryTimes - 1;
    else
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
    	self.m_btnStart:setEnabled(false)
		self.m_btnClose:setOpacity(155)
		self.m_btnHelp:setOpacity(155)
    end
end

function BigWheelPop:onGetPlayTimesResponse(isSuccess, result)
	Log.d('onGetPlayTimesResponse-----------------',result)
    if isSuccess == true and g_TableLib.isTable(result) then
    	self.m_retryTimes = 3
    	self.m_btnStart:setEnabled(true)
		self.m_btnClose:setOpacity(255)
		self.m_btnHelp:setOpacity(255)
    	self.m_remainTimes = result.times or 0
    	self.m_drawMoney = result.money or 3000
    	self.m_txAgainDraw:setString(g_MoneyUtil.formatMoney(self.m_drawMoney) .. '\n' .. GameString.get('str_bigWheel_againDraw'))
		self:updateStartBtn()
		self:updateRemainTimes()
		g_AccountManager:getInstance():requestUserInfo()
    end
end

function BigWheelPop:getTheLottery(targetItemId)

	g_Model:setData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED, false);

	self.m_btnStart:setEnabled(true)
	self.m_btnClose:setEnabled(true)
	self.m_btnClose:setOpacity(255)
	self.m_btnHelp:setEnabled(true)
	self.m_btnHelp:setOpacity(255)

	local log = self:createLotteryLogItem(targetItemId)

	Log.d('getTheLottery------',targetItemId)
	g_AccountManager:requestUserInfo()
	if targetItemId == 12 then -- 抽中再来一次
		self.m_remainTimes = self.m_remainTimes + 1
		self:updateStartBtn()
		self:updateRemainTimes()
	end

	if log then
		self.m_viewRule:setVisible(false)
		self.m_viewLottery:setVisible(true)
		self.m_viewLottery:addChild(log)

		local viewSize = self.m_viewLottery:getContentSize()
		local viewLogSize = self.m_viewLotteryLog:getContentSize()
		local startPos = cc.p(viewSize.width/2 - 476,viewSize.height/2 +217)
		local endPos, viewPos -- 移动后要重新add到ViewLotteryLog上，便于后续向上移动时做出mask效果
		if self.m_firstLog == nil then
			endPos = cc.p(viewSize.width/2,viewSize.height/2 -60)
			viewPos = cc.p(viewLogSize.width/2,viewLogSize.height/2 + 45)
		else
			endPos = cc.p(viewSize.width/2,viewSize.height/2 -150)
			viewPos = cc.p(viewLogSize.width/2,viewLogSize.height/2 - 45)
		end
		
		log:setPosition(startPos)
		local endCall = cc.CallFunc:create(function(sender)
			sender:removeFromParent()
			self.m_viewLotteryLog:addChild(sender)
			sender:setPosition(viewPos)
			if self.m_firstLog == nil then
				self.m_firstLog = sender
			else
				self.m_secondLog = sender
			end
			self.m_selectFrame:setVisible(false)
		end)
		local moveAction = cc.MoveTo:create(2.0, endPos)	
		local sequenceAction = cc.Sequence:create(moveAction,endCall)
		log:runAction(sequenceAction)

		self.m_selectFrame:setVisible(true)
		self.m_animManager:playAnimationClip(self.m_selectFrame,"selectTwinkleClip")
		self.m_animManager:playAnimationClip(self.m_circleFrame,"circleTwinkleClip")

		if self.m_firstLog and self.m_secondLog then
			local endCall = cc.CallFunc:create(function(sender)
				sender:removeFromParent()
			end)
			local moveAction = cc.MoveTo:create(1.0, cc.p(viewPos.x,viewPos.y+180))	
			local sequenceAction = cc.Sequence:create(moveAction,endCall)
			self.m_firstLog:runAction(sequenceAction)

			local endCall = cc.CallFunc:create(function(sender)
				self.m_firstLog = self.m_secondLog
			end)
			local moveAction = cc.MoveTo:create(1.0, cc.p(viewPos.x,viewPos.y+90))	
			local sequenceAction = cc.Sequence:create(moveAction,endCall)
			self.m_secondLog:runAction(sequenceAction)
		end
	end
end

function BigWheelPop:createLotteryLogItem(targetItemId)
	local imgPath, titleStr, scale 
	for i=1, #self.m_itemArray do
		local item = self.m_itemArray[i]
		if item:getWinId() == targetItemId then
			imgPath =  item:getIconPath()
			titleStr = item:getTitle()
			scale = item:getImgScale()
		end
	end
	if imgPath then
		local logItem = display.newNode()
		local icon =  display.newSprite(imgPath)
		icon:setPosition(cc.p(-40,0))
		icon:setScale(scale)
		logItem:addChild(icon)

		local title = cc.Label:createWithSystemFont(titleStr,"",22);
		title:setPosition(cc.p(10,0))
		title:setAnchorPoint(cc.p(0,0.5))
		title:setAlignment(cc.TEXT_ALIGNMENT_LEFT)
		title:setColor(cc.c3b(255,227,38))
		logItem:addChild(title)

		g_AlarmTips.getInstance():setTextAndShow(string.format(GameString.get('str_bigWheel_tips_reward'),titleStr))

		return logItem
	end
end

function BigWheelPop:updateStartBtn()
	if self:isMoneyPlay() then
		self.m_imgBegin:setVisible(false)
		self.m_txAgainDraw:setVisible(true)
	else
		self.m_imgBegin:setVisible(true)
		self.m_txAgainDraw:setVisible(false)
	end
	self.m_txRemainDrawNum:setString(tostring(self.m_remainTimes))
end

function BigWheelPop:updateRemainTimes()
	-- jf
	g_Model:setData(g_ModelCmd.WHEEL_FREE_REMAIN_TIMES, self.m_remainTimes);
end

function BigWheelPop:isMoneyPlay()
	if self.m_remainTimes <= 0 then
		return true
	else
		return false
	end
end



return BigWheelPop;