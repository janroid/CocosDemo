--[[--ldoc desc
@module SngLobbyCtr
@author %s
Date   %s
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SngLobbyCtr = class("SngLobbyCtr",ViewCtr);
local SngLobbyData = require("SngLobbyData")
BehaviorExtend(SngLobbyCtr);

---配置事件监听函数
SngLobbyCtr.s_eventFuncMap =  {
		[g_SceneEvent.SNG_LOBBY_REFRESH_DATA]			= "refreshSngList",
		[g_SceneEvent.GET_SNG_MTT_REFRESH] 				= "refreshSngPrizeData",
		[g_SceneEvent.SNG_LOGIN_TO_ROOM] 				= "onSngLoginToRoom",
		[g_SceneEvent.SNG_REQ_USER_INFO_DATA] 			= "requestUserInfo",
		
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见ViewCtr.updateView函数
}

function SngLobbyCtr:ctor(view)
	ViewCtr.ctor(self);
	self.m_view = view

end


function SngLobbyCtr:requestUserInfo()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_MAIN)
	g_HttpManager:doPost(params,self,self.onUserInfoCallBack)
end

function SngLobbyCtr:onUserInfoCallBack(isSuccess, data)
	Log.d("UserInfoCtr:onUserInfoCallBack",isSuccess,data)
	if isSuccess and next(data) ~= nil then
		if data and not g_TableLib.isEmpty(data) then
			if tonumber(data.money) then
				g_AccountInfo:setMoney(data.money)
			end

			if tonumber(data.exp) then
				g_AccountInfo:setUserExp(data.exp)
			end
		end
        g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_INFO_SUCCESS,data)
    else
        Log.e("UserInfoCtr:onUserInfoCallBack", "decode json has an error occurred!");
    end
end


function SngLobbyCtr:refreshSngList()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.REQUEST_SNG_LIST)
	SngLobbyData:setIsLoading(true);
	g_HttpManager:doPost(params,self, self.onSngListDataResponse)
end

function SngLobbyCtr:onSngListDataResponse(isSuccess,data)
	if not isSuccess then 
		Log.e("SngLobbyCtr:onSngListDataResponse failed")
		return 
	end

	if data ==  "0" then 
		SngLobbyData:setSngListData({["tab"] = SngLobbyData.MATCH_NOT_FOUND})
	else
        if g_TableLib.isEmpty(data) then
            SngLobbyData:setSngListData({["tab"] = SngLobbyData.MATCH_NOT_FOUND});
            return;
		end
		
        local sngData = data.sng;

        if(sngData ~= nil) then
    		local listLength = #sngData;
    		local sngList = {};
            for i=1,listLength do
    			sngList[i] = SngLobbyData:parseData(sngData[i]);
    		end
    		-- self.m_knockoutHallData:storeData(sngList, MatchHallData.VALID_TIME);
    		SngLobbyData:setSngListData({["tab"] = SngLobbyData.MATCH_SNG, ["data"] = sngList});
        end
    end 
end

function SngLobbyCtr:refreshSngPrizeData(type)
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.GET_SNG_OR_MTT_RANK)
	params.type = type
	g_HttpManager:doPost(params,self, self.onSngPrizeDataResponse)
end

function SngLobbyCtr:onSngPrizeDataResponse(isSuccess,data)
	if not isSuccess or g_TableLib.isEmpty(data) then
		Log.e("SngLobbyCtr:onSngPrizeDataResponse failed")
		return 
	end

	local prizeData = SngLobbyData:parseXML(data)
	g_Model:setData(g_ModelCmd.SNG_MTT_DATA,prizeData)
end

function SngLobbyCtr:onSngLoginToRoom(data)
	Log.d(data)
	g_RoomInfo:setRoomIp(data.roomInfo.m_ip)
	g_RoomInfo:setRoomPort(data.roomInfo.m_port)
	g_RoomInfo:setTid(0)
	local SNGRoomScene = import('app.scenes.sngRoom').SNGRoomScene 
	cc.Director:getInstance():pushScene(SNGRoomScene:create())


	-- local requestLoginData = {}
	-- requestLoginData.tid = data.roomInfo.tid
	-- requestLoginData.ip = data.roomInfo.ip
	-- requestLoginData.port = data.roomInfo.port
	-- requestLoginData.password = data.roomInfo.password
	-- if data.roomInfo.roomStyle ~= nil then
	-- 	requestLoginData.roomStyle = data.roomInfo.roomStyle
	-- end
	
	-- requestLoginData.uid = g_AccountInfo:getId()
	-- requestLoginData.mtkey = g_AccountInfo:getmtkey()
	-- requestLoginData.imgUrl = g_AccountInfo:getBigPic()
	-- requestLoginData.giftId = g_AccountInfo:getUserUseGiftId()
end

function SngLobbyCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用ViewCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	ViewCtr.onCleanup(self);
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
		不用可删除
	]]

end



return SngLobbyCtr;