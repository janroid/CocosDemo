--[[--ldoc desc
@module ServerCtr
@author KuovaneWu
Date   2018-10-26
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local GameServer =   require ".GameServer"


local ServerCtr = class("ServerCtr",cc.Node);


BehaviorExtend(ServerCtr);



---配置事件监听函数
ServerCtr.eventFuncMap =  {
	---配置事件监听函数
	[1] = "onSendMsg",
	[2] = "onRecvMsg"
}


local function initProtocol()
	local protos = {
        "dev/demo/templateDemo/server/MsgType.pb",
        "dev/demo/templateDemo/server/MsgProtocol.pb",
    }
    for k,v in pairs(protos) do
        local pbFilePath = cc.FileUtils:getInstance():fullPathForFilename(v)       	  
	    local buffer = readProtobufFile(pbFilePath)      
	    protobuf.register(buffer)--注:protobuf 是因为在protobuf.lua里面使用module(protobuf)来修改全局名字  
    end
end


function ServerCtr:ctor(delegate)
	--ViewCtr.ctor(self,delegate);
	initProtocol()
	self.m_gameServer = GameServer:create(2,self)
	self.m_gameServer:requestConnect("127.0.0.1",14001)
end



function ServerCtr:onCleanup()
	--ViewCtr.onCleanup(self);
	-- xxxxxx
end

---刷新UI
function ServerCtr:updateView(data)
	local ui = self:getParent();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function ServerCtr:haldler(status,...)
end

function ServerCtr:onSendMsg(msg)
	print("ServerCtr:onSendMsg")
end

function ServerCtr:onRecvMsg(msg)
	print("ServerCtr:onRecvMsg")
	self:updateView({result="解析成功"})
end



local VXSOCKET_EVENT_CONNECT_BEGIN = 0
local VXSOCKET_EVENT_CONNECT_COMPLETE = 1
local VXSOCKET_EVENT_CONNECT_FAILED = 2
local VXSOCKET_EVENT_CLOSED = 3
local VXSOCKET_EVENT_RECV = 4
local VXSOCKET_EVENT_SEND = 5

function ServerCtr:connectResult(nNetSocketId,nEventId,pEventArg)

	 print("ServerCtr:connectResult")
	 local result = "连接服务器中..."
	 if g_SocketCmd.SOCKET_EVENT_CONNECT_BEGIN == nEventId then
	
		
	 elseif g_SocketCmd.SOCKET_EVENT_CONNECT_FAILED == nEventId then
	 	result = "连接服务器失败"
	 elseif g_SocketCmd.SOCKET_EVENT_CONNECT_COMPLETE == nEventId then
	 	result = "连接服务器成功"
	 	self.m_gameServer:reqLogin()
	 	--self:onSendMsg("")
     end
	 self:updateView({result=result})
end



return ServerCtr;