--[[--ldoc desc
@module HallScene
@author WuHuang

Date   2018-10-25
]]
local ViewScene = import("framework.scenes").ViewScene;
local NetImageView =  import("app.common.customUI").NetImageView
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap
local StoreConfig = import("app.scenes.store").StoreConfig
local BannerPageView = require("BannerPageView")

local helpType = import('app.scenes.help').ShowType
local ActivityWebInfo = import('app.scenes.activity').ActivityWebInfo

local DailyTaskManager = import("app.scenes.dailyTask").DailyTaskManager;

local HallScene = class("HallScene",ViewScene);
--BehaviorExtend(HallScene);

function HallScene:ctor()
	ViewScene.ctor(self,nil,"HallScene")
	self:bindCtr(require("HallCtr"));
	self:init();
end

function HallScene:onCleanup()
	Log.d("HallScene","HallScene:onCleanup")
	if self.m_bannerPageViewNode then
		self.m_bannerPageViewNode:stopAutoTimer()
		self.m_bannerPageViewNode = nil
	end
	if self.m_rotationEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_rotationEntry)
		self.m_rotationEntry = nil
	end
	if self.m_preLoadTimer then
		g_Schedule:cancel(self.m_preLoadTimer)
		self.m_preLoadTimer =nil
	end
	g_Model:unwatchData(g_ModelCmd.WHEEL_FREE_REMAIN_TIMES, self, self.onFreeRemainTimes)
	g_PopupManager:clearPop(g_PopupConfig.S_POPID.ACTIVITY_WEB_POP)
	ViewScene.onCleanup(self)
end

function HallScene:onEnter()
	ViewScene.onEnter(self)
	Log.d("HallScene","HallScene:onEnter")
	if self.m_bannerPageViewNode then
		self.m_bannerPageViewNode:setPageIndex(1)
		self.m_bannerPageViewNode:resumeAutoTimer()
	end
	if not g_SoundManager:isMusicPlaying() then
		if g_SettingConfig.getBGMSwitch() then
			if g_SoundManager.isMusicPause then
				g_SoundManager:resumeMusic()
			else
				g_SoundManager:playMusic(g_SoundMap.music.BMG, true)
			end
		end
		local percent = g_SettingConfig.getSliderPercent()
		g_SoundManager:setMusicVolume(percent / 100.00)
		g_SoundManager:setEffectsVolume(percent / 100.00)
	end
	self:doLogic(g_SceneEvent.RANK_HALL_GET_MYRANK)
	self:doLogic(g_SceneEvent.RANK_HALL_RANKLIST_REQUEST)
	self:playEnterAni(0)
	self:updateRedPoint()
end

function HallScene:onExit()
	Log.d("HallScene","HallScene:onExit")
	if self.m_bannerPageViewNode then
		self.m_bannerPageViewNode:pauseAutoTimer()
	end
end

function HallScene:init()
	self:initRoot()
	self:initUI()
	-- 向control请求广告图数据
	self:doLogic(g_SceneEvent.HALL_REQUEST_BANNER)
	self:doLogic(g_SceneEvent.Hall_REQUEST_PLAYTIMES)
	self:initListener()
	self.m_preLoadTimer = g_Schedule:schedulerOnce(function()
		self:preLoadAcitvity()
	end,0.5)
	self:initRedPoint()
end

function HallScene:initRoot()
	if not self.m_root then
		self.m_root = self:loadLayout('creator/hall/hallScene.ccreator')
		self:addChild(self.m_root)
	end
end

