--[[
    author:{JanRoid}
    time:2018-12-3
    Description: 房间Socket类
]] 

local Socket = import("framework.socket").Socket

local RoomSocket = class("RoomSocket",Socket)

function RoomSocket:ctor()
    Socket.ctor(self, g_SocketCmd.SOCKET_TYPE_ROOM)
end

function RoomSocket:onConnectComplete()
    Log.d("RoomSocket:onConnectComplete")
    g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CONNECT_SUCCESS)
    g_Model:setData(g_ModelCmd.ROOM_HEARTBEAT_TIMEOUT_TIMES,self.m_heartbeatTimeout)
end

function RoomSocket:onConnectFailed()
    Log.d("RoomSocket:onConnectFailed")
end

--function RoomSocket:connect(ip, port)
--    Socket.connect(self, "159.138.53.187", 7009)
--end

function RoomSocket:reConnect()
    Log.d("RoomSocket:reConnect - ",self.m_name)
    self:clear()
    self.m_reConnectTimes = self.m_reConnectTimes + 1
    self:connect(g_ProxyManager:getProxyIpPort())
end

function RoomSocket:onDisconnect()
    Log.d("RoomSocket:onDisconnect")
end

function RoomSocket:reConnectTimeout()
    Log.d("RoomSocket:reConnectTimeout")
    g_Schedule:cancel(self.m_timer)
    g_Model:setData(g_ModelCmd.ROOM_HEARTBEAT_TIMEOUT_TIMES,4)
    g_Progress.getInstance():dismiss()
    g_AlertDialog.getInstance()
            :setTitle(GameString.get("tips"))
            :setContent(GameString.get("str_common_network_problem"))
            :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
            :setLeftBtnTx(GameString.get("str_common_retry"))
            :setRightBtnTx(GameString.get("str_common_back"))
            :setCloseBtnVisible(false)
            :setLeftBtnFunc(
                function ()
                    self:disConnect()
                    self:resetConnectTimes()
                    self:connect(g_ProxyManager:getProxyIpPort())
                    g_Progress.getInstance():show()
                end)
            :setRightBtnFunc(
                function ()
                    cc.Director:getInstance():popScene()
                end)
            :show()
end

function RoomSocket:onSendHeartbeat()
    Socket.onSendHeartbeat(self)
    self.m_sendHeartbeatTime = os.clock()--projectx.lcc_getmicrosecond()
    self.m_timer = g_Schedule:schedulerOnce(function ()
        g_Model:setData(g_ModelCmd.ROOM_HEARTBEAT_TIMEOUT_TIMES,3)
    end, 3)
    if self.m_heartbeatTimeout > 3 then
        self:disConnect()
        self:connect(g_ProxyManager:getProxyIpPort())
    end
end

function RoomSocket:parseMsg(msgType,msgData,msgSize)
    Socket.parseMsg(self,msgType,msgData,msgSize)
    if msgType == self.m_heartbeatCMD then
        g_Schedule:cancel(self.m_timer)
        local time = os.clock()--projectx.lcc_getmicrosecond()
        local dt = time - (self.m_sendHeartbeatTime or time)
        local i = math.floor(dt * 1000 / 50)
        Log.d("HeartbeatTime", self.m_sendHeartbeatTime, time, dt, i)
        g_Model:setData(g_ModelCmd.ROOM_HEARTBEAT_TIMEOUT_TIMES,i > 3 and 3 or i)
    end
end

return RoomSocket