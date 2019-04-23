--[[--ldoc desc
@module LoginRewardUI
@author RyanXu

Date   2018-10-31
]]

local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local LoginRewardUI = class("LoginRewardUI",PopupBase);
BehaviorExtend(LoginRewardUI);

LoginRewardUI.s_rewardType = {
	base = 0,
	fb = 1,
	play = 2,
	vip = 3,
	invite = 4,
}

LoginRewardUI.s_targetPos = cc.p(200,50)

function LoginRewardUI:ctor(data)
	PopupBase.ctor(self);
	self.m_data = data
	self:bindCtr(require(".LoginRewardCtr"));
	local map = {
		g_SoundMap.effect.ChipDropping,
		g_SoundMap.effect.BubbleBreak
	}
	g_SoundManager:preloadEffects(map)
	self:init();
end

LoginRewardUI.blockBackBtn = true

function LoginRewardUI:init()
	self.m_aniManager = self:loadLayout("creator/loginReward/loginReward.ccreator");

	self:addChild(self.m_aniManager)

	self.m_btnAllReward =  g_NodeUtils:seekNodeByName(self,'btn_all_reward') 
	self.m_btnLoginReward =  g_NodeUtils:seekNodeByName(self,'btn_login_reward')
	self.m_btnPlayReward =  g_NodeUtils:seekNodeByName(self,'btn_play_reward') 
	self.m_btnVipReward =  g_NodeUtils:seekNodeByName(self,'btn_vip_reward')
	self.m_btnFbReward =  g_NodeUtils:seekNodeByName(self,'btn_fb_reward')
	 
	self.m_txAll =  g_NodeUtils:seekNodeByName(self,'tx_all')
	self.m_txTips =  g_NodeUtils:seekNodeByName(self,'tx_tips')
	self.m_txLoginReward =  g_NodeUtils:seekNodeByName(self,'tx_login_reward') 
	self.m_txLoginRewardNum =  g_NodeUtils:seekNodeByName(self,'tx_login_reward_num') 
	self.m_txPlayReward =  g_NodeUtils:seekNodeByName(self,'tx_play_reward') 
	self.m_txPlayRewardNum =  g_NodeUtils:seekNodeByName(self,'tx_play_reward_num') 
	self.m_txVipReward =  g_NodeUtils:seekNodeByName(self,'tx_vip_reward') 
	self.m_txVipRewardNum =  g_NodeUtils:seekNodeByName(self,'tx_vip_reward_num')
	self.m_txFbReward =  g_NodeUtils:seekNodeByName(self,'tx_fb_reward') 
	self.m_txFbRewardNum =  g_NodeUtils:seekNodeByName(self,'tx_fb_reward_num') 

	self.m_txPlayHadReward =  g_NodeUtils:seekNodeByName(self,'tx_play_had_reward') 
	self.m_txVipHadReward =  g_NodeUtils:seekNodeByName(self,'tx_vip_had_reward') 

	self.m_btnLoginReward:setVisible(false)
	self.m_btnPlayReward:setVisible(false)
	self.m_btnVipReward:setVisible(false)
	self.m_btnFbReward:setVisible(false)

	local function formatMoney(money)
		if g_AppManager:getAppVer() == g_AppManager.S_APP_VER.FB_VN then
			return g_MoneyUtil.formatMoney(money)
		else
			return g_MoneyUtil.skipMoney(money)
		end
	end

	self.m_btnArray = {}
	if self.m_data ~= nil and self.m_data.data ~= nil then
		for i=1, #self.m_data.data do
			local rewardData = self.m_data.data[i]
			if rewardData.id == LoginRewardUI.s_rewardType.base then
				self.m_btnArray[#self.m_btnArray+1] = self.m_btnLoginReward
				self.m_btnLoginReward:setVisible(true)
				self.m_txLoginRewardNum:setString("+$"..formatMoney(rewardData.chips))
				self.m_btnLoginReward.m_collectMoney = rewardData.chips
			elseif rewardData.id == LoginRewardUI.s_rewardType.fb then
				self.m_btnArray[#self.m_btnArray+1] = self.m_btnFbReward
				self.m_btnFbReward:setVisible(true)
				self.m_txFbRewardNum:setString("+$"..formatMoney(rewardData.chips))
				self.m_btnFbReward.m_collectMoney = rewardData.chips
			elseif rewardData.id == LoginRewardUI.s_rewardType.play then
				self.m_btnArray[#self.m_btnArray+1] = self.m_btnPlayReward
				self.m_btnPlayReward:setVisible(true)
				self.m_txPlayRewardNum:setString("+$"..formatMoney(rewardData.chips))
				self.m_btnPlayReward.m_collectMoney = rewardData.chips
			elseif rewardData.id == LoginRewardUI.s_rewardType.vip then
				self.m_btnArray[#self.m_btnArray+1] = self.m_btnVipReward
				self.m_btnVipReward:setVisible(true)
				self.m_txVipRewardNum:setString("+$"..formatMoney(rewardData.chips))
				self.m_btnVipReward.m_collectMoney = rewardData.chips
			end
		end
	end

	self.m_btnLayout = self.m_btnLoginReward:getParent()
	self.m_btnLayout:forceDoLayout()

    self.m_chipArr = {};
    for i=1,7 do
        self.m_chipArr[i] = "creator/loginReward/img/act-task-reward-chip-icon-" .. i .. ".png";
    end

	self:initString();
	self:initListener()
end

function LoginRewardUI:initString()
	local function formatMoney(money)
		if g_AppManager:getAppVer() == g_AppManager.S_APP_VER.FB_VN then
			return g_MoneyUtil.formatMoney(money)
		else
			return g_MoneyUtil.skipMoney(money)
		end
	end
	self.m_txAll:setString(GameString.get("str_loginReward_all") .. formatMoney(self.m_data.chips))
	self.m_txTips:setString(GameString.get("str_loginReward_tips"))

	self.m_txLoginReward:setString(GameString.get("str_loginReward_login"))
	self.m_txPlayReward:setString(GameString.get("str_loginReward_play"))
	self.m_txVipReward:setString(GameString.get("str_loginReward_vip"))
	self.m_txFbReward:setString(GameString.get("str_loginReward_fb"))
	self.m_txPlayHadReward:setString(GameString.get("str_loginReward_hadReward"))
	self.m_txVipHadReward:setString(GameString.get("str_loginReward_hadReward"))

end

function LoginRewardUI:createChipAnim(startPoint,endPoint,delay)

	local id = math.modf(7 * math.random() - 0.499999) + 1;

	local chip = cc.Sprite:create(self.m_chipArr[id])
	self:addChild(chip);
	chip:setVisible(false);

	chip:setPosition(startPoint.x +  math.random(-20,20),startPoint.y +  math.random(-20,20));

	local midPoint = cc.p((endPoint.x+startPoint.x)/2, (endPoint.y+startPoint.y)/2)
	local xielv = (startPoint.y-endPoint.y) / (startPoint.x-endPoint.x)
	local fanxielv = -1/xielv
	local lenght = math.sqrt(math.pow(startPoint.y-endPoint.y,2) + math.pow(startPoint.x-endPoint.x,2))
	local hight = math.random(lenght*0.1,lenght*0.15)
	local x = hight / fanxielv

	local bezier = {
    	cc.p(midPoint.x + x, midPoint.y+hight),
    	cc.p(midPoint.x + x, midPoint.y+hight),
    	endPoint,
  	}
	local moveAction = cc.BezierTo:create(1, bezier)
	local endCall = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
	end)
	local startCall = cc.CallFunc:create(function(sender)
		chip:setVisible(true);
	end)
	local fadeAction = cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.3, 0.5),endCall)
	local rotaiton = cc.RotateBy:create(1,360)
	local spawnAction = cc.Spawn:create(moveAction,fadeAction,rotaiton)
	local EasaIn = cc.EaseInOut:create(spawnAction, 2.0)
	chip:runAction(cc.Sequence:create(cc.DelayTime:create(delay),startCall,EasaIn))
	
end

function LoginRewardUI:collectChipAnim(btn,endPoint,delay)

	local bubble = cc.Sprite:create("creator/loginReward/img/bubble_01.png")
	self:addChild(bubble);
	
	bubble:setVisible(false);
	btn:setEnabled(false)
	local startCall = cc.CallFunc:create(function(sender)
		bubble:setVisible(true);
		btn:setVisible(false)
		local startPoint = btn:convertToWorldSpaceAR(cc.p(0,0))
		bubble:setPosition(startPoint.x,startPoint.y);
		g_SoundManager:playEffect(g_SoundMap.effect.ChipDropping)
		g_SoundManager:playEffect(g_SoundMap.effect.BubbleBreak)
		self.m_aniManager:playAnimationClip(bubble,"bubbleClip")
		for i=1,10 do
			self:createChipAnim(startPoint,endPoint,delay + i*0.04)
		end
	end)
	local endCall = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
		g_AccountInfo:setMoney(g_AccountInfo:getMoney() + tonumber(btn.m_collectMoney))
		g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_DATA)
	end)
	bubble:runAction(cc.Sequence:create(cc.DelayTime:create(delay),startCall,cc.DelayTime:create(1.0),endCall))