function HallScene:initUI()
	self.m_shadeBtn      = g_NodeUtils:seekNodeByName(self.m_root, 'shadeBtn')

	self.m_bottomMenu    = g_NodeUtils:seekNodeByName(self.m_root, 'bottomSprite')
	self.m_leftSprite    = g_NodeUtils:seekNodeByName(self.m_root, 'leftSprite')
	self.m_rightSprite   = g_NodeUtils:seekNodeByName(self.m_root, 'rightSprite')

	self.m_mailBtn       = g_NodeUtils:seekNodeByName(self.m_root, 'mailBtn')  
	self.m_relaxationBtn = g_NodeUtils:seekNodeByName(self.m_root, 'relaxationBtn')  
	self.m_acitvityBtn   = g_NodeUtils:seekNodeByName(self.m_root, 'acitvityBtn')  
	self.m_missionBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'missionBtn')  
	self.m_moreBtn       = g_NodeUtils:seekNodeByName(self.m_root, 'moreBtn')  
	self.m_marketBtn     = g_NodeUtils:seekNodeByName(self.m_root, 'marketBtn')  
	self.m_headerBgBtn   = g_NodeUtils:seekNodeByName(self.m_root, 'headerBgBtn')
	self.m_headIconContainer   = g_NodeUtils:seekNodeByName(self.m_root, 'head_icon')
	self.m_backPackBtn   = g_NodeUtils:seekNodeByName(self.m_root, 'backPackBtn')
	self.m_feedbackBtn   = g_NodeUtils:seekNodeByName(self.m_root, 'feedbackBtn')
	self.m_friendBtn     = g_NodeUtils:seekNodeByName(self.m_root, 'friendBtn')
	self.m_courseBtn     = g_NodeUtils:seekNodeByName(self.m_root, 'courseBtn')
	self.m_settingBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'settingBtn')

	self.m_nameLabel     = g_NodeUtils:seekNodeByName(self.m_root, 'nameLabel')
	self.m_chipLabel     = g_NodeUtils:seekNodeByName(self.m_root, 'chipLabel')

	self.m_normalBtn     = g_NodeUtils:seekNodeByName(self.m_root, 'normalBtn')
	self.m_mttBtn        = g_NodeUtils:seekNodeByName(self.m_root, 'mttBtn')
	self.m_quickBtn      = g_NodeUtils:seekNodeByName(self.m_root, 'quickBtn')
	self.m_moreBgSprite  = g_NodeUtils:seekNodeByName(self.m_root, 'moreBgSprite')
	self.m_vipImg		 = g_NodeUtils:seekNodeByName(self.m_root, 'vipImg')
	self.m_btnSwitch      = g_NodeUtils:seekNodeByName(self.m_root, 'swithBtn')
	self.m_btnRank       = g_NodeUtils:seekNodeByName(self.m_root, 'rankBtn')
	self.m_rankView = g_NodeUtils:seekNodeByName(self.m_root, 'rankSprite')
	self.m_bannerView = g_NodeUtils:seekNodeByName(self.m_root, 'bannerSprite')

	self.m_txMailBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_mailBtn')
	self.m_txRelaxationBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_relaxationBtn')
	self.m_txAcitvityBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_acitvityBtn')
	self.m_txMissionBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_missionBtn')
	self.m_txMoreBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_moreBtn')

	self.m_txBackpackBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_backPackBtn')
	self.m_txFeedbackBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_feedbackBtn')
	self.m_txFriendBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_friendBtn')
	self.m_txCourseBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_courseBtn')
	self.m_txSettingBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_settingBtn')
	self.m_txRankBtn    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_rankBtn')
	self.m_quickTextImg    = g_NodeUtils:seekNodeByName(self.m_root, 'quickText')
	self.m_mttTextImg      = g_NodeUtils:seekNodeByName(self.m_root, 'mttText')
	self.m_normalTextImg   = g_NodeUtils:seekNodeByName(self.m_root, 'normalText')
	
	self.m_quickTextImg:setTexture(switchFilePath("hall/quick.png"))
	self.m_mttTextImg:setTexture(switchFilePath("hall/mtt.png"))
	self.m_normalTextImg:setTexture(switchFilePath("hall/normal.png"))
	
	g_NodeUtils:convertTTFToSystemFont(self.m_nameLabel)

	self.m_btnSwitch:setVisible(false)
	BehaviorExtend(self.m_headIconContainer)
	self.m_headIconContainer:bindBehavior(BehaviorMap.HeadIconBehavior)

	self:initString()
	self:setupBtnClickEvent() -- 配置各个按钮点击事件
	self:hideMoreView()
	self:updateUserIcon()	
	local nameSize = self.m_nameLabel:getContentSize()
	local nameWidth  = nameSize.width
	Log.d("Johnson nameWidth ",nameWidth)
	self.m_nameLabel:setString(g_StringLib.limitLength(g_AccountInfo:getNickName(),30,300))
	self.m_chipLabel:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
	self:showVip()
	self:createRankView()
	self:showDiscount()
	self:initGameView()
