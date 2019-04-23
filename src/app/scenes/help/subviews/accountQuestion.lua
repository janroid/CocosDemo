local baseView = require("subviews.questionBaseView")
local AccountQuestion = class("AccountQuestion",baseView)

function AccountQuestion:showData()
    local gameString = cc.exports.GameString
    for i=11,10,-1 do
        local itemData = {title = gameString.get("str_help_que" .. tostring(i)),content = gameString.get("str_help_ans" .. tostring(i))}
        self:addItem(itemData)
    end
end

function AccountQuestion:ctor(...)
    baseView.ctor(self,...)
end

return AccountQuestion