end

function LoginRewardUI:initListener()
	self.m_btnAllReward:addClickEventListener(
		function(sender)

			self.m_btnAllReward:setVisible(false)
			local delay = 0
			for i = 1, #self.m_btnArray do
				local btn = self.m_btnArray[i]
				if btn:isVisible() == true then
					self:collectChipAnim(btn,LoginRewardUI.s_targetPos,delay)
					delay = delay + 0.2	
				end
			end
			self:delayHiddenPop()	
		end
	)

	if self.m_btnLoginReward then
		self.m_btnLoginReward:addClickEventListener(
			function(sender)
				self:collectChipAnim(self.m_btnLoginReward,LoginRewardUI.s_targetPos,0)
				self:delayHiddenPop()		
			end
		)
	end
	if self.m_btnPlayReward then
		self.m_btnPlayReward:addClickEventListener(
			function(sender)
				self:collectChipAnim(self.m_btnPlayReward,LoginRewardUI.s_targetPos,0)	
				self:delayHiddenPop()	
			end
		)
	end
	if self.m_btnVipReward then
		self.m_btnVipReward:addClickEventListener(
			function(sender)
				self:collectChipAnim(self.m_btnVipReward,LoginRewardUI.s_targetPos,0)	
				self:delayHiddenPop()	
			end
		)
	end
	if self.m_btnFbReward then
		self.m_btnFbReward:addClickEventListener(
			function(sender)
				self:collectChipAnim(self.m_btnFbReward,LoginRewardUI.s_targetPos,0)
				self:delayHiddenPop()		
			end
		)
	end
end

function LoginRewardUI:delayHiddenPop()
	if self:checkIsCollectFinish() == true then
		self.m_btnAllReward:setVisible(false)
	end

	local hiddenCall = cc.CallFunc:create(function(sender)
		if self:checkIsCollectFinish() == true then
			g_AccountInfo:setLoginReward(nil)
			-- self.m_aniManager:stopAllAnimationClips()
			g_PopupManager:clearPop(g_PopupConfig.S_POPID.LOGIN_REWARD_POP)
		end
	end)
	local hiddenAction = cc.Sequence:create(cc.DelayTime:create(2.0),hiddenCall)
	
	self:stopActionByTag(1)
	hiddenAction:setTag(1)
	self:runAction(hiddenAction)
end

function LoginRewardUI:checkIsCollectFinish()

	local isFinish = true
	for i = 1, #self.m_btnArray do
		local btn = self.m_btnArray[i]
		if btn:isEnabled() == true then
			isFinish = false
		end
	end
	return isFinish
end

---刷新界面
function LoginRewardUI:updateView(data)
	data = checktable(data);
end

return LoginRewardUI;