--[[--ldoc desc
@module GameReviewSeatview
@author JamesLiang

Date   2019/01/04
]]

local GameReviewSeatview  = class("GameReviewSeatview",cc.Node)
GameReviewSeatview.NAMEBG_POSITION = {
    {x=0, y=47},--1号位
    {x=57.5, y=46},
    {x=70, y=-94},
    {x=0, y=-100},
    {x=0, y=-100},
    {x=0, y=-100},
    {x=-70, y=-94},
    {x=-63, y=46},
    {x=-4, y=47},--9号位
}
GameReviewSeatview.CARDTYPERESULT ={
    {x=0, y=-70},--1号位
    {x=-66, y=-36},
    {x=-54, y=27},
    {x=1, y=31},
    {x=1, y=31},
    {x=1, y=31},
    {x=62, y=26},
    {x=65, y=-38.5},
    {x=-4, y=-70},--9号位
}

function GameReviewSeatview:ctor(i)
    self:initScene()
    self:creatHandCard()
    self:setSeatId(i)
    self:setLayoutPosition(i)
end

function GameReviewSeatview:initScene()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/roomGameReview/roomGameReviewSeatview.ccreator')
    self.m_handCardsView = g_NodeUtils:seekNodeByName(self.m_root, "handCardsView")
    self.m_cardtypeResult = g_NodeUtils:seekNodeByName(self.m_root, "cardtypeResult")
    self.m_cardtypeFold = g_NodeUtils:seekNodeByName(self.m_root, "cardtypeFold")
    self.m_nameBg = g_NodeUtils:seekNodeByName(self.m_root, "name_bg")
    self.m_nameLabel = g_NodeUtils:seekNodeByName(self.m_root, "name_label")
    self.m_winMoneyLabel = g_NodeUtils:seekNodeByName(self.m_root, "winMoney_label")
    self.m_winImg = g_NodeUtils:seekNodeByName(self.m_root, "win_img")
    self.m_isWinBg = g_NodeUtils:seekNodeByName(self.m_root, "isWin_bg")
    

    g_NodeUtils:convertTTFToSystemFont(self.m_nameLabel)

    self.m_cardtypeResult:setVisible(false)
    self.m_cardtypeFold:setVisible(true)
    self.m_isWinBg:setVisible(false)
    self.m_winImg:setVisible(false)
    self.m_cardtypeResult:setString(GameString.get("str_room_operation_type_2"))
    self.m_cardtypeFold:setString(GameString.get("str_room_operation_type_2"))
    -- self.m_cardtypeResult:setTextColor(cc.c4b(255,255,255,255))
    -- self.m_cardtypeResult:setTextColor(cc.c4b(255,94,94,255))
    

    local rootSize = self.m_root:getContentSize()
    self.m_width = rootSize.width
    self.m_height = rootSize.height
    self:setContentSize(rootSize)
    self:addChild(self.m_root)
    local x, y = self.m_root:getPosition()
    -- self.m_root:setPosition(cc.p(self.m_width/2, self.m_height/2))
    self.m_root:setPosition(cc.p(0, 0))

end

function GameReviewSeatview:creatHandCard()
    local psize = self.m_handCardsView:getContentSize()
    self.m_handCardLeft = g_PokerCard:create()
    local sSize = self.m_handCardLeft:getContentSize()
    self.m_handCardsView:addChild(self.m_handCardLeft)
    self.m_handCardLeft:setAnchorPoint(cc.p(0,0))
    self.m_handCardLeft:setVisible(false)
    self.m_handCardLeft:showBack()
    self.m_handCardLeft:setVisible(true)
    self.m_handCardLeft:setRotation(-4)
    self.m_handCardLeft:setScale(0.6)
    local offX = (psize.width-sSize.width*0.6)*0.5
    local offy = (psize.height-sSize.height*0.6)
    self.m_handCardLeft:setPosition(cc.p(-10+offX, offy-39))

    self.m_handCardRight = g_PokerCard:create()
    self.m_handCardsView:addChild(self.m_handCardRight)
    self.m_handCardRight:setAnchorPoint(cc.p(0,0))
    self.m_handCardRight:setVisible(false)
    self.m_handCardRight:showBack()
    self.m_handCardRight:setVisible(true)
    self.m_handCardRight:setRotation(8)
    self.m_handCardRight:setScale(0.6)
    self.m_handCardRight:setPosition(cc.p(10+offX, offy-35))
    
