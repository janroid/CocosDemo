
local BaseSocket = class("BaseSocket")

function BaseSocket:ctor()
	-- self:enableNodeEvents()
	self.mBodyWriters = {};
	self.mBodyReaders = {};
end

function BaseSocket:onCleanup()
	self.mBodyWriters = {};
	self.mBodyReaders = {};
end

--[[--
初始化包头配置
]]
function BaseSocket:initHeadConfig(config)
	self.headConfig = config;
end

-- 封装发送socket消息
function BaseSocket:getSendMsg(data)
	local bodyBuf = self:writeBody(data); -- body内容
	local size = bodyBuf and string.len(bodyBuf) or 0; -- body长度
	local byteWrite = by.ByteData:new(1024);
	local headBuf = self:onWriteHead(byteWrite,size,self.headConfig) -- head
	if bodyBuf then
		byteWrite:writeData(bodyBuf,size);
	end
	return byteWrite;
end

--[[
解析数据包
	@msgData：消息内容,二进制数据
	@msgSize：消息长度
]]
function BaseSocket:receiveMsg(msgData,msgSize)
	local readObj = by.ReadByteData:new(msgData,msgSize);
	local bodyLen = self:onReadHead(readObj,self.headConfig); -- 解析head获得body的长度
	local body = readObj:readData(bodyLen); -- 读取body内容
	local data = self:readBody(body); -- 解析body
	return data;
end

-- 写入数据包
function BaseSocket:writeBody(data)
	for i,writer in ipairs(self.mBodyWriters) do
		local bodyBuf = writer:writePacket(data);
		if bodyBuf then
			return bodyBuf;
		end
	end
end

-- 读取数包
function BaseSocket:readBody(bodyBuf)
	for i,reader in ipairs(self.mBodyReaders) do
		local bodyData = reader:readPacket(bodyBuf);
		if bodyData then
			return bodyData;
		end
	end
end
--[[--
添加写包处理
@param bodyWriter 写包处理器
]]
function BaseSocket:addBodyWriter(bodyWriter)
	table.insert(self.mBodyWriters,1,bodyWriter)
end

--[[--
添加读包处理
@param bodyReader 读包处理器
]]
function BaseSocket:addBodyReader(bodyReader)
	table.insert(self.mBodyReaders,1,bodyReader)
end


--[[--
添加写包处理
@param bodyWriter 写包处理器
]]
function BaseSocket:removeBodyWriter(bodyWriter)
	g_ableLib.removeByValue(self.mBodyWriters,bodyWriter)
end

--[[--
添加读包处理
@param bodyReader 读包处理器
]]
function BaseSocket:removeBodyReader(bodyReader)
	g_ableLib.removeByValue(self.mBodyReaders,bodyReader)
end

return BaseSocket;