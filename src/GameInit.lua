

local function gotoLoginScene()
    local SceneLogin = require("app.scenes.login.LoginScene")
    cc.Director:getInstance():runWithScene(SceneLogin:create(true))

end

local function initNotificationNode(  )
    local NotificationNode = require("app.common.NotificationNode")
    cc.Director:getInstance():setNotificationNode(NotificationNode.new())

end

cc.exports.init_load = function()
    require("app.common.Static")
    require("app.config.lan.GameString")

    GameString.load("string_zw")
    initNotificationNode()
    gotoLoginScene()
end