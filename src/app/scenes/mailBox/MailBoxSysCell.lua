local MailBoxSysCell  = class("MailBoxSysCell",cc.TableViewCell)

MailBoxSysCell.ctor = function(self)   
    self:init()
end

MailBoxSysCell.init = function(self)
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/mailBox/layout/mailbox_sys_item.ccreator')
    self:addChild(self.m_root)
    self.m_txtDate    = g_NodeUtils:seekNodeByName(self.m_root,'txt_date')

    self.m_txtMsg = cc.Label:createWithSystemFont("", 'fonts/arial.ttf', 24, cc.size(590, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    self.m_txtMsg:setColor(cc.c3b(196, 214, 236))
    self.m_txtMsg:setAnchorPoint(cc.p(0, 0))
    self.m_txtMsg:setLineBreakWithoutSpace(false)

    self.m_txtMsgView = ccui.ScrollView:create()
    self.m_txtMsgView:setBounceEnabled(false)
    self.m_txtMsgView:setDirection(ccui.ScrollViewDir.vertical)
    self.m_txtMsgView:setContentSize(cc.size(590, 108))
    self.m_txtMsgView:setScrollBarWidth(0)
    self.m_root:addChild(self.m_txtMsgView)
    g_NodeUtils:arrangeToLeftCenter(self.m_txtMsgView, 85)
    local container = self.m_txtMsgView:getInnerContainer()
    container:addChild(self.m_txtMsg)
    g_NodeUtils:arrangeToLeftCenter(self.m_txtMsg, 0)
end

MailBoxSysCell.updateCell = function(self,data)
    self.m_txtDate:setString(data.m_timeNew)
    
    self.m_txtMsg:setString(data.m_message)
    local textS = self.m_txtMsg:getContentSize()
    if textS.height <= 110 then -- 4行文字高度大致108高度，5行文字高度约135， 所以 108<= height <= 135即可
        self.m_txtMsgView:setSwallowTouches(false)
        self.m_txtMsgView:setInnerContainerSize(cc.size(590, 108)) -- 必须重置，避免循环利用时滚动问题
    else
        self.m_txtMsgView:setSwallowTouches(true)
        self.m_txtMsgView:setInnerContainerSize(cc.size(textS.width, textS.height))
    end
    g_NodeUtils:arrangeToLeftCenter(self.m_txtMsg)-- 调整文字位置

    if not data.m_attaches or g_TableLib.isEmpty(data.m_attaches) then
        -- 纯消息类型默认已读
        g_EventDispatcher:dispatch(g_SceneEvent.MAILBOX_EVENT_GET,self)
    end
    -- if (not self.m_data.m_attaches or g_TableLib.isEmpty(self.m_data.m_attaches)) 
    -- and not self.m_data.m_hasReaded then
    --     --未讀郵件 纯消息类型默认已读
    --     Log.d("MailBoxCtr   未讀郵件 纯消息类型默认已读")
    --     g_EventDispatcher:dispatch(g_SceneEvent.MAILBOX_EVENT_GET,self)
    -- end
end

return MailBoxSysCell