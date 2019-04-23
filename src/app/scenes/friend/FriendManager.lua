-- 用于好友追踪，好友召回
local FriendConfig = require('FriendConfig')
local HttpCmd = import("app.config.config").HttpCmd
local DailyTaskManager = import("app.scenes.dailyTask").DailyTaskManager;
local SeatManager = import("app.scenes.normalRoom").SeatManager:getInstance()
local FriendManager = class("FriendManager")

-- 配置事件监听函数
FriendManager.s_eventFuncMap = {
    [g_SceneEvent.FRIEND_RECALL]            			= "onRecall",
    [g_SceneEvent.FRIEND_GIVE_GIFT]	 	    			= "sendGift",
	[g_SceneEvent.FRIEND_TRACK]             			= "trackToRoom",
	[g_SceneEvent.FRIEND_INVITE_FACEBOOK_FRIENDS]		= "onInviteFBFriends",
	[g_SceneEvent.FRIEND_ADD_FRIEND]					= "addFriend",
}

function FriendManager.getInstance()
    if(FriendManager.s_instance == nil) then
        FriendManager.s_instance = FriendManager:create()
    end
    return FriendManager.s_instance
end

function FriendManager.release()
    FriendManager.s_instance:onCleanup()
    FriendManager.s_instance = nil
end

function FriendManager:ctor()
    self:registerEvent()
end

function FriendManager:onCleanup()
    self:unRegisterEvent()
end

---注册监听事件
function FriendManager:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        assert(self[v],"配置的回调函数不存在")
	        g_EventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function FriendManager:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

-- 召回
function FriendManager:onRecall(uid)
    local url = g_AccountInfo:getCallbackCgiRoot()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_CALLBACKNEW)
	param.fbid = uid
	
    if url ~= nil then        
        g_HttpManager:doPostWithUrl(url, param, 
            self, self.onRecallResp);
    else
        g_HttpManager:doPost(param, 
            self, self.onRecallResp);
    end
end



function FriendManager:onRecallResp(isSuccess,data,param)
	if not isSuccess then
		self:onFaild()
		return;
	end
	
	if data.ret then
		for k,v in pairs(data.ret) do
			if v then
				if v.error == 0 then
					g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_RECALL_SUCCESS,  tonumber(k))
					g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_friend_recall_success'))
					g_StatisticReportTool.reportFriend(g_StatisticReportTool.Friend_Callback,"success")
					
				elseif v.error == -3 then
					g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_friend_recall_repeat'))
					g_StatisticReportTool.reportFriend(g_StatisticReportTool.Friend_Callback,"repeat")
				else
					g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_friend_recall_fail'))
					g_StatisticReportTool.reportFriend(g_StatisticReportTool.Friend_Callback,"fail")
				end
			end
		end
	end
end

function FriendManager:onFaild()
    g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
end


-- 赠送礼物
function FriendManager:sendGift(friend)
	-- 赠送礼物
	local data = {}
	data.friend = friend
	data.type = import("app.scenes.gift").GiftPop.s_showType.SHOW_SEND_GIFT
	g_EventDispatcher:dispatch(g_SceneEvent.OPEN_GIFT_POPUP,data);
	-- Log.e("sendGift", "还未实现呢")
end

