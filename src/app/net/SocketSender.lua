local SocketSender = class("SocketSender")

local SocketReceive = import(".SocketReceive")
local ServerManager = import(".clientServer/ServerManager")

function SocketSender:ctor()
    self.m_receive = SocketReceive.new()

    self.m_serverManager = ServerManager.new(self.m_receive)
end

return SocketSender