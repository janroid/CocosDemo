--[[
    author:{JanRoid}
    time:2018-1-3
    Description: 老虎机Socket
    断线重连机制：
        1、断线后会进行3次重连
        2、玩家调用request接口，会触发重连
        3、房间server连接成功，会触发重连
]] 

local Socket = import("framework.socket").Socket

local SlotSocket = class("SlotSocket",Socket)

function SlotSocket:ctor()
    Socket.ctor(self, g_SocketCmd.SOCKET_TYPE_SLOT)
    self.m_isReconnecting = false
    Log.d("SlotSocket:ctor id = ",g_SocketCmd.SOCKET_TYPE_SLOT)
end

function SlotSocket:dtor()
    self:timeOutClear()
end

function SlotSocket:connect(ip,port)
    Log.d("SlotSocket:connect --> ",ip,port)
    if self.m_nServerStatus == g_SocketCmd.SOCKET_STATUS_CONNECTING then
        return
    end

    Socket.connect(self,ip,port)
end

function SlotSocket:reConnect()
    Log.d("SlotSocket:reConnect")
    self.m_isReconnecting = true
    self.m_ip, self.m_port = g_ProxyManager:getProxyIpPort()
    Socket.reConnect(self)
end

function SlotSocket:disConnect( )
    Log.d("SlotSocket:disConnect --> ")
    Socket.disConnect(self)
end

--[[
    @desc: 重连超过次数
    author:{author}
    time:2019-01-15 11:57:27
    @return:
]]
function SlotSocket:reConnectTimeout()
    Log.d("SlotSocket:reConnectTimeout")
    self.m_isReconnecting = false
    g_EventDispatcher:dispatch(g_SceneEvent.SLOT_CONNECT_RESULT, 1)
end

function SlotSocket:onConnectComplete()
    Log.d("SlotSocket:onConnectComplete")
    
    self:connectSlot()
    self:requestLogin()
    if self.m_isReconnecting then
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_CONNECT_RESULT, 0)  
    end
    
    self.m_isReconnecting = false
end

function SlotSocket:onConnectFailed()
    Log.d("SlotSocket:onConnectFailed")

    g_EventDispatcher:dispatch(g_SceneEvent.SLOT_CONNECT_RESULT, 1)
end

function SlotSocket:onDisconnect()
    Log.d("SlotSocket:onDisconnect ")
    g_EventDispatcher:dispatch(g_SceneEvent.SLOT_CONNECT_RESULT, 3)
end

function SlotSocket:parseMsg(cmd,msgData,msgSize)
    Log.s("SlotSocket.parseMsg",cmd,msgSize)
    Socket.parseMsg(self,cmd,msgData,msgSize)

    self:timeOutClear()

    if cmd == g_SocketCmd.SlotSocketCMD.SLOT_SVR_RECV_CMD_CALCULATOR then
        self:receiveCalculate()
    elseif cmd == g_SocketCmd.SlotSocketCMD.SLOT_SVR_RECV_CMD_SLOT_SUCC then
        self:receiveSlotSuccess()
    elseif cmd == g_SocketCmd.SlotSocketCMD.SLOT_SVR_RECV_CMD_SLOT_FAIL then
        self:receiveSlotFail()
    else
        self:receiveSocketFail()
    end
end

--[[
    @desc: 连接到老虎机server
    @return:
]]
function SlotSocket:connectSlot()
    local ip = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "slotIp")
    local port = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "slotPort")
    Log.d("SlotSocket:connectSlot - ", ip, port)
    self:writeBegin()
    self:writeString(ip)
	self:writeInt(port)
	self:sendMsg(g_SocketCmd.RoomSocketCMD.CLI_CMD_PROXY_LOGIN)
end

--[[
    @desc: 登陆老虎机
    @return:
]]
function SlotSocket:requestLogin()
    Log.d("SlotSocket:requestLogin - ", g_AccountInfo:getId(), g_AccountInfo:getmtkey())
    self:writeBegin()
    self:writeInt(g_AccountInfo:getId() or 0)
    self:writeString(g_AccountInfo:getmtkey() or "")
    self:sendMsg(g_SocketCmd.SlotSocketCMD.SLOT_SVR_SEND_CMD_LOGIN)