end

function HallScene:initString()
	self.m_txMailBtn:setString(GameString.get('str_hall_icon_mall'))
	self.m_txRelaxationBtn:setString(GameString.get('str_hall_icon_game'))
	self.m_txAcitvityBtn:setString(GameString.get('str_hall_icon_acitvity'))
	self.m_txMissionBtn:setString(GameString.get('str_hall_icon_mession'))
	self.m_txMoreBtn:setString(GameString.get('str_hall_icon_more'))
	self.m_txBackpackBtn:setString(GameString.get('str_hall_icon_backpack'))
	self.m_txFeedbackBtn:setString(GameString.get('str_hall_icon_feedback'))
	self.m_txFriendBtn:setString(GameString.get('str_hall_icon_friend'))
	self.m_txCourseBtn:setString(GameString.get('str_hall_icon_course'))
	self.m_txSettingBtn:setString(GameString.get('str_hall_icon_setting'))
	self.m_txRankBtn:setString(GameString.get('str_hall_icon_rank'))
end


function HallScene:initRedPoint()
	self.m_missionBtn:addRedPoint()
	self.m_missionBtn:adjustRedPointPos(-1,-12)
end

function HallScene:updateRedPoint()
	if DailyTaskManager.getInstance():hasUnrecieveReward() then
		self.m_missionBtn:showRedPoint(true)
	else
		self.m_missionBtn:hideRedPoint()
	end
end

function HallScene:initListener()
	g_Model:watchData(g_ModelCmd.WHEEL_FREE_REMAIN_TIMES, self, self.onFreeRemainTimes, false)
end

function HallScene:showVip()
	local vip = tonumber(g_AccountInfo:getVip())
	if vip and vip > 0 and vip < 5  then
		self.m_vipImg:setTexture(string.format("creator/common/vip/vip_icon_%d.png", vip))
		self.m_vipImg:setVisible(true)
	else
		self.m_vipImg:setVisible(false)
	end
end

-- 设置按钮点击事件
function HallScene:setupBtnClickEvent()
	local btnsActions = {
		{ btn = self.m_mailBtn,       cmds = self.onMailBtnClick },       -- 邮箱
		{ btn = self.m_relaxationBtn, cmds = self.onRelaxationBtnClick }, -- 
		{ btn = self.m_acitvityBtn,   cmds = self.onAcitvityBtnClick },   -- 活动
		{ btn = self.m_missionBtn,    cmds = self.onMissionBtnClick },    -- 任务
		{ btn = self.m_marketBtn,     cmds = self.onMarketBtnClick },     -- 商城
		{ btn = self.m_normalBtn,     cmds = self.onNormalBtnClick },     -- 普通场
		{ btn = self.m_mttBtn,        cmds = self.onMttBtnClick },        -- MTT
		{ btn = self.m_quickBtn,      cmds = self.onQuickBtnClick },      -- 立即开始
		{ btn = self.m_headerBgBtn,   cmds = self.onUserHeaderBtnClick }, -- 个人头像
		{ btn = self.m_backPackBtn,   cmds = self.onBackPackBtnClick }, -- 背包
		{ btn = self.m_feedbackBtn,   cmds = self.onFeedbackBtnClick }, -- 反馈
		{ btn = self.m_friendBtn,     cmds = self.onFriendBtnClick },   -- 好友
		{ btn = self.m_courseBtn,     cmds = self.onCourseBtnClick },   -- 教程
		{ btn = self.m_settingBtn,    cmds = self.onSettingBtnClick },  -- 设置
		{ btn = self.m_btnSwitch, 	  cmds = self.onSwitchBtnClick},    -- 大厅左侧排行榜、活动banner切换
		{ btn = self.m_btnRank, 	  cmds = self.onRankBtnClick},		-- 更多->排行榜
	}

	for i,value in ipairs(btnsActions) do
		value.btn:addTouchEventListener(function(sender, eventType)
			if (2 == eventType) then -- up
				value.cmds(self)
				self:hideMoreView()
			end
		end)
	end

	-- 
	self.m_shadeBtn:addTouchEventListener(function(sender, eventType)
		if (2 == eventType) then -- up
			self:hideMoreView()
		end
	end)
	
	-- 更多
	self.m_moreBtn:addTouchEventListener(function(sender, eventType)
		if (2 == eventType) then -- up
			self:showMoreView()
		end
	end)

	self.m_moreBgSprite:addTouchEventListener(function(sender, eventType)
	end)
