
local GameServerId =
{
	CLI_CMD_LOGIN                     = 0x1001; --CLI请求登陆
	CLI_CMD_RETURN                    = 0x1002; --CLI请求返回大厅或登录界面
	CLI_CMD_SITDOWN                   = 0x1003; --CLI请求坐下
	CLI_CMD_STAND                     = 0x1005; --CLI请求站起
	CLI_CMD_REQ_BET                   = 0x1004; --CLI请求下注
	CLI_CMD_REQ_AUTOSIT               = 0x1006; --CLI请求自动买入
	CLI_CMD_REQ_CANCEL_AUTOSIT        = 0x1007; --CLI请求取消自动买入
	CLI_CMD_REQ_SEND_MSG              = 0x1008; --CLI请求发送消息
	CLI_CMD_REQ_SEND_EMOTION          = 0x1009; --CLI请求发送表情
	CLI_CMD_REQ_SHOW_HAND_CARD        = 0x100A; --CLI请求亮出手牌
	CLI_CMD_REQ_SEND_CHIPS            = 0x100C; --CLI请求赠送筹码
	CLI_CMD_SEND_GIFT                 = 0x100B; --CLI请求赠送礼物
	CLI_CMD_SEND_HD                   = 0x100D; --CLI请求使用互动道具
	CLI_CMD_CHANGE_GIFT               = 0x100E; --CLI请求更换礼物
	CLI_CMD_ADD_FRIEND                = 0x100F; --CLI请求广播加为牌友
	CLI_CMD_HEART_BEAT                = 0x1010; --主svr心跳包命令字
	CLI_CMD_NEXT_STAND                = 0x1011; --CLI请求本局结束后站起
	CLI_CMD_BACK_SEAT                 = 0x1012; --CLI请求回到座位
	CLI_CMD_SEND_DEALER_MONEY         = 0x1014; --CLI请求给荷官送筹码
	CLI_CMD_BUY_NEXT_LOTTO		    = 0x1020;	--CLI请求购买下一局大乐透
	CLI_CMD_AUTO_BUY_LOTTO		    = 0x1021;	--CLI请求自动购买大乐透
	CLI_CMD_CANCEL_AUTO_BUY_LOTTO     = 0x1022;	--CLI请求取消自动购买大乐透
	CLI_CMD_DELAY_AUTO_BUY_LOTTO      = 0x1023; --CLI请求通知延迟自动购买大乐透
	CLI_CMD_REQ_SEND_MSG_NEW          = 0x1024; --CLI请求发送消息(new)

--[Comment]
--SVR返回命令字段
	SVR_CMD_LOGIN_SUCC             = 0x2001; --SVR返回登陆成功包
	SVR_CMD_LOGIN_FAIL             = 0x2002; --SVR返回登陆失败包
	SVR_CMD_RELOGIN_SUCC           = 0x200F; --SVR返回重连登陆成功包
	SVR_CMD_SITEDOWN_FAIL          = 0x2004; --SVR返回坐下失败包
	SVR_CMD_USER_CRASH             = 0x2013; --SVR返回破产包
	SVR_CMD_SEND_CHIPS_FAIL        = 0x2018; --SVR返回赠送筹码失败包
	SVR_CMD_EXTRA_LOGIN_INFO       = 0x2022; --SVR返回登录成功额外信息包
	SVR_CMD_SEND_DEALER_CHIP_SUCC  = 0x2027; --SVR通知赠送荷官筹码成功
	SVR_CMD_SEND_DEALER_CHIP_FAIL  = 0x2028; --SVR通知赠送荷官筹码失败
	SVR_CMD_CONNECTGAMESERVER	   = 0x2107; --連接gameServer回包
	SVR_CMD_CHANGE_PLAYER_GIFT     = 0x2108; --SVR通知改变玩家礼物

--[Comment]
--SVR广播命令字段
	SVR_BCCMD_SEND_GIFT            = 0x2015; --SVR广播赠送礼物
	SVR_BCCMD_SEND_CHIPS           = 0x2016; --SVR广播赠送筹码
	SVR_BCCMD_BET_SUCC             = 0x2008; --SVR广播下注成功信息	
	SVR_BCCMD_BET_TURN_TO          = 0x200C; --SVR广播轮到谁下注
	SVR_BCCMD_STAND                = 0x2006; --SVR广播用户站起成功
	SVR_BCCMD_GAME_START           = 0x2007; --SVR广播游戏开始
	SVR_BCCMD_SITDOWN              = 0x2005; --SVR广播坐下信息
	SVR_BCCMD_CARD_FLOP            = 0x2009; --SVR广播翻三张
	SVR_BCCMD_CARD_TRUN            = 0x200A; --SVR广播翻第四张
	SVR_BCCMD_CARD_RIVER           = 0x200B; --SVR广播翻第五张
	SVR_BCCMD_CHIPSPOTS            = 0x200D; --SVR广播奖池信息
	SVR_BCCMD_GAME_OVER            = 0x200E; --SVR广播游戏结束
	SVR_BCCMD_CHATMSG              = 0x2011; --SVR广播发送消息
	SVR_BCCMD_EMOTION              = 0x2012; --SVR广播发送表情
	SVR_BCCMD_SHOW_HAND_CARD       = 0x2014; --SVR广播亮出手牌
	SVR_BCCMD_ALLIN                = 0x3001; --SVR广播All-In结束
	SVR_BCCMD_SEND_HD              = 0x2017; --SVR广播互动道具
	SVR_BCCMD_KITOUT               = 0x2019; --SVR广播踢人
	SVR_BCCMD_ADD_FRIEND           = 0x201A; --SVR广播用户加牌友
	SVR_BCCMD_LEAVE_SEAT           = 0x201B; --SVR广播用户暂离
	SVR_BCCMD_SVR_SWITCH           = 0x2100; --SVR广播SVR升级成功
	SVR_BCCMD_SVR_STOP             = 0x2101; --SVR广播停服通知
	SVR_BCCMD_BUY_LOTTO_SUCCEED    = 0x2041; --SVR通知购买大乐透成功
	SVR_BCCMD_BUY_LOTTO_FAIL	   = 0x2042; --SVR通知购买大乐透失败
	SVR_BCCMD_CHATMSG_NEW          = 0x2051; --SVR广播发送消息(new)

	SERVER_COMMAND_ANT_OVER        = 0x2102; --前注回合结束
	SERVER_COMMAND_EXP_LIMIT       = 0x2104; --当天玩牌经验达到上限时会收到此消息

--[Comment]
--私人房
	SVR_BCCMD_TABLE_OWNER				= 0x2023; --广播私人房间房主
	SERVER_CMD_BROADCAST_OWNER_LEAVE	= 0x2024;	--广播房主离开
	SERVER_CMD_LOGOUT					= 0x2026;--用户被踢出
--2017.6.30新增的
	SERVER_CMD_LOGOUT_SUCCESS         = 0x2029; --通用房间解散被踢出 
	SERVER_CMD_RPRIVATE_LOGOUT_SUCCESS= 0x2030; --私人房解散被路踢出 

--[Comment]
--多人锦标赛 
	SVR_BCCMD_BLIND_CHANGE_T		= 0x7001; --SVR广播盲注改变
	SVR_BCCMD_MATCH_END_T			= 0x7003; --SVR广播比赛结束
	SVR_BCCMD_ALL_RANKING_T		= 0x7004; --弃用,保留
	SVR_BCCMD_TABLE_ID_T			= 0x7006; --SVR返回桌子ID
	SVR_BCCMD_COUNT_DOWN_TIME_T	= 0x7009; --SVR返回比赛时间
	SVR_BCCMD_SWITCH_TABLE_T		= 0x700A; --SVR广播开始换桌
	SVR_BCCMD_SWITCH_TABLE_SUCC_T	= 0x700B; --SVR广播换桌成功
	SVR_BCCMD_MATCH_START_T		= 0x700C; --SVR广播比赛开始
	SVR_BCCMD_MATCH_CLOSE_T		= 0x700D; --SVR广播比赛即将关闭
	SVR_BCCMD_MATCH_TIME_T		= 0x700E; --SVR通知比赛开始时间
	SVR_CMD_USER_RANKING_T		= 0x7007; --SVR返回用户排名
	SVR_CMD_USER_OUT_T			= 0x7005; --SVR返回用户出局

--[Comment]
--单桌淘汰赛
	SVR_BCCMD_TABLE_ID_K           = 0x7103; --SVR广播tableID
	SVR_BCCMD_MATCH_START_K        = 0x7101; --SVR广播比赛开始
	SVR_BCCMD_MATCH_END_K          = 0x7102; --SVR广播比赛结束
	SVR_BCCMD_BLIND_CHANGE_K       = 0x7106; --SVR广播盲注改变
	SVR_BCCMD_ALL_RANKING_K        = 0x7107; --SVR返回所有用户排名
	SVR_BCCMD_MATCH_CLOSE_K        = 0x7108; --SVR广播比赛即将关闭
	SVR_CMD_USER_RANKING_K         = 0x7104; --SVR返回用户排名
	SVR_CMD_USER_OUT_K             = 0x7105; --SVR返回用户出局
	SVR_CMD_MATCH_INFO_K           = 0x7109; --SVR广播比赛信息
}

