local baseView = require("subviews.feedbackBaseView")
local HttpCmd = import("app.config.config").HttpCmd

local View = class("HallPayFeedback",baseView)
local HttpCmd = import("app.config.config").HttpCmd

function View:ctor(...)
    self:initView(...)
    local gameString = cc.exports.GameString
    self.topPlaceHolderLabel:setString(gameString.get("str_help_hall_feedback1"))

    self.m_feedBackId = 1001
    self:getFeedBackList()
    
end


return View