end

function GameReviewSeatview:setLayoutPosition(i)
    local nameBgPos = GameReviewSeatview.NAMEBG_POSITION[i]
    self.m_nameBg:setPosition(cc.p(nameBgPos.x + 100, nameBgPos.y+100))
    local cardTypeResultPos = GameReviewSeatview.CARDTYPERESULT[i]
    self.m_cardtypeResult:setPosition(cc.p(cardTypeResultPos.x+100, cardTypeResultPos.y+100))
    self.m_cardtypeFold:setPosition(cc.p(cardTypeResultPos.x+100, cardTypeResultPos.y+100))
end 

function GameReviewSeatview:updateView(data)
    self.m_handCardLeft:setCard(data.handCard1)
    self.m_handCardLeft:showCard();
    self.m_handCardRight:setCard(data.handCard2)
    self.m_handCardRight:showCard()
end
    
function GameReviewSeatview:showFadeCard()
    self.m_handCardLeft:showFadeCard()
    self.m_handCardRight:showFadeCard()
end

function GameReviewSeatview:showCardResult(isShow, cardType)
    if isShow  then
        self.m_cardtypeResult:setVisible(true)
        self.m_cardtypeResult:setString(GameString.get("str_room_card_type_result")[cardType])
    else
        self.m_cardtypeResult:setVisible(false)
        self.m_cardtypeResult:setString(cardType or "")
    end
    self.m_cardtypeResult:setVisible(true)
    self.m_cardtypeFold:setVisible(false)
    -- self.m_cardtypeResult:setTextColor(cc.c4b(255,255,255,255))
    -- self.m_cardtypeResult:setTextColor(cc.c4b(58,215,136,255))
end

function GameReviewSeatview:showHighLight(data)

    local isvisible = self.m_cardtypeResult:isVisible()
    local string = self.m_cardtypeResult:getString()
    if self:isEqualToWinnerCard(self.m_handCardLeft,data) then
        self.m_handCardLeft:showHighLight()
    end
    if self:isEqualToWinnerCard(self.m_handCardRight,data) then
        self.m_handCardRight:showHighLight()
    end
end

function GameReviewSeatview:isEqualToWinnerCard(handCard, winnerCard)
    for i = 1, 5 do
        local cardName = "card"..i
        if handCard:getCardValue()~=0 and winnerCard[cardName] then
            if bit.band(winnerCard[cardName], 0xff)==handCard:getCardValue() and bit.rshift(winnerCard[cardName], 8)==handCard:getCardType() then
                return true
            end
        end
    end
    return false
end

function GameReviewSeatview:setWinAndWinchip(isWin, winChip)
    self.m_winImg:setVisible(isWin)
    self.m_isWinBg:setVisible(isWin)
    if isWin then
        self.m_winMoneyLabel:setString("+" .. string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(winChip)))
    else
        self.m_winMoneyLabel:setString("-" .. string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(winChip)))
    end
end

function GameReviewSeatview:setName(name)
    self.m_nameLabel:setVisible(true)
    self.m_nameLabel:setString(g_StringLib.limitLength(name,20,88))
end

function GameReviewSeatview:setSeatId(seatId)
    self.m_seatId = seatId
end

function GameReviewSeatview:getSeatId(seatId)
    return self.m_seatId
end

function GameReviewSeatview:reset()
    self.m_cardtypeResult:setVisible(true)
    self.m_isWinBg:setVisible(false)
    self.m_winImg:setVisible(false)
    self.m_cardtypeResult:setString(GameString.get("str_room_operation_type_2"))
    self.m_cardtypeResult:setVisible(false)
    self.m_cardtypeFold:setVisible(true)
    -- self.m_cardtypeResult:setTextColor(cc.c4b(255,255,255,255))
    -- self.m_cardtypeResult:setTextColor(cc.c4b(255,94,94,255))
    self.m_handCardLeft:refresh();
    self.m_handCardLeft:showBack();
    self.m_handCardRight:refresh();
    self.m_handCardRight:showBack();
end

return GameReviewSeatview