local ServerManager = class("ServerManager")

local DataCenter = import("DataCenter")

function ServerManager:ctor(receive)
    if not receive then
        Log.d("ServerManager:ctor - receive is nil")
        return
    end

    self.m_receive = receive
    self.m_dataCenter = DataCenter.new()
end

function ServerManager:login(data)
    local name = data[1]
    local pwd = data[2]

    local result = {}

    if not name or not pwd then
        result.error = -1

        self.m_receive:receive(g_SocketCmd.NET_LOGIN, result)

        return
    end

    if string.len(name) < 1 or string.len(pwd) < 1 then
        result.error = -1

        self.m_receive:receive(g_SocketCmd.NET_LOGIN, result)

        return
    end

    local user = self.m_dataCenter:getUser(name, pwd)

    if user then
        result.error = 0
        result.info = user
    else
        result.error = -2
    end

    self.m_receive:receive(g_SocketCmd.NET_LOGIN, result)
end

function ServerManager:register(data)
    local name = data[1]
    local pwd = data[2]
    local agin = data[3]

    local result = {}

    if pwd ~= agin then
        result.error = -2

        self.m_receive:receive(g_SocketCmd.NET_REGISTER, result)

        return
    end

    if not name or not pwd or not agin or string.len(name) < 1 or string.len(pwd) < 1 or string.len(agin) < 1 then
        result.error = -1

        self.m_receive:receive(g_SocketCmd.NET_REGISTER, result)

        return
    end

    local user = self.m_dataCenter:registerUser(name,pwd)

    if user then
        result.error = 0
        result.info = user
        self.m_receive:receive(g_SocketCmd.NET_LOGIN, result)
    else
        result.error = -3
        self.m_receive:receive(g_SocketCmd.NET_REGISTER, result)
    end
end

function ServerManager:accountInfo( )
    
end



return ServerManager