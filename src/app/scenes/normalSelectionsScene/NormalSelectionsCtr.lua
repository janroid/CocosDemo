--[[--ldoc desc
@module NormalSelectionsCtr
@author RyanXu
Date   2018-11-9
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local NormalSelectionsCtr = class("NormalSelectionsCtr",ViewCtr);
BehaviorExtend(NormalSelectionsCtr);

local HttpCmd = import("app.config.config").HttpCmd

local SceneConfig = require('config.SceneConfig')

---配置事件监听函数
NormalSelectionsCtr.s_eventFuncMap =  {

	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_TABAR_INDEX]			= "onUpdateTabarIndex",
	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_SORT_TYPE]			= "onUpdateSortType",
	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_DISPLAY_TYPE]		= "onUpdateDisplayType",
	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_FILTER]				= "onUpdateFilter",
	[g_SceneEvent.NORMAL_SELECTIONS_SEARCH_ROOM]				= "onSearchRoom",
	[g_SceneEvent.NORMAL_SELECTIONS_REFRESH_ROOM]               = "onRefreshRoom",
	[g_SceneEvent.NORMAL_SELECTIONS_FORCE_UPDATE]               = "onForceUpdate",
	[g_SceneEvent.NORMAL_SELECTIONS_QUICKSTART]               	= "requestQuickStart",
	
}

function NormalSelectionsCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);

	self.m_data = require("NormalSelectionsData")
	self.m_data:init()
	self.m_currentDisplayType = SceneConfig.displayType.list
end

function NormalSelectionsCtr:onCleanup()
	ViewCtr.onCleanup(self);
end

function NormalSelectionsCtr:onUpdateTabarIndex(index)
	if index == 3 then
		self.m_currentRoomRank = SceneConfig.roomRankType.highRank
	elseif index == 2 then
		self.m_currentRoomRank = SceneConfig.roomRankType.middleRank
	else
		self.m_currentRoomRank = SceneConfig.roomRankType.lowRank
	end 
	self:updateDisplay()
	self:updateRoomInfo(self:getCurrentRankData())
end

function NormalSelectionsCtr:onForceUpdate()
	self.m_data:cleanData()
	self:updateRoomInfo(self:getCurrentRankData())
end

function NormalSelectionsCtr:onUpdateDisplayType(displayType)
	self.m_currentDisplayType = displayType
	self:updateDisplay()
	self:updateRoomInfo(self:getCurrentRankData())
end

function NormalSelectionsCtr:onUpdateSortType(sortType)
	self.m_data:setSortType(sortType)
	self:updateRoomInfo(self:getCurrentRankData())
end

function NormalSelectionsCtr:onUpdateFilter( filterArray )
	self.m_data:setFilter(filterArray)
	
	self:updateRoomInfo(self:getCurrentRankData())
end

function NormalSelectionsCtr:onSearchRoom(roomID)
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.SEARCH_ROOM)
    param.tid = roomID
	g_HttpManager:doPost(param, self, self.onRequestSearchRoomSuccess, self.onRequestSearchRoomSuccess);
end

function NormalSelectionsCtr:onRequestSearchRoomSuccess(isSuccess, result)
	g_Progress.getInstance():dismiss()
	if isSuccess and g_TableLib.isTable(result) then
		Log.d('onRequestSearchRoomSuccess',result)
		local info = self.m_data:makeSearchData(result)
		self:updateRoomInfo(info)
    else
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_network_err'))
	end
end

function NormalSelectionsCtr:onRefreshRoom()
	self:requestNormalRoomInfo(self.m_currentRoomRank)
end

function NormalSelectionsCtr:updateDisplay()
	self:updateView(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_DISPLAY,self.m_currentRoomRank, self.m_currentDisplayType)
end

function NormalSelectionsCtr:getCurrentRankData()
	if self.m_currentRoomRank == SceneConfig.roomRankType.highRank then
		return self.m_data:getDataUseFilter(self.m_currentRoomRank)
	else
		return self.m_data:getData(self.m_currentRoomRank)
	end
end

function NormalSelectionsCtr:updateRoomInfo(data)
	if data then
		if self.m_currentDisplayType == SceneConfig.displayType.graph and self.m_currentRoomRank == SceneConfig.roomRankType.highRank then	
			self:updateView(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_GRAPH_INFO,data)
		else
			self:updateView(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_LIST_INFO,data,self.m_currentRoomRank)
		end
	else
		self:requestNormalRoomInfo(self.m_currentRoomRank)
	end
end

function NormalSelectionsCtr:requestNormalRoomInfo(roomRank)
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.NORMAL_ROOM_LIST)
    param.field = roomRank
	g_HttpManager:doPost(param, self, self.onRequestNormalRoomInfoSuccess, self.onRequestNormalRoomInfoFailed);
end

function NormalSelectionsCtr:onRequestNormalRoomInfoSuccess(isSuccess, response)
	g_Progress.getInstance():dismiss()
    if not isSuccess or not g_TableLib.isTable(response) then
        Log.d("LoginFail", GameString.get("str_login_network_err"))
    else
    	self.m_data:updateData(response)
  		self:updateRoomInfo(self:getCurrentRankData())
    end
end

function NormalSelectionsCtr:onRequestNormalRoomInfoFailed()
	print('failed')
end

-- UI触发的逻辑处理
function NormalSelectionsCtr:haldler(status,...)
	if NormalSelectionsCtr.s_controlFuncMap[tonumber(status)] then
		NormalSelectionsCtr.s_controlFuncMap[tonumber(status)](self, ...)
	end
end

function NormalSelectionsCtr:requestQuickStart( )
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.TABLE_QUICKIN)
	g_HttpManager:doPost(param, self, self.onQuickStartResponse)
	g_Progress.getInstance():show()
end

function NormalSelectionsCtr:onQuickStartResponse(isSuccess, data)
	if not isSuccess then
		g_Progress.getInstance():dismiss()
		return
	end
	local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(data)
end

return NormalSelectionsCtr;