local utils = import("framework/utils")
local bit = utils.BitUtil

local CalculateCardType = class();

--牌面值从0x2-0xe，分别代表2、3、4、5、6、7、8、9、10、J、Q、K、A
--花色: 1=钻石，2=梅花，3=红心，4=黑桃
--所以红心2是0x302

CalculateCardType.TAG = "CalculateCardType";

--[Comment]
--所有牌
CalculateCardType.m_allCards = {};
--[Comment]
--相同的牌（起始位置，连续几张相同）
CalculateCardType.m_sameCards = {};
--[Comment]
--各花色数量
CalculateCardType.m_colorCount = {};
--[Comment]
--成牌的5张牌
CalculateCardType.m_highCards = {};
--[Comment]
--成牌的关键牌（对子以上才记录）
CalculateCardType.m_keyCards = {};
--[Comment]
--同花成牌的花色
CalculateCardType.m_flushColor = 0;
--[Comment]
--至少有两张相同牌的牌面数量
CalculateCardType.m_sameCardCount = 0;
--[Comment]
--对子的数量
CalculateCardType.m_pairCount = 0;
--[Comment]
--三条的数量
CalculateCardType.m_threeCount = 0;
CalculateCardType.m_bestPokerType = 10;
CalculateCardType.m_bestPokerArr = nil;
CalculateCardType.m_currentPokerType = 10;
CalculateCardType.m_currentPokerArr = nil;

CalculateCardType.UNKNOWN        = 1;
CalculateCardType.HIGH_CARD      = 2; --牌型: 高牌
CalculateCardType.PAIR           = 3; --牌型: 一对
CalculateCardType.TWO_PAIRS      = 4; --牌型: 两对
CalculateCardType.THREE_KIND     = 5; --牌型: 三条
CalculateCardType.STRAIGHT       = 6; --牌型: 顺子
CalculateCardType.FLUSH          = 7; --牌型: 同花
CalculateCardType.FULL_HOUSE     = 8; --牌型: 葫芦
CalculateCardType.FOUR_KIND      = 9; --牌型: 四条
CalculateCardType.STRAIGHT_FLUSH = 10;--牌型: 同花顺
CalculateCardType.ROYAL_FLUSH    = 11;--牌型: 皇家同花顺

CalculateCardType.DISPLAYCARDTYPE = 1;
CalculateCardType.COLORS =
{
    "♦", "♣", "♥", "♠",
};
CalculateCardType.CARDTYPE_NAME =
{
    [CalculateCardType.HIGH_CARD     ] = GameString.get("str_room_card_type_2"),--"高牌",
    [CalculateCardType.PAIR          ] = GameString.get("str_room_card_type")[9],--"一对",
    [CalculateCardType.TWO_PAIRS     ] = GameString.get("str_room_card_type")[8],--"两对",
    [CalculateCardType.THREE_KIND    ] = GameString.get("str_room_card_type")[7],--"三条",
    [CalculateCardType.STRAIGHT      ] = GameString.get("str_room_card_type")[6],--"顺子",
    [CalculateCardType.FLUSH         ] = GameString.get("str_room_card_type")[5],--"同花",
    [CalculateCardType.FULL_HOUSE    ] = GameString.get("str_room_card_type")[4],--"葫芦",
    [CalculateCardType.FOUR_KIND     ] = GameString.get("str_room_card_type")[3],--"四条",
    [CalculateCardType.STRAIGHT_FLUSH] = GameString.get("str_room_card_type")[2],--"同花顺",
    [CalculateCardType.ROYAL_FLUSH   ] = GameString.get("str_room_card_type")[1],--"皇家同花顺",
};

CalculateCardType.getCardDisName = function(self, card)
    local value = self:getcardvalue(card);
    local color = self:getcolor(card);
    local sColor = "";
    if(CalculateCardType.COLORS[color]) then
        sColor = CalculateCardType.COLORS[color];
    end
    if(value ~= 0) then
        return sColor .. self:getCardName(value);
    else
        return "";
    end
end

CalculateCardType.getCardTypeName = function(self, cardType)
    if(CalculateCardType.CARDTYPE_NAME[cardType]) then
        return CalculateCardType.CARDTYPE_NAME[cardType];
    else
        return "";
    end
end

