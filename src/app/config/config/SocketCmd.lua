--[[
    author:{JanRoid}
    time:2018-12-3
    Description: 定义Socket相关命令字，宏定义等数据
]] 

local SocketCmd = {
    -- socket状态定义(c++)
	SOCKET_STATUS_NON = -1; -- 初始状态
	SOCKET_STATUS_CONNECTING = 0; -- 开始连接
	SOCKET_STATUS_CONNECTED = 1; -- 连接成功
	SOCKET_STATUS_CONNECTFAIL = 2; -- 连接失败
    SOCKET_STATUS_DISCONNECT = 3; -- 连接断开
    
    -- 定义socket标识
	SOCKET_TYPE_ROOM = g_GetIndex();  -- 房间socket
	SOCKET_TYPE_TRUMPET = g_GetIndex(); --小喇叭socket
	SOCKET_TYPE_SLOT = g_GetIndex(); -- 老虎机SOcket



    -------------------- 自定义数据
    SOCKET_EVENT_CONNECT_BEGIN = g_GetIndex(); -- 开始连接socket
    SOCKET_EVENT_CONNECT_COMPLETE = g_GetIndex(); -- socket连接成功
    SOCKET_EVENT_CONNECT_FAILED = g_GetIndex(); -- socket连接失败
    SOCKET_EVENT_CONNECT_TIMEOUT = g_GetIndex(); -- socket连接超时
    SOCKET_EVENT_CONNECT_ERROR = g_GetIndex(); -- socket连接，参数错误
    SOCKET_EVENT_CLOSED = g_GetIndex(); -- 关闭socket
    SOCKET_EVENT_RECV = g_GetIndex(); -- 收到socket消息
    SOCKET_EVENT_SEND = g_GetIndex(); -- 发送socket消息

}

