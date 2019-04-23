local baseView = require("subviews.feedbackBaseView")
local HttpCmd = import("app.config.config").HttpCmd

local View = class("HallBugFeedback",baseView)
local HttpCmd = import("app.config.config").HttpCmd

function View:ctor(...)
    self:initView(...)
    local gameString = cc.exports.GameString
    self.topPlaceHolderLabel:setString(gameString.get("str_help_hall_feedback3"))

    self.m_feedBackId = 1000
    self:getFeedBackList()
end

return View