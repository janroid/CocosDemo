--[[
    author:{JanRoid}
    time:2018-10-26 16:35:06
    Description:项目初始化代码放在这个类下
]]
local function gotoLoginScene()
    local SceneLogin = import("app.scenes.login").scene
    
    if fix_restart_lua then
        -- 为了支持重启，这里不能直接使用runWithScene
        display.runScene(SceneLogin:create(true))
    else
        cc.Director:getInstance():runWithScene(SceneLogin:create(true))
    end
end

local function gotoUpdateScene()
    local UpdateScene = import("app.scenes.update").scene
    
    if fix_restart_lua then
        -- 为了支持重启，这里不能直接使用runWithScene
        display.runScene(UpdateScene:create())
    else
        cc.Director:getInstance():runWithScene(UpdateScene:create())
    end
end

local function initGlobal()
    require("updateConfig")
    local global = import("app.global.init")

    global:initData();
end

local function initModule()

    import("app.scenes.gift").GiftManager.getInstance()
    import("app.scenes.mttLobbyScene").MttManager.getInstance()
    import("app.scenes.chat").ChatManager.getInstance()
end

cc.exports.init_load = function()
    initGlobal()
    initModule()
    local NotificationNode = import("app.common.customUI").NotificationNode
    local node = NotificationNode:create()
    node:setContentSize(cc.size(display.width,display.height))
    cc.Director:getInstance():setNotificationNode(node)
  
    if g_SystemInfo:isAndroid() or g_SystemInfo:isIOS() then
        NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_GAME_INIT_CONFIG, "", nil, function(_, config)
            print("ReneYang, initConfig",config)
            g_AppManager:init(config)
            -- gotoLoginScene()
            gotoUpdateScene()
        end)
    else
        local pcconfig = require("PcConfig")
        -- pcconfig:generateVersionCode()
        g_AppManager:init(pcconfig)
        if pcconfig.NEED_CHECK_UPDATE then -- win32平台需要去检查热更新，请到PcConfig 打开NEED_CHECK_UPDATE开关
            gotoUpdateScene()
        else
            gotoLoginScene()
        end
    end
end

local function initConfig()

end
