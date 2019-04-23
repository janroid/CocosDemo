local baseView = require("subviews.questionBaseView")
local LoginQuestion = class("LoginQuestion",baseView)

function LoginQuestion:showData()
    local gameString = cc.exports.GameString
    for i=14,12,-1 do
        local itemData = {title = gameString.get("str_help_que" .. tostring(i)),content = gameString.get("str_help_ans" .. tostring(i))}
        self:addItem(itemData)
    end
end
function LoginQuestion:ctor(...)
    baseView.ctor(self,...)
end

return LoginQuestion