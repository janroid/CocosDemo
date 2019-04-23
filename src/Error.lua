--[[
    author:{JanRoid}
    time:2018-12-5
    Description: 处理Lua报错
]] 

cc.exports.showErrormsg = function(msg)
    if DEBUG == 0 then
        NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_UMENG_UPLOAD,msg)
        if fix_restart_lua then
            fix_restart_lua()
        end
        return    -- 非debug模式下不显示
    end

    local screenSize = cc.Director:getInstance():getOpenGLView():getFrameSize()

    local scene = cc.Director:getInstance():getNotificationNode()

    local root = g_NodeUtils:getRootNodeInCreator("creator/common/layout/errorPop.ccreator")
    scene:add(root)

    local content = g_NodeUtils:seekNodeByName(root,"content")
    local closeBtn = g_NodeUtils:seekNodeByName(root,"btn_close")
    closeBtn:addClickEventListener(function()
        scene:removeChild(root)
        root = nil
    end)

    local bg = g_NodeUtils:seekNodeByName(root,"background")
    bg:addClickEventListener(function()
        
    end)


    content:setString(msg)

end