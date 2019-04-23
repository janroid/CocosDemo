--[[--ldoc desc
@module TutorialRewardPop
@author ReneYang

Date   2019-1-22
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TutorialRewardPop = class("TutorialRewardPop",PopupBase);
BehaviorExtend(TutorialRewardPop);

-- 配置事件监听函数
TutorialRewardPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
	[g_SceneEvent.BEGINNER_TUTORIAL_EXIT] = "exit";
}

TutorialRewardPop.s_type = {
	["start"] = 1;
	["receiveReward"] = 2;
}
function TutorialRewardPop:ctor()
	PopupBase.ctor(self, true);
	self:bindCtr(require("tutorialReward.TutorialRewardCtr"))
	self:init()
	self:setClickShadeClose(false)
	self:setListener()
end

function TutorialRewardPop:show(sType)
	PopupBase.show(self)
	g_AccountInfo:setFirstIn(0)
	if sType == TutorialRewardPop.s_type["start"] then
		self.m_btnExit  : setVisible(true);
		self.m_btnStart : setVisible(true);
		self.m_btnReceiveAward : setVisible(false);
		self.m_content:setString(GameString.get("str_tutoria_start_desc_text"));
	else
		self.m_btnExit  : setVisible(false);
		self.m_btnStart : setVisible(false);
		self.m_btnReceiveAward : setVisible(true);
		self.m_content:setString(GameString.get("str_tutoria_complete_desc_text"));
	end
end

function TutorialRewardPop:hidden()
	PopupBase.hidden(self)
end

function TutorialRewardPop:init()
	self:loadLayout("creator/tutorial/tutorialReward.ccreator", true);
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, "closeBtn")
	self.m_title = g_NodeUtils:seekNodeByName(self, "labelTitle")
	self.m_content = g_NodeUtils:seekNodeByName(self, "labelContent")
	self.m_btnExit = g_NodeUtils:seekNodeByName(self, "btnExit")
	self.m_labelExit = g_NodeUtils:seekNodeByName(self, "labelExit")
	self.m_btnStart = g_NodeUtils:seekNodeByName(self, "btnStart")
	self.m_labelStart = g_NodeUtils:seekNodeByName(self, "labelStart")
	self.m_btnReceiveAward = g_NodeUtils:seekNodeByName(self, "btnReceiveAward")
	self.m_labelReceiveAward = g_NodeUtils:seekNodeByName(self, "labelReceiveAward")
	self.m_reward1 = g_NodeUtils:seekNodeByName(self, "reward1")
	self.m_labelReward1 = g_NodeUtils:seekNodeByName(self.m_reward1, "labelReward")
	self.m_reward2 = g_NodeUtils:seekNodeByName(self, "reward2")
	self.m_labelReward2 = g_NodeUtils:seekNodeByName(self.m_reward2, "labelReward")
	self.m_reward3 = g_NodeUtils:seekNodeByName(self, "reward3")
	self.m_labelReward3 = g_NodeUtils:seekNodeByName(self.m_reward3, "labelReward")
	
	self.m_title:setString(GameString.get("str_tutoria_popup_title"))
	self.m_labelExit:setString(GameString.get("str_common_tutoria_popup_quit_btn"))
	self.m_labelStart:setString(GameString.get("str_common_tutoria_popup_start_btn"))
	self.m_labelReceiveAward:setString(GameString.get("str_common_tutoria_popup_receive_btn"))
	
	local rewardInfo,flag = g_JsonUtil.decode(g_AccountInfo:getNewCourse());--奖励信息
	Log.d("g_AccountInfo:getNewCourse()",g_AccountInfo:getNewCourse())
    if flag then
        rewardInfo = rewardInfo or {};
        self.m_labelReward1:setString(g_StringLib.substitute(GameString.get("str_tutoria_popup_chips"),       g_MoneyUtil.formatMoney(rewardInfo.money    or 0)));
        self.m_labelReward2:setString(g_StringLib.substitute(GameString.get("str_tutoria_popup_exp"),         rewardInfo.exp      or 0));
        self.m_labelReward3:setString(g_StringLib.substitute(GameString.get("str_tutoria_popup_funny_props"), rewardInfo.functool or 0));
    else
        Log.e(self.TAG, "showEnd", "decode json has an error occurred!");
    end
end


function TutorialRewardPop:setListener()
	self.m_btnClose:addClickEventListener(function(sender)
		g_PopupManager:hidden(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP)
	end)
	self.m_btnExit:addClickEventListener(function(sender)
		g_PopupManager:hidden(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP)
	end)
	self.m_btnStart:addClickEventListener(function(sender)
		g_PopupManager:hidden(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP)
		local normalRoomScene = import('app.scenes.tutorial').scene
		cc.Director:getInstance():pushScene(normalRoomScene:create())
	end)
	self.m_btnReceiveAward:addClickEventListener(function(sender)
		self:doLogic(g_SceneEvent.BEGINNER_TUTORIAL_REWARD)
	end)
end


function TutorialRewardPop:createChipAnim(startPoint,endPoint,delay)
	local chip = cc.Sprite:create("creator/loginReward/img/chip_01.png")
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
	local moveAction = cc.BezierTo:create(0.7, bezier)
	local endCall = cc.CallFunc:create(function(sender)
		sender:removeFromParent()
	end)
	local startCall = cc.CallFunc:create(function(sender)
		chip:setVisible(true);
		-- self.m_aniManager:playAnimationClip(chip,"chipClip")
	end)
	local fadeAction = cc.Sequence:create(cc.DelayTime:create(0.7),cc.FadeTo:create(0.3, 0.5),endCall)
	local spawnAction = cc.Spawn:create(moveAction,fadeAction)
	local EasaIn = cc.EaseInOut:create(spawnAction, 2.0)
	local endCall = cc.CallFunc:create(function(sender)
		if self.m_called then return end
		self.m_called = true
		g_PopupManager:clearPop(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP)
	end)
	chip:runAction(cc.Sequence:create(cc.DelayTime:create(delay),startCall,EasaIn, endCall))

end

function TutorialRewardPop:exit(isSuccess)
	Log.d("TutorialRewardPop:exit",isSuccess)
	if isSuccess then
		local delay = 0
		self.m_called = false
		for i=1, 10 do
			self:createChipAnim(self.m_btnReceiveAward:getParent():convertToWorldSpace(cc.p(self.m_btnReceiveAward:getPosition())),cc.p(180, 20),delay + i*0.04)
		end
	end
end

function TutorialRewardPop:onCleanup()
	PopupBase.onCleanup(self)
end


return TutorialRewardPop;