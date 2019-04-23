local BetInZone = class("BetInZone", cc.Node);

BetInZone.m_chipLabel = nil;
BetInZone.whiteChipBitmapFontTextFormat = nil;
BetInZone.yellowChipBitmapFontTextFormat = nil;

BetInZone.init = function(self)
    BetInZone.yellowChipBitmapFontTextFormat = nil;
    BetInZone.whiteChipBitmapFontTextFormat = nil;
end

BetInZone.ctor = function(self, labelColor)
    self.m_background = cc.Scale9Sprite:create( "creator/normalRoom/img/pos/room-bet-chip-bg.png")
    self:addChild(self.m_background);

    local r = 0;
    local g = 0;
    local b = 0;
    if (labelColor == "w") then
--        self.m_chipLabel.textRendererProperties.textFormat = whiteChipBitmapFontTextFormat;
        r = 255;
        g = 255;
        b = 255;
    else
--        self.m_chipLabel.textRendererProperties.textFormat = yellowChipBitmapFontTextFormat;
        r = 250;
        g = 219;
        b = 140;
    end
    local size = self.m_background:getContentSize();
    self.m_chipLabel = cc.Label:createWithSystemFont("", nil, 24)
    self.m_chipLabel:setTextColor(cc.c3b(r,g,b))
    g_NodeUtils:arrangeToCenter(self.m_chipLabel)
    self:addChild(self.m_chipLabel)
    self:setContentSize(size)
end

BetInZone.setChipLabel = function(self, value)
    self.m_chipLabel:setVisible(tonumber(value) ~= 0)
    self.m_background:setVisible(tonumber(value) ~= 0)
    self.m_chipLabel:setString(g_MoneyUtil.formatMoney(value));
    self.m_chips = value
    local txSize = self.m_chipLabel:getContentSize()
    self.m_background:setContentSize(txSize.width + 15, txSize.height)
    self:setContentSize(txSize.width + 15, txSize.height)
end

function BetInZone:getChips()
    return self.m_chips or 0
end

return BetInZone