local LBServerId=
{
--[Comment]
--喇叭server
	LB_SVR_CMD_SYSTEM              = 0x1002; --喇叭SVR系统广播
	LB_SVR_CMD_SINGLE              = 0x1003; --喇叭SVR个人广播
	LB_SVR_CMD_HEARTBEAT           = 0x2001; --喇叭SVR心跳包
	LB_SVR_TYPE_LEVEL_UP           = 0x1001; --个人升级广播
	--LB_SVR_TYPE_GLORY_FINISH       = 0x1002; --个人完成成就广播
	--LB_SVR_TYPE_TASK_FINISH        = 0x1003; --个人完成任务广播
	LB_SVR_TYPE_EXP                = 0x1004; --坐下加经验广播
	LB_SVR_TYPE_LOTTERY            = 0x1005; --个人中奖广播
	LB_SVR_TYPE_MESSAGE            = 0x1006; --个人有新消息
	LB_SVR_TYPE_EDIT_CHIP	       = 0x1007; --维护金币
	LB_SVR_TYPE_MATCH_PROMPT       = 0x1008; --比赛通知进场
	LB_SVR_TYPE_INVITE_PLAY        = 0x1009; --邀请打牌
	LB_SVR_TYPE_GET_VIP            = 0x100A; --vip点亮
	LB_SVR_TYPE_EDIT_SCORE         = 0x100B; --维护积分
	LB_SVR_TYPE_DELAY_PAY          = 0x100C; --延迟发货
	LB_SVR_TYPE_SUCCESS_PAY        = 0x100D; --支付成功
	LB_SVR_TYPE_SUCCESS_ACT        = 0x1015; --活动完成
	--LB_SVR_TYPE_ALL_TIP            = 0x2001; --所有展示位提示
	LB_SVR_TYPE_HEAD_TIP           = 0x2002; --顶头提示
	LB_SVR_TYPE_SLOT               = 0x2003; --老虎机大奖
	LB_SVR_TYPE_ROOM_TIP           = 0x2004; --房间提示
	LB_SVR_TYPE_SMALL_LABA         = 0x2005; --小喇叭消息
	LB_SVR_TYPE_BIG_LABA           = 0x2006; --大喇叭消息
	LB_SVR_TYPE_LOTTO_REWARD       = 0x2007; --大乐透中奖通知
	LB_SVR_TYPE_LOTTO_POOL         = 0x2008; --大乐透奖池通知
	LB_SVR_TYPE_SLOT_REWARD        = 0x200A; --老虎机牌型活动中奖通知 0x200C 卡拉币场
	LB_SVR_TYPE_PASSDAY            = 0x300B; --跨天推送广播
	LB_SVR_TYPE_UPDATE_GIFT        = 0x300C; --有玩家礼物修改时，更新信息到房间其他玩家
	LB_SVR_TYPE_UPDATE_TICKETS     = 0x1017; --维护门票

--[Comment]
--David新增命令
	LB_SVR_TYPE_PUSH_MESSAGE	         = 0x200B;--系统推送信息
	LB_SVR_TYPE_DOUBLE_LOGIN             = 0x9001; --重复登录
	LB_SVR_TYPE_PLAYER_NUM               = 0x3001; --当前玩家人数
	LB_SVR_TYPE_DOSH_BOARD_MESSAGE       = 0x1013; --doshboard消息

--[Comment]
--移动(MB)专属Type
	LB_SVR_TYPE_MB_DISCOUNT		       = 0x10001; --打折信息
	LB_SVR_TYPE_MB_SYS_MSG 		       = 0x10002; --移动设备活动消息 
	LB_SVR_TYPE_MB_ITEM_DISCOUNT         = 0x10003; --详细打折信息
	LB_SVR_TYPE_MB_USER_PAY              = 0x10004; --用户充值
	LB_SVR_TYPE_MB_DOLL_ACQUIRE_PROMPT   = 0x50001; --用户获得玩偶提示
	LB_SVR_TYPE_MB_SINGLE_MESSAGE  	   = 0x50002; --后台通知消息，前端展示消息，不做其他用
	LB_SVR_TYPE_MB_ACCEPT_RED_PACKS      = 0x50003; --用户获得红包提示
	LB_SVR_TYPE_MB_COMMON_MESSAGE_PROMPT = 0x50004; --公共弹框消息提示

	LB_SVR_TYPE_PUSH_MATCH_MESSAGE	   = 0x300A;--系统推送进入比赛信息
}


