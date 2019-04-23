local BaseView = class("BaseView",cc.Node)

--上下边距为5
local upGap = 5
local downGap = 5

local Item = class("Item",cc.Node)
function Item:ctor(title,content)
    self.title = title
    self.content = content
    self.isOpen = false

    self:initView()
end

function Item:setFirst()
    self.closeBg:setPositionY(0)
    local closeBgSize = self.closeBg:getContentSize()
    self.closeSize = cc.size(closeBgSize.width,closeBgSize.height)
end

function Item:initView()
    self.open = display.newNode()
    self.close = display.newNode()
    self.open:addTo(self)
    self.close:addTo(self)
    if not self.isOpen then
        self.open:setVisible(false)
    else
        self.close:setVisible(false)
    end

    --add close
    local closeBg = display.newSprite("creator/help/res/itemClose.png")
    closeBg:align(display.CENTER_BOTTOM,0,upGap + downGap):addTo(self.close)
    local closeBgSize = closeBg:getContentSize()
    self.closeSize = cc.size(closeBgSize.width,closeBgSize.height + upGap + downGap)
    self.closeBg = closeBg

    local iconGap = 40
    display.newSprite("creator/help/res/arrowUp.png"):align(display.CENTER,iconGap,closeBgSize.height / 2):addTo(closeBg)
    local label = GameString.createLabel(self.title,g_DefaultFontName, g_AppManager:getAdaptiveConfig().Help.SubViewFontSize,cc.size(closeBgSize.width * 0.9,0))
    label:align(display.LEFT_CENTER,iconGap + 35,closeBgSize.height / 2):addTo(closeBg)
    label:setTextColor(cc.c4b(0x95,0xdb,0xf0,0xff))

    --add open
    local labelContent = GameString.createLabel(self.content,g_DefaultFontName, g_AppManager:getAdaptiveConfig().Help.SubViewFontSize,cc.size(602 - 20,0))
    local labelContentSize = labelContent:getContentSize()
    local contentBg = display.newSprite("creator/help/res/itemContent.png",{capInsets = cc.rect(0,0,10,10),rect = cc.rect(4,4,2,2)})
    contentBg:setContentSize(cc.size(602,labelContentSize.height + 20))
    contentBg:align(display.CENTER_BOTTOM,0,0):addTo(self.open)
    labelContent:align(display.CENTER,602 / 2,labelContentSize.height / 2 + 10):addTo(contentBg)
    labelContent:setTextColor(cc.c4b(0xad,0xc6,0xe5,0xff))

    local openBg = display.newSprite("creator/help/res/itemOpen.png")
    openBg:align(display.CENTER_BOTTOM,0,labelContentSize.height + 20):addTo(self.open)

    iconGap = 35
    local openBgSize = openBg:getContentSize()
    display.newSprite("creator/help/res/arrowDown.png"):align(display.CENTER,iconGap,openBgSize.height/2):addTo(openBg)
    local label1 = GameString.createLabel(self.title,g_DefaultFontName, g_AppManager:getAdaptiveConfig().Help.SubViewFontSize,cc.size(openBgSize.width * 0.9,0))
    label1:align(display.LEFT_CENTER,iconGap + 30,openBgSize.height / 2):addTo(openBg)
    label1:setTextColor(cc.c4b(0xc4,0xea,0xf6,0xff))

    self.openSize = cc.size(openBgSize.width,labelContentSize.height + 20 + openBgSize.height)
    self.openBgSize = openBgSize
end

function Item:getStatus()
    return self.isOpen
end

function Item:click()
    self.isOpen = not self.isOpen
    if self.isOpen then
        self.open:setVisible(true)
        self.close:setVisible(false)
    else
        self.close:setVisible(true)
        self.open:setVisible(false)
    end
end

function Item:getSizes()
    return self.closeSize ,self.openSize
end

function Item:getRealSize()
    if self.isOpen then
        return self.openSize
    else
        return self.closeSize
    end
end

function Item:getClickSize()
    if self.isOpen then
        return self.openBgSize
    else
        return self.closeSize
    end
end
function BaseView:ctor(...)
    g_EventDispatcher:register(g_SceneEvent.EVENT_CLOSE_DETALE_ITEM,self,self.closeDetailView)
    self:initView(...)
    self:showData()
end

function BaseView:showData()
end

function BaseView:onCleanup()
    if g_EventDispatcher then
        g_EventDispatcher:unRegisterAllEventByTarget(self)
    end
end

function BaseView:dtor()
    if g_EventDispatcher then
        g_EventDispatcher:unRegisterAllEventByTarget(self)
    end
end

