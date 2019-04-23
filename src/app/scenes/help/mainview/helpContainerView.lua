
local PopupBase = import("app.common.popup").PopupBase
local HelpContainerView  = class("helpContainerView",PopupBase)
local creatorPath = "creator/help/helpScene.ccreator"
local config = require("config")
local contentViewsSize = cc.size(646,495) --通用样式大小
local contentSize = cc.size(646,495 - 90)

local showAni = true
local titleShowAni = false
local leftViewHeight = 495
local subViewsRector = false --右边元素重新构造

--不支持命名冲突
local function parseChild(tab,node)
    local nodeName = node:getName()
    if nodeName ~= nil then
        if tab[nodeName] ~= nil then
            error("命名重复")
        end
        tab[nodeName] = node
    end
    local children = node:getChildren() -- return array table
    for _,child in ipairs(children) do
        parseChild(tab,child)
    end
end

function HelpContainerView:ctor(...)
    PopupBase.ctor(self);
    self:initData(...)
    self:parseCreator()
    self:initView()
    self:addCloseListener()
end

function HelpContainerView:onEnter()
end

function HelpContainerView:onExit()
end

function HelpContainerView:show( ... )
    PopupBase.show(self)
    local type,closeCallback,index,subIndex = ...
    self.m_index = index or 4
    self.m_subIndex = subIndex or 1
    self:clickLeftItem(self.m_index,true)
    g_EventDispatcher:dispatch(g_SceneEvent.FEEDBACK_ONSHOW)
end

function HelpContainerView:initData(...)
    self.leftChoiceIndex = nil
    self.rightTitleChoiceIndex = nil
    local type,closeCallback,index,subIndex = ...
    self.closeCallback = closeCallback
    self.itemsData = clone(config.getSubViews(type))
    self.m_index = index or 4
    self.m_subIndex = subIndex or 1
    self.customView = {}
end

function HelpContainerView:addCloseListener()
    self.close:addClickEventListener(function(sender) 
        self:closeView()
    end)
end

function HelpContainerView:closeView()
    if self.closeCallback then
        self.closeCallback()
    end
    self:hidden()
end

function HelpContainerView:hidden()
	PopupBase.hidden(self)
    g_EventDispatcher:dispatch(g_SceneEvent.EVENT_CLOSE_DETALE_ITEM)
end

function HelpContainerView:onCleanup()
    PopupBase.onCleanup(self)
    deleteWithChildren(self.subContent) 
    deleteWithChildren(self.subItemBg) 
    
    self.itemsData = nil
    self.customView = nil
end

function HelpContainerView:initView()
    -- self:clickLeftItem(self.m_index,true)
end

function HelpContainerView:parseCreator()
    self:loadLayout(creatorPath)
    self.m_root:addClickEventListener(function()
        self:hidden()
    end)
    self.m_imgTitle = g_NodeUtils:seekNodeByName(self, 'title')
    self.m_imgTitle:setTexture(switchFilePath("help/title.png"))
    parseChild(self,self)
    self:leftSliderView()
    self:addSubItemBgTouchListener()
end

function HelpContainerView:clickLeftItem(idx,closeAni)
    if self.leftChoiceIndex == idx then
        if self.m_subIndex==2 then
            self:clickRightTitle(self.m_subIndex,true)
        end
        return
    end
    g_EventDispatcher:dispatch(g_SceneEvent.EVENT_CLOSE_DETALE_ITEM)
    local lastLeftChoiceIndex = self.leftChoiceIndex
    self.leftChoiceIndex = idx
    self.rightTitleChoiceIndex = nil
    local moveTime = 0
    if showAni and not closeAni then
        moveTime = 0.15
    end
    local containerSize = self.leftContainer:getContentSize()
    self.removeLeftSelected:stopAllActions()
    self.removeLeftSelected:runAction(cc.Sequence:create(
        cc.MoveTo:create(moveTime,cc.p(0,containerSize.height - (idx) * self.leftItemSize.height)),
        cc.CallFunc:create(function() 
            local oldViews = self.customView[lastLeftChoiceIndex]
            if oldViews and #oldViews > 0 then
                for _,oldView in ipairs(oldViews) do
                    if oldView and oldView.customEvent then
                        oldView:customEvent("invisible")
                    end
                end
            end
            local oldViews = self.customView[self.leftChoiceIndex]
            if oldViews and #oldViews > 0 then
                for _,oldView in ipairs(oldViews) do
                    if oldView and oldView.customEvent then
                        oldView:customEvent("visible")
                    end
                end
            end
            self:initRightView(idx)
            if self.m_subIndex==2 then
                self:clickRightTitle(self.m_subIndex,true)
            end
        end))
    )
