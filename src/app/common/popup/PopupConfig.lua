--[[
    author:{JanRoid}
    time:2018-10-30 14:42:43
    Description: 注册popwindow
]]

local PopupConfig = {}

PopupConfig.S_POPID = {
    -- test
    --POP_DEMO = getIndex();
    POP_STORE = g_GetIndex();
    POP_SETTING = g_GetIndex();
    POP_BANKRUPT = g_GetIndex();
    POP_GIFT = g_GetIndex();        --礼物
    POP_GIFT_DETAILE = g_GetIndex(); -- 礼物详情
    POP_CARD_CALCULATOR = g_GetIndex(); -- 算牌器

    --POP_DEMO = g_GetIndex();
    LOGIN_EMAIL_POP             = g_GetIndex(), -- email登录
    CHANGE_PWD_POP              = g_GetIndex(), -- 修改密码
    RESET_PWD_POP               = g_GetIndex(), -- 重置密码

    USER_INFO_POP               = g_GetIndex(), -- 用户信息
    SET_HEAD_POP                = g_GetIndex(), -- 设置头像
    OTHER_INFO_POP              = g_GetIndex(), -- 他人信息
    SAFE_BOX_POP                = g_GetIndex(), -- 保险箱
    SAFE_BOX_SET_PASSWORD_POP   = g_GetIndex(), -- 保险箱设置密码
    SAFE_BOX_PASSWORD_POP       = g_GetIndex(),
    MAIL_BOX_POP                = g_GetIndex(),  -- 邮箱
    MAIL_BOX_FILL_INFO_POP       = g_GetIndex(),  -- 邮箱填写资料

    FRIEND_POP                  = g_GetIndex(),
    ACHIEVEMENT_POP              = g_GetIndex(),
    RANK_POP                    = g_GetIndex(), -- 排行榜
    RANK_PLAYER_INFO_POP        = g_GetIndex(), -- 排行榜好友信息弹窗
    
    LOGIN_REWARD_POP            = g_GetIndex(), -- 登录奖励

    HELP_POP                    = g_GetIndex(), -- 帮助页面

    ACCOUNT_UPGRADE_POP         = g_GetIndex(), -- 账号升级
    DEFAULT_ACCOUNT_POP         = g_GetIndex(), -- 有原来的账号

    DAILYTASK_POP               = g_GetIndex(), -- 每日任务
    ROOMTASK_POP                = g_GetIndex(), --房间内任务

    CHOOSE_MTT_OR_SNG_POP         = g_GetIndex(), -- SNG MTT 选择

    ROOM_CHAT_POP               = g_GetIndex(),
    
    BIG_WHEEL_POP               = g_GetIndex(), -- 大转盘
    BIG_WHEEL_HELP_POP          = g_GetIndex(), -- 大转盘帮助
    SLOT_POP                    = g_GetIndex(), -- 老虎机

    SUPER_LOTTO_POP               = g_GetIndex(), -- 夺金岛
    SUPER_LOTTO_RULE_POP          = g_GetIndex(), -- 夺金岛说明
    SUPER_LOTTO_REWARD_POP         = g_GetIndex(), -- 夺金岛中奖
    SUPER_LOTTO_REWARD_LIST_POP    = g_GetIndex(), -- 夺金岛中奖记录

    DEALER_POP                     = g_GetIndex(), -- 荷官弹窗
    DEALER_CHANGE_POP               = g_GetIndex(), -- 荷官更换弹窗

    PRIVATE_HALL_POP            = g_GetIndex(), -- 私人房大厅   
    ACTIVITY_WEB_POP            = g_GetIndex(), -- 活动网页 
    ROOM_GAME_REVIEW_DETAIL     = g_GetIndex(), -- 房间牌局回顾详请
    ROOM_GAME_REVIEW_POP        = g_GetIndex(), -- 房间牌局回顾弹窗
    
    SNG_LOBBY_HELP_POP          =g_GetIndex(), --SNG大厅帮助弹窗
    SNG_REWARD_POP              = g_GetIndex(), --sng奖励弹窗--rank<= 3
    SNG_RESULT_POP              = g_GetIndex(), --sng结算弹窗-rank>3
    
    TUTORIAL_DEALER_POP         = g_GetIndex(), -- 新手教程荷官弹窗，使用继承复写其中某些方法
    TUTORIAL_GIFT_DETAILS_POP   = g_GetIndex(), -- 新手教程礼物详情弹窗，使用继承复写其中某些方法
    TUTORIAL_REWARD_POP         = g_GetIndex(), -- 新手教程入口及领奖弹窗
    NOVICE_REWARD_POP           = g_GetIndex(), -- 新手奖励
    ROOM_BUY_IN                 = g_GetIndex(), -- 房间买入弹框
    ROOM_INVITE_FRIEND          = g_GetIndex(), -- 房间邀请弹框
    BACKKEY_LOGOUT              = g_GetIndex(), -- 大厅返回键返回弹窗
    
    MTT_SIGNUP_SUCC_POP         = g_GetIndex(), -- mtt 报名成功
    MTT_SIGNUP_WAY_POP          = g_GetIndex(), -- mtt 报名方式选择
    MTT_HELP_POP                = g_GetIndex(), -- mtt帮助弹框  
    MTT_DETAIL_POP              = g_GetIndex(), -- mtt详情弹框  
    MTT_RESULT_POP              = g_GetIndex(), -- mtt 结算弹窗 前三名
    MTT_OTHER_RESULT_POP        = g_GetIndex(), -- mtt 结算弹窗 其他名称
    MTT_ADDON_POP               = g_GetIndex(), -- mtt addon
    MTT_REBUY_POP               = g_GetIndex(), -- mtt rebuy  

    PRIVACY_POLICY_POP          = g_GetIndex(), -- PRIVACY_POLICY_POP  
}

