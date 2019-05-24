local SocketReceive = class("SocketReceive")

function SocketReceive:ctor()
    
end

function SocketReceive:receive(cmd, data)
    
end


function SocketReceive:receiveLogin(data)
    g_EventDispatcher:dispatchEvent(g_CustomEvent.LOGIN_RPS_LOGIN, data)
end

function SocketReceive:receiveRegister(data)
    g_EventDispatcher:dispatchEvent(g_CustomEvent.LOGIN_RPS_REGISTER, data)
end


return SocketReceive