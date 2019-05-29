local SocketReceive = class("SocketReceive")

function SocketReceive:ctor()
    
end

function SocketReceive:receive(cmd, data)
    if cmd == g_GamePb.method.RpsAuthor then
    	local mtype = getNumFromTable(data, "Type", g_ServerConfig.LOGIN_TYPE.NONE)
    	if mtype == g_ServerConfig.LOGIN_TYPE.LOGIN then
    		self:receiveLogin(data)
    	elseif mtype == g_ServerConfig.LOGIN_TYPE.REGISTER then
    		self:receiveRegister(data)
    	end
	elseif cmd == g_GamePb.method.RpsUserInfo then
		self:receiveUserInfo(data)
	else
		Log.d("SocketReceive.receive - cmd =",cmd, ", not received !")
	end
end


function SocketReceive:receiveLogin(data)
    g_EventDispatcher:dispatchEvent(g_CustomEvent.LOGIN_RPS_LOGIN, data)
end

function SocketReceive:receiveRegister(data)
    g_EventDispatcher:dispatchEvent(g_CustomEvent.LOGIN_RPS_REGISTER, data)
end

function SocketReceive:receiveUserInfo(data)
	g_EventDispatcher:dispatchEvent(g_CustomEvent.USERINFO_RPS, data)
end


return SocketReceive