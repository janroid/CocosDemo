--[[
    author:{JanRoid}
    time:2018-12-10
    Description: socket连接管理
]]

local RoomSocket = require("roomSocket.RoomSocket")

local RoomSocketManager = class("RoomSocketManager")

function RoomSocketManager:ctor()
	self.m_socket = RoomSocket:create()
	self.m_socket:setReceiveHandler(self, self.onReceiveMsg)
	self.m_socket:setHeartbeatCMD(g_SocketCmd.RoomSocketCMD.CMD_HEART_BEAT)
end

function RoomSocketManager:dtor()

end

function RoomSocketManager:cmdPrint(cmd)
	if g_SocketCmd.RoomSocketMap[cmd] ~= nil then
		Log.i("RoomSocketManager", string.format("0x%02x", cmd), " :", g_SocketCmd.RoomSocketMap[cmd]);
	else
		Log.d("RoomSocketManager", string.format("cmd=0x%x", cmd));
	end
end

function RoomSocketManager:onReceiveMsg(cmd)
	self:cmdPrint(cmd)
	if cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_LOGIN_SUCC then
		self:onLoginSuccess()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_LOGIN_FAIL then
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_LOGIN_FAIL, self.m_socket:readShort())
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_EXTRA_LOGIN_INFO then
		self:extraLoginInfo()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_RELOGIN_SUCC then
		self:onLoginSuccess()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_LOGOUT_SUCCESS then
		self:onLogoutSuccess()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SITDOWN then
		self:broadcastSitDown()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_STAND then
		self:broadcastStandUp()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_SITEDOWN_FAIL then
		g_Model:setData(g_ModelCmd.ROOM_SIT_FAIL_DATA, self.m_socket:readShort());
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_GAME_START then
		self:gameStart()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_BET_TURN_TO then
		self:turnToBet()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_BET_SUCC then
		self:broadcastOperation()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_CARD_FLOP then
		self:saveCard("FLOP")
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_CARD_TURN then
		self:saveCard("TURN")
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_CARD_RIVER then
		self:saveCard("RIVER")
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_CHIPS_POTS then
		self:broadcastPots()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_CHATMSG_NEW then
		self:broadcastChatData()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_EMOTION then
		self:broadcastEmotion()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_GAME_OVER then
		self:gameOverNormal()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_SEND_CHIPS_FAIL then
		self:sendChipsFail()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SEND_CHIPS then
		self:sendChipsSuccess()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SEND_HD then
		self:broadcastSendHD();
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SEND_GIFT then
		self:sendGiftSuccess();
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_ADD_FRIEND then
		self:broadcastAddFriend();
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_TABLE_OWNER then
		self:privateOwnerChange()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_BROADCAST_OWNER_LEAVE then
		self:privateOwnerLeave()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_PRIVATE_LOGOUT_SUCC then
		self:privateLogoutSuccess()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_SEND_DEALER_CHIP_SUCC then
		self:sendDealerChipsSucc()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_SEND_DEALER_CHIP_FAIL then
		self:sendDealerChipsFail()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_BUY_LOTTO_SUCCEED then
		self:buyLottoSucceed();
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_BUY_LOTTO_FAIL then
		self:buyLottoFail();
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SHOW_HAND_CARD then
		self:broadcastShowHand();
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_ALLIN then
		g_Model:setData(g_ModelCmd.ROOM_ALL_IN_DATA, true)
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_KICK_OUT then
		self:kickOutFromRoom()
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_USER_CRASH then
        self:userCrash();
	--广播：用户暂离（目前仅限比赛场）
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_LEAVE_SEAT then
		self:broadcastLeaveSeat();
		
 --********** 淘汰赛 ************/
    --广播比赛开始
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_START_K then
        g_Model:setData(g_ModelCmd.ROOM_MATCH_START, true);
                
    --广播比赛结束
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_END_K then
        g_Model:setData(g_ModelCmd.ROOM_MATCH_END, true);
                
    --广播比赛关闭
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_CLOSE_K then
        g_Model:setData(g_ModelCmd.ROOM_MATCH_CLOSE, true);
                
    --广播比赛桌子id
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_TABLE_ID_K then
        self:broadcastTableId();
                
    --广播所有名次
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_ALL_RANKING_K then
                
    --盲注变化
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_BLIND_CHANGE_K then
        g_Model:setData(g_ModelCmd.ROOM_BLIND_CHANGE, self.m_socket:readInt64());
                
    --用户排名
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_USER_RANKING_K then
        self:userRankingK();
                
    --比赛出局
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_USER_OUT_K then
        self:userOutK();
                
    --比赛信息
    elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_MATCH_INFO_K then
        self:matchInfoK();
 --********** 淘汰赛 ************/

		--********** 锦标赛 ************/
		--广播比赛开始
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_START_T then
		g_Model:setData(g_ModelCmd.ROOM_MATCH_START, true);
		
		--广播比赛开始时间戳
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_TIME_T then
		g_Model:setData(g_ModelCmd.ROOM_MATCH_START_TIME_T, self.m_socket:readInt64());
		
		--广播比赛剩余开始时间
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_COUNT_DOWN_TIME_T then
		g_Model:setData(g_ModelCmd.ROOM_COUNT_DOWN_TIME_T, self.m_socket:readInt64());
		
		--广播盲注变化
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_BLIND_CHANGE_T then
		local smallBlind = self.m_socket:readInt64();
		local raiseBlindCD = self.m_socket:readInt();
		g_Model:setData(g_ModelCmd.ROOM_BLIND_CHANGE, smallBlind);
		g_Model:setData(g_ModelCmd.NEW_MTT_RAISE_BLIND_CD, raiseBlindCD);
		
		--广播正在换桌
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SWITCH_TABLE_T then
		-- g_AlarmTips.getInstance():setText(GameString.get("str_hall_tournament_switch_table_tip")):show()
		
		--广播换桌成功
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_SWITCH_TABLE_SUCC_T then
		
		--广播用户排名
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_USER_RANKING_T then
		self:userRankingT();
		
		--广播桌子ID
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_TABLE_ID_T then
		--03 显示用 未显示
		self:setTid();
		
		--广播用户出局
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_CMD_USER_OUT_T then
		self:userOutT();
		
		--广播比赛结束
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_END_T then
		g_Model:setData(g_ModelCmd.ROOM_MATCH_END, true);
		
		--广播比赛关闭
	elseif cmd == g_SocketCmd.RoomSocketCMD.SVR_BCCMD_MATCH_CLOSE_T then
		g_Model:setData(g_ModelCmd.ROOM_MATCH_CLOSE, true);
		
		--SVR通知用户是否Rebuy
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_USER_REBUY then
		-- 01
		self:mactchUserRebuy();
		
		--SVR广播有用户正在Rebuy  --显示等待弹窗
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_BROADCAST_REBUY then
		self:matchBroadcastRebuy();
		
		--SVR服务端响应Rebuy，成功包，对所有用户发?
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_BROADCAST_REBUY_SUCESS then
		self:rebuyOrSucc();
		
		--SVR服务端响应Rebuy，所有rebuy完成
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_BROADCAST_ALL_REBUY_END then
		self:allRebuyEnd();
		
		--SVR服务端维护奖池排名盲注等信息
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_USER_PRIZE_RANK_INFO then
		self:rankPrizeInfo();
		
		--SVR通知用户是否Addon
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_USER_ADDON then
		--02
		self:matchRoomAddon();
		
		--SVR广播Addon成功
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_BROADCAST_USER_ADDON_SUCESS then
		self:rebuyOrSucc();
		
		--SVR广播Addon失败 或者Rebuy失败
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_USER_ADDON_REBUY_FAILD then
		self:rebuyAddonFaild();
	
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_MATCH_NOT_START then
		self:matchNotStart();
	
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_SEND_MID then
		self:setMid();
	
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_COMMAND_ANT_OVER then
		self:antEnd();
	
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_APPLY_REWARD_NUM then
		self:updateApplyAndRewardNum();
	
	elseif cmd == g_SocketCmd.RoomSocketCMD.SERVER_CMD_TRACE_FRIEND then
		local uid = self.m_socket:readInt();
		g_Model:setData(g_ModelCmd.TRACE_FRIEND, uid);
		Log.d("traceFriend,id:", uid)
