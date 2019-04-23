--[[--ldoc desc
@module LoginCtr
@author ReneYang
Date   2018-10-26
]]

local AchieveInfo = import("app/model").AchieveInfo
local SlotInfo = import("app/model").SlotInfo

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd
local BehaviorMap = import("app.common.behavior").BehaviorMap

local LoginCtr = class("LoginCtr",ViewCtr);
BehaviorExtend(LoginCtr);

LoginCtr.S_ERRORCODE = {
    FB_LOGIN_ERR                    = -2;      --accesstoken验证不通过或者请检查appid,app密钥是否正确，或者web机房到facebook网络不通

    --游客
    ANDROID_CLOSE_GUESS_LOGIN       = -1;      --安卓-关闭游客登录
    ANDROID_CLOSE_GUESS_REGISTER    = -3;      --安卓-关闭游客注册
	OPEN_UDID_ERR                   = -4;      --IOS-openudid错误
	IOS_CLOSE_GUESS_LOGIN           = -6;      --IOS-关闭游客登录
	IOS_CLOSR_GUESS_REGISTER        = -7;      --IOS-关闭游客注册
	RESTRICTE_LOGIN_IP              = -8;      --安卓-登录限制IP
	ANDROID_MAC_IS_NULL             = -9;      --安卓-MAC为空
	ANDROID_MAC_IS_FAKE             = -10;     --安卓-MAC为02:00:00:00:00:00
	ANDROID_MAC_FORMAT_WRONG        = -11;     --安卓-MAC格式不对
	ANDROID_RESTRICTE_REGISTER      = -12;     --安卓-注册限制
	ANDROID_EMULATOR_LIMIT			= -13;     --限制模拟器游客登录
	--邮箱账号
	EMAIL_ERROR                     = -98;     --用户不存在
	PASSWORD_ERROR                  = -99;     --密码错误

	--公共
	COMMON_RESTRICTE_IP             = -101;    --IP次数限制
	COMMON_IP_BLACK_LIST            = -102;    --IP黑名单
	COMMON_FROZEN                   = -103;    --账号冻结
	COMMON_SERVER_DOWN              = -104;    --服务器停服维护

	------客户端自定义-------
	COMMON_ERR                      = 10000;   -- 自定义网络异常，没有数据返回
	FB_ACCESS_TOKEN_ERR             = 10001;   --拿不到accessToken


}

LoginCtr.s_LoginFailTipsMap = {
	[LoginCtr.S_ERRORCODE.FB_LOGIN_ERR]                      = "str_login_fb_access_token_err";
	[LoginCtr.S_ERRORCODE.ANDROID_CLOSE_GUESS_LOGIN]         = "str_login_close_guess_login";
	[LoginCtr.S_ERRORCODE.ANDROID_CLOSE_GUESS_REGISTER]      = "str_login_close_guess_register";
	[LoginCtr.S_ERRORCODE.OPEN_UDID_ERR]                     = "str_login_network_err";
	[LoginCtr.S_ERRORCODE.IOS_CLOSE_GUESS_LOGIN]             = "str_login_close_guess_login";
	[LoginCtr.S_ERRORCODE.IOS_CLOSR_GUESS_REGISTER]          = "str_login_close_guess_register";
	[LoginCtr.S_ERRORCODE.RESTRICTE_LOGIN_IP]                = "str_login_restricte_login";
	[LoginCtr.S_ERRORCODE.ANDROID_MAC_IS_NULL]               = "str_login_open_wifi_tip";
	[LoginCtr.S_ERRORCODE.ANDROID_MAC_IS_FAKE]               = "str_login_open_wifi_tip";
	[LoginCtr.S_ERRORCODE.ANDROID_MAC_FORMAT_WRONG]          = "str_login_open_wifi_tip";
	[LoginCtr.S_ERRORCODE.ANDROID_RESTRICTE_REGISTER]        = "str_login_close_guess_register";
	[LoginCtr.S_ERRORCODE.EMAIL_ERROR]                       = "str_login_login_email_error";
	[LoginCtr.S_ERRORCODE.PASSWORD_ERROR]                    = "str_login_login_password_error";
	[LoginCtr.S_ERRORCODE.COMMON_RESTRICTE_IP]               = "str_login_restricte_register";
	[LoginCtr.S_ERRORCODE.COMMON_IP_BLACK_LIST]              = "str_login_restricte_login";
	[LoginCtr.S_ERRORCODE.COMMON_SERVER_DOWN]                = "str_login_server_down";
	[LoginCtr.S_ERRORCODE.COMMON_ERR]                        = "str_login_network_err";
	[LoginCtr.S_ERRORCODE.FB_ACCESS_TOKEN_ERR]               = "str_login_fb_access_token_err";
	[LoginCtr.S_ERRORCODE.ANDROID_EMULATOR_LIMIT]			 = "str_login_emulator_limit";
}
---配置事件监听函数
LoginCtr.s_eventFuncMap =  {
	[g_SceneEvent.LOGIN_SUCCESS]			= "onLoginSuccess",
	[g_SceneEvent.LOGIN_EMAIL]				= "onEmailLogin",
    [g_SceneEvent.LOGIN_GUEST]				= "onGuestLogin",
    [g_SceneEvent.LOGIN_FACEBOOK]			= "requestFBLogin",
	
}

