local StoreChipsItem = require ".StoreChipsItem"
local StoreManager = require ".StoreManager"
local StoreChipsPage = class("StoreChipsPage",cc.Node)

function StoreChipsPage:ctor(data,pageType)
    self.m_data = data
    self.m_pageType = pageType
    self.m_discountItem = {}
    self:init(data)
end

function  StoreChipsPage:onCleanup()
    print("StoreChipsPage:cleanup -------------------")
    self:stopCountDown()
end

function StoreChipsPage:init(data)
    if data==nil then
        return 
    end
    self._size = cc.size(760, 526 )
    if not self.m_PropsListView then
        self.m_PropsListView = ccui.ScrollView:create()
        self.m_PropsListView:setBounceEnabled( true )
        self.m_PropsListView:setDirection( ccui.ScrollViewDir.vertical )
        self.m_PropsListView:setContentSize(self._size)
        self.m_PropsListView:setPositionY(-10)
    end
    local container = self.m_PropsListView:getInnerContainer()
	--添加 ArrangeNode 更好的操作 scrollview
    local arrangeNode = cc.Node:create()
    arrangeNode:setTag(1)
    container:addChild(arrangeNode)
    arrangeNode:setAnchorPoint(cc.p(0,0))
    local dy = 120
    local len = #data
    local count = 0 
    for i=1, len do
        local itemNode = StoreChipsItem:create(data[i])
        local hasDiscount = itemNode:hasDiscount()
        local discountTime = itemNode:getRemainTime()
        if hasDiscount then
            count = count + 1
            itemNode:setPositionY(-(i-1)*dy-30)
        end
        if hasDiscount and discountTime>0 then
            table.insert(self.m_discountItem,itemNode)
        end
        itemNode:setRootParent(self)
        itemNode:setTag(i)
        itemNode:setAnchorPoint(cc.p(0.5,0))
        arrangeNode:addChild(itemNode)
        itemNode:setPositionY(-(i-1)*dy-30*count)
        -- itemNode:setLocalZOrder()
	end
	self:addChild(self.m_PropsListView)
    local s = self.m_PropsListView:getContentSize()
	local height = len*dy+count*30

	if height < s.height then
        height = s.height
        self.m_PropsListView:setBounceEnabled(false)
	end

	arrangeNode:setPosition(20,height)

    self.m_PropsListView:setInnerContainerSize(cc.size(s.width,height))
    self.m_PropsListView:setScrollBarWidth(0)
	-- --self.m_PropsListView:scrollToTop(1.0,true)
    self.m_PropsListView:jumpToTop()
    self:stopCountDown()
    if #self.m_discountItem > 0 then
        self:beginCountDown()
    end
end

function StoreChipsPage:stopCountDown()
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil;
    end
end

function StoreChipsPage:beginCountDown()
    
    local scheduler  = cc.Director:getInstance():getScheduler()
    self.schedulerID = scheduler:scheduleScriptFunc(function()
        if self.schedulerID == nil then return end 
        for k, child in pairs(self.m_discountItem) do
            if child.getRemainTime and child:getRemainTime() >0 then
                child:updateTime()
            else
                if self.schedulerID == nil then return end
                if self.stopCountDown then self:stopCountDown() end
                if self.m_pageType == "chip" then
                    StoreManager.getInstance():requestStoreData(StoreConfig.STORE_POP_UP_CHIPS_PAGE,true)
                elseif self.m_pageType == "coin" then
                    StoreManager.getInstance():requestStoreData(StoreConfig.STORE_POP_UP_BY_PAGE,true)
                else
                    StoreManager.getInstance():requestStoreData(-1,true)
                end
            end
        end
    end,1.0,false)
end

function StoreChipsPage:updateData(data)
    self.m_data = data
    local container = self.m_PropsListView:getInnerContainer()
    local itemContainer = container:getChildByTag(1)
    local childrens = itemContainer:getChildren()

    for k, child in pairs(childrens) do
        child:updateView(data[k])
    end
end

function StoreChipsPage:showOrHideDesc(index)
    -- self.m_PropsListView:getChildren()
    local container = self.m_PropsListView:getInnerContainer()
    local itemContainer = container:getChildByTag(1)
    local childrens = itemContainer:getChildren()
    local clickItem = itemContainer:getChildByTag(index)
    local offset = clickItem:getDesHeight()   -- 点击item描述的高度
    local clickItemDesStatus =  clickItem:isShowDes()
    local openIndex = -1   -- 已打开的item
    local openOffset = 0   -- 已经打开的Item描述的高度

    for k, child in pairs(childrens) do
        local isShowDes = child:isShowDes()
        if isShowDes then
            openIndex = child:getTag()
            openOffset = child:getDesHeight()
        end
    end
    for k, child in pairs(childrens) do
        local posY = child:getPositionY()
        if k == index then 
            child:changeArrow()
        else
            local isShowDes = child:isShowDes()
            if isShowDes then
                child:hideDescription()
            end
        end
        if k > openIndex and index ~= openIndex then
            local m2=cc.MoveTo:create(0.3,cc.p(0,posY+openOffset))-- 上移
            child:runAction(m2)
        end
        if k > index then
            posY = child:getPositionY()
            if clickItemDesStatus then  -- 点击Item的描述内容是否可见
                local m2=cc.MoveTo:create(0.3,cc.p(0,posY+offset))-- 上移
                child:runAction(m2)
            else
                local m2=cc.MoveTo:create(0.3,cc.p(0,posY-offset))
                child:runAction(m2)
            end
        end
    end
    local s = container:getContentSize()
    local itemContainerY = itemContainer:getPositionY()
    local totalOffset = offset - openOffset
    if index == openIndex then
        totalOffset = offset
    end
    if not clickItemDesStatus then
        itemContainer:setPositionY(itemContainerY+totalOffset)
        self.m_PropsListView:setInnerContainerSize(cc.size(s.width,s.height+totalOffset))
    else
        itemContainer:setPositionY(itemContainerY-totalOffset)
        self.m_PropsListView:setInnerContainerSize(cc.size(s.width,s.height-totalOffset))
    end
    
end

function StoreChipsPage:getItemCount()
    return #self.m_data
end

return StoreChipsPage