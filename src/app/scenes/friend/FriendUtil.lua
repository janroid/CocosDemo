local FriendConfig = require('FriendConfig')
local FriendUtil = {}

function FriendUtil.getFriendStatus(data)
    local friendStatus = FriendConfig.FRIEND_STATUS.Trackable
    local statusText = ""
	if data.status == FriendConfig.STATUS.AT_PLAY then
		 --房间内
		--坐下
		if data.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_NORMAL
			or data.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_PROFESSIONAL then
				local desc = FriendUtil.getFriendStatusDesc(data)
				local smallBlind = g_MoneyUtil.formatMoney(data.smallBlind) .. "/" .. g_MoneyUtil.formatMoney((data.smallBlind * 2));
				statusText = string.format( desc, smallBlind )		
		elseif data.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_TOURNAMENT then
			-- MTT
			statusText = GameString.get("str_friend_track_mtt") .. data.mttname or ""
		elseif data.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_KNOCKOUT then
			--淘汰赛
			statusText = GameString.get("str_friend_track_sng")
            friendStatus = FriendConfig.FRIEND_STATUS.Untrackable
		else
			--其他未知情况
			statusText = data.tableName or ""
			friendStatus = FriendConfig.FRIEND_STATUS.Untrackable
    	end
		if data.isSitdown then
            statusText = statusText .. "  " .. GameString.get('str_friend_trace_status2')
        else
            --旁观中
            statusText = statusText .. "  " .. GameString.get('str_friend_trace_status3')
		end
	elseif data.status == FriendConfig.STATUS.ON_LINE then
		statusText = GameString.get("str_friend_trace_status4")
        friendStatus = FriendConfig.FRIEND_STATUS.Untrackable
	elseif data.status == FriendConfig.STATUS.OFF_LINE or status == nil then
		 --召回 push 0 可以，-1不在xx天内,-2在线,-3次数限制,-5 不是牌友
		 if data.push == 0 then--and data.isPlatFriend == false then   --允许召回且是FB好友（isPlatFriend == false为FB好友 ）
			statusText = string.format( GameString.get('str_friend_friend_popup_callback'), g_MoneyUtil.formatMoney(g_AccountInfo:getCallbackReward()))
            friendStatus = FriendConfig.FRIEND_STATUS.Recallable
		elseif data.push == -3 then
			statusText = string.format( GameString.get('str_friend_friend_popup_callback'),  g_MoneyUtil.formatMoney(g_AccountInfo:getCallbackReward()))
            friendStatus = FriendConfig.FRIEND_STATUS.NotRecallable
        else
            statusText = GameString.get("str_friend_trace_status1");
            friendStatus = FriendConfig.FRIEND_STATUS.Untrackable
        end
    end
    return friendStatus,statusText
end

function FriendUtil.getFriendStatusDesc(data)
    local text = "";
    if data.isPri then
        text = GameString.get('str_friend_user_friend_statue_private')
    else
        if data.tableLevel == 1 then
            text = GameString.get('str_friend_user_friend_statue_primary_level')
        elseif data.tableLevel == 2 then
            text = GameString.get('str_friend_user_friend_statue_primary_level')
        elseif data.tableLevel == 3 then
            text = GameString.get('str_friend_user_friend_statue_middle_level')
        elseif data.tableLevel == 4 then
            text = GameString.get('str_friend_user_friend_statue_high_level')
        else
            text = "%s";
        end
    end
    return text;
end

return FriendUtil