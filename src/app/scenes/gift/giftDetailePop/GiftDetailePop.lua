--[[--ldoc desc
@module GiftDetailePop
@author CavanZhou

Date   %s
]]
local GiftManager = require(".GiftManager");
local NetImageView = import("app.common.customUI").NetImageView
local TabarView = import("app.common.customUI").TabarView
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local GiftDetailePop = class("GiftDetailePop", PopupBase)
BehaviorExtend(GiftDetailePop)

-- 配置事件监听函数
GiftDetailePop.s_eventFuncMap = {
    [g_SceneEvent.HIDE_GIFT_DIALOG]	 =  "hidden";
}

function GiftDetailePop:ctor(data)
    self.m_data = data
    PopupBase.ctor(self)
    self:bindCtr(require(".giftDetailePop.GiftDetailePopCtr"))
    self:init(self.m_data)
    self:setBtnClickListener()
end

function GiftDetailePop:show(data, type,friendId)
    PopupBase.show(self)
    self.m_data = data
    self.m_type = type
    self:updateData(data)
    if type==2 and not data.isOwn then -- 点击好友赠送礼物按钮,房间里面还要单独处理
        self.m_buttonCenterLabel:setString(GameString.get("str_gift_present"))
        
        self.m_buttonCenter:setOpacity(255)
        self.m_buttonBuyForTable:setOpacity(0)
        self.m_buttonBuy:setOpacity(0)
        self.m_buttonCenter:setTouchEnabled(true)
        self.m_buttonBuyForTable:setTouchEnabled(false)
        self.m_buttonBuy:setTouchEnabled(false)
        self.m_buttonCenter:addClickEventListener(function(sender) self:onBtnSendClick()end )
        self.m_data.uid = friendId
    elseif type==1 and not data.isOwn then --SHOW_MY_GIFT 我的禮物進入
            self.m_buttonCenterLabel:setString(GameString.get("str_gift_buy_long"))
            
            self.m_buttonCenter:setOpacity(255)
            self.m_buttonBuyForTable:setOpacity(0)
            self.m_buttonBuy:setOpacity(0)
            self.m_buttonCenter:setTouchEnabled(true)
            self.m_buttonBuyForTable:setTouchEnabled(false)
            self.m_buttonBuy:setTouchEnabled(false)
            self.m_buttonCenter:addClickEventListener(function(sender) self:onBtnBuyClick()end )
            self.m_data.uid = 0
    elseif type==3 and not data.isOwn then --SHOW_SEND_GIFT_ROOM 房间他人禮物進入
            self.m_buttonBuyLabel:setString(GameString.get("str_gift_present"))
            
            self.m_buttonCenter:setOpacity(0)
            self.m_buttonBuyForTable:setOpacity(255)
            self.m_buttonBuy:setOpacity(255)
            self.m_buttonCenter:setTouchEnabled(false)
            self.m_buttonBuyForTable:setTouchEnabled(true)
            self.m_buttonBuy:setTouchEnabled(true)
            
            self.m_buttonBuy:addClickEventListener( function(sender) self:onBtnSendClick() end)
            self.m_buttonBuyForTable:addClickEventListener( function(sender) self:onBtnBuyForTableClick() end)
            self.m_data.uid = friendId
    elseif type==4 and not data.isOwn then --SHOW_MY_GIFT_ROOM 房间个人禮物進入
            self.m_buttonBuyLabel:setString(GameString.get("str_gift_buy_long"))
            
            self.m_buttonCenter:setOpacity(0)
            self.m_buttonBuyForTable:setOpacity(255)
            self.m_buttonBuy:setOpacity(255)
            self.m_buttonCenter:setTouchEnabled(false)
            self.m_buttonBuyForTable:setTouchEnabled(true)
            self.m_buttonBuy:setTouchEnabled(true)
            
            self.m_buttonBuy:addClickEventListener( function(sender) self:onBtnBuyClick() end)
            self.m_buttonBuyForTable:addClickEventListener( function(sender) self:onBtnBuyForTableClick() end)
            self.m_data.uid = friendId
    end
