--[[--ldoc desc
@module SlotMachine
@author JanRoid

Date  201-12-25
]]

local filePath = "creator/slot/run.png"
local abs = math.abs
local floor = math.floor

local schedule = cc.Director:getInstance():getScheduler();
local SlotRunner = require("SlotRunner")
local SlotHelp = require("SlotHelp")
local SlotNotify = require("SlotNotify")

local intervalTime = 0.2  -- 老虎机滚动间隔时间
local slotTransTime = 0.5 -- 老虎机显示动画时间
local runSpeed = 200 -- 老虎机滚动速度
local rouckerSpeed = 400 -- 摇杆回弹速度
local maxDis = -140  -- 老虎机滑杆最大滑动位移
local minRunTime = 2 -- 老虎机最少滚动时间

local pokerPath = "creator/slot/poker/%s%s.png"

-- 老虎机item坐标
local pokerPos = {
	{card = "creator/slot/poker/310.png", x = 2, y =0},
	{card = "creator/slot/poker/311.png", x = 65, y =0},
	{card = "creator/slot/poker/312.png", x = 129, y =0},
	{card = "creator/slot/poker/313.png", x = 193, y =0},
	{card = "creator/slot/poker/314.png", x = 257, y =0}
}

local ViewBase = cc.load("mvc").ViewBase;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SlotMachine = class("SlotMachine",ViewBase);
BehaviorExtend(SlotMachine);

-- 配置事件监听函数
SlotMachine.s_eventFuncMap = {
	[g_SceneEvent.SLOT_SHOW_LOTTERY] = "showLottery";
	[g_SceneEvent.SLOT_SHOW_LUCKY] = "showLucky";
	[g_SceneEvent.SLOT_SHOW_TIPS] = "showTips";
	[g_SceneEvent.SLOT_PLAY_ANIM] = "runSlotAnim";
	[g_SceneEvent.SLOT_PLAY_FAIL] = "playSlotFail";
}

function SlotMachine:ctor()
	ViewBase.ctor(self);
	self:setLocalZOrder(KZOrder.Scene + 10)
	self:bindCtr(require("SlotCtr"))
	self:init()
end

function SlotMachine:init()
	self.m_root,self.m_animManager = self:loadLayout("creator/slot/layout_slot.ccreator");
	self:addChild(self.m_root)
	self:addChild(self.m_animManager)

	self:initScene()
	self:initString()

	self.m_helpView = SlotHelp:create()
	self:addChild(self.m_helpView)
end

function SlotMachine:clearAll( )
	Log.d("SlotMachine:clearAll")
	self:clearTurnSchedule()
	self:clearEndSchedule()

	if self.m_autoSchedule then
		schedule:unscheduleScriptEntry(self.m_autoSchedule)
		self.m_autoSchedule = nil
	end

	if self.m_delaySchedule then
		g_Schedule:cancel(self.m_delaySchedule)
		self.m_delaySchedule = nil
	end

	if self.m_winSchedule then
		g_Schedule:cancel(self.m_winSchedule)
		self.m_winSchedule = nil
	end

	if self.m_guideSchedulers then
		for k, v in pairs(self.m_guideSchedulers) do
			g_Schedule:cancel(v)
		end
		self.m_guideSchedulers = {}
	end

	for k,v in ipairs(self.m_turntableMap) do
		self.m_turntableMap[k]:reset()
	end
end

function SlotMachine:clearEndSchedule( )
	if self.m_schedule then
		schedule:unscheduleScriptEntry(self.m_schedule)
		self.m_schedule = nil
	end
end