--		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SWITCH_ROOM)
		--********** 锦标赛 ************/
	end
end

function RoomSocketManager:broadcastShowHand()
	local data = {}
	data.seatId = self.m_socket:readByte() + 1
	data.handCard1 = self.m_socket:readShort()
	data.handCard2 = self.m_socket:readShort()
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SHOW_HAND, data)
end

function RoomSocketManager:onLogoutSuccess()
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_LOGOUT_SUCCESS)
end

function RoomSocketManager:onLoginSuccess()
	local roomData = g_RoomInfo
	roomData:setSmallBlind(self.m_socket:readInt64())               --小盲注
	roomData:setMinBuyIn(self.m_socket:readInt64())               --最小买入
	roomData:setMaxBuyIn(self.m_socket:readInt64())               --最大买入
	roomData:setTableName(self.m_socket:readString())              --桌子名字
	roomData:setRoomType(self.m_socket:readInt())                 --房间场别
	roomData:setTableLevel(self.m_socket:readInt())                 --房间级别
	roomData:setUserChips(self.m_socket:readInt64())               --用户钱数
	roomData:setBetInExpire(self.m_socket:readInt() - 1)                 --下注最大时间
	roomData:setGameStatus(self.m_socket:readByte())                --游戏状态
	roomData:setMaxSeatCount(self.m_socket:readByte())                --最大座位数量
	roomData:setRoundCount(self.m_socket:readInt())                 --游戏局数
	roomData:setDealerSeatId(self.m_socket:readByte() + 1)            --庄家座位
	roomData:setChipsPotsCount(self.m_socket:readByte())                --奖池数量
	
	local chipsPots = {};--奖池信息
	for i = 1, roomData:getChipsPotsCount() do
		chipsPots[i] = self.m_socket:readInt64();
	end
	roomData:setChipsPots(chipsPots)
	
	local publicCards = {}
	local gameStatus = roomData:getGameStatus()
	if gameStatus >= g_RoomInfo.GAME_STATE_FLOP_ROUND and
			gameStatus <= g_RoomInfo.GAME_STATE_RIVER_ROUND then
		--gameStatus介于2（FLOP_ROUND）与4（RIVER_ROUND）之间，所以此处需加1
		local arrLen = gameStatus + 1;
		for i = 1, arrLen do
			publicCards[i] = self.m_socket:readShort();
		end
	end
	roomData:setPublicCards(publicCards)
	
	local betInSeatId = self.m_socket:readByte();--目前正在下注的座位
	roomData:setBetInSeatId(betInSeatId + 1)
	if betInSeatId ~= -1 then
		roomData:setCallNeedChips(self.m_socket:readInt64())--跟注需要钱数
		roomData:setMinRaiseChips(self.m_socket:readInt64())--加注最小钱数
		roomData:setMaxRaiseChips(self.m_socket:readInt64())--加注最大钱数
	end
	
	roomData:setPlayerCount(self.m_socket:readByte())     --玩家数量(坐下)
	
	--每个用户的信息
	local playerList = {}
	local playerCount = roomData:getPlayerCount()
	for i = 1, playerCount do
		local tableUserData = {}
		tableUserData.seatId = self.m_socket:readByte() + 1;--座位id (lua下标从1开始)
		tableUserData.uid = self.m_socket:readInt();        --用户id
		tableUserData.totalChips = self.m_socket:readInt64();    --用户钱数
		tableUserData.exp = self.m_socket:readInt();        --用户经验
		tableUserData.vip = self.m_socket:readByte();    --VIP标识
		tableUserData.name = self.m_socket:readStringEx();    --用户名
		tableUserData.gender = self.m_socket:readString();    --性别
		tableUserData.photoUrl = self.m_socket:readString();    --用户图片url
		tableUserData.winRound = self.m_socket:readInt();        --用户赢盘数
		tableUserData.loseRound = self.m_socket:readInt();        --用户输盘数
		tableUserData.currentPlace = self.m_socket:readString();    --用户所在地
		tableUserData.homeTown = self.m_socket:readString();    --用户家乡
		tableUserData.giftId = self.m_socket:readInt();        --用户默认道具
		tableUserData.seatChips = self.m_socket:readInt64();    --座位的钱数
		tableUserData.betInChips = self.m_socket:readInt64();    --座位的总下注数
		tableUserData.operationStatus = self.m_socket:readByte();    --当前操作类型
		playerList[tableUserData.seatId] = tableUserData;
	end
	roomData:setPlayerList(playerList)
	
	--是否有手牌
	local handCard = {}
	local handCardFlag = self.m_socket:readByte();
	if handCardFlag == 1 then
		handCard[1] = (self.m_socket:readShort());
		handCard[2] = (self.m_socket:readShort());
	end
	roomData:setHandCardFlag(handCardFlag)
	roomData:setHandCard(handCard)
	
	-- 2013-1-14 srv升级协议,增加平台标示和房间flag */
	local platFlags = {};
	for i = 1, 9 do
		platFlags[i] = self.m_socket:readInt();
	end
	for _, player in ipairs(playerList) do
		player.platFlag = platFlags[player.seatId];
	end
	roomData:setFlag(self.m_socket:readInt())
	
	local playerAnte = self.m_socket:readInt64();    -- 该轮下的前注
	for _, player in ipairs(playerList) do
		player.ante = playerAnte;
	end
	
	g_Model:setData(g_ModelCmd.ROOM_DATA, roomData)
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_LOGIN_SUCCESS)
end