function LoginCtr:ctor(scene,isFirstStart)
	self.m_isFirstStart = isFirstStart
    ViewCtr.ctor(self);
    self:bindBehavior(BehaviorMap.DownloadBehavior);
end

function LoginCtr:onEnter()
	self:cleanData()
	if self.m_isFirstStart then
        self:notifyNativeEngineLoaded()
        -- 隱私政策彈框
        local isAgreed = cc.UserDefault:getInstance():getBoolForKey(g_UserDefaultCMD.PRIVACY_POLICY_AGREED, false)
        if isAgreed or g_SystemInfo:isWindows() then
            self:autoLogin()
        else
            g_PopupManager:show(g_PopupConfig.S_POPID.PRIVACY_POLICY_POP)
        end
	end
end

function LoginCtr:onCleanup()
	ViewCtr.onCleanup(self)
end


function LoginCtr:notifyNativeEngineLoaded()
	NativeEvent.getInstance():callNative(NativeCmd.KEY.NATIVE_CMD_ENGINE_LOADED)
end


function LoginCtr:onLoginSuccess()
	Log.d("onLoginSuccess, replaceScene to hallScene")
    g_Model:setData(g_ModelCmd.DATA_HALL_SCENE_FROM, 1);
	local hallscene = import('app/scenes/hallScene').scene
	cc.Director:getInstance():replaceScene(hallscene:create())
end



function LoginCtr:autoLogin()
    local autoLogin = cc.UserDefault:getInstance():getBoolForKey(g_UserDefaultCMD.IS_FACEBOOK_LOGIN,false)
    Log.d("autoLogin", autoLogin)
	if autoLogin == true then
		self:requestFBLogin()
	end
end


-- FB登录请求
function LoginCtr:requestFBLogin()
    
    if g_AppManager:isDebug() and g_SystemInfo:isWindows() then -- win32 使用其他登录拿来的token
        local token = 'EAAJXuollRYMBAMXwO2jEwSOfswTgUzdkibehEBA0Jc57RlAZBisfVgDkeljYjp1C1AAL6A9dMdJ4g0OgjJModx5KWZBuX8gCYuARpYu6RyU8oawaLsd0OYXBks7YcBtvDtkzipJXmaEnw5LDFvHyEIvYnHBQFxUQ6OMqbgpP4T66C7FOjZBXnCyKfOl9wiSwEZB2GftkNsQfzGfYwei3lUhxw8p7TGkZD'
        self:onFacebookLogin(token)
    else
        NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_LOGIN_FACEBOOK, nil, self, self.onFacebookLoginResp)
    end
end

-- FB登录响应
function LoginCtr:onFacebookLoginResp(response)
    response = response or {}
    local result = tonumber(response.result)

    if result == 0 or result == 3 then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_cancle_tip'))
        -- 用户取消登录
        self:updateView(g_SceneEvent.LOGIN_FAILED)
    elseif result == 1 then
        Log.d("LoginCtr.onFacebookLoginResp", response)
        self:onFacebookLogin(response.token)
	else 
        Log.d("Facebook Login fail:",response.error)
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
        self:updateView(g_SceneEvent.LOGIN_FAILED)
	end
end

function LoginCtr:onFacebookLogin(token)
    Log.d("ReneYang", "LoginCtr.onFacebookLogin", token)
    self.m_token = token
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.ACCOUNT_LOGIN)
    param.signed_request = self.m_token

    self:doLogin(param)
end

