--[[--ldoc desc
@module DealerChangePop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DealerChangePop = class("DealerChangePop",PopupBase);
BehaviorExtend(DealerChangePop);

local DealerItem = require('DealerItem')
local DealerConfig = require('DealerConfig')

-- 配置事件监听函数
DealerChangePop.s_eventFuncMap = {
}

function DealerChangePop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("DealerChangeCtr"))
	self:init()
end

function DealerChangePop:show()
	PopupBase.show(self)
	local default = g_AccountInfo:getDefaultHeguan()
	self:jumpToPage(default)
end

function DealerChangePop:hidden()
	PopupBase.hidden(self)
end

function DealerChangePop:init()
	self:loadLayout("creator/dealer/dealerChangePop.ccreator");

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')
	self.m_btnLeft = g_NodeUtils:seekNodeByName(self, 'btn_left')
	self.m_btnRight = g_NodeUtils:seekNodeByName(self, 'btn_right')	
	self.m_btnSetDealer = g_NodeUtils:seekNodeByName(self, 'btn_set_dealer')	
	self.m_pvDealerSelector = g_NodeUtils:seekNodeByName(self, 'pv_dealer_selector')	
	self.m_viewDealerSelector = g_NodeUtils:seekNodeByName(self, 'view_dealer_selector')
	self.m_btnShare = 	g_NodeUtils:seekNodeByName(self, 'btn_share')

	self.m_txShare = g_NodeUtils:seekNodeByName(self, 'tx_share')
	self.m_txSetDealer = g_NodeUtils:seekNodeByName(self, 'tx_set_dealer')
	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	-- self.m_viewV = g_NodeUtils:seekNodeByName(self, 'pageView')	

	-- self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	self.m_txDesc = g_NodeUtils:seekNodeByName(self, 'tx_dealer_desc')
	self.m_txPrice = g_NodeUtils:seekNodeByName(self, 'tx_desc')

	self:initPageView()
	self:setDealerData()
	self:initBtnClickEvent()

	self:initString()

	self.regetTimes = 3
end

function DealerChangePop:initString()
	-- local currentPage = self.m_pageView:getItem(1)
	-- local desc = currentPage:getDesc()
	-- self.m_txDesc:setString(desc)

	-- local price = currentPage:getPrice()
	-- local descStr = string.format(GameString.get('str_dealer_desc'),price)
	-- self.m_txPrice:setString(descStr)

	self.m_txShare:setString(GameString.get("str_sng_reward_pop_share"))
	self.m_txSetDealer:setString(GameString.get("str_dealer_set_dealer"))
	self.m_txTitle:setString(GameString.get("str_dealer_title"))
end

function DealerChangePop:initBtnClickEvent()
	local btnsActions = {
		{ btn = self.m_btnClose,       	cmds = self.onBtnCloseClick },      
		{ btn = self.m_btnLeft, 		cmds = self.onBtnLeftClick },  
		{ btn = self.m_btnRight, 		cmds = self.onBtnRightClick },
		{ btn = self.m_btnSetDealer,	cmds = self.onBtnSetDealerClick },
		{ btn = self.m_btnShare,		cmds = self.onBtnShareClick },
	}
	for i,value in ipairs(btnsActions) do
		value.btn:addClickEventListener(function(sender)
			value.cmds(self)
		end)
	end
end

function DealerChangePop:onScrollPageStart()
	local items = self.m_pageView:getItems()

	for i=1, #items do
		items[i]:scrollStart()
	end
end

function DealerChangePop:onScrollPageEnd()
	local currentIndex = self.m_pageView:getCurrentPageIndex()
	local currentPage = self.m_pageView:getItem(currentIndex)
	currentPage:scrollEnd()
	local desc = currentPage:getDesc()
	self.m_txDesc:setString(desc)

	local price = currentPage:getPrice()
	local descStr = string.format(GameString.get('str_dealer_desc'),price)
	if price == 0 then
		descStr = GameString.get('str_dealer_free_service')
	end
	self.m_txPrice:setString(descStr)

	if currentIndex == 0 then
		self.m_btnLeft:setEnabled(false)
	else
		self.m_btnLeft:setEnabled(true)
	end

	local pageNum = #self.m_pageView:getItems()
	if currentIndex == pageNum - 1 then
		self.m_btnRight:setEnabled(false)
	else
		self.m_btnRight:setEnabled(true)
	end
end

function DealerChangePop:initPageView()
	local size = self.m_viewDealerSelector:getContentSize()
	self.m_pageView = ccui.PageView:create()
	self.m_pageView:setContentSize(size);
	self.m_pageView:setDirection(2);
	self.m_pageView:setBounceEnabled(true);
	self.m_pageView:setItemsMargin(-450)
	self.m_pageView:setIndicatorEnabled(true)
	self.m_pageView:setIndicatorPosition(cc.p(size.width/2,size.height/2-175))
	self.m_pageView:setIndicatorSelectedIndexColor(cc.c4b(255,255,255,255))
	self.m_pageView:setIndicatorIndexNodesColor(cc.c4b(1,12,49,255))
	self.m_pageView:setIndicatorIndexNodesScale(0.2)
	self.m_pageView:setIndicatorSpaceBetweenIndexNodes(20)
	self.m_viewDealerSelector:addChild(self.m_pageView)

	local function pageViewEvent(self, sender, eventType)
		if eventType == ccui.ScrollviewEventType.autoscrollEnded then -- scroll start
			self:onScrollPageStart()
		end
		if eventType == 12 then --scroll end
			self:onScrollPageEnd()
		end
	end
	self.m_pageView:addScrollViewEventListener(handler(self, pageViewEvent))
end

function DealerChangePop:setDealerData()

	local data = g_Model:getData(g_ModelCmd.DEALER_LIST)

	Log.d('setDealerData',data)

	if data then
		self:addDealer(data)
	else
		local params = HttpCmd:getMethod(HttpCmd.s_cmds.DEALER_GET_INFO)
		g_HttpManager:doPost(params,self, self.onGetInfoResponse)
	end
end

function DealerChangePop:onGetInfoResponse(isSuccess, result)
    if isSuccess == true and result then
    	g_Model:setData(g_ModelCmd.DEALER_LIST,result)
        self:addDealer(result)
    elseif (self.regetTimes >= 0) then
        self:getInfoError();
    end
end

function DealerChangePop:getDealerInfoError()
    if self.m_retryTimes > 0 then
		local params = HttpCmd:getMethod(HttpCmd.s_cmds.DEALER_GET_INFO)
	    g_HttpManager.post(params, self, self.onGetInfoResponse, self.getInfoError);
        self.m_retryTimes = self.m_retryTimes - 1;
    else
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
    end
end

function DealerChangePop:addDealer(dealerInfoArray)
	local bgSize = self.m_pageView:getContentSize()
	for i=1,#dealerInfoArray do
		local dealerData = dealerInfoArray[i];
		local dealerItem = DealerItem:create(dealerData,bgSize);
		self.m_pageView:pushBackCustomItem(dealerItem)
	end
	self:onScrollPageEnd()
end

function DealerChangePop:onBtnCloseClick()
	self:hidden()
end

function DealerChangePop:onBtnLeftClick()
	self:onScrollPageStart()
	local currentIndex = self.m_pageView:getCurrentPageIndex()
	if currentIndex > 0 then
		self.m_pageView:scrollToPage(currentIndex - 1)
	end
end

function DealerChangePop:onBtnRightClick()
	self:onScrollPageStart()
	local currentIndex = self.m_pageView:getCurrentPageIndex()
	local pageNum = #self.m_pageView:getItems()
	if currentIndex < pageNum -1 then
		self.m_pageView:scrollToPage(currentIndex + 1)
	end
end

function DealerChangePop:jumpToPage(dealerId)
	local pages = self.m_pageView:getItems()
	for i=1,#pages do
		local page = pages[i]
		if page:getId() == dealerId then
			self:onScrollPageStart()
			self.m_pageView:jumpToItem(i-1,cc.p(0,0),cc.p(0,0))
			self:onScrollPageEnd()
			return
		end
	end
end

function DealerChangePop:onBtnSetDealerClick()
	local currentIndex = self.m_pageView:getCurrentPageIndex()
	local currentPage = self.m_pageView:getItem(currentIndex)
	self.m_currentPage = currentPage

	local params = HttpCmd:getMethod(HttpCmd.s_cmds.DEALER_SET_ID)
	params.deingerId = currentPage:getId()
	g_HttpManager:doPost(params,self, self.onSetDealerResponse)
end

function DealerChangePop:onSetDealerResponse( isSuccess, result)
	-- Log.d("onSetDealerResponse",isSuccess, result)
    if isSuccess == true and result == 0 then
        if self.m_currentPage then
        	self.m_currentPage:setToSelectDealer()
        	self:hidden()
        end
   	end
end

function DealerChangePop:onCleanup()
	PopupBase.onCleanup(self)
	self.m_currentPage = nil
end

function DealerChangePop:onBtnShareClick()

	if g_AccountInfo:getLoginFrom() ~= g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_other_account'))
		return
	end

	local param = GameString.get('str_social_config').changeDealer
	param.link = g_AppManager:getFBAppLink()
	NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_SHARE_FACEBOOK, param, self, self.onShareComplete)
end

function DealerChangePop:onShareComplete(response)
	if response and tonumber(response.result)  == 1 then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_success'))
		g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_SHARE_SUCCESS)
	elseif tonumber(response.result) == 3 then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_cancel'))
	else
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_failed'))
	end
end


return DealerChangePop;