function RoomSocketManager:extraLoginInfo()
	local extraLoginInfo = {}
	extraLoginInfo.currentDealer = self.m_socket:readInt();
	extraLoginInfo.userDealer = self.m_socket:readInt();
	extraLoginInfo.setDealer = self.m_socket:readInt();
	extraLoginInfo.dealerName = self.m_socket:readString();
	extraLoginInfo.dealerCharge = self.m_socket:readInt64();
	extraLoginInfo.autoBuyLotto = self.m_socket:readInt();
	extraLoginInfo.buyNextLotto = self.m_socket:readInt();
	
	extraLoginInfo.lottoPrice = self.m_socket:readInt64();
	extraLoginInfo.royalFlushScale = self.m_socket:readByte();
	extraLoginInfo.straightFlushScale = self.m_socket:readByte();
	extraLoginInfo.fourKindScale = self.m_socket:readByte();
	
	g_Model:setData(g_ModelCmd.ROOM_EXTRA_LOGIN_INFO, extraLoginInfo);
	Log.d("RoomSocketManager:extraLoginInfo", extraLoginInfo)
end

--广播用户坐下
function RoomSocketManager:broadcastSitDown()
	local userData = {}
	userData.seatId = self.m_socket:readByte() + 1;
	userData.uid = self.m_socket:readInt();
	userData.name = self.m_socket:readStringEx();
	userData.gender = self.m_socket:readString();
	userData.totalChips = self.m_socket:readInt64();
	userData.exp = self.m_socket:readInt();
	userData.vip = self.m_socket:readByte();
	userData.photoUrl = self.m_socket:readString();
	userData.winRound = self.m_socket:readInt();
	userData.loseRound = self.m_socket:readInt();
	userData.currentPlace = self.m_socket:readString();
	userData.homeTown = self.m_socket:readString();
	userData.giftId = self.m_socket:readInt();
	userData.seatChips = self.m_socket:readInt64();
	
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_USER_SIT_DOWN, userData);
	Log.d("broadcastSitDown", userData.uid, userData.photoUrl)
end

--广播用户站起
function RoomSocketManager:broadcastStandUp()
	local standUpData = {}
	standUpData.seatId = self.m_socket:readByte() + 1;
	standUpData.userChips = self.m_socket:readInt64();
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_USER_STAND_UP, standUpData);
	Log.d("broadcastStandUp", standUpData)
end

function RoomSocketManager:gameStart()
	local roomData = g_RoomInfo
	roomData:setRoundCount(self.m_socket:readInt())          --当前局数
	roomData:setDealerSeatId(self.m_socket:readByte() + 1)     --庄家座位
	roomData:setPlayerCount(self.m_socket:readByte())         --在玩人数
	
	--座位上玩家的信息
	for i = 1, roomData:getPlayerCount() do
		local seatId = self.m_socket:readByte() + 1 --Lua下标从1开始
		local player = roomData:getPlayerList()[seatId]
		player.uid = self.m_socket:readInt()
		player.seatChips = self.m_socket:readInt64()
		if player.uid == g_AccountInfo:getId() then
			roomData:setUserChips(player.seatChips)
		end
		player.lastBetChips = 0
		player.betInChips = 0
	end
	local handCard = {}
	handCard[1] = self.m_socket:readShort()
	handCard[2] = self.m_socket:readShort()
	local userChips = self.m_socket:readInt64()
	g_AccountInfo:setMoney(userChips)
	
	roomData:setHandCard(handCard)
	roomData:setPublicCards({})
	
	g_Model:setData(g_ModelCmd.ROOM_DATA, roomData)
    g_Model:setData(g_ModelCmd.ROOM_GAME_START_DATA,1);--现在房间数据均保存在roominfo中，无需额外保存
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_GAME_START, roomData)
	Log.d("RoomSocketManager:gameStart", userChips)
end

function RoomSocketManager:turnToBet()
	local data = g_RoomInfo
	data:setBetInSeatId(self.m_socket:readByte() + 1)
	data:setCallNeedChips(self.m_socket:readInt64())
	data:setMinRaiseChips(self.m_socket:readInt64())
	data:setMaxRaiseChips(self.m_socket:readInt64())
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_TURN_TO_OPERATE, data)
end

