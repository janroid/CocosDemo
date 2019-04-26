local NetManager = require("framework.net.NetManager")
local NativeCall = {}

function NativeCall.lcc_connectToServer(netSocketId,ip,port,protocol)
	if XG_USE_FAKE_SERVER then

		NativeCall.ccl_socketEvent(netSocketId,g_Event.SOCKET_EVENT_CONNECT_BEGIN)
		NativeCall.ccl_socketEvent(netSocketId,g_Event.SOCKET_EVENT_CONNECT_COMPLETE)

		return 
	end
    projectx.lcc_connectToServer(netSocketId,ip,port,protocol or 0)
end

function NativeCall.lcc_disconnectToServer(netSocketId)
    projectx.lcc_disconnectToServer(netSocketId)
end


function NativeCall.ccl_socketEvent(netSocketId,eventId,arg)
    print("ccl_socketEvent="..netSocketId.." eventId="..eventId)
    NetManager.getInstance():onNetEventHandler(netSocketId,eventId,arg)
    return 1
end


function NativeCall.lcc_sendMsgToServer(netSocketId,msgType,msgData)

	if XG_USE_FAKE_SERVER then
		NetSys:onEvent(msgType,msgData)
		return 
	end
	print("发送消息")
	projectx.lcc_sendMsgToServer(netSocketId,msgType,msgData:getData(),msgData:getLength())
end


function NativeCall.ccl_recvMsgFromServer(netSocketId,msgType,msgSize,msgData)
	print("接收消息")
	print("start lcc_recvMsgFromServer =xxx"..netSocketId)
	NetManager.getInstance():parseMsg(netSocketId,msgType,msgData,msgSize)
    print("end lcc_recvMsgFromServer =xxx"..netSocketId)
	--projectx.lcc_sendMsgToServer(netSocketId,msgType,msgData)
end


function NativeCall.lcc_download(url,identifier)
	--print("NativeCall.lcc_download="..url)
	projectx.lcc_download(url,identifier)
	--print("NativeCall.lcc_download22222=2"..url)
end

function NativeCall.lcc_getMD5Hash(data)
	return projectx.lcc_getMD5Hash(data)
end

function NativeCall.lcc_getMD5HashFromFile(fileName)
	return projectx.lcc_getMD5HashFromFile(fileName)
end

function NativeCall.lcc_unCompress(fileName,outDir,passworld)
	return projectx.lcc_unCompress(fileName,outDir or "",passworld or "")
end

function NativeCall.lcc_setDefaultFontName(fontName)
	return projectx.lcc_setDefaultFontName(fontName or "")
end


function NativeCall.lcc_setGLProgramState(node,  shadeId)
	projectx.lcc_setGLProgramState(node,  shadeId)
end


function NativeCall.lcc_callSystemEvent(key,  data)
	projectx.lcc_callSystemEvent(key, data)
end


function NativeCall.ccl_systemCallLuaEvent(key,  data)
	print("ccl_systemCallLuaEvent"..key..data)
	local callbackEntry = nil
	local callback = function()
		NativeEvent.getInstance():nativeCallLua(key, data)
		if callbackEntry then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(callbackEntry)
			callbackEntry = nil
		end
	end
	callbackEntry =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback,0.01,false)
end


function NativeCall.ccl_appPause()
	print("ccl_appPause")
	g_EventDispatcher:dispatch(g_SceneEvent.EVENT_APP_PAUSE)
end


function NativeCall.ccl_appResume()
	print("ccl_appResume")
	g_EventDispatcher:dispatch(g_SceneEvent.EVENT_APP_RESUME)
end

return NativeCall;