function LoginCtr:onGuestLogin()
    local sysDevice = g_SystemInfo:getDevice()
    -- 老版本逻辑如此
    if device.platform == "windows" then
        sysDevice = "android"
    end

    local param = HttpCmd:getMethod(HttpCmd.s_cmds.ACCOUNT_LOGIN)
    param.device = sysDevice

    self:doLogin(param)
end

function LoginCtr:onEmailLogin(email, pwd)
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.ACCOUNT_LOGIN)
    param.email = email
    param.encryptPassword = NativeCall.lcc_getMD5Hash(pwd)

    self:doLogin(param)
end

function LoginCtr:doLogin(data)
    
    self:updateView(g_SceneEvent.LOGIN_UPDATE_DEBUGVIEW)
    g_Progress.getInstance():show(30)
    local mac = g_SystemInfo:getMacAddr() or ""
    local openUDID = g_SystemInfo:getOpenUDID()
    local deviceDetails =  g_SystemInfo:getDeviceDetails() or '';
	local key = os.date("%Y%m%d", os.time());
    local encryptDeviceInfo = g_ToolKit.rc4_encrypt(string.reverse(deviceDetails), key);
    local param = {
        ["mobile_request"] 	= g_Base64.encode(mac .. "_" .. g_AppManager:getEncKey()),
        ["mac"] 			= mac,
        ["openUDID"] 		= (openUDID ~= "") and g_Base64.encode(openUDID .. "_" ..g_AppManager:getEncKey()) or openUDID,
        ["deviceId"]		= g_SystemInfo:getDeviceId(),
        ["deviceName"]		= g_SystemInfo:getDeviceName(),
        ["device"]			= g_SystemInfo:getDevice(),
        ["version"]			= g_SystemInfo:getVersionName(),
        ["platform"]		= (device.platform == "ios" and "iphone"  or "android"),
        ["osVersion"] 		= g_SystemInfo:getOSVersion(),
        ["pay"]				= g_SystemInfo:getPlay(),
        ["android_ver"]		= g_AppManager:getAndroidVer(),
        ["apk_version"]     = g_SystemInfo:getVersionCode(),
        ["apk_appid"]       = g_AppManager:getAppId();
		["deviceDetails"]   = encryptDeviceInfo
    };
    g_TableLib.deepMerge(param, data)
    g_HttpManager:doPostWithUrl(g_AppManager:getLoginUrl().."mobile.php", param, self, self.onLoginResponse);
end

function LoginCtr:clearEmailAccount()
    --cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_PWD, "")
    --cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.ACCOUNT_EMAIL_REMEBER_PWD, false)
end

