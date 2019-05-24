--[[
    socket基类封装, 该类为全局类
    author:{Janroid}
    time:2018-11-23
]]

local Socket = class("Socket")

local socketName = {
    [g_SocketCmd.SERVER_GAME] = "GameSocket",
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
    self.m_reConnectTimes = 0
    self.m_reconnectMaxTimes = 3 -- 最大重连次数
    self.m_name = socketName[self.m_socketID]
end

function Socket:connect(ip, port)
    Log.d("Socket:connect",self.m_name,ip,port)
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
    NativeCall.lcc_connectToServer(self.m_socketID, ip, port, g_SocketCmd.SERVER_TYPE_RUNMOUSE)
end

function Socket:disConnect()
    Log.d("Socket:disConnect - ",self.m_name)
    self:clear()
end

function Socket:clear()
    self.m_nServerStatus = g_SocketCmd.SOCKET_STATUS_DISCONNECT
    NativeCall.lcc_disconnectToServer(self.m_socketID)
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
    Log.d("Socket:onNetEventHandler - name = ",self.m_name,", EventId = ",nEventId,"EventArg = ",pEventArg)
    self.m_nServerStatus = nEventId
    if g_SocketCmd.SOCKET_STATUS_CONNECTING == nEventId then                 -- 0 开始连接socket
        self:onConnectBegin(pEventArg);
    elseif g_SocketCmd.SOCKET_STATUS_CONNECTFAIL == nEventId or g_SocketCmd.SOCKET_STATUS_DISCONNECT == nEventId then  -- 2 3
        self:clear()
        self:onDisconnect()
    elseif g_SocketCmd.SOCKET_STATUS_CONNECTED == nEventId then              -- 1 socket连接成功
        self:resetConnectTimes()
        self:onConnectComplete(pEventArg);
    end
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
	--@cmd: 
    @return:
]]
function Socket:receiveMsg(cmd, msgSize, msgData)
    Log.s("Socket.parseMsg - ",self.m_name,cmd,msgSize)
    --local bodyBuf = g_Protobuf:decode(g_GamePb.method.LoginResult, msgData)
end

function Socket:sendMsg(cmd, bodyBuf, size)
    Log.s("Socket:sendMsg",self.m_name,string.format("0x%02x", cmd))
    if self.m_nServerStatus ~= g_SocketCmd.SOCKET_STATUS_CONNECTED then
        Log.d("Socket:sendMsg - error : socket not connected!")
        return 
    end
    NativeCall.lcc_sendMsgToServer(self.m_socketID, cmd, bodyBuf, size)
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


-------------------------------------- private func ---------------------------------------
function Socket._eventHandler(netSocketId, eventId, arg)
    if Socket.s_sockets[netSocketId] then
        Socket.s_sockets[netSocketId]:onNetEventHandler(eventId, arg)
    else
        Log.e("Socket._eventHandler - not SocketId find : id = ",netSocketId)
    end
end

function Socket._recvMsg(netSocketId, msgType, msgSize, msgData)
    if Socket.s_sockets[netSocketId] then
        Socket.s_sockets[netSocketId]:receiveMsg(msgType, msgSize, msgData)
    else
        Log.e("Socket._recvMsg - not SocketId find : id = ",netSocketId)
    end
end

return Socket

