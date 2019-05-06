-- 定义全局变量

local Static = {}

setmetatable(Static, {
    __newindex = function(_, name, value)
        if cc.exports[name] then
            assert(cc.exports[name], "Error: 当前已经存在"..name.."名称的全局变量，请重新定义名称")
        end
        cc.exports[name] = value;
    end,

    __index = function(_, name)
        return cc.exports[name]
    end
})

Static.g_IncreaseID = 0
Static.g_GetIndex = function()
    Static.g_IncreaseID = Static.g_IncreaseID + 1;
    return Static.g_IncreaseID
end

local funs = require("framework.expand.FunctionEx")
for k, v in pairs(funs) do
    Static[k] = v
end

require("framework.scenes.ViewBaseEx")

-- 自定义ID
Static.g_CustomEvent = require("app.config.CustomEvent")
Static.g_HttpCmd = require("app.net.HttpCmd")
Static.g_SocketCmd = require("app.net.SocketCmd")
Static.g_DataKey = require("app.config.DataKey")

Static.Log = require("framework.utils.Log")
Static.g_Base64 = require("framework.utils.Base64")
Static.g_BitUtil = require("framework.utils.Bit")
Static.g_ListLib = require("framework.utils.ListLib")
Static.g_MathLib = require("framework.utils.MathLib")
Static.g_NumberLib = require("framework.utils.NumberLib")
Static.g_StringLib = require("framework.utils.StringLib")
Static.g_TableLib = require("framework.utils.TableLib")
Static.g_TimeLib = require("framework.utils.TimeLib")
Static.g_NodeUtils = require("framework.utils.NodeUtils")
Static.g_ArrayUtils = require("framework.utils.ArrayKit") 
Static.g_JsonUtil = require("framework.utils.JsonKit")
Static.g_XmlUtil = require("framework.utils.XmlKit")
Static.g_DictUtils = require("framework.io.DictUtils")

Static.g_NoticePop = require("app.views.NoticePop")

Static.g_NetManager = require("app.net.NetManager")

local EventDispatcher = require("framework.expand.EventDispatcher")
Static.g_EventDispatcher = EventDispatcher.getInstance()
Static.g_PopupManager = require("app.common.popup.PopupManager")



