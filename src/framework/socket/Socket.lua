--[[
    socket基类封装, 该类为全局类
    author:{Janroid}
    time:2018-11-23
]]

local Socket = class("Socket")
local NetManager = import("framework.net").NetManager

local socketName = {
    [g_SocketCmd.SOCKET_TYPE_ROOM] = "RoomSocket",
    [g_SocketCmd.SOCKET_TYPE_TRUMPET] = "TrumpetSocket",
    [g_SocketCmd.SOCKET_TYPE_SLOT] = "SlotSocket",
 }

Socket.s_sockets = {}

--[[
    @desc: 
    author:{author}
    time:2018-11-23 15:29:35
    --@socketId: 每条socket的唯一ID
    @return:
]]
function Socket:ctor(socketId)
    self.m_socketID = socketId
    self.m_nServerStatus = g_SocketCmd.SOCKET_STATUS_NON
    Socket.s_sockets[socketId] = self
    self.heartbeatInterval = 15
    self.m_reConnectTimes = 0
    self.m_reconnectMaxTimes = 3 -- 最大重连次数
    self.m_heartbeatTimeout = 0  -- 心跳超时次数
    self.m_name = socketName[self.m_socketID]
end

function Socket:connect(ip, port)
    Log.d("Socket:connect",self.m_name,ip,port)
    self:setAutoReconnect(true)
    if self.m_nServerStatus == g_SocketCmd.SOCKET_STATUS_CONNECTING or self.m_nServerStatus == g_SocketCmd.SOCKET_STATUS_CONNECTED then
        Log.d("Socket:connect REPEAT",self.m_name,ip,port)
        return
    end
    if not ip or not port then
        self:reConnectTimeout()
        return
    end
    self.m_ip = ip
    self.m_port = port
    self.m_nServerStatus = g_SocketCmd.SOCKET_STATUS_CONNECTING
    self.m_socketID = g_GetIndex()
    NetManager.getInstance():addServer(self.m_socketID,self)
    NativeCall.lcc_connectToServer(self.m_socketID, ip, port)
end

function Socket:disConnect()
    Log.d("Socket:disConnect - ",self.m_name)
    self:setAutoReconnect(false)
    self:clear()
end

function Socket:clear()
    self:stopHeartbeat()
    self.m_nServerStatus = g_SocketCmd.SOCKET_STATUS_DISCONNECT
    NetManager.getInstance():removeServer(self.m_socketID)
    NativeCall.lcc_disconnectToServer(self.m_socketID)
end

function Socket:setAutoReconnect(reconnect)
    Log.d("Socket:setAutoReconnect - ",self.m_name,reconnect)
    self.m_autoReconnect = reconnect
end

function Socket:resetConnectTimes()
    self.m_reConnectTimes = 0
end

function Socket:reConnect()
    Log.d("Socket:reConnect - ",self.m_name)
    self:clear()
    self.m_reConnectTimes = self.m_reConnectTimes + 1
    self:connect(self.m_ip, self.m_port)
end

function Socket:reConnectHandler()
    Log.d("Socket:reConnectHandler - ",self.m_name)
    g_Schedule:schedulerOnce(function ()
        if not self.m_autoReconnect then return end
        if self.m_reConnectTimes < self.m_reconnectMaxTimes then
            self:reConnect()
        else
            self:reConnectTimeout()
        end
    end, 1)
end

function Socket:reConnectTimeout()
    Log.d("Socket:reConnectTimeout - ",self.m_name)
end

--[[
    @desc: socket状态回调函数。
    author:{author}
    time:2018-11-23 15:43:55
    --@eventId: 参考SocketCmd.lua类中SOCKET_STATU定义宏。
	--@eventArg: 
    @return:
]]
function Socket:onNetEventHandler(nEventId, pEventArg)
    Log.d("Socket:onNetEventHandler - name = ",self.m_name,", EventId = ",nEventId,"EventArg = ",pEventArg,", Status = ",self.m_nServerStatus, self.m_socketID)
    self.m_nServerStatus = nEventId

    if g_SocketCmd.SERVER_STATUS_CONNECTING == nEventId then                 -- 0 开始连接socket
        self:onConnectBegin(pEventArg);
    elseif g_SocketCmd.SOCKET_STATUS_CONNECTFAIL == nEventId or g_SocketCmd.SOCKET_STATUS_DISCONNECT == nEventId then  -- 2 3
        self:clear()
        if self.m_autoReconnect then
            self:reConnectHandler()
        end
        self:onDisconnect()
    elseif g_SocketCmd.SOCKET_STATUS_CONNECTED == nEventId then              -- 1 socket连接成功
        self:resetConnectTimes()
        self:startHeartbeat()
        self:onConnectComplete(pEventArg);
    end
