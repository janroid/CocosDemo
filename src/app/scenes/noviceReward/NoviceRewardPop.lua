--[[--ldoc desc
@module NoviceRewardPop
@author ReneYang

Date   2019-1-22
]]
local NoviceRewardItem = require("NoviceRewardItem")
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend

local ChipAnim = import("app.common.animation").ChipAnim

local NoviceRewardPop = class("NoviceRewardPop",PopupBase);
BehaviorExtend(NoviceRewardPop);

-- 配置事件监听函数
NoviceRewardPop.s_eventFuncMap = {
	[g_SceneEvent.NOVICE_REWARD_REFRESH] = "refreshRewardView";
	[g_SceneEvent.NOVICE_REWARD_RECEIVE_SUCCESS] = "receiveRewardSuccess";
}

function NoviceRewardPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("NoviceRewardCtr"))
	self:init()
end

function NoviceRewardPop:show()
	PopupBase.show(self)
end

function NoviceRewardPop:hidden()
	PopupBase.hidden(self)
	if g_AccountInfo:getFirstIn() == 1 then
		-- 新手教程引导
		g_PopupManager:show(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP,1)
	end
end

function NoviceRewardPop:init()
	self:loadLayout("creator/noviceReward/noviceReward.ccreator");
	self.m_rewardScrollView = g_NodeUtils:seekNodeByName(self, "scrollview")
	self.m_rewardScrollView:setBounceEnabled(false)
	self.m_rewardScrollView:setScrollBarEnabled(false)
	self.m_layout = g_NodeUtils:seekNodeByName(self, "layout")
	
	self.m_btnReceive = g_NodeUtils:seekNodeByName(self, "btnReceive")
	self.m_labelReceive = g_NodeUtils:seekNodeByName(self.m_btnReceive, "Label")
	self.m_labelReceive:setString(GameString.get("str_login_novice_reward_btn_text"))

	self.m_imgTitle = g_NodeUtils:seekNodeByName(self, "title")
	self.m_imgTitle:setTexture(switchFilePath("noviceReward/title.png"))

	self.m_btnReceive:addClickEventListener(function()
		self:doLogic(g_SceneEvent.NOVICE_REWARD_RECEIVE)
		
	end)
end

function NoviceRewardPop:refreshRewardView(data)
	Log.d("ReneYang","refreshRewardView", data)
	
	self.m_layout:setPosition(0,0)
	for i = 1,#data do
		
		local item = NoviceRewardItem:create();
		if g_AccountInfo:getLoginRewardStep() == i then
			data[i].isLight = true
		end
		data[i].day = i
		item:refreshData(data[i])
		item:setContentSize(cc.size(206,320))
		self.m_layout:addChild(item)
	end
	self.m_layout:forceDoLayout ()
	local size = self.m_layout:getContentSize()
	self.m_rewardScrollView:setInnerContainerSize(size)
end

function NoviceRewardPop:receiveRewardSuccess()
	local x,y = self.m_rewardScrollView:getPosition()
	local size = self.m_rewardScrollView:getContentSize()
	local startPoint = {
		x= x + 206 * (g_AccountInfo:getLoginRewardStep() - 1),
		y = y + size.height/2,
	}
	local endPoint = {
		x= 180,
		y = 20,
	}
	local delay = 0
	--for i=1, 10 do
		self:createChipAnim(startPoint,endPoint)--,delay + i*0.04)
	--end


	g_AccountInfo:setIsGetRegistReward(true) -- 已領取註冊獎勵

	local endCall = cc.CallFunc:create(function(sender)
		g_PopupManager:hidden(g_PopupConfig.S_POPID.NOVICE_REWARD_POP)
	end)
	self.m_btnReceive:setVisible(false)
	self:runAction(cc.Sequence:create(cc.DelayTime:create(2), endCall))
end

function NoviceRewardPop:createChipAnim(startPoint,endPoint,delay)
	local ani = ChipAnim:create()
	cc.Director:getInstance():getRunningScene():addChild(ani,1000000)
	ani:play(startPoint,endPoint)
	
end
return NoviceRewardPop;