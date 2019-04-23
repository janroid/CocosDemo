

local ChatManager = class("ChatManager")

ChatManager.s_eventFuncMap = {
    [g_SceneEvent.SHOW_TOP_TRUMPET_TIP]			= "showTopTrumpeTip",
    [g_SceneEvent.ROOM_CHAT_SEND_MESSAGE]			= "onSendTxtMsg",
    [g_SceneEvent.ROOM_CHAT_SEND_EMOTION]			= "onSendEmotion",
}

function ChatManager.getInstance()
    if(ChatManager.s_instance == nil) then
        ChatManager.s_instance = ChatManager:create()
    end
    return ChatManager.s_instance
end

function ChatManager.release()
    if ChatManager.s_instance then
        delete(ChatManager.s_instance)
    end
end

function ChatManager:ctor()
    self:registerEvent()
    self.m_txtMessages = {}
    self.m_emotionMessages = {}
    self.m_index = 0

    g_Model:watchData(g_ModelCmd.ROOM_CHAT_DATA,self, self.onRecieveTxtMsg,false)
    g_Model:watchData(g_ModelCmd.ROOM_SMALL_LABA_DATA,self,self.onRecieveSmallLabaMessage,false)
    g_Model:watchData(g_ModelCmd.ROOM_EXPRESSION_DATA,self, self.onRecieveEmotion,false)
    
end

function ChatManager:dtor()
    self:unRegisterEvent()

    g_Model:unwatchData(g_ModelCmd.ROOM_CHAT_DATA,self, self.onRecieveTxtMsg,false)
    g_Model:unwatchData(g_ModelCmd.ROOM_SMALL_LABA_DATA,self,self.onRecieveSmallLabaMessage,false)
	g_Model:unwatchData(g_ModelCmd.ROOM_EXPRESSION_DATA,self, self.onRecieveEmotion,false)
end

---注册监听事件
function ChatManager:registerEvent()
	if self.s_eventFuncMap then
	    for k,v in pairs(self.s_eventFuncMap) do
	        g_EventDispatcher:register(k,self,self[v])
	    end
	end
end

---取消事件监听
function ChatManager:unRegisterEvent()
	if g_EventDispatcher then
		g_EventDispatcher:unRegisterAllEventByTarget(self)
	end	
end

--- ------ event ---------------------------------------

function ChatManager:showTopTrumpeTip(data)
    if g_TableLib.isEmpty(data) then return end
	local message = data.message
	local type = data.type
	local temp  = {}
	temp.text = message
--	temp.img = "creator/common/dialog/big_trumpet_bg.png"
    temp.img = -1
    -- g_AlarmTips.getInstance():setText(message):show(type)
    local BroadCastNotify = import("app.common.customUI").BroadcastNotify
	BroadCastNotify.getInstance():setText(temp):show()
end


function ChatManager:getNextIndex()
    self.m_index = self.m_index + 1
    return self.m_index 
end

function ChatManager:onSendTxtMsg(msg)
   
    local index = self:getNextIndex()
    self.m_txtMessages[index] = msg
    g_Schedule:schedulerOnce(function()
        if self.m_txtMessages[index] then
            self.m_txtMessages = {}
            g_AlarmTips.getInstance():setText(GameString.get("str_chat_network_weak")):show()
        end
    end, 3)
end

function ChatManager:onRecieveTxtMsg(data)
    if data.senderUid == g_AccountInfo:getId() then
        for k ,v in pairs(self.m_txtMessages) do
            self.m_txtMessages[k] = nil 
        end
    end
end

function ChatManager:onSendEmotion(msg)
    local index = self:getNextIndex()
    self.m_emotionMessages[index] = msg
    g_Schedule:schedulerOnce(function()
        if self.m_emotionMessages[index] then
            self.m_emotionMessages = {}
            g_AlarmTips.getInstance():setText(GameString.get("str_chat_network_weak")):show()
        end
    end, 3)
end


function ChatManager:onRecieveEmotion(data)

    local playerList = g_RoomInfo:getPlayerList()

    local playerData = playerList[data.seatId]
    if playerData then

        if playerData.uid == g_AccountInfo:getId() then
            for k ,v in pairs(self.m_emotionMessages) do
                self.m_emotionMessages[k] = nil 
             end
         end
    end
end


return ChatManager