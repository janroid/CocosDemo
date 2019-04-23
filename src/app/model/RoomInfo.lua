--[[
    author:{JanRoid}
    time:2018-12-3
    Description: 房间数据类
]] 

local RoomInfo = class("RoomInfo")
RoomInfo.ROOM_TYPE_FAST         = -1;--快速场
RoomInfo.ROOM_TYPE_NONE         = 0; --不在房间
RoomInfo.ROOM_TYPE_NORMAL       = 1; --普通场
RoomInfo.ROOM_TYPE_PROFESSIONAL = 2; --专业场
RoomInfo.ROOM_TYPE_TOURNAMENT   = 3; --锦标赛
RoomInfo.ROOM_TYPE_KNOCKOUT     = 4; --淘汰赛
RoomInfo.ROOM_TYPE_PROMOTION    = 5; --晋级赛
RoomInfo.ROOM_TYPE_PRIVATE    	= 9; --私人房
RoomInfo.ROOM_TYPE_TUTORIA  	 = 98;--新手教程
RoomInfo.ROOM_TYPE_SINGLE_GAME  = 99;--单机游戏

--[Comment]
--新手场	
RoomInfo.ROOM_LEVEL_NEWER  = 1;
--[Comment]
--初级场	
RoomInfo.ROOM_LEVEL_PRIMARY = 2;
--[Comment]
--中级场
RoomInfo.ROOM_LEVEL_INTERMEDIATE = 3;
--[Comment]
--高级场	
RoomInfo.ROOM_LEVEL_SENIOR = 4;

RoomInfo.GAME_STATE_READY         = 0;
RoomInfo.GAME_STATE_PREFLOP_ROUND = 1;
RoomInfo.GAME_STATE_FLOP_ROUND    = 2;
RoomInfo.GAME_STATE_TURN_ROUND    = 3;
RoomInfo.GAME_STATE_RIVER_ROUND   = 4;
RoomInfo.GAME_STATE_ROUND_OVER    = 6;

RoomInfo.ERROR_LOGIN_MTKEY               = 0x9001;--参数非法
RoomInfo.ERROR_LOGIN_USER_DISABLE        = 0x9002;--用户被禁
RoomInfo.ERROR_LOGIN_TABLE_ERR           = 0x9003;--登录桌子错误
RoomInfo.ERROR_LOGIN_ROOM_FULL           = 0x9004;--用户达到最大值
RoomInfo.ERROR_LOGIN_RECONN_ROOM         = 0x9005;--重连进入不同的桌子
RoomInfo.ERROR_LOGIN_OTHER_RELOGIN       = 0x9006;--账号被其他人登陆了
RoomInfo.ERROR_LOGIN_EXP_DISABLE         = 0x9007;--等级不够
RoomInfo.ERROR_LOGIN_SERVER_STOP         = 0x9008;--停服标志
RoomInfo.ERROR_LOGIN_KICKOUT             = 0x9009;--被踢出
RoomInfo.ERROR_LOGIN_PASSWORD_ERROR      = 0x810A;--密码错误
RoomInfo.ERROR_LOGIN_TABLE_NOTEXIST      = 0x810B;--房间不存在
RoomInfo.ERROR_LOGIN_NO_APPLY            = 0x900B;--没有报名
RoomInfo.ERROR_LOGIN_END                 = 0x900E;--比赛结束
RoomInfo.ERROR_LOGIN_MTT_END             = 0x900E;--比赛结束
RoomInfo.ERROR_LOGIN_CROSS_SERVER        = 0x9202; --SVR通知卡房进入新房间失败
RoomInfo.ERROR_LOGIN_OTHER               = 0;--其它错误  （客户端自定义的）

function RoomInfo:notInRoom()
	local rt = RoomInfo:getRoomType()
	return rt == RoomInfo.ROOM_TYPE_NONE
end

