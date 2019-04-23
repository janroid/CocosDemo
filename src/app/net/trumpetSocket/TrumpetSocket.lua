--[[
    author:{Patric}
    time:2018-12-29
    Description: 小喇叭Socket类
]] 

local schedule = cc.Director:getInstance():getScheduler();

local Socket = import("framework.socket").Socket

local TrumpetSocket = class("TrumpetSocket",Socket)

TrumpetSocket.S_HEART_TIMEOUT = "heart_timeout" -- 心跳超时
TrumpetSocket.S_HEART_REPEAT = "heart_repeat" -- 心跳循环

function TrumpetSocket:ctor()
    Socket.ctor(self, g_SocketCmd.SOCKET_TYPE_TRUMPET)

    self.m_timeListeners = {}
    self.s_heartTimeout = 3 -- 心跳包3s超时
    self.s_heartRepeat = 20  -- 20s发一次心跳 
    self.s_maxConnectTime = 3 -- 重连重试次数

    self.m_heartCount = 0; -- 心跳超时次数
end

function TrumpetSocket:dtor()
    self:clearTimer()
end

function TrumpetSocket:connect()
    Log.d("TrumpetSocket:connect")
    if self.m_nServerStatus == g_SocketCmd.SOCKET_STATUS_CONNECTING then
        Log.d("TrumpetSocket:connect -- is connecting")
        return
    end
    local ip, port = g_ProxyManager:getProxyIpPort()
    Socket.connect(self,ip,port)

    self:startTimer()
    self:addTimeoutListener(TrumpetSocket.S_HEART_REPEAT, self.s_heartRepeat)
end

--[[
    @desc: 重连
    author:{author}
    time:2019-01-23 11:41:21
    @return:
]]
function TrumpetSocket:reConnect()
    self.m_ip, self.m_port = g_ProxyManager:getProxyIpPort()
    Socket.reConnect(self)
end

--[[
    @desc: 连接小喇叭server
    @return:
]]
function TrumpetSocket:connectTrumpet()
    local ip = g_Model:getProperty(g_ModelCmd.DATA_TRUMPET, "trumpetIp")
    local port = g_Model:getProperty(g_ModelCmd.DATA_TRUMPET, "trumpetPort")

    self:writeBegin()
    self:writeString(ip)
    self:writeInt(port)
    Log.d("TrumpetSocket:connectTrumpet", ip, port)
    self:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_PROXY_LOGIN)
end

--[[
    @desc: 验证用户信息
    @return:
]]
function TrumpetSocket:loginTrumpet( )
    local userId = g_AccountInfo:getId() or 0
    local mtkey = g_AccountInfo:getmtkey() or ""
    Log.d("TrumpetSocket:loginTrumpet", userId, mtkey)
    self:writeBegin()
    self:writeInt(userId)
    self:writeString(mtkey)
    self:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_LOGIN)
end

function TrumpetSocket:addTimeoutListener(key, delay)
    self.m_timeListeners[key] = delay
end

function TrumpetSocket:clearTimeoutListener(key)
    self.m_timeListeners[key] = nil
end

--[[
    @desc: 处理超时逻辑
    @return:
]]
function TrumpetSocket:startTimer()
    self:clearTimer()
    self.m_timerSchedule = schedule:scheduleScriptFunc(function()
        for k,v in pairs(self.m_timeListeners) do
            v = v -1
            if v <= 0 then
                self.m_timeListeners[k] = nil
                self:handlerTimeOut(k)
            else
                self.m_timeListeners[k] = v
            end
        end
    end, 1, false)
end

function TrumpetSocket:clearTimer()
    if  self.m_timerSchedule then
        schedule:unscheduleScriptEntry(self.m_timerSchedule)
        self.m_timerSchedule = nil
    end
end

--[[
    @desc: 处理超时
    --@key: 
    @return:
]]
function TrumpetSocket:handlerTimeOut(key)
    Log.s("TrumpetSocket:handlerTimeOut -- key = ",key,self.m_nServerStatus)
    if key == TrumpetSocket.S_HEART_TIMEOUT then -- 心跳超时
        self.m_heartCount = self.m_heartCount + 1
        if self.m_heartCount >= 6 then
            self.m_heartCount = 0
            self:reConnect()
        end
    elseif key == TrumpetSocket.S_HEART_REPEAT then
        self:startHeart()
        self:addTimeoutListener(TrumpetSocket.S_HEART_REPEAT, self.s_heartRepeat)
    end
end

-- 心跳
function TrumpetSocket:startHeart()
    if (self.m_nServerStatus ~= g_SocketCmd.SOCKET_STATUS_CONNECTED) then     

        self.m_heartCount = 0
        self:reConnect()

        return
    end
    
    self:writeBegin()
    self:writeShort(0)
    self:sendMsg(g_SocketCmd.TrumpetSocketCMD.LB_SVR_CMD_HEARTBEAT)

    self:addTimeoutListener(TrumpetSocket.S_HEART_TIMEOUT, self.s_heartTimeout)
end

function TrumpetSocket:stopHeart()
    self:clearTimeoutListener(TrumpetSocket.S_HEART_TIMEOUT)
end

-- socket连接成功
function TrumpetSocket:onConnectComplete()
    self:connectTrumpet()
    self:loginTrumpet()
end

-- 连接失败
function TrumpetSocket:onConnectFailed()
    self:reConnect()
end

--[[
    @desc: 重连超过次数
    @return:
]]
function TrumpetSocket:reConnectTimeout()
    -- 超时后等120s，重新再来
    self.m_reConnectTimes = 0
end

function TrumpetSocket:parseMsg(cmd,msgData,msgSize)
    Log.s("TrumpetSocket.parseMsg",cmd,msgSize)
    if cmd == g_SocketCmd.TrumpetSocketCMD.LB_SVR_CMD_HEARTBEAT then -- 心跳包
        Log.s("TrumpetSocket:parseMsg --> 收到心跳包")
        self:stopHeart()
    else
        Socket.parseMsg(self,cmd,msgData,msgSize)
    end

end



return TrumpetSocket