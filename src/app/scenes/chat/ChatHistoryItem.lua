
local ChatHistoryItem  = class("ChatHistoryItem",ccui.Layout)
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
BehaviorExtend(ChatHistoryItem);

local bublleRightPath = "creator/chatPop/imgs/normal_bg_right.png"
local speakerPath = "creator/chatPop/imgs/speaker_bg_left.png"
local speakerRightPath = "creator/chatPop/imgs/speaker_bg_right.png"

local tag = 0

ChatHistoryItem.S_COORD = {
    text = {x1=30,y1=36,x2=-10, y2=36, w=0, offx=0,maxW=340, h=40, maxH=80,fontSize = 20,r=0xff,g=0xff,b=0xff};
    bubble ={x1=60,y1=55,x2=400,y2=55,offx = 0};
    icon = {x1=10,y1=55,x2=410,y2=55,};
    speaker = {x1=20,y1=40,x2=30,y=40};

};

function ChatHistoryItem:ctor()   
    self:init()
end

function ChatHistoryItem:init()
    local chat_history_item = g_NodeUtils:getRootNodeInCreator('creator/chatPop/historyItem.ccreator');
    self.m_root = g_NodeUtils:seekNodeByName(chat_history_item,"root");
    self.m_root:removeFromParent(false)
    --self.m_root:setAnchorPoint(0,0)
    self:addChild(self.m_root)
    self.m_root:setPosition(0,0)
    self:setContentSize( self.m_root:getContentSize())
    -- Log.d("root",self.m_root:getTopInParent())
    

    self.m_imgUserIcon      = g_NodeUtils:seekNodeByName(self.m_root,'user_icon');
    BehaviorExtend(self.m_imgUserIcon)
	self.m_imgUserIcon:bindBehavior(BehaviorMap.HeadIconBehavior);
    self.m_imgBubble        = g_NodeUtils:seekNodeByName(self.m_root,'img_bubble');
    --self.m_layoutContent    = g_NodeUtils:seekNodeByName(self.m_root,'layout_content')
    self.m_labelContent    = g_NodeUtils:seekNodeByName(self.m_root,'label_content')
    self.m_smallSpeaker       = g_NodeUtils:seekNodeByName(self.m_root,'speaker_icon')
    self.m_bigSpeaker       = g_NodeUtils:seekNodeByName(self.m_root,'small_speaker')
    self.m_smallSpeaker:setVisible(false)
    self.m_bigSpeaker:setVisible(false)
    --self.m_size = self:getContentSize()
   -- self.m_txChatContent:setAnchorPoint(0,1)
   --self.m_txChatContent:ignoreContentAdaptWithSize(false)
    
end

function ChatHistoryItem:refreshData(data)    
    if g_TableLib.isEmpty(data) then 
        return 
    end
    self.m_data = data
    self:refreshView()
end


function  ChatHistoryItem:getIncreaseTag()
	tag = tag + 1
	return tag
end

function ChatHistoryItem:refreshContent()
    --self.m_layoutContent:removeAllElements()

    if self.m_data.type == 1 then
        self.m_labelContent:setColor(cc.c3b(255,255,255))
        
    else
        self.m_labelContent:setColor(cc.c3b(0,0,0))
        self.m_smallSpeaker:setVisible(true)
        self.m_imgBubble:setTexture(speakerPath)
        --speaker_bg_left
    end

    self.m_labelContent:setString(self.m_data.message)

    self:updatePos()

end

function ChatHistoryItem:updatePos()

    local x = 16
    local y = 0
    local tss = self.m_smallSpeaker:getContentSize()
    if self.m_smallSpeaker:isVisible() then
        
        x = x + tss.width
    end
    local tbs = self.m_bigSpeaker:getContentSize()
    if self.m_bigSpeaker:isVisible() then
        x = x + tbs.width
        y = tbs.height
    end

    local labelSize =self.m_labelContent:getContentSize()

    if labelSize.width + x > 330 then
        self.m_labelContent:setDimensions(330 - x,labelSize.height)
        self.m_labelContent:setOverflow(cc.LabelOverflow.RESIZE_HEIGHT)
        labelSize =self.m_labelContent:getContentSize()
    end


    local s = labelSize

    s.height = s.height + 20
    s.width = s.width  + x+10

    if s.height < y then
        s.height = y + 20
    end

    self.m_imgBubble:setContentSize(s)
    self.m_labelContent:setPosition(x,s.height /2)
    self.m_smallSpeaker:setPositionY(s.height -5)
    self.m_bigSpeaker:setPositionY(s.height -5)

    local sItemSize = self:getContentSize()

    sItemSize.height = s.height

    self:setContentSize(sItemSize)

    self.m_root:setPositionY(sItemSize.height)
    self:adjustPos()
end


function ChatHistoryItem:adjustPos()
    local userId = g_AccountInfo:getId()
    if userId == self.m_data.senderUid then  

        local s = self.m_root:getContentSize()
        local bubbleSize = self.m_imgBubble:getContentSize()
        self.m_imgBubble:setPositionX(s.width - 50 -bubbleSize.width )


        if self.m_smallSpeaker:isVisible() then
            

            self.m_imgBubble:setTexture(speakerRightPath)
            self.m_labelContent:setPositionX(6)
            local lableSize = self.m_labelContent:getContentSize()
            local speakerSize = self.m_smallSpeaker:getContentSize()
            self.m_smallSpeaker:setPositionX(6+lableSize.width+speakerSize.width/2)
            self.m_smallSpeaker:setScaleX(-1)
        else
            self.m_imgBubble:setTexture(bublleRightPath)
           
        end
        self.m_imgBubble:setCenterRect(cc.rect(5,26,8,14))
        self.m_imgBubble:setContentSize(bubbleSize)
       -- self.m_smallSpeaker:setPositionX(0)

        self.m_imgUserIcon:setPositionX(s.width - 50)
    end