function RoomSocketManager:broadcastOperation()
	local seatId = self.m_socket:readByte() + 1
	local player = g_RoomInfo:getPlayerList()[seatId]
	player.operationStatus = self.m_socket:readByte()
	player.lastBetChips = player.betInChips or 0
	player.betInChips = self.m_socket:readInt64()
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_OPERATE_SUCCESS, player)
	Log.i("RoomSocketManager:broadcastBetSuccess", player.operationStatus, player.betInChips, player.lastBetChips)
end

function RoomSocketManager:saveCard(types)
	local publicCards = {}
	if "FLOP" == types then
		publicCards[1] = self.m_socket:readShort()
		publicCards[2] = self.m_socket:readShort()
		publicCards[3] = self.m_socket:readShort()
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_PUBLIC_CARD_FLOP, publicCards)
	elseif "TURN" == types then
		publicCards[4] = self.m_socket:readShort()
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_PUBLIC_CARD_TURN, publicCards)
	elseif "RIVER" == types then
		publicCards[5] = self.m_socket:readShort()
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_PUBLIC_CARD_RIVER, publicCards)
	end
	g_TableLib.deepMerge(g_RoomInfo:getPublicCards(), publicCards)
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_REQ_CARD_CALCULATE) -- req成牌概率
end

function RoomSocketManager:broadcastPots()
	local roomData = g_RoomInfo
	local chipsPotsCount = self.m_socket:readByte()
	local chipsPots = {}
	for i = 1, chipsPotsCount do
		chipsPots[i] = self.m_socket:readInt64();
	end
	roomData:setChipsPotsCount(chipsPotsCount)
	roomData:setChipsPots(chipsPots)
	
	for _, data in pairs(g_RoomInfo:getPlayerList()) do
		data.lastBetChips = 0
		data.betInChips = 0
	end
	Log.d("RoomSocketManager:broadcastPots", chipsPots)
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_POTS_INFO, chipsPots)
end

function RoomSocketManager:gameOverNormal()
	local gameOverData = {}
	gameOverData.expChange = {}
	gameOverData.chips = {}
	for i = 1, 9 do
		local SeatManager =import("app.scenes.normalRoom").SeatManager
		local selfSeatId = SeatManager:getInstance():getSelfSeatId()
		local expChange = self.m_socket:readInt()
		local chips = self.m_socket:readInt64()
		gameOverData.expChange[i] = expChange;--按seatId存入
		gameOverData.chips[i] = chips;--按seatId存入
		if selfSeatId == i then  -- 更新用户的游戏币和经验值
			local userExp = tonumber(g_AccountInfo:getUserExp())  
			g_AccountInfo:setUserExp(userExp+tonumber(expChange))
			g_AccountInfo:setMoney(chips)
		end
	end
	gameOverData.playerCount = self.m_socket:readByte();
	gameOverData.playerList = {};
	
	for i = 1, gameOverData.playerCount do
		local seatId = self.m_socket:readByte() + 1
		gameOverData.playerList[seatId] = {
			["seatId"] = seatId,
			["handCard1"] = self.m_socket:readShort(),
			["handCard2"] = self.m_socket:readShort(),
			["cardType"] = self.m_socket:readByte()
		};
	end
	
	gameOverData.chipsPotsCount = self.m_socket:readByte();
	gameOverData.chipsPotsInfo = {};
	gameOverData.winners = {}
	
	for i = 1, gameOverData.chipsPotsCount do
		local winNumbers = self.m_socket:readByte();
		local winMoney = self.m_socket:readInt64()
		local perMoney = self.m_socket:readInt64()
		local winnersInfo = {};
		
		for n = 1, winNumbers do
			local winnerObj = {};
			winnerObj.seatId = self.m_socket:readByte() + 1;
			winnerObj.uid = self.m_socket:readInt();
			winnerObj.cardType = self.m_socket:readByte();
			winnerObj.card1 = self.m_socket:readShort();
			winnerObj.card2 = self.m_socket:readShort();
			winnerObj.card3 = self.m_socket:readShort();
			winnerObj.card4 = self.m_socket:readShort();
			winnerObj.card5 = self.m_socket:readShort();
			local player = gameOverData.playerList[winnerObj.seatId]
			if player then
				winnerObj.handCard1 = player.handCard1
				winnerObj.handCard2 = player.handCard2
			end
			winnersInfo[n] = winnerObj;
			gameOverData.winners[#gameOverData.winners + 1] = winnerObj.uid
			
			local win = perMoney - g_RoomInfo:getAllBet()
			if not g_RoomInfo:isMatch() and winnerObj.uid == g_AccountInfo:getId() and win > g_AccountInfo:getMaxAward() then
				local param = HttpCmd:getMethod(HttpCmd.s_cmds.ROOM_UPLOAD_BEST_CARDTYPE)
				param.maxaward = win
				g_HttpManager:doPost(param, nil, nil);
				g_AccountInfo:setMaxAward(win)
			end
		end
		gameOverData.chipsPotsInfo[i] = { ["winNumbers"] = winNumbers, ["winMoney"] = winMoney, ["perMoney"] = perMoney, ["winner"] = winnersInfo };
	end
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_GAME_OVER_DATA, gameOverData)
end

function RoomSocketManager:sendChipsFail()
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_CHIPS_FAIL, self.m_socket:readShort())
end

function RoomSocketManager:sendChipsSuccess()
	local param = {}
	param.senderSeatId = self.m_socket:readByte() + 1;
	param.sendChips = self.m_socket:readInt64();
	param.recieverSeatId = self.m_socket:readByte() + 1;
	
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_CHIPS_SUCC, param)
end