CalculateCardType.getHighCards = function(self) 
    return self.m_highCards;
end

CalculateCardType.calculateType = function(self, HandCard1, HandCard2, CardArr) 
    if not HandCard1 or not HandCard2 or g_TableLib.isEmpty(CardArr) then
        return
    end
    self.m_flushColor    = 0;
    self.m_sameCardCount = 0;
    self.m_pairCount     = 0;
    self.m_threeCount    = 0;

    for i = 1, 7 do
        self.m_allCards[i] = 0;
    end
    for i = 1, 4 do
        self.m_colorCount[i] = 0;
    end
    for i = 1, 3 do
        self.m_sameCards[i] = {0,0};
    end
    for i = 1, 5 do
        self.m_highCards[i] = 0;
    end
    self.m_allCards[1] = HandCard1;
    self.m_allCards[2] = HandCard2;
    for i = 1, 5 do
        if(type(CardArr[i]) == "number") then
            self.m_allCards[i + 2] = CardArr[i];
        else
            self.m_allCards[i + 2] = 0;
        end
    end

    --冒泡排序
    local temp = 0;
    local max = 0;
    for i = 1, 7 do
        max = i;
        for j = i + 1, 7 do
            if (self:getcardvalue(self.m_allCards[j]) > self:getcardvalue(self.m_allCards[max])) then
                max = j;
            end
        end
        if (max ~= i) then
            temp = self.m_allCards[i];
            self.m_allCards[i] = self.m_allCards[max];
            self.m_allCards[max] = temp;
        end
    end

    --计算各花色数量
    for i = 1, 7 do
        if (self.m_allCards[i] ~= 0) then
            local color = self:getcolor(self.m_allCards[i]);
            if self.m_colorCount[color] ~= nil then 
                self.m_colorCount[color] = self.m_colorCount[color] + 1;
                if (self.m_colorCount[color] >= 5) then
                    self.m_flushColor = color;
                end
            end
        end
    end

    --计算相同牌面的数量
    local count = 0;
    local start = 0;
    local index;
    for i = 2, 7 do
        while(true) do
            if (count == 0) then
                if (self.m_allCards[i - 1] == 0) then
                    break;
                end
                count = 1;
                start = self:getcardvalue(self.m_allCards[i - 1]);
            end
            if (start == self:getcardvalue(self.m_allCards[i])) then
                count = count + 1;
            else
                if (count >= 2) then
            	    self:samecards(i, count);
                end
                count = 0;
            end
            index = i;
            break;
        end
    end

    if (count >= 2) then
        self:samecards(index+1, count);
    end

    --计算牌型
    self.DISPLAYCARDTYPE = 10;
    if (self:isRoyalFlush()) then
        self.DISPLAYCARDTYPE = CalculateCardType.ROYAL_FLUSH;
    elseif (self:isStraightFlush()) then
        self.DISPLAYCARDTYPE = CalculateCardType.STRAIGHT_FLUSH;
    elseif (self:isFourCard()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.FOUR_KIND;
    elseif (self:isFullHouse()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.FULL_HOUSE;
    elseif (self:isFlush()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.FLUSH;
    elseif (self:isStraight()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.STRAIGHT;
    elseif (self:isThreeCard()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.THREE_KIND;
    elseif (self:isTwoPair()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.TWO_PAIRS;
    elseif (self:isPair()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.PAIR;
    elseif(self:isHighCard()) then
        self.DISPLAYCARDTYPE =  CalculateCardType.HIGH_CARD;
    else
        self.DISPLAYCARDTYPE =  CalculateCardType.HIGH_CARD;
    end

    --for debug only !!!
    local sLine = "";
    local sHand1 = self:getCardDisName(HandCard1);
    local sHand2 = self:getCardDisName(HandCard2);
    sLine = sLine .. sHand1;
    sLine = sLine .. sHand2;
    for _,v in pairs(CardArr) do
        sLine = sLine .. self:getCardDisName(v);
    end
    Log.d(CalculateCardType.TAG, sLine .. "=" .. self:getCardTypeName(self.DISPLAYCARDTYPE));

    return self.DISPLAYCARDTYPE;
end

CalculateCardType.getCardName = function(self, cardValue) 
    if(cardValue == 14) then
        return "A";
    elseif(cardValue == 13) then
        return "K";
    elseif(cardValue == 12) then
        return "Q";
    elseif(cardValue == 11) then
        return "J";
    else
        return tostring(cardValue);
    end
end

CalculateCardType.isHighCard = function(self) 
    for i=1,5 do
        self.m_highCards[i] = self.m_allCards[i];
        self.m_keyCards[i] = 0;
    end
    return true;
end

CalculateCardType.isPair = function(self) 
    if (self.m_pairCount < 1) then
        return false;
    end

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    local startPosition = self.m_sameCards[1][1];
    local n = 3;
    self.m_highCards[1] = self.m_allCards[startPosition];
    self.m_keyCards[1] = self.m_allCards[startPosition];
    self.m_highCards[2] = self.m_allCards[startPosition + 1];
    self.m_keyCards[2] = self.m_allCards[startPosition + 1];
    local i = 1;
    local value = self:getcardvalue(self.m_highCards[1]);
    while(i <= 7 and n <= 5) do
        local v = self:getcardvalue(self.m_allCards[i]);
        if (v ~= value) then
            self.m_highCards[n] = self.m_allCards[i];
            n = n + 1;
        end
        i = i + 1;
    end
    return true;
end

CalculateCardType.isTwoPair = function(self) 
    if (self.m_pairCount < 2) then
        return false;
    end

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    local startPosition = self.m_sameCards[1][1];
    self.m_highCards[1] = self.m_allCards[startPosition];
    self.m_keyCards[1] = self.m_allCards[startPosition];
    self.m_highCards[2] = self.m_allCards[startPosition + 1];
    self.m_keyCards[2] = self.m_allCards[startPosition + 1];

    startPosition = self.m_sameCards[2][1];
    self.m_highCards[3] = self.m_allCards[startPosition];
    self.m_keyCards[3] = self.m_allCards[startPosition];
    self.m_highCards[4] = self.m_allCards[startPosition + 1];
    self.m_keyCards[4] = self.m_allCards[startPosition + 1];
    for i=1,7 do
        local val1 = self:getcardvalue(self.m_allCards[i]);
        local val2 = self:getcardvalue(self.m_highCards[1]);
        local val3 = self:getcardvalue(self.m_highCards[3]);
        if (val1 ~= val2 and val1 ~= val3) then
            self.m_highCards[5] = self.m_allCards[i];
            break;
        end
    end
    return true;
end

CalculateCardType.isThreeCard = function(self) 
    if (self.m_threeCount < 1) then
        return false;
    end

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    self:filterFirstThreeCard();
    local threeKindValue = self:getcardvalue(self.m_highCards[1]);
    local n = 4;
    local i = 1;
    while(i <= 7 and n <= 5) do
        if (threeKindValue ~= self:getcardvalue(self.m_allCards[i])) then
            self.m_highCards[n] = self.m_allCards[i];
            n = n + 1;
        end
        i = i + 1;
    end
    return true;
end

--获取最大的三条 
CalculateCardType.filterFirstThreeCard = function(self) 
    local startPosition = -1;
    for i=1,self.m_sameCardCount do
        if (self.m_sameCards[i][2] == 3) then
            startPosition = self.m_sameCards[i][1];
            break;
        end
    end
    
    for i = 1, 3 do
        local card = self.m_allCards[startPosition + i - 1];
        self.m_highCards[i] = card;
        self.m_keyCards[i] = card;
    end
end

CalculateCardType.isStraight = function(self) 
    local i = 0;
    local nCount = 0;
    local nowValue = 0;
    local nextValue = 0;

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    local hasAce = false;
    local hasAceAndKing = false;
    local tempAce = 1;
    local scArray = {};
    for j=1,7 do
        scArray[#scArray+1] = self.m_allCards[j];
    end

    if(self:getcardvalue(scArray[1])==14 and self:getcardvalue(scArray[2])~=13) then
        --有A没有K的情况，把A的值置为1，放在数组最后，然后重新排序排出有0的情况
        hasAce = true;
        tempAce = CalculateCardType.deleteAt(scArray, 1);
        scArray[#scArray+1] = 1;
        table.sort(scArray, function(a, b)
                                return self:sortFunc(a, b);
                            end);
    elseif (self:getcardvalue(scArray[1])==14 and self:getcardvalue(scArray[2])==13) then
        --有A有K的情况，先把A当14来算，再把A当1来算
        hasAceAndKing = true;
    end

    i = 2;
    while (i <= 7) do
        nowValue   = self:getcardvalue(scArray[i-1]);
        nextValue  = self:getcardvalue(scArray[i]);
        self.m_highCards[nCount+1] = scArray[i-1];
        self.m_keyCards[nCount+1] = scArray[i-1];

        if (nowValue > 1 and nowValue == nextValue + 1) then -- nowValue > 1 排除有0的情况
            nCount = nCount + 1;
            if (nCount == 4) then
                self.m_highCards[5] = scArray[i];
                self.m_keyCards[5] = scArray[i];
                if(hasAce and self.m_highCards[5] == 1) then
                    self.m_highCards[nCount+1] = tempAce;
                    self.m_keyCards[nCount+1] = tempAce;
                end
                return true;
            end
        elseif (nowValue ~= nextValue) then
            nCount = 0;
        end
        i = i + 1;
    end
    if (hasAceAndKing) then
        nCount = 0;
        hasAce = true;
        tempAce = CalculateCardType.deleteAt(scArray, 1);
        scArray[#scArray+1] = 1;
        table.sort(scArray, function(a, b)
                                return self:sortFunc(a, b);
                            end);

        i = 2;
        while (i <= 7) do
            nowValue   = self:getcardvalue(scArray[i-1]);
            nextValue  = self:getcardvalue(scArray[i]);
            self.m_highCards[nCount+1] = scArray[i-1];
            self.m_keyCards[nCount+1] = scArray[i-1];

            if (nowValue > 1 and nowValue == nextValue + 1) then -- nowValue > 1 排除有0的情况
                nCount = nCount + 1;
                if (nCount == 4) then
                    self.m_highCards[5] = scArray[i];
                    self.m_keyCards[5] = scArray[i];
                    if(hasAce and self.m_highCards[5] == 1) then
                        self.m_highCards[nCount+1] = tempAce;
                        self.m_keyCards[nCount+1] = tempAce;
                    end
                    return true;
                end
            elseif (nowValue ~= nextValue) then
                nCount = 0;
            end
            i = i + 1;
        end
    end
    return false;
end

CalculateCardType.sortFunc = function(self, a, b) 
    if (self:getcardvalue(a) > self:getcardvalue(b)) then
        return true;---1;
    else
        return false;--1;
    end
end

CalculateCardType.isFlush = function(self) 
    if (self.m_flushColor == 0) then
        return false;
    end

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    local position = 1;
    local i = 1;
    while(i <= 7 and position <= 5) do
        if (self:getcolor(self.m_allCards[i]) == self.m_flushColor) then
            self.m_highCards[position] = self.m_allCards[i];
            self.m_keyCards[position] = self.m_allCards[i];
            position = position + 1;
        end
        i = i + 1;
    end
    return true;
end

CalculateCardType.isFullHouse = function(self) 
    if (self.m_threeCount < 1) then
        return false;
    end
    if (self.m_threeCount == 1 and self.m_pairCount < 1) then
        return false;
    end
    local position = 1;

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    self:filterFirstThreeCard();

    if (self.m_threeCount > 1) then
        position = self.m_sameCards[2][1];
        self.m_highCards[4] = self.m_allCards[position];
        self.m_keyCards[4] = self.m_allCards[position];
        self.m_highCards[5] = self.m_allCards[position + 1];
        self.m_keyCards[5] = self.m_allCards[position + 1];
    else
        for i=1,self.m_sameCardCount do
            if (self.m_sameCards[i][2] == 2) then
                position = self.m_sameCards[i][1];
                break;
            end
        end
        self.m_highCards[4] = self.m_allCards[position];
        self.m_keyCards[4] = self.m_allCards[position];
        self.m_highCards[5] = self.m_allCards[position + 1];
        self.m_keyCards[5] = self.m_allCards[position + 1];
    end
    return true;
end

CalculateCardType.isFourCard = function(self) 
    for i=1,self.m_sameCardCount do
        if (self.m_sameCards[i][2] == 4) then
            for j=1,5 do
                self.m_keyCards[j] = 0;
            end

            self.m_highCards[1] = self.m_allCards[self.m_sameCards[i][1]];
            self.m_keyCards[1] = self.m_allCards[self.m_sameCards[i][1]];
            self.m_highCards[2] = self.m_allCards[self.m_sameCards[i][1]+1];
            self.m_keyCards[2] = self.m_allCards[self.m_sameCards[i][1]+1];
            self.m_highCards[3] = self.m_allCards[self.m_sameCards[i][1]+2];
            self.m_keyCards[3] = self.m_allCards[self.m_sameCards[i][1]+2];
            self.m_highCards[4] = self.m_allCards[self.m_sameCards[i][1]+3];
            self.m_keyCards[4] = self.m_allCards[self.m_sameCards[i][1]+3];
            self.m_sameCards[i][1] = self.m_sameCards[i][1] == 1 and 5 or 1;
            self.m_highCards[5] = self.m_allCards[self.m_sameCards[i][1]];
            return true;
        end
    end
    return false;
end

CalculateCardType.isRoyalFlush = function(self)
    if (self.m_flushColor == 0) then    --剔除不是同花
        return false;
    end

    local scArray  = {};

    for i=1,5 do
        self.m_keyCards[i] = 0;
    end

    for j=1,7 do
        if( self:getcolor(self.m_allCards[j]) == self.m_flushColor) then
            scArray[#scArray+1] = self.m_allCards[j];
        end
    end
   

    if (self:isStraight() and scArray ~= nil and self:getcardvalue(scArray[1])==14 and self:getcardvalue(scArray[2])==13) then --顺子，有A和K
    local i = 1;
    while (i <= 5) do
        self.m_highCards[i] = scArray[i];
        self.m_keyCards[i] = scArray[i];
        i = i+1;
    end
        return true;
    end
    return false;
end

CalculateCardType.isStraightFlush = function(self) 
    if (self.m_flushColor == 0) then
        return false;
    end
    if (self:isStraight()) then
        local i = 0; 
        local j = 0; 
        local nCount = 0;
        local nowValue = 0;
        local nextValue = 0;

        local hasAce = false;
        local tempAce    = 1;
        local scArray  = {};

        for i=1,5 do
            self.m_keyCards[i] = 0;
        end

        for j=1,7 do
            if( self:getcolor(self.m_allCards[j]) == self.m_flushColor) then
                scArray[#scArray+1] = self.m_allCards[j];
            end
        end

        if(scArray and self:getcardvalue(scArray[1]) == 14 and self:getcardvalue(scArray[2]) ~= 13) then
            hasAce = true;
            tempAce = CalculateCardType.deleteAt(scArray, 1);
            scArray[#scArray+1] = 1;
        end

        i = 2;
        while (i <= #scArray) do
            nowValue   = self:getcardvalue(scArray[i-1]);
            nextValue  = self:getcardvalue(scArray[i]);
            self.m_highCards[nCount+1] = scArray[i-1];
            self.m_keyCards[nCount+1] = scArray[i-1];

            if (nowValue == nextValue + 1) then
                nCount = nCount + 1;
                if (nCount == 4) then
                    self.m_highCards[5] = scArray[i];
                    self.m_keyCards[5] = scArray[i];
                    if(hasAce and self.m_highCards[5] == 1) then
                        self.m_highCards[nCount+1] = tempAce;
                        self.m_keyCards[nCount+1] = tempAce;
                    end
                    return true;
                end
            end
            i = i + 1;
        end
    end
    return false;
end

CalculateCardType.getcardvalue = function(self, c) 
    return bit.band(c, 0xFF);
end

CalculateCardType.getcolor = function(self, c) 
    return bit.brshift(c, 8);
end

CalculateCardType.samecards = function(self, endPosition, count) 
    self.m_sameCardCount = self.m_sameCardCount + 1;
    self.m_sameCards[self.m_sameCardCount][1] = endPosition - count;--相同牌起始位置索引
    self.m_sameCards[self.m_sameCardCount][2] = count;--相同牌的数量
    if(count == 2) then
        self.m_pairCount = self.m_pairCount + 1;
    elseif(count == 3) then
        self.m_threeCount = self.m_threeCount + 1;
    end
end

CalculateCardType.getCardType = function(self) 
    return self.DISPLAYCARDTYPE;
end

CalculateCardType.getKeyCardArray = function(self) 
    return self.m_keyCards;
end

--/************************上报最佳牌型*********************/

CalculateCardType.setBestPoker = function(self) 
    if not self.m_allCards or #self.m_allCards<7 then
        return
    end
    self.m_currentPokerArr  = {};
    self.m_bestPokerArr     = {};
    for m = 1, 5 do
        if (self:getcolor(self.m_highCards[m]) == 0 or self:getcardvalue(self.m_highCards[m]) == 0) then
            return;
        end
        self.m_currentPokerArr[m] = self.m_highCards[m];
    end
    self.m_currentPokerType = self.DISPLAYCARDTYPE;
    if(g_AccountInfo:getId() == nil) then
        return;
    end
    local bestPokerStr = g_AccountInfo:getBestPoker();
    if ( bestPokerStr and bestPokerStr ~= "0" and bestPokerStr ~= "-1" ) then
        if ( string.sub(bestPokerStr, 1, 1) == "a" ) then
            self.m_bestPokerType = 10;
        else
            self.m_bestPokerType = tonumber(string.sub(bestPokerStr, 1, 1));
        end
        bestPokerStr = string.sub(bestPokerStr, 2, string.len(bestPokerStr));

        for i=1,5 do
            local s = string.sub(bestPokerStr, 2, 2);
            bestPokerStr = string.sub(bestPokerStr, 3, string.len(bestPokerStr));
            if(s == "a") then
                self.m_bestPokerArr[i] = 10;
            elseif(s == "b") then
                self.m_bestPokerArr[i] = 11;
            elseif(s == "c") then
                self.m_bestPokerArr[i] = 12;
            elseif(s == "d") then
                self.m_bestPokerArr[i] = 13;
            elseif(s == "e") then
                self.m_bestPokerArr[i] = 14;
            else
                if s == nil then 
                    s = 0;
                end
                self.m_bestPokerArr[i] = tonumber(s);
            end
        end
    else
        self.m_bestPokerType = 1;
        for j=1,5 do
            self.m_bestPokerArr[j] = 0;
        end
    end

    if self.m_bestPokerType == nil then 
        self.m_bestPokerType = 1;
    end
    
    --小于最佳牌型，不上报
    if self.m_currentPokerType < self.m_bestPokerType then --  or TutorialKit.isTutorial() --新手场过滤zk
        return;
    --大于最佳牌型，上报
    elseif ( self.m_currentPokerType > self.m_bestPokerType ) then
        local cardArr = {};
        for n=1,5 do
            cardArr[n] = string.format("%x", self:getcolor( self.m_currentPokerArr[n] )) .. string.format("%x", self:getcardvalue( self.m_currentPokerArr[n] ));
        end
        self:uploadBestPoker({cardType=self.m_currentPokerType, cards=cardArr})
    --相同的牌型，比较具体大小
    else
        self:cardValueCompare();
    end
end

CalculateCardType.cardValueCompare = function(self) 
    for i=1,5 do
        if ( self:getcardvalue( self.m_currentPokerArr[i] ) > self.m_bestPokerArr[i] ) then
            local cardArr = {};
            for j=1,5 do
                cardArr[j] = string.format("%x", self:getcolor( self.m_currentPokerArr[j] )) .. string.format("%x", self:getcardvalue( self.m_currentPokerArr[j] ));
            end
            self:uploadBestPoker({cardType=self.m_currentPokerType, cards=cardArr})
            break;
        end
    end
end

        
CalculateCardType.uploadBestPoker = function(self, data)
    local valueStr  = string.format("%x", data.cardType);
    for i = 1, 5 do 
        valueStr = valueStr..data.cards[i];
    end
    
    g_AccountInfo:setBestPoker(valueStr)

    --上报给php
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.ROOM_UPLOAD_BEST_CARDTYPE)
    param.bestpoker = valueStr
    g_HttpManager:doPost(param, nil, nil);
end


CalculateCardType.deleteAt = function(t, i)
    local j = i;
    local ret = t[i];
    while(t[j+1]) do
        t[j] = t[j+1];
        j = j + 1;
    end
    t[j] = nil;
    return ret;
end

return CalculateCardType