local BaseView = require("subviews.detailRuleBaseView")
local View = class("BetRule",BaseView)

function View:ctor(...)
    self:initView(...)
    self:setContent()
end

function View:setContent()
    local gameString = cc.exports.GameString
    local data = {}
    for i=1,10,2 do
        local title = gameString.get("str_help_rule_dec" .. tostring(20 + i))
        local content = gameString.get("str_help_rule_dec" .. tostring(21 + i))
        data[#data + 1] = {title = title,content = content}
    end
    self:setData(data)
end

return View