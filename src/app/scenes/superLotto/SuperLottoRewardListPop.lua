--[[--ldoc desc
@module SuperLottoRewardListPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SuperLottoRewardListPop = class("SuperLottoRewardListPop",PopupBase);
BehaviorExtend(SuperLottoRewardListPop);

local RewardListItem = require('RewardListItem')

-- 配置事件监听函数
SuperLottoRewardListPop.s_eventFuncMap = {
}

function SuperLottoRewardListPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("SuperLottoRewardListCtr"))
	self:init()
end

function SuperLottoRewardListPop:show()
	PopupBase.show(self)
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.SUPER_LOTTO_GET_REWARD_LIST)
	g_HttpManager:doPost(params,self, self.onGetRewardList)
end

function SuperLottoRewardListPop:hidden()
	PopupBase.hidden(self)
end

function SuperLottoRewardListPop:init()
	self:loadLayout("creator/superLotto/superLottoRewardList.ccreator");

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')	
	self.m_viewRewardList = g_NodeUtils:seekNodeByName(self,'view_reward_list')

	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')

	self:initString()
	self:initBtnClickEvent()
end

function SuperLottoRewardListPop:initString()
	self.m_txTitle:setString(GameString.get('str_superLotto_reward_list_title'))

	self.m_listView = ccui.ListView:create()
	self.m_listView:setContentSize(self.m_viewRewardList:getContentSize());
	self.m_listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_listView:setBounceEnabled(true);
	self.m_listView:setScrollBarWidth(6)
	self.m_viewRewardList:addChild(self.m_listView)
end

function SuperLottoRewardListPop:onGetRewardList(isSuccess, result)
    if not isSuccess or not g_TableLib.isTable(result) then
       	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
    else
    	Log.d('onGetRewardList',result)
    	self.m_listView:removeAllChildren()
    	if result.ret == 1 then
    		local list = result.rewardUids 
    		for i=1, #list do
    			local data = list[i]
    			local newItem = RewardListItem.create()
    			
    			self.m_listView:pushBackCustomItem(newItem)
    			newItem:setData(data)
    		end
    	end
    end
end

function SuperLottoRewardListPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
end

function SuperLottoRewardListPop:onBtnCloseClick()
	self:hidden()
end

function SuperLottoRewardListPop:onCleanup()
	PopupBase.onCleanup(self)
end


return SuperLottoRewardListPop;