function LoginCtr:onLoginResponse(isSuccess, response, param)
    g_Progress.getInstance():dismiss()
    local isEmailLogin = (param and param.email) and true or false
    if not isSuccess then
	    g_AlarmTips.getInstance():setText(GameString.get("str_login_network_err")):show()
        if isEmailLogin then
            self:clearEmailAccount()
        end
        self:onLoginFailed()
        return;
    end

    Log.d("LoginCtr:onLoginResponse response = ",response)

    local errorcode = tonumber(response.errorcode)
    if errorcode then
        if isEmailLogin then
            self:clearEmailAccount()
        end
        self:onLoginFailed()
        if errorcode == LoginCtr.S_ERRORCODE.COMMON_FROZEN then
            -- 账号被封
            Log.d("LoginFail", string.format(GameString.get("str_login_ban_tip"), data.mid))

            g_AlertDialog.getInstance()
                :setTitle(GameString.get("str_common_warning"))
                :setContent(g_StringLib.substitute(GameString.get("str_common_ban_tip"),tostring(response.mid)))
                :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
                :setLeftBtnTx(GameString.get("str_common_appeal"))
                :setRightBtnTx(GameString.get("str_common_sure"))
                :setCloseBtnVisible(false)
                :setLeftBtnFunc(
                    function()
                        local helpType = import('app.scenes.help').ShowType
                        g_PopupManager:show(g_PopupConfig.S_POPID.HELP_POP,helpType.showTypeLogin)
                    end)
                :show() 

        else
            local tip = GameString.get("str_login_bad_network")
            if errorcode and LoginCtr.s_LoginFailTipsMap[errorcode] then
                tip = GameString.get(LoginCtr.s_LoginFailTipsMap[errorcode])
            end
            if errorcode == LoginCtr.S_ERRORCODE.FB_LOGIN_ERR then
                -- fb 登出
                NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_LOGOUT_FACEBOOK)
            elseif loginResultType == LoginCtr.S_ERRORCODE.EMAIL_ERROR or
            loginResultType == LoginCtr.S_ERRORCODE.PASSWORD_ERROR then
                self:clearEmailAccount()
            end
            g_AlarmTips.getInstance():setTextAndShow(tip)
        end
        return
    end

    response.uid = tonumber(response.uid or "");
    if response.uid ~= nil and response.uid > 0 then
        if response.nick == nil then 
            if g_SystemInfo:isAndroid() then
                response.nick = "Android " .. response.uid;
            else
                response.nick = "iPhone " .. response.uid;
            end
        end

        --游客登录记录玩家昵称
        if response.from == g_AccountInfo.S_LOGIN_FROM.GUEST then
            -- 保存用户昵称
            cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.GUEST_NICKNAME,response.nick)
        end

        g_HttpManager:addDefaultParam("mtkey", response.mtkey)
        g_HttpManager:addDefaultParam("skey", response.skey)
        g_HttpManager:addDefaultParam("uid", response.uid)
        g_HttpManager:addDefaultParam("version", g_SystemInfo:getVersionName())
        g_HttpManager:addDefaultParam("device",  g_SystemInfo:getDevice()=="win32" and "android" or g_SystemInfo:getDevice())
        g_HttpManager:addDefaultParam("channel", response.channel)
        g_HttpManager:addDefaultParam("mac", g_SystemInfo:getMacAddr())
	    local openUDID = g_SystemInfo:getOpenUDID()
        g_HttpManager:addDefaultParam("openUDID", (openUDID ~= "") and g_Base64.encode(openUDID .. "_" ..g_AppManager:getEncKey()) or openUDID)
        if(response.apik ~= nil) then
            g_HttpManager:addDefaultParam("apik", response.apik)
        end
        g_HttpManager:setDefaultUrl(response.CGI_ROOT)
        g_HttpManager:setDefaultStaticUrl(response.CGI_ROOT_STATIC)

        -- room
        g_RoomInfo:setProxyIp(response.proxyip)
        g_RoomInfo:setProxyPort(response.proxyport)
        local tableType = tonumber(response.tableType)
        if g_RoomInfo:isPrivateRoom(response.tid) then -- php也是这么判断的
            tableType = g_RoomInfo.ROOM_TYPE_PRIVATE
        end
        local reConnectData = {
	        ip = response.ip;
	        port = response.port;
	        tid = response.tid;
	        flag = response.status;
            tableType = tableType;
        }

	    g_Model:setData(g_ModelCmd.RECONNECT_DATA,reConnectData)
	    
        g_AccountInfo:init(response)
        g_PhpInfo.init(response)

        -- 初始化老虎机信息
        local slotInfo = SlotInfo:create()
        slotInfo:init(response)
        g_Model:setData(g_ModelCmd.DATA_SLOT,slotInfo)
        -- 初始化代理IP
        g_ProxyManager:init(response)
        -- 小喇叭数据
        local trumperIp = getStrFromTable(response,"BROADCAST_IP")
        local trumperPort = getStrFromTable(response,"BROADCAST_PORT")
        g_Model:setProperty(g_ModelCmd.DATA_TRUMPET, "trumpetIp", trumperIp)
        g_Model:setProperty(g_ModelCmd.DATA_TRUMPET, "trumpetPort", trumperPort)

        self:downloadMessageFile(response.MSGTPL_ROOT_LUA)
        self:downloadAchieveConfig(tostring(response.ACHIEVE_CONF_LUA))
        self:downloadSlotConfig(response.SLOT_ROOT_LUA)
        self:setPayCGI(response.PAY_CGI_ROOT, response.mtkey, response.skey)
        self:requestStoreData()
        -- facebook账号自动登录标记
        if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
            cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.IS_FACEBOOK_LOGIN, true)
        else
            cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.IS_FACEBOOK_LOGIN, false)
        end
        self:updateView(g_SceneEvent.LOGIN_SUCCESS)
    else
        self:onLoginFailed()
    end
    self:uploadToken()
end

