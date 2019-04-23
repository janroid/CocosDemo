--[[--ldoc desc
@module ListItemTextMsg
@author JamesLiang

Date   2018/12/25
]]

local ListItemTextMsg  = class("ListItemTextMsg",cc.Node)

function ListItemTextMsg:ctor(data, width, height)
    self.m_data = data
    self:setContentSize(148, 80)
    self.m_width = 148
    self.m_height = 80
    local size = self:getAnchorPoint()
    -- self:setPosition(-self.m_width/2, -self.m_height/2)
    self:updateView(self.m_data)
    self:setColor(cc.c3b(204, 15, 15))
end

function ListItemTextMsg:updateView(data)
    self:removeAllChildren()
    if self.m_msgLabel then
        self.m_msgLabel:removeFromParent()
        self.m_msgLabel = nil
    end
    if self.m_scrollView then
        self.m_scrollView:removeFromParent()
        self.m_scrollView = nil
    end
    self.m_scrollView = ccui.ScrollView:create()
    self.m_msgLabel = cc.Label:createWithSystemFont(data,   "fonts/arial.ttf", 24,cc.size(140,76),cc.TEXT_ALIGNMENT_CENTER,cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    self.m_msgLabel:setColor(cc.c3b(196, 214, 236))
    self.m_msgLabel:setTag(1)
    -- self.m_msgLabel:setDimensions(140,76)
    self.m_msgLabel:setOverflow(cc.LabelOverflow.RESIZE_HEIGHT)
    self.m_scrollView:setBounceEnabled(true)
    self.m_scrollView:setDirection(ccui.ScrollViewDir.vertical)
    self.m_scrollView:setContentSize(cc.size(140,76))
    self.m_scrollView:setScrollBarWidth(0)
    -- local container = scrollview:getInnerContainer()
    -- self.m_msgLabel:setString(data)
    local labelSize = self.m_msgLabel:getContentSize()
    if labelSize.height <= self.m_height then
        self.m_msgLabel:setAnchorPoint(cc.p(0.5,0.5))

        self.m_msgLabel:setPosition(148/2, 80/2)
        self:addChild(self.m_msgLabel)
    else
        self.m_msgLabel:setAnchorPoint(cc.p(0,0))
        self.m_scrollView:setPosition(4, 2)
        self.m_scrollView:getInnerContainer():addChild(self.m_msgLabel)
        self.m_scrollView:setInnerContainerSize(cc.size(140,labelSize.height))
        local size = self.m_scrollView:getAnchorPoint()
        local size1 = self.m_scrollView:getInnerContainer():getAnchorPoint()
        self:addChild(self.m_scrollView)
        local posx, posy = self.m_msgLabel:getPosition()
        g_NodeUtils:arrangeToLeftCenter(self.m_msgLabel)
        posx, posy = self.m_msgLabel:getPosition()
        print("m_msgLabel", posx, posy)
        self.m_scrollView:jumpToTop()
    end
end

return  ListItemTextMsg