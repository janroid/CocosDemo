local StoreSelfPropsListItem = require ".StoreSelfPropsListItem"
local StoreManager = require ".StoreManager"
local StoreConfig = require(".StoreConfig")
local StoreSelfPropsPage = class("StoreSelfPropsPage",cc.Node)
local HttpCmd = import("app.config.config").HttpCmd

function StoreSelfPropsPage:ctor(data,pageType)
    self.m_data = data
    self.m_pageType = pageType
    self:init(data)
    self:registerEvent()
end

function StoreSelfPropsPage:onCleanup()
    self:unRegisterEvent()
end
StoreSelfPropsPage.eventFuncMap =  {
    [g_SceneEvent.SELF_PROPS_SHOW_PROPS_INFO]		 	 	= "onShowPropsInfo";  --展开邀请函详细信息
    [g_SceneEvent.SELF_PROPS_USE_PROPS]		 	 	            = "onUseProps";  --使用道具
    [g_SceneEvent.CLOSE_STORE1]                          = "unRegisterEvent";
    -- [g_SceneEvent.SHOW_STORE]                          = "registerEvent";
};

---注册监听事件
function StoreSelfPropsPage:registerEvent()
    self.eventFuncMap = checktable(self.eventFuncMap);
    for k,v in pairs(self.eventFuncMap) do
    	print(k,v)
        assert(self[v],"配置的回调函数不存在")
        g_EventDispatcher:register(k,self,self[v])
    end
end
---取消事件监听
function StoreSelfPropsPage:unRegisterEvent()
    if self and g_EventDispatcher then
        g_EventDispatcher:unRegisterAllEventByTarget(self)
    end 
end

function StoreSelfPropsPage:init(data)
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
        local itemNode = StoreSelfPropsListItem:create(data[i])
        -- itemNode:setOnBtnArrowClick(function()
        --     self:showOrHideDesc(i)
        -- end)
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
	-- --self.m_PropsListView:scrollToTop(1.0,true)
    self.m_PropsListView:jumpToTop()
end

function StoreSelfPropsPage:updateData(data)
    if not self.m_PropsListView or g_TableLib.isEmpty(data) then  return end
    self.m_data = data
    local container = self.m_PropsListView:getInnerContainer()
    local itemContainer = container:getChildByTag(1)
    local childrens = itemContainer:getChildren()

    for k, child in pairs(childrens) do
        child:updateView(data[k])
    end
end


function StoreSelfPropsPage:getItemCount()
    return #self.m_data
end

function StoreSelfPropsPage:onShowPropsInfo(propsId)
    --展开邀请函详细信息(原来的代码里面没有实现此功能)
end

function StoreSelfPropsPage:onUseProps(propsId)
    --使用道具
    -- g_AlarmTips.getInstance():setText("send"):show()
    StoreManager.getInstance():onUseProps(propsId)
end

return StoreSelfPropsPage