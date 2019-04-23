--[[--ldoc desc
@module GiftPop
@author CavanZhou

Date   %s
]]

local TabarView = import("app.common.customUI").TabarView
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local GiftContentView = require(".giftPop.GiftContentView")
local GiftPop = class("GiftPop", PopupBase)
BehaviorExtend(GiftPop)
GiftPop.s_myGift = "mygift"
GiftPop.s_byChip = "bychip"
GiftPop.s_byCoalaa = "bycoalaa"
GiftPop.s_showType = {
    SHOW_GIFT = 0;      -- 正常显示
    SHOW_MY_GIFT = 1;   -- 我的礼物
    SHOW_SEND_GIFT = 2; -- 赠送他人礼物
    SHOW_SEND_GIFT_ROOM = 3;
    SHOW_MY_GIFT_ROOM = 4;
}
-- 配置事件监听函数
GiftPop.s_eventFuncMap = {
	[g_SceneEvent.HIDE_GIFT_DIALOG]	 =  "hidden";
	[g_SceneEvent.GIFT_EVENT_LEFT_TAB_CHANGED]	 =  "onLeftTabChanged";
}

function GiftPop:ctor()
    PopupBase.ctor(self)
    self:bindCtr(require(".giftPop.GiftCtr"))
    self.m_leftSelectedIndex = 1
    self.m_topSelectedIndex = 1 -- 顶部tab
    self.m_topTabNum = 3 -- 应该是可以后台配置的 暂时未找到

    self:init()
end


function GiftPop:onCleanup()
    PopupBase.onCleanup(self)
end

function GiftPop:show(data)
    self:watchData();
    PopupBase.show(self)
    self.m_showType = data and data.type and data.type or GiftPop.s_showType.SHOW_GIFT 
    if self.m_showType==GiftPop.s_showType.SHOW_MY_GIFT then
        self.m_tabarView:setTabarState(self.m_topTabNum)
    elseif self.m_showType==GiftPop.s_showType.SHOW_SEND_GIFT 
        or self.m_showType==GiftPop.s_showType.SHOW_SEND_GIFT_ROOM 
        or self.m_showType==GiftPop.s_showType.SHOW_MY_GIFT_ROOM then
        self.m_tabarView:setTabarState(1)
    end  
    self.m_giftGoldView.m_friendId = data.uid
    self.m_giftGoldView.m_pageType = self.m_showType
end

function GiftPop:hidden()
    self:unwatchData()
    PopupBase.hidden(self)
end

function GiftPop:init()
    -- do something
    -- 加载布局文件
    self:loadLayout("creator/gift/layout/gift.ccreator")
    self.m_bg = g_NodeUtils:seekNodeByName(self, "content")
    self.m_background = g_NodeUtils:seekNodeByName(self.m_bg, "bg")
    self.m_viewTopBg = g_NodeUtils:seekNodeByName(self.m_bg, "bg_top")
    self.m_viewTopTabBg = g_NodeUtils:seekNodeByName(self.m_viewTopBg, "gift_bar_bg")
    self.m_viewCloseBg = g_NodeUtils:seekNodeByName(self.m_bg, "close_bg")
    self.m_close = g_NodeUtils:seekNodeByName(self.m_viewCloseBg, "close")
    self.m_viewBottom = g_NodeUtils:seekNodeByName(self.m_bg, "view_bottom")

    self:createGiftTab()
    self:setBtnClickListener()
    self:initRightContainer({});
    
    g_EventDispatcher:dispatch(g_SceneEvent.GIFT_DIALPG_ON_POPUP_END, 
    {topSelect = self:getSelectedCategory(), leftSelect = self:getSelectedTag(), myGiftSelect = self:getMygiftSelectedTag()});
end

function GiftPop:setBtnClickListener()
    self.m_background:addClickEventListener(
        function(sender)
        end
    )
    self.m_bg:addClickEventListener(
        function(sender)
            self:hidden()
        end
    )
    self.m_close:addClickEventListener(
        function(sender)
            self:hidden()
        end
    )
end