end

function HelpContainerView:leftSliderView()
    self.leftItemSize = self.removeLeftSelected:getContentSize()
    self.removeLeftSelected:removeFromParent(false)
    self.removeLeftSelected:setAnchorPoint(display.LEFT_BOTTOM)
    local tableSize = cc.size(self.leftItemSize.width,leftViewHeight)
    local function cellSize(tb,idx)
        return self.leftItemSize.width,self.leftItemSize.height
    end
    local function cells()
        return #self.itemsData
    end
    local function moveAction(index,closeAni)

    end
    local function cellAtIndex(tb,idx)
        idx = idx + 1
        local cell = tb:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
        end
        cell:removeAllChildren(true)
        local label = GameString.createLabel(tostring(self.itemsData[idx].key), g_DefaultFontName, g_AppManager:getAdaptiveConfig().Help.TabarFontSize)
        label:align(display.CENTER,self.leftItemSize.width / 2,self.leftItemSize.height / 2):addTo(cell)
        display.newSprite("creator/help/res/leftLine.png"):align(display.CENTER_BOTTOM,self.leftItemSize.width / 2,0):addTo(cell)
        cell.click = function() 
            self:clickLeftItem(idx)
        end
        return cell
    end
    local function touchCell(tb,cell)
        cell:click()
    end
    local tableView = cc.TableView:create(tableSize)
    local container = tableView:getContainer()
    self.leftContainer = container
    self.removeLeftSelected:addTo(container)
    tableView:setBounceable(false)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
    tableView:registerScriptHandler(cellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(cells, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSize, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(touchCell, cc.TABLECELL_TOUCHED)
    tableView:setDelegate()
    tableView:reloadData()
    tableView:align(display.LEFT_BOTTOM,10,527 - leftViewHeight):addTo(self.content)
end

function HelpContainerView:addSubItemBgTouchListener()
    local function onTouchBegan(touch, event)
        if not self:isVisible() then
            return false
        end
        local subContentlen = #self.itemsData[self.leftChoiceIndex].content
        self.subItemBg.clickIndex = nil
        local clickInSpritePos = self.subItemBg:convertTouchToNodeSpace(touch)
        local s = self.subItemBg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect,clickInSpritePos) then
            if clickInSpritePos.x <= 10 then
                self.subItemBg.clickIndex = 1
            elseif clickInSpritePos.x >= rect.width - 10 then
                self.subItemBg.clickIndex = subContentlen
            else
                self.subItemBg.clickIndex = math.floor((clickInSpritePos.x - 10) / (rect.width - 20) * subContentlen) + 1
            end
            return true
        end
        return false
    end
   
    local function onTouchEnded(touch, event)
        local subContentlen = #self.itemsData[self.leftChoiceIndex].content
        local clickInSpritePos = self.subItemBg:convertTouchToNodeSpace(touch)
        local s = self.subItemBg:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        if cc.rectContainsPoint(rect,clickInSpritePos) then
            local endClickIndex = 0
            if clickInSpritePos.x <= 10 then
                endClickIndex = 1
            elseif clickInSpritePos.x >= rect.width - 10 then
                endClickIndex = subContentlen
            else
                endClickIndex = math.floor((clickInSpritePos.x - 10) / (rect.width - 20) * subContentlen) + 1
            end
            if self.subItemBg.clickIndex == endClickIndex then
                self:clickRightTitle(endClickIndex)
            end
        end
        self.subItemBg.clickIndex = nil
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self.subItemBg:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.subItemBg)
end

