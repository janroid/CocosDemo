local StoreManager = require ".StoreManager"
local StoreDiscountImg = require ".StoreDiscountImg"
local StoreChipsItem  = class("StoreChipsItem",cc.Node)

function StoreChipsItem:ctor(data)
    self:init()
    self.m_data = data
    self:updateView(data)
end

function StoreChipsItem:init()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/store/layout/layout_store_chips_coalaa_list_item.ccreator')
    self:addChild(self.m_root)
    self.m_btnLightBg = g_NodeUtils:seekNodeByName(self.m_root,'btn_light_bg')
    self.m_btnLightBg:setSwallowTouches(false)
    -- self.m_btnLightBg:setTouchEnable(false)
    self.m_txtProPriceDesc = g_NodeUtils:seekNodeByName(self.m_btnLightBg,'txt_pro_price_desc') -- 商品价格描述
    self.m_txtProDesc = g_NodeUtils:seekNodeByName(self.m_btnLightBg,'txt_pro_desc')    -- 商品名称
    self.m_imgProduct= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'img_product')  -- 商品图片
    self.m_btnBuy= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'btn_buy')  -- 购买按钮
    self.m_txtProPrice= g_NodeUtils:seekNodeByName(self.m_btnBuy,'txt_product_price')  -- 购买按钮商品价格
    self.m_imgNew= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'img_new')  -- 新品标签
    self.m_imgHot= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'img_hot')  -- 热销标签
    self.m_cashTimeContainer= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'cash_time_container')  -- 折扣倒计时容器
    self.m_imgTimeBg= g_NodeUtils:seekNodeByName(self.m_cashTimeContainer,'img_time_bg')  -- 折扣倒计时背景
    self.m_txtCashTimer= g_NodeUtils:seekNodeByName(self.m_cashTimeContainer,'txt_cash_timer')  -- 折扣倒计时
    self.m_imgIcon= g_NodeUtils:seekNodeByName(self.m_cashTimeContainer,'img_icon')  -- 折扣倒计时图片
    self.m_imgDiscountIcon= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'img_discount_icon')  -- 折扣标签
    self.m_txtProPriceBack= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'txt_pro_price_back')  -- ?
    self.m_txtProDiscountDesc= g_NodeUtils:seekNodeByName(self.m_btnLightBg,'txt_pro_discount_desc')  -- 折扣描述
    self.m_txtProPriceBack:setVisible(false)
    self.m_cashTimeContainer:setVisible(false)
    self.m_imgDiscountIcon:setVisible(false)
    self.m_txtProDiscountDesc:setVisible(false)
    self.m_imgNew:setVisible(false)
    self.m_imgHot:setVisible(false)
    self.m_hasDiscount = false
    self:setBtnClickListener()
end

function StoreChipsItem:setIsHasDiscount(hasDiscount)
    self.m_imgDiscountIcon:setVisible(hasDiscount)
    self.m_txtProDiscountDesc:setVisible(hasDiscount)
    self.m_txtCashTimer:setVisible(hasDiscount)
    self.m_hasDiscount = hasDiscount
    if self.m_remainTime > 0 then
        self.m_cashTimeContainer:setVisible(true)
    else
        self.m_cashTimeContainer:setVisible(false)
    end
end

function StoreChipsItem:setBtnClickListener()
    local function btnBuyClickListener(sender)
        Log.d("StoreChipsItem:onBuyClick ",self.m_data)
        local start_pos = sender:getTouchBeganPosition()
        local end_pos = sender:getTouchEndPosition()
        if math.abs(start_pos.y - end_pos.y) > 20 then return end
        StoreManager.getInstance():requestCreateOrder(self.m_data)
    end
    self.m_btnLightBg:addClickEventListener(btnBuyClickListener)
    self.m_btnBuy:addClickEventListener(function()
        StoreManager.getInstance():requestCreateOrder(self.m_data)
    end)
end

function StoreChipsItem:setRootParent(rootParent)
    self.rootParent = rootParent
end

