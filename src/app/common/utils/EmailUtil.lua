local EmaiUtil = {}

EmaiUtil.S_FORMAT_RESULT = {
    STR_IS_EMPTY        = 1; -- 邮箱账号为空
    INCORRECT_FORMAT    = 2; -- 邮箱格式错误
    CORRECT_FORMAT      = 3; -- 邮箱格式正确
}

-- 判断邮箱格式是否正确
function EmaiUtil.judgeEmailFormat(email)
    if email == nil or string.trim(email) == "" then
        return EmaiUtil.S_FORMAT_RESULT.STR_IS_EMPTY
    elseif string.isRightEmail(email) then
        return EmaiUtil.S_FORMAT_RESULT.CORRECT_FORMAT
    end
    return EmaiUtil.S_FORMAT_RESULT.INCORRECT_FORMAT
end

return EmaiUtil