SocketCmd.RoomSocketCMD = {
	CMD_HEART_BEAT                    = 0x1010; --主svr心跳包命令字
	CLI_CMD_PROXY_LOGIN               = 0x6001; --CLI请求通过Proxy服务器连接GameServer
	CLI_CMD_LOGIN                     = 0x1001; --CLI请求登陆
	CLI_CMD_LOGOUT                    = 0x1002; --CLI请求登出
	CLI_CMD_SITDOWN                   = 0x1003; --CLI请求坐下
	CLI_CMD_STAND                     = 0x1005; --CLI请求站起
	CLI_CMD_REQ_OPERATION             = 0x1004; --CLI请求操作
	CLI_CMD_REQ_SEND_CHIPS            = 0x100C; --CLI请求赠送筹码
	CLI_CMD_REQ_SEND_EMOTION          = 0x1009; --CLI请求发送表情
	CLI_CMD_ADD_FRIEND                = 0x100F; --CLI请求广播加为牌友
	CLI_CMD_REQ_AUTO_BUY_IN           = 0x1006; --CLI请求自动买入
	CLI_CMD_REQ_SHOW_HAND_CARD        = 0x100A; --CLI请求亮出手牌

	CLI_CMD_SEND_DEALER_MONEY         = 0x1014; --CLI请求给荷官送筹码
	CLI_CMD_SEND_GIFT                 = 0x100B; --CLI请求赠送礼物
	CLI_CMD_CHANGE_GIFT               = 0x100E; --CLI请求更换礼物 ---       
	CLI_CMD_REQ_SEND_MSG_NEW		  = 0x1024; --CLI请求发送消息
	CLI_CMD_NEXT_STAND                = 0x1011; --CLI请求本局结束后站起
	CLI_CMD_BUY_NEXT_LOTTO		      = 0x1020;	--CLI请求购买下一局大乐透
	CLI_CMD_AUTO_BUY_LOTTO		      = 0x1021;	--CLI请求自动购买大乐透
	CLI_CMD_CANCEL_AUTO_BUY_LOTTO     = 0x1022;	--CLI请求取消自动购买大乐透

--3.2Mtt
	CLIENT_CMD_REQ_REBUY           	  = 0x1301;--CLI请求rebuy
    CLIENT_CMD_REQ_ADDON           	  = 0x1302;--CLI请求addon
	CLI_CMD_BACK_SEAT                 = 0x1012; --CLI请求回到座位

	SVR_CMD_LOGIN_SUCC                = 0x2001; --SVR返回登陆成功包
	SVR_CMD_LOGIN_FAIL                = 0x2002; --SVR返回登陆失败包
	SVR_CMD_RELOGIN_SUCC              = 0x200F; --SVR返回重连登陆成功包
	SERVER_CMD_LOGOUT_SUCCESS         = 0x2029; --SVR返回登出成功包
	SVR_CMD_EXTRA_LOGIN_INFO          = 0x2022; --SVR返回登录成功额外信息包
	SVR_BCCMD_SITDOWN                 = 0x2005; --SVR广播坐下信息
	SVR_BCCMD_STAND                   = 0x2006; --SVR广播用户站起成功
	SVR_CMD_SITEDOWN_FAIL             = 0x2004; --SVR返回坐下失败包
	SVR_BCCMD_GAME_START              = 0x2007; --SVR广播游戏开始
	SVR_BCCMD_BET_TURN_TO             = 0x200C; --SVR广播轮到谁下注
	SVR_BCCMD_BET_SUCC                = 0x2008; --SVR广播下注成功信息
	SVR_BCCMD_CARD_FLOP               = 0x2009; --SVR广播翻三张
	SVR_BCCMD_CARD_TURN               = 0x200A; --SVR广播翻第四张
	SVR_BCCMD_CARD_RIVER              = 0x200B; --SVR广播翻第五张
	SVR_BCCMD_CHIPS_POTS              = 0x200D; --SVR广播奖池信息
	SVR_BCCMD_GAME_OVER               = 0x200E; --SVR广播游戏结束
	SVR_BCCMD_EMOTION                 = 0x2012; --SVR广播发送表情";
	SVR_BCCMD_CHATMSG_NEW             = 0x2051; --SVR广播发送消息(new)";
	SVR_BCCMD_TABLE_OWNER	  		  = 0x2023; --广播私人房间房主
	SVR_CMD_BROADCAST_OWNER_LEAVE	  = 0x2024; --广播房主离开
	SVR_CMD_PRIVATE_LOGOUT_SUCC		  = 0x2030; --私人房解散被迫踢出
	SERVER_CMD_KICK_OUT			      = 0x2026; --用户被踢出
	SVR_CMD_USER_CRASH                = 0x2013; --SVR返回破产包

	SVR_BCCMD_BUY_LOTTO_SUCCEED       = 0x2041; --SVR通知购买大乐透成功
	SVR_BCCMD_BUY_LOTTO_FAIL	      = 0x2042; --SVR通知购买大乐透失败

	SVR_CMD_SEND_CHIPS_FAIL           = 0x2018; --SVR返回赠送筹码失败包
	SVR_BCCMD_SEND_CHIPS              = 0x2016; --SVR广播赠送筹码
	SVR_BCCMD_SEND_GIFT            	  = 0x2015; --SVR广播赠送礼物
	SVR_BCCMD_SEND_HD                 = 0x2017; --SVR广播互动道具
	SVR_BCCMD_ADD_FRIEND              = 0x201A; --SVR广播用户加牌友
	SVR_BCCMD_LEAVE_SEAT              = 0x201B; --SVR广播用户暂离 比赛场
	SVR_BCCMD_SHOW_HAND_CARD          = 0x2014; --SVR广播亮出手牌
	SVR_BCCMD_ALLIN                   = 0x3001; --SVR广播All-In结束

	SVR_CMD_SEND_DEALER_CHIP_SUCC  	  = 0x2027; --SVR通知赠送荷官筹码成功
	SVR_CMD_SEND_DEALER_CHIP_FAIL  	  = 0x2028; --SVR通知赠送荷官筹码失败

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

	
	--[Comment]
	--多人锦标赛 mtt
    SVR_BCCMD_BLIND_CHANGE_T		  = 0x7001; --SVR广播盲注改变  ok
    SVR_BCCMD_MATCH_END_T			  = 0x7003; --SVR广播比赛结束  ok
    SVR_BCCMD_ALL_RANKING_T		 	  = 0x7004; --弃用,保留 个屁   ok
    SVR_BCCMD_TABLE_ID_T			  = 0x7006; --SVR返回桌子ID    ok
    SVR_BCCMD_COUNT_DOWN_TIME_T		  = 0x7009; --SVR返回比赛时间  ok
    SVR_BCCMD_SWITCH_TABLE_T		  = 0x700A; --SVR广播开始换桌  ok
    SVR_BCCMD_SWITCH_TABLE_SUCC_T	  = 0x700B; --SVR广播换桌成功  ok
    SVR_BCCMD_MATCH_START_T			  = 0x700C; --SVR广播比赛开始  ok
    SVR_BCCMD_MATCH_CLOSE_T		 	  = 0x700D; --SVR广播比赛即将关闭 ok
    SVR_BCCMD_MATCH_TIME_T			  = 0x700E; --SVR通知比赛开始时间  ok
    SVR_CMD_USER_RANKING_T		 	  = 0x7007; --SVR返回用户排名  ok
    SVR_CMD_USER_OUT_T				  = 0x7005; --SVR返回用户出局  ok
	--3.2mtt
    SERVER_CMD_USER_REBUY			  		= 0x7011; --SVR通知用户是否Rebuy  ok
    SERVER_CMD_BROADCAST_REBUY		  		= 0x7010; --SVR广播有用户正在Rebuy ok
    SERVER_CMD_BROADCAST_REBUY_SUCESS 		= 0x7013; --SVR服务端响应Rebuy，成功包，对所有用户发 -- ok
    SERVER_CMD_BROADCAST_ALL_REBUY_END		= 0x7012; --SVR服务端响应Rebuy，所有rebuy完成  -- ok
    SERVER_CMD_USER_PRIZE_RANK_INFO			= 0x7015; --SVR服务端维护奖池排名盲注等信息  ok
    SERVER_CMD_USER_ADDON					= 0x7016; --SVR通知用户是否Addon  ok
    SERVER_CMD_BROADCAST_USER_ADDON_SUCESS  = 0x7014; --SVR广播Addon成功  ok
    SERVER_CMD_USER_ADDON_REBUY_FAILD		= 0x2301; --SVR广播Addon失败 或者Rebuy失败  ok
    SERVER_CMD_MATCH_NOT_START				= 0x7017; --SVR通知用户比赛不开赛 1：未达到报名人数，2：坐下的人数小于2   ok 退出待處理
    SERVER_CMD_SEND_MID                 	= 0x7018; -- ok
    SERVER_CMD_APPLY_REWARD_NUM         	= 0x1303; --更新报名人数和获奖人数  ok
    SERVER_CMD_TRACE_FRIEND					= 0x2032; --追蹤好友
	SERVER_COMMAND_ANT_OVER        			= 0x2102; --前注回合结束 ok 未實現
}


