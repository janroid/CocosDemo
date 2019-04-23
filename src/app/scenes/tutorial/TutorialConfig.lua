return {
    BUTTON_ENABLE ={ -- 上一步/下一步 按钮是否可点击
        PRIVIOUS_ENABLE = 1, -- 仅上一步可操作
        NEXT_ENABLE     = 2, -- 仅下一步可操作
        BOTH_ENABLE     = 3, -- 二者均可操作
        BOTH_DISABLE    = 4, -- 二者均不可操作

    },
    BUTTON_VISIBLE = { -- 上一步/下一步 按钮是否可见
        PRIVIOUS_VISIBLE = 1,-- 仅上一步可见
        NEXT_VISIBLE     = 2,-- 仅下一步可见
        BOTH_VISIBLE     = 3,-- 二者均可见
        BOTH_INVISIBLE   = 4,-- 二者均不可见
    },
    ARROW_ANIM_MOVE_DISTANCE = 20, -- 箭头动画移动的距离
    OPERATE_BTN_ENABLE = { -- 看牌、弃牌、加注按钮是否可点击
        FOLD_ENABLE      = 1;
        CHECK_ENABLE     = 2;
        RAISE_ENABLE     = 3;
        ALL_ENABLE       = 4;
        ALL_DISABLE      = 5;
    },

    SEAT_INIT_INFO = {
        [1] = {
            status = GameString.get("str_beginner_tutorial_player_a_name"),
            head = "9",
        },
        [2] = {
            status = GameString.get("str_beginner_tutorial_player_b_name"),
            head = "10",
        },
        [3] = {
            status = g_AccountInfo:getNickName(),
            head = g_AccountInfo:getSmallPic(),
        },
    },

    HANDCARD_SMALL_POSTION = { -- 小手牌时的位置
        [1] = {
            x = 0,
            y = 75,
        },
        [2] = {
            x = 0,
            y = 75,
        },
        [3] = {
            x = g_PokerCard.CARD_WIDTH*2,
            y = 60,
        },
        
    },
    HANDCARD_NORMAL_POSTION = {
        offsetX1 = 40,
        offsetX2 = 58,
        offsetY = 6,
    },
    HANDCARD_VALUE = {-- 手牌的值
        --牌面值从0x2-0xe，分别代表2、3、4、5、6、7、8、9、10、J、Q、K、A
        --花色: 1=钻石，2=梅花，3=红心，4=黑桃
        [1] = { -- 第一轮手牌
            0x40a,-- 黑桃10
            0x404,-- 黑桃4
            0x10c,-- 方片Q
            0x102,-- 方片2
            0x405,-- 黑桃5
            0x10d,-- 方片K
        },
        [2] = { -- 第二轮手牌
            0x30e, -- 红桃A
            0x302, -- 红桃2
            0x10a, -- 方片10
            0x40d, -- 黑桃K
            0x402, -- 黑桃2
            0x20a, -- 梅花10
        }
    },
    PUBLIC_CARD_VALUE = {
        [1] = {0x40b, 0x20a,0x10a,0x403, 0x309},
        [2] = {0x30b, 0x408,0x10d,0x40a, 0x30a}
    },


}