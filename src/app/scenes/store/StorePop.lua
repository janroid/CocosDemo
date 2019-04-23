--[[--ldoc desc
@module StorePop
@author JohnsonZhang

Date   2018-11-7
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local StorePop = class("StorePop",PopupBase);
BehaviorExtend(StorePop);
local StoreChipsPage= require ".StoreChipsPage"
local StorePropsVipPage = require ".StorePropsVipPage"
local StoreSelfPropsPage = require ".StoreSelfPropsPage"
local StoreHistoryPage = require ".StoreHistoryPage"
local StoreTabItem = require ".StoreTabItem"
local StoreManager = require ".StoreManager"
local StoreConfig = require ".StoreConfig"

StorePop.s_TitleBg = "creator/store/left_title_bg.png"
StorePop.s_TitleBg1 = "creator/store/store_left_title_bg1.png"

function StorePop:ctor()
    print('StorePop:ctor()***************')
	PopupBase.ctor(self,true);
	self:bindCtr(require("StoreCtr"));
	self:init();
	self.currentPage = -1
end


StorePop.s_eventFuncMap =  {
    [g_SceneEvent.STORE_EVENT_REFRESH_DATA]		 	 	= "onRefreshData";  
    [g_SceneEvent.STORE_EVENT_SHOW]		 	 	        = "onShow";
    [g_SceneEvent.UPDATE_USER_DATA]                     = "updateUserData";
    [g_SceneEvent.CLOSE_STORE]                          = "hidden";
};

function StorePop:init()
	-- 加载布局文件
	self:loadLayout('creator/store/layout/layout_store.ccreator');
	-- self:add(self.m_root);
	self.m_bg = g_NodeUtils:seekNodeByName(self,'bg') 
    self.m_background = g_NodeUtils:seekNodeByName(self,'background')
    self.m_imgLeftBg = g_NodeUtils:seekNodeByName(self.m_bg,'img_left_bg') 
    self.m_imgRightBg = g_NodeUtils:seekNodeByName(self.m_bg,'img_right_bg') 
    self.m_chipContainer = g_NodeUtils:seekNodeByName(self.m_imgRightBg,'chip_container') 
    self.m_coalaaContainer = g_NodeUtils:seekNodeByName(self.m_imgRightBg,'coalaa_container') 
    self.m_propsContainer = g_NodeUtils:seekNodeByName(self.m_imgRightBg,'props_container') 
    self.m_vipContainer = g_NodeUtils:seekNodeByName(self.m_imgRightBg,'vip_container') 
    self.m_ownPropsContainer = g_NodeUtils:seekNodeByName(self.m_imgRightBg,'user_own_props_container') 
    self.m_buyHistoryContainer = g_NodeUtils:seekNodeByName(self.m_imgRightBg,'user_buy_history_container') 
    self.m_close = g_NodeUtils:seekNodeByName(self.m_bg,'close')
    self.m_txtChip = g_NodeUtils:seekNodeByName(self.m_bg,'txt_chip')
    self.m_imgChipBg = g_NodeUtils:seekNodeByName(self.m_bg,'img_chip_bg')
    self.m_imgChipIcon = g_NodeUtils:seekNodeByName(self.m_bg,'small_chip_icon')
    self.m_leftTabContainer = g_NodeUtils:seekNodeByName(self.m_bg,'left_tab_container')

    self.m_imgTitle = g_NodeUtils:seekNodeByName(self,'store_title')
    self.m_imgTitle:setTexture(switchFilePath("store/store_title.png"))

    self:setBtnClickListener()
    self:adaptiveTxtChipSize(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
    self:createStoreTab()
    self:setPageVisible(-1)
end

function StorePop:setBtnClickListener()
    self.m_bg:addClickEventListener(function(sender) end)
    self.m_background:addClickEventListener(function(sender)
        self:hidden()
    end)
    self.m_close:addClickEventListener(function(sender)
		self:hidden()
    end)
end

function StorePop:createStoreTab()
    local m_disabledItem = nil
    self.tabItemGroup = cc.Layer:create()
    local dy = 76
    
    local tabContainerSize = self.m_leftTabContainer:getContentSize()
    local positionY = tabContainerSize.height/2
    local positionX = tabContainerSize.width/2+5
    for i =1,#StoreConfig.STR_STORE_PRODUCT_CATEGORY_ITEM+1 do
        local index = i
        if i>5 then
            index = i-1
        end
        if i == 5 then
            local accountManageNode = cc.Sprite:create(self.s_TitleBg)
            accountManageNode:setAnchorPoint(cc.p(0.5,1))
            local nodeSize =  accountManageNode:getContentSize()
            positionY = positionY - nodeSize.height
           
            local nodeBg = cc.Sprite:create(self.s_TitleBg1)
            -- nodeBg:setContentSize(cc.size(140,15))
            accountManageNode:addChild(nodeBg)
            nodeBg:setPosition(cc.p(nodeSize.width/2,nodeSize.height/2))

            local item = cc.Label:createWithSystemFont(GameString.get("str_store_account_manage"),nil,22)
            item:setTextColor(cc.c4b(103,168,249,255))
            accountManageNode:addChild(item)
            item:setPosition(cc.p(nodeSize.width/2,nodeSize.height/2))
            accountManageNode:setPosition(cc.p(positionX,positionY+10))
            self.tabItemGroup:addChild(accountManageNode)
        else
            if i ~= 1 then 
                positionY = positionY -dy
            end
            local item = self:createTab()
            local function menuCallback(sender) 
                if self.tabItemGroup then
                    local childrens =  self.tabItemGroup:getChildren()
                    for k, child in pairs(childrens) do
                        if tonumber(child:getTag()) and tonumber(child:getTag())>0 then
                            if child:isSelected() then
                                child:setSelected(false)
                            end
                        end
                    end
                end
                item:setSelected(true)
                self:switchToPage(index)
            end
            
            item:addClickEventListener(menuCallback)
            item:setPosition(cc.p(positionX,positionY))
            item:setTag(index)
            item:setTabName(StoreConfig.STR_STORE_PRODUCT_CATEGORY_ITEM[index])
            self.tabItemGroup:addChild(item)
        end
    end
    local leftBgSize =  self.m_leftTabContainer:getContentSize()
    self.tabItemGroup:setPosition(cc.p(0, leftBgSize.height/2-60))
    self.m_leftTabContainer:addChild(self.tabItemGroup)
end

function StorePop:createTab()
    local node = StoreTabItem:create()
    return node
end

function StorePop:switchToPage(tabIndex)
    StoreManager.getInstance():requestBankruptData()
    print("switchToPage tabIndex = " .. tabIndex .. " self.currentPage = " .. self.currentPage)
    if self.currentPage == tabIndex then return end
    self.currentPage = tabIndex
    if StoreConfig.STORE_POP_UP_CHIPS_PAGE == tabIndex then  --筹码
        self:createChipsPage()
    elseif StoreConfig.STORE_POP_UP_BY_PAGE == tabIndex then-- 金币
        self:createCoinPage()
    elseif StoreConfig.STORE_POP_UP_PROPS_PAGE == tabIndex then -- 道具
        self:createPropsPage()
    elseif StoreConfig.STORE_POP_UP_VIP_PAGE == tabIndex then -- 贵宾卡
        self:createVIPPage()
    elseif  StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE == tabIndex then -- 我的道具
        self:createMyPropsPage()
    elseif StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE == tabIndex then -- 购买记录
        self:createHistoryPage()
    end
    self:setPageVisible(tabIndex)
    if self.tabItemGroup then
        local childrens =  self.tabItemGroup:getChildren()
        for k, child in pairs(childrens) do
            -- print(child:getTag()) 
            if tonumber(child:getTag()) and tonumber(child:getTag())>0 then
                if child:isSelected() then
                    child:setSelected(false)
                end
                if tabIndex == child:getTag() then
                    child:setSelected(true)
                end
            end
        end
    end
end

function StorePop:setPageVisible(index)
    self.m_chipContainer:setVisible(index == StoreConfig.STORE_POP_UP_CHIPS_PAGE)
    self.m_coalaaContainer:setVisible(index == StoreConfig.STORE_POP_UP_BY_PAGE)
    self.m_propsContainer:setVisible(index == StoreConfig.STORE_POP_UP_PROPS_PAGE)
    self.m_vipContainer:setVisible(index == StoreConfig.STORE_POP_UP_VIP_PAGE)
    self.m_ownPropsContainer:setVisible(index == StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE)
    self.m_buyHistoryContainer:setVisible(index == StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE)
end

function StorePop:createChipsPage(needRefresh)
    local data = g_TableLib.copyTab(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_CHIPS_PAGE))
    for k, item in pairs(data) do
        item.m_localPay = "chip"
    end

    if not self.m_storeChipsPage then
        self.m_storeChipsPage = StoreChipsPage:create(data,"chip")
        self.m_chipContainer:addChild(self.m_storeChipsPage)
    else
        local pageItemCount =  self.m_storeChipsPage:getItemCount()
        if pageItemCount ~= #data or needRefresh then  --数据条目有更新
            self.m_storeChipsPage:stopCountDown()
            self.m_chipContainer:removeChild(self.m_storeChipsPage,true)
            self.m_storeChipsPage = nil
            self.m_storeChipsPage = StoreChipsPage:create(data)
            self.m_chipContainer:addChild(self.m_storeChipsPage)
        else
            self.m_storeChipsPage:updateData(data)
        end
    end
    
end

function StorePop:createCoinPage()
    local data = g_TableLib.copyTab(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_BY_PAGE))
    for k, item in pairs(data) do
        item.m_localPay = "coin"
    end

    if not self.m_storeCoalaaPage then
        self.m_storeCoalaaPage = StoreChipsPage:create(data,"coin")
        self.m_coalaaContainer:addChild(self.m_storeCoalaaPage)
    else
        local pageItemCount =  self.m_storeCoalaaPage:getItemCount()
        if pageItemCount ~= #data then  --数据条目数目有更新
            self.m_storeCoalaaPage:stopCountDown()
            self.m_coalaaContainer:removeChild(self.m_storeCoalaaPage,true)
            self.m_storeCoalaaPage = nil
            self.m_storeCoalaaPage = StoreChipsPage:create(data)
            self.m_coalaaContainer:addChild(self.m_storeCoalaaPage)
        else
            self.m_storeCoalaaPage:updateData(data)
        end
    end
end

function StorePop:createPropsPage() 
    local data = g_TableLib.copyTab(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_PROPS_PAGE))

    for k, item in pairs(data) do
        item.m_localPay = "props"
    end
    if not self.m_storePropsPage then
        self.m_storePropsPage = StorePropsVipPage:create(data,"props")
        self.m_propsContainer:addChild(self.m_storePropsPage)
    else
        local pageItemCount =  self.m_storePropsPage:getItemCount()
        if pageItemCount ~= #data then  --数据条目数目有更新
            self.m_propsContainer:removeChild(self.m_storePropsPage,true)
            self.m_storePropsPage = nil
            self.m_storePropsPage = StorePropsVipPage:create(data)
            self.m_propsContainer:addChild(self.m_storePropsPage)
        else
            self.m_storePropsPage:updateData(data)
        end
    end
    