function BaseView:closeDetailView()
    if self.openItemIndex ~= nil then
        self:changeItem(self.openItemIndex)
    end
    if self.scrollView then
        if self.__offset and self.__offset < 0 then
            self.scrollView:setContentOffset(cc.p(0,self.__offset),false)
        end
    end
end

function BaseView:initView(size)
    self.items = {}
    self.size = size
    self:createCustomScrollView(size)
end

--内部方法
function BaseView:addItem(itemData)
    local newItem = Item:create(itemData.title,itemData.content)
    
    local lastItemInfo = self.items[#self.items]
    local height = 0
    if lastItemInfo then
        local lastItem = lastItemInfo.node
        local _,lastY = lastItem:getPosition()
        -- height = lastY + lastItem:getRealSize().height + upGap + downGap
        height = lastY + lastItem:getRealSize().height
    else
        newItem:setFirst() --最下面一个
    end
    newItem:align(display.CENTER_BOTTOM,self.size.width / 2,height):addTo(self.scrollViewContainer)
    local newItemSize = newItem:getRealSize()
    local inContainerRect = cc.rect(self.size.width / 2 - newItemSize.width / 2,height,newItemSize.width,newItemSize.height)
    self.items[#self.items + 1] = {node = newItem,inContainerRect = inContainerRect}

    local newHeight = height + newItemSize.height
    if newHeight < self.size.height then
        self.scrollViewContainer:setContentSize(cc.size(self.size.width,newHeight))
        self.scrollView:setViewSize(cc.size(self.size.width,newHeight))
        self.scrollView:setPosition(cc.p(0,(self.size.height - newHeight) / 2))
        self.scrollView:setBounceable(false)
    else
        self.scrollViewContainer:setContentSize(cc.size(self.size.width,newHeight))
        self.scrollView:setViewSize(self.size)
        self.scrollView:setPosition(cc.p(0,0))
        self.scrollView:setBounceable(true)
        self.__offset = self.size.height - newHeight
        if self.__offset < 0 then
            self.scrollView:setContentOffset(cc.p(0,self.__offset),false)
        end
    end
end

function BaseView:createCustomScrollView()
    local scrollViewContainer = display.newNode()
    local scrollView = cc.ScrollView:create(self.size,scrollViewContainer)
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);--方向  横－竖
    scrollView:setIgnoreAnchorPointForPosition(false)
    scrollView:align(display.CENTER,0,0)
    scrollView:addTo(self)
    scrollView:setDelegate()
    self.scrollViewContainer = scrollViewContainer
    self.scrollView = scrollView
    local function onTouchBegan(touch, event)
        local clickInSpritePos = scrollViewContainer:convertTouchToNodeSpace(touch)
        local touchIndex = self:checkHit(clickInSpritePos) 
        if touchIndex then
            self.startIndex = touchIndex
            self.startPos = clickInSpritePos
            return true
        end
        return false
    end
    local function onTouchEnded(touch, event)
        local clickInSpritePos = scrollViewContainer:convertTouchToNodeSpace(touch)
        local touchIndex = self:checkHit(clickInSpritePos) 
        if touchIndex then
            if touchIndex == self.startIndex then
                if math.abs( clickInSpritePos.x - self.startPos.x) + math.abs( clickInSpritePos.y - self.startPos.y ) < 10 then
                    self:changeItem(touchIndex)
                end
            end
        end
        self.startIndex = nil
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    -- 也可以设在scrollView ，但是优先级需要比0（scrollView 也有个默认的监听） 大    listener:setFixedPriority(1)
    scrollViewContainer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,scrollViewContainer)
end