function RoomSocketManager:sendGiftSuccess()
	local param = {}
	param.sendSeatId = self.m_socket:readByte() + 1;
	param.giftId = self.m_socket:readInt();
	local count = self.m_socket:readByte();
	param.userArr = {};
	for i = 1, count do
		param.userArr[i] = {};
		param.userArr[i].seatId = self.m_socket:readByte() + 1;
		param.userArr[i].seatUid = self.m_socket:readInt();
	end
	g_EventDispatcher:dispatch(g_SceneEvent.GIFT_SEND_GIFT_SUCC, param)
end

--广播使用互动道具		 
-- BIG_HDDJ_ID  = 100000; 这个测试用的?
RoomSocketManager.broadcastSendHD = function(self)
	local param = {}
	param.sendSeatId = self.m_socket:readByte() + 1;
	param.hddjId = self.m_socket:readInt();
	param.receiveSeatId = self.m_socket:readByte() + 1;
	param.uid = self.m_socket:readInt();
	
	if param.hddjId == 100000 then
	elseif import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeatId() ~= param.sendSeatId then
		g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC, param)
	end
end

--广播加为好友	 
RoomSocketManager.broadcastAddFriend = function(self)
	local param = {}
	param.sendSeatId = self.m_socket:readByte() + 1;
	param.receiveSeatId = self.m_socket:readByte() + 1;
	
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFO_PLAY_ADD_FRIEND_ANIM, param)
end

function RoomSocketManager:broadcastChatData()
	local chatData = {}
	chatData.messageType = self.m_socket:readShort();-- message type
	chatData.senderTid = self.m_socket:readInt();--sender tid
	chatData.receiverTid = self.m_socket:readInt();--receiver tid
	chatData.senderUid = self.m_socket:readInt();
	chatData.senderName = self.m_socket:readStringEx();
	chatData.receiverUid = self.m_socket:readInt();
	chatData.receiverName = self.m_socket:readStringEx();
	chatData.message = self.m_socket:readStringEx();
	Log.d("broadcastChatData data = ",chatData)
	if (chatData.messageType == 0) then
		g_Model:setData(g_ModelCmd.ROOM_CHAT_DATA, chatData);
	end
end

function RoomSocketManager:broadcastEmotion()
	local emotionData = {}
	emotionData.seatId = self.m_socket:readByte() + 1;
	emotionData.expressionType = self.m_socket:readInt();
	emotionData.expressionId = self.m_socket:readInt();
	emotionData.minusMoney = self.m_socket:readInt64();
	emotionData.totalMoney = self.m_socket:readInt64();
	
	g_Model:setData(g_ModelCmd.ROOM_EXPRESSION_DATA, emotionData);
end


--***************************** 锦标赛 starFt ********************************\
--设置排名
function RoomSocketManager:userRankingT()
	if self.m_userRankingData == nil then
		self.m_userRankingData = import('app.scenes.mttRoom').UserRankingData:create()
	end
	self.m_userRankingData.count = self.m_socket:readInt();--当前人数
	self.m_userRankingData.ranking = self.m_socket:readInt();--当前排名
	self.m_userRankingData.selfChip = self.m_socket:readInt64();--当前剩余筹码
	self.m_userRankingData.differChip = self.m_socket:readInt64();--与前一名的差距
	
	g_Model:setData(g_ModelCmd.ROOM_MATCH_RANKING, self.m_userRankingData);
end

--收到暂离
function RoomSocketManager:broadcastLeaveSeat()
    local obj   =  {};
    obj.seatId  = self.m_socket:readByte(packetId) + 1;
    obj.time    = self.m_socket:readInt(packetId);
    g_Model:setData(g_ModelCmd.ROOM_LEAVE_SEAT_DATA, obj);
end

--请求回到座位
function RoomSocketManager:requestBackSeat()
	Log.d("RoomSocketManager:requestBackSeat")
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_BACK_SEAT)
end

--用户出局
function RoomSocketManager:userOutT()
	self.m_matchUserOutData = import('app.scenes.normalRoom').MatchUserOutData:create()
	
	self.m_matchUserOutData:refresh();
	self.m_matchUserOutData.ranking = self.m_socket:readInt();
	self.m_matchUserOutData.chip = self.m_socket:readInt64();
	self.m_matchUserOutData.exp = self.m_socket:readInt();
	self.m_matchUserOutData.coalaa = self.m_socket:readInt();
	self.m_matchUserOutData.reward = self.m_socket:readString();
	self.m_matchUserOutData.score = self.m_socket:readInt();
	
	self.m_matchUserOutData.allocation = self.m_socket:readInt();
	self.m_matchUserOutData.isReward = self.m_socket:readInt();

	-- Log.d('RoomSocketManager----------', self.m_matchUserOutData)
	
	-- this data need add php request result
	g_Model:setData(g_ModelCmd.ROOM_USER_OUT_T, self.m_matchUserOutData);
end

function RoomSocketManager:setTid()
	local tableID = self.m_socket:readInt();
	g_RoomInfo:setTid(tableID)
	g_Model:setData(g_ModelCmd.NEW_MTT_TABLE_ID, tableID);
end

function RoomSocketManager:matchNotStart()
	local reasonType = self.m_socket:readInt();
	g_EventDispatcher:dispatch(g_SceneEvent.SHOW_MATCH_NOT_START_TIPS, reasonType);
end

function RoomSocketManager:setMid()
	local mid = self.m_socket:readInt();
	g_RoomInfo:setMid(mid)
	g_Model:setData(g_ModelCmd.NEW_MTT_MID, mid);
end

function RoomSocketManager:antEnd()
	g_Model:setData(g_ModelCmd.NEW_MTT_ANT_END, true);
end

function RoomSocketManager:updateApplyAndRewardNum()
	local obj = {};
	obj.rewardNum = self.m_socket:readInt();
	obj.applyNum = self.m_socket:readInt();
	g_Model:setData(g_ModelCmd.NEW_MTT_APPLY_AND_REWAED_INFO, obj);