end

function StorePop:createVIPPage()
    local data =  g_TableLib.copyTab(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_VIP_PAGE))

    for k, item in pairs(data) do
        item.m_localPay = "vip"
    end
    if not self.m_storeVipPage then
        self.m_storeVipPage = StorePropsVipPage:create(data,"vip")
        self.m_vipContainer:addChild(self.m_storeVipPage)
    else
        local pageItemCount =  self.m_storeVipPage:getItemCount()
        if pageItemCount ~= #data then  --数据条目数目有更新
            self.m_vipContainer:removeChild(self.m_storeVipPage,true)
            self.m_storeVipPage = nil
            self.m_storeVipPage = StorePropsVipPage:create(data)
            self.m_vipContainer:addChild(self.m_storeVipPage)
        else
            self.m_storeVipPage:updateData(data)
        end
    end
end

function StorePop:createMyPropsPage()
    local data =  g_TableLib.copyTab1(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE))
    if g_TableLib.isEmpty(data) or data == nil then
        if not self.myPropsNilTip then
            self.myPropsNilTip = cc.Label:createWithSystemFont(GameString.get("str_store_no_props"),nil,36)
            self.m_ownPropsContainer:addChild(self.myPropsNilTip)
            self.myPropsNilTip:setPosition(cc.p(self.m_ownPropsContainer:getContentSize().width/2,self.m_ownPropsContainer:getContentSize().height/2))
            self.myPropsNilTip:setVisible(true)
        else
            self.myPropsNilTip:setVisible(true)
        end
        if self.m_storeSelfPropsPage then
            g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_STORE1)
            self.m_ownPropsContainer:removeChild(self.m_storeSelfPropsPage,true)
            self.m_storeSelfPropsPage = nil
        end
        return
    end

    if self.myPropsNilTip then
        self.myPropsNilTip:setVisible(false)
    end

    for k, item in pairs(data) do
        item.m_localPay = "props_own"
    end
    
    if not self.m_storeSelfPropsPage then
        self.m_storeSelfPropsPage = StoreSelfPropsPage:create(data,"props_own")
        self.m_ownPropsContainer:addChild(self.m_storeSelfPropsPage)
    else
        local pageItemCount =  self.m_storeSelfPropsPage:getItemCount()
        if pageItemCount ~= #data then  --数据条目数目有更新
            g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_STORE1);  
            -- self.m_storeSelfPropsPage:onCleanup()
            self.m_ownPropsContainer:removeChild(self.m_storeSelfPropsPage,true)
            self.m_storeSelfPropsPage = nil
            self.m_storeSelfPropsPage = StoreSelfPropsPage:create(data)
            self.m_ownPropsContainer:addChild(self.m_storeSelfPropsPage)
        else
            self.m_storeSelfPropsPage:updateData(data)
        end
    end