end

function Socket:setHeartbeatInterval(interval)
    self.heartbeatInterval = interval
end

function Socket:setHeartbeatCMD(cmd)
    self.m_heartbeatCMD = cmd
end

function Socket:stopHeartbeat()
    if self.m_heartbeatTimer then
        self.m_heartbeatTimer:cancel()
        self.m_heartbeatTimer = nil
    end
end

function Socket:startHeartbeat()
    self.m_heartbeatTimeout = 0
    if self.m_heartbeatCMD then
        self.m_heartbeatTimer = g_Schedule:schedule(function()
            if  self.m_heartbeatCMD
                and self.m_nServerStatus == g_SocketCmd.SOCKET_STATUS_CONNECTED then
                    
                self:sendMsg(self.m_heartbeatCMD)
                self:onSendHeartbeat()
            end
        end, 5, self.heartbeatInterval or 10, -1)
    end
end

function Socket:onSendHeartbeat()
    Log.d("Socket:onSendHeartbeat - ",self.m_name)
    self.m_heartbeatTimeout = self.m_heartbeatTimeout + 1
end

function Socket:onConnectBegin()
    Log.d("Socket:onConnectBegin - ",self.m_name)
end

function Socket:onConnectComplete()
    Log.d("Socket:onConnectComplete - ",self.m_name)
end

function Socket:onConnectFailed()
    Log.d("Socket:onConnectFailed - ",self.m_name)
end

function Socket:onDisconnect()
    Log.d("Socket:onDisconnect - ",self.m_name)
end

--[[
    @desc: 接收消息入口
    author:{author}
    time:2018-11-27 10:02:05
    --@msgData:
	--@msgType: 
    @return:
]]
function Socket:parseMsg(msgType,msgData,msgSize)
    Log.s("Socket.parseMsg - ",self.m_name,msgType,msgSize)
    self.m_recData = by.ReadByteData:new(msgData,msgSize)
    if type(self.m_handler) == "function" then
        self.m_handler(self.m_handlerObj,msgType)
    end
    self.m_heartbeatTimeout = 0
end

function Socket:setReceiveHandler(obj,handler)
    self.m_handlerObj = obj
    self.m_handler = handler
end

function Socket:sendMsg(cmd)
    Log.s("Socket:sendMsg",self.m_name,string.format("0x%02x", cmd))
    NetManager.getInstance():sendMsgToCurServer(self.m_socketID, cmd, self.m_byteData or by.ByteData:new(1024))
end

function Socket:readByte()
    return self.m_recData:readByte()
end

function Socket:readShort()
    return self.m_recData:readShort()
end

function Socket:readInt()
    return self.m_recData:readInt32()
end

function Socket:readInt64()
    return self.m_recData:readInt64()
end

function Socket:readString()
    return self:readStringEx()
end

function Socket:readStringEx()
    local ret = self.m_recData:readData(self.m_recData:readInt32()-1)
     self.m_recData:readData(1)
    return ret
end

function Socket:writeBegin(len)
    self.m_byteData = by.ByteData:new(len or 1024)
end

function Socket:writeString(str)
    local len = string.len(str)
    self:writeInt(len + 1)
    self.m_byteData:writeData(str, len)
    self:writeByte(0)
end

function Socket:writeInt(num)
    self.m_byteData:writeInt32(num)
end

function Socket:writeInt64(num)
    self.m_byteData:writeInt64(num)
end

function Socket:writeByte(b)
    self.m_byteData:writeByte(b)
end

function Socket:writeShort(short)
    self.m_byteData:writeShort(short)
end

return Socket