SocketCmd.TrumpetSocketCMD = {
	LB_SVR_CMD_SYSTEM              = 0x1002; --喇叭SVR系统广播
	LB_SVR_CMD_SINGLE              = 0x1003; --喇叭SVR个人广播
	LB_SVR_CMD_HEARTBEAT           = 0x2001; --喇叭SVR心跳包
	LB_SVR_TYPE_LEVEL_UP           = 0x1001; --个人升级广播
	 LB_SVR_TYPE_GLORY_FINISH       = 0x1002; --个人完成成就广播
	-- LB_SVR_TYPE_TASK_FINISH        = 0x1003; --个人完成任务广播
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
	LB_SVR_TYPE_ALL_TIP            = 0x2001; --所有展示位提示
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

	--新增命令
	LB_SVR_TYPE_PUSH_MESSAGE	         = 0x200B;--系统推送信息
	LB_SVR_TYPE_DOUBLE_LOGIN             = 0x9001; --重复登录
	LB_SVR_TYPE_PLAYER_NUM               = 0x3001; --当前玩家人数
	LB_SVR_TYPE_DOSH_BOARD_MESSAGE       = 0x1013; --doshboard消息


	--移动(MB)专属Type
	LB_SVR_TYPE_MB_DISCOUNT		         = 0x10001; --打折信息
	LB_SVR_TYPE_MB_SYS_MSG 		         = 0x10002; --移动设备活动消息 
	LB_SVR_TYPE_MB_ITEM_DISCOUNT         = 0x10003; --详细打折信息
	LB_SVR_TYPE_MB_USER_PAY              = 0x10004; --用户充值
	LB_SVR_TYPE_MB_DOLL_ACQUIRE_PROMPT   = 0x50001; --用户获得玩偶提示
	LB_SVR_TYPE_MB_SINGLE_MESSAGE  	     = 0x50002; --后台通知消息，前端展示消息，不做其他用
	LB_SVR_TYPE_MB_ACCEPT_RED_PACKS      = 0x50003; --用户获得红包提示
	LB_SVR_TYPE_MB_COMMON_MESSAGE_PROMPT = 0x50004; --公共弹框消息提示

	LB_SVR_TYPE_PUSH_MATCH_MESSAGE	     = 0x300A;--系统推送进入比赛信息
}

