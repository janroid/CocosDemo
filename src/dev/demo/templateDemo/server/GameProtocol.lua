local GameMsgType = require ".GameMsgType"
local GameServerId = GameMsgType.GameServerId
local GameServerIdName = GameMsgType.GameServerIdName
local GameProtocol = class("GameProtocol")

function GameProtocol:ctor()
  self.m_selfServerId = 0
  self.m_selfIndex = 0
end

function GameProtocol.getEventType(sProtocolMsgType)

	local msgType = protobuf.enum_id("XGMsg.GameServerId", sProtocolMsgType)  
	if msgType == nil then
		print("error ="..sProtocolMsgType)
	end
	return msgType
end

function GameProtocol.getProtocolType(nEventType)

end

function GameProtocol.getProtocolTypeName(nMsgType)
	return GameServerIdName[nMsgType] or ""
end

function GameProtocol:plHead(cmd,dataSize)
	local head = protobuf.pack("XGMsg.MsgHeadData cmd msgSize",cmd,dataSize) 
	return head
end
	-- ==================== begin: sending protocols ====================
function GameProtocol:plHeartBeat()
end

function GameProtocol:plLogin(tid,uid,mtkey,imgUrl,giftId,passworld) 

   
  --[[local stringbuffer = protobuf.pack("XGMsg.RoomReqLoginData tid uid mtkey imgUrl giftId passworld",1,1,"mtkey","url",1,"123456") 
  local dataSize = string.len(stringbuffer)
  local headData = self:plHead(GameServerId.CLI_CMD_LOGIN,dataSize)
  local len = string.len(headData)
  local pb = len..headData..stringbuffer
  
]]

  local byteData = by.ByteData:new()
  byteData:writeInt32(121)
  byteData:writeData("abc",3)
  return byteData
end

function GameProtocol:plExitGame()
end

return GameProtocol