end

--[[
    @desc: 玩老虎机
    --@betMoney: 下注额度
    @return:
]]
function SlotSocket:requestPlay(betMoney)
    Log.d("SlotSocket:requestPlay - betMoney = ",betMoney)
    self:writeBegin()
    self:writeInt(g_AccountInfo:getId())
    self:writeInt64(betMoney)
    self:sendMsg(g_SocketCmd.SlotSocketCMD.SLOT_SVR_SEND_CMD_SLOT)

    self:timeOutStart()
end

--[[
    @desc: 计算牌型概率
    --@cardMap: 牌数组
    @return:
]]
function SlotSocket:requestCalculate(cardMap)
    Log.d("SlotSocket:requestCalculate - ", cardMap)
    self:writeBegin()
    self:writeInt(#cardMap)
    for k,v in ipairs(cardMap) do
        self:writeInt(v)
    end
    self:sendMsg(g_SocketCmd.SlotSocketCMD.SLOT_SVR_SEND_CMD_CALCULATOR)

    self:timeOutStart()
end

--[[
    @desc: 计算牌型回调
    author:{author}
    time:2019-01-14 18:07:06
    @return:
]]
function SlotSocket:receiveCalculate()
    local cardProbability = {}
    for i = 1, 8 do
        local probability = self:readInt()
        cardProbability[i] = tonumber(string.format("%.1f", (probability * 0.01))) --保留1小数
    end
            
    Log.d("SlotSocket:receiveCalculate - ",cardProbability)
    --设置算牌器显示数据
    --g_Model:setData(g_ModelCmd.ROOM_CALCULATOR_DATA, cardProbability);
end

--[[
    @desc: 老虎机中奖结果
    author:{author}
    time:2019-01-14 18:07:18
    @return:
]]
function SlotSocket:receiveSlotSuccess()
    local data = {}

    data.betMoney  = self:readInt64()
    data.winMoney  = self:readInt64()
    data.cardMap = {}
    data.cardMap[1] = self:readShort() --第一张牌
    data.cardMap[2] = self:readShort() --第二张牌
    data.cardMap[3] = self:readShort() --第三张牌
    data.cardMap[4] = self:readShort() --第四张牌
    data.cardMap[5] = self:readShort() --第五张牌
    data.inMoney = self:readInt64()  -- 座位上的钱
    data.outMoney = self:readInt64() -- 座位外的钱（玩家的钱 = 座位上的钱 + 座位外的钱）
    data.totalMoney = data.inMoney + data.outMoney
    
    Log.d("SlotSocket:receiveSlotSuccess - ",data)

    g_EventDispatcher:dispatch(g_SceneEvent.SLOT_RESULT, data)
end

--[[
    @desc: 老虎机异常
    author:{author}
    time:2019-01-14 18:07:34
    @return:
]]
function SlotSocket:receiveSlotFail()
    local data = {}

    data.outMoney   = self:readInt64()
    data.betMoney    = self:readInt64()
    data.inMoney = self:readInt64()
    data.totalMoney = data.inMoney + data.outMoney

    Log.d("SlotSocket:receiveSlotFail - ",data)
    g_EventDispatcher:dispatch(g_SceneEvent.SLOT_RESULT, data)      
end

--[[
    @desc: 出现未知返回数据时，当做超时处理
]]
function SlotSocket:receiveSocketFail()
    self:timeOutStart()
end

--[[
    @desc: 发送命令超时检测
    @return:
]]
function SlotSocket:timeOutStart()
    self:timeOutClear()

    self.m_sendScheduler = g_Schedule:schedulerOnce(function()
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_CONNECT_RESULT, 2)
        self.m_sendScheduler = nil
        self:reConnect()
    end, 5)
end

function SlotSocket:timeOutClear()
    if self.m_sendScheduler then
        g_Schedule:cancel(self.m_sendScheduler)
        self.m_sendScheduler = nil
    end   
end

function SlotSocket:isConnected()
    return (self.m_nServerStatus == g_SocketCmd.SOCKET_STATUS_CONNECTED)
end

function SlotSocket:isReconnecting()
    return self.m_isReconnecting
end

return SlotSocket