--[[--ldoc desc
    定义游戏中需要用到的全局变量
    所有游戏中需要用到的全局变量都需要定义到该文件下
    统一命名规范：
        g_Xxxxxxx
    注意g_后面紧跟着的字段采用大驼峰命名方法
]]
local Global = {};
setmetatable(Global, {
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

-- 添加全局变量统一入口
cc.exports.ADDGLOBAL = function(key,value)
    assert(key,"GlobalMap -- ADDGLOBAL key 不能为空")
    assert(value,"GlobalMap -- ADDGLOBAL value 不能为空")
    assert(type(key)=="string","GlobalMap -- ADDGLOBAL key 必须为String")

    cc.exports[key] = value
end

-------------------- 自增ID -------------------------
Global.g_IncreaseID = 0
Global.g_GetIndex = function()
    Global.g_IncreaseID = Global.g_IncreaseID + 1;
    return Global.g_IncreaseID
end

---------------------- 导入全局方法 -----------------------
local funs = require("FunctionsEx")
for k, v in pairs(funs) do
    Global[k] = v
end

-----------------------------------------------------
-- -- 定义业务会用到的全局数据
-- 加载自定义事件模块
local event = import("framework.event");
Global.g_EventDispatcher = event.EventDispatcher; -- 事件处理器
-- 加载工具类
local utils = import("framework.utils");

Global.g_Base64 = utils.Base64;
Global.g_BitUtil = utils.BitUtil;
Global.g_ListLib = utils.ListLib;
Global.g_MathLib = utils.MathLib;
Global.g_NumberLib = utils.NumberLib;
Global.g_StringLib = utils.StringLib;
Global.g_TableLib = utils.TableLib;
Global.g_TimeLib = utils.TimeLib;
Global.g_NodeUtils = utils.NodeUtils;
Global.Log = utils.Log;  -- 因为习惯，没有遵守规范
Global.g_toast = utils.Toast;
Global.g_ArrayUtils = utils.ArrayKit 
Global.g_JsonUtil = utils.JsonKit
Global.g_XmlUtil = utils.XmlKit
Global.g_DictUtils = utils.DictUtils

local behavior = import("framework.behavior");
Global.BehaviorBase = behavior.BehaviorBase
Global.BehaviorExtend = behavior.BehaviorExtend
Global.BehaviorMap = behavior.BehaviorMap 

-- 加载protobuf
local pb = import("framework.pbc");
Global.g_Protobuf = pb.BYProtobuf;

local sys = import("framework.sys")
Global.NativeCall = sys.NativeCall;

local config = import("app.config.config");
Global.g_TableLib.merge(Global,config.Const);
Global.g_UserDefaultCMD = config.UserDefaultCmd;
Global.g_SceneEvent = config.SceneConfig;
Global.HttpCmd = config.HttpCmd
Global.g_HeadConfig = config.HeadConfig
Global.g_SocketCmd = config.SocketCmd 
Global.g_ClientConfig = config.ClientConfig
Global.g_ServerConfig = config.ServerConfig

Global.g_SettingConfig = import("app.scenes.setting").SettingConfig -- 待优化

local extend = import("framework.extend");
Global.g_Schedule = extend.Schedule;
Global.delete = extend.NodeEx.delete;
Global.deleteWithChildren = extend.NodeEx.deleteWithChildren;

-- 原生交互Key值定义表
Global.NativeCmd = import("app.config.config").NativeCmd
Global.NativeEvent = sys.NativeEvent

local graphics = import("framework.graphics");
Global.g_ShaderCache = graphics.ShaderCache;

local netSo = import("framework.socket")
Global.Socket = netSo.Socket

local net = import("framework.net")
Global.g_HttpManager = net.HttpManager:getInstance()

local net = import("app.net")
Global.g_ProxyManager = net.ProxyManager:create()

local popup = import("app.common.popup")
local PopupManager = popup.PopupManager
Global.g_PopupManager = PopupManager.getInstance()
Global.g_PopupConfig = popup.PopupConfig

local application = import("app.config.application")
Global.g_AppManager = application.AppManager
Global.g_SystemInfo = application.SystemInfo
Global.g_FeatureConfig = {}

local utils = import('app.common.utils')
Global.g_ToolKit = utils.toolKit
Global.g_MoneyUtil = utils.MoneyUtil
Global.g_StringUtils = utils.StringKit;
Global.g_LanguageUtil = utils.LanguageUtil
Global.g_RGBUtil = utils.RGBKit
Global.g_ExpUtils = utils.ExpUtil
Global.g_EmailUtil = utils.EmailUtil
Global.g_DownloadUtil = utils.DownloadUtil:new()
Global.g_StatisticReportTool = utils.StatisticReportTool

local model = import('app.model')
Global.g_AccountInfo = model.AccountInfo
Global.g_AccountManager = model.AccountManager:getInstance()
Global.g_PhpInfo = model.PhpInfo
Global.g_RoomInfo = model.RoomInfo
Global.g_Model = model.Model:create()
Global.g_ModelCmd = model.ModelCmd

local customUI= import('app.common.customUI')
Global.g_AlarmTips= customUI.AlarmTips
Global.g_AlertDialog = customUI.AlertDialog
Global.g_Progress = customUI.Progress
Global.g_TopTips = customUI.TopTips

local poker = import('app.scenes.poker')
Global.g_PokerCard = poker.PokerCard
Global.g_PokerManager = poker.PokerManager

local media = import("framework.media");
Global.g_SoundManager = media.SoundManager;
Global.g_SoundMap = media.SoundMap;

local ChatManager = import("app.scenes.chat").ChatManager
Global.g_ChatManager = ChatManager:getInstance()

-------------------------------------------------
-- 初始化公共模块
local function initData()
    Global.NativeEvent.getInstance():registerConfig(Global.NativeCmd.NATIVE_CONFIG)
end

return initData;