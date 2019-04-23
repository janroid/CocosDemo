local ModelCmd = {
    RANK_MY_INFO                                = "RANK_MY_INFO"; -- 排行榜——我的排行信息
    RANK_LIST_DISPLAY                           = "RANK_LIST_DISPLAY"; -- 排行榜——排行榜列表
    
    ALL_TASK_LIST                               = "ALL_TASK_LIST";	--全部每日任务列表
    ROOM_TASK_LIST                              = "ROOM_TASK_LIST";	--房间每日任务列表
    TASK_SPECIAL                                = "TASK_SPECIAL";	--每日任务置顶任务
    CURRENRT_FINISHED_TASK                      = "CURRENRT_FINISHED_TASK"; --当前已完成没领奖的任务
    HOME_TASK_SWARDS				            = "HOME_TASK_SWARDS";--每日任务完成提示

    ROOM_DATA                                   = "TABLE_DATA";                      -- 房间信息
    ROOM_EXTRA_LOGIN_INFO                       = "ROOM_EXTRA_LOGIN_INFO";           -- 房间额外信息
    ROOM_SIT_DOWN_USERS                         = "ROOM_SIT_DOWN_USERS";             -- 房间内坐下用户
    USER_SELF_SEAT_ID                           = "USER_SELF_SEAT_ID";               -- 自己座位ID
    ROOM_SIT_FAIL_DATA                          = "ROOM_SIT_FAIL_DATA";              -- 坐下失败code
    ROOM_ALL_IN_DATA                            = "ROOM_ALL_IN_DATA";                -- all in
    ROOM_TOURNAMENT_DATA                        = "ROOM_TOURNAMENT_DATA";--当前房间锦标赛数据
    ROOM_ENTER_MATCH_DATA                       = "ROOM_ENTER_MATCH_DATA";--房间进入锦标赛数据
    ROOM_ENTER_HIGHT_DATA                       = "ROOM_ENTER_HIGHT_DATA";--房间高级房数据
    ROOM_ENTER_MTT_LOBBY                        = "ROOM_ENTER_MTT_LOBBY";--房间跳转 mtt大厅
    ROOM_REQUEST_LOGIN_DATA                     = "ROOM_REQUEST_LOGIN_DATA";
    USER_HDDJ_NUMBER                            = "USER_HDDJ_NUMBER"; --获取互动道具数量
    --rank
    FRIEND_UID_LIST = "FRIEND_UID_LIST";
    ROOM_ADD_FRIEND_UID_LIST = "ROOM_ADD_FRIEND_UID_LIST";-- 房间个人信息 添加的好友id list
    ROOM_USER_PROP_DATA                         = "ROOM_USER_PROP_DATA";--道具数据
    
    --礼物
    GIFT_DATA = "GIFT_DATA";
    GIFT_LIST_OWNED = "GIFT_LIST_OWNED";
    GIFT_LIST_DISPLAYING = "GIFT_LIST_DISPLAYING";
    GIFT_ID_FILE_MAPPING = "GIFT_ID_FILE_MAPPING";
    GIFT_ID_XML_MAPPING = "GIFT_ID_XML_MAPPING";
    GIFT_ALL_DATA = "GIFT_ALL_DATA";
    DOLL_LIST_DATA = "DOLL_LIST_DATA";

    -- MTT Lobby list
    NEW_MTT_ALL_LIST_DATA = "NEW_MTT_ALL_LIST_DATA",
    NEW_MTT_SINGLE_MATCH_DATA = "NEW_MTT_SINGLE_MATCH_DATA",
    NEW_MTT_LIST_DATA = "NEW_MTT_LIST_DATA",
    TOURNAMENT_USER_DATA = "TOURNAMENT_USER_DATA";--锦标赛用户数据
    TOURNAMENT_DETAIL_DATA = "TOURNAMENT_DETAIL_DATA";--锦标赛详情数据
    
    ROOM_LEAVE_SEAT_DATA = "ROOM_LEAVE_SEAT_DATA"; -- 玩家离开座位倒计时
    --mtt 锦标赛
    ROOM_MATCH_RANKING = "ROOM_MATCH_RANKING"; --
    ROOM_MATCH_END = "ROOM_MATCH_END";
    TRACE_FRIEND = "TRACE_FRIEND";
    ROOM_MATCH_CLOSE = "ROOM_MATCH_CLOSE";
    ROOM_BLIND_CHANGE = "ROOM_BLIND_CHANGE";
    ROOM_MATCH_START = "ROOM_MATCH_START";
    ROOM_COUNT_DOWN_TIME_T = "ROOM_COUNT_DOWN_TIME_T";
    ROOM_MATCH_START_TIME_T = "ROOM_MATCH_START_TIME_T";
    ROOM_USER_OUT_T = "ROOM_USER_OUT_T"; 
    ROOM_GAME_START_DATA = "ROOM_GAME_START_DATA";
    -- ROOM_TOURNAMENT_OUT_RESULT = "ROOM_TOURNAMENT_RESULT";
    NEW_MTT_TABLE_ID 			= "NEW_MTT_TABLE_ID";		  --tid
    NEW_MTT_MID 				= "NEW_MTT_MID";			  --mid
    NEW_MTT_ANT_END           = "NEW_MTT_ANT_END";--ant结束
    NEW_MTT_APPLY_AND_REWAED_INFO = "NEW_MTT_APPLY_AND_REWAED_INFO";--更新錢圈人數
    NEW_MTT_ROOM_MATCH_INFO 	= "NEW_MTT_ROOM_MATCH_INFO";--比赛房间内奖池排名等信息
    NEW_MTT_CAN_REBUY 		= "NEW_MTT_CAN_REBUY";		--发送rebuy信息
    NEW_MTT_REBUY_ORADDON_SUCC_INFO = "NEW_MTT_REBUY_SUCC_INFO"; --rebuy或者addon成功返回的座位号和筹码数据
    NEW_MTT_CAN_ADDON 		= "NEW_MTT_CAN_ADDON"; 		--发送可以addon信息
    NEW_MTT_MY_SEATCHIPS = "NEW_MTT_MY_SEATCHIPS"; -- mtt 自己的筹码改变
    NEW_MTT_RAISE_BLIND_CD 		= "NEW_MTT_RAISE_BLIND_CD"; 		--涨盲倒计时
    ROOM_TOURNAMENT_OUT_RESULT = "ROOM_TOURNAMENT_OUT_RESULT"; --通知mtt比赛自己站起

    -- 算牌器
    ROOM_CALCULATOR_DATA = "ROOM_CALCULATOR_DATA";
    ROOM_CARD_TYPE = "ROOM_CARD_TYPE";--计算出的牌型
    
    -- 房间内聊天
    ROOM_CHAT_DATA = "ROOM_CHAT_DATA";
    ROOM_CHAT_HISTORY = "ROOM_CHAT_HISTORY";
    ROOM_SMALL_TRUMPET_DATA = "ROOM_SMALL_TRUMPET_DATA";
    ROOM_EXPRESSION_DATA = "ROOM_EXPRESSION_DATA";
    ROOM_SMALL_LABA_DATA = "ROOM_SMALL_LABA_DATA"; --小喇叭消息
    -- 老虎机
    DATA_SLOT = "DATA_SLOT_INFO";

    -- 成就
    DATA_ACHIEVE_INFO = "DATA_ACHIEVE_INFO";
    USER_GLORY_FINISH = "USER_GLORY_FINISH";			--用户获得新成就
    --SNG LOBBY
    SNG_HALL_CURRENT_MATCH_DATA = "SNG_HALL_CURRENT_MATCH_DATA"; --sng大厅列表信息
    SNG_MTT_DATA = "SNG_MTT_DATA";

    --SNG ROOM 
    ROOM_TABLE_ID_K             = "ROOM_TABLE_ID_K";
    ROOM_USER_OUT_K             = "ROOM_USER_OUT_K";
    ROOM_MATCH_INFO_K           = "ROOM_MATCH_INFO_K";
    KNOCKOUT_TABLE_DATA         = "KNOCKOUT_TABLE_DATA";
    ROOM_USER_RANKING_DATA      = "ROOM_USER_RANKING_DATA";--排名数据

    -- BIG WHEEL
    IS_ACTIVITY_WHEEL_OPENED = "IS_ACTIVITY_WHEEL_OPENED";

    -- 夺金岛
    LOTTO_BUY_SUCCEED = "LOTTO_BUY_SUCCEED";  --购买大乐透成功
    LOTTO_BUY_FAIL = "BUY_LOTTO_FAIL";  --购买大乐透失败
    LOTTO_IS_AUTO_BUY = "LOTTO_IS_AUTO_BUY";
    LOTTO_IS_NEXT_BUY = "LOTTO_IS_NEXT_BUY";
    LOTTO_IS_CURRENT_BUY = "LOTTO_IS_CURRENT_BUY";
    LOTTO_REWARD = "LOTTO_REWARD";
    LOTTO_POOL = "LOTTO_POOL";
    LOTTO_REWARD_LIST = "LOTTO_REWARD_LIST";

    -- 荷官
    DEALER_LIST = "DEALER_LIST";
    SELECTED_DEALER = "SELECTED_DEALER";
    DEALYER_ID = "DEALYER_ID";
    DEALYER_TEXTURE = "DEALYER_TEXTURE";

    -- 活动红点提示未阅读数
    ACTIVITY_UNREAD_NUMBER = "ACTIVITY_UNREAD_NUMBER";

    -- 新手教程 礼物详情
    TUTORIAL_GIFT_CLICKED = "TUTORIAL_GIFT_CLICKED";
    USER_RECEIVED_TUTORIAL_REWARD = "USER_RECEIVED_TUTORIAL_REWARD"; -- 新手教程奖励是否领取
    -- 小喇叭
    DATA_TRUMPET = "DataTrumpet";
    DATA_HALL_SCENE_FROM = "DataHallSceneFrom";

    -- 大厅
    WHEEL_FREE_REMAIN_TIMES = "wheelFreeRemainTimes";
    RECONNECT_DATA = "reConnectData";
    
    RECEIVE_INVITE_DATA = "receive_invite_data";
    ROOM_HEARTBEAT_TIMEOUT_TIMES = "room_heartbeat_timeout_times";
}
return ModelCmd