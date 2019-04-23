local PokerCard = class("PokerCard",cc.Node)

PokerCard.CARD_TYPES  = {"diamond","club","heart","spade"};
PokerCard.CARD_WIDTH  = 80;
PokerCard.CARD_HEIGHT = 108;

function PokerCard:ctor(value)
    self:setAnchorPoint(0.5 ,0.5)
    self.m_scaleX = 1
    self.m_scaleY = 1
    self.pokerSpriteFrame = cc.SpriteFrameCache:getInstance()
    self.pokerSpriteFrame:addSpriteFrames("creator/pokerCard/poker.plist")
    self.m_isValue = false
    self.m_isFront      = true
    self.m_cardChecked  = false
    self:setContentSize(cc.size(PokerCard.CARD_WIDTH ,PokerCard.CARD_HEIGHT))
    self.m_cardBackground = self:createWithSpriteFrame("poker-background.png")
    self.m_cardBack= self:createWithSpriteFrame("poker-back.png")
    self.m_cardBackground:addTo(self)
    g_NodeUtils:arrangeToCenter(self.m_cardBackground)
    self.m_cardBack:addTo(self)
    g_NodeUtils:arrangeToCenter(self.m_cardBack)
    self.m_cardBack:setVisible(false);
    if value and value > 0 then
        self:setCard(value);
    end
end

function PokerCard:createWithSpriteFrame(name)
    if self.pokerSpriteFrame then
       return cc.Sprite:createWithSpriteFrame(self.pokerSpriteFrame:getSpriteFrame(name))
    end
end

function PokerCard:getCard()
    return self.m_card
end

function PokerCard:setCard(value)
    self.m_card = value
    if self.m_isValue == false then
        self:createCard(value);
    elseif self.m_isValue == true then
        self:update(value)
    end   
end

function PokerCard:createCard(value)
    self.m_isValue = true
    if value and value > 0 then
        if self.m_cardType == nil or self.m_cardValue == nil then 
            self.m_cardType,self.m_cardValue = self:getCardTypeAndValueByValue(value);
        end
    end
    self.m_cardValue = self.m_cardValue or 10;
    if g_TableLib.indexof({1, 2, 3, 4}, self.m_cardType) == false then
        self.m_cardType = 1;
    end

    -- 牌值
    if self.m_cardType == 2 or self.m_cardType == 4 then 
        self.m_numImg = self:createWithSpriteFrame("poker-black-"..tostring(self.m_cardValue)..".png");                                  
    else
        self.m_numImg =self:createWithSpriteFrame("poker-red-"..tostring(self.m_cardValue)..".png");                      
    end
    local numImgSize = self.m_numImg:getContentSize()
    self.m_numImg:setPosition(cc.p(numImgSize.width/2+5, self.CARD_HEIGHT  - numImgSize.height/2))
    self.m_cardBackground:addChild(self.m_numImg);
    -- 花色 小图标
    self.m_smallIcon = self:createWithSpriteFrame("poker-small-"..self.CARD_TYPES[self.m_cardType]..".png");
    local smallIconSize = self.m_smallIcon:getContentSize()
    self.m_smallIcon:setPosition(cc.p(smallIconSize.width/2+8,self.CARD_HEIGHT - 30 - smallIconSize.height/2))
    self.m_cardBackground:addChild(self.m_smallIcon);

     -- 花色 大图标
     if 11 <= self.m_cardValue and self.m_cardValue <= 13 then
        self.m_bigIcon = self:createWithSpriteFrame("poker-character-"..tostring(self.m_cardValue)..".png");  
        local bigIconSize = self.m_bigIcon:getContentSize()
        self.m_bigIcon:setPosition(cc.p(bigIconSize.width/2+18,self.CARD_HEIGHT - 22 - bigIconSize.height/2));
    else 
        self.m_bigIcon = self:createWithSpriteFrame("poker-big-"..self.CARD_TYPES[self.m_cardType]..".png");
        local bigIconSize = self.m_bigIcon:getContentSize()
        self.m_bigIcon:setPosition(cc.p(bigIconSize.width/2+23,self.CARD_HEIGHT - 32 - bigIconSize.height/2));
    end
    
    self.m_cardBackground:addChild(self.m_bigIcon);

     --card highLight
     self.m_cardHLight = self:createWithSpriteFrame("poker-hight-light.png");
     self.m_cardHLight:setLocalZOrder(2)
    self.m_cardBackground:addChild(self.m_cardHLight)
     g_NodeUtils:arrangeToCenter(self.m_cardHLight)
     self.m_cardHLight:setVisible(false) 
 
     --card darkLight
     self.m_cardDLight = self:createWithSpriteFrame("poker-dark-light.png")
     self.m_cardDLight:setLocalZOrder(2)
    self.m_cardBackground:addChild(self.m_cardDLight)
     g_NodeUtils:arrangeToCenter(self.m_cardDLight)
     self.m_cardDLight:setVisible(false)
