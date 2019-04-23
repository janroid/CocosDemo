local showTypeLogin = 1
local showTypeHall = 2

local config = {
    showType = {
        showTypeLogin = showTypeLogin,
        showTypeHall = showTypeHall,
    },
    defaultShowType = showTypeHall,
    subviews = {
        --常见问题
        ["comQuestion"] = require("subviews.comQuestion"),
        ["payQuestion"] = require("subviews.payQuestion"),
        ["accountQuestion"] = require("subviews.accountQuestion"),
        ["loginQuestion"] = require("subviews.loginQuestion"),

        --基本规则
        ["spePokerType"] = require("subviews.spePokerType"),
        ["detailRule"] = require("subviews.detailRule"),
        ["betRule"] = require("subviews.betRule"),
        ["nounRule"] = require("subviews.nounRule"),

        --等级说明
        ["expSystem"] = require("subviews.expSystem"),
        ["levelSystem"] = require("subviews.levelsSystem"),

        --大厅问题反馈
        ["hallPayFeedback"] = require("subviews.hallPayFeedback"),
        ["hallAccountFeedback"] = require("subviews.hallAccountFeedback"),
        ["hallBugFeedback"] = require("subviews.hallBugFeedback"),
        ["hallAdviseFeedback"] = require("subviews.hallAdviseFeedback"),

        --登录问题反馈
        ["loginFeedback"] = require("subviews.loginFeedback"),
    },
    checkEmailPatternStr = "^[%d%a_.]+@[%d%a]+[.%a]+$", 
    checkPhonePatternStr = "^%d%d%d%d%d%d%d%d%d%d%d$",
}

function config.checkContactValid(content)
    if content == string.match( content,config.checkEmailPatternStr) then
        return true,config.checkEmailPatternStr
    end
    if content == string.match( content,config.checkPhonePatternStr) then
        return true,config.checkPhonePatternStr
    end
    if g_AppManager:getAppVer() == g_AppManager.S_APP_VER.FB_VN then
        return true,config.checkPhonePatternStr
    end
    return ret
end

function config.getSubViews(type)
    local gameString = cc.exports.GameString
    local ret  = {
        {key = gameString.get("str_help_title1"),
        content  = {
                {title = gameString.get("str_help_title1"),path = config.subviews.comQuestion},
                {title = gameString.get("str_help_title5"),path = config.subviews.payQuestion},
                {title = gameString.get("str_help_title6"),path = config.subviews.accountQuestion},
                {title = gameString.get("str_help_title7"),path = config.subviews.loginQuestion}}},
        {key = gameString.get("str_help_title2"),
        content  = {
                {title = gameString.get("str_help_title10"),path = config.subviews.spePokerType},
                {title = gameString.get("str_help_title11"),path = config.subviews.detailRule},
                {title = gameString.get("str_help_title12"),path = config.subviews.betRule},
                {title = gameString.get("str_help_title13"),path = config.subviews.nounRule}}},
        {key = gameString.get("str_help_title3"),
        content  = {
                {title = gameString.get("str_help_title14"),path = config.subviews.expSystem},
                {title = gameString.get("str_help_title15"),path = config.subviews.levelSystem}}}
    }
    local hallFeedback = {key = gameString.get("str_help_title4"),
        content  = {
            {title = gameString.get("str_help_title5"),path = config.subviews.hallPayFeedback},
            {title = gameString.get("str_help_title6"),path = config.subviews.hallAccountFeedback},
            {title = gameString.get("str_help_title8"),path = config.subviews.hallBugFeedback},
            {title = gameString.get("str_help_title9"),path = config.subviews.hallAdviseFeedback}}}
    local loginFeedback = {key = gameString.get("str_help_title4"),
        noTitle = true,
        content  = {
            {path = config.subviews.loginFeedback}}}
    if type == nil then
        type = config.showType.defaultShowType
    end
    if type ~= config.showType.showTypeLogin and type ~= config.showType.showTypeHall then
        error("必须提供显示种类")
    end
    if type == config.showType.showTypeLogin then
        ret[ #ret + 1] = loginFeedback
    else
        ret[ #ret + 1] = hallFeedback
    end
    return ret
end

return config