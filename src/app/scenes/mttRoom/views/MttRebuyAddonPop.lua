--[[--ldoc desc
@module MttRebuyAddonPop
@author CavanZhou

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MttRebuyAddonPop = class("MttRebuyAddonPop",PopupBase);
BehaviorExtend(MttRebuyAddonPop);
MttRebuyAddonPop.s_showType = {
	ADDON  = 1;
	REBUY  = 2;
}
-- 配置事件监听函数
MttRebuyAddonPop.s_eventFuncMap = {
	[g_SceneEvent.CLOSE_REBUY]				= "closeRubuyPop",--关闭rebuy相关的弹窗
	[g_SceneEvent.CLOSE_ADDON]				= "closeAddonPop",
}

function MttRebuyAddonPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("views.MttRebuyAddonCtr"))
	self:loadLayout("creator/mttRoom/layout/mttRebuyAddonPop.ccreator");
	self:init()
end

function MttRebuyAddonPop:show()
	PopupBase.show(self)
end

function MttRebuyAddonPop:hidden()
	PopupBase.hidden(self)
end

function MttRebuyAddonPop:init()

	self.m_txTitle 		= g_NodeUtils:seekNodeByName(self, 'alert_title')
	self.m_viewDsc      = g_NodeUtils:seekNodeByName(self, 'viewDsc')
	self.m_txPrizePool  = g_NodeUtils:seekNodeByName(self, 'txScore')
	self.m_txRank  		= g_NodeUtils:seekNodeByName(self, 'txRank')
	self.m_bgPoolNum    = g_NodeUtils:seekNodeByName(self, 'bg_currency_num1')
	self.m_bgRankNum    = g_NodeUtils:seekNodeByName(self, 'bg_currency_num')
	self.m_tipTitleCost = g_NodeUtils:seekNodeByName(self.m_viewDsc , 'tipTitleCost')
	self.m_txCostNum    = g_NodeUtils:seekNodeByName(self.m_viewDsc , 'txCostNum')
	self.m_tipTitleBuy  = g_NodeUtils:seekNodeByName(self.m_viewDsc , 'tipTitleBuy')
	self.m_txBuyNum     = g_NodeUtils:seekNodeByName(self.m_viewDsc , 'txBuyNum')

	self.m_viewOver     = g_NodeUtils:seekNodeByName(self.m_viewDsc, 'viewOver')
	self.m_txTotalNum   = g_NodeUtils:seekNodeByName(self.m_viewOver, 'txTotalNum')
	self.m_txOverNum    = g_NodeUtils:seekNodeByName(self.m_viewOver, 'txOverNum')
	self.m_tipTitleOver = g_NodeUtils:seekNodeByName(self.m_viewOver, 'tipTitleOver')
	
	self.m_txLeftBtn    = g_NodeUtils:seekNodeByName(self, 'btn_left_txt')
	self.m_txRightBtn   = g_NodeUtils:seekNodeByName(self, 'btn_right_txt')

	self.m_tipTitleCost:setString(GameString.get('str_rebuy_cost_long_7'))
	self.m_tipTitleBuy:setString(GameString.get('str_rebuy_buy_long_7'))
	self.m_tipTitleOver:setString(GameString.get('str_rebuy_over_num'))

    g_NodeUtils:seekNodeByName(self,"btn_left"):addClickEventListener(function(sender) self:onBtnLeftClick() end)
    g_NodeUtils:seekNodeByName(self,"btn_right"):addClickEventListener(function(sender) self:onBtnRightClick() end)
    g_NodeUtils:seekNodeByName(self,"btn_close"):addClickEventListener(function(sender) self:onBtnCloseClick() end)
    g_NodeUtils:seekNodeByName(self,"bg"):addClickEventListener(function() end)
	g_NodeUtils:seekNodeByName(self,"pop_transparency_bg"):addClickEventListener(function(sender)  end) --self:onBtnCloseClick()
	self.m_viewOver:setVisible(false)
end

function MttRebuyAddonPop:updateRebbyUI(data)
	g_NodeUtils:arrangeToCenter(self.m_viewDsc,0,0)
	self.m_viewOver:setVisible(true)
	self.m_txTitle:setString("Rebuy")
	self.m_txLeftBtn:setString(GameString.get('str_room_cancle_buy_chips'))

	local str = data.chipOrGlod==1 and GameString.get('str_store_chips') or GameString.get('str_store_coin')
	self.m_txOverNum:setString(tostring(data.rebuyRemainTime))
	self.m_txTotalNum:setString(tostring(g_StringLib.substitute(GameString.get("str_rebuy_total_num"), data.rebuyTotolTime or "")))
	self.m_txBuyNum:setString(tostring(data.rebuyGetChips))
	self.m_txCostNum:setString(tostring(data.rebuyCost)..str)
end

function MttRebuyAddonPop:updateAddonUI(data)
	g_NodeUtils:arrangeToCenter(self.m_viewDsc,0,-31)
	self.m_viewOver:setVisible(false)
	self.m_txTitle:setString("Addon")
	self.m_txLeftBtn:setString(GameString.get('str_room_cancle_addon_chips'))
	self.m_txRightBtn:setString(GameString.get('str_room_goon_addon_chips'))
	
	local str = data.chipOrGlod==1 and GameString.get('str_store_chips') or GameString.get('str_store_coin')
	self.m_txBuyNum:setString(tostring(data.addonGetChips))
	self.m_txCostNum:setString(tostring(data.addonCost)..str)
end

function MttRebuyAddonPop:show(data)
	self.m_showType = data and data.type and data.type or MttRebuyAddonPop.s_showType.ADDON 
	self.m_data     = data 
	local str1 = data and data.currentRank and data.currentRank or "__"
	local str2 = data and data.currentNum and data.currentNum or "__"

	self.m_txRank:setString(str1.." /"..str2)
	self.m_txPrizePool:setString(data.curentPrize)
	self.m_bgPoolNum:setContentSize(self.m_txPrizePool:getContentSize().width + 42,40)
	self.m_bgRankNum:setContentSize(self.m_txRank:getContentSize().width + 49,40)

    if self.m_showType==MttRebuyAddonPop.s_showType.ADDON then
		self:updateAddonUI(data)
		self:startInterval(data);	
	else
		self:updateRebbyUI(data)
		self:startInterval(data);	
	end  
    PopupBase.show(self)
end
    
function MttRebuyAddonPop:stopInterval()
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
end
        
function MttRebuyAddonPop:startInterval(data)
    self:stopInterval();
	self.m_currentTime = data.rebuyTime or 11
	local str = self.m_showType==MttRebuyAddonPop.s_showType.ADDON and GameString.get('str_room_goon_addon_chips') or GameString.get('str_room_goon_buy_chips')
	self.m_txRightBtn:setString(str .." ( " .. self.m_currentTime .. " )" )
	self.m_scheduleTask = g_Schedule:schedule(function()
		self.m_currentTime = self.m_currentTime - 1
		if self.m_currentTime <0 then
			self:onBtnCloseClick()
			return
		end
		local str1 = self.m_showType==MttRebuyAddonPop.s_showType.ADDON and GameString.get('str_room_goon_addon_chips') or GameString.get('str_room_goon_buy_chips')
		self.m_txRightBtn:setString(str1 .." ( " .. self.m_currentTime .. " )" )
	end,1,1,self.m_currentTime + 1) 
end

function MttRebuyAddonPop:onBtnLeftClick()
	if self.m_showType==MttRebuyAddonPop.s_showType.ADDON then
		g_EventDispatcher:dispatch(g_SceneEvent.NEW_MTT_SEND_ADDON,0)
	else
		g_EventDispatcher:dispatch(g_SceneEvent.NEW_MTT_SEND_REBUY,0)
	end
	self:hidden()
end

function MttRebuyAddonPop:onBtnRightClick()
	if self.m_showType==MttRebuyAddonPop.s_showType.ADDON then
		g_EventDispatcher:dispatch(g_SceneEvent.NEW_MTT_SEND_ADDON,1)
	else
		g_EventDispatcher:dispatch(g_SceneEvent.NEW_MTT_SEND_REBUY,1)
	end
	self:hidden()
end

function MttRebuyAddonPop:closeAddonPop()
	if self.m_showType==MttRebuyAddonPop.s_showType.ADDON then
		self:hidden()
	end
end

function MttRebuyAddonPop:closeRubuyPop()
	if self.m_showType==MttRebuyAddonPop.s_showType.REBUY then
		self:hidden()
	end
end

function MttRebuyAddonPop:onBtnCloseClick()
	self:onBtnLeftClick()
end

function MttRebuyAddonPop:onCleanup()
	self:stopInterval()
	PopupBase.onCleanup(self)
end

function MttRebuyAddonPop:hidden()
	self.m_showType = nil
	self:stopInterval()
    PopupBase.hidden(self)
end


return MttRebuyAddonPop;