function HelpContainerView:initRightView(idx)
    local subData = self.itemsData[idx]
    local noTitle = subData.noTitle
    local subContentlen = #subData.content
    local needContentCtor = true
    local needTitleCtor = true
    self.subItemBg:setVisible(false)
    if subViewsRector then
        self.subContent:removeAllChildren(true)
        self.subItemBg:removeAllChildren(true)
    else
        for _,v in ipairs(self.subContent:getChildren()) do
            v:setVisible(false)
        end
        for _,v in ipairs(self.subItemBg:getChildren()) do
            v:setVisible(false)
        end
        local oldContentNode = self.subContent:getChildByName( "type_" .. tostring(idx))
        local oldTitleNode = self.subItemBg:getChildByName( "type_" .. tostring(idx))
        if oldContentNode then
            needContentCtor = false
            self.subContentNode = oldContentNode
            oldContentNode:setVisible(true)
        end
        if oldTitleNode then
            needTitleCtor = false
            self.subItemBgNode = oldTitleNode
            self.subItemBg:setVisible(true)
            oldTitleNode:setVisible(true)
        end
    end

    if needTitleCtor and not noTitle and subContentlen > 0 then
        local subItemBgSize = self.subItemBg:getContentSize()
        self.subItemBg:setVisible(true)
        local node = display.newNode()
        node:setName("type_" .. tostring(idx))
        node:addTo(self.subItemBg)
        self.subItemBgNode = node
        local subSelectMask = display.newSprite("creator/help/res/subItem"  .. tostring(subContentlen) .. ".png")
        node:addChild(subSelectMask)
        subSelectMask:align(display.CENTER,subItemBgSize.width / 2,subItemBgSize.height / 2)
        node.subSelectMask = subSelectMask
        for i,v in ipairs(subData.content) do
            local label = GameString.createLabel(v.title, g_DefaultFontName, g_AppManager:getAdaptiveConfig().Help.SubviewTabarFontSize)
            label:align(display.CENTER,10 + ((2 * i - 1) * 0.5 / subContentlen) * (subItemBgSize.width - 20),subItemBgSize.height / 2):addTo(node)
        end
    end

    if needContentCtor then
        local node = display.newNode()
        node:setName("type_" .. tostring(idx))
        node:addTo(self.subContent)
        self.subContentNode = node

        local stencilNode = cc.DrawNode:create()
        stencilNode:drawSolidRect(cc.p(0,0), cc.p(contentViewsSize.width,contentViewsSize.height), cc.c4f(1,0,0,1))
        local clipper = cc.ClippingNode:create();
        clipper:setStencil(stencilNode)
        clipper:addTo(node)
    
        local contentContainer = display.newNode()
        contentContainer:align(display.LEFT_BOTTOM,0,0):addTo(clipper)
        node.contentContainer = contentContainer
        self.customView[idx] = {}
        for i,v in ipairs(subData.content) do
            local classPath = v.path
            if classPath then
                local contentView = classPath:create(contentSize)
                contentView:setIgnoreAnchorPointForPosition(false)
                contentView:align(display.CENTER,contentViewsSize.width * (i - 0.5),contentViewsSize.height / 2 - 22):addTo(contentContainer)
                if noTitle then
                    contentView:setPositionY(contentView:getPositionY() + 55)
                end
                if contentView.customEvent then
                    contentView:customEvent("create")
                end
                self.customView[idx][i] = contentView
            end
        end
    end
    self:clickRightTitle(self.m_subIndex,true)
end

function HelpContainerView:clickRightTitle(idx,closeAni)
    if self.rightTitleChoiceIndex == idx then
        return
    end
    local lastRightTitleChoiceIndex = self.rightTitleChoiceIndex
    self.rightTitleChoiceIndex = idx
    local moveTime = 0
    if titleShowAni and not closeAni then
        moveTime = 0.15
    end
    local subContentlen = #self.itemsData[self.leftChoiceIndex].content
    if subContentlen <= 0 then
        return
    end
    local subItemBgSize = self.subItemBg:getContentSize()
    if self.subItemBgNode and self.subItemBgNode.subSelectMask then
        self.subItemBgNode.subSelectMask:stopAllActions()
        self.subItemBgNode.subSelectMask:runAction(cc.MoveTo:create(moveTime,cc.p(10 + ((2 * idx - 1) * 0.5 / subContentlen) * (subItemBgSize.width - 20),subItemBgSize.height / 2)))
    end
    self.subContentNode.contentContainer:stopAllActions()
    if lastRightTitleChoiceIndex ~= nil then
        local oldView = self.customView[self.leftChoiceIndex][lastRightTitleChoiceIndex]
        if oldView and oldView.customEvent then
            oldView:customEvent("pause")
        end
    end
    
    self.subContentNode.contentContainer:runAction(cc.Sequence:create(cc.MoveTo:create(moveTime,cc.p(0 - (idx - 1) * contentViewsSize.width,0)),cc.CallFunc:create(function() 
        local oldView = self.customView[self.leftChoiceIndex][self.rightTitleChoiceIndex]
        if oldView and oldView.customEvent then
            oldView:customEvent("resume")
        end
    end)))
    self.m_subIndex =  1
end



return HelpContainerView