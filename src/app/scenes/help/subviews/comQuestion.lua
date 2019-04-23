local baseView = require("subviews.questionBaseView")
local ComQuestion = class("ComQuestion",baseView)

function ComQuestion:showData()
    local gameString = cc.exports.GameString
    for i=8,1,-1 do
        local itemData = {title = gameString.get("str_help_que" .. tostring(i)),content = gameString.get("str_help_ans" .. tostring(i))}
        self:addItem(itemData)
    end
end

function ComQuestion:ctor(...)
    baseView.ctor(self,...)
end

return ComQuestion