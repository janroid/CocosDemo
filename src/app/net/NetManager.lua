local NetManager = class("NetManager")
local GameSocket = import("GameSocket")

function NetManager:ctor( )
    self.m_gameSocket = GameSocket.new()
end

function NetManager:getInstance( )
    if not NetManager.s_instance then
        NetManager.s_instance = NetManager.new()
    end

    return NetManager.s_instance
end

function NetManager:getGameSocket( )
    if not self.m_gameSocket then
        self.m_gameSocket.new()
    end

    return self.m_gameSocket
end

function NetManager:openGameSocket( )
    local ip = "127.0.0.1"
    local port = 3563

    self.m_gameSocket:connect(ip,port)
end

function NetManager:sendSocketMsg(cmd, data)
    self.m_gameSocket:sendMsg(cmd, data)
end



return NetManager