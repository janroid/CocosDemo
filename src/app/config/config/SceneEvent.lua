--[[
    author:{JanRoid}
    time:2018-11-12 14:42:43
    Description: 场景事件定义，所有场景相关事件定义到此文件中
                 命名规范：所有字母大写
                    局部事件：场景名称_事件的用途
                    公共事件：COMMON_事件用途
                
]]

local SceneEvent = {
     ----------按鍵事件--------------
     EVENT_BACK = g_GetIndex();
     EVENT_APP_RESUME = g_GetIndex();
     EVENT_APP_PAUSE = g_GetIndex();

    LOGIN_SUCCESS                       = g_GetIndex(); -- 登录成功
    LOGIN_FAILED                        = g_GetIndex(); -- 登录失败
    LOGIN_EMAIL                         = g_GetIndex(); -- email登录
    LOGIN_GUEST                         = g_GetIndex(); -- 游客登录
    LOGIN_FACEBOOK                      = g_GetIndex(); -- facebook登录
    LOGIN_RESET_PWD                     = g_GetIndex(); -- 重置密码
    LOGIN_UPDATE_DEBUGVIEW              = g_GetIndex(); -- debug view 信息更新
    BLIND_SUCCESS                       = g_GetIndex(); -- 绑定邮箱成功信息

    -------------- PopBase ----------------
    POP_DESTORY                         = g_GetIndex(); -- 弹框销毁
    POP_HIDDEN                          = g_GetIndex(); -- 弹框隐藏

    ------- HallScene  start-----
    HALL_REQUEST_BANNER                 = g_GetIndex(); -- 请求Banner图片
    HALL_REQUEST_BANNER_SUCCESS         = g_GetIndex(); -- 请求Banner图片成功
    HALL_QUICKSTART                     = g_GetIndex(); -- 快速进入游戏
    Hall_REQUEST_PLAYTIMES              = g_GetIndex(); -- 请求大转盘可以玩的次数
    Hall_REQUEST_PLAYTIMES_SUCCESS      = g_GetIndex(); -- 请求成功
    Hall_SHOW_SUBGAMES                  = g_GetIndex(); -- 显示小游戏
    HALL_UPDATE_RED_POINT               = g_GetIndex(), --更新红点

    -------UserInfoPop start ------
    UPDATE_USER_HEAD_ICON = g_GetIndex();  -- 更新头像
    UPLOAD_USER_HEAD_ICON = g_GetIndex();  -- 上传头像
    UPLOAD_USER_HEAD_ICON_SUCCESS = g_GetIndex();  -- 上传头像成功
    MODIFY_USER_INFO = g_GetIndex();  -- 修改玩家信息
    MODIFY_USER_INFO_SUCCESS = g_GetIndex();  -- 修改玩家信息成功
    REQUEST_USER_INFO = g_GetIndex();  -- 请求用户信息
    REQUEST_USER_INFO_SUCCESS = g_GetIndex();  -- 请求用户信息成功
    REQUEST_USER_GLORY = g_GetIndex();  -- 请求用户成就信息
    REQUEST_USER_GLORY_SUCCESS = g_GetIndex();  -- 请求用户成就信息成功
    REQUEST_USER_STATISTICS = g_GetIndex();  -- 请求用户统计数据
    REQUEST_USER_STATISTICS_SUCCESS = g_GetIndex();  -- 请求用户统计数据成功
    USER_INFO_MAIL_CHANGE_PWD = g_GetIndex(); -- 邮箱用户更改密码

    -- ------------------------------ 商城 start -------------------------------------------------
    STORE_EVENT_REFRESH_DATA =  g_GetIndex(); -- 更新商城数据
    STORE_EVENT_SHOW =  g_GetIndex(); -- 跳转商城界面 
    SELF_PROPS_SHOW_PROPS_INFO = g_GetIndex(); --展开道具详细信息
    SELF_PROPS_USE_PROPS =  g_GetIndex(); --使用道具
    STORE_REQUEST_BANKRUPT_DATA =  g_GetIndex(); --请求破产数据
    STORE_DISCOUNT_UPDATE =  g_GetIndex(); --刷新商城 折扣信息
    STORE_DISCOUNT_UPDATE1 =  g_GetIndex(); --刷新破产页面折扣信息
    CLOSE_STORE =  g_GetIndex(); --关闭商城
    CLOSE_STORE1 =  g_GetIndex(); --关闭商城
    SHOW_STORE =  g_GetIndex(); --关闭商城
    STORE_REQ_USER_MONEY =  g_GetIndex(); --获取最新金钱
    --------------------------- 商城 end ------------------------------------------------- 

    EVENT_CLOSE_DETALE_ITEM              = g_GetIndex(), -- 
    --------------------------- 邮箱 start -------------------------------------------------
    MAILBOX_EVENT_GET =    g_GetIndex(); -- 领取邮件奖励
    MAILBOX_EVENT_SIGN =   g_GetIndex(); -- 邮件实物奖励填写资料
    MAILBOX_EVENT_REQUEST_DATA  = g_GetIndex();-- 获取邮箱数据
    MAILBOX_EVENT_REQUEST_DATA_SUCCESS  = g_GetIndex();-- 获取邮箱数据成功
    MAILBOX_EVENT_GET_ATTACH = g_GetIndex();   -- 领取附件奖励
    MAILBOX_EVENT_GET_ATTACH_SUCCESS = g_GetIndex();
    ------------------------------ 邮箱 end -------------------------------------------------

    --------------------------- 保險箱 start -------------------------------------------------
    SAFE_BOX_EVENT_GET_DATA = g_GetIndex();   -- 獲取保險箱信息
    SAFE_BOX_EVENT_GET_DATA_SUCCESS = g_GetIndex();   -- 獲取保險箱信息成功
    SAFE_BOX_EVENT_SAVE_MONEY = g_GetIndex();   -- 存錢
    SAFE_BOX_EVENT_SAVE_MONEY_SUCCESS = g_GetIndex();   -- 存錢成功
    SAFE_BOX_EVENT_DRAW_MONEY = g_GetIndex();   -- 取錢
    SAFE_BOX_EVENT_DRAW_MONEY_SUCCESS = g_GetIndex();   -- 取錢成功
    SAFE_BOX_SET_PASSWORD_SUCCESS = g_GetIndex(); -- 设置保险箱密码成功
   
    ------------------------------ 保險箱 end -------------------------------------------------

    ------- FriendPop start ------
    FRIEND_REQUEST_FRIEND_LIST          = g_GetIndex(), -- 获取好友列表
    FRIEND_GIVE_CHIPS                   = g_GetIndex(), -- 赠送好友筹码
    FRIEND_REFRESH_ITEM_DATA            = g_GetIndex(), -- 某项好友数据刷新
    FRIEND_GIVE_GIFT                    = g_GetIndex(), -- 赠送好友礼物
    FRIEND_DELETE_FRIEND                = g_GetIndex(), -- 删除好友
    FRIEND_DELETE_FRIEND_SUCCESS        = g_GetIndex(), -- 删除好友成功
    FRIEND_RECALL                       = g_GetIndex(), -- 召回
    FRIEND_RECALL_SUCCESS               = g_GetIndex(), -- 好友召回请求接口成功
    FRIEND_TRACK                        = g_GetIndex(), -- 好友追踪
    FRIEND_INVITE_FACEBOOK_FRIENDS      = g_GetIndex(), --邀请FaceBook好友
    FRIEND_ADD_FRIEND                   = g_GetIndex(), -- 添加好友


    RANK_HALL_RANKLIST_REQUEST          = g_GetIndex(), -- 获取大厅排行榜信息
    RANK_HALL_RANKLIST_RESPONSE         = g_GetIndex(), -- 大厅排行榜响应
    RANK_HALL_REFRESH_VIEW              = g_GetIndex(), -- 刷新界面
    RANK_HALL_GET_MYRANK                = g_GetIndex(), -- 大厅排行榜获取玩家自己的数据
    RANK_HALL_RETURN_MYRANK             = g_GetIndex(), -- 返回大厅排行榜玩家自己的数据
    

    RANKPOP_GET_USER_INFO               = g_GetIndex(), -- 排行榜获取玩家信息
    RANKPOP_GET_USER_INFO_RESPONSE      = g_GetIndex(), -- 返回排行榜玩家信息
    RANKPOP_GET_USER_INFO_RESPONSE1      = g_GetIndex(), -- 返回排行榜玩家信息
    RANKPOP_TAB_CHANGED                 = g_GetIndex(), -- 排行榜tab切换
    
    -- 设置
    SETTING_LOGOUT                      = g_GetIndex(); -- 登出账号


    -- gift
    GIFT_GET_LIST                       = g_GetIndex(); -- 获取礼物列表
    GIFT_GET_LIST_SUCCESS               = g_GetIndex(); -- 获取礼物列表
    GIFT_EVENT_LEFT_TAB_CHANGED         = g_GetIndex(); -- 左侧tab 改变
    GIFT_SEND_GIFT                      = g_GetIndex(), -- s赠送礼物
    GIFT_SEND_GIFT_SUCC                 = g_GetIndex(), -- s赠送礼物成功
    GIFT_SEV_CHANGE_GIFT                = g_GetIndex(), -- s修改礼物请求
    GIFT_NOTIFY_GIFT_USED               = g_GetIndex(), -- s修改玩家座位礼物
    
    --礼物页面 
    -- SHOW_GIFT_DIALOG                            = g_GetIndex();
    HIDE_GIFT_DIALOG                            = g_GetIndex();
    SHOW_GIFT_OPERATE                           = g_GetIndex();
    HIDE_GIFT_OPERATE                           = g_GetIndex();
    SHOW_GIFT_DUE                               = g_GetIndex();
    HIDE_GIFT_DUE                               = g_GetIndex();
    SHOW_GIFT_GLORY                             = g_GetIndex();
    HIDE_GIFT_GLORY                             = g_GetIndex();
    SHOW_GIFT_NORMAL                            = g_GetIndex();
    HIDE_GIFT_NORMAL                            = g_GetIndex();
    --礼物
    STORE_POPUP_TAB_CHANGE                  = g_GetIndex();
    OPEN_GIFT_POPUP                         = g_GetIndex();
    GIFT_BUY_FOR_SELF                       = g_GetIndex();
    GIFT_BUY_FOR_PERSON                     = g_GetIndex();
    GIFT_BUY_FOR_TABLE                      = g_GetIndex();
    GIFT_USE                                = g_GetIndex();
    QUICKLY_SALE_ALL_OVERDUE_GIFT           = g_GetIndex();--一键出售所有过期礼物
    SALE_OVERDUE_GIFT                       = g_GetIndex();--卖出过期礼物
    ROLL_COLLECT_REQUEST                    = g_GetIndex();--请求上报
    ROLL_COLLECT_UPDATAE_STATUS             = g_GetIndex();--跟新玩偶数据

    GIFT_CATEGORY_TAG_CHANGE                = g_GetIndex();--GiftDialog分类改变通知GiftManager
    GIFT_SALE_BUTTON_STATUS_CHANGE_DARK     = g_GetIndex();
    GIFT_SALE_BUTTON_STATUS_CHANGE_LIGHT    = g_GetIndex();
    GIFT_DIALPG_ON_POPUP_END                = g_GetIndex();--弹出GiftDialog后加载礼物数据
    
    -- 用户信息 界面 
    USERINFOPOP_SEND_PROP                   = g_GetIndex();--发送互动道具
    USERINFOPOP_SEND_CHIP                   = g_GetIndex(), -- 赠送筹码
    USERINFOPOP_SEND_CHIPS_FAIL             = g_GetIndex(), -- 赠送筹码失敗
    USERINFOPOP_SEND_CHIPS_SUCC             = g_GetIndex(), -- 赠送筹码成功
    USERINFOPOP_SEND_PROP_SUCC              = g_GetIndex(), -- 发送互动道具成功
    USERINFO_PLAY_ADD_FRIEND_ANIM           = g_GetIndex(), -- 发送添加好友动画
    REQUEST_USER_PROP_DATA                  = g_GetIndex();--用户道具信息
    USERINFOPOP_SEV_ADD_FRIEND              = g_GetIndex(), -- 添加好友

    -------NormalSelections -------
    NORMAL_SELECTIONS_UPDATE_TABAR_INDEX = g_GetIndex();
    NORMAL_SELECTIONS_UPDATE_SORT_TYPE = g_GetIndex();
    NORMAL_SELECTIONS_UPDATE_DISPLAY_TYPE = g_GetIndex();
    NORMAL_SELECTIONS_UPDATE_FILTER = g_GetIndex();
    NORMAL_SELECTIONS_SEARCH_ROOM = g_GetIndex();
    NORMAL_SELECTIONS_REFRESH_ROOM = g_GetIndex();
    NORMAL_SELECTIONS_FORCE_UPDATE = g_GetIndex();

    NORMAL_SELECTIONS_UPDATE_DISPLAY = g_GetIndex();
    NORMAL_SELECTIONS_UPDATE_GRAPH_INFO = g_GetIndex();
    NORMAL_SELECTIONS_UPDATE_LIST_INFO = g_GetIndex();

    NORMAL_SELECTIONS_QUICKSTART  = g_GetIndex(); -- 快速进入游戏

    UPGRADE_ACCOUNT_HIDE_UPGRADE_BTN = g_GetIndex();
    ---------------------DailyTask Start--------------------------
    DAILYTASK_EVENT_REQUEST_DATA = g_GetIndex(); --获取每日任务数据
    DAILYTASK_EVENT_REQUEST_DATA_SUCCESS = g_GetIndex(); --获取每日任务数据成功
    DAILYTASK_EVENT_GET_REWARD_SUCCESS = g_GetIndex(); --领取每日任务奖励成功
    DAILYTASK_EVENT_SHARE_SUCCESS = g_GetIndex();
    ---------------------DailyTask End----------------------------    

    -------MttSelections -------
    MTT_GET_LIST_REQUEST                   = g_GetIndex();
    MTT_GET_LIST_REQUEST1                  = g_GetIndex();
    MTT_DELETE_LIST_EVENT                  = g_GetIndex();
    MTT_APPLY_REQUEST                      = g_GetIndex(); -- 报名
    MTT_CANCEL_REQUEST                     = g_GetIndex();--取消报名
    MTT_WATCH_REQUEST                      = g_GetIndex();--观看比赛
    MATCH_HALL_WATCH_TOURNAMENT            = g_GetIndex();--
    MATCH_HALL_ENTER_ROOM                  = g_GetIndex();--进入房间
    SHOW_MTT_SINGLE_MATCH                  = g_GetIndex();--
    MTT_WATCH                              = g_GetIndex();--观看比赛
    MTT_SHOW_ALLPY_SUCC_POP                = g_GetIndex();--显示报名成功弹窗
    MTT_SHOW_APPLY_WAY_POP                 = g_GetIndex();--显示报名方式选择弹窗
    MTT_REFRESH_SUCC                       = g_GetIndex();--下拉刷新完成
    MTT_CANCEL_SIGN_SCUU                   = g_GetIndex();-- 取消报名成功
    MTT_DETAIL_CLOSE_POP                   = g_GetIndex();-- 关闭详情弹窗
    REQUEST_QUICK_START                    = g_GetIndex();

    ----------------------小喇叭socket --------------------------------

    
    -------room -------
    ROOM_CONNECT_SUCCESS                      = g_GetIndex();  --房间socket连接成功
    ROOM_LOGIN_SUCCESS                        = g_GetIndex();  --房间登录成功
    ROOM_LOGIN_FAIL                           = g_GetIndex();  --房间登录失敗
    ROOM_RE_LOGIN                             = g_GetIndex();  --重新登录房间
    ROOM_LOGOUT_SUCCESS                       = g_GetIndex();  --登出成功
    ROOM_USER_BUY_IN                          = g_GetIndex();  --买入
    ROOM_USER_SIT_DOWN                        = g_GetIndex();  --用戶坐下
    ROOM_USER_STAND_UP                        = g_GetIndex();  --用戶站起
    ROOM_GAME_START                           = g_GetIndex();  --牌局开始
    ROOM_PUBLIC_CARD_FLOP                     = g_GetIndex();  --翻公共牌
    ROOM_PUBLIC_CARD_TURN                     = g_GetIndex();  --翻公共牌
    ROOM_PUBLIC_CARD_RIVER                    = g_GetIndex();  --翻公共牌
    ROOM_TURN_TO_OPERATE                      = g_GetIndex();  --轮到操作
    ROOM_OPERATE_SUCCESS                      = g_GetIndex();  --操作成功
    ROOM_CHAT_SEND_EXPRESSION                 = g_GetIndex();  --发送表情
    ROOM_POTS_INFO                            = g_GetIndex();  --奖池信息
    ROOM_GAME_OVER_DATA                       = g_GetIndex();  --牌局结束
    ROOM_SHOW_HAND                            = g_GetIndex();  --亮出手牌
    ROOM_INIT_VIEW                            = g_GetIndex();  -- 初始化房间数据
    SHOW_TOP_TRUMPET_TIP                      = g_GetIndex();  --喇叭消息
    ROOM_AUTO_BUY_IN                          = g_GetIndex();  --自动补充筹码
    ROOM_PRE_SWITCH_ROOM                      = g_GetIndex();  --切换房间
    ROOM_SWITCH_ROOM                          = g_GetIndex();  --直接切换房间
    ROOM_POP_SCENE                            = g_GetIndex();  --退出房间
    GET_USER_HDDJ_NUMBER                      = g_GetIndex();  --获取互动道具 数量
    
    --mtt room
    SHOW_REBUYING_TIPS                        = g_GetIndex();--展示有其他用户正在rebuy
    HIDDEN_REBUYING_TIPS                      = g_GetIndex();--g关闭其他用户正在rebuy
    CLOSE_REBUY                               = g_GetIndex();--关闭rebuy相关的弹窗
    CLOSE_ADDON                               = g_GetIndex();
    SHOW_MATCH_NOT_START_TIPS                 = g_GetIndex();--提示mtt不开赛
    NEW_MTT_SEND_REBUY                        = g_GetIndex();--发送 rebuy
    NEW_MTT_SEND_ADDON                        = g_GetIndex();--发送 addon
    MTT_MY_MATCH_TOP_TIPS                     = g_GetIndex();--我的比赛开赛提醒
    MTT_GLOBAL_MATCH_TOP_TIPS                 = g_GetIndex();--所有比赛开赛提醒
    ROOM_MTT_RESULT_POP_CLOSE                 = g_GetIndex();--结算弹窗关闭

    -------夺金岛--------
    SUPER_LOTTO_IS_NEXT_BUY                     = g_GetIndex();
    SUPER_LOTTO_IS_AUTO_BUY                     = g_GetIndex();
    ROOM_EXTRA_LOGIN_INFO                       = g_GetIndex();

    SUPER_LOTTO_AUTO_BUY                        = g_GetIndex(); --夺金岛请求自动买入
    -- SUPER_LOTTO_DELAY_AUTO_BUY                  = g_GetIndex(); --夺金岛请求自动买入
    SUPER_LOTTO_BUY_NEXT                        = g_GetIndex(); --夺金岛请求买入下一局
    SUPER_LOTTO_CANCEL_AUTO_BUY                 = g_GetIndex(); --夺金岛请求取消自动买入

    SUPER_LOTTO_BOUGHT                          = g_GetIndex(); --夺金岛购买成功回调函数
    ROOM_REQ_CARD_CALCULATE                     = g_GetIndex(); --req 成牌概率
    ROOM_OPERATION_HANDLER                      = g_GetIndex(); --room 一些动作回调
    -------ROOM CHAT begin--------
    ROOM_CHAT_SEND_QUICK_MESSAGE                = g_GetIndex(); --发送快捷聊天信息
    ROOM_REMOVE_CHAT_POP                        = g_GetIndex();  --关闭聊天弹窗
    ROOM_CHAT_SMALLL_TRUMPET                    = g_GetIndex(); --发送小喇叭消息
    ROOM_CHAT_BIG_TRUMPET                       = g_GetIndex(); --发送大喇叭消息
    ROOM_CHAT_SEND_MESSAGE                      = g_GetIndex(); --发送聊天信息
    ROOM_CHAT_SEND_EMOTION                      = g_GetIndex(); --发送聊天表情
    ROOM_CHAT_SMALLL_TRUMPET_SUCCESS            = g_GetIndex(); --发送小喇叭消息成功
    -------ROOM CHAT end ---------

    ------- 私人房大厅 begin -------
    PRIVATE_HALL_CFG_REQUEST    = g_GetIndex(); --请求私人房大厅配置
    PRIVATE_HALL_CFG_RESPONSE   = g_GetIndex(); --响应私人房大厅配置
    PRIVATE_ROOM_CREATE_REQUEST = g_GetIndex(); --请求创建私人房
    PRIVATE_ROOM_BECOME_VIP     = g_GetIndex(); --成为vip
    PRIVATE_ROOM_CHECK_PASSWORD = g_GetIndex(); --核对密码
    PRIVATE_ROOM_GET_PWD_REQUEST  = g_GetIndex(); --获取私人房間密码信息
    PRIVATE_ROOM_GET_PWD_RESPONSE = g_GetIndex(); --响应私人房間密码信息
    PRIVATE_ROOM_MOTIFY_PWD_REQUEST = g_GetIndex(); -- 修改私人房間密码
    PRIVATE_ROOM_OWNER_CHANGED  = g_GetIndex(); -- 私人房拥有者变化了
    PRIVATE_ROOM_BACK_TO_HALL   = g_GetIndex(); -- 踢出私人房间，返回到大厅
    ------- 私人房大厅 end -------

    --------------------- 老虎机 ----------------------------
    SLOT_RESULT = g_GetIndex(); -- 老虎机返回结果
    SLOT_CONNECT_RESULT = g_GetIndex(); -- 老虎机socket连接结果
    SLOT_PLAY = g_GetIndex(); -- 玩老虎机
    SLOT_CALCULATOR = g_GetIndex(); -- 算牌器计算概率
    SLOT_SHOW_LOTTERY = g_GetIndex(); -- 显示牌型
    SLOT_SHOW_LUCKY = g_GetIndex(); -- 显示幸运牌
    SLOT_SHOW_TIPS = g_GetIndex(); -- 显示提示信息
    SLOT_PLAY_ANIM = g_GetIndex(); -- 老虎机动画
    SLOT_PLAY_FAIL = g_GetIndex(); -- 网络异常，取消老虎机

    ------- 活动web end -------

    ------- 荷官界面 begin -------
    DEALERPOP_SEND_CHIP = g_GetIndex(); -- 荷官界面，发送筹码
    SEND_CHIP_FUNISH                      = g_GetIndex();--发送筹码动画完毕
    ------- 荷官界面 end -------

    ------- sng 大厅 begin ------
    SNG_LOBBY_REFRESH_DATA = g_GetIndex();
    GET_SNG_MTT_REFRESH = g_GetIndex();
    SNG_LOGIN_TO_ROOM = g_GetIndex();
    SNG_REQ_USER_INFO_DATA = g_GetIndex();
    -------sng 大厅 end ---------
 
    --------sng 房间 begin----------
    ROOM_SNG_END_BACK_TO_LOBBY = g_GetIndex();
    ROOM_SNG_END_PLAY_AGAIN =g_GetIndex();
    ROOM_SNG_RESULT_POP_CLOSE = g_GetIndex();
    --------sng 房间 end------------
    ----------按鍵事件--------------
    EVENT_BACK = g_GetIndex();

    ------- 新手教程 begin -------
    BEGINNER_TUTORIAL_OPERATIONAL = g_GetIndex(); -- 执行操作
    BEGINNER_TUTORIAL_DO_PRIVIOUS = g_GetIndex(); --上一步
    BEGINNER_TUTORIAL_DO_NEXT = g_GetIndex();     -- 下一步
    BEGINNER_TUTORIAL_SEND_GIFT = g_GetIndex();     -- 赠送礼物
    BEGINNER_TUTORIAL_COMPLETE_LEARNING = g_GetIndex();     -- 完成教学
    BEGINNER_TUTORIAL_REWARD = g_GetIndex(); -- 新手教程领奖
    BEGINNER_TUTORIAL_EXIT = g_GetIndex(); -- 退出新手教程
    ------- 新手教程 end   -------

    --- 新手奖励 start ---
    NOVICE_REWARD_REFRESH = g_GetIndex(), -- 获取到数据刷新UI
    NOVICE_REWARD_RECEIVE = g_GetIndex(), --领取奖励
    NOVICE_REWARD_RECEIVE_SUCCESS = g_GetIndex(), -- 新手奖励领取成功
    --- 新手奖励 end   ---

    FILE_DOWNLOAD_PROGRESS = g_GetIndex(), -- 文件下载进度

    UPDATE_USER_DATA = g_GetIndex(),-- 更新界面用户数据显示

    UPDATE_USER_LEVEL = g_GetIndex(),-- 更新用户等级显示

    -- feedback -- 
    FEEDBACK_ONSHOW = g_GetIndex(), --反馈弹框打开
    FEEDBACK_SUBMIT_SUCCESS = g_GetIndex(), --反馈成功
}

return SceneEvent