function RoomInfo:isMatch()
	local rt = RoomInfo:getRoomType()
	local ret = (rt == RoomInfo.ROOM_TYPE_KNOCKOUT) or
			(rt == RoomInfo.ROOM_TYPE_TOURNAMENT) or
			(rt == RoomInfo.ROOM_TYPE_PROMOTION);
	return ret;
end

addProperty(RoomInfo, "proxyIp")
addProperty(RoomInfo, "proxyPort")
local init = function()
	addProperty(RoomInfo, "roomIp")
	addProperty(RoomInfo, "roomPort")
	addProperty(RoomInfo, "tid")
	addProperty(RoomInfo, "smallBlind") 	    --小盲注
	addProperty(RoomInfo, "minBuyIn") 		    --最小携带
	addProperty(RoomInfo, "maxBuyIn") 		    --最大携带
	addProperty(RoomInfo, "tableId") 	        --桌子ID
	addProperty(RoomInfo, "tableName") 	        --桌子名字
	addProperty(RoomInfo, "roomType", 0) 		    --房间场别
	addProperty(RoomInfo, "tableLevel") 		--房间级别
	addProperty(RoomInfo, "userChips", 0) 	        --用户钱数
	addProperty(RoomInfo, "betInExpire") 		--下注最大时间
	addProperty(RoomInfo, "gameStatus") 		--游戏状态
	addProperty(RoomInfo, "maxSeatCount") 	    --最大玩家数量
	addProperty(RoomInfo, "roundCount") 		--游戏局数
	addProperty(RoomInfo, "dealerSeatId")       --庄家座位ID
	addProperty(RoomInfo, "chipsPotsCount") 	--奖池数量
	addProperty(RoomInfo, "chipsPots") 	        --奖池数组
	addProperty(RoomInfo, "publicCards",{})        --桌子上的牌，数组内存PublicCard对象
	addProperty(RoomInfo, "betInSeatId") 	    --桌子目前的下注位置
	addProperty(RoomInfo, "callNeedChips", 0)      --跟注需要钱数（重连数据）
	addProperty(RoomInfo, "minRaiseChips", 0)      --加注最小钱数（重连数据）
	addProperty(RoomInfo, "maxRaiseChips", 0)      --加注最大钱数（重连数据）
	addProperty(RoomInfo, "playerCount") 		--玩家数量（坐下）
	addProperty(RoomInfo, "playerList") 	    --玩家用户的信息，数组内存RoomLoginPlayer对象
	addProperty(RoomInfo, "handCardFlag") 	    --是否有手牌，1有，0无
	addProperty(RoomInfo, "flag") 		    --房间标识
	addProperty(RoomInfo, "handCard",{}) 		    --手牌
	addProperty(RoomInfo, "password") 		    --密码
	addProperty(RoomInfo, "owner") 		    --私人房房主id
	addProperty(RoomInfo, "mid") 		    --mtt 使用未发现使用的地方
	addProperty(RoomInfo, "autoSitDown", true) 		    --自动坐下
	addProperty(RoomInfo, "allBet", 0) 		    --总下注筹码
end

init()

-- 获取玩家自己房间数据对象
function RoomInfo:getUserSelf()
	if not RoomInfo:getPlayerList() then return end
	for k, v in pairs(RoomInfo:getPlayerList()) do
		if v.uid == g_AccountInfo:getId() then
			return v
		end
	end
end

function RoomInfo:reset()
	init()
end

function RoomInfo:setData(data)
	if data then
		self:setRoomIp(data.ip)
		self:setRoomPort(data.port)
		self:setTid(data.tid)
		self:setFlag(data.roomFlag or data.flag)
		self:setRoomType(data.tableType or 0)
		self:setPassword(data.password)
	end
end

--@desc:  根据房间号判断是否为私人房；php 以这个作为私人房类别
--@tid: 房间号
--@return: bool
function RoomInfo:isPrivateRoom(tid)
	tid = tonumber(tid) or 0
	return (tid > 0 and tid < 10000) 
end

return RoomInfo;