end

function PokerCard:update(value)
    self:hideFadeCard();
    if value and value > 0 then
        self.m_cardType,self.m_cardValue = self:getCardTypeAndValueByValue(value);
    end
    if g_TableLib.indexof({1, 2, 3, 4}, self.m_cardType) ~= false then
        
        if self.m_cardType == 2 or self.m_cardType == 4 then 
            self.m_numImg:setSpriteFrame(self.pokerSpriteFrame:getSpriteFrame("poker-black-"..tostring(self.m_cardValue)..".png"));                                  
        else
            self.m_numImg:setSpriteFrame(self.pokerSpriteFrame:getSpriteFrame("poker-red-"..tostring(self.m_cardValue)..".png"));
        end
        local numImgSize = self.m_numImg:getContentSize()
        self.m_numImg:setPosition(cc.p(numImgSize.width/2+5, self.CARD_HEIGHT - numImgSize.height/2))
    --     As3Kit.reAdjustSize(self.m_numImg);
        
        local smallIconSize = self.m_smallIcon:getContentSize()
        self.m_smallIcon:setSpriteFrame(self.pokerSpriteFrame:getSpriteFrame("poker-small-"..self.CARD_TYPES[self.m_cardType]..".png"));
        self.m_smallIcon:setPosition(cc.p(smallIconSize.width/2+8,self.CARD_HEIGHT - 30 - smallIconSize.height/2))
        --     As3Kit.reAdjustSize(self.m_smallIcon);

        if 11 <= self.m_cardValue and self.m_cardValue <= 13 then
            self.m_bigIcon = self.m_bigIcon:setSpriteFrame("poker-character-"..tostring(self.m_cardValue)..".png");  
            local bigIconSize = self.m_bigIcon:getContentSize()
            self.m_bigIcon:setPosition(cc.p(bigIconSize.width/2+18,self.CARD_HEIGHT - 22 - bigIconSize.height/2));
        else 
            self.m_bigIcon = self.m_bigIcon:setSpriteFrame("poker-big-"..self.CARD_TYPES[self.m_cardType]..".png");
            local bigIconSize = self.m_bigIcon:getContentSize()
            self.m_bigIcon:setPosition(cc.p(bigIconSize.width/2+23,self.CARD_HEIGHT - 32 - bigIconSize.height/2));
        end
    --     As3Kit.reAdjustSize(self.m_bigIcon);
    end
end

function PokerCard:getCardTypeAndValueByValue(value)
    if value and value > 0 then 
        local cardValue = bit.band(value,0xff) ;
        local cardType  = bit.rshift(value,8);
        return cardType , cardValue;
    end
end

function PokerCard:showBack()
    self.m_cardBack:setVisible(true);
    self.m_isFront = false;
end

function PokerCard:hideBack()
    if self.m_cardBack ~= nil then
        self.m_isFront = true;
        self.m_cardBack:setVisible(false);
    end
end

function PokerCard:showHighLight()
    if self.m_cardHLight ~= nil then 
        self.m_cardHLight:setVisible(true)
    end
    self:hideFadeCard();