function BaseView:changeItem(index)
    --首先关闭，需要关闭的
    local shouldCloseItemIndexStart = nil
    local shouldCloseHeight = nil
    local shouldCloseItem = nil
    local shouldCloseItemIndex = nil

    local shouldOpenItemIndexStart = nil
    local shouldOpenHeight = nil
    local shouldOpenItem = nil
    local shouldOpenItemIndex = nil

    --模拟往下偏移值,因为一开始设定往上偏移模拟,需要模拟往下偏移值
    local shouldDownOffsetValue = nil

    local itemsNum = #self.items
    local shouldOpen = true
    if self.openItemIndex ~= nil then
        if self.openItemIndex == index then
            shouldOpen = false
        end
        shouldCloseItem = self.items[self.openItemIndex].node
        shouldCloseItemIndex = self.openItemIndex
        local closeSisze,openSize = shouldCloseItem:getSizes()
        shouldCloseHeight = closeSisze.height - openSize.height
        if self.openItemIndex + 1 <= itemsNum then
            shouldCloseItemIndexStart = self.openItemIndex + 1
        end
        self.openItemIndex = nil
    end
    if shouldOpen then
        self.openItemIndex = index
        shouldOpenItem = self.items[index].node
        shouldOpenItemIndex = index
        local closeSisze,openSize = shouldOpenItem:getSizes()
        shouldOpenHeight = openSize.height - closeSisze.height
        if index + 1 <= itemsNum then
            shouldOpenItemIndexStart = index + 1
        end
    end
   
    if shouldCloseItem then
        shouldCloseItem:click()
        local oldRect = self.items[shouldCloseItemIndex].inContainerRect
        oldRect.height = oldRect.height + shouldCloseHeight
        self.items[shouldCloseItemIndex].inContainerRect = oldRect
        shouldDownOffsetValue = shouldCloseHeight
    end
    if shouldOpenItem then
        shouldOpenItem:click()
        local oldRect = self.items[shouldOpenItemIndex].inContainerRect
        oldRect.height = oldRect.height + shouldOpenHeight
        self.items[shouldOpenItemIndex].inContainerRect = oldRect
        if shouldDownOffsetValue ~= nil then
            shouldDownOffsetValue = shouldDownOffsetValue + shouldOpenHeight
        else
            shouldDownOffsetValue = shouldOpenHeight
        end
    end
    local baseIndex = 1
    if shouldCloseItemIndexStart ~= nil then
        if shouldOpenItemIndexStart ~= nil then
            baseIndex = math.min( shouldCloseItemIndexStart,shouldOpenItemIndexStart)
        else
            baseIndex = shouldCloseItemIndexStart
        end
    else
        if shouldOpenItemIndexStart ~= nil then
            baseIndex = shouldOpenItemIndexStart
        end
    end
    
    local heightChange = 0
    if shouldCloseHeight ~= nil then
        heightChange = heightChange + shouldCloseHeight
    end
    if shouldOpenHeight ~= nil then
        heightChange = heightChange + shouldOpenHeight
    end
    
    local oldSize = self.scrollViewContainer:getContentSize()
    self.scrollViewContainer:setContentSize(cc.size(self.size.width,oldSize.height + heightChange))
    local newHeight = oldSize.height + heightChange
    local oldViewHeight = self.scrollView:getViewSize()
    local viewSizeChange = 0
    if newHeight < self.size.height then
        self.scrollViewContainer:setContentSize(cc.size(self.size.width,newHeight))
        viewSizeChange = oldViewHeight.height - newHeight
        self.scrollView:setViewSize(cc.size(self.size.width,newHeight))
        self.scrollView:setPosition(cc.p(0,(self.size.height - newHeight) / 2 ))
        self.scrollView:setBounceable(false)
    else
        viewSizeChange = self.size.height - oldViewHeight.height
        self.scrollViewContainer:setContentSize(cc.size(self.size.width,newHeight))
        self.scrollView:setViewSize(self.size)
        self.scrollView:setPosition(cc.p(0,0))
        self.scrollView:setBounceable(true)
    end
    
    for i = baseIndex,itemsNum do
        local height = 0
        local itemInfo = self.items[baseIndex]
        if shouldCloseItemIndexStart ~= nil and i >= shouldCloseItemIndexStart then
            height = height + shouldCloseHeight
        end
        if shouldOpenItemIndexStart ~= nil and i >= shouldOpenItemIndexStart then
            height = height + shouldOpenHeight--打开不显示边距
        end
        if height ~= 0 then
            local oldY = self.items[i].node:getPositionY()
            self.items[i].node:setPositionY(oldY + height)
            self.items[i].inContainerRect.y = oldY + height
        end
    end

    if  shouldDownOffsetValue ~= nil and shouldDownOffsetValue ~= 0 then
        local oldValue = self.scrollView:getContentOffset()
        oldValue.y = oldValue.y - shouldDownOffsetValue + viewSizeChange
        if oldValue.y > 0 then
            oldValue.y = 0
        end
        self.scrollView:setContentOffset(oldValue,false)
    end
end

function BaseView:checkHit(inContainerPos)
    --遍历所有元素结点
    local clickX,clickY = inContainerPos.x,inContainerPos.y
    for index,itemInfo in ipairs(self.items) do
        local itemRect = clone(itemInfo.inContainerRect)
        local clickSize = itemInfo.node:getClickSize()
        if itemRect.height ~= clickSize.height then
            itemRect.y = itemRect.y + (itemRect.height - clickSize.height)
            itemRect.height = clickSize.height
        end
        --先判断高度
        if clickY >= itemRect.y and clickY <= itemRect.height + itemRect.y then
            if clickX >= itemRect.x and clickX <= itemRect.width + itemRect.x then
                return index
            else
                break
            end
        end
    end
end

return BaseView