--[[
    author:{JanRoid}
    time:2019-1-4
    Description: 开关配置表，游戏中需要使用开关都定义到这个文件
]] 

local FeatureConfig = {}

FeatureConfig.STR_COMMON_BIG_NUM_TOKEN				= { --大數字單位（千、百萬、十億、萬億）
    [1] = "K";
    [2] = "M";
    [3] = "B";
    [4] = "T";
}

FeatureConfig.STR_ROOM_GAME_REVIEW_POP_UP_IS_OPEN = true;                --牌局回顧開關(0:關閉,1:打開)

return FeatureConfig