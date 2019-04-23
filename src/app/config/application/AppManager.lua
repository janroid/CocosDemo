--[[
    初始化游戏平台数据
    author:{author}
    time:2018-10-26 11:13:25
]]

import("app.config.language")

local AppManager = {}

local VER_PATH = ".%s_%s/GameConfig"
local VER_PATH_CONFIG = ".%s_%s/%s"
local STR_PATH = "String_%s"
local FEATURE_CONFIG_PATH = ".%s_%s/FeatureConfig"

AppManager.S_APP_VER = {
    FB_ZW = 1,
    FB_TL = 3,
    FB_AR = 4,
    FB_FR = 5,
    FB_ID = 8,
    FB_VN = 9
    
}

AppManager.S_PLATFORM = {
    [AppManager.S_APP_VER.FB_ZW] = "zw",
    [AppManager.S_APP_VER.FB_TL] = "tl",
    [AppManager.S_APP_VER.FB_AR] = "ar",
    [AppManager.S_APP_VER.FB_FR] = "fr",
    [AppManager.S_APP_VER.FB_ID] = "id",
    [AppManager.S_APP_VER.FB_VN] = "vn",

}

function AppManager:init(config)

    self.m_loginVer = tonumber(config.LOGIN_VER)
    self.m_appflatform = self.S_PLATFORM[tonumber(config.LOGIN_VER)]

    local isDemo = (tonumber(config.IS_DEMO) == 1) or (config.IS_DEMO == true)
    self:setDemo(isDemo)

    self.m_isDebug = false
    if tonumber(config.IS_DEBUG) == 1 or config.IS_DEBUG == true then
        self.m_isDebug = true
        DEBUG = 1
    else
        DEBUG = 0
    end
    -- 当前设备的游客是否已经绑定过了
    self.m_guestBindedEmail = (tonumber(config.IS_BIND_EMAIL) == 1)

    if config.CLOSE_SOCKET_INFO then
        Log.setCloseSocketInfo(true)
    end

    self.m_gameConfig = require(string.format(VER_PATH,"android",self.m_appflatform))
    self.m_adaptConfig = require(string.format(VER_PATH_CONFIG,"android",self.m_appflatform,"AdaptiveConfig"))
    g_FeatureConfig = require(string.format(FEATURE_CONFIG_PATH,"android",self.m_appflatform))

    GameString.load(string.format(STR_PATH, self.m_appflatform))

    self:processSystemInfo(config)
    self:processDifferentConfig()
    
    if self.m_loginVer == AppManager.S_APP_VER.FB_ZW then
        cc.exports.g_DefaultFontName = "creator/common/fonts/default.ttf"
        NativeCall.lcc_setDefaultFontName(g_DefaultFontName)
    end
end

function AppManager:processSystemInfo(config)
    local info = {}
    info.VERSION_NAME = config.VERSION_NAME
    info.VERSION_CODE = config.VERSION_CODE
    info.OS_VERSION = config.OS_VERSION
    info.DEVICE_ID = config.DEVICE_ID 
    info.DEVICE_NAME = config.DEVICE_NAME
    info.MAC_ADDRESS = config.MAC_ADDRESS
    info.OPEN_UUID = config.OPEN_UUID
    info.DEVICE_MODEL = config.DEVICE_MODEL
    info.TOTAL_MEMORY = config.TOTAL_MEMORY
    info.FREE_MEMORY = config.FREE_MEMORY

    info.DEVICE_DETAILS = config.DEVICE_DETAILS
    g_SystemInfo:init(info)
end

