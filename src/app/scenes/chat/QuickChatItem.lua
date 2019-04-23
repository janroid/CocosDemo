
local QuickChatItem  = class("QuickChatItem",ccui.Layout)

QuickChatItem.S_COORD = {
	w = 465,
	h = 64,
	maxH = 90,
	text = {x=20, y=0, w = 0, maxW=380, h=40, maxH=80, align = kAlignLeft,textAlign= kAlignLeft,fontSize = 28,r=0xff,g=0xff,b=0xff};
	line = {x=0, y=0, w=423, h=2,file="creator/chatPop/imgs/message_split.png"};
};

function QuickChatItem:ctor()   
    self:setTouchEnabled(true)
    self:init()
end

function QuickChatItem:init()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/chatPop/quickChatItem.ccreator');
    --self.m_root= g_NodeUtils:seekNodeByName(quick_chat_item,"root");
    --self.m_root:removeFromParent(false);
    self.m_root:setPosition(0,0);
    self.m_root:setAnchorPoint(0,0);
--     self.m_root:setSwallowTouches(false)   
    self:addChild(self.m_root);  
    self.m_commtext   		= g_NodeUtils:seekNodeByName(self.m_root,'label_common_text') ;
    self.m_commtext:setSystemFontSize(g_AppManager:getAdaptiveConfig().RoomChat.QuickChatFontSize or 30)

end

function QuickChatItem:refreshData(data)
    if string.len(data) == 0 then
        return 
    end
    
    self.m_data = data
    self:refreshView()
    
end

function QuickChatItem:refreshView()
    self.m_commtext:setString(self.m_data)
    local x,y  = self.m_commtext:getPosition()
    local size = self.m_commtext:getContentSize()
    local adjustHeight = 64
    if size.height > 40 then -- 大于40说明换行了, 支持两行
        y = (y + size.height) * 0.5 + 3
        adjustHeight = size.height * 0.5 + 50
        size.height = adjustHeight
        self.m_commtext:setContentSize(size)
        self.m_commtext:setPosition(x, y)
    end
    self:setContentSize(cc.size(465, adjustHeight))
end


return QuickChatItem;