local SlotServerId=
{

--[Comment]
--老虎机server
	SLOT_SVR_SEND_CMD_LOGIN        = 0x1001; --登陆
	SLOT_SVR_SEND_CMD_CALCULATOR   = 0x1002; --算牌器请求包
	SLOT_SVR_SEND_CMD_SLOT         = 0x1003; --老虎机请求包
	SLOT_SVR_RECV_CMD_CALCULATOR   = 0x2001; --算牌器返回包
	SLOT_SVR_RECV_CMD_SLOT_SUCC    = 0x2002; --老虎机成功
	SLOT_SVR_RECV_CMD_SLOT_FAIL    = 0x3001; --老虎机失败

	CLI_CMD_PROXY_LOGIN            = 0x6001; --CLI请求通过Proxy服务器连接GameServer
--[Comment]
--3.2Mtt
	CLIENT_CMD_REQ_REBUY           = 0x1301;--CLI请求rebuy
	CLIENT_CMD_REQ_ADDON           = 0x1302;--CLI请求addon

--[Comment]
--3.2mtt
	SERVER_CMD_USER_REBUY					= 0x7011; --SVR通知用户是否Rebuy
	SERVER_CMD_BROADCAST_REBUY			= 0x7010; --SVR广播有用户正在Rebuy
	SERVER_CMD_BROADCAST_REBUY_SUCESS		= 0x7013; --SVR服务端响应Rebuy，成功包，对所有用户发
	SERVER_CMD_BROADCAST_ALL_REBUY_END	= 0x7012; --SVR服务端响应Rebuy，所有rebuy完成
		
	SERVER_CMD_USER_PRIZE_RANK_INFO		= 0x7015; --SVR服务端维护奖池排名盲注等信息
		
	SERVER_CMD_USER_ADDON					= 0x7016; --SVR通知用户是否Addon
	SERVER_CMD_BROADCAST_USER_ADDON_SUCESS= 0x7014; --SVR广播Addon成功
	SERVER_CMD_USER_ADDON_REBUY_FAILD		= 0x2301; --SVR广播Addon失败 或者Rebuy失败
		
	SERVER_CMD_MATCH_NOT_START			= 0x7017; --SVR通知用户比赛不开赛 1：未达到报名人数，2：坐下的人数小于2
	SERVER_CMD_SEND_MID                   = 0x7018;
	SERVER_CMD_APPLY_REWARD_NUM           = 0x1303; --更新报名人数和获奖人数
	SERVER_CMD_TRACE_FRIEND				= 0x2032; --追蹤好友
}


