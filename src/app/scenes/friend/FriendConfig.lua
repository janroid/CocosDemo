-- 用于声明Friend模块的一些常量值
local FriendConfig = {}

-- 好友状态
FriendConfig.STATUS = {
    AT_PLAY  = 1;--房间
    ON_LINE  = 2;--大厅
    OFF_LINE = 3;--离线
}

-- 好友状态
FriendConfig.TABLE_TYPE = {
    ROOM_TYPE_FAST         = -1;--快速场
    ROOM_TYPE_NONE         = 0; --不在房间
    ROOM_TYPE_NORMAL       = 1; --普通场
    ROOM_TYPE_PROFESSIONAL = 2; --专业场
    ROOM_TYPE_TOURNAMENT   = 3; --锦标赛
    ROOM_TYPE_KNOCKOUT     = 4; --淘汰赛
    ROOM_TYPE_PROMOTION    = 5; --晋级赛
    ROOM_TYPE_TUTORIA  	 = 98;--新手教程
    ROOM_TYPE_SINGLE_GAME  = 99;--单机游戏
}

FriendConfig.FRIEND_STATUS = {
    Trackable = 1; -- 可追踪
    Untrackable = 2; -- 不可追踪
    Recallable = 3; -- 可召回
    NotRecallable = 4; -- 不可召回
}
return FriendConfig