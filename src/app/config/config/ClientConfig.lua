--[[
    author:{JanRoid}
    time:2018-1-14
    Description: 客户端常量定义
]]

local ClientConfig = {}

-- 老虎机提示消息类型
ClientConfig.SLOT_MSG_TYPE = {
    SLOT_WIN_MSG = 1;       -- 中奖消息
    SLOT_RECONNECT_MSG = 2; -- 重连消息
    SLOT_FAIL_MSG = 3;      -- 失败消息 
    SLOT_LESS_CHIPS = 4;    -- 游戏币不足
    SLOT_CONNECT_FAIL = 5;  -- 断开连接
    SLOT_RECON_SUCC = 6; --重連成功
}


return ClientConfig