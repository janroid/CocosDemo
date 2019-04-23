
local socket = require1 "socket"
local net = import('framework.net');
local Connect = net.Connect;
local BaseSocket = net.BaseSocket;

-- 对外暴露的接口
local exportInterface = {
	"openSocket",
	"closeSocket",
	"sendMsg",
	"isConnected",
};

local configMap = require("Config");
local socketWrite = require("SocketWrite");
local socketReader = require("SocketReader");

local SocketManager = class("SocketManager",BaseSocket)
BehaviorExtend(SocketManager);

SocketManager.eventFuncMap =  {
};

function SocketManager:ctor(netType)
	BaseSocket.ctor(self);
    self.m_nNetSocketId = netType or NET_SOCKET_COMMON;
	self.socket = Connect:create(self.m_nNetSocketId,self);
	self:bindBehavior(BehaviorMap.PublicBehavior); -- 绑定公共方法检测组件
	self:initPublicFunc(exportInterface); -- 设置公共方法

	-- 绑定socket组件
	local behaviorMap = checktable(configMap.behaviorMap);
	for k,v in pairs(behaviorMap) do 
		self:bindBehavior(v);
	end
	self:initHeadConfig(self:getHeadConfig()); -- 初始化包头配置

    self:addBodyWriter(socketWrite:create());
    self:addBodyReader(socketReader:create());

    self:initListener();
end

function SocketManager:initListener()
	self.eventFuncMap[self.m_nNetSocketId] = "onReceiveMsg";
	self:registerEvent();
end

function SocketManager:onCleanup()
	self:closeSocket();
	self:unRegisterEvent();
end

-- 打开socket
function SocketManager:openSocket(ip,port)
	if not self:isConnected() then
		self.socket:requestInterface("requestConnect",ip,port);
	end
end

-- 关闭socket
function SocketManager:closeSocket()
	self.socket:requestInterface("closeSocket");
end

-- socket连接结果
function SocketManager:connectResult(type,eventId,info)
	dump("socket连接结束",eventId)
	g_EventDispatcher:dispatch(eventId,info);
end


-- 是否已经连接成功
function SocketManager:isConnected()
	return self.socket:requestInterface("isConnected")
end

-- 发送socket消息
function SocketManager:sendMsg(data)
	local info = self:getSendMsg(data);
	self.socket:requestInterface("sendMsg",info);
	-- self:onReceiveMsg(info:getData(),info:getLength());
end

-- 接收socket消息
function SocketManager:onReceiveMsg(msgData,msgSize)
    local msg = self:receiveMsg(msgData,msgSize);
    self:dispatchReceiveMsg(msg);
end

return SocketManager