end
--[[
    比赛房间内奖池排名等信息
    cmd         0x7015
    int      人数
    int      名次
    int64    当前总奖池
    int64    前注
    int      涨盲时间
    int64    小盲
	int64    涨盲倒计时间
--]]
function RoomSocketManager:rankPrizeInfo()
	local obj = {};
	obj.pnum = self.m_socket:readInt();
	obj.rank = self.m_socket:readInt();
	obj.prize = self.m_socket:readInt64();
	obj.ante = self.m_socket:readInt64();
	obj.uptime = self.m_socket:readInt();
	obj.sblind = self.m_socket:readInt64();
	obj.leftTime = self.m_socket:readInt64();--倒计时--2017.7.28z增加的
	g_Model:setData(g_ModelCmd.NEW_MTT_ROOM_MATCH_INFO, obj);
end

--srv提示用户可以rebuy
function RoomSocketManager:mactchUserRebuy()
	--[[
		int			当前排名
		int			总报名人数
		int64		当前奖池
		int			Rebuy的总次数
		int			Rebuy的剩余次数
		int         Rebuy的单位
		int64		Rebuy需要支付的金钱
		int64		Rebuy能换取的筹码
		int			Rebuy倒计时
	--]]
	local obj = {};
	obj.currentRank = self.m_socket:readInt();  --当前排名
	obj.currentNum = self.m_socket:readInt();
	obj.curentPrize = self.m_socket:readInt64();
	obj.rebuyTotolTime = self.m_socket:readInt();
	obj.rebuyRemainTime = self.m_socket:readInt();
	obj.chipOrGlod = self.m_socket:readInt();
	obj.rebuyCost = self.m_socket:readInt64();
	obj.rebuyGetChips = self.m_socket:readInt64();
	obj.rebuyTime = self.m_socket:readInt();
	g_Model:setData(g_ModelCmd.NEW_MTT_CAN_REBUY, obj);
end

--广播有人正在rebuy
function RoomSocketManager:matchBroadcastRebuy()
	local cdTime = self.m_socket:readInt(); --倒计时（秒）
	g_EventDispatcher:dispatch(g_SceneEvent.SHOW_REBUYING_TIPS, cdTime);
end

--rebuy或者addon成功
function RoomSocketManager:rebuyOrSucc()
	local obj = {};
	local userMoney;
	local userCoalaa;
	
	obj.seatId = self.m_socket:readInt() + 1;
	obj.chips = self.m_socket:readInt64();
	obj.addChips = self.m_socket:readInt64();
	
	obj.userMoney = self.m_socket:readInt64();
	obj.userCoalaa = self.m_socket:readInt64();
	
	g_Model:setData(g_ModelCmd.NEW_MTT_REBUY_ORADDON_SUCC_INFO, obj);
end

--所有的rebuy结束
function RoomSocketManager:allRebuyEnd()
	g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_REBUY);
	g_EventDispatcher:dispatch(g_SceneEvent.HIDDEN_REBUYING_TIPS)
end

function RoomSocketManager:matchRoomAddon()
	
	local obj = {};
	obj.currentRank = self.m_socket:readInt();
	obj.currentNum = self.m_socket:readInt();
	obj.curentPrize = self.m_socket:readInt64();
	obj.chipOrGlod = self.m_socket:readInt();--Addon单位，2-卡拉币 1-筹码
	obj.addonCost = self.m_socket:readInt64();
	obj.addonGetChips = self.m_socket:readInt64();
	
	g_Model:setData(g_ModelCmd.NEW_MTT_CAN_ADDON, obj);
end

function RoomSocketManager:rebuyAddonFaild()
	local reasonType = self.m_socket:readShort()
	if (reasonType == -27630) then --  --应该为 0x9412 readShort读出出错为-27630
		g_AlarmTips.getInstance():setText(GameString.get("str_new_mtt_less_of_money")):show()--您的余额不足
	end
	
	g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_REBUY);
	g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_ADDON);
end
--***************************** 淘汰赛 end ********************************/

-- @desc: 0x2023 房主变化
function RoomSocketManager:privateOwnerChange()
	local ownerUid = self.m_socket:readInt()
	g_EventDispatcher:dispatch(g_SceneEvent.PRIVATE_ROOM_OWNER_CHANGED, ownerUid)
end

-- @desc: 0x2024 私人房房主离开
function RoomSocketManager:privateOwnerLeave()
	local ownerUid = self.m_socket:readInt();--0,1
	Log.d("privateOwnerLeave---",ownerUid)
	-- 提示房间其他玩家，在本局结束后房间将关闭
	g_EventDispatcher:dispatch(g_SceneEvent.PRIVATE_ROOM_OWNER_CHANGED, 0, true) -- 0 表示房主不存在了
end

-- @desc: 0x2030 把玩家踢出私人房，返回大厅，提示房間解散
function RoomSocketManager:privateLogoutSuccess()
	Log.d("privateLogoutSuccess")
	g_EventDispatcher:dispatch(g_SceneEvent.PRIVATE_ROOM_BACK_TO_HALL)
	g_Schedule:schedulerOnce(function()
		g_AlertDialog.getInstance():setTitle(GameString.get("tips"))
		:setContent(GameString.get("str_private_owner_close_room"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
		:setCenterBtnTx(GameString.get("str_room_confirm"))
		:show()
	end, 0.15)
end

--通知用户破产		 
function RoomSocketManager:userCrash()

	local userCrushData = {
		times = 0;--times为1表示第一次或者第二次破产，times为2表示最后一次破产，times为3表示完全破产
		subsidizeChips = 0;--救济金
	}
	
    userCrushData.times          = self.m_socket:readByte()  or 0
    userCrushData.subsidizeChips = self.m_socket:readInt64() or 0

	--通知php用户破产
	g_EventDispatcher:dispatch(g_SceneEvent.STORE_REQUEST_BANKRUPT_DATA)
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_BANKRUPT,userCrushData)
	
    local money = g_AccountInfo:getMoney() + userCrushData.subsidizeChips;
    if money < 0 then
       money = 0;
    end
	g_AccountInfo:setMoney(money)
	local selfSeat = import("app.scenes.normalRoom").SeatManager:getInstance():getSelfSeat()
	if selfSeat then
		local data12 = selfSeat:getSeatData()
		selfSeat:getSeatData().totalChips = money;
	end
end

-- @desc: 0x2026 房主离开，踢出玩家
function RoomSocketManager:kickOutFromRoom()
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_POP_SCENE, true)
end