end

-- 点击底部菜单显示更过view
function HallScene:showMoreView()
	local visible = self.m_moreBgSprite:isVisible()
	self.m_moreBgSprite:setVisible(not visible)
	self.m_shadeBtn:setVisible(not visible)

	if self.m_moreBgSprite:isVisible() then
		local function ani1()
			-- 缩放
			return cc.ScaleTo:create(0.05, 1.2, 1.2)
		end

		local function ani2()
			-- 缩放
			return cc.ScaleTo:create(0.05, 1, 1)
		end

		local function delayTime()
			-- 延迟时长
			return cc.DelayTime:create(0.05)
		end

		local delayT = delayTime()
		-- 效果动画
		local scale_up = ani1()
		local scale_down = ani2()

		-- 动画组
		local seq = cc.Sequence:create(scale_up, delayT, scale_down)

		-- 执行动画
		self.m_moreBgSprite:runAction(seq)
	end
end

function HallScene:hideMoreView()
	self.m_shadeBtn:setVisible(false)
	self.m_moreBgSprite:setVisible(false)
end

-- 进场动画
function HallScene:playEnterAni(delay)
	if not self.m_btPosition then
		self.m_btPosition = cc.p(self.m_bottomMenu:getPosition())
	end
	if not self.m_rtPosition then
		self.m_rtPosition = cc.p(self.m_rightSprite:getPosition())
	end
	self.m_bottomMenu:setPosition(self.m_btPosition)
	self.m_rightSprite:setPosition(self.m_rtPosition)
	self.m_bottomMenu:stopAllActions()
	self.m_rightSprite:stopAllActions()
	self:playEaseBackInOutAni(self.m_bottomMenu, delay, 1, 0, self.m_bottomMenu:getContentSize().height)
	--self:playEaseBackInOutAni(self.m_leftSprite, delay, 1, self.m_leftSprite:getContentSize().width, 0)
	self:playEaseBackInOutAni(self.m_rightSprite, delay, 1, -self.m_rightSprite:getContentSize().width, 0)
end

function HallScene:playExitAni(delay, callBack)
	self:playEaseBackInOutAni(self.m_bottomMenu, delay, 1, 0, -self.m_bottomMenu:getContentSize().height)
	--self:playEaseBackInOutAni(self.m_leftSprite, delay, 1, -self.m_leftSprite:getContentSize().width, 0)
	self:playEaseBackInOutAni(self.m_rightSprite, delay, 1, self.m_rightSprite:getContentSize().width, 0, callBack)
end

