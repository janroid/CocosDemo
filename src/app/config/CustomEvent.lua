
local getIndex = function()
    local prefix = "cus_e_"

    return prefix .. g_GetIndex()
end

local CustomEvent = {
    POP_DESTORY = getIndex(); -- 弹框销毁
    POP_HIDDEN = getIndex();  -- 弹框隐藏
    EVENT_BACK = getIndex();  -- 返回键事件\
    APP_PAUSE = getIndex(); -- 应用切换到后台
    APP_RESUME = getIndex(); -- 应用恢复到前台

    --  login
    LOGIN_REGISTER = getIndex(); -- 注册事件
    LOGIN_LOGIN = getIndex(); -- 登陆事件
    LOGIN_RPS_LOGIN = getIndex(); -- 登陆回调
    LOGIN_RPS_REGISTER = getIndex(); -- 注册回调
}

return CustomEvent