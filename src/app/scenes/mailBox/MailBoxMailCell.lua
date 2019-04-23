local MailBoxMailCell  = class("MailBoxMailCell",cc.TableViewCell)
-- local BehaviorMap = import("app.common.behavior").BehaviorMap;
local NetImageView = import("app.common.customUI").NetImageView

MailBoxMailCell.TYPE_GET = 1;   -- 领取
MailBoxMailCell.TYPE_SIGN = 2;   -- 填写资料
MailBoxMailCell.TYPE_CHECK = 3; -- 查看
MailBoxMailCell.TYPE_PIC = 4; --  显示图片
BehaviorExtend(MailBoxMailCell)
MailBoxMailCell.ctor = function(self)   
    self:init()
    -- self:bindBehavior(BehaviorMap.DownloadBehavior)
end

MailBoxMailCell.init = function(self)
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/mailBox/layout/mailbox_mail_item.ccreator')
    self:addChild(self.m_root)
    self.m_sptIconSmall    = g_NodeUtils:seekNodeByName(self.m_root,'spt_icon_small')
    self.m_sptRedPoint     = g_NodeUtils:seekNodeByName(self.m_root,'spt_red_point')
    self.m_btnGet          = g_NodeUtils:seekNodeByName(self.m_root,'btn_get')
    self.m_labGet          = g_NodeUtils:seekNodeByName(self.m_root,'lab_get')
    -- self.m_sptIcon         = g_NodeUtils:seekNodeByName(self.m_root,'spt_icon')
    self.m_iconContainer         = g_NodeUtils:seekNodeByName(self.m_root,'icon_container')
    self.m_btnGet:addClickEventListener(function(sender)
        self:onBtnGetClick()
    end)
    self.m_iconContainer:setVisible(false)
    self.isLoadIcon = false

    self.m_txtMsg = cc.Label:createWithSystemFont("", 'fonts/arial.ttf', 24, cc.size(540, 0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    self.m_txtMsg:setColor(cc.c3b(196, 214, 236))
    self.m_txtMsg:setAnchorPoint(cc.p(0, 0))
    self.m_txtMsg:setLineBreakWithoutSpace(false)
    self.m_txtMsgView = ccui.ScrollView:create()
    self.m_txtMsgView:setBounceEnabled(false)
    self.m_txtMsgView:setDirection(ccui.ScrollViewDir.vertical)
    self.m_txtMsgView:setContentSize(cc.size(540, 55))
    self.m_txtMsgView:setScrollBarWidth(0)
    self.m_root:addChild(self.m_txtMsgView)
    g_NodeUtils:arrangeToLeftCenter(self.m_txtMsgView, 85)
    local container = self.m_txtMsgView:getInnerContainer()
    container:addChild(self.m_txtMsg)
    g_NodeUtils:arrangeToLeftCenter(self.m_txtMsg, 0)
end

MailBoxMailCell.updateCell = function(self,data)
    self.m_data = data
    
    self.m_txtMsg:setString(data.m_message)
    local textS = self.m_txtMsg:getContentSize()
    -- 两行文字高度大致55高度，三行文字高度约83， 所以 55<= height <= 83即可
    -- 设计要求只显示两行，超出才开滚动
    if textS.height <= 60 then 
        self.m_type = MailBoxMailCell.TYPE_GET
        self.m_txtMsgView:setSwallowTouches(false)
        self.m_txtMsgView:setInnerContainerSize(cc.size(540, 55)) -- 必须重置，避免循环利用时滚动问题
    else
        self.m_type = MailBoxMailCell.TYPE_CHECK
        self.m_txtMsgView:setSwallowTouches(true)
        self.m_txtMsgView:setInnerContainerSize(cc.size(textS.width, textS.height))
    end
    g_NodeUtils:arrangeToLeftCenter(self.m_txtMsg)

    if self.m_data.m_attaches and not g_TableLib.isEmpty(self.m_data.m_attaches) and not self.m_data.m_hasGetAttaches then
        self.m_btnGet:setVisible(true);
        self.m_labGet:setString(GameString.get("str_mail_cell_operate_get"))
        self.m_type = MailBoxMailCell.TYPE_GET
        self.m_btnGet:setVisible(true)
        -- self.m_btnGet:set
        self.m_sptRedPoint:setVisible(true)
        self.m_iconContainer:setVisible(false)
        if self.m_data.m_hasGetAttaches then
            self.m_sptRedPoint:setVisible(false)
            self.m_sptIconSmall:setTexture("creator/mailBox/mail_icon_small.png")
        else
            self.m_sptRedPoint:setVisible(true)
            self.m_sptIconSmall:setTexture("creator/mailBox/mail_icon_small_unget.png")
        end
     else
        if  self.m_type or not self.m_type == MailBoxMailCell.TYPE_CHECK then
            self.m_type = MailBoxMailCell.TYPE_PIC
            self.m_btnGet:setVisible(false)
            self.m_iconContainer:setVisible(true)
        end
        if self.m_data.m_hasReaded then
            self.m_sptRedPoint:setVisible(false)
            self.m_sptIconSmall:setTexture("creator/mailBox/mail_icon_small.png")
        else
            self.m_sptRedPoint:setVisible(true)
            self.m_sptIconSmall:setTexture("creator/mailBox/mail_icon_small_unget.png")
        end
        self.m_iconContainer:setVisible(false)
        if self.m_data and self.m_data.m_giftUrl then
            local url = self.m_data.m_giftUrl
            if not url then
                return
            end
            self.m_iconContainer:setVisible(true)
            
            if not self.m_rewardIcon then
                self.m_rewardIcon = NetImageView:create(url)
                local size = self.m_iconContainer:getContentSize()
                local width = size.width
                local height = size.height
                local x,y = self.m_iconContainer:getPosition()
                self.m_rewardIcon:ignoreContentAdaptWithSize(false) 
                self.m_rewardIcon:setContentSize(cc.size(80,80))
                self.m_rewardIcon:setPosition(cc.p(width/2,height/2))
                self.m_rewardIcon:setAnchorPoint(cc.p(0.5,0.5))
                self.m_iconContainer:addChild(self.m_rewardIcon)
            else
                self.m_rewardIcon:setUrlImage(url)
            end
        end
     end

    if (not self.m_data.m_attaches or g_TableLib.isEmpty(self.m_data.m_attaches)) 
    and not self.m_data.m_hasReaded then
        --未讀郵件 纯消息类型默认已读
        Log.d("MailBoxCtr   未讀郵件 纯消息类型默认已读")
        g_EventDispatcher:dispatch(g_SceneEvent.MAILBOX_EVENT_GET,self)
    end
    -- self.m_type = MailBoxMailCell.TYPE_SIGN
    if self.m_type == MailBoxMailCell.TYPE_GET then
        self.m_labGet:setString(GameString.get("str_mail_cell_operate_get"))
    elseif self.m_type == MailBoxMailCell.TYPE_SIGN then
        self.m_labGet:setString(GameString.get("str_mail_cell_operate_fill"))
    elseif self.m_type == MailBoxMailCell.TYPE_CHECK then
        self.m_labGet:setString(GameString.get("str_mail_cell_operate_read"))
    end
end

-- <#nick##包惟真#><#gift##炮響福到#>
MailBoxMailCell.getMsgUrl = function(self,str)-- <#nick##包惟真#><#gift##炮響福到#>
    local giftData = g_Model:getData(g_ModelCmd.GIFT_ALL_DATA) -- 炮響福到
    if str then
        str = g_StringLib.replace( str,"##","=\"")
        str = g_StringLib.replace( str,"#><#","\",")
        str = g_StringLib.replace( str,"<#","{")
        str = g_StringLib.replace( str,"#>","\"}")
        return str
    end
end

MailBoxMailCell.onBtnGetClick = function(self)
    if self.m_type == MailBoxMailCell.TYPE_GET then  -- 領取獎勵
        g_EventDispatcher:dispatch(g_SceneEvent.MAILBOX_EVENT_GET_ATTACH,self);
    elseif self.m_type == MailBoxMailCell.TYPE_SIGN then -- 填寫資料
        g_PopupManager:show(g_PopupConfig.S_POPID.MAIL_BOX_FILL_INFO_POP)
    elseif self.m_type == MailBoxMailCell.TYPE_CHECK then -- 查看詳情
        -- 内容过多详情
        g_AlertDialog.getInstance()
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
        :setTitle(GameString.get("str_mail_detail_title"))
        :setCloseBtnVisible(false)
        :setContent(self.m_data.m_message):show()
    end
end

return MailBoxMailCell