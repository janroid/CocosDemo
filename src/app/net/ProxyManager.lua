--[[
    author:{JanRoid}
    time:2019-1-18
    Description: 网络模块代理管理类，负责断线重连及域名轮询工作
]] 

local ProxyManager = class("ProxyManager")

function ProxyManager:ctor()
    self.m_proxyIp = nil
    self.m_proxyPort = nil
    self.m_proxyArray = {}
    self.m_proxyArrayIndex = 0
end

function ProxyManager:init(loginData)
    local proxyIp = getStrFromTable(loginData,"proxyip")
    local proxyPort = getStrFromTable(loginData,"proxyport")

    local mtkey = getStrFromTable(loginData, "mtkey")
    local token = getStrFromTable(loginData, "proxytoken")
    local tokenArray = getTabFromTable(loginData, "proxytoken_array")
    local time = getStrFromTable(loginData,"today")
    local uid = getStrFromTable(loginData, "uid")

    -- 优先使用加密过的IP和port
    if string.len(token) > 1 then 
        self:decryptData(mtkey, token, tokenArray, time, uid)

        if self.m_proxyIp ~= nil  and self.m_proxyPort ~= nil then
            return
        end
    end

    -- 没有加密的ip和port的情况下，使用明文的ip和port
    self.m_proxyIp = proxyIp
    self.m_proxyPort = proxyPort

    local tab = {}
    tab.ip = proxyIp
    tab.port = proxyPort
    table.insert(self.m_proxyArray, tab)
end

--[[
    @desc: 解析数据
    @return:
]]
function ProxyManager:decryptData(mtkey, token, tokenArray, time, uid)
    local flag = false
    local array = nil
    --解密Array
    local firstKey = time .. uid;
    token = g_ToolKit.rc4_decrypt(token, mtkey);
    array,flag  = g_JsonUtil.decode(token);
    
    --解密IP和端口
    array  = g_ArrayUtils.reverse(array);
    self.m_proxyIp = g_ToolKit.rc4_decrypt(array[1], firstKey);
    self.m_proxyPort = tonumber(g_ToolKit.rc4_decrypt(array[2], self.m_proxyIp));
            
    self.m_proxyArray = {};
    self.m_proxyArray[1] = {};
    self.m_proxyArray[1].ip = self.m_proxyIp;
    self.m_proxyArray[1].port = self.m_proxyPort;
    
    if tokenArray ~= nil and #tokenArray > 0 then
        for i = 1, #tokenArray do
            tokenArray[i] = g_ToolKit.rc4_decrypt(tokenArray[i], mtkey);
            array, flag = g_JsonUtil.decode(tokenArray[i]);
            array = g_ArrayUtils.reverse(array);
            self.m_proxyArray[i + 1]      = {};
            self.m_proxyArray[i + 1].ip   = g_ToolKit.rc4_decrypt(array[1], firstKey);
            self.m_proxyArray[i + 1].port = tonumber(g_ToolKit.rc4_decrypt(array[2], self.m_proxyArray[i + 1].ip));
        end
    end 
end

-- 返回下一组ip和port
function ProxyManager:getProxyIpPort()
    if self.m_proxyArray ~= nil and #self.m_proxyArray > 0 then
        self.m_proxyArrayIndex = self.m_proxyArrayIndex + 1;
        if self.m_proxyArrayIndex > #self.m_proxyArray then
            self.m_proxyArrayIndex = 1;
        end
        self.m_proxyIp    = self.m_proxyArray[self.m_proxyArrayIndex].ip;
        self.m_proxyPort  = self.m_proxyArray[self.m_proxyArrayIndex].port;
    end

    return self.m_proxyIp, self.m_proxyPort
end

function ProxyManager:getCurrentProxyIpPort()
    return self.m_proxyIp, self.m_proxyPort
end

return ProxyManager