local GameServerIdName = {
	[GameServerId.CLI_CMD_LOGIN] = "XGMsg.CLI_CMD_LOGIN",
	[GameServerId.CLI_CMD_RETURN] = "XGMsg.CLI_CMD_RETURN",
	[GameServerId.CLI_CMD_SITDOWN] = "XGMsg.CLI_CMD_SITDOWN",
	[GameServerId.CLI_CMD_STAND] = "XGMsg.CLI_CMD_STAND",
	[GameServerId.CLI_CMD_REQ_BET] = "XGMsg.CLI_CMD_REQ_BET",
	[GameServerId.CLI_CMD_REQ_AUTOSIT] = "XGMsg.CLI_CMD_REQ_AUTOSIT",
	[GameServerId.CLI_CMD_REQ_CANCEL_AUTOSIT] = "XGMsg.CLI_CMD_REQ_CANCEL_AUTOSIT",
	[GameServerId.CLI_CMD_REQ_SEND_MSG] = "XGMsg.CLI_CMD_REQ_SEND_MSG",
	[GameServerId.CLI_CMD_REQ_SEND_EMOTION] = "XGMsg.CLI_CMD_REQ_SEND_EMOTION",
	[GameServerId.CLI_CMD_REQ_SHOW_HAND_CARD] = "XGMsg.CLI_CMD_REQ_SHOW_HAND_CARD",
	[GameServerId.CLI_CMD_REQ_SEND_CHIPS] = "XGMsg.CLI_CMD_REQ_SEND_CHIPS",
	[GameServerId.CLI_CMD_SEND_GIFT] = "XGMsg.CLI_CMD_SEND_GIFT",
	[GameServerId.CLI_CMD_SEND_HD] = "XGMsg.CLI_CMD_SEND_HD",
	[GameServerId.CLI_CMD_CHANGE_GIFT] = "XGMsg.CLI_CMD_CHANGE_GIFT",
	[GameServerId.CLI_CMD_ADD_FRIEND] = "XGMsg.CLI_CMD_ADD_FRIEND",
	[GameServerId.CLI_CMD_HEART_BEAT] = "XGMsg.CLI_CMD_HEART_BEAT",
	[GameServerId.CLI_CMD_NEXT_STAND] = "XGMsg.CLI_CMD_NEXT_STAND",
	[GameServerId.CLI_CMD_BACK_SEAT] = "XGMsg.CLI_CMD_BACK_SEAT",
	[GameServerId.CLI_CMD_SEND_DEALER_MONEY] = "XGMsg.CLI_CMD_SEND_DEALER_MONEY",
	[GameServerId.CLI_CMD_BUY_NEXT_LOTTO] = "XGMsg.CLI_CMD_BUY_NEXT_LOTTO",
	[GameServerId.CLI_CMD_AUTO_BUY_LOTTO] = "XGMsg.CLI_CMD_AUTO_BUY_LOTTO",
	[GameServerId.CLI_CMD_CANCEL_AUTO_BUY_LOTTO] = "XGMsg.CLI_CMD_CANCEL_AUTO_BUY_LOTTO",
	[GameServerId.CLI_CMD_DELAY_AUTO_BUY_LOTTO] = "XGMsg.CLI_CMD_DELAY_AUTO_BUY_LOTTO",
	[GameServerId.CLI_CMD_REQ_SEND_MSG_NEW] = "XGMsg.CLI_CMD_REQ_SEND_MSG_NEW",
	[GameServerId.SVR_CMD_LOGIN_SUCC] = "XGMsg.RoomReqSitDownData",
	[GameServerId.SVR_CMD_LOGIN_FAIL] = "XGMsg.SVR_CMD_LOGIN_FAIL",
	[GameServerId.SVR_CMD_RELOGIN_SUCC] = "XGMsg.SVR_CMD_RELOGIN_SUCC",
	[GameServerId.SVR_CMD_SITEDOWN_FAIL] = "XGMsg.SVR_CMD_SITEDOWN_FAIL",
	[GameServerId.SVR_CMD_USER_CRASH] = "XGMsg.SVR_CMD_USER_CRASH",
	[GameServerId.SVR_CMD_SEND_CHIPS_FAIL] = "XGMsg.SVR_CMD_SEND_CHIPS_FAIL",
	[GameServerId.SVR_CMD_EXTRA_LOGIN_INFO] = "XGMsg.SVR_CMD_EXTRA_LOGIN_INFO",
	[GameServerId.SVR_CMD_SEND_DEALER_CHIP_SUCC] = "XGMsg.SVR_CMD_SEND_DEALER_CHIP_SUCC",
	[GameServerId.SVR_CMD_SEND_DEALER_CHIP_FAIL] = "XGMsg.SVR_CMD_SEND_DEALER_CHIP_FAIL",
	[GameServerId.SVR_CMD_CONNECTGAMESERVER] = "XGMsg.SVR_CMD_CONNECTGAMESERVER",
	[GameServerId.SVR_CMD_CHANGE_PLAYER_GIFT] = "XGMsg.SVR_CMD_CHANGE_PLAYER_GIFT",
	[GameServerId.SVR_BCCMD_SEND_GIFT] = "XGMsg.SVR_BCCMD_SEND_GIFT",
	[GameServerId.SVR_BCCMD_SEND_CHIPS] = "XGMsg.SVR_BCCMD_SEND_CHIPS",
	[GameServerId.SVR_BCCMD_BET_SUCC] = "XGMsg.SVR_BCCMD_BET_SUCC",
	[GameServerId.SVR_BCCMD_BET_TURN_TO] = "XGMsg.SVR_BCCMD_BET_TURN_TO",
	[GameServerId.SVR_BCCMD_STAND] = "XGMsg.SVR_BCCMD_STAND",
	[GameServerId.SVR_BCCMD_GAME_START] = "XGMsg.SVR_BCCMD_GAME_START",
	[GameServerId.SVR_BCCMD_SITDOWN] = "XGMsg.SVR_BCCMD_SITDOWN",
	[GameServerId.SVR_BCCMD_CARD_FLOP] = "XGMsg.SVR_BCCMD_CARD_FLOP",
	[GameServerId.SVR_BCCMD_CARD_TRUN] = "XGMsg.SVR_BCCMD_CARD_TRUN",
	[GameServerId.SVR_BCCMD_CARD_RIVER] = "XGMsg.SVR_BCCMD_CARD_RIVER",
	[GameServerId.SVR_BCCMD_CHIPSPOTS] = "XGMsg.SVR_BCCMD_CHIPSPOTS",
	[GameServerId.SVR_BCCMD_GAME_OVER] = "XGMsg.SVR_BCCMD_GAME_OVER",
	[GameServerId.SVR_BCCMD_CHATMSG] = "XGMsg.SVR_BCCMD_CHATMSG",
	[GameServerId.SVR_BCCMD_EMOTION] = "XGMsg.SVR_BCCMD_EMOTION",
	[GameServerId.SVR_BCCMD_SHOW_HAND_CARD] = "XGMsg.SVR_BCCMD_SHOW_HAND_CARD",
	[GameServerId.SVR_BCCMD_ALLIN] = "XGMsg.SVR_BCCMD_ALLIN",
	[GameServerId.SVR_BCCMD_SEND_HD] = "XGMsg.SVR_BCCMD_SEND_HD",
	[GameServerId.SVR_BCCMD_KITOUT] = "XGMsg.SVR_BCCMD_KITOUT",
	[GameServerId.SVR_BCCMD_ADD_FRIEND] = "XGMsg.SVR_BCCMD_ADD_FRIEND",
	[GameServerId.SVR_BCCMD_LEAVE_SEAT] = "XGMsg.SVR_BCCMD_LEAVE_SEAT",
	[GameServerId.SVR_BCCMD_SVR_SWITCH] = "XGMsg.SVR_BCCMD_SVR_SWITCH",
	[GameServerId.SVR_BCCMD_SVR_STOP] = "XGMsg.SVR_BCCMD_SVR_STOP",
	[GameServerId.SVR_BCCMD_BUY_LOTTO_SUCCEED] = "XGMsg.SVR_BCCMD_BUY_LOTTO_SUCCEED",
	[GameServerId.SVR_BCCMD_BUY_LOTTO_FAIL] = "XGMsg.SVR_BCCMD_BUY_LOTTO_FAIL",
	[GameServerId.SVR_BCCMD_CHATMSG_NEW] = "XGMsg.SVR_BCCMD_CHATMSG_NEW",
	[GameServerId.SERVER_COMMAND_ANT_OVER] = "XGMsg.SERVER_COMMAND_ANT_OVER",
	[GameServerId.SERVER_COMMAND_EXP_LIMIT] = "XGMsg.SERVER_COMMAND_EXP_LIMIT",
	[GameServerId.SVR_BCCMD_TABLE_OWNER] = "XGMsg.SVR_BCCMD_TABLE_OWNER",
	[GameServerId.SERVER_CMD_BROADCAST_OWNER_LEAVE] = "XGMsg.SERVER_CMD_BROADCAST_OWNER_LEAVE",
	[GameServerId.SERVER_CMD_LOGOUT] = "XGMsg.SERVER_CMD_LOGOUT",
	[GameServerId.SERVER_CMD_LOGOUT_SUCCESS] = "XGMsg.SERVER_CMD_LOGOUT_SUCCESS",
	[GameServerId.SERVER_CMD_RPRIVATE_LOGOUT_SUCCESS] = "XGMsg.SERVER_CMD_RPRIVATE_LOGOUT_SUCCESS",
	[GameServerId.SVR_BCCMD_BLIND_CHANGE_T] = "XGMsg.SVR_BCCMD_BLIND_CHANGE_T",
	[GameServerId.SVR_BCCMD_MATCH_END_T] = "XGMsg.SVR_BCCMD_MATCH_END_T",
	[GameServerId.SVR_BCCMD_ALL_RANKING_T] = "XGMsg.SVR_BCCMD_ALL_RANKING_T",
	[GameServerId.SVR_BCCMD_TABLE_ID_T] = "XGMsg.SVR_BCCMD_TABLE_ID_T",
	[GameServerId.SVR_BCCMD_COUNT_DOWN_TIME_T] = "XGMsg.SVR_BCCMD_COUNT_DOWN_TIME_T",
	[GameServerId.SVR_BCCMD_SWITCH_TABLE_T] = "XGMsg.SVR_BCCMD_SWITCH_TABLE_T",
	[GameServerId.SVR_BCCMD_SWITCH_TABLE_SUCC_T] = "XGMsg.SVR_BCCMD_SWITCH_TABLE_SUCC_T",
	[GameServerId.SVR_BCCMD_MATCH_START_T] = "XGMsg.SVR_BCCMD_MATCH_START_T",
	[GameServerId.SVR_BCCMD_MATCH_CLOSE_T] = "XGMsg.SVR_BCCMD_MATCH_CLOSE_T",
	[GameServerId.SVR_BCCMD_MATCH_TIME_T] = "XGMsg.SVR_BCCMD_MATCH_TIME_T",
	[GameServerId.SVR_CMD_USER_RANKING_T] = "XGMsg.SVR_CMD_USER_RANKING_T",
	[GameServerId.SVR_CMD_USER_OUT_T] = "XGMsg.SVR_CMD_USER_OUT_T",
	[GameServerId.SVR_BCCMD_TABLE_ID_K] = "XGMsg.SVR_BCCMD_TABLE_ID_K",
	[GameServerId.SVR_BCCMD_MATCH_START_K] = "XGMsg.SVR_BCCMD_MATCH_START_K",
	[GameServerId.SVR_BCCMD_MATCH_END_K] = "XGMsg.SVR_BCCMD_MATCH_END_K",
	[GameServerId.SVR_BCCMD_BLIND_CHANGE_K] = "XGMsg.SVR_BCCMD_BLIND_CHANGE_K",
	[GameServerId.SVR_BCCMD_ALL_RANKING_K] = "XGMsg.SVR_BCCMD_ALL_RANKING_K",
	[GameServerId.SVR_BCCMD_MATCH_CLOSE_K] = "XGMsg.SVR_BCCMD_MATCH_CLOSE_K",
	[GameServerId.SVR_CMD_USER_RANKING_K] = "XGMsg.SVR_CMD_USER_RANKING_K",
	[GameServerId.SVR_CMD_USER_OUT_K] = "XGMsg.SVR_CMD_USER_OUT_K",
	[GameServerId.SVR_CMD_MATCH_INFO_K] = "XGMsg.SVR_CMD_MATCH_INFO_K",
}



return {
	GameServerId = GameServerId,
	LBServerId = LBServerId,
	SlotServerId = SlotServerId,
	GameServerIdName = GameServerIdName,
}
