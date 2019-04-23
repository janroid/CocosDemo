local StoreTabItem  = class("StoreItem",cc.Node)

function StoreTabItem:ctor()
    self:init()
end

function StoreTabItem:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/store/layout/store_tab.ccreator')
    self:addChild(self.m_root)

    self.m_normalBtn = g_NodeUtils:seekNodeByName(self.m_root,'nomal') 
    self.m_selectImage = g_NodeUtils:seekNodeByName(self.m_root,'select') 
    self.m_tabName = g_NodeUtils:seekNodeByName(self.m_root,'tab_name') 
    self.m_selectImage:setVisible(false)
    self.m_isSelected = false
    self.m_tag = -1
end

function StoreTabItem:setTabName(tabName)
    self.m_tabName:setString(tabName)
end

function StoreTabItem:setTag(tag)
    self.m_tag = tag
end

function StoreTabItem:getTag()
    return self.m_tag
end

function StoreTabItem:addClickEventListener(listener)
    self.m_normalBtn:addClickEventListener(listener)
end

function StoreTabItem:setSelected(isSelect) 
    self.m_isSelected = isSelect
    if self.m_isSelected then
        self.m_selectImage:setVisible(true)
    else
        self.m_selectImage:setVisible(false)
    end
end

function StoreTabItem:isSelected() 
    return self.m_isSelected 
end

function StoreTabItem:initData(data)
    self.m_txtProductName:setString(data)
end

return StoreTabItem