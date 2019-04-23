--[[--ldoc desc
@module HallCtr
@author WuHuang
Date   2018-10-25
]]
local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local StoreConfig = import("app.scenes.store").StoreConfig
local PopupConfig = import('app.common.popup').PopupConfig
local PopupManager = import('app.common.popup').PopupManager
local HallScene = require("HallScene")
local HttpCmd = import("app.config.config").HttpCmd
local TrumpetSocketManager = import("app/net").TrumpetSocketManager
local DailyTaskManager = import("app.scenes.dailyTask").DailyTaskManager

local HallCtr = class("HallCtr",ViewCtr);
BehaviorExtend(HallCtr);

---配置事件监听函数
HallCtr.s_eventFuncMap =  {
	[g_SceneEvent.HALL_REQUEST_BANNER]			= "requestBannerImages",
	[g_SceneEvent.HALL_QUICKSTART]              = "requestQuickStart",
	[g_SceneEvent.Hall_REQUEST_PLAYTIMES]		= "requestCanPlayTimes",
}


function HallCtr:ctor()
	ViewCtr.ctor(self);
end

function HallCtr:onCleanup()
	ViewCtr.onCleanup(self);
end
function HallCtr:onExit()
	ViewCtr.onExit(self);
end
function HallCtr:onEnter()
	print("HallCtr:onEnter")
	self:requestBankData()
	self:initGameData()
	local from = g_Model:getData(g_ModelCmd.DATA_HALL_SCENE_FROM);  -- 區分進入HallScene的場景 1，LoginScene 2 新手教程
	local isGetRegistReward = g_AccountInfo:isGetRegistReward()
	if from == 1 and g_AccountInfo:getLoginRewardStep() > 0 and g_AccountInfo:getLoginRewardStep() < 4 then
		if not isGetRegistReward then
			-- 新手奖励
			g_PopupManager:show(g_PopupConfig.S_POPID.NOVICE_REWARD_POP)
		end
	else
		-- 每日登录奖励
		local loginReward = g_AccountInfo:getLoginReward()
		if not g_TableLib.isEmpty(loginReward) and loginReward.ret == 1 then
			g_PopupManager:show(g_PopupConfig.S_POPID.LOGIN_REWARD_POP, loginReward)
		end
	end
	g_Model:clearData(g_ModelCmd.DATA_HALL_SCENE_FROM);
	
	self:reConnectToRoom()
end

function HallCtr:reConnectToRoom()
	local data = g_Model:getData(g_ModelCmd.RECONNECT_DATA) or {}
	local tid = tonumber(data.tid)
	Log.d("HallCtr:reConnectToRoom", data)
	if tid and tid > 1 then
		g_RoomInfo:setAutoSitDown(false)
		data.reconnect = true
		local RoomPresenter = import("app.presenter").RoomPresenter
		RoomPresenter:toRoom(data)
	end
	g_Model:clearData(g_ModelCmd.RECONNECT_DATA)
end

--[[
    @desc: 用于处理需要登录游戏后就要初始化的数据
    @return:
]]
function HallCtr:initGameData( )
	TrumpetSocketManager.getInstance():openSocket()
	DailyTaskManager.getInstance():userLoggeIn()
end

function HallCtr:requestBankData()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_BANKCLICK)
	g_HttpManager:doPost(params,self, self.onGetBankDataReponse)
end

function HallCtr:onGetBankDataReponse(isSuccess, data)
	Log.d("HallCtr:onGetBankDataReponse ",isSuccess,data)
	if isSuccess and next(data) ~= nil then
		local bankMoney = data.bankmoney
		local bankToken = data.token
		local tag = data.tag
		g_AccountInfo:setBankMoney(bankMoney)
		g_AccountInfo:setBankToken(bankToken)
		g_AccountInfo:setIsSetBankPassword(tag == 1)
	end
end

function HallCtr:requestBannerImages()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.BANNER_SHOW)
	g_HttpManager:doPost(params, self, self.BannerCallBack);
end

function HallCtr:BannerCallBack(isSuccess, data)
	g_EventDispatcher:dispatch(g_SceneEvent.HALL_REQUEST_BANNER_SUCCESS,isSuccess,data)
end

function HallCtr:requestQuickStart( )
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.TABLE_QUICKIN)
	g_HttpManager:doPost(param, self, self.onQuickStartResponse)
	g_Progress.getInstance():show()
end

function HallCtr:onQuickStartResponse(isSuccess, data)
	Log.d("HallCtr:onQuickStartResponse",data)
	if not isSuccess then
		g_Progress.getInstance():dismiss()
		return
	end
--[[	local flag = data.flag
	g_RoomInfo:setRoomIp(data.ip)
	g_RoomInfo:setRoomPort(data.port)
	g_RoomInfo:setTid(data.tid)
	
	local normalRoomScene = import('app.scenes.normalRoom').scene
	cc.Director:getInstance():pushScene(normalRoomScene:create())]]
	-- data.tableType = g_RoomInfo.ROOM_TYPE_TOURNAMENT
	local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(data)
end

function HallCtr:requestCanPlayTimes()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.Hall_REQUEST_PLAYTIMES)
	g_HttpManager:doPost(params, self, self.getWheelCallBack);
end

function HallCtr:getWheelCallBack(isSuccess, data)
	g_EventDispatcher:dispatch(g_SceneEvent.Hall_REQUEST_PLAYTIMES_SUCCESS,isSuccess,data)
end

return HallCtr;