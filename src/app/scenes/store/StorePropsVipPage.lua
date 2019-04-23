local StorePropVipItem = require ".StorePropVipItem"
local StoreManager = require ".StoreManager"
local StorePropsVipPage = class("StorePropsVipPage",cc.Node)

function StorePropsVipPage:ctor(data,pageType)
    self.m_data = data
    self.m_pageType = pageType
    self:init(data)
end

function StorePropsVipPage:init(data)
    if data == nil or #data == 0 then 
        return
    end
    self._size = cc.size( 760, 526 )
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
    for i=1, len do
        local itemNode = StorePropVipItem:create(data[i])
        itemNode:setOnBtnArrowClick(function()
            self:showOrHideDesc(i)
            if i == len and i > 3 then
                self.m_PropsListView:scrollToBottom(0.2,false)
            end
        end)
        itemNode:setRootParent(self)
        itemNode:setTag(i)
        itemNode:setAnchorPoint(cc.p(0.5,0))
        arrangeNode:addChild(itemNode)
        itemNode:setPositionY(-(i-1)*dy)
	end
	self:addChild(self.m_PropsListView)
    local s = self.m_PropsListView:getContentSize()
	local height = len*dy

	if height < s.height then
        height = s.height
        self.m_PropsListView:setBounceEnabled(false)
	end

	arrangeNode:setPosition(20,height)

    self.m_PropsListView:setInnerContainerSize(cc.size(s.width,height))
    self.m_PropsListView:setScrollBarWidth(0)
    self.m_PropsListView:jumpToTop()
    

end

function StorePropsVipPage:updateData(data)
    if not self.m_PropsListView or g_TableLib.isEmpty(data) then  return end
    self.m_data = data
    local container = self.m_PropsListView:getInnerContainer()
    local itemContainer = container:getChildByTag(1)
    local childrens = itemContainer:getChildren()

    for k, child in pairs(childrens) do
        child:updateView(data[k])
    end
end

function StorePropsVipPage:showOrHideDesc(index)
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
            local m2=cc.MoveTo:create(0.2,cc.p(0,posY+openOffset))-- 上移
            child:runAction(m2)
        end
        if k > index then
            posY = child:getPositionY()
            if clickItemDesStatus then  -- 点击Item的描述内容是否可见
                local m2=cc.MoveTo:create(0.2,cc.p(0,posY+offset))-- 上移
                child:runAction(m2)
            else
                local m2=cc.MoveTo:create(0.2,cc.p(0,posY-offset))
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

function StorePropsVipPage:getItemCount()
    return #self.m_data
end

return StorePropsVipPage