--[[

-- 好友追踪 注释部分为原有代码逻辑
function FriendManager:onTrack(friend)
    if g_TableLib.isEmpty(friend) then return end

    if friend.status == FriendConfig.STATUS.AT_PLAY then
        local roomInfo = {}
        roomInfo.tableType = friend.tableType
        if friend.tableType == g_RoomInfo.ROOM_TYPE_NORMAL or
           friend.tableType == g_RoomInfo.ROOM_TYPE_PROFESSIONAL then
           if friend.isPri then
                roomInfo.tid = friend.mtid
                roomInfo.ip = friend.mip
                roomInfo.port = friendmport
                roomInfo.password = ""
                roomInfo.isNoClose = true
                roomInfo.isCode = friend.roomFlag
            else    
                roomInfo.tid = friend.tid
                roomInfo.ip = friend.ip 
                roomInfo.port = friend.port
            end
        elseif friend.tableType == g_RoomInfo.ROOM_TYPE_TOURNAMENT then
            if friend.mttstart == 1 then
                --mtt已开赛，追踪到房间
                roomInfo.tid = friend.tid
                roomInfo.ip = friend.ip 
                roomInfo.port = friend.port
            else
                roomInfo.preMtt = true
                --未开赛，打开mtt详情   
            end
        end
        if not g_RoomInfo:notInRoom() then
            local msg = nil
            if g_RoomInfo:isMatch() then
                msg = GameString.get("str_room_match_room_track_friend_tips2")
            else
                msg = GameString.get("str_room_track_friend_tips")
            end

            local isInGame = SeatManager:selfInGame()
            local roomType = g_RoomInfo:getRoomType()
            if isInGame then --在牌局中
                g_EventDispatcher:dispatch(g_SceneEvent.ROOM_PRE_SWITCH_ROOM,roomInfo)
            elseif g_RoomInfo:getRoomType() == g_RoomInfo.ROOM_TYPE_TOURNAMENT then
                local msg = nil
                if g_RoomInfo:getGameStatus() == 0 then    
                    msg = GameString.get("str_room_match_room_track_friend_tips1")  
                else 
                    msg = GameString.get("str_room_match_room_track_friend_tips3")  
                end
                g_AlertDialog.getInstance()
		        :setTitle("")
		        :setContent(msg)
		        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		        :setLeftBtnTx(GameString.get("str_common_confirm"))
		        :setRightBtnTx(GameString.get("str_common_cancel"))
		        :setCloseBtnVisible(false)
		        :setLeftBtnFunc(
		        function()
			        g_EventDispatcher:dispatch(g_SceneEvent.ROOM_PRE_SWITCH_ROOM,roomInfo)
		        end)
		        :show() 
            elseif g_RoomInfo:getRoomType() == g_RoomInfo.ROOM_TYPE_KNOCKOUT then
                g_AlertDialog.getInstance()
		        :setTitle("")
		        :setContent(GameString.get("str_quit_match_tip"))
		        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		        :setLeftBtnTx(GameString.get("str_common_confirm"))
		        :setRightBtnTx(GameString.get("str_common_cancel"))
		        :setCloseBtnVisible(false)
		        :setLeftBtnFunc(
		        function()
			        g_EventDispatcher:dispatch(g_SceneEvent.ROOM_PRE_SWITCH_ROOM,roomInfo)
		        end)
		        :show() 
            else --非 mtt sng且不在牌局中 
                g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SWITCH_ROOM,roomInfo)               
            end
        else
            self:trackToRoom(roomInfo)
        end
    end
end
]]

function FriendManager:trackToRoom(data)
    local toRoomData = data
    local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(toRoomData)
end

-- FB好友邀请
function FriendManager:onInviteFBFriends()
	local fbInviteReward = (g_AccountInfo:getBlowup() or 1000) * 5000 -- facebook邀请奖励
	local params = {
		['data'] = "byinvite|" .. (g_AccountInfo:getId() or ""),
		['message'] = string.format(GameString.get('str_friend_invite_fb_invite_desc'),fbInviteReward),
	}
	NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_INVITE_FRIEND_FACEBOOK, params, self, self.onFBInviteCallback)
end

function FriendManager:onFBInviteCallback(response)
	-- local response = g_JsonUtil.decode(result)
	-- Log.d("ReneYang", "onFBInviteCallback", result,";",response)
	Log.d("ReneYang", "onFBInviteCallback", response)
	if g_TableLib.isTable(response) and response.result then
		local code = tonumber(response.result)
		local tips = ""
		if code == 1 then -- 成功
			tips = GameString.get('str_friend_invite_success')
            if response.ids then  --上报FB邀请
                local num = g_StringLib.patternCount(response.ids,",") + 1
                DailyTaskManager.getInstance():reportInviteFriend(num)
            end
		elseif code == 2 then -- 失败
			tips = string.format(GameString.get('str_friend_invite_error'), response.error)
		elseif code == 3 then -- 取消
			tips = GameString.get('str_friend_invite_cancel')
		elseif code == 4 then -- 出错
			tips = string.format(GameString.get('str_friend_invite_error'), response.error)
		end
		g_AlarmTips.getInstance():setTextAndShow(tips)
	end
end

function FriendManager:addFriend(uid)
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_ADD)
	param.fuid = uid
	g_HttpManager:doPost(param, self, self.onAddFriendResponse)
end

function FriendManager:onAddFriendResponse(isSuccess, data,param)
	if data ~= nil and tostring(data) == "1" then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_friend_add_friend_success'))
		local list = g_Model:getData(g_ModelCmd.FRIEND_UID_LIST) or {}
		table.insert(list, tostring(param.fuid))
		g_Model:setData(g_ModelCmd.FRIEND_UID_LIST,list)
    end
end

return FriendManager