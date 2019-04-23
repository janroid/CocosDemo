--[[
    author:{JanRoid}
    time:2018-1-2
    Description: 老虎机socket连接管理
]] 

local SlotSocket = require("slotSocket.SlotSocket")
local SlotSocketManager = class("SlotSocketManager")

SlotSocketManager.s_eventFuncMap = {
    [g_SceneEvent.SLOT_CONNECT_RESULT] = "onConnectResult";
    [g_SceneEvent.ROOM_LOGIN_SUCCESS] = "checkReconnect"; -- 登陆房间成功后，尝试重连老虎机，解决断网后老虎无法重连bug
}

function SlotSocketManager:ctor(socket)
    self:registerEvent()
    self.m_socket = SlotSocket:create()
end

function SlotSocketManager:dtor()
    g_EventDispatcher:unRegisterAllEventByTarget(self)
    self:closeSocket()
end

function SlotSocketManager:openSocket()
    local ip, port = g_ProxyManager:getProxyIpPort()

    Log.d("SlotSocketManager:openSocket --> ",ip, port)
    if not ip or not port then
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECONNECT_MSG)  
        return 
    end
    
    self.m_socket:connect(ip, port)
end

function SlotSocketManager:closeSocket()
    Log.d("SlotSocketManager:closeSocket --> ")
    self.m_socket:disConnect()
end

--[[
    @desc: 请求玩一局老虎机
    author:{author}
    time:2019-01-14 18:01:17
    --@betMoney: 
    @return:
]]
function SlotSocketManager:requestPlay(betMoney)
    Log.d("SlotSocketManager:requestPlay --> ",betMoney)
    if not self.m_socket:isConnected() then  -- 检查老虎机是否连上
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_FAIL_MSG)  
        self.m_socket:reConnect()
        Log.d("SlotSocketManager:requestPlay in not connected ")
        return
    end

    betMoney = tonumber(betMoney)
    if not betMoney or betMoney < 0 then
        Log.e("SlotSocketManager:requestPlay - betMoney is nil")
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_LESS_CHIPS)
        return
    end

    self.m_socket:requestPlay(betMoney)
    return true
end

--[[
    @desc: 计算牌型概率
    author:{author}
    time:2019-01-14 18:03:55
    --@cardMap: 
    @return:
]]
function SlotSocketManager:requestCalculate(cardMap)
    if not self.m_socket:isConnected() then -- -- 检查老虎机是否连上
        self.m_socket:reConnect()

        return
    end

    if not cardMap or next(cardMap) == nil then
        Log.e("SlotSocketManager:requestCalculate - cardMap is null or nil !")
        return
    end

    self.m_socket:requestCalculate(cardMap)
end

-- 老虎机显示结果
function SlotSocketManager:onSlotResult(data)
    g_EventDispatcher:dispatch(g_SceneEvent.SLOT_RESULT, data)
end

--[[
    @desc: socket连接状态
    --@mtype: 0：重连成功，1：连接失败，2：返回超时, 3:网络断线
    @return:
]]
function SlotSocketManager:onConnectResult(mtype)
    Log.d("SlotSocketManager:onConnectResult - ",mtype)
    
    if mtype == 0 then
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECON_SUCC)
    elseif mtype == 3 then
        -- g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECONNECT_MSG)
    elseif mtype == 2 then
        g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_RECONNECT_MSG)
        self:onSlotResult({}) 
    elseif mtype == 1 then
        -- g_EventDispatcher:dispatch(g_SceneEvent.SLOT_SHOW_TIPS, g_ClientConfig.SLOT_MSG_TYPE.SLOT_FAIL_MSG)    
    end
end

function SlotSocketManager:checkReconnect()
    if not self.m_socket:isConnected() then
        self.m_socket:reConnect()
    end
end

function SlotSocketManager:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        assert(self[v],"配置的回调函数不存在")
	        g_EventDispatcher:register(k,self,self[v])
	    end
	end
end


return SlotSocketManager