end

function GiftDetailePop:hidden()
    PopupBase.hidden(self)
end

function GiftDetailePop:init(data)
    -- do something

    -- 加载布局文件
    self:loadLayout("creator/gift/layout/giftDetailPop.ccreator")
    self.m_bg = g_NodeUtils:seekNodeByName(self, "content")
    self.m_background = g_NodeUtils:seekNodeByName(self.m_bg, "bg")
    self.m_viewTopBg = g_NodeUtils:seekNodeByName(self.m_bg, "bg_top")
    self.m_viewTopTabBg = g_NodeUtils:seekNodeByName(self.m_viewTopBg, "gift_bar_bg")
    self.m_viewCloseBg = g_NodeUtils:seekNodeByName(self.m_bg, "close_bg")
    self.m_close = g_NodeUtils:seekNodeByName(self.m_viewCloseBg, "close")

    self.m_viewBottom = g_NodeUtils:seekNodeByName(self.m_bg, "view_bottom")
    self.m_buttonCenter = g_NodeUtils:seekNodeByName(self.m_viewBottom, "buttonCenter")
    self.m_buttonBuy = g_NodeUtils:seekNodeByName(self.m_viewBottom, "buttonBuy")
    self.m_buttonBuyForTable = g_NodeUtils:seekNodeByName(self.m_viewBottom, "buttonBuyTable")
    self.m_buttonCenterLabel = g_NodeUtils:seekNodeByName(self.m_buttonCenter, "Label")
    self.m_buttonBuyForTableLabel = g_NodeUtils:seekNodeByName(self.m_buttonBuyForTable, "Label")
    self.m_buttonBuyLabel = g_NodeUtils:seekNodeByName(self.m_buttonBuy, "Label")

    self.m_viewContent = g_NodeUtils:seekNodeByName(self.m_bg, "viewContent")
    self.m_title = g_NodeUtils:seekNodeByName(self.m_bg, "title")
    self.m_imageViewBg = g_NodeUtils:seekNodeByName(self.m_viewContent, "gift_small_pop_bg")
    self.m_giftImgView = g_NodeUtils:seekNodeByName(self.m_imageViewBg, "gift_icon")
    self.m_iconHot = g_NodeUtils:seekNodeByName(self.m_imageViewBg, "gift_hot")
    self.m_iconNew = g_NodeUtils:seekNodeByName(self.m_imageViewBg, "gift_new")
    self.m_iconCheck = g_NodeUtils:seekNodeByName(self.m_imageViewBg, "gift_check")
    self.m_iconCoin = g_NodeUtils:seekNodeByName(self.m_viewContent, "icon_coin")
    self.m_iconChip = g_NodeUtils:seekNodeByName(self.m_viewContent, "icon_chip")
    self.m_labelCost = g_NodeUtils:seekNodeByName(self.m_viewContent, "labelCost")
    self.m_labelType = g_NodeUtils:seekNodeByName(self.m_viewContent, "labelInType")
    self.m_labelTitle = g_NodeUtils:seekNodeByName(self.m_viewContent, "labelInTitle")
    self.m_labelData = g_NodeUtils:seekNodeByName(self.m_viewContent, "labelInData")

    self.m_buttonBuyLabel:setString(GameString.get("str_gift_buy_long")) 
    self.m_buttonBuyForTableLabel:setString(GameString.get("str_gift_buy_for_table")) 
    
    self:updateData(data)
end

