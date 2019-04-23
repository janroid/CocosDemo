local GiftPopRightTableViewCell  = class("GiftPopRightTableViewCell",cc.Node)
local NetImageView = import("app.common.customUI").NetImageView

GiftPopRightTableViewCell.TYPE_GET = 1;   -- 领取
GiftPopRightTableViewCell.TYPE_SIGN = 2;   -- 填写资料
GiftPopRightTableViewCell.TYPE_CHECK = 3; -- 查看
GiftPopRightTableViewCell.TYPE_PIC = 4; --  显示图片
GiftPopRightTableViewCell.ctor = function(self) 
    self.m_isTouch = false  
    self:init()
    -- self:setTouchEvent()
end

GiftPopRightTableViewCell.init = function(self)

    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/gift/layout/giftItem.ccreator')
    self:addChild(self.m_root)
    local root = g_NodeUtils:seekNodeByName(self.m_root,"root")
    self.m_bg = g_NodeUtils:seekNodeByName(root, "bg")
    self.m_tittle = g_NodeUtils:seekNodeByName(self.m_bg, "tittle")
    self.m_iconHot = g_NodeUtils:seekNodeByName(self.m_bg, "gift_hot")
    self.m_iconNew = g_NodeUtils:seekNodeByName(self.m_bg, "gift_new")
    self.m_imgView = g_NodeUtils:seekNodeByName(self.m_bg, "icon")
    self.m_iconCheck = g_NodeUtils:seekNodeByName(self.m_bg, "gift_icon_check")
    
    -- self.m_touchView = g_NodeUtils:seekNodeByName(self.m_bg, "touchView")
    self.m_bg:setSwallowTouches(false)
    self.m_bg:setTouchEnabled(false)
    self.m_iconCheck:setVisible(false)
end

GiftPopRightTableViewCell.updateCell = function(self,data)
    self:onUpdateListInfo(data)
end

GiftPopRightTableViewCell.setEnabled = function(self,isabled)
    self.m_bg:setOpacity(isabled and 255 or 0)
    self.m_isTouch = isabled
end

function GiftPopRightTableViewCell:onUpdateListInfo(data)
    self.m_data = data
    
    local strDsc = GameString.get("str_gift_gift_past_due")
    if self:getIsOutOfDate(data) >= 0 then
        local price = data.price
        if price then
            price = g_MoneyUtil.adaptiveMoney(price)
        end
        strDsc = price or (data.name=="" and GameString.get("str_gift_gift_buy_by_self") or GameString.get("str_gift_present"))
    end

    local color = data.price and cc.c4b(167,206,255,255) or (data.expire and tonumber(data.expire) < 0 and cc.c4b(183,183,183,255) or cc.c4b(255,255,255,255))
    
    self.m_tittle :setString(strDsc)
    self.m_tittle :setTextColor(color)
    self.m_iconHot:setOpacity(data.itemTag=="2" and 255 or 0)
    self.m_iconNew:setOpacity(data.itemTag=="1" and 255 or 0) 
    if g_AccountInfo:getUserUseGiftId() == data.id then -- id其他页面是字符串 我的礼物页是number
        self.m_iconCheck:setVisible(true)
    else
        self.m_iconCheck:setVisible(false)
    end
    self:addGiftImage(self.m_imgView,data.id)
	self:enableLoadingTouch(true)
end

function GiftPopRightTableViewCell:addGiftImage(imgView,id)
    local pre = g_AccountInfo:getGiftSWFURL()
    local map = g_Model:getData(g_ModelCmd.GIFT_ID_FILE_MAPPING);
    local url = "";
    local name = tostring(id);
    if type(pre) ~= "string" then
        pre = "";
    end
    if map and map[name] then
        url = pre .. map[name] .. ".png";
    else
        url = pre .. tostring(name) .. ".png";
    end
    if imgView and url then
        local urlImg = imgView:getChildren()[1]
        if not urlImg then
            urlImg = NetImageView:create(url,"creator/gift/imgs/gift_default_img.png")
            local size = imgView:getContentSize()
            local width = size.width
            local height = size.height
            local x,y = imgView:getPosition()
            urlImg:setPosition(cc.p(width/2,height/2))
            urlImg:setAnchorPoint(cc.p(0.5,0.5))
            imgView:addChild(urlImg)
        else
            urlImg:setUrlImage(url)
        end
    end 
end

function GiftPopRightTableViewCell:showDetailePop(type,friendId)
    if self.m_isTouch then
        Log.d("showDetailePop", self.m_data,type, friendId )
        if g_Model:getData(g_ModelCmd.TUTORIAL_GIFT_CLICKED) == true then -- 新手教程中赠送礼物
            g_PopupManager:show(g_PopupConfig.S_POPID.TUTORIAL_GIFT_DETAILS_POP,self.m_data,type,friendId) 
        else
            g_PopupManager:show(g_PopupConfig.S_POPID.POP_GIFT_DETAILE,self.m_data,type,friendId) 
        end
    end 
end

function GiftPopRightTableViewCell:enableLoadingTouch(isEnable)
end

function GiftPopRightTableViewCell:getIsOutOfDate(data)

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

GiftPopRightTableViewCell.setTouchEvent=function(self)
    local function onTouchBegan(touch, event)

        self.m_currentLocation = touch:getLocation()
        local pos = self.m_root:convertTouchToNodeSpace(touch)
        local size =self.m_root:getContentSize()
        local rect = cc.rect(0, 0, size.width, size.height);
        if cc.rectContainsPoint(rect,pos) then
            self.m_isTouch = true
            return true
        end
    end
    local function onTouchMoved(touch, event)
    end

    local function onTouchEnd(touch, event)
        local data = self.m_data
        self.m_isTouch = false
    end
    local function onTouchCanceld(touch, event)
        self.m_isTouch = false
    end
    -- begin,moved,ended,cancel, must按順序執行 定義
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnd,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCanceld,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end


return GiftPopRightTableViewCell