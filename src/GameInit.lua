

local function gotoLoginScene()
    local SceneLogin = require("app.scenes.hall.HallScene")
    cc.Director:getInstance():runWithScene(SceneLogin:create(true))

end

cc.exports.init_load = function()
    require("app.common.Static")


    gotoLoginScene()
end