end

function StorePop:createHistoryPage()
    local data = g_TableLib.copyTab(StoreManager.getInstance():getPageData(StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE))
    if not self.m_histroyPage then
        self.m_histroyPage = StoreHistoryPage:create(data)
        self.m_buyHistoryContainer:addChild(self.m_histroyPage)
    else
        local pageItemCount =  self.m_histroyPage:getItemCount()
        if pageItemCount ~= #data then  --数据条目数目有更新
            self.m_buyHistoryContainer:removeChild(self.m_histroyPage,true)
            self.m_histroyPage = nil
            self.m_histroyPage = StoreHistoryPage:create(data)
            self.m_buyHistoryContainer:addChild(self.m_histroyPage)
        else
            self.m_histroyPage:updateData(data)
        end
    end
   
end

function StorePop:adaptiveTxtChipSize(money)  
    self.m_txtChip:setString(money);                              
    local txtSize = self.m_txtChip:getContentSize();
    local iconSize = self.m_imgChipIcon:getContentSize();
    local chipBgSize = self.m_imgChipBg:getContentSize();
    self.m_imgChipBg:setContentSize(cc.size(txtSize.width+40,chipBgSize.height));
end

---刷新界面
function StorePop:updateView(data)
	data = checktable(data);
end

function StorePop:exit()
    self:removeFromParent()
    -- cc.Director:getInstance():popScene()
