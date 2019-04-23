local baseView = require("subviews.feedbackBaseView")
local View = class("HallAccountFeedback",baseView)
local HttpCmd = import("app.config.config").HttpCmd

function View:ctor(...)
    self:initView(...)
    local gameString = cc.exports.GameString
    self.topPlaceHolderLabel:setString(gameString.get("str_help_hall_feedback2"))

    self.m_feedBackId = 1002
    self:getFeedBackList()
end



return View