
local GameProtocol = require ".GameProtocol"

local Net = import("framework.net");
local NetManager = Net.NetManager
local Connect = Net.Connect


local GameServer = class("GameServer",Connect)


function GameServer:ctor(nNetSocketId,delegate)
	Connect.ctor(self,nNetSocketId,delegate)
end

function GameServer:dtor()
	self:disconnect()
end


function GameServer:parseMsg(msgType,msgData,msgSize)


	local msgName = self.m_protocol.getProtocolTypeName(msgType)
	local msg = protobuf.decode(msgName, msgData, msgSize) 


    if type(msg) =='table' then
		print("GameServer:parseMsg success = " .. msgName.." msgSize="..msgSize)    
		g_EventDispatcher:dispatch(2,"解析数据成功")
    else
		print("GameServer:parseMsg fail = " .. msgName.." msgSize="..msgSize)    
		g_EventDispatcher:dispatch(2,"解析数据失败")
    end
		
--	NetSys:onEvent(msgType,msg)
end


function GameServer:onConnectComplete( nEventId,pEventArg)
	self.m_protocol = GameProtocol:create()
	Connect.onConnectComplete(self,nEventId,pEventArg)
	
end



function GameServer:reqLogin()
	local data = self.m_protocol:plLogin()
	NativeCall.lcc_sendMsgToServer(self.m_nNetSocketId,4097,data)
end



return GameServer