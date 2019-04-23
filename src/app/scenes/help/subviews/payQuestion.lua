local baseView = require("subviews.questionBaseView")
local PayQuestion = class("PayQuestion",baseView)

function PayQuestion:showData()
    local gameString = cc.exports.GameString
    for i=9,9,-1 do
        local itemData = {title = gameString.get("str_help_que" .. tostring(i)),content = gameString.get("str_help_ans" .. tostring(i))}
        self:addItem(itemData)
    end
end

function PayQuestion:ctor(...)
    baseView.ctor(self,...)
end

return PayQuestion  