-- [key] = {path = "xxx/xxx",name = "xxx"}
PopupConfig.S_FILES = {
    -- test
    -- [PopupConfig.S_POPID.POP_DEMO] = {path = "dev.pop", name = "PopDemo"};
    [PopupConfig.S_POPID.POP_STORE] = {path = "app.scenes.store", name = "StorePop"};
    [PopupConfig.S_POPID.POP_GIFT] = {path = "app.scenes.gift", name = "GiftPop"};
    [PopupConfig.S_POPID.POP_GIFT_DETAILE] = {path = "app.scenes.gift", name = "GiftDetailePop"};
    [PopupConfig.S_POPID.POP_CARD_CALCULATOR] = {path = "app.scenes.cardCalculator", name = "CardCalculatorPop"};
    [PopupConfig.S_POPID.POP_SETTING] = {path = "app.scenes.setting", name = "SettingPop"};
    [PopupConfig.S_POPID.POP_BANKRUPT] = {path = "app.scenes.bankruptcy", name = "BankruptcyPop"};
    [PopupConfig.S_POPID.LOGIN_EMAIL_POP] = {path = "app.scenes.loginEmail", name = "LoginEmailPop"};
    [PopupConfig.S_POPID.CHANGE_PWD_POP]  = {path = "app.scenes.changePwd", name = "ChangePwdPop"};
    [PopupConfig.S_POPID.RESET_PWD_POP]   = {path = "app.scenes.resetPwd", name = "ResetPwdPop"};
    [PopupConfig.S_POPID.USER_INFO_POP] = {path = "app.scenes.userInfo", name = "UserInfoPop"};
    [PopupConfig.S_POPID.SET_HEAD_POP] = {path = "app.scenes.userInfo", name = "SettingHeadPop"};
    [PopupConfig.S_POPID.OTHER_INFO_POP] = {path = "app.scenes.userInfo", name = "OtherInfoPop"};
    [PopupConfig.S_POPID.SAFE_BOX_POP] = {path = "app.scenes.safeBox", name = "SafeBoxPop"};
    [PopupConfig.S_POPID.SAFE_BOX_SET_PASSWORD_POP] = {path = "app.scenes.safeBox", name = "SafeBoxSetPasswordPop"};
    [PopupConfig.S_POPID.SAFE_BOX_PASSWORD_POP] = {path = "app.scenes.safeBox", name = "SafeBoxPasswordPop"};
    [PopupConfig.S_POPID.MAIL_BOX_POP] = {path = "app.scenes.mailBox", name = "MailBoxPop"};
    [PopupConfig.S_POPID.MAIL_BOX_FILL_INFO_POP] = {path = "app.scenes.mailBox", name = "MailFillInfoPop"};
    [PopupConfig.S_POPID.FRIEND_POP] = {path = "app.scenes.friend", name = "FriendPop"};
    [PopupConfig.S_POPID.ACHIEVEMENT_POP] = {path = "app.scenes.achievement", name = "AchievementPop"};

    [PopupConfig.S_POPID.RANK_POP] = {path = "app.scenes.rank.rankMain", name = "RankPop"};
    [PopupConfig.S_POPID.LOGIN_REWARD_POP] = {path = "app.scenes.loginReward", name = "LoginRewardPop"};
    [PopupConfig.S_POPID.RANK_PLAYER_INFO_POP] = {path = "app.scenes.userInfo", name = "PlayerInfoPop"};
    [PopupConfig.S_POPID.HELP_POP] = {path = "app.scenes.help", name = "HelpPop"};
    [PopupConfig.S_POPID.ACCOUNT_UPGRADE_POP] = {path = "app.scenes.accountUpgrade", name = "AccountUpgradePop"};
    [PopupConfig.S_POPID.DEFAULT_ACCOUNT_POP] = {path = "app.scenes.defaultAccount", name = "DefaultAccountPop"};
    
    [PopupConfig.S_POPID.DAILYTASK_POP] = {path = "app.scenes.dailyTask", name = "DailyTaskPop"};
    [PopupConfig.S_POPID.ROOMTASK_POP] = {path = "app.scenes.dailyTask", name = "RoomTaskPop"};
    
    [PopupConfig.S_POPID.CHOOSE_MTT_OR_SNG_POP] = {path = "app.scenes.chooseMTTorSNG", name = "ChooseMTTorSNGpop"};
    [PopupConfig.S_POPID.ROOM_CHAT_POP] = {path = "app.scenes.chat",name = "ChatPop"};
    [PopupConfig.S_POPID.BIG_WHEEL_POP] = {path = "app.scenes.bigWheel", name = "BigWheelPop"};
    [PopupConfig.S_POPID.BIG_WHEEL_HELP_POP] = {path = "app.scenes.bigWheel", name = "BigWheelHelpPop"};

    [PopupConfig.S_POPID.SUPER_LOTTO_POP] = {path = "app.scenes.superLotto", name = "SuperLottoPop"};
    [PopupConfig.S_POPID.SUPER_LOTTO_RULE_POP] = {path = "app.scenes.superLotto", name = "SuperLottoRulePop"};
    [PopupConfig.S_POPID.SUPER_LOTTO_REWARD_POP] = {path = "app.scenes.superLotto", name = "SuperLottoRewardPop"};
    [PopupConfig.S_POPID.SUPER_LOTTO_REWARD_LIST_POP] = {path = "app.scenes.superLotto", name = "SuperLottoRewardListPop"};
    [PopupConfig.S_POPID.DEALER_POP] = {path = "app.scenes.dealer", name = "DealerPop"};
    [PopupConfig.S_POPID.DEALER_CHANGE_POP] = {path = "app.scenes.dealer", name = "DealerChangePop"};
    [PopupConfig.S_POPID.PRIVATE_HALL_POP] = {path = "app.scenes.privateHall", name = "PrivateHallPop"};
    [PopupConfig.S_POPID.ACTIVITY_WEB_POP] = {path = "app.scenes.activity", name = "ActivityPop"};
    [PopupConfig.S_POPID.MTT_ADDON_POP] = {path = "app.scenes.mttRoom", name = "MttRebuyAddonPop"};
    [PopupConfig.S_POPID.MTT_REBUY_POP] = {path = "app.scenes.mttRoom", name = "MttRebuyPop"};
    [PopupConfig.S_POPID.MTT_HELP_POP] = {path = "app.scenes.mttLobbyScene", name = "MttHelpPop"};
    [PopupConfig.S_POPID.MTT_SIGNUP_SUCC_POP] = {path = "app.scenes.mttLobbyScene", name = "MTTSignupSuccPop"};
    [PopupConfig.S_POPID.MTT_SIGNUP_WAY_POP] = {path = "app.scenes.mttLobbyScene", name = "MTTSignupWayPop"};
    [PopupConfig.S_POPID.SNG_LOBBY_HELP_POP] = {path = "app.scenes.sngLobby",name = "SngLobbyHelpPop"};
    [PopupConfig.S_POPID.SNG_REWARD_POP] = {path = "app.scenes.sngRoom",name = "SNGRoomRewardPop"};
    [PopupConfig.S_POPID.SNG_RESULT_POP] = {path = "app.scenes.sngRoom",name = "SNGRoomResultPop"};
    [PopupConfig.S_POPID.TUTORIAL_DEALER_POP] = {path = "app.scenes.tutorial", name = "TutorialDealerPop"};
    [PopupConfig.S_POPID.MTT_DETAIL_POP] = {path = "app.scenes.mttLobbyScene", name = "MttDetailPop"};
    [PopupConfig.S_POPID.TUTORIAL_GIFT_DETAILS_POP] = {path = "app.scenes.tutorial", name = "TutorialGiftDetailPop"};
    [PopupConfig.S_POPID.TUTORIAL_REWARD_POP] = {path = "app.scenes.tutorial", name = "TutorialRewardPop"};
    [PopupConfig.S_POPID.NOVICE_REWARD_POP] = {path = "app.scenes.noviceReward", name = "NoviceRewardPop"};

    [PopupConfig.S_POPID.ROOM_GAME_REVIEW_DETAIL] = {path = "app.scenes.roomGameReview", name = "RoomGameReviewDetail"};
    [PopupConfig.S_POPID.ROOM_GAME_REVIEW_POP] = {path = "app.scenes.roomGameReview", name = "RoomGameReviewPop"};
    [PopupConfig.S_POPID.ROOM_BUY_IN] = {path = "app.scenes.normalRoom", name = "BuyInPop"};
    [PopupConfig.S_POPID.ROOM_INVITE_FRIEND] = {path = "app.scenes.normalRoom", name = "InviteFriendPop"};
    [PopupConfig.S_POPID.BACKKEY_LOGOUT] = {path = "app.scenes.backKeyLoginout", name = "KeyBackPop"};
    [PopupConfig.S_POPID.MTT_RESULT_POP] = {path = "app.scenes.mttRoom", name = "MttResultPop"};
    [PopupConfig.S_POPID.MTT_OTHER_RESULT_POP] = {path = "app.scenes.mttRoom", name = "MttOtherResultPop"};
    [PopupConfig.S_POPID.PRIVACY_POLICY_POP] = {path = "app.scenes.privacyPolicy", name = "PrivacyPolicyPop"};
}



return PopupConfig