SocketCmd.SlotSocketCMD = {
	SLOT_SVR_SEND_CMD_LOGIN        = 0x1001; --登陆
	SLOT_SVR_SEND_CMD_CALCULATOR   = 0x1002; --算牌器请求包
	SLOT_SVR_SEND_CMD_SLOT         = 0x1003; --老虎机请求包
	SLOT_SVR_RECV_CMD_CALCULATOR   = 0x2001; --算牌器返回包
	SLOT_SVR_RECV_CMD_SLOT_SUCC    = 0x2002; --老虎机成功
	SLOT_SVR_RECV_CMD_SLOT_FAIL    = 0x3001; --老虎机失败
}

SocketCmd.TrumpetSocketMap = {
	--喇叭server
[0x1002] = "ServerCommand.LB_SVR_CMD_SYSTEM                   --喇叭SVR系统广播";
[0x1003] = "ServerCommand.LB_SVR_CMD_SINGLE                   --喇叭SVR个人广播";
[0x2001] = "ServerCommand.LB_SVR_CMD_HEARTBEAT                --喇叭SVR心跳包";
[0x1001] = "ServerCommand.LB_SVR_TYPE_LEVEL_UP                --个人升级广播";
 --[0x1002] = "ServerCommand.LB_SVR_TYPE_GLORY_FINISH            --个人完成成就广播";
 --[0x1003] = "ServerCommand.LB_SVR_TYPE_TASK_FINISH             --个人完成任务广播";
[0x1004] = "ServerCommand.LB_SVR_TYPE_EXP                     --坐下加经验广播";
[0x1005] = "ServerCommand.LB_SVR_TYPE_LOTTERY                 --个人中奖广播";
[0x1006] = "ServerCommand.LB_SVR_TYPE_MESSAGE                 --个人有新消息";
[0x1007] = "ServerCommand.LB_SVR_TYPE_EDIT_CHIP	              --维护金币";
[0x1008] = "ServerCommand.LB_SVR_TYPE_MATCH_PROMPT            --比赛通知进场";
[0x1009] = "ServerCommand.LB_SVR_TYPE_INVITE_PLAY             --邀请打牌";
[0x100A] = "ServerCommand.LB_SVR_TYPE_GET_VIP                 --vip点亮";
[0x100B] = "ServerCommand.LB_SVR_TYPE_EDIT_SCORE              --维护积分";
[0x100C] = "ServerCommand.LB_SVR_TYPE_DELAY_PAY               --延迟发货";
[0x100D] = "ServerCommand.LB_SVR_TYPE_SUCCESS_PAY             --支付成功";
[0x1015] = "ServerCommand.LB_SVR_TYPE_SUCCESS_ACT             --活动完成";
[0x2001] = "ServerCommand.LB_SVR_TYPE_ALL_TIP                 --所有展示位提示";
[0x2002] = "ServerCommand.LB_SVR_TYPE_HEAD_TIP                --顶头提示";
[0x2003] = "ServerCommand.LB_SVR_TYPE_SLOT                    --老虎机大奖";
[0x2004] = "ServerCommand.LB_SVR_TYPE_ROOM_TIP                --房间提示";
[0x2005] = "ServerCommand.LB_SVR_TYPE_SMALL_LABA              --小喇叭消息";
[0x2006] = "ServerCommand.LB_SVR_TYPE_BIG_LABA                --大喇叭消息";
[0x2007] = "ServerCommand.LB_SVR_TYPE_LOTTO_REWARD            --大乐透中奖通知";
[0x2008] = "ServerCommand.LB_SVR_TYPE_LOTTO_POOL              --大乐透奖池通知";
[0x200A] = "ServerCommand.LB_SVR_TYPE_SLOT_REWARD             --老虎机牌型活动中奖通知 0x200C 卡拉币场";

[0x200B] = "ServerCommand.LB_SVR_TYPE_PUSH_MESSAGE	           -系统推送信息";
[0x9001] = "ServerCommand.LB_SVR_TYPE_DOUBLE_LOGIN             --重复登录";
[0x3001] = "ServerCommand.LB_SVR_TYPE_PLAYER_NUM               --当前玩家人数";
[0x1013] = "ServerCommand.LB_SVR_TYPE_DOSH_BOARD_MESSAGE       --doshboard消息";

--移动(MB)专属Type
[0x10001] = "ServerCommand.LB_SVR_TYPE_MB_DISCOUNT		         --打折信息";
[0x10002] = "ServerCommand.LB_SVR_TYPE_MB_SYS_MSG 		         --移动设备活动消息 ";
[0x10003] = "ServerCommand.LB_SVR_TYPE_MB_ITEM_DISCOUNT          --详细打折信息";
[0x10004] = "ServerCommand.LB_SVR_TYPE_MB_USER_PAY               --用户充值";
[0x50001] = "ServerCommand.LB_SVR_TYPE_MB_DOLL_ACQUIRE_PROMPT    --用户获得玩偶提示";
[0x50002] = "ServerCommand.LB_SVR_TYPE_MB_SINGLE_MESSAGE  	     --后台通知消息，前端展示消息，不做其他用";
[0x50003] = "ServerCommand.LB_SVR_TYPE_MB_ACCEPT_RED_PACKS       --用户获得红包提示";
[0x50004] = "ServerCommand.LB_SVR_TYPE_MB_COMMON_MESSAGE_PROMPT  --公共弹框消息提示";

[0x300A]  = "ServerCommand.LB_SVR_TYPE_PUSH_MATCH_MESSAGE	     --系统推送进入比赛信息";
}

