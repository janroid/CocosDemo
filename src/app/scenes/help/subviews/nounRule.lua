local BaseView = require("subviews.detailRuleBaseView")
local View = class("BetRule",BaseView)

function View:ctor(...)
    self:initView(...)
    self:setContent()
end

function View:setContent()
    local gameString = cc.exports.GameString
    local data = {}
    for i=1,14 do
        local title = gameString.get("str_help_noun_tit" .. tostring(i))
        local content = gameString.get("str_help_noun_des" .. tostring(i))
        data[#data + 1] = {title = title,content = content}
    end
    self:setData(data)
end

return View