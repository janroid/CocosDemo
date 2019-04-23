--[[
    author:{JanRoid}
    time:2018-11-30
    Description: 定义Http接口,所有Http接口统一定义于此，便于维护
]]

local HttpCmd = {}

HttpCmd.s_cmds = {
    TABLE_QUICKIN = g_GetIndex();
    FRIEND_LIST = g_GetIndex();
    FRIEND_ONLINE_LIST = g_GetIndex();
    FRIEND_GIVECHIPSNEW = g_GetIndex();
    FRIEND_DELPOKER = g_GetIndex();
    FRIEND_CALLBACKNEW = g_GetIndex();
    FRIEND_ADD  = g_GetIndex();
    ACCOUNT_LOGIN = g_GetIndex(); -- 登陆接口
    MSG_GET = g_GetIndex();
    MSG_SETREAD = g_GetIndex();
    MSG_REWARD = g_GetIndex();
    MOBILEBANK_BANKCLICK = g_GetIndex();
    MOBILEBANK_BANKSAVEMONEY = g_GetIndex();
    MOBILEBANK_BANKGETMONEY = g_GetIndex();
    MOBILEBANK_BANKCHECKPSW = g_GetIndex();
    MOBILEBANK_CANCELPSW = g_GetIndex();
    MOBILEBANK_SETPSW = g_GetIndex();
    USER_UPLOADPIC = g_GetIndex();
    USER_MODIFYINFO = g_GetIndex();
    USER_MAIN = g_GetIndex();
    BANNER_SHOW = g_GetIndex();
    USER_USEPROPS = g_GetIndex();  -- 使用道具
    USER_SENDPROPS = g_GetIndex();  -- 发送互动道具
    GET_USER_ROPS_NUM = g_GetIndex();  -- 请求互动道具数量
    USER_GETUSERCHENGJIU = g_GetIndex();  -- 获取用户成就信息
    USER_GETPOKERSTAT = g_GetIndex();  -- 获取用户统计数据
    USER_GETPAY = g_GetIndex();  -- 获取用戶購買記錄
    USER_GETUSERPROPS = g_GetIndex();  -- 获取用戶道具
    BREAK_GETINFO = g_GetIndex();  -- 破产
    BREAK_REPORT = g_GetIndex();  -- 破产
    USER_GETUSERACHIREWARD = g_GetIndex();  -- 获取用户成就奖励
    PAY_CREATE_ORDER = g_GetIndex();  -- 下单
    TJ_PAY_REPORT = g_GetIndex();  -- 支付上报
    RANK_MAIN = g_GetIndex();
    RANK_MFMONEY = g_GetIndex();
    USER_OTHER_MAIN = g_GetIndex();

    NORMAL_ROOM_LIST = g_GetIndex();
    SEARCH_ROOM = g_GetIndex();
    SEND_FEEDBACK = g_GetIndex();
    GET_FEEDBACK_LIST = g_GetIndex();
    CHECK_EMAIL = g_GetIndex();
    GET_EMAIL_VERIFY = g_GetIndex();
    BIND_EMAIL = g_GetIndex();

    --宝箱
    TREASUREBOX_GET_INFO = g_GetIndex();
    TREASUREBOX_SET_STAND = g_GetIndex();
    TREASUREBOX_SET_SIT = g_GetIndex();
    TREASUREBOX_GET_REWARD = g_GetIndex();

    DAILY_TASK_INFO = g_GetIndex();
    DOLL_REPORT = g_GetIndex();
    TJ_GAME_REPORT = g_GetIndex();
    SPRING_REPORT = g_GetIndex();

    EMAIL_ACCOUNT_MODIFY_PASSWORD = g_GetIndex();
    ROOM_UPLOAD_BEST_CARDTYPE = g_GetIndex();  -- 上報最佳牌型
    -- gift 界面
    GIFT_GET_LIST = g_GetIndex(); -- 下载 禮物列表 xml
    GIFT_GET_BUY = g_GetIndex();  -- 買 给自己
    GIFT_GET_OWN = g_GetIndex();  -- 自己擁有
    GIFT_GET_SELL = g_GetIndex();  
    GIFT_GET_USE = g_GetIndex();  -- 使用礼物
    GIFT_GET_PRESENT = g_GetIndex();  -- 赠送一个人礼物

    -- login
    LOGIN_UPLOAD_TOKEN = g_GetIndex();  -- 上报token

    --MTT Lobby
    MTT_LOBBY_LIST       = g_GetIndex(); -- 获取mtt 列表
    MTT_LOBBY_LIST1       = g_GetIndex(); -- 获取mtt 列表 test
    MTT_APPLY            = g_GetIndex(); -- 报名mtt比赛
    MTT_CANCEL_SIGN      = g_GetIndex(); -- 报名mtt比赛
    MTT_MATCH_DETAIL     = g_GetIndex(); -- mtt比赛 详情
    MTT_MATCH_TRACK      = g_GetIndex(); -- mtt比赛 追踪

    BIG_WHEEL_PLAY = g_GetIndex();
    BIG_WHEEL_MONEY_PLAY = g_GetIndex();
    BIG_WHEEL_GET_PLAY_TIMES = g_GetIndex();

    SUPER_LOTTO_GET_REWARD_LIST = g_GetIndex();
    SUPER_LOTTO_GET_REWARD = g_GetIndex();

    DEALER_GET_INFO = g_GetIndex();
    DEALER_SET_ID = g_GetIndex();

    PRIVATE_HALL_CFG    = g_GetIndex();-- 私人房大厅配置
    PRIVATE_ROOM_CREATE = g_GetIndex();-- 私人房创建
    PRIVATE_ROOM_CHECKPWD = g_GetIndex(); -- 核对密碼
    USER_PROP_DATA        = g_GetIndex(); --用户道具信息
    PRIVATE_ROOM_GET_PWD    = g_GetIndex(); -- 私人房密码信息
    PRIVATE_ROOM_MOTIFY_PWD = g_GetIndex(); -- 请求修改私人房密码
    ROOM_CHAT_TRUMPET = g_GetIndex();--发送小喇叭
    ACTIVITY_UNREAD_NUMBER = g_GetIndex(); -- 清除活动红点的显示
    SLOT_GETLUCKY = g_GetIndex(); -- 老虎机幸运数字
    SLOT_REWARD = g_GetIndex; -- 老虎机奖励
    REQUEST_SNG_LIST = g_GetIndex();--获取sng比赛列表
    GET_SNG_OR_MTT_RANK = g_GetIndex();--mtt or sng 参赛获奖次数

    MTT_GET_BONUS = g_GetIndex();--得到MTT的比赛奖励信息
    
    MTT_GET_RANK = g_GetIndex();--得到MTT的比赛排名信息
    
    RESET_MTKEY = g_GetIndex();--重新获取mtkey
    ONLINE_INFO = g_GetIndex();--获取在线信息
    TUTORIAL_REWARD = g_GetIndex();-- 新手教程奖励
    REGISTER_REWARD = g_GetIndex();-- 新手奖励
    REGISTER_REWARD_RECEIVE = g_GetIndex();-- 领取新手奖励

    MTT_GET_REWARD = g_GetIndex(); --玩家结束比赛的奖励数据

    Hall_REQUEST_PLAYTIMES = g_GetIndex(); --大转盘可玩次数

    GET_LEVEL_DATA = g_GetIndex(); --得到经验等级数据
}