SocketCmd.RoomSocketMap = {
	--[Comment]
	--心跳包
	[0x1010] = "ServerCommand.CLI_CMD_HEART_BEAT                 --主svr心跳包命令字";
	[0x1002] = "ServerCommand.CLI_CMD_LOGOUT                 	 --登出房间";
	[0x1009] = "ServerCommand.CLI_CMD_REQ_SEND_EMOTION           --CLI请求发送表情";
	[0x1024] = "ServerCommand.CLI_CMD_REQ_SEND_MSG_NEW           --CLI请求发送消息(new)";
	[0x1011] = "ServerCommand.CLI_CMD_NEXT_STAND           		 --CLI请求本局结束后站起";

	--[Comment]
	--SVR返回命令字段
	[0x2001] = "ServerCommand.SVR_CMD_LOGIN_SUCC                  --SVR返回登陆成功包";
	[0x2002] = "ServerCommand.SVR_CMD_LOGIN_FAIL                  --SVR返回登陆失败包";
	[0x200F] = "ServerCommand.SVR_CMD_RELOGIN_SUCC                --SVR返回重连登陆成功包";
	[0x2004] = "ServerCommand.SVR_CMD_SITEDOWN_FAIL               --SVR返回坐下失败包";
	[0x2012] = "ServerCommand.SVR_BCCMD_EMOTION                   --SVR广播发送表情";
	[0x2013] = "ServerCommand.SVR_CMD_USER_CRASH                  --SVR返回破产包";
	[0x2018] = "ServerCommand.SVR_CMD_SEND_CHIPS_FAIL             --SVR返回赠送筹码失败包";
	[0x2022] = "ServerCommand.SVR_CMD_EXTRA_LOGIN_INFO            --SVR返回登录成功额外信息包";
	[0x2027] = "ServerCommand.SVR_CMD_SEND_DEALER_CHIP_SUCC       --SVR通知赠送荷官筹码成功";
	[0x2028] = "ServerCommand.SVR_CMD_SEND_DEALER_CHIP_FAIL       --SVR通知赠送荷官筹码失败";
	
	--[Comment]
	--SVR广播命令字段
	[0x2015] = "ServerCommand.SVR_BCCMD_SEND_GIFT                 --SVR广播赠送礼物";
	[0x2016] = "ServerCommand.SVR_BCCMD_SEND_CHIPS                --SVR广播赠送筹码";
	[0x2008] = "ServerCommand.SVR_BCCMD_BET_SUCC                  --SVR广播下注成功信息";
	[0x200C] = "ServerCommand.SVR_BCCMD_BET_TURN_TO               --SVR广播轮到谁下注";
	[0x2006] = "ServerCommand.SVR_BCCMD_STAND                     --SVR广播用户站起成功";
	[0x2007] = "ServerCommand.SVR_BCCMD_GAME_START                --SVR广播游戏开始";
	[0x2005] = "ServerCommand.SVR_BCCMD_SITDOWN                   --SVR广播坐下信息";
	[0x2009] = "ServerCommand.SVR_BCCMD_CARD_FLOP                 --SVR广播翻三张";
	[0x200A] = "ServerCommand.SVR_BCCMD_CARD_TRUN                 --SVR广播翻第四张";
	[0x200B] = "ServerCommand.SVR_BCCMD_CARD_RIVER                --SVR广播翻第五张";
	[0x200D] = "ServerCommand.SVR_BCCMD_CHIPSPOTS                 --SVR广播奖池信息";
	[0x200E] = "ServerCommand.SVR_BCCMD_GAME_OVER                 --SVR广播游戏结束";
	[0x2011] = "ServerCommand.SVR_BCCMD_CHATMSG                   --SVR广播发送消息";
	[0x2012] = "ServerCommand.SVR_BCCMD_EMOTION                   --SVR广播发送表情";
	[0x2014] = "ServerCommand.SVR_BCCMD_SHOW_HAND_CARD            --SVR广播亮出手牌";
	[0x3001] = "ServerCommand.SVR_BCCMD_ALLIN                     --SVR广播All-In结束";
	[0x2017] = "ServerCommand.SVR_BCCMD_SEND_HD                   --SVR广播互动道具";
	[0x2019] = "ServerCommand.SVR_BCCMD_KITOUT                    --SVR广播踢人";
	[0x201A] = "ServerCommand.SVR_BCCMD_ADD_FRIEND                --SVR广播用户加牌友";
	[0x201B] = "ServerCommand.SVR_BCCMD_LEAVE_SEAT                --SVR广播用户暂离";
	[0x2100] = "ServerCommand.SVR_BCCMD_SVR_SWITCH                --SVR广播SVR升级成功";
	[0x2101] = "ServerCommand.SVR_BCCMD_SVR_STOP                  --SVR广播停服通知";
	[0x2041] = "ServerCommand.SVR_BCCMD_BUY_LOTTO_SUCCEED         --SVR通知购买大乐透成功";
	[0x2042] = "ServerCommand.SVR_BCCMD_BUY_LOTTO_FAIL	          --SVR通知购买大乐透失败";
	[0x2051] = "ServerCommand.SVR_BCCMD_CHATMSG_NEW               --SVR广播发送消息(new)";
	[0x2029] = "SERVER_CMD_LOGOUT_SUCCESS                         --SVR返回登出成功包";
	
	--[Comment]
	--私人房
	[0x2023] = "ServerCommand.SVR_BCCMD_TABLE_OWNER				     --广播私人房间房主";
	[0x2024] = "ServerCommand.SVR_CMD_BROADCAST_OWNER_LEAVE	    	--广播房主离开";
	[0x2026] = "ServerCommand.SERVER_CMD_LOGOUT					    --用户户被踢出";
	[0x2030] = "ServerCommand.SVR_CMD_PRIVATE_LOGOUT_SUCC			--私人房解散被迫踢出";
	--[Comment]
	--多人锦标赛
	[0x7001] = "ServerCommand.SVR_BCCMD_BLIND_CHANGE_T		   --SVR广播盲注改变-MTT-zk";
	[0x7003] = "ServerCommand.SVR_BCCMD_MATCH_END_T			   --SVR广播比赛结束-MTT-zk";
	[0x7004] = "ServerCommand.SVR_BCCMD_ALL_RANKING_T		   --弃用,保留-MTT-zk";
	[0x7006] = "ServerCommand.SVR_BCCMD_TABLE_ID_T			   --SVR返回桌子ID-MTT-zk";
	[0x7009] = "ServerCommand.SVR_BCCMD_COUNT_DOWN_TIME_T	   --SVR返回比赛时间-MTT-zk";
	[0x700A] = "ServerCommand.SVR_BCCMD_SWITCH_TABLE_T		   --SVR广播开始换桌-MTT-zk";
	[0x700B] = "ServerCommand.SVR_BCCMD_SWITCH_TABLE_SUCC_T	   --SVR广播换桌成功-MTT-zk";
	[0x700C] = "ServerCommand.SVR_BCCMD_MATCH_START_T		   --SVR广播比赛开始-MTT-zk";
	[0x700D] = "ServerCommand.SVR_BCCMD_MATCH_CLOSE_T		   --SVR广播比赛即将关闭-MTT-zk";
	[0x700E] = "ServerCommand.SVR_BCCMD_MATCH_TIME_T		   --SVR通知比赛开始时间-MTT-zk";
	[0x7007] = "ServerCommand.SVR_CMD_USER_RANKING_T		   --SVR返回用户排名-MTT-zk";
	[0x7005] = "ServerCommand.SVR_CMD_USER_OUT_T			   --SVR返回用户出局-MTT-zk";
	
	[0x7011]  = "ServerCommand.SERVER_CMD_USER_REBUY	               --SVR通知用户是否Rebuy-MTT-zk";
	[0x7010]  = "ServerCommand.SERVER_CMD_BROADCAST_REBUY	           --SVR广播有用户正在Rebuy-MTT-zk";
	[0x7013]  = "ServerCommand.SERVER_CMD_BROADCAST_REBUY_SUCESS	   --SVR服务端响应Rebuy，成功包，对所有用户发-MTT-zk";
	[0x7012]  = "ServerCommand.SERVER_CMD_BROADCAST_ALL_REBUY_END	   --SVR服务端响应Rebuy，所有rebuy完成-MTT-zk";
		
	[0x7015]  = "ServerCommand.SERVER_CMD_USER_PRIZE_RANK_INFO  		   --SVR服务端维护奖池排名盲注等信息-MTT-zk";		
	[0x7016]  = "ServerCommand.SERVER_CMD_USER_ADDON					   --SVR通知用户是否Addon-MTT-zk";
	[0x7014]  = "ServerCommand.SERVER_CMD_BROADCAST_USER_ADDON_SUCESS   --SVR广播Addon成功-MTT-zk";
	[0x2301]  = "ServerCommand.SERVER_CMD_USER_ADDON_REBUY_FAILD		   --SVR广播Addon失败 或者Rebuy失败-MTT-zk";			
	[0x7017]  = "ServerCommand.SERVER_CMD_MATCH_NOT_START			   --SVR通知用户比赛不开赛 1：未达到报名人数，2：坐下的人数小于2-MTT-zk";
	[0x7018]  = "ServerCommand.SERVER_CMD_SEND_MID                  -MTT-zk";
	[0x1303]  = "ServerCommand.SERVER_CMD_APPLY_REWARD_NUM             --更新报名人数和获奖人数-MTT-zk";
	[0x2032]  = "ServerCommand.SERVER_CMD_TRACE_FRIEND				   --追蹤好友-MTT-zk";
	[0x2102]  = "ServerCommand.SERVER_COMMAND_ANT_OVER        		   --前注回合结束-MTT-zk";
	
	--[Comment]
	--单桌淘汰赛
	[0x7103] = "ServerCommand.SVR_BCCMD_TABLE_ID_K                sng   --SVR广播tableID";
	[0x7101] = "ServerCommand.SVR_BCCMD_MATCH_START_K             sng   --SVR广播比赛开始";
	[0x7102] = "ServerCommand.SVR_BCCMD_MATCH_END_K               sng   --SVR广播比赛结束";
	[0x7106] = "ServerCommand.SVR_BCCMD_BLIND_CHANGE_K            sng   --SVR广播盲注改变";
	[0x7107] = "ServerCommand.SVR_BCCMD_ALL_RANKING_K             sng   --SVR返回所有用户排名";
	[0x7108] = "ServerCommand.SVR_BCCMD_MATCH_CLOSE_K             sng   --SVR广播比赛即将关闭";
	[0x7104] = "ServerCommand.SVR_CMD_USER_RANKING_K              sng   --SVR返回用户排名";
	[0x7105] = "ServerCommand.SVR_CMD_USER_OUT_K                  sng   --SVR返回用户出局";
	[0x7109] = "ServerCommand.SVR_CMD_MATCH_INFO_K                sng   --SVR广播比赛信息";
	
	
}
return SocketCmd