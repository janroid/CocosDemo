--[[--ldoc desc
@module SlotCtr
@author JanRoid
Date  2018-12-25
]]

local SlotSocketManager = import("app.net").SlotSocketManager
local HttpCmd = import("app.config.config").HttpCmd

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SlotCtr = class("SlotCtr",ViewCtr);
BehaviorExtend(SlotCtr)

local defaultPokers = {
	{type = 1, value = 3},
	{type = 2, value = 5},
	{type = 3, value = 7},
	{type = 4, value = 9},
	{type = 1, value = 11},
}

---配置事件监听函数
SlotCtr.s_eventFuncMap =  {
	[g_SceneEvent.SLOT_PLAY] = "playSlot";
	[g_SceneEvent.SLOT_CALCULATOR] = "calculator";
	[g_SceneEvent.SLOT_RESULT] = "onSlotResult";
}

function SlotCtr:ctor()
	ViewCtr.ctor(self)

	self:init()
end

function SlotCtr:init()
	self:requestLuckyPoker()

	self.m_socketManager = SlotSocketManager:create()
	self.m_socketManager:openSocket()
end

function SlotCtr:show()
	ViewCtr.show(self)
end

function SlotCtr:hidden()
	ViewCtr.hidden(self)
end

function SlotCtr:playSlot(betMoney)
	if self.m_socketManager:requestPlay(betMoney) then
		self:updateView(g_SceneEvent.SLOT_PLAY_ANIM)
	else
		self:updateView(g_SceneEvent.SLOT_PLAY_FAIL)
	end
end

function SlotCtr:onSlotResult(data)
	local cardMap = getTabFromTable(data,"cardMap")
	local winMoney = getNumFromTable(data,"winMoney",0)
	
	g_Model:setProperty(g_ModelCmd.DATA_SLOT, "winMoney",winMoney)

	if next(data) == nil then -- 网络异常
		self:updateView(g_SceneEvent.SLOT_SHOW_LOTTERY, defaultPokers,-1)
	elseif next(cardMap) == nil then -- 钱不够
		self:updateView(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_LESS_CHIPS)
		self:updateView(g_SceneEvent.SLOT_SHOW_LOTTERY, defaultPokers, -2)

	else -- 成功
		local pokerMap = self:calculateCard(cardMap)
		self:updateView(g_SceneEvent.SLOT_SHOW_LOTTERY,pokerMap,winMoney)
	end

	local totalMoney = data.totalMoney

	if tonumber(totalMoney) then
		g_AccountInfo:setMoney(tonumber(totalMoney))
		local user = g_RoomInfo:getUserSelf()
		if user then
			user.totalChips = totalMoney
		end
	end

end

--[[
    @desc: 算牌器
    --@cardMap: 
    @return:
]]
function SlotCtr:calculator(cardMap)
	self.m_socketManager:requestCalculate(cardMap)
end

--[[
    @desc: 根据值计算牌，
    --@map: 
    @return:
]]
function SlotCtr:calculateCard(map)
	local pokers = {}
	for k, v in ipairs(map) do
		pokers[k] = {}
		pokers[k].value = g_BitUtil.band(v,0xff)   -- 牌的值
        pokers[k].type = g_BitUtil.brshift(v,8) -- 花色
	end

	return pokers
end

--[[
    @desc: 请求幸运牌型
    @return:
]]
function SlotCtr:requestLuckyPoker()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.SLOT_GETLUCKY)
	g_HttpManager:doPost(params, self, self.onLuckyRespose)
end

function SlotCtr:onLuckyRespose(isSuccess, data)
	if not isSuccess then
		Log.e("SlotCtr:onLuckyRespose - net error !")
		return
	end

	local times = getNumFromTable(data, "times", 1)
	local strLuck = getStrFromTable(data, "lucky","")

	if string.len(strLuck) > 0 then
		local tab = {}
		for i = 1, string.len(strLuck) do
			tab[i] = string.sub(strLuck,i,i)
		end

		g_Model:setProperty(g_ModelCmd.DATA_SLOT, "luckPoker",tab)
	end
	g_Model:setProperty(g_ModelCmd.DATA_SLOT, "luckMultiple",times)

	self:updateView(g_SceneEvent.SLOT_SHOW_LUCKY)
end


function SlotCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用ViewCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

function SlotCtr:onEnter()
	ViewCtr.onEnter(self, false);
	-- xxxxxx
end

function SlotCtr:onExit()
	Log.d("SlotCtr:onExit")
	ViewCtr.onCleanup(self, false);
	if self.m_socketManager then
		delete(self.m_socketManager)
	end
	self.m_socketManager = nil
end

return SlotCtr;