end

function ChatHistoryItem:refreshView()
    self:refreshContent()
    self:upadateIcon()
    --self:setContentSize(cc.size(self.m_cellW,self.m_cellH))
--    self.m_root:setPosition(cc.p(0,0))
--    self:alignToTopLeft(self.m_root)
    --local x,y = self.m_root:getPosition()
    --local size =self:getContentSize()
   --[[ self.m_imgUserIcon:setTexture("creator/userInfo/head/man.jpg")
    self.m_imgUserIcon:setContentSize(cc.size(40,40))
    self:upadateIcon()

    local text = ChatHistoryItem.S_COORD.text
    local bubble = ChatHistoryItem.S_COORD.bubble
    local icon = ChatHistoryItem.S_COORD.icon
    local speaker = ChatHistoryItem.S_COORD.speaker

    local userName = g_AccountInfo:getNickName() 
    local userId = g_AccountInfo:getId()
    self.m_txChatContent:setString(self.m_data.message)   
    local label = cc.Label:createWithSystemFont(self.m_data.message,"",20)
    local labelSize = label:getContentSize()
    local labelLenth = string.len(self.m_data.message)

    if labelSize.width > 330 then
        self.m_txChatContent:setDimensions(text.maxW,labelSize.height)
    else
        self.m_txChatContent:setDimensions((labelSize.width+20),labelSize.height)
    end
    local labelSize = self.m_txChatContent:getContentSize()
    if userId == self.m_data.senderUid then   
        self.m_imgBubble:setAnchorPoint(1,1)
        if self.m_data.type == 1 then
            text.offx =0
            bubble.offx = 0
            self.m_imgBubble:setTexture("creator/chatPop/imgs/normal_bg_right.png")
            self.m_imgBubble:setCenterRect(cc.rect(5,26,8,14))
        else
            text.offx =15
            bubble.offx = 30
            self.m_imgBubble:setTexture("creator/chatPop/imgs/speaker_bg_right.png")
            self.m_imgBubble:setCenterRect(cc.rect(5,26,8,14))
        end
        self.m_imgBubble:setPosition(cc.p(bubble.x2,bubble.y2))
        self.m_imgUserIcon:setPosition(icon.x2,icon.y2)
        self.m_imgBubble:setContentSize(labelSize.width + 50 +bubble.offx,labelSize.height +15)
        g_NodeUtils:arrangeToTopCenter(self.m_txChatContent,text.offx+5,-6)   
    else
        self.m_imgBubble:setAnchorPoint(0,1)
        if self.m_data.type == 1 then
            text.offx =0
            bubble.offx = 0
            self.m_imgBubble:setTexture("creator/chatPop/imgs/normal_bg_left.png")
            self.m_imgBubble:setCenterRect(cc.rect(12,28,13,12))
        else
            text.offx =15
            bubble.offx = 30
            self.m_imgBubble:setTexture("creator/chatPop/imgs/speaker_bg_left.png")
            self.m_imgBubble:setCenterRect(cc.rect(12,28,13,12))
        end
        self.m_imgBubble:setContentSize(labelSize.width + 30 +bubble.offx,labelSize.height +15)
        self.m_imgBubble:setPosition(cc.p(bubble.x1,bubble.y1))
        g_NodeUtils:arrangeToTopCenter(self.m_txChatContent,text.offx+5,-6)    

        
        self.m_imgUserIcon:setPosition(icon.x1,icon.y1)
    end    
    if self.m_data.type == 1 then
        --self.m_imgSpeaker:setVisible(false)
    else
       -- self.m_imgSpeaker:setVisible(true)
       -- self.m_imgSpeaker:setPosition(speaker.x1,speaker.y1+labelLenth)
       -- text.x1 = text.x1 + text.offx
    end

   -- self.m_imgSpeaker:setAnchorPoint(0,1)
   -- g_NodeUtils:arrangeToTopCenter(self.m_imgSpeaker,-(labelSize.width/2),-5)
   ]]
end

function ChatHistoryItem:upadateIcon()
    local clipPath = "creator/rank/rankPlayerInfo/head_bg.png"
	local size = self.m_imgUserIcon:getContentSize()
	self.m_imgUserIcon:setHeadIcon(self.m_data.picture,size.width,size.height, clipPath)
end

function ChatHistoryItem:alignToTopLeft(node)
    local parent = node:getParent()
    local pSize = parent:getContentSize()
    local sSize = node:getContentSize()
    local anr = node:getAnchorPoint()

    node:setPosition(0,pSize.height - sSize.height*(1.0 - anr.y) +(offy or 0) )
    -- node:setPosition(0,0)
end

function ChatHistoryItem:initListener()    
    self.m_root:addTouchEventListener(function(sender, eventType)
        if (eventType == ccui.TouchEventType.began) then
            sender.m_moved = false
        end
        if (eventType == ccui.TouchEventType.moved) then
            sender.m_moved = true
        end
        if (eventType == ccui.TouchEventType.ended) then -- up
            if sender.m_moved then
                return
            else
                self:onCellClick()
            end
        end
    end)
end

function ChatHistoryItem:onCellClick()
    Log.d("data = ",self.m_data)
end

return ChatHistoryItem;