function GiftDetailePop:updateData(data)
    -- 禮物名字
    if data.isOwn then -- 赠送的礼物也有名字md
        self:setGiftName(data) 
        self.m_title:setString(GameString.get("str_rank_playerinfo8")) 
    else
        -- self:setGiftName(data) 
        self.m_labelTitle:setString(data.name)
        self.m_title:setString(GameString.get("str_gift_room_purchase")) 
    end

    self.m_iconHot:setOpacity(data.itemTag == "2" and 255 or 0)
    self.m_iconNew:setOpacity(data.itemTag == "1" and 255 or 0)
    self.m_iconCoin:setOpacity(data.type == "2" and 255 or 0)
    self.m_iconChip:setOpacity(data.type == "1" and 255 or 0)
    self.m_iconCheck:setOpacity(0)
    self.m_labelCost:setString(data.price and g_MoneyUtil.adaptiveMoney(data.price) or "")
    local isOutOfDate = self:getIsOutOfDate(data)
    --禮物 有效期
    if isOutOfDate == 0 then --永久
        self.m_labelData:setString(g_StringLib.substitute(GameString.get("str_gift_expired_days"),GameString.get("str_gift_expired_days_forever")))
    elseif isOutOfDate > 0 then --未過期
        if data.isOwn then --剩余有效期
            local days = math.ceil((data.expire - os.time()) / (60 * 60 * 24))
            self.m_labelData:setString(
                g_StringLib.substitute(
                    GameString.get("str_gift_expired_days"),
                    g_StringLib.substitute(GameString.get("str_gift_expired_days_num"), days)
                )
            )
        else
            self.m_labelData:setString(
                g_StringLib.substitute(
                    GameString.get("str_gift_expired_days"),
                    g_StringLib.substitute(GameString.get("str_gift_expired_days_num"), data.expire)
                )
            )
        end
    elseif isOutOfDate < 0 then --過期 self.m_sellPrice
        self.m_labelData:setString(self.m_sellPrice)
    end
    -- 禮物圖片
    self:addGiftImage(self.m_giftImgView, data.id)
    -- 按鈕
    self.m_buttonCenter:setOpacity(data.isOwn and 255 or 0)
    self.m_buttonBuyForTable:setOpacity(data.isOwn and 0 or 255)
    self.m_buttonBuy:setOpacity(data.isOwn and 0 or 255)
    self.m_buttonCenter:setTouchEnabled(data.isOwn)
    self.m_buttonBuyForTable:setTouchEnabled(not data.isOwn)
    self.m_buttonBuy:setTouchEnabled(not data.isOwn)
    -- 是否過期
    self.m_labelType:setOpacity(data.price and 0 or 255)
    self.m_labelType:setString(self:getFromName(data))
    -- 我的禮物 是否使用特殊處理
    if not data.price then --無 為 我的禮物
        if isOutOfDate < 0 then -- 已經過期
            -- self.m_labelType:setString(GameString.get("str_gift_gift_past_due"))
            self.m_buttonCenterLabel:setString(GameString.get("str_gift_sale_overdue_gift"))
            self.m_buttonCenter:addClickEventListener(function(sender) self:onCenterBtnSellClick()end )
        else-- 未過期 
            if g_AccountInfo:getUserUseGiftId() == data.id then -- 是否使用中
                
                self.m_iconCheck:setOpacity(255)
                self.m_buttonCenter:setTouchEnabled(false)
                self.m_buttonCenter:setOpacity(155)
            end
            self.m_buttonCenter:addClickEventListener(function(sender) self:onCenterBtnUseClick() end)
            self.m_buttonCenterLabel:setString(GameString.get("str_gift_use"))
            -- self.m_labelType:setString(data.name == "" and GameString.get("str_gift_gift_buy_by_self") or GameString.get("str_gift_present"))
        end
    end

end

function GiftDetailePop:setGiftName(data)
    
    local array = g_Model:getData(g_ModelCmd.GIFT_ALL_DATA);	
    if data.isOwn then	
    --     --尝试在现有所有礼物列表中查找当前礼物的名称（名称在拉取自己礼物的接口中未返回）
        if array then
            for _, g in ipairs(array) do
                if tostring(g.id) == tostring(data.id) then
                    self.m_labelTitle:setString(g.name)
                    if g["type"] == "1" then
                        self.m_sellPrice = g_StringLib.substitute(GameString.get("str_gift_gift_past_due_price"), math.ceil(g.price*30/100))
                    elseif g["type"] == "2" then
                        local current = tonumber(GameString.get("str_common_currency_multiple"))
                        self.m_sellPrice = g_StringLib.substitute(GameString.get("str_gift_gift_past_due_price"), math.ceil(g.price*30/100*current*2000))
                    end
                    break;
                end
            end
        end
    end
