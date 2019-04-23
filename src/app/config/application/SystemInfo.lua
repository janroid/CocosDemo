--[[
    设备信息，版本信息等
    author:{ReneYang}
    time:2018-11-08 11:13:25
]]

local SystemInfo = {}

function SystemInfo:init(info)
    self.m_info = info
    self.m_versionName = info.VERSION_NAME
    self.m_versionCode = info.VERSION_CODE
    self.m_OSVersion = info.OS_VERSION
    self.m_deviceId = info.DEVICE_ID or "" -- win32为""
    self.m_deviceName = info.DEVICE_NAME
    self.m_macAddr = info.MAC_ADDRESS
    self.m_deviceDeatails = info.DEVICE_DETAILS or ""
    self.m_openUUID = info.OPEN_UUID
    self.m_deviceModel = info.DEVICE_MODEL
    self.m_totalMemory = info.TOTAL_MEMORY
    self.m_freeMemory = info.FREE_MEMORY

    self:setOSVersion()
    self:setPlay()
    self:setDeviceName()
    self:setDevice()
    self:setMacAddr()
end

function SystemInfo:setOSVersion()
    if self.m_OSVersion == nil then
        if self:isIOS() then
            self.m_OSVersion = "8.0.0"
        elseif self:isAndroid() then
            self.m_OSVersion = "4.0"
        else
            self.m_OSVersion = "1.0"
        end
    end
end

function SystemInfo:getLuaVersion()
    return self.m_versionCode or 0
end

function SystemInfo:getVersionName()
    return self.m_versionName
end

function SystemInfo:getVersionCode()
    return self.m_versionCode
end

function SystemInfo:getOSVersion()
    
    return self.m_OSVersion
end

function SystemInfo:getPlatform()
    return device.platform
end

function SystemInfo:getDeviceId()
    return self.m_deviceId
end

function SystemInfo:setDeviceName()
    if self:isAndroid() or self:isIOS() then
        self.m_deviceName = self.m_deviceModel or self.m_deviceName or ""
    else
        local name = "";
        local tempFile = "d:/hostname.txt";
        if(not cc.FileUtils:getInstance():isFileExist(tempFile)) then
            os.execute("hostname > " .. tempFile);
        end
        if(cc.FileUtils:getInstance():isFileExist(tempFile)) then
         local f = io.open(tempFile, "r");
            if(f) then
                name = f:read();
                f:close();
            end
        end
        self.m_deviceName = name;
    end
end
function SystemInfo:getDeviceName()
    return self.m_deviceName
end


function SystemInfo:setDevice()
    if device.platform == "ios" then
        self.m_device = "iphone"
        if self.m_deviceModel == 'iPhone Simulator' then -- iOS 模拟器，调低点帧率，不然很卡
            cc.Director:getInstance():setAnimationInterval(1/30.0)
        end
    elseif device.platform == "android" then
        local deviceFlag = "android";
        if(g_AppManager:getAndroidVer() and g_AppManager:getAndroidVer() ~= "") then
            Log.d("login","SystemInfo:setDevice",g_AppManager:getAndroidVer())
            if(g_AppManager:getAndroidVer()== "2") then
                --deviceFlag = "android_java"; -- 改为android
            else
                deviceFlag = g_AppManager:getAndroidVer();
            end
        end
        self.m_device = deviceFlag;
    else
        self.m_device = "win32"
    end
end
function SystemInfo:getDevice()
    return self.m_device
end

-- 老版本返回""
function SystemInfo:getOpenUDID()
    return self.s_guid or self.m_openUUID or tostring(os.time())
end

-- mac地址
function SystemInfo:getMacAddr()
    return self.m_macAddr
end



function SystemInfo:setMacAddr()
    if device.platform == "android" then
        self.m_macAddr =  self.m_macAddr
    elseif device.platform == "ios" then
        --获取Mac地址  IOS7.0后MAC地址已被屏蔽了
        self.m_macAddr = "02:00:00:00:00:00"
    else
        -- win32
        local sMac = "89:12:c4:d2:45:76";
        local hasMac = false;
        local tempFile = "d:/ipconfig.txt";
        if(not cc.FileUtils:getInstance():isFileExist(tempFile)) then
            os.execute("ipconfig/all > " .. tempFile);
        end
        --查找:后的带五个-的字符串
        if(cc.FileUtils:getInstance():isFileExist(tempFile)) then
            for line in io.lines(tempFile) do
                local pos = string.find(line, " : ");
                if(pos) then
                    local s = string.sub(line, pos+3);
                    if(g_StringLib.isStringMac(s) and not hasMac) then
                        hasMac = true;
                        sMac = string.gsub(s, "-", ":");
                    end
                end
            end
        end
    
        if self.s_guid ~= nil then
            sMac = string.sub(sMac, 0, string.len(sMac) - 2);
            if string.len(self.s_guid) <= 1 then 
                self.s_guid = "0" .. self.s_guid;
                sMac = sMac .. self.s_guid;
            else 
                sMac = sMac .. string.sub(self.s_guid, 0, 2);
            end
        end
    
        self.m_macAddr =  sMac;
    end
end
-- 
SystemInfo.setGuid = function(self, guid)
    self.s_guid = tonumber(guid);
    if(self.s_guid ~= nil) then
        self.s_guid = tostring(self.s_guid);
    end
    self:setMacAddr()
end

-- 老版本中如此
function SystemInfo:setPlay()
    if device.platform == "ios" then
        self.m_play = "iphone"
    else
        self.m_play = "android"
    end
end
function SystemInfo:getPlay()
    return self.m_play
end

function SystemInfo:getDeviceDetails()
    return self.m_deviceDeatails
end

function SystemInfo:isAndroid()
    return device.platform == 'android'
end

function SystemInfo:isIOS()
    return device.platform == 'ios'
end

function SystemInfo:isWindows()
    return device.platform == 'windows'
end

return SystemInfo