function StoreChipsItem:updateView(data)
    local bankrupctData = StoreManager.getInstance():getBankruptData()
    local detail = {}
    local expire = 0
    local discount = 0
    self.m_expireTime = -1
    if not g_TableLib.isEmpty(bankrupctData) then
        local info  =  bankrupctData.info 
        detail = info.detail or {}   -- 折扣商品id集合
        expire = info.expire   -- 剩餘時間
        if tonumber(expire) and tonumber(expire) > 0 then
            for k,v in pairs(detail) do
                if data.m_id == k then
                    discount = v
                    self.m_expireTime = expire
                end
            end
        end
    end
    
    
    if(data.m_img~="") then
        if(tonumber(data.m_img) > 107 and data.m_localPay == "chip") then
            self.m_imgProduct :setTexture("creator/store/Chip-107.png");
        elseif(tonumber(data.m_img) > 113 and data.m_localPay == "coin") then
            self.m_imgProduct :setTexture("creator/store/KaraCoin-113.png");
        else
            local preStr = data.m_localPay == "chip" and "Chip-" or "KaraCoin-"
            self.m_imgProduct :setTexture("creator/store/"..preStr..data.m_img..".png");
        end
    else
        if(tonumber(data.m_id) > 107 and data.m_localPay == "chip") then
            self.m_imgProduct :setTexture("creator/store/Chip-107.png");
        elseif(tonumber(data.m_id) > 113 and data.m_localPay == "coin") then
            self.m_imgProduct :setTexture("creator/store/KaraCoin-113.png");
        else
            local preStr = data.m_localPay == "chip" and "Chip-" or "KaraCoin-"
            self.m_imgProduct :setTexture("creator/store/"..preStr..data.m_id..".png");
        end
    end

    if data.m_priceFormatter then
        self.m_txtProPrice:setString(data.m_priceFormatter(data.m_price))
    else
        self.m_txtProPrice:setString(data.m_price)
    end

    -- self.m_imgProduct:set
    
    if(data.m_localPayDis~= nil and data.m_localPayDis ~= -1) then
        if discount < data.m_localPayDis then
            discount = data.m_localPayDis;
            self.m_expireTime = -1
        end
    end
    
    local discount1 = StoreManager.getInstance():getItemDiscount(self.m_data.m_localPay)
    
    if discount < discount1 then
        discount = discount1
        self.m_expireTime = -1
    end

    -- self.m_expireTime = data.m_expire or -1
    self.m_remainTime = self.m_expireTime
    local timeStr = g_TimeLib.seconds2hhmmss(self.m_remainTime) or ""
    self.m_txtCashTimer:setString(timeStr)

    if tonumber(discount) > 0 then
        if self.dicountImg ~=nil then
            self.dicountImg:setNum("+".. discount .. "%")
        else
            self.dicountImg = StoreDiscountImg:create("+".. discount .. "%")
            local discountSize = self.m_imgDiscountIcon:getContentSize()
            self.dicountImg:setPosition(cc.p(discountSize.width/2-30,discountSize.height/2))
            self.m_imgDiscountIcon:addChild(self.dicountImg)
        end
        self:setIsHasDiscount(true)
    elseif discount <0 then
        if self.dicountImg ~=nil then
            self.dicountImg:setNum("+".. discount .. "%")
        else
            self.dicountImg = StoreDiscountImg:create("+".. discount .. "%")
            local discountSize = self.m_imgDiscountIcon:getContentSize()
            self.dicountImg:setPosition(cc.p(discountSize.width/2-30,discountSize.height/2))
            self.m_imgDiscountIcon:addChild(self.dicountImg)
        end
        self:setIsHasDiscount(true)
    else
        self:setIsHasDiscount(false)   
    end

    local formatStr = ""
    if (data.m_localPay == "chip") then
        formatStr = GameString.get("str_store_chips_text")
    else
        formatStr = GameString.get("str_store_coalaa_text")
    end
    if discount < 0 then
        self.m_imgDiscountIcon:setVisible(true);
        self.m_txtProDiscountDesc:setVisible(true) 
        local str = math.floor(g_MoneyUtil.formatMoney(tonumber((data.m_num) * (1 - discount / 100))))
        self.m_txtProDesc:setString(string.format(formatStr,str)); 
        self.m_txtProDiscountDesc:setString(string.format(formatStr,g_MoneyUtil.formatMoney(tonumber(data.m_num)))); 
    elseif discount > 0 then
        self.m_imgDiscountIcon:setVisible(true);
        self.m_txtProDiscountDesc:setVisible(true)
        self.m_txtProDesc:setString(string.format(formatStr,g_MoneyUtil.formatMoney(math.floor(tonumber((data.m_num) * (1 + discount / 100))))));
        self.m_txtProDiscountDesc:setString(string.format(formatStr,g_MoneyUtil.formatMoney(tonumber(data.m_num))));
    else
        self.m_imgDiscountIcon:setVisible(false);
        self.m_txtProDesc:setString(string.format(formatStr, g_MoneyUtil.formatMoney(tonumber(data.m_num),nil,3)));
    end

    self:setProPriceDesc(data,discount);

end

function StoreChipsItem:updateTime()
    local timeStr = g_TimeLib.seconds2hhmmss(self.m_remainTime)
    self.m_remainTime = self.m_remainTime - 1
    self.m_txtCashTimer:setString(timeStr)
    if self.m_remainTime > 0 then
        self:setIsHasDiscount(true)
    else
        self:setIsHasDiscount(false)
    end
end

function StoreChipsItem:getRemainTime()
    return self.m_remainTime
end

function StoreChipsItem:setProPriceDesc(data,discount)
        local price = 0;
        local priceDollar = "";
        local coalaaUnitPrice = "";
        if(data.m_localPayPrice ~=nil and data.m_localPayPrice~="") then
            price = tonumber(data.m_localPayPrice);
            priceDollar = data.m_localPayUnit;
        else
            local reg ="%d+[,.%d]*";
            local truePrice = data.m_price;
            if data.m_priceFormatter then
                truePrice = data.m_priceFormatter(data.m_price)
            end
            
            local words = {}
            for w in string.gmatch(truePrice,reg) do
                words[#words+1] =w;
            end 
                
            local priceNumber = truePrice and words[1] or "";
            priceDollar = string.gsub(truePrice,priceNumber,"");
            local stringPrc = string.gsub(priceNumber,",","");
            -- Log.d( "StoreChipsItem:setProPriceDesc" ,stringPrc)
            price = tonumber(stringPrc);       
        end

        if price == nil then
            price = 1;
        end
        
        if(data.m_localPay == "chip") then
            self.m_txtProPriceDesc:setString(priceDollar.."1=".. 
                string.format(
                    GameString.get("str_store_chips_text"), g_MoneyUtil.formatMoney(math.floor((tonumber(data.m_num) * (1 + discount / 100)) / price))));
        else
            self.m_txtProPriceDesc:setString(priceDollar.."1=".. string.format( GameString.get("str_store_coalaa_text") , g_MoneyUtil.formatMoney(math.floor((tonumber(data.m_num) * (1 + discount / 100)) / price))));
        end
end

-- 是否有折扣
function StoreChipsItem:hasDiscount()
    return self.m_hasDiscount
end

return StoreChipsItem