function RoomSocketManager:openSocket(ip, port)
	Log.d("RoomSocketManager:openSocket --> ", ip, port)
	self.m_socket:connect(ip, port)
end

function RoomSocketManager:closeSocket()
	Log.d("RoomSocketManager:closeSocket --> ")
	self.m_socket:disConnect()
end

function RoomSocketManager:connectGameServer()
	self.m_socket:writeBegin()
	self.m_socket:writeString(g_RoomInfo:getRoomIp())
	self.m_socket:writeInt(g_RoomInfo:getRoomPort())
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_PROXY_LOGIN)
end

function RoomSocketManager:loginRoom()
	Log.d("RoomSocketManager:loginRoom --> ", g_RoomInfo:getTid())
	--lcc_sendMsgToServer
	self.m_socket:writeBegin()
	self.m_socket:writeInt(g_RoomInfo:getTid())
	self.m_socket:writeInt(g_AccountInfo:getId())
	self.m_socket:writeString(g_AccountInfo:getmtkey())
	self.m_socket:writeString(g_AccountInfo:getBigPic())
	self.m_socket:writeInt(g_AccountInfo:getUserGift())
	
	local password = g_RoomInfo:getPassword()
	if password ~= nil then
		self.m_socket:writeString(password);
	end
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_LOGIN)
end

function RoomSocketManager:logoutRoom()
	Log.d("RoomSocketManager:logoutRoom")
	self.m_socket:setAutoReconnect(false)
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_LOGOUT)
end

--发送请求坐下包
function RoomSocketManager:requestBuyIn(buyInData)
	Log.i("RoomSocketManager:requestBuyIn", buyInData)
	self.m_socket:writeBegin()
	self.m_socket:writeByte((buyInData.seatId - 1));--座位ID
	self.m_socket:writeInt64(buyInData.buyinChips);--买入筹码
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_SITDOWN)
end

function RoomSocketManager:autoBuyIn()
	Log.d("RoomSocketManager:autoBuyIn")
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_REQ_AUTO_BUY_IN)
end

--发送请求站起包
function RoomSocketManager:requestStandUp()
	Log.i("RoomSocketManager:requestStandUp")
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_STAND)
end

--用户在游戏中接受了好友邀请
--请求用户本局游戏后站起,或者mtt开赛提醒后跳转
function RoomSocketManager:requestNextStandup()
	Log.i("RoomSocketManager:requestNextStandup")
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_NEXT_STAND)
end

--发送赠送筹码
function RoomSocketManager:requestSendChips(sendChipsData)
	Log.i("RoomSocketManager:requestSendChips", sendChipsData)
	self.m_socket:writeBegin()
	self.m_socket:writeByte((sendChipsData.senderSeatId - 1));
	self.m_socket:writeInt64(sendChipsData.sendChips)
	self.m_socket:writeByte((sendChipsData.recieverSeatId - 1))
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_REQ_SEND_CHIPS)
end

--发送赠送筹码给荷官
function RoomSocketManager:requestSendChipsToDealer()
	Log.i("RoomSocketManager:requestSendChipsToDealer")
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_SEND_DEALER_MONEY)
end

--发送赠送gift
function RoomSocketManager:requestSendGift(sendGiftData)
	Log.i("RoomSocketManager:requestSendGift", sendGiftData)
	
	self.m_socket:writeBegin()
	self.m_socket:writeByte(tonumber(sendGiftData.sendSeatId) - 1);
	self.m_socket:writeInt(tonumber(sendGiftData.giftId));
	self.m_socket:writeByte(#sendGiftData.userArr);
	local arrLen = #sendGiftData.userArr;
	for i = 1, arrLen do
		if sendGiftData.userArr[i].seatId then
			self.m_socket:writeByte((sendGiftData.userArr[i].seatId - 1));
		else
			self.m_socket:writeByte(0);
		end
		self.m_socket:writeInt(sendGiftData.userArr[i].seatUid);
	end
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_SEND_GIFT)
end

--[Comment]
--改变礼物通知server,server 再广播给每一个玩家
--@param	seatId		发送者座位id
function RoomSocketManager:requestChangeGift(data)
	Log.i("RoomSocketManager:requestChangeGift")
	self.m_socket:writeBegin()
	self.m_socket:writeInt(data.giftId);
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_CHANGE_GIFT)
end

--[Comment]
--加为牌友
--@param	sendSeatId		发送者座位id
--@param	receiveSeatId	接受者座位id
function RoomSocketManager:requestAddFriend(data)
	
	Log.i("RoomSocketManager:requestSendChips", sendSeatId, receiveSeatId)
	self.m_socket:writeBegin()
	self.m_socket:writeByte((data.sendSeatId - 1));
	self.m_socket:writeByte((data.receiveSeatId - 1))
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_ADD_FRIEND)
end

RoomSocketManager.operationType = {
	FOLD = 1; --弃牌
	CHECK = 2; --看牌
	CALL = 3; --下注
}
--发送请求操作包
function RoomSocketManager:requestOperation(data)
	Log.i("RoomSocketManager:requestOperation", data)
	self.m_socket:writeBegin();
	self.m_socket:writeByte(data.operationType)
	self.m_socket:writeInt64(data.betMoney)
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_REQ_OPERATION)
end