function SlotMachine:initScene()
	self.m_btnRoucker = self:seekNodeByName("img_ball")
	self.m_rckHand = self:seekNodeByName("img_rocker")
	self.m_btnRuleMax = self:seekNodeByName("btn_rule2")
	self.m_btnRule = self:seekNodeByName("btn_rule")
	self.m_btnTag = self:seekNodeByName("btn_show")
	self.m_lyPoker = self:seekNodeByName("ly_poker")
	self.m_tgAuto = self:seekNodeByName("toggle_auto")
	self.m_txAuto = self:seekNodeByName("tx_auto")
	self.m_btnAuto = self:seekNodeByName("btn_auto")
	self.m_tgAmount = self:seekNodeByName("toggle_amount")
	self.m_background = self:seekNodeByName("img_bg")
	self.m_txMoney = self:seekNodeByName("tx_money")
	self.m_winBg = self:seekNodeByName("img_money")
	self.m_txLv1 = self:seekNodeByName("tx_lv1")
	self.m_txLv2 = self:seekNodeByName("tx_lv2")
	self.m_txLv3 = self:seekNodeByName("tx_lv3")
	self.m_txBet = self:seekNodeByName("tx_bet")
	self.m_viewGuide = self:seekNodeByName("view_guide")
	self.m_guideMap = {}
	self.m_guideMap[1] = self:seekNodeByName("arrow1")
	self.m_guideMap[2] = self:seekNodeByName("arrow2")
	self.m_guideMap[3] = self:seekNodeByName("arrow3")

	self.m_txLv1:enableOutline(cc.c4b(139,36,4,255))
	self.m_txLv2:enableOutline(cc.c4b(139,36,4,255))
	self.m_txLv3:enableOutline(cc.c4b(139,36,4,255))

	-- 创建裁剪区域
	local size = self.m_lyPoker:getContentSize()
	local stencil = cc.Sprite:create("creator/slot/clip_stencil.png")
	stencil:setAnchorPoint(0,0)
	stencil:setPosition(0,0)
	self.m_clipsNode = cc.ClippingNode:create(stencil)
	self.m_clipsNode:setAlphaThreshold(0)
	self.m_clipsNode:setInverted(false)
	self.m_clipsNode:setAnchorPoint(0,0)
	self.m_clipsNode:setPosition(0,0)
	self.m_lyPoker:add(self.m_clipsNode)

	self.m_tgAuto:setSelected(false) -- 默认不自动玩

	self.m_btnRuleMax:addClickEventListener(function() self:onRuleClick() end)
	self.m_btnRule:addClickEventListener(function() self:onRuleClick() end)
	self.m_btnTag:addClickEventListener(function() self:onTagClick() end)
	self.m_tgAuto:addEventListener(function(toggle, selected)
		self:onAutoPlayClick(selected == 0)
	end)
	self.m_tgAmount:addEventListener(function(toggle,index,selected)
		g_SoundManager:playEffect(g_SoundMap.effect.SlotBet)
		self:onBetChanged(index+1) -- 因为index时从0开始的
	end)
	self.m_btnAuto:addClickEventListener(function()
		local checked = self.m_tgAuto:isSelected()
		self.m_tgAuto:setSelected(not checked)
		self:onAutoPlayClick(not checked)
	end)


	self:initRunner()
	self:initRocker()

	-- 老虎机是否正在运行
	self.m_isRunning = false
	-- 是否在滑动老虎机
	self.m_isSlideing = false
	-- 是否自动玩
	self.m_isAutoRuning = false
	-- 老虎机是否显示状态
	self.m_isShow = false
	-- 老虎机滚动事件，最少滚动2s
	self.m_runningTime = 0
	-- 下注额度
	self.m_betMoney = 0
	self.m_betMoneyMap = {}
	-- 赢的钱
	self.m_winMoney = 0

	self:initBetMoney()

end

