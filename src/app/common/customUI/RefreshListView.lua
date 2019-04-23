
local RefreshListView = class("RefreshListView",ccui.ListView);
                        
RefreshListView.ctor = function(self)
    self.m_isRefreshing = false
    local function touchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            local item = self:getItem(0)
            local innerPos = self:getInnerContainerPosition()
            local innerSize = self:getInnerContainerSize()
            local listViewSize = self:getContentSize()
            local offset = innerSize.height - listViewSize.height + innerPos.y
            if offset <= -70 then
                self.m_isRefreshing = true
                self:setBounceEnabled(false)
                self:stopScroll()
                self:setEnabled(false)
                
                local innerContainer = self:getInnerContainer()
                innerContainer:runAction(cc.MoveTo:create(0.2,cc.p(0,listViewSize.height-innerSize.height-70)))
                self.m_txLoading = cc.Label:createWithSystemFont(GameString.get("str_refresh"),"",24);
                innerContainer:addChild(self.m_txLoading)
                self.m_txLoading:setPosition(cc.p(listViewSize.width/2, innerSize.height + 35))
                self.m_txLoading:setColor(cc.c3b(0,0,0))
                if self.m_callBackFunc then
                    self.m_callBackFunc(self)
                end
            end
        end
    end
    self:addTouchEventListener(touchEvent)
end

RefreshListView.addRefreshEventListener = function (self, func)
    self.m_callBackFunc = func
end

RefreshListView.refreshComplete = function (self)
    local innerContainer = self:getInnerContainer()
    innerContainer:stopAllActions()
    self:setBounceEnabled(true)
    self.m_txLoading:removeFromParent()
    self:setEnabled(true) 
    self:scrollToTop(0.2,true)
    self.m_isRefreshing = false
end

RefreshListView.isRefreshing = function (self)
    return self.m_isRefreshing
end

RefreshListView.dtor = function(self)

end
 

return RefreshListView