function LoginCtr:uploadToken()
    local token;
    if g_SystemInfo:isAndroid() then 
        --发送GCM推送-jaywillou-20151020-add
        token = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.PUSH_NOTIFICATION_TOKEN,"")
    elseif  g_SystemInfo:isIOS() then 
        token = cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.PUSH_NOTIFICATION_TOKEN,"")
    end
    Log.d("LoginCtr:.onLoginResult, token", token);
    if not g_SystemInfo:isWindows() then
        local postData = HttpCmd:getMethod(HttpCmd.s_cmds.LOGIN_UPLOAD_TOKEN)
        postData.token = token
            g_HttpManager:doPost(postData, LoginCtr, function(obj,isSuccess,ret) 
            if isSuccess then
                Log.d("LoginCtr:uploadToken","onPostGcmTokenSuccess",ret);
            else
                Log.d("LoginCtr:uploadToken","onPostGcmTokenfail",ret);
            end
        end)
    end
end

-- 网络原因导致的失败
function LoginCtr:onLoginFailed()
    self:updateView(g_SceneEvent.LOGIN_FAILED)
end

function LoginCtr:downloadAchieveConfig(url)
    local fileName = "AchieveConfig.lua"
    local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/")
    local forceDown = false
    if cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACHIEVE_CONFIG_URL,"")~=url then
        forceDown = true
        cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.ACHIEVE_CONFIG_URL,url)
    end
    self:downloadFile(url,self.downLoadSuccess,filePath,fileName,nil,nil,forceDown)
end

-- 下载老虎机配置
function LoginCtr:downloadSlotConfig(url)
    local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/")
    self:downloadFile(url,function(obj,data)
        pcall(function()
            if data.isSuccess and data.fullFilePath then
                local func = loadfile(data.fullFilePath)
                if func then
                    local config = func()
                    Log.d("LoginCtr:downloadSlotConfig - config = ",config)

                    if next(config) ~= nil then
                        g_Model:setProperty(g_ModelCmd.DATA_SLOT, "betConfig",config)
                    end
                end
            end
        end)
    end, filePath,nil,nil,".lua")
end


function LoginCtr:downLoadSuccess(data)
    Log.d("LoginCtr:downLoadSuccess ",data.isSuccess,data.fullFilePath)
    local achieveInfo = AchieveInfo:create()
    achieveInfo:loadConfig(data.fullFilePath)
    g_Model:setData(g_ModelCmd.DATA_ACHIEVE_INFO, achieveInfo)
    
end

function LoginCtr:downloadMessageFile(url)
    local fileName = "message.lua"
    local filePath = g_LanguageUtil.switchFilePath("src/app/cache/platformFile/")
    local forceDown = false
    if cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.MESSAGE_CONFIG_URL,"")~=url then
        forceDown = true
        cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.MESSAGE_CONFIG_URL,url)
    end
    self:downloadFile(url,self.downLoadMessageSuccess,filePath,fileName,nil,nil,forceDown)
end

function LoginCtr:downLoadMessageSuccess(data)
    Log.d("LoginCtr:downLoadMessageSuccess ",data.isSuccess,data.fullFilePath)
    pcall(function()
        if data.isSuccess and data.fullFilePath then
            local fun=loadfile(data.fullFilePath)
            if fun then
                local messageTemplate = fun()
                -- Log.d("Johnson ",message)
                if not g_TableLib.isEmpty(messageTemplate) then
                    g_AppManager:setMessageTemplate(messageTemplate)
                end
            end 
        end
    end);
    
end

--  设置发货所需要的payCGI mid channel mtkey,skey
function LoginCtr:setPayCGI(payCGI, mtkey, skey) 
    Log.d("LoginCtr:setPayCGI,payCGI",payCGI)
    local uid = g_AccountInfo:getId()
    local channel = g_AccountInfo:getChannel()
    local param ={
        payCGI  = payCGI,
        uid     = tostring(uid),
        channel = channel,
        mtkey   = mtkey,
        skey    = skey,
    }
    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_SET_GOOGLE_PAY_CGI_URL,param)
end

function LoginCtr:requestStoreData()
    local StoreManager = import("app.scenes.store").StoreManager
	StoreManager.getInstance():requestData()
end

function LoginCtr:cleanData()
    
	g_AccountInfo:reset()
	g_RoomInfo:reset()
	import("app.scenes.store").StoreManager.delete()
    import("app/net").TrumpetSocketManager.delete()
    import("app.scenes.mttLobbyScene").MttManager.clearData()
	g_HttpManager:clearDefaultParams()
end

return LoginCtr;