local SocketReceive = class("SocketReceive")

function SocketReceive:ctor()
    
end

function SocketReceive:receive(cmd, data)
    if cmd == g_SocketCmd.NET_LOGIN then
        self:receiveLogin(data)
    elseif cmd == g_SocketCmd.NET_REGISTER then
        self:receiveRegister(data)
    end
end


function SocketReceive:receiveLogin(data)
    g_EventDispatcher:dispatchEvent(g_CustomEvent.LGOIN_RPS_LOGIN, data)
end

function SocketReceive:receiveRegister(data)
    g_EventDispatcher:dispatchEvent(g_CustomEvent.LOGIN_RPS_REGISTER, data)
end


return SocketReceive