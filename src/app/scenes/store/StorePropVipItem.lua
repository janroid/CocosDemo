local NodeUtils = import("framework.utils").NodeUtils
local StoreManager = require ".StoreManager"
local StorePropVipItem  = class("StorePropVipItem",cc.Node)

function StorePropVipItem:ctor(data)
    self:init()
    self.m_data = data
    self:updateView(data)
end

function StorePropVipItem:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/store/layout/layout_store_props_vip_list_item.ccreator')
    self:addChild(self.m_root)
    self.m_btnItem = NodeUtils:seekNodeByName(self.m_root,'btn_item')
    self.m_btnItem:setSwallowTouches(false)
    self.m_txtProductName = NodeUtils:seekNodeByName(self.m_btnItem,'txt_product_name') 
    self.m_btnBuy = NodeUtils:seekNodeByName(self.m_btnItem,'btn_buy') 
    self.m_txtProductPrice = NodeUtils:seekNodeByName(self.m_btnBuy,'txt_product_price')
    self.m_btnArrow= NodeUtils:seekNodeByName(self.m_btnItem,'btn_arrow') 
    self.m_btnArrowClickArea= NodeUtils:seekNodeByName(self.m_btnItem,'btn_array_click_area')
    self.m_imgProduct= NodeUtils:seekNodeByName(self.m_btnItem,'img_product') 
    self.m_btnItemDark= NodeUtils:seekNodeByName(self.m_root,'btn_item_dark') 
    self.m_descriptionTxt= NodeUtils:seekNodeByName(self.m_root,'label_description')
    self.m_isShowDes = false
    self.m_btnItemDark:setVisible(false)
    self.m_descriptionTxt:setVisible(false)
    self:setBtnClickListener()
end
function StorePropVipItem:setRootParent(rootParent)
    self.rootParent = rootParent
end

function StorePropVipItem:setBtnClickListener()
    local function btnBuyClickListener(sender)
        Log.d("StoreChipsItem:onBuyClick ",self.m_data)
        local start_pos = sender:getTouchBeganPosition()
        local end_pos = sender:getTouchEndPosition()
        if math.abs(start_pos.y - end_pos.y) > 20 then return end
        StoreManager:getInstance():requestCreateOrder(self.m_data)
    end
    self.m_btnItem:addClickEventListener(btnBuyClickListener)
    self.m_btnBuy:addClickEventListener(btnBuyClickListener)
end

function StorePropVipItem:updateView(data)
    self.m_txtProductName:setString(data.m_displayName)
    self:setDescriptionTxt(data.m_desc)
    if data.m_priceFormatter then
        self.m_txtProductPrice:setString(data.m_priceFormatter(data.m_price))
    else
        self.m_txtProductPrice:setString(data.m_price)
    end
    if((data.m_img~= "") and (data.m_localPay == "props")) then
        self.m_imgProduct:setTexture("creator/store/store_pro_small_"..tonumber(data.m_img)..".png"); 						
    elseif((data.m_img~="") and (data.m_localPay == "vip")) then
        self.m_imgProduct:setTexture("creator/store/store_pro_small_"..tonumber(data.m_img)..".png"); 
    else
        self.m_imgProduct:setTexture("creator/store/store_pro_small_"..tonumber(data.m_id)..".png");
    end
end

function StorePropVipItem:setDescriptionTxt(descriptionTxt)
    self.m_descriptionTxt:setString(descriptionTxt)
    local txtViewSize =self.m_descriptionTxt:getContentSize()
    
    local height = txtViewSize.height+20
    local btnItemDarkSize = self.m_btnItemDark:getContentSize();
    if txtViewSize.height < btnItemDarkSize.height then
        height = btnItemDarkSize.height+20
    else
        self.m_btnItemDark:setContentSize(cc.size(btnItemDarkSize.width,height));
        self.m_descriptionTxt:setPositionY(txtViewSize.height+20)
    end
    
end

function StorePropVipItem:changeArrow()
    if self.m_isShowDes then
        self:hideDescription()
    else  
        self:showDescription()
    end
end

function StorePropVipItem:isShowDes()
    return self.m_isShowDes
end

function StorePropVipItem:getDesHeight()
    local darkBgSize = self.m_btnItemDark:getContentSize()
    local descriptionTxtSize = self.m_descriptionTxt:getContentSize()
    return descriptionTxtSize.height+20
end

-- 隐藏描述内容
function StorePropVipItem:hideDescription()
    local actionRotate =  cc.RotateTo:create(0.2,0)
    self.m_btnArrow:runAction(actionRotate)
    self.m_isShowDes = false
    local arrowPosY = self.m_btnItemDark:getPositionY()
    local descSize = self.m_descriptionTxt:getContentSize()
    local itemSize = self.m_btnItemDark:getContentSize()
    -- if 
    local moveDis = descSize.height
    if itemSize.height>descSize.height then
        moveDis = itemSize.height
    -- -- else
    -- --     moveDis = moveDis-itemSize.height-20
    end
    local callbackFunc = function ()
        self.m_descriptionTxt:setVisible(false)
        self.m_btnItemDark:setVisible(false)
        -- self.m_btnItemDark:setContentSize(cc.size(itemSize.width,itemSize.height));
    end
    
    local actionScale = cc.ScaleTo:create(0.2,1.0,moveDis/(itemSize.height))
    -- local actionMove =  cc.MoveTo:create(0.2,cc.p(0,arrowPosY+moveDis-itemSize.height-20))
    -- local actionMove =  cc.MoveTo:create(0.2,cc.p(0,arrowPosY+moveDis))
    -- local spawn = cc.Spawn:create(actionMove)
    local seq = cc.Sequence:create(actionScale, cc.CallFunc:create(callbackFunc) )
    
    self.m_btnItemDark:runAction(seq)
    self.m_descriptionTxt:setVisible(false)
    self.m_btnItemDark:setVisible(false)
    
end

-- 显示描述内容
function StorePropVipItem:showDescription()
    local actionRotate =  cc.RotateTo:create(0.2,180)
    self.m_btnArrow:runAction(actionRotate)
    self.m_isShowDes = true
    local arrowPosY = self.m_btnItemDark:getPositionY()
    local descSize = self.m_descriptionTxt:getContentSize()
    local itemSize = self.m_btnItemDark:getContentSize()
    local moveDis = descSize.height
    if itemSize.height>descSize.height then
        moveDis = itemSize.height
    end

    local callbackFunc = function ()
        self.m_descriptionTxt:setVisible(true)
        self.m_btnItemDark:setVisible(true)
        self.m_btnItemDark:setContentSize(cc.size(itemSize.width,descSize.height+40));
    end
    local actionScale = cc.ScaleTo:create(0.2,1.0,(moveDis)/itemSize.height)
    local seq = cc.Sequence:create(actionScale, cc.CallFunc:create(callbackFunc) )
    self.m_btnItemDark:runAction(seq)
end

function StorePropVipItem:setOnBtnArrowClick(arrowClickFun)
    self.m_btnArrow:addClickEventListener(arrowClickFun)
    self.m_btnArrowClickArea:addClickEventListener(arrowClickFun)
end

return StorePropVipItem