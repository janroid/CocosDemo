
local getIndex = function()
    local prefix = "cus_e_"

    return prefix .. g_GetIndex()
end

local CustomEvent = {
    POP_DESTORY = getIndex(); -- 弹框销毁
    POP_HIDDEN = getIndex();  -- 弹框隐藏
    EVENT_BACK = getIndex();  -- 返回键事件

}

return CustomEvent