end

function GiftDetailePop:addGiftImage(imgView, id)
    local pre = g_AccountInfo:getGiftSWFURL()
    local map = g_Model:getData(g_ModelCmd.GIFT_ID_FILE_MAPPING)
    local url = ""
    local name = tostring(id)
    if type(pre) ~= "string" then
        pre = ""
    end
    if map and map[name] then
        url = pre .. map[name] .. ".png"
    else
        url = pre .. tostring(name) .. ".png"
    end
    if imgView and url then
        local urlImg = imgView:getChildren()[1]
        if not urlImg then
            urlImg = NetImageView:create(url, "creator/gift/imgs/gift_default_img.png")
            local size = imgView:getContentSize()
            local width = size.width
            local height = size.height
            local x, y = imgView:getPosition()
            urlImg:setPosition(cc.p(width / 2, height / 2))
            urlImg:setAnchorPoint(cc.p(0.5, 0.5))
            imgView:addChild(urlImg)
        else
            urlImg:loadTexture("creator/gift/imgs/gift_default_img.png")
            urlImg:setUrlImage(url)
        end
    end
end

function GiftDetailePop:setBtnClickListener()
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
    self.m_buttonBuy:addClickEventListener(
        function(sender)
            self:onBtnBuyClick()
        end
    )
    self.m_buttonBuyForTable:addClickEventListener(
        function(sender)
            self:onBtnBuyForTableClick()
        end
    )
end

------------------------------  click event -----------------------------
--
function GiftDetailePop:onBtnSendClick(index)
    local SeatManager = import("app.scenes.normalRoom").SeatManager:getInstance()
    local selfSeatId = SeatManager:getSelfSeatId()
    if selfSeatId == -1 and self.m_type==3 then    --如果在房间里，并且没有坐下不能赠送礼物
        g_AlarmTips.getInstance():setText(GameString.get("str_gift_gift_msg_arr")[1]):show()
        self:hidden()
        g_EventDispatcher:dispatch(g_SceneEvent.HIDE_GIFT_DIALOG);
        return;
    end
    GiftManager:getInstance():onBuyGiftForPerson(self.m_data)
end
function GiftDetailePop:onBtnBuyClick(index)
    GiftManager:getInstance():onBuyGiftForSelf(self.m_data)
end
function GiftDetailePop:onBtnBuyForTableClick(index)
    GiftManager:getInstance():onBuyGiftForTable(self.m_data)
end
function GiftDetailePop:onCenterBtnSellClick(index)
    GiftManager:getInstance():onSaleOverdueGift(self.m_data)
end
function GiftDetailePop:onCenterBtnUseClick(index)
    local data = {}
    data.showTips = true
    data.giftId = self.m_data.id
    GiftManager:getInstance():onGiftUse(data) 
end

function GiftDetailePop:getFromName(data)
    if data["type"] == "4" then
        return GameString.get("str_gift_glory_obtain_gift");
    else
        if not data.isOwn then
            if data.expire == 0 then
                return GameString.get("str_gift_gift_past_due");
            elseif data.expire > 0 then
                return GameString.get("str_gift_present");
            end
        else
            if data.expire == 0 then
                return GameString.get("str_gift_gift_past_due");
            elseif data.expire > 0 then
                return GameString.get("str_gift_gift_buy_by_self");
            end
        end
    end
end

function GiftDetailePop:getIsOutOfDate(data)

    if not data.isOwn then
        if data.expire == 0 then
            return 0
        elseif data.expire > 0 then
            return 1
        end
    else
        if data.expire == 0 then
            return -1
        elseif data.expire > 0 then
            return 1
        end
    end
end

function GiftDetailePop:onCleanup()
    PopupBase.onCleanup(self)
end

return GiftDetailePop
