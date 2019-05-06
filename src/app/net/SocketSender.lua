local SocketSender = class("SocketSender")

local SocketReceive = import("SocketReceive")
local ServerManager = import("clientServer.ServerManager")

function SocketSender:ctor()
    self.m_receive = SocketReceive.new()

    self.m_serverManager = ServerManager.new(self.m_receive)
end

function SocketSender:sendLogin(data)
    self.m_serverManager:login(data)
end

function SocketSender:sendRegister(data)
    self.m_serverManager:register(data)
end

return SocketSender