-- 退场动画
function HallScene:playEaseBackInOutAni(node, delay, nodeDuration, nodeX, nodeY, callBack)
	if not node then
		return
	end

	local function ani()
		-- 位移
		return cc.MoveBy:create(nodeDuration, cc.p(nodeX, nodeY))
	end

	local function delayTime()
		-- 延迟时长
		return cc.DelayTime:create(delay)
	end

	local delayT = delayTime()
	-- 效果动画
	local move_ease = cc.EaseBackInOut:create(ani())

	 -- 动画组
	local seq
	if callBack then
		seq = cc.Sequence:create(delayT, move_ease, cc.CallFunc:create(callBack))
	else
		seq = cc.Sequence:create(delayT, move_ease)
	end

	-- 执行动画
	node:runAction(seq)
end


function HallScene:createRankView()
	
	local HallRankUI = import("app.scenes.rank.hallRank").HallRankUI;
    self.m_rankView:add(HallRankUI:create());
end

function HallScene:showDiscount()
	self.m_add = g_NodeUtils:seekNodeByName(self.m_root, 'add')
	self.m_num1 = g_NodeUtils:seekNodeByName(self.m_root, 'discoutNum1')
	self.m_num2 = g_NodeUtils:seekNodeByName(self.m_root, 'discoutNum2')
	self.m_num3 = g_NodeUtils:seekNodeByName(self.m_root, 'discoutNum3')
	self.m_percent = g_NodeUtils:seekNodeByName(self.m_root, 'percent')
	self.m_discountBg = g_NodeUtils:seekNodeByName(self.m_root, 'discountBg')
	self.m_imageTextLayout = g_NodeUtils:seekNodeByName(self.m_root, 'imageText')
	self:onStorediscountUpdate()
end

function HallScene:onStorediscountUpdate()

	local discount = 0
	local itemDiscount = g_AccountInfo:getItemDiscount()
	if itemDiscount then
        for k,v in pairs(itemDiscount) do
            if v > discount then
                discount = v;
            end
        end
	end

	-- 貌似没有这个字段的数据
	local localpayoff = g_AccountInfo:getLocalpayoff()
	if localpayoff and localpayoff > discount then
		discount = localpayoff
	end

	local StoreManager = import("app.scenes.store").StoreManager
	local cash_discount = StoreManager.getInstance():getDiscountData()
	if cash_discount and type(cash_discount.discount) == "number" and cash_discount.discount > discount then
		discount = cash_discount.discount
	end

	-- 测试数据
	if discount > 0 then
		self.m_discountBg:setVisible(true)
		local allImageText = tostring(discount)
		local len = string.len(allImageText)
		for i = 1, 3 do
			if i <= len then
				local imageName = string.charAt(allImageText, i)
				if imageName == "+" then
					imageName = "add"
				end
				if imageName == "%" then
					imageName = "percen"
				end
				
				self["m_num" .. i]:setTexture("creator/hall/discount/" .. imageName .. ".png")
				self["m_num" .. i]:setVisible(true)
			else
				self["m_num" .. i]:setVisible(false)
			end
		end
		self.m_imageTextLayout:forceDoLayout()
	else
		self.m_discountBg:setVisible(false)
	end
end

-- 创建广告view
function HallScene:createBannerPageView(data)
	
    local bannerViewSize = self.m_bannerView:getContentSize()

	-- PageView
	if not self.m_bannerPageViewNode then
		self.m_bannerPageViewNode = BannerPageView:create(data, bannerViewSize.width, bannerViewSize.height)
		self.m_bannerPageViewNode:setAnchorPoint(cc.p(0, 0))
		self.m_bannerView:addChild(self.m_bannerPageViewNode)
	else 
		self.m_bannerPageViewNode:updateData(data)
	end
end

function HallScene:onRequestBannerSuccess(isSuccess,data)
	 --Log.d("Johnson  onRequestBannerSuccess",data)
	if isSuccess and not g_TableLib.isEmpty(data) then
		self.m_banners = data
		self:createBannerPageView(data)
		self.m_btnSwitch:setVisible(true)
	else 
		self.m_btnSwitch:setVisible(false)
		self.m_rankView:setVisible(true)
	end
end

