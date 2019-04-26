local NetManager = class("NetManager")

local SocketSender = import(".SocketSender")
local HttpReceive = import(".HttpReceive")

function NetManager:ctor( )
    self.m_socketSender = SocketSender.new()

end

function NetManager:getInstance( )
    if not NetManager.s_instance then
        NetManager.s_instance = NetManager.new()
    end

    return NetManager.s_instance
end

function NetManager:getSender( )
    return self.m_socketSender
end

function NetManager:postUrl(cmd, param, obj, func)
    if not cmd then
        Log.e("NetManager:postUrl - error: cmd is null!")

        return
    end

    self.m_httpReceive:receive(cmd,obj,func)
end


return NetManager