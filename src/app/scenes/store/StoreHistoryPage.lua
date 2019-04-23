local StoreHistoryItem = require ".StoreHistoryItem"
local StoreHistoryPage = class("StoreHistoryPage",cc.Node)

function StoreHistoryPage:ctor(data)
    self.m_data = data
    self:init(data)
end

function StoreHistoryPage:init(data)
    self._size = cc.size( 760, 526 )
    if not self.m_HistoryListView then
        self.m_HistoryListView = ccui.ScrollView:create()
        self.m_HistoryListView:setBounceEnabled( true )
        self.m_HistoryListView:setDirection( ccui.ScrollViewDir.vertical )
        self.m_HistoryListView:setContentSize(self._size)
        self.m_HistoryListView:setPositionY(-10)
    end
    local container = self.m_HistoryListView:getInnerContainer()
	--添加 ArrangeNode 更好的操作 scrollview
    local arrangeNode = cc.Node:create()
    arrangeNode:setTag(1)
    container:addChild(arrangeNode)
    arrangeNode:setAnchorPoint(cc.p(0,0))
    local dy = 56
    local len = #data
    for i=1, len do
        local itemNode = StoreHistoryItem:create(data[i])
        itemNode:setTag(i)
        itemNode:setAnchorPoint(cc.p(0,1))
        arrangeNode:addChild(itemNode)
        itemNode:setPositionY(-(i-1)*dy)
	end
	self:addChild(self.m_HistoryListView)
    local s = self.m_HistoryListView:getContentSize()
	local height = len*dy

	if height < s.height then
        height = s.height
        self.m_HistoryListView:setBounceEnabled(false)
	end

	arrangeNode:setPosition(20,height)

    self.m_HistoryListView:setInnerContainerSize(cc.size(s.width,height))
    self.m_HistoryListView:setScrollBarWidth(0)
	-- --self.m_HistoryListView:scrollToTop(1.0,true)
    self.m_HistoryListView:jumpToTop()
end

function StoreHistoryPage:updateData(data)
    self.m_data = data
    local container = self.m_HistoryListView:getInnerContainer()
    local itemContainer = container:getChildByTag(1)
    local childrens = itemContainer:getChildren()

    for k, child in pairs(childrens) do
        child:updateView(data[k])
    end
end

function StoreHistoryPage:getItemCount()
    return #self.m_data
end

return StoreHistoryPage