-- 处理游戏版本间差异化配置
function AppManager:processDifferentConfig()
    local subVer = self.m_gameConfig.SUB_VER
    if subVer and "" ~= subVer then
        Log.d("appManager.processDifferentConfig sub", subVer)
        self.m_androidVer = self.m_gameConfig[SUB_VER].ANDROID_VER
        self.m_playStorePublicKey = self.m_gameConfig[SUB_VER].PLAYSTOREPUBLICKEY;
        if self.m_isDemo then
            self.m_loginUrl = self.m_gameConfig.S_LOGIN_URL_DEMO
            self.m_specialCgi = self.m_gameConfig[SUB_VER].SPECIAL_CGI_DEMO
            self.m_appid = self.m_gameConfig[SUB_VER].APPID_DEMO
        else
            self.m_loginUrl = self.m_gameConfig.S_LOGIN_URL
            self.m_specialCgi = self.m_gameConfig[SUB_VER].SPECIAL_CGI
            self.m_appid = self.m_gameConfig[SUB_VER].APPID
        end
    else
        self.m_androidVer= self.m_gameConfig.ANDROID_VER
        self.m_playStorePublicKey = self.m_gameConfig._PLAYSTOREPUBLICKEY;
        Log.d("appManager.processDifferentConfig", self.m_androidVer)
        if self.m_isDemo then
            self.m_loginUrl = self.m_gameConfig.LOGIN_URL_DEMO
            self.m_appid = self.m_gameConfig.APPID_DEMO
            self.m_specialCgi = self.m_gameConfig.SPECIAL_CGI_DEMO
        else
            self.m_loginUrl = self.m_gameConfig.LOGIN_URL
            self.m_appid = self.m_gameConfig.APPID
            self.m_specialCgi = self.m_gameConfig.SPECIAL_CGI
        end    
    end
end

function AppManager:getAppVer()
    return tonumber(self.m_loginVer)
end

function AppManager:getLoginUrl()
    return self.m_loginUrl
end

function AppManager:getSpecialCgi()
    return self.m_specialCgi
end

function AppManager:getPlayStorePublicKey()
    return self.m_playStorePublicKey
end

-- 老代码中是写死的 不知道干嘛用的
function AppManager:getEncKey()
    return "abctest"
end

function AppManager:getAppId()
    return self.m_appid
end

function AppManager:getAndroidVer()
    return self.m_androidVer
end

function AppManager:getAdaptiveConfig()
    return self.m_adaptConfig
end

function AppManager:getUpdateUrl()
    if g_AppManager:isDebug() then
        return self.m_gameConfig.UPDATE_URL_DEMO
    else
        return self.m_gameConfig.UPDATE_URL
    end
end

function AppManager:getRegionalID()
    return self.m_gameConfig.REGIONAL_ID
end

function AppManager:getFBAppLink()
    return self.m_gameConfig.FB_APPLINK_URL or ""
end

function AppManager:getMessageTemplate()
    return self.m_messageTemplate
end

function AppManager:setMessageTemplate(messageTemplate)
    self.m_messageTemplate = messageTemplate
end

function AppManager:setDemo(isDemo)
    self.m_isDemo = isDemo
    -- cc.Director:getInstance():setDisplayStats(self.m_isDebug)
end

function AppManager:isDemo()
    return self.m_isDemo
end

function AppManager:setDebug(isDebug)
    self.m_isDebug = isDebug
end

function AppManager:isDebug()
    return self.m_isDebug
end

function AppManager:getAppPlatform()
    return self.m_appflatform
end

function AppManager:isGuestBindedEmail()
    return self.m_guestBindedEmail
end

--@desc: 打开url
--@url: string
--@return: bool 是否打开成功
function AppManager:openURL(url)
    if type(url) ~= 'string' or url == '' then
        return false
    else   
        return cc.Application:getInstance():openURL(url) -- 其实这个方法win32模拟器也可以使用，会打开一个网页浏览器
    end
end

-- 跳转到应用商店（GoogleStore, AppStore)
function AppManager:gotoAppStore()
    if device.platform == "android" then
        return NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_JUMP_GOOGLE_PLAY)
    elseif device.platform == "ios" then
        return g_AppManager:openURL(AppManager:getStoreURL())
    end
end

function AppManager:getStoreURL()
    if device.platform == "ios" then
        return self.m_gameConfig.STORE_URL_IOS
    else
        return self.m_gameConfig.STORE_URL_ANDROID
    end
end

return AppManager