end

-- 数据更新，刷新当前所在界面的数据
function StorePop:onRefreshData(data)
    local index = data.index
    local needRefresh = data.needRefresh
    if index == StoreConfig.STORE_POP_UP_CHIPS_PAGE then
        self:createChipsPage(needRefresh)
    elseif index == StoreConfig.STORE_POP_UP_BY_PAGE then
        self:createCoinPage(needRefresh)
    elseif index == StoreConfig.STORE_POP_UP_PROPS_PAGE then
        self:createPropsPage(needRefresh)
    elseif index == StoreConfig.STORE_POP_UP_VIP_PAGE then
        self:createVIPPage(needRefresh)
    elseif index == StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE then
        self:createMyPropsPage(needRefresh)
    elseif index == StoreConfig.STORE_POP_UP_BUY_HISTORY_PAGE then
        self:createHistoryPage(needRefresh)
    else -- 破产倒计时结束需要重新布局   只有筹码有破产优惠
        self:createChipsPage(needRefresh)
        -- self:createCoinPage(needRefresh)
    end
    
end

-- 更新用户数据
function StorePop:updateUserData()
    -- body
    self:adaptiveTxtChipSize(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
end

-- 数据更新，刷新所在界面的数据
function StorePop:onShow(index)
    self:switchToPage(index)
end

function StorePop:show(index)
    StoreManager.getInstance():requestMyStoreData()
    index = index or StoreConfig.STORE_POP_UP_CHIPS_PAGE
	print("StorePop:show  index" .. index)
	PopupBase.show(self);
    self:switchToPage(index)
    g_EventDispatcher:dispatch(g_SceneEvent.STORE_REQ_USER_MONEY)
end

function StorePop:hidden()
    PopupBase.hidden(self)
    -- g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_STORE1);  
    if self.m_storeChipsPage then
        self.m_storeChipsPage:stopCountDown()
    end
    if self.m_storeCoalaaPage then
        self.m_storeCoalaaPage:stopCountDown()
    end
end



function StorePop:onCleanup()
    g_EventDispatcher:dispatch(g_SceneEvent.CLOSE_STORE1);  
    PopupBase.onCleanup(self)
    if self.m_storeChipsPage then
        self.m_storeChipsPage:stopCountDown()
    end
    if self.m_storeCoalaaPage then
        self.m_storeCoalaaPage:stopCountDown()
    end
end
function StorePop:onEnter()
    PopupBase.onEnter(self)
 
end



---刷新界面
function StorePop:updateView(data)
	data = checktable(data);
end

return StorePop;