function RoomSocketManager:requestSendMessage(data)
	Log.i("RoomSocketManager:requestSendMessage", data)
	self.m_socket:writeBegin();
	self.m_socket:writeShort(0);--0:user to table
	self.m_socket:writeInt(g_AccountInfo:getId());
	self.m_socket:writeString(g_AccountInfo:getNickName());
	self.m_socket:writeInt(0);
	self.m_socket:writeString("");
	self.m_socket:writeString(data);
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_REQ_SEND_MSG_NEW)
end

function RoomSocketManager:requestSendEmotion(emotionId, emotionType)
	Log.i("RoomSocketManager:requestSendEmotion", emotionId)
	local emotionType = emotionType or 1
	self.m_socket:writeBegin();
	self.m_socket:writeInt(emotionType)
	self.m_socket:writeInt(emotionId)
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_REQ_SEND_EMOTION)
end

function RoomSocketManager:sendDealerChipsSucc()
	local param = {}
	param.senderSeatId = self.m_socket:readByte() + 1;
	param.totalChips = self.m_socket:readInt64()
	param.sendChips = self.m_socket:readInt64()
	param.recieverSeatId = self.m_socket:readByte() + 1;
	g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_CHIPS_SUCC, param)
end

function RoomSocketManager:sendDealerChipsFail()
	g_AlarmTips.getInstance():setText(GameString.get("str_dealer_no_money")):show()
end

function RoomSocketManager:requestSuperLottoBuyNext(money)
	money = money or 0;
	self.m_socket:writeBegin()
	self.m_socket:writeInt64(money);
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_BUY_NEXT_LOTTO)
end

function RoomSocketManager:requestSuperLottoAutoBuy(money)
	Log.i("RoomSocketManager:requestSuperLottoAutoBuy")
	money = money or 0;
	self.m_socket:writeBegin()
	self.m_socket:writeInt64(money);
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_AUTO_BUY_LOTTO)
end

function RoomSocketManager:requestSuperLottoCancelAutoBuy(money)
	Log.i("RoomSocketManager:requestSuperLottoCancelAutoBuy")
	money = money or 0;
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_CANCEL_AUTO_BUY_LOTTO)
end

----mtt --------
--发送rebuy请求 1是同意 0是不同意
function RoomSocketManager:reqRebuy(rebuyData)
	--
	self.m_socket:writeBegin()
	self.m_socket:writeInt(rebuyData);
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLIENT_CMD_REQ_REBUY)
end

--发送addon请求 1是同意 0是不同意
function RoomSocketManager:reqAddon(addonData)
	--
	self.m_socket:writeBegin()
	self.m_socket:writeInt(addonData);
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLIENT_CMD_REQ_ADDON)
end
-- 請求 報名人數和參賽人數
function RoomSocketManager:reqApplyAndRewardNum()
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.SERVER_CMD_APPLY_REWARD_NUM)
end

function RoomSocketManager:buyLottoSucceed()
	local param = {}
	param.seatId = self.m_socket:readByte() + 1; --购买大乐透用户的座位号
	param.uid = self.m_socket:readInt();       --购买大乐透用户的Uid
	param.money = self.m_socket:readInt64();    --购买大乐透用户的场内筹码
	g_Model:setData(g_ModelCmd.LOTTO_BUY_SUCCEED, param);
end

function RoomSocketManager:buyLottoFail()
	local code = self.m_socket:readShort();
	g_Model:setData(g_ModelCmd.LOTTO_BUY_FAIL, code);
	g_Model:setData(g_ModelCmd.LOTTO_IS_AUTO_BUY, false);
	g_Model:setData(g_ModelCmd.LOTTO_IS_NEXT_BUY, false);
end

function RoomSocketManager:requestShowHandCard()
	Log.d("RoomSocketManager:requestShowHandCard")
	self.m_socket:writeBegin()
	self.m_socket:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_REQ_SHOW_HAND_CARD)
end

--------------SNG淘汰赛-------------
function RoomSocketManager:broadcastTableId()
	local tableIdData = {}
    tableIdData.tableId = self.m_socket:readInt() or 0;--桌子id
    tableIdData.startTime = self.m_socket:readInt64() or 0;--开始时间
    tableIdData.duration = self.m_socket:readInt() or 0;--已持续时间
    tableIdData.smallBlind = self.m_socket:readInt64() or 0;--单桌实时小盲

    g_Model:setData(g_ModelCmd.ROOM_TABLE_ID_K, tableIdData);
end

function RoomSocketManager:userRankingK()
	local rankData = {}
    rankData.count        = self.m_socket:readByte();--当前人数
    rankData.ranking      = self.m_socket:readByte();--当前排名
    rankData.selfChip     = self.m_socket:readInt64();--当前剩余筹码
    rankData.differChip   = self.m_socket:readInt64();--与前一名的差距
    
    g_Model:setData(g_ModelCmd.ROOM_MATCH_RANKING, rankData);
end

function RoomSocketManager:userOutK()
    local userOutData = {}
    userOutData.ranking = self.m_socket:readByte() or 0;--排名
    userOutData.chip    = self.m_socket:readInt64() or 0;--奖励筹码
    userOutData.coalaa  = self.m_socket:readInt() or 0;--奖励卡拉币
    userOutData.score   = self.m_socket:readInt() or 0;--奖励积分
    userOutData.exp     = self.m_socket:readInt64() or 0;--预留
    userOutData.reward  = "";
        
    g_Model:setData(g_ModelCmd.ROOM_USER_OUT_K, userOutData);
end

function RoomSocketManager:matchInfoK()
    local rewards = {};
    local data = {};
    local rewardData = nil;
    data.buyIn           = self.m_socket:readInt64();
    data.serviceCharge   = self.m_socket:readInt64();
    data.rewards         = rewards;
    for i = 1, 3 do
        rewardData = {};
        rewardData.chip         = self.m_socket:readInt64();
        rewardData.coalaa       = self.m_socket:readInt();
        rewardData.experience   = self.m_socket:readInt();
        rewards[i] = rewardData;
    end
    g_Model:setData(g_ModelCmd.ROOM_MATCH_INFO_K, data);
end

return RoomSocketManager