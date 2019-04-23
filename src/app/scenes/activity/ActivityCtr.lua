--[[--ldoc 网页活动控制器
@module ActivityCtr
@author LoyalwindPeng
Date   2019-1-7
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ActivityCtr = class("ActivityCtr",PopupCtr);
BehaviorExtend(ActivityCtr);

---配置事件监听函数
ActivityCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	

}

function ActivityCtr:ctor()
	PopupCtr.ctor(self);
end

function ActivityCtr:show()
	PopupCtr.show(self)
end

function ActivityCtr:hidden()
	PopupCtr.hidden(self)
end

function ActivityCtr:onWebClose(data)

end

function ActivityCtr:onWebPlayNow(data)
	if self:_isNotInHallScene() then return end
	g_EventDispatcher:dispatch(g_SceneEvent.HALL_QUICKSTART)
end

function ActivityCtr:onWebOpenShop(data)
	local StoreConfig = import('app.scenes.store').StoreConfig
	local shopMap = {
		['nil']    	   = StoreConfig.STORE_POP_UP_CHIPS_PAGE,
		['chip']       = StoreConfig.STORE_POP_UP_CHIPS_PAGE,
		['coalaa']     = StoreConfig.STORE_POP_UP_BY_PAGE,
		['prop']       = StoreConfig.STORE_POP_UP_PROPS_PAGE,
		['vip']        = StoreConfig.STORE_POP_UP_VIP_PAGE,
		['myPro']      = StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE,
		['buyHistory'] = StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE
	}
	local page = shopMap[tostring(data)]
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE, page)
end	

function ActivityCtr:onWebShowActWheel(data)
	g_PopupManager.getInstance():show(g_PopupConfig.S_POPID.BIG_WHEEL_POP)
end

--进普通场房间  data为房间类型  1 ~ 4(老版本功能，暂时不需要加接口)
function ActivityCtr:onWebGoGameRoom(data)

end	

function ActivityCtr:onWebGoNormalHall(data)
	if self:_isNotInHallScene() then return end
	local tab = tonumber(data) or 1
	local NormalSelectionsScene = import('app.scenes.normalSelectionsScene').scene
	cc.Director:getInstance():pushScene(NormalSelectionsScene:create(tab))
end	

function ActivityCtr:onWebGoSNGHall(data)
	if self:_isNotInHallScene() then return end
	local SngLobbyScene = import('app.scenes.sngLobby').SngLobbyScene
	cc.Director:getInstance():pushScene(SngLobbyScene:create())
end	

function ActivityCtr:onWebGoMTTHall(data)
	if self:_isNotInHallScene() then return end
	local mttLobbyScene = import('app.scenes.mttLobbyScene').scene
	cc.Director:getInstance():pushScene(mttLobbyScene:create())
end	
-- 无
function ActivityCtr:onWebGoPromotionHall(data)

end	

function ActivityCtr:onWebOpenGift(data)
	local params = g_TableLib.copyTab(data)
	if params['tabId'] ~= nil then
		params.tabId = 2;
	end
	g_EventDispatcher:dispatch(g_SceneEvent.OPEN_GIFT_POPUP, params)
end	

function ActivityCtr:onWebOpenTicket(data)

end	

function ActivityCtr:onWebInviteFriend(data)
	g_PopupManager:show(g_PopupConfig.S_POPID.FRIEND_POP)
end	
--无
function ActivityCtr:onWebOpenNewActWheel(data)

end	
--无
function ActivityCtr:onWebBlindsRoom(data)

end	

--钻石大赢家 暂时没有
function ActivityCtr:onWebDiamondWinner(data)

end	

--  未实现
function ActivityCtr:onWebOpenFansCode(data)

end	

--打开点球活动 不实现
function ActivityCtr:onWebOpenPenalties(data)

end	

--打开金钥匙 
function ActivityCtr:onWebOpenGoldenKey(data)

end	

function ActivityCtr:onWebOpenTask(data)
	if self:_isNotInHallScene() then return end
	g_PopupManager:show(g_PopupConfig.S_POPID.DAILYTASK_POP)
end	

function ActivityCtr:onWebOpenFriendsPage(data)
	g_PopupManager:show(g_PopupConfig.S_POPID.FRIEND_POP)
end	

--关闭页面, 检测下一个自动html页面 不实现
function ActivityCtr:onWebCheckNextHtml(data)

end	

--跳转到互动中心，追加url 
function ActivityCtr:onWebOpenWebView(data)

end	

function ActivityCtr:onWebOpenFeed(data)
	local HelpType = import('app.scenes.help').ShowType
	g_PopupManager:show(g_PopupConfig.S_POPID.HELP_POP, HelpType.showTypeHall)
end	

function ActivityCtr:onWebOpenBrowser(data)
	if data and data.url then
		g_AppManager:openURL(tostring(data.url))
	end
end	

function ActivityCtr:_isNotInHallScene()
	if cc.Director:getInstance():getRunningScene():getName() ~= "HallScene" then
		return true
	else
		return false
	end
end

function ActivityCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function ActivityCtr:onEnter()
	PopupCtr.onEnter(self, true);
	-- xxxxxx
end

function ActivityCtr:onExit()
	PopupCtr.onCleanup(self, true);
	-- xxxxxx
end

return ActivityCtr;