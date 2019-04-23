cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath() .. "assets/src/",true)
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath() .. "assets/res/",true)

local breakSocketHandle, debugXpCall = require("LuaDebugjit")("localhost",7003)
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle ,0.3,false)

require("config")
require("cocos.init")

local function main()  
    
end


local oldTrackBackFunc = __G__TRACKBACK__
__G__TRACKBACK__ = function ( msg )
    msg = debug.traceback(msg)
    print(msg)
    showErrormsg(msg)
    oldTrackBackFunc(msg)
end
local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end