function GiftPop:createGiftTab()
    
    self.m_topStrs = self.m_topTabNum==3 and GameString.get("str_gift_pop_title_3") or GameString.get("str_gift_pop_title_2")
    local param = {
        --bgFile = "creator/gift/imgs/gift_bar_bg.png",
        imageFile = "creator/gift/imgs/gift_bar_button.png",
        tabarSize = {width = 580, height = 70},
        text = {
            name = self.m_topStrs,
            fontSize = 28,
            color = {on = {r = 255, g = 255, b = 255}, off = {r = 215, g = 239, b = 248}},
            bold = false
        },
        index = 1,
        isMove = true,
        tabClickCallbackObj = self,
        tabClickCallbackFunc = self.onTabarClickCallBack
    }
    local tabarView = TabarView:create(param)
    self.m_viewTopTabBg:addChild(tabarView)
    g_NodeUtils:arrangeToCenter(tabarView)
    self.m_tabarView = tabarView
end

function GiftPop:createGiftGoldView()
    self.m_giftGoldView = GiftContentView:create()
    self.m_giftGoldView:setVisible(true)
    self.m_viewBottom:addChild(self.m_giftGoldView)
end

function GiftPop:watchData(index)
    if self.m_watchDataList == nil then
        self.m_watchDataList = {
            {g_ModelCmd.GIFT_LIST_DISPLAYING, self, self.giftListDisplaying, false};
        }
    end
    g_Model:watchDataList(self.m_watchDataList);
end

function GiftPop:unwatchData(index)
    if self.m_watchDataList ~= nil then
        g_Model:unwatchDataList(self.m_watchDataList);
    end
    self.m_watchDataList = nil;
end

--获取左侧所选tab的 tag
function GiftPop:getSelectedTag()
    if self.m_leftSelectedIndex then
        local tab = {[1] = "0", [2] = "1", [3] = "2", [4] = "3", [5] = "4"};
        return tab[self.m_leftSelectedIndex];
    end
    return nil;
end

--获取左侧所选 我的礼物tab的 tag
function GiftPop:getMygiftSelectedTag()

    if self.m_leftSelectedIndex then
        local tab = {[1] = "0", [2] = "1"};
        return tab[self.m_leftSelectedIndex];
    end
    return nil;
end
--获取顶部所选的tabCategory
function GiftPop:getSelectedCategory()
    if self.m_topSelectedIndex then
        if self.m_topTabNum==3 then
            local tab = {[1] = GiftPop.s_byChip, [2] = GiftPop.s_byCoalaa, [3] = GiftPop.s_myGift};
            return tab[self.m_topSelectedIndex];
        else
            local tab = {[1] = GiftPop.s_byChip, [2] = GiftPop.s_myGift};
            return tab[self.m_topSelectedIndex];
        end
    end
    return nil;
end
------------------------------  click event -----------------------------
--
function GiftPop:onLeftTabChanged(index) 
    Log.d("GiftPop.onLeftTabChanged", "index:".. index);
    self.m_leftSelectedIndex = index;
    local data = {selectedCategory = self:getSelectedCategory(), myGiftSelectedTag = self:getMygiftSelectedTag(), selectedTag = self:getSelectedTag()};
    g_EventDispatcher:dispatch(g_SceneEvent.GIFT_CATEGORY_TAG_CHANGE, data);
end

function GiftPop:onTabarClickCallBack(index)
    Log.d("GiftPop.onTopTabChanged", "index:".. index);
    self.m_topSelectedIndex = index;
    self.m_leftSelectedIndex = 1
    local data = {selectedCategory = self:getSelectedCategory(), myGiftSelectedTag = self:getMygiftSelectedTag(), selectedTag = self:getSelectedTag()};
    g_EventDispatcher:dispatch(g_SceneEvent.GIFT_CATEGORY_TAG_CHANGE, data);

end
---- --------------------------------------------- event ---------------------------
--刷新 右侧 list
function GiftPop:initRightContainer(data)
    if not self.m_giftGoldView then
        self:createGiftGoldView()
    end

    local tabData = self:getSelectedCategory()== GiftPop.s_myGift and GameString.get("str_mygift_left_category_item") or GameString.get("str_gift_pop_chip_title")
    self.m_giftGoldView:updateTabListItem(tabData,self.m_leftSelectedIndex)
    self.m_giftGoldView:updateListItem(data)
end
function GiftPop:giftListDisplaying(data)
    if data and type(data) == "string" then
        self:initRightContainer({});
    elseif data then
      
        self:initRightContainer(data);
          if self:getMygiftSelectedTag() == "1" and self:getSelectedCategory() == GiftPop.s_myGift and self.m_scrollView and self.m_btnQuicklySalesGift then
        end
    else
        self:initRightContainer({});
    end
end

return GiftPop