end

function PokerCard:isHighLight()
    return self.m_cardHLight and self.m_cardHLight:isVisible()
end

function PokerCard:hideHighLight()
    if self.m_cardHLight ~= nil then
        self.m_cardHLight:setVisible(false);
    end
end

function PokerCard:showFadeCard()
    if self.m_cardDLight ~= nil then
        self.m_cardDLight:setVisible(true)
    end
    self:hideHighLight()
end

function PokerCard:hideFadeCard()
    if self.m_cardDLight ~= nil then
        self.m_cardDLight:setVisible(false);
    end
end

function PokerCard:getCardType()
    return self.m_cardType
end

function PokerCard:getCardValue()
    return self.m_cardValue
end

function PokerCard:shakeCard()
    self.m_srcCardX, self.m_srcCardY = self:getPosition()
    self.m_scheduleTask = g_Schedule:schedule(function()
        self:shaking()
    end,1/60)
end

function PokerCard:shaking()
    local x,y = self:getPosition();
    if (x < self.m_srcCardX - 1 or x > self.m_srcCardX + 1) then
        x = self.m_srcCardX;
    end
    if (y < self.m_srcCardY - 1 or y > self.m_srcCardY + 1) then
        y = self.m_srcCardY;
    end
    x = x + math.floor(math.random() * 2) - 1;
    y = y + math.floor(math.random() * 2) - 1;
    self:setPosition(cc.p(x, y));
end

function PokerCard:stopShakeCard()
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
end

function PokerCard:setScale(x,y)
    x= x or 1
    y = y or x or 1
    self.m_scaleX = x
    self.m_scaleY = y
    getmetatable(self)["setScale"](self,x,y)
end

function PokerCard:flipCardStage1(callFunc, obj)
    if self:isVisible() == true then
        
        self.flipCardAnimCallObj = obj
        self.flipCardAnimCallFunc = callFunc
        self.m_isflipPlay1 = true;
        local actScale = cc.ScaleTo:create(0.2, 0.01, self.m_scaleY)
        local delay = cc.DelayTime:create(0.5)
        local seq = cc.Sequence:create(delay , actScale, cc.CallFunc:create(function()
            self:flipCardStage2()
        end))
        self:runAction(seq)
        self:setScale(self.m_scaleX, self.m_scaleY);
    end
end

function PokerCard:flipCardStage2()
    self:hideBack();

    self.m_isflipPlay1 = false;
    local actScale = cc.ScaleTo:create(0.2, self.m_scaleX, self.m_scaleY)
    local callFunc = cc.CallFunc:create(function()
        g_EventDispatcher:dispatch(g_SceneEvent.ROOM_OPERATION_HANDLER,self:getTag())
        if self.flipCardAnimCallFunc then
            self.flipCardAnimCallFunc(self.flipCardAnimCallObj)
            self.flipCardAnimCallFunc = nil
            self.flipCardAnimCallObj = nil
        end
    end)
    self:runAction(cc.Sequence:create(actScale, callFunc))
end

function PokerCard:stopFlipCard()
    self:stopAllActions()
end

function PokerCard:showCard()
    if self.m_isFront == false then
        self:hideBack();
    end
    self:setVisible(true);
    -- self.m_isflipPlay1 = false;
    -- self.m_isflipPlay2 = false;
end

function PokerCard:setChecked(checked)
    self.m_checked = checked;
end

function PokerCard:isChecked()
    return self.m_checked;
end

function PokerCard:isFront()
    return self.m_isFront;
end

function PokerCard:refresh()
    self:stopFlipCard();
    self:stopShakeCard();
    self:removeCardOverlay();
end

function PokerCard:cleanUp()
    self:stopFlipCard();
    self:stopShakeCard();
    self:removeCardOverlay();
end

function PokerCard:removeCardOverlay()
    self:hideBack();
    self:hideFadeCard();
    self:hideHighLight();
end

function PokerCard:dtor()
    self.m_isValue = false
end

return PokerCard