--[[
    @desc: 初始化下注额度
    @return:
]]
function SlotMachine:initBetMoney()
	local smallBlind = g_RoomInfo:getSmallBlind()
	local maxBet = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "maxBet")
	local multiBet = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "multiBet")
	local roomType = g_RoomInfo:getRoomType()

	if (smallBlind * 4 * multiBet > maxBet) 
		or roomType == g_RoomInfo.ROOM_TYPE_KNOCKOUT then -- 淘汰赛
		self.m_betMoneyMap[1] = (maxBet / 4)
		self.m_betMoneyMap[2] = (maxBet / 2)
		self.m_betMoneyMap[3] = (maxBet)
	else
		self.m_betMoneyMap[1] = (smallBlind * multiBet)
		self.m_betMoneyMap[2] = (smallBlind * 2 * multiBet)
		self.m_betMoneyMap[3] = (smallBlind * 4 * multiBet)
	end


	local config = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "betConfig")
	if config and next(config) ~= nil then
		for k,v in ipairs(config) do
			local sb = tonumber(v.sb) or 0
			local mb = tonumber(v.mb) or 0

			if smallBlind <= mb and sb < smallBlind then
				self.m_betMoneyMap[1] = tonumber(v.e) or self.m_betMoneyMap[1]
				self.m_betMoneyMap[2] = tonumber(v.f) or self.m_betMoneyMap[2]
				self.m_betMoneyMap[3] = tonumber(v.g) or self.m_betMoneyMap[3]

				break
			end
		end
	end

	self.m_txLv1:setString(g_MoneyUtil.formatMoney(self.m_betMoneyMap[1]))
	self.m_txLv2:setString(g_MoneyUtil.formatMoney(self.m_betMoneyMap[2]))
	self.m_txLv3:setString(g_MoneyUtil.formatMoney(self.m_betMoneyMap[3]))
	self.m_betMoney = self.m_betMoneyMap[1]
	g_Model:setProperty(g_ModelCmd.DATA_SLOT, "betMoney",self.m_betMoney)
end

-- 初始化老虎机滚动item
function SlotMachine:initRunner( )
	self.m_turntableMap = {}
	self.m_pokerMap = {}
	for i = 1, 5 do
		local img = SlotRunner:create()	
		img:setPosition(pokerPos[i].x, pokerPos[i].y)
		img:setVisible(false)
		self.m_clipsNode:add(img)
		self.m_turntableMap[i] = img

		local poker = cc.Sprite:create(pokerPos[i].card)
		poker:setAnchorPoint(0,0)
		poker:setPosition(pokerPos[i].x, pokerPos[i].y)
		self.m_clipsNode:add(poker)
		self.m_pokerMap[i] = poker
	end
	self.m_pokerHeight = self.m_pokerMap[1]:getContentSize().height
end

function SlotMachine:initString()
	self.m_txAuto:setString(GameString.get("str_slot_auto_play"))
end

