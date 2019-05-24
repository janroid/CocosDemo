local Socket = require("framework.net.Socket")
local GameSocketReceive = import("SocketReceive")

local GameSocket = class("GameSocket",Socket)

function GameSocket:ctor()
    Socket.ctor(self, g_SocketCmd.SERVER_GAME)
    self.m_receive = GameSocketReceive.new()

end


function GameSocket:receiveMsg(cmd, msgSize, msgData)
    local data = g_Protobuf:decode(cmd,msgData) or {}
    Log.d("GameSocket:receiveMsg",", cmd = ", cmd, "data = ", data)

    if self.m_receive then
        self.m_receive:receive(cmd,data)
    end
end

function GameSocket:sendMsg(cmd, data)
    local bodyBuf = g_Protobuf:encode(cmd, data)
	local size = bodyBuf and string.len(bodyBuf) or 0

    Socket.sendMsg(self,cmd, bodyBuf, size)
end
return GameSocket