HttpCmd.s_config = {
  
    [HttpCmd.s_cmds.GIFT_GET_LIST] = {mod = "user",act = "test"};
    [HttpCmd.s_cmds.GIFT_GET_BUY] = {mod = "shop",act = "pay"};
    [HttpCmd.s_cmds.GIFT_GET_OWN] = {mod = "user",act = "getUserGiftNew"};
    [HttpCmd.s_cmds.GIFT_GET_SELL] = {mod = "shop",act = "sell"};
    [HttpCmd.s_cmds.GIFT_GET_USE] = {mod = "shop",act = "setHeadGift"};
    [HttpCmd.s_cmds.GIFT_GET_PRESENT] = {mod = "shop",act = "present"};

    --login
    [HttpCmd.s_cmds.LOGIN_UPLOAD_TOKEN] = {mod = "mobile",act = "GiveToken"};

    -- mtt lobbylist
    [HttpCmd.s_cmds.MTT_LOBBY_LIST] = {mod = "match",act = "newList"};
    [HttpCmd.s_cmds.MTT_LOBBY_LIST1] = {mod = "match",act = "matchNewList"};
    [HttpCmd.s_cmds.MTT_APPLY] = {mod = "match",act = "signup"};
    [HttpCmd.s_cmds.MTT_CANCEL_SIGN] = {mod = "match",act = "cancelSign"};
    [HttpCmd.s_cmds.MTT_MATCH_DETAIL] = {mod = "match",act = "detail"};
    [HttpCmd.s_cmds.MTT_MATCH_TRACK] = {mod = "match",act = "track"};

    [HttpCmd.s_cmds.TABLE_QUICKIN] = {mod = "table", act = "quickIn"};
    [HttpCmd.s_cmds.FRIEND_LIST] = {mod = "friend", act = "list"};
    [HttpCmd.s_cmds.FRIEND_ONLINE_LIST] = {mod = "friend", act = "getOnlineFriends"};
    [HttpCmd.s_cmds.FRIEND_GIVECHIPSNEW] = {mod = "friend", act = "giveChipsNew"};
    [HttpCmd.s_cmds.FRIEND_DELPOKER] = {mod = "friend", act = "DelPoker"};
    [HttpCmd.s_cmds.FRIEND_CALLBACKNEW] = {mod = "friend", act = "callbackNew"};
    [HttpCmd.s_cmds.ACCOUNT_LOGIN] = {};  -- 登陆接口特殊化
    [HttpCmd.s_cmds.MSG_GET] = {mod = "msg", act = "get"};
    [HttpCmd.s_cmds.MSG_SETREAD] = {mod = "msg", act = "setRead"};
    [HttpCmd.s_cmds.MSG_REWARD] = {mod = "msg", act = "reward"};
    [HttpCmd.s_cmds.MOBILEBANK_BANKCLICK] = {mod = "mobileBank", act = "bankClick"};
    [HttpCmd.s_cmds.MOBILEBANK_BANKSAVEMONEY] = {mod = "mobileBank", act = "bankSaveMoney"};
    [HttpCmd.s_cmds.MOBILEBANK_BANKGETMONEY] = {mod = "mobileBank", act = "bankGetMoney"};
    [HttpCmd.s_cmds.MOBILEBANK_BANKCHECKPSW] = {mod = "mobileBank", act = "bankCheckpsw"};
    [HttpCmd.s_cmds.MOBILEBANK_CANCELPSW] = {mod = "mobileBank", act = "canclePWD"};
    [HttpCmd.s_cmds.MOBILEBANK_SETPSW] = {mod = "mobileBank", act = "setPwd"};
    [HttpCmd.s_cmds.USER_UPLOADPIC] = {mod = "user", act = "uploadpic"};
    [HttpCmd.s_cmds.USER_MODIFYINFO] = {mod = "user", act = "modifyInfo"};
    [HttpCmd.s_cmds.USER_MAIN] = {mod = "user", act = "main"};
    [HttpCmd.s_cmds.BANNER_SHOW] = {mod = "banner", act = "show"};
    [HttpCmd.s_cmds.USER_USEPROPS] = {mod="user", act="useprops"};
    [HttpCmd.s_cmds.USER_SENDPROPS] = {mod="user", act="useUserFun"};
    [HttpCmd.s_cmds.GET_USER_ROPS_NUM] = {mod="user", act="getUserFun"};
    [HttpCmd.s_cmds.USER_GETUSERCHENGJIU] = {mod="user", act="GetUserChengJiu"};
    [HttpCmd.s_cmds.USER_GETPOKERSTAT] = {mod="user", act="getPokerStat"};
    [HttpCmd.s_cmds.USER_GETPAY] = {mod="user", act="getpay"};
    [HttpCmd.s_cmds.USER_GETUSERPROPS] = {mod="user", act="getUserProps"};
    [HttpCmd.s_cmds.BREAK_GETINFO] = {mod="break", act="getInfo"};
    [HttpCmd.s_cmds.BREAK_REPORT] = {mod="break", act="report"};
    [HttpCmd.s_cmds.USER_GETUSERACHIREWARD] = {mod="user", act="getUserAchiReward"};
    [HttpCmd.s_cmds.PAY_CREATE_ORDER] = {mod="pay", act="getPayCenterID"};
    [HttpCmd.s_cmds.TJ_PAY_REPORT] = {mod="tj", act="pay"};
    [HttpCmd.s_cmds.RANK_MAIN] = {mod = "rank", act = "main"};
    [HttpCmd.s_cmds.RANK_MFMONEY] = {mod = "rank", act = "mfmoney"};
    [HttpCmd.s_cmds.USER_OTHER_MAIN] = {mod = "user", act = "othermain"};
    [HttpCmd.s_cmds.FRIEND_ADD] = {mod = "friend", act = "setPoker"};
    [HttpCmd.s_cmds.NORMAL_ROOM_LIST] = {mod = "table",act = "tableInfo"};
    [HttpCmd.s_cmds.SEARCH_ROOM] = {mod = "table",act = "search"};
    [HttpCmd.s_cmds.SEND_FEEDBACK] = {mod = "feedback",act = "setNew"};
    [HttpCmd.s_cmds.GET_FEEDBACK_LIST] = {mod = "feedback",act = "getList"};

    [HttpCmd.s_cmds.CHECK_EMAIL] = {mod = "email",act = "check"};
    [HttpCmd.s_cmds.GET_EMAIL_VERIFY] = {mod = 'user', act = 'setEmailToken'};
    [HttpCmd.s_cmds.BIND_EMAIL] = {mod = "email",act = "bind"};
    
    [HttpCmd.s_cmds.TREASUREBOX_GET_INFO] = {mod = "treasureBox",act = "get"};
    [HttpCmd.s_cmds.TREASUREBOX_SET_STAND] = {mod = "treasureBox",act = "stand"};
    [HttpCmd.s_cmds.TREASUREBOX_SET_SIT] = {mod = "treasureBox",act = "sit"};
    [HttpCmd.s_cmds.TREASUREBOX_GET_REWARD] = {mod = "treasureBox",act = "reward"};

    [HttpCmd.s_cmds.DAILY_TASK_INFO] = {mod = "taskNew", act = "list"};
    [HttpCmd.s_cmds.DOLL_REPORT] = {mod = "doll",act = "report"};
    [HttpCmd.s_cmds.TJ_GAME_REPORT] = {mod = "tj",act = "game"};
    [HttpCmd.s_cmds.SPRING_REPORT] = {mod = "spring",act = "report"};

    [HttpCmd.s_cmds.EMAIL_ACCOUNT_MODIFY_PASSWORD] = {mod = "email",act = "modify"};
    [HttpCmd.s_cmds.ROOM_UPLOAD_BEST_CARDTYPE] = {mod = "user",act = "setMostStat"};

    [HttpCmd.s_cmds.BIG_WHEEL_PLAY] = {mod = "dazhuanpan",act = "Play"};
    [HttpCmd.s_cmds.BIG_WHEEL_MONEY_PLAY] = {mod = "dazhuanpan",act = "moneyPlay"};
    [HttpCmd.s_cmds.BIG_WHEEL_GET_PLAY_TIMES] = {mod = "dazhuanpan",act = "GetCanPlayTimes"};

    [HttpCmd.s_cmds.SUPER_LOTTO_GET_REWARD_LIST] = {mod = "duojindao",act = "getRewardUids"};
    [HttpCmd.s_cmds.SUPER_LOTTO_GET_REWARD] = {mod = "duojindao",act = "reward"};
    [HttpCmd.s_cmds.DEALER_GET_INFO] = {mod = "changeDeinger",act = "DeingerList"};
    [HttpCmd.s_cmds.DEALER_SET_ID] = {mod = "changeDeinger",act = "signChange"};

    [HttpCmd.s_cmds.PRIVATE_HALL_CFG]        = {mod = "ptable", act = "getCfg"};
    [HttpCmd.s_cmds.PRIVATE_ROOM_CREATE]     = {mod = "ptable", act = "create"};
    [HttpCmd.s_cmds.PRIVATE_ROOM_CHECKPWD]   = {mod = "ptable", act = "CheckPWD"};
    [HttpCmd.s_cmds.PRIVATE_ROOM_GET_PWD]    = {mod = "ptable", act = "getInfo"};
    [HttpCmd.s_cmds.PRIVATE_ROOM_MOTIFY_PWD] = {mod = "ptable", act = "ChangePassward"};

    [HttpCmd.s_cmds.ACTIVITY_UNREAD_NUMBER] = { mod = "act", act = "setMbHotAct" };

    [HttpCmd.s_cmds.USER_PROP_DATA]          = {mod ="user", act ="getUserProps"};
    [HttpCmd.s_cmds.SLOT_GETLUCKY]           = {mod = "tiger", act = "getLucky"};
    [HttpCmd.s_cmds.SLOT_REWARD]             = {mod = "tiger",act = "reward"};
    [HttpCmd.s_cmds.ROOM_CHAT_TRUMPET] = {mod = "lb",act = "speak"};
    [HttpCmd.s_cmds.REQUEST_SNG_LIST] = {mod = "sng",act = "sngList"};
    [HttpCmd.s_cmds.GET_SNG_OR_MTT_RANK] = {mod = "match",act = "matchPointRank"};
    [HttpCmd.s_cmds.MTT_GET_BONUS] = {mod = "match",act = "bonus"};
    [HttpCmd.s_cmds.MTT_GET_RANK] = {mod = "match",act = "rank"};
    [HttpCmd.s_cmds.RESET_MTKEY] = {["mod"]="user", ["act"]="setmtkey"};
    [HttpCmd.s_cmds.ONLINE_INFO] = {["mod"]= "user", ["act"]= "onlineInfo"};
    [HttpCmd.s_cmds.TUTORIAL_REWARD] = {["mod"]= "user", ["act"]= "reward"};
    [HttpCmd.s_cmds.REGISTER_REWARD] = {["mod"]= "registerReward", ["act"]= "text"};
    [HttpCmd.s_cmds.REGISTER_REWARD_RECEIVE] = {["mod"]= "registerReward", ["act"]= "reward"};
    [HttpCmd.s_cmds.MTT_GET_REWARD] = {["mod"]= "match", ["act"]= "reward"};
    [HttpCmd.s_cmds.Hall_REQUEST_PLAYTIMES] = {["mod"]= "dazhuanpan", ["act"]= "GetCanPlayTimes"};
    [HttpCmd.s_cmds.GET_LEVEL_DATA] = {["mod"]= "mobile", ["act"]= "getLevelList"};
}

function HttpCmd:getMethod(cmd)
    if not cmd or not HttpCmd.s_config[cmd] then
        Log.e("HttpCmd:getMethod","can't find cmd = ",cmd);

        return {}
    end

    return g_TableLib.copyTab(HttpCmd.s_config[cmd])
end

return HttpCmd;