function SlotMachine:showLucky()
	local tx = ""
	local luckyPoker = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "luckPoker") or {}
	for i = 1, #luckyPoker do
		local ch = luckyPoker[i];
		if(ch == "a") then
			tx = tx .. "10"
		elseif(ch == "b") then
			tx = tx .. "J"
		elseif(ch == "c") then
			tx = tx .. "Q"
		elseif(ch == "d") then
			tx = tx .. "K"
		elseif(ch == "e") then
			tx = tx .. "A"
		else
			tx = tx .. ch
		end

		if (i < #luckyPoker) then
			tx = tx .. ", "
		end
	end

	self.m_txMoney:setString(string.format(GameString.get("str_slot_lucky_card"), tx))
	self.m_winBg:setTexture("creator/slot/normal.png")
end

-- 摇杆动画逻辑
function SlotMachine:initRocker( )
	self.m_handPosY = self.m_rckHand:getPositionY()
	self.m_handSize = self.m_rckHand:getContentSize()

	local startPosY = self.m_btnRoucker:getPositionY() 
	
	local posY = 0
	local play = false  --摇杆需要移动超过1/2区域才算启动成功 

	local touchBegan = function(touch, event)
		Log.d("SlotMachine:initRocker -- touchBegan")
		local pt = self.m_btnRoucker:convertTouchToNodeSpace(touch)
		local rc = cc.rect(0,0, self.m_btnRoucker:getContentSize().width, self.m_btnRoucker:getContentSize().height)
		if cc.rectContainsPoint(rc,pt) 
			and not self.m_isRunning 
			and not self.m_isSlideing 
			and not self.m_isAutoRuning then 

			posY = touch:getLocation().y
			self.m_isHandFlipped = false  -- 当前是否镜像处理中
			self.m_isSlideing = true -- 防止多次触发

			return true
		end
		play = false
		return false
	end

	local touchMove = function(touch,event)
		local subY = touch:getLocation().y - posY

		if subY > 0 then  -- 限制滑动范围
			subY = 0
		elseif subY < maxDis then
			subY = maxDis
		end

		if math.abs(subY) > math.abs(maxDis/2) then
			play = true
		end

		self:slotHandAnim(startPosY, subY)
	end

	local touchEnd = function(touch, event)
		self.m_isSlideing = false
		Log.d("SlotMachine:initRocker -- touchEnd")
		if self.m_schedule then
			Log.e("SlotMachine:initRocker -- 多次调用touchEnd错误！ ")
			return
		end


		local subY = touch:getLocation().y - posY
		if subY > 0 then -- 限制滑动范围
			subY = 0
		elseif subY < maxDis then
			subY = maxDis
		end

		local sy = subY
		self.m_schedule = schedule:scheduleScriptFunc(function(dt) 
			sy = sy + rouckerSpeed * dt  -- 回弹事件0.5s
			if sy > 0 then
				sy = 0
			end
			self:slotHandAnim(startPosY, sy)

			if sy == 0 then
				self:clearEndSchedule()
			end

		end, 1/60, false)

		if play then
			g_SoundManager:playEffect(g_SoundMap.effect.SlotPull)
			self.m_isRunning = true
			self:playSlot()
		end
	end
	
	local touchListen = cc.EventListenerTouchOneByOne:create()
	touchListen:registerScriptHandler(touchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	touchListen:registerScriptHandler(touchMove, cc.Handler.EVENT_TOUCH_MOVED)
	touchListen:registerScriptHandler(touchEnd, cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(touchListen, self.m_btnRoucker)

end

--[[
    @desc: 老虎机自动玩逻辑
    @return:
]]
function SlotMachine:autoPlay()
	Log.d("SlotMachine:autoPlay")
	if not self.m_isAutoRuning or self.m_isRunning then
		self.m_tgAmount:setEnabled(true)
		return
	end

	if self.m_autoSchedule then
		schedule:unscheduleScriptEntry(self.m_autoSchedule)
		self.m_autoSchedule = nil
	end

	g_SoundManager:playEffect(g_SoundMap.effect.SlotAutoBet)

	self.m_tgAmount:setEnabled(false)
	self.m_isRunning = true
	local startPosY = self.m_btnRoucker:getPositionY() 
	local subY = 0
	local dis = -rouckerSpeed
	-- 自动摇杆动画
	self.m_autoSchedule = schedule:scheduleScriptFunc(function(dt) 
		subY = subY + dis * dt
		if subY > 0 then
			subY = 0
			self:slotHandAnim(startPosY, subY)
			if self.m_autoSchedule then
				schedule:unscheduleScriptEntry(self.m_autoSchedule)
				self.m_autoSchedule = nil
			end
		elseif subY < maxDis then
			subY = maxDis
			dis = rouckerSpeed -- 改变运动方向
			self:slotHandAnim(startPosY, subY)
			self:autoBetAnim()
			self:playSlot()
		else
			self:slotHandAnim(startPosY, subY)
		end
	end, 1/60, false)
end

--[[
    @desc: 计算老虎机摇杆动画
    time:2018-12-26 16:10:49
	--@startPosY: 摇杆按钮初始的Y坐标
	--@subY: 摇杆移动的位移
    @return:
]]
function SlotMachine:slotHandAnim(startPosY, subY)
	local offsetY = 0  -- 摇杆缩放过程中造成的位移偏量
	self.m_btnRoucker:setPositionY(startPosY + subY)

	-- 摇杆偏移量30，scale = 0.5
	if subY < maxDis/2 then  -- 下半段移动
		if not self.m_isHandFlipped then
			-- 镜像处理  
			self.m_rckHand:setFlippedY(true)
			-- 摇杆缩放后，其坐标会受到影响
			local h = self.m_handSize.height/2
			-- 镜像处理后，原点变为原来的顶端，需要换算
			self.m_handPosY = self.m_handPosY - h + 5
			self.m_isHandFlipped = true
		end

		-- 移动的同时进行缩放
		local sc = abs(subY + abs(maxDis/2)) / abs(maxDis/2)
		self.m_rckHand:setContentSize(self.m_handSize.width, self.m_handSize.height * (sc*0.5 + 0.5))
		-- 变换的一瞬间位置偏移
		offsetY = self.m_handSize.height * (sc*0.5)

	else -- 上半段移动
		if self.m_isHandFlipped then
			self.m_rckHand:setFlippedY(false)
			local h = self.m_handSize.height/2
			self.m_handPosY = self.m_handPosY + h - 5
			self.m_isHandFlipped = false
		end

		local sc = abs(subY) / abs(maxDis/2)
		self.m_rckHand:setContentSize(self.m_handSize.width, self.m_handSize.height * (1-sc*0.5))

	end

	-- 摇杆总移动距离控制在30，根据比例移动摇杆
	local ppr = abs(subY) / abs(maxDis)
	self.m_rckHand:setPositionY(self.m_handPosY - 30 * ppr - offsetY)
end


local animSpeed = 50     --速度
local isMovePoker = true  -- poker牌是否移动状态

--[[
    @desc: 
    author:{author}
    time:2019-01-02 16:58:13
    --@mtype: 1: 老虎机启动， 2：老虎机结束
    @return:
]]
function SlotMachine:turntableAnim(mtype)
	self:clearTurnSchedule()

	local totalTime = 0
	local index = 0
	self.m_turnSchedule = schedule:scheduleScriptFunc(function(dt) 
		totalTime = totalTime + dt
		self.m_runningTime = self.m_runningTime + dt
		local subTime = index * intervalTime
		if totalTime > subTime then
			index = index + 1
			if mtype == 1 then
				self:slotStart(index)
				self.m_runningTime = 0
			elseif mtype == 2 then
				self:slotStop(index)
			end
		end
			
		end, 1/60, false)
end

--[[
    @desc: 老虎机启动，扑克牌移动
    --@index:
	--@dt: 
    @return:
]]
function SlotMachine:slotStart(index)
	if self.m_turntableMap[index] then
		self.m_turntableMap[index]:setVisible(true)
		self.m_turntableMap[index]:run()
	end

	local action = cc.MoveBy:create(self.m_pokerHeight/runSpeed, cc.p(0, -self.m_pokerHeight))
	local callBack = cc.CallFunc:create(function()
		self.m_pokerMap[index]:setPositionY(80)
		self.m_pokerMap[index]:setVisible(false)
	end)
	local seq = cc.Sequence:create(action, callBack)
	self.m_pokerMap[index]:runAction(seq)

	-- 销毁
	if index == 5 then
		self:clearTurnSchedule()
	end
end

--[[
    @desc: 老虎机显示结果
    author:{author}
    time:2019-01-02 17:00:01
    --@index: 
    @return:
]]
function SlotMachine:slotStop(index)
	self.m_pokerMap[index]:setVisible(true)
	local action = cc.MoveBy:create(self.m_pokerHeight/runSpeed, cc.p(0, -self.m_pokerHeight))
	local callBack = cc.CallFunc:create(function()
		local x,y = self.m_pokerMap[index]:getPosition()
		if self.m_turntableMap[index] then
			self.m_turntableMap[index]:reset()
			self.m_turntableMap[index]:setVisible(false)
		end
	end)
	local seq = cc.Sequence:create(action, callBack)
	self.m_pokerMap[index]:runAction(seq)

	-- 销毁
	if index == 5 then
		self:clearTurnSchedule()
		self:showWin()
	end
end

function SlotMachine:clearTurnSchedule( )
	if self.m_turnSchedule then
		schedule:unscheduleScriptEntry(self.m_turnSchedule)
		self.m_turnSchedule = nil
	end
end

--[[
    @desc: 显示赢取奖励
    --@money: 
    @return:
]]
function SlotMachine:showWin()
	self.m_tgAmount:setEnabled(true)
	if self.m_winMoney > 0 then
		self:showTips(g_ClientConfig.SLOT_MSG_TYPE.SLOT_WIN_MSG)
		self.m_txMoney:setString(string.format(GameString.get("str_slot_win"), g_MoneyUtil.formatMoney(self.m_winMoney)))
		self:winAnim()
	elseif self.m_winMoney < 0 then
		if self.m_winMoney == -1 then -- 网络错误
			self.m_txMoney:setString(GameString.get("str_slot_fail4"))
		end
		self:cancelAuto()
	elseif self.m_winMoney == 0 then
		-- 如果不是自动玩，且未中奖，不需要等待时间，可以马上滑动开始下一把
		if not self.m_isAutoRuning then 
			self.m_isRunning = false
			return
		end
	end
	self.m_winSchedule = g_Schedule:schedulerOnce(function()
		self.m_isRunning = false
		self:winAnim(true)
		self:autoPlay()
		self.m_winSchedule = nil
		
	end, 2)
	
end

--[[
    @desc: 显示头奖
    @return:
]]
function SlotMachine:showJackpot()
	local jackPot = self.m_betMoney * 10000
	self.m_txMoney:setString(string.format(GameString.get("str_slot_prize"),jackPot))
	self.m_winBg:setTexture("creator/slot/normal.png")
end

--[[
    @desc: 老虎机显示中奖结果
    @return:
]]
function SlotMachine:showLottery(prizeMap,winMoney)
	Log.d("SlotMachine:showLottery - ",self.m_isRunning)
	if not self.m_isRunning then
		return
	end
	
	self.m_winMoney = winMoney

	if self.m_runningTime < minRunTime then
		local delay = minRunTime - self.m_runningTime
		self.m_delaySchedule = g_Schedule:schedulerOnce(function()
			self:initPokers(prizeMap)
			self:turntableAnim(2)
			self.m_delaySchedule = nil
		end, delay)
	else
		self:initPokers(prizeMap)
		self:turntableAnim(2)
	end
	
end

function SlotMachine:initPokers(prizeMap)
	for i = 1, 5 do
		self.m_pokerMap[i]:setTexture(string.format(pokerPath,prizeMap[i].type,prizeMap[i].value))
		Log.d("SlotMachine:initPokers -- i = ", "i",", img = ",string.format(pokerPath,prizeMap[i].type,prizeMap[i].value))
	end
end

--[[
    @desc: 老虎机显示&隐藏动画
    @return:
]] 
function SlotMachine:showAnim()
	self:showGuideAnim()
	self.m_btnTag:setTouchEnabled(false)
	local w = self.m_background:getContentSize().width
	local pos = nil
	if self.m_isShow then
		self.m_isShow = false
		pos = cc.p(w + 15, 0)
	else
		self.m_isShow = true
		pos = cc.p(-w - 15, 0)
	end
	local action = cc.MoveBy:create(slotTransTime, pos)
	local callBack = cc.CallFunc:create(function()
		self.m_btnTag:setTouchEnabled(true)
	end)
	local seq = cc.Sequence:create(action, callBack)
	self.m_background:runAction(seq)
end

-- 扣钱动画
function SlotMachine:autoBetAnim()
	if not self.m_isShow then
		self.m_txBet:setString("-"..g_MoneyUtil.formatMoney(self.m_betMoney))
		self.m_txBet:setVisible(true)
		self.m_animManager:playAnimationClip(self.m_txBet,"betAnim",function()
			if self.m_txBet then
				self.m_txBet:setVisible(false)
			end
		end)
	end
end

--[[
    @desc: 指引动画
    @return:
]]
function SlotMachine:showGuideAnim()
	local count = g_DictUtils.getInt(g_UserDefaultCMD.GUIDE_SLOT,0)
	if count > 0 then -- 只第一次显示指引
		return
	end

	self.m_guideRuning = true
	self.m_viewGuide:setVisible(true)
	local delay = 0.5
	local totalTime = 1.5 -- 动画事件
	self.m_guideSchedulers = {}

	for i = 1, 3 do
		local time = (i-1)*delay
		local x,y = self.m_guideMap[i]:getPosition()
		if time > 0 then
			self.m_guideSchedulers[i] = g_Schedule:schedulerOnce(function()
				local moveBy = cc.MoveTo:create(totalTime,cc.p(x,y-80))
				local scaleBy = cc.ScaleTo:create(totalTime,1)
				local fadeto = cc.FadeTo:create(totalTime,255)

				local callBack = cc.CallFunc:create(function()
					self.m_guideMap[i]:setPosition(x,y)
					self.m_guideMap[i]:setScale(0.7)
					self.m_guideMap[i]:setOpacity(0)
				end)

				local spawn = cc.Spawn:create(moveBy,scaleBy,fadeto)
				local seq = cc.Sequence:create(spawn, callBack) 
				local delayAc = cc.DelayTime:create(time)
				local action = cc.RepeatForever:create(seq)
				self.m_guideMap[i]:runAction(action)
				self.m_guideSchedulers[i] = nil
			end, time)
		else
			local moveBy = cc.MoveTo:create(totalTime,cc.p(x,y-80))
			local scaleBy = cc.ScaleTo:create(totalTime,1)
			local fadeto = cc.FadeTo:create(totalTime,255)

			local callBack = cc.CallFunc:create(function()
				self.m_guideMap[i]:setPosition(x,y)
				self.m_guideMap[i]:setScale(0.7)
				self.m_guideMap[i]:setOpacity(0)
			end)

			local spawn = cc.Spawn:create(moveBy,scaleBy,fadeto)
			local seq = cc.Sequence:create(spawn, callBack) 
			local action = cc.RepeatForever:create(seq)
			self.m_guideMap[i]:runAction(action)
		end	
	end

	g_DictUtils.setInt(g_UserDefaultCMD.GUIDE_SLOT,count + 1)
end

function SlotMachine:clearGuideAnim()
	self.m_viewGuide:setVisible(false)
	if self.m_guideRuning then
		for k,v in ipairs(self.m_guideMap) do
			v:stopAllActions()
		end
	end
end

--[[
    @desc: 小摇杆动画
    @return:
]]
function SlotMachine:playSlot()
	self:clearGuideAnim()
	self:showJackpot()
	
	if not self:checkPlay() then
		self:showTips(g_ClientConfig.SLOT_MSG_TYPE.SLOT_LESS_CHIPS)
		self.m_isRunning = false
		if self.m_isAutoRuning then
			self:cancelAuto()
		end

		return 
	end

	self.m_tgAmount:setEnabled(false)
	self:doLogic(g_SceneEvent.SLOT_PLAY, self.m_betMoney)
end

function SlotMachine:checkPlay()
	local roomType = g_RoomInfo:getRoomType()
	local user = g_RoomInfo:getUserSelf()
	local money = g_AccountInfo:getMoney() -- 玩家站起状态

	if user and roomType ~= g_RoomInfo.ROOM_TYPE_KNOCKOUT then -- 玩家坐下状态
		money = user.totalChips - user.seatChips
	end

	if money > self.m_betMoney then
		return true
	end

	return false
end

function SlotMachine:playSlotFail( )
	self.m_isRunning = false
	self:cancelAuto()
end

function SlotMachine:runSlotAnim( )
	-- 动画
	self.m_animManager:playAnimationClip(self.m_background,"startAnim")
	self:turntableAnim(1)
end

function SlotMachine:winAnim(isStop)
	if isStop then
		self.m_animManager:stopAnimationClip(self.m_winBg, "winAnim")
		self.m_winBg:setTexture("creator/slot/normal.png")
	else
		g_SoundManager:playEffect(g_SoundMap.effect.SlotWin)
		self.m_animManager:playAnimationClip(self.m_winBg, "winAnim")
	end
end

--[[
    @desc: 显示消息提示，详见ClientConfig.SLOT_MSG_TYPE
    --@msgType:1:中奖消息，2：重连消息，3： 初始化失败消息, 4：钱不够，5、网络中断
    @return:
]]
function SlotMachine:showTips(msgType)
	Log.d("SlotMachine:showTips --- ",msgType)
	if msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECONNECT_MSG
		or msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_FAIL_MSG
		or msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_CONNECT_FAIL
		or msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECON_SUCC then

		if not self.m_isAutoRuning and not self.m_isShow then
			-- 老虎机未启用时，重连信息不需要提示，
			-- 悄悄的进村，打枪的不要
			Log.d("SlotMachine:showTips --- 1")
			return
		end
	end

	local msg = ""
	if msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_WIN_MSG then
		local check = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "callWins")
		Log.d("SlotMachine:showTips --- 2",check,self.m_winMoney)
		if check == true then
			return
		end

		if self.m_winMoney > 0 then
			msg = string.format(GameString.get("str_slot_win_money"),self.m_winMoney)
		end
	elseif msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECONNECT_MSG then
		msg = GameString.get("str_slot_reconnect")
	elseif msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_FAIL_MSG then
		msg = GameString.get("str_slot_fail2")
	elseif msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_LESS_CHIPS then
		msg = GameString.get("str_slot_fail1")
	elseif msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_CONNECT_FAIL then
		msg = GameString.get("str_slot_fail3")
	elseif msgType == g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECON_SUCC then
		msg = GameString.get("str_slot_success")
	end

	if string.len(msg) > 0 then
		Log.d("SlotMachine:showTips --- msg = ",msg)
		SlotNotify.getInstance():setText(msg):show()
	end

end

-- 取消老虎机自动玩状态
function SlotMachine:cancelAuto()
	self.m_tgAuto:setSelected(false)
	self:onAutoPlayClick(false)
end

--------------------------------------- click func -----------------------------------------
-- 自动玩
function SlotMachine:onAutoPlayClick(auto)
	if auto and not self:checkPlay() then
		self:showTips(g_ClientConfig.SLOT_MSG_TYPE.SLOT_LESS_CHIPS)
		self.m_tgAuto:setSelected(false)
		return
	end

	self.m_isAutoRuning = auto
	g_Model:setProperty(g_ModelCmd.DATA_SLOT, "autoPlay",auto)
	self:autoPlay()
end

function SlotMachine:onBetChanged(index)
	self.m_betMoney = self.m_betMoneyMap[index]	
	g_Model:setProperty(g_ModelCmd.DATA_SLOT, "betMoney",self.m_betMoney)
end

function SlotMachine:onRuleClick()
	self.m_helpView:show()
end

function SlotMachine:onTagClick()
	self:showAnim()
end

function SlotMachine:onEnter( )
	ViewBase.onEnter(self)
	self:registerEvent()

	local map = {
		g_SoundMap.effect.SlotBet,
		g_SoundMap.effect.SlotPull,
		g_SoundMap.effect.SlotAutoBet,
		g_SoundMap.effect.SlotWin
	}
	g_SoundManager:preloadEffects(map)

end

function SlotMachine:onExit( )
	ViewBase.onExit(self)
	self:unRegisterEvent()
end


function SlotMachine:onCleanup()
	self:clearAll()
	ViewBase.onCleanup(self)
end

function SlotMachine:onBackEvent()
	if self.m_helpView and self.m_helpView:isVisible() then
		self.m_helpView:hidden()
		return true
	end

	if self.m_isShow then
		self:showAnim()

		return true
	end
end


return SlotMachine