function HallScene:onRequestPlaytimesSuccess(isSuccess,data)
	Log.d("Johnson  onRequestPlaytimesSuccess",data)
	if isSuccess and data then
		local currenTimes   = data.times;
		local times         = tonumber(currenTimes or 0);
		--修改动画状态
		if times == 0 and self.m_rotationEntry then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_rotationEntry)
			self.m_rotationEntry = nil
    	end
	end
end

function HallScene:initGameView()
	self.m_gameShade = g_NodeUtils:seekNodeByName(self.m_root, 'gameShade')
	self.m_gameBg = g_NodeUtils:seekNodeByName(self.m_root, 'gameBg')
	self.m_gameLayout = g_NodeUtils:seekNodeByName(self.m_root, 'gameLayout')
	self.m_wheel = g_NodeUtils:seekNodeByName(self.m_root, 'wheelIcon')
	self.m_gift = g_NodeUtils:seekNodeByName(self.m_root, 'gift')
	self.m_ticket = g_NodeUtils:seekNodeByName(self.m_root, 'ticket')
	self:hideGameview()
	self.m_gameShade:addClickEventListener(
	  function (send)
		self:hideGameview()
      end
	)
	self.m_wheel:addClickEventListener(
	  function (send)
		self:hideGameview()
		g_PopupManager.getInstance():show(g_PopupConfig.S_POPID.BIG_WHEEL_POP)
      end
	)
	self.m_gift:addClickEventListener(
	  function (send)
		self:hideGameview()
		--显示弹窗
      end
	)
	self.m_ticket:addClickEventListener(
	  function (send)
		self:hideGameview()
		--显示刮刮乐弹窗 目前还没有做
      end
	)

	self.m_wheel:setVisible(false)
	self.m_gift:setVisible(false)
	self.m_ticket:setVisible(false)
	self:startAnimation()
	
	local visibleItem = {}
	for i, v in ipairs(g_AccountInfo:getFreeChipList()) do
		if v == 1 then
			visibleItem[#visibleItem + 1] = self.m_wheel
			self.m_wheel:setVisible(true)
		elseif v == 4 then
			--visibleItem[#visibleItem + 1] = self.m_gift
			--self.m_gift:setVisible(true)
		elseif v == 2 then
			--visibleItem[#visibleItem + 1] = self.m_ticket
			--self.m_ticket:setVisible(true)
		end
	end
	self.m_gameLayout:forceDoLayout()
	local gamebgSize = self.m_gameBg:getContentSize()
	local gameLayoutSize = self.m_gameLayout:getContentSize()
	self.m_gameBg:setContentSize(cc.size(gameLayoutSize.width,gamebgSize.height))
	if #visibleItem == 0 then 
		self.m_gameViewNothing = true
	end
end

function HallScene:startAnimation()
	self.m_playWheelAnimArr = {}
	for i = 1, 8 do
        self.m_playWheelAnimArr[i] = g_NodeUtils:seekNodeByName(self, "img_flash_light"..i)
        self.m_playWheelAnimArr[i] : setVisible(true)
	end
	local i = 1
    local callback = function ()
        for j = 1,8 do
            if j==i then
                self.m_playWheelAnimArr[j]:setVisible(true)
            else
                self.m_playWheelAnimArr[j]:setVisible(false)
            end            
        end           
        i = i+1 > 8 and 1 or i+1
	end
	self.m_rotationEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.05, false)
end

function HallScene:updateUserIcon()
	local pic = g_AccountInfo:getSmallPic()
	local size = self.m_headIconContainer:getContentSize()
	local border = 4
	local clipPath = "creator/hall/header_bg.png"
	self.m_headIconContainer:setHeadIcon(pic, size.width - border, size.height - border, clipPath)
end

function HallScene:updateUserInfo()
	self:updateUserIcon()
	self:showVip()
	self.m_nameLabel:setString(g_StringLib.limitLength(g_AccountInfo:getNickName(),30,300))
	self.m_chipLabel:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
end

function HallScene:onMailBtnClick()
	print('onMailBtnClicked')
	g_PopupManager:show(g_PopupConfig.S_POPID.MAIL_BOX_POP)

end

function HallScene:onRelaxationBtnClick()
	print('onRelaxationBtnClick')
	self:showGameview()
end

function HallScene:showGameview()
	print('showGameview')
	if self.m_gameViewNothing then
		return
	end
	self.m_gameShade:setVisible(true)
	self.m_gameBg:setVisible(true)
end

function HallScene:hideGameview()
	print('hideGameview')
	self.m_gameShade:setVisible(false)
	self.m_gameBg:setVisible(false)
end

function HallScene:onFreeRemainTimes(times)
	print('onFreeRemainTimes')
	if times <= 0 and self.m_rotationEntry then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_rotationEntry)
		self.m_rotationEntry = nil
	else
		if times > 0 and not self.m_rotationEntry then -- 抽奖有再来一次
			self:startAnimation()
		end
	end
end

function HallScene:onAcitvityBtnClick()
	print('onAcitvityBtnClick')
	local flag, webInfo = self:createWebInfo(false, true)
	if flag then
		g_PopupManager:show(g_PopupConfig.S_POPID.ACTIVITY_WEB_POP, webInfo)
	else
		g_AlertDialog.getInstance()
		:setTitle(GameString.get("tips"))
		:setContent(GameString.get("str_activity_newest_empty"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
		:setCenterBtnTx(GameString.get("str_common_know"))
		:show()
	end
end

function HallScene:createWebInfo(reCreate, forcedDisplay)
	local res = g_AccountInfo:getHallIcon()
	if g_TableLib.isTable(res) and res.icon ~= nil and not g_SystemInfo.isWindows() then
		local callJS = ActivityWebInfo:defaultCallJs()
		local webInfo = ActivityWebInfo.new(tostring(res.url))
		webInfo:setCallJS(callJS)
		webInfo:setReCreate(reCreate)
		webInfo:setForcedDisplay(forcedDisplay)
		webInfo:setX(0)
		webInfo:setY(0)
		webInfo:setFull(true)
		return true, webInfo
	else
		return false
	end	
end

function HallScene:preLoadAcitvity()
	local flag, webInfo = self:createWebInfo(true,false)
	if not flag then return end
	Log.d("preLoadActivity",flag,webInfo)
	g_PopupManager:createPop(g_PopupConfig.S_POPID.ACTIVITY_WEB_POP):preLoad(webInfo)
end

function HallScene:onMissionBtnClick()
	print('onMissionBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.DAILYTASK_POP)
end

function HallScene:onMarketBtnClick()
	print('onMarketBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_CHIPS_PAGE)
end

function HallScene:onNormalBtnClick()
	print('onNormalBtnClick')

 	local normalSelectionsScene = import('app/scenes/normalSelectionsScene').scene
	cc.Director:getInstance():pushScene(normalSelectionsScene:create());
end

function HallScene:onMttBtnClick()
	print('onMttBtnClick')
	--g_PopupManager:show(g_PopupConfig.S_POPID.CHOOSE_MTT_OR_SNG_POP)
	local chooseMTTorSNGScene = import('app/scenes/chooseMTTorSNG').scene
	cc.Director:getInstance():pushScene(chooseMTTorSNGScene:create());
end

function HallScene:onQuickBtnClick()
	self:doLogic(g_SceneEvent.HALL_QUICKSTART);
	-- local data = {}
	-- data.ranking = 2
	-- data.chip = 20
	-- g_PopupManager:show(g_PopupConfig.S_POPID.SNG_REWARD_POP, data)

end

function HallScene:onUserHeaderBtnClick()
	print('onUserHeaderBtnClick')
	-- local userInfo = import("app.scenes.userInfo").UserInfoPop
	-- local scene = userInfo:create()
	-- self:addChild(scene)
	-- import
	g_PopupManager:show(g_PopupConfig.S_POPID.USER_INFO_POP)
end

function HallScene:onBackPackBtnClick()
	print('onBackPackBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE)
end

function HallScene:onFeedbackBtnClick()
	print('onFeedbackBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.HELP_POP,helpType.showTypeHall)
	-- g_PopupManager:show(g_PopupConfig.S_POPID.BIG_WHEEL_POP)
	-- g_PopupManager:show(g_PopupConfig.S_POPID.SUPER_LOTTO_POP)
end

function HallScene:onFriendBtnClick()
	print('onFriendBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.FRIEND_POP)
end

function HallScene:onCourseBtnClick()
	local tutorialInfo = g_AccountInfo:getNewCourse()
    if tutorialInfo ~= nil then
        local tutorialObj,flag = g_JsonUtil.decode(tutorialInfo);
        if flag and g_TableLib.isTable(tutorialObj) then
            if tutorialObj.bit == 0 and not g_Model:getData(g_ModelCmd.USER_RECEIVED_TUTORIAL_REWARD) then
				g_PopupManager:show(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP,1)
            elseif tutorialObj.bit == 0 and g_Model:getData(g_ModelCmd.USER_RECEIVED_TUTORIAL_REWARD) then
				local tutorialScene = import('app.scenes.tutorial').scene
				cc.Director:getInstance():pushScene(tutorialScene:create())
            elseif tutorialObj.bit == 1 then
                local tutorialScene = import('app.scenes.tutorial').scene
				cc.Director:getInstance():pushScene(tutorialScene:create())                
            end
        else
            Log.e(self.TAG, "onTutorial", "decode json has an error occurred!");
        end

    else
        local tutorialScene = import('app.scenes.tutorial').scene
		cc.Director:getInstance():pushScene(tutorialScene:create())
    end
end

function HallScene:onSettingBtnClick()
	print('onSettingBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_SETTING)
end

-- 活动banner和大厅排行榜切换
function HallScene:onSwitchBtnClick()
	if self.m_bannerView:isVisible() then
		self:setBannerViewVisibility(false)
	else
		self:setBannerViewVisibility(true)
	end
end

-- 排行榜弹窗
function HallScene:onRankBtnClick()
	print('onRankBtnClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.RANK_POP)
end

function HallScene:setBannerViewVisibility(visibility)
	self.m_bannerView:setVisible(visibility)
	self.m_bannerPageViewNode:setVisible(visibility)
	self.m_rankView:setVisible(not visibility)
end

function HallScene:onEventBack()
	-- g_AlertDialog.getInstance()
	-- 	:setTitle(GameString.get("str_logout_title"))
	-- 	:setContent(GameString.get("str_logout_content"))
	-- 	:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
	-- 	:setLeftBtnTx(GameString.get("str_logout_btn_cancel"))
	-- 	:setRightBtnTx(GameString.get("str_logout_btn_confirm"))
	-- 	:setRightBtnFunc(function()
	-- 		if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
	-- 			NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_LOGOUT_FACEBOOK)
	-- 		end
	-- 		g_AccountInfo:reset()
	-- 		local loginScene = import("app.scenes.login").scene
	-- 		cc.Director:getInstance():replaceScene(loginScene:create())
	-- 	end)
	-- 	:show()
	g_PopupManager:show(g_PopupConfig.S_POPID.BACKKEY_LOGOUT)
end

-- 配置事件监听函数
HallScene.s_eventFuncMap = {
	[g_SceneEvent.HALL_REQUEST_BANNER_SUCCESS] = "onRequestBannerSuccess";
	[g_SceneEvent.UPDATE_USER_HEAD_ICON] = "updateUserInfo";
	[g_SceneEvent.UPDATE_USER_DATA]   = "updateUserInfo";
	[g_SceneEvent.Hall_REQUEST_PLAYTIMES_SUCCESS] = "onRequestPlaytimesSuccess";
	[g_SceneEvent.Hall_SHOW_SUBGAMES] = "showGameview";
	[g_SceneEvent.STORE_DISCOUNT_UPDATE]		= "onStorediscountUpdate",
	[g_SceneEvent.HALL_UPDATE_RED_POINT]		= "updateRedPoint",
}

return HallScene;