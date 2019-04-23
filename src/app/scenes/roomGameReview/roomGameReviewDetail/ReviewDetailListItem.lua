--[[--ldoc desc
@module RoomGameReviewDetailListItem
@author JamesLiang

Date   2018/12/21
]]
local ListItemTextMsg = require(".roomGameReviewDetail.ListItemTextMsg")
local ReviewDetailListItem  = class("ReviewDetailListItem",cc.Node)

function ReviewDetailListItem:ctor(data, width, height)
    self.m_data = data
    -- self.m_width = width
    -- self.m_height = height
    -- self:setContentSize(self.m_width, self.m_height)
    self:init()
    self:updateView(data)
end

function ReviewDetailListItem:init()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/roomGameReview/reviewDetailListItem.ccreator')
    local cont = self.m_root:getContentSize()
    self:addChild(self.m_root)
    self:setContentSize(self.m_root:getContentSize())
    self.m_width = self.m_root:getContentSize().width
    self.m_height = self.m_root:getContentSize().height
    self.m_root:setPosition(self.m_width/2, self.m_height/2)
    self.m_nameLabel = g_NodeUtils:seekNodeByName(self.m_root,"name_label")

    self.m_winMoneyLabel = g_NodeUtils:seekNodeByName(self.m_root,"winMoney_label")
    self.m_loseMoney_label = g_NodeUtils:seekNodeByName(self.m_root,"loseMoney_label")
    self.m_winnerIcon = g_NodeUtils:seekNodeByName(self.m_root,"winnerIcon")
    self.m_winnerIcon:setVisible(false)
    self.m_winMoneyLabel:setVisible(false)
    self.m_loseMoney_label:setVisible(false)
    self.m_handCards = g_NodeUtils:seekNodeByName(self.m_root,"handCards")
    self.m_handCardsChip = g_NodeUtils:seekNodeByName(self.m_root,"handCards_chip")
    self.m_publicCardsChip = g_NodeUtils:seekNodeByName(self.m_root,"publicCards_chip")
    self.m_turnCardsChip = g_NodeUtils:seekNodeByName(self.m_root,"turnCards_chip")
    self.m_riverCardsChip = g_NodeUtils:seekNodeByName(self.m_root,"riverCards_chip")

    self.handCards_chip_label = g_NodeUtils:seekNodeByName(self.m_root,"handCards_chip_label")
    self.publicCards_chip_label = g_NodeUtils:seekNodeByName(self.m_root,"publicCards_chip_label")
    self.turnCards_chip_label = g_NodeUtils:seekNodeByName(self.m_root,"turnCards_chip_label")
    self.riverCards_chip_label = g_NodeUtils:seekNodeByName(self.m_root,"riverCards_chip_label")

    self.handCards_chip_label:setVisible(false)
    self.publicCards_chip_label:setVisible(false)
    self.turnCards_chip_label:setVisible(false)
    self.riverCards_chip_label:setVisible(false)

    self.m_handCard1 = g_PokerCard:create()
    self.m_handCard1:setAnchorPoint(cc.p(0,0))
    self.m_handCard1:setScale(0.5)
    self.m_handCard1:setPosition(40, 13) 
    self.m_handCard1:showBack()
    self.m_handCards:addChild(self.m_handCard1)

    self.m_handCard2 = g_PokerCard:create()
    self.m_handCard2:setAnchorPoint(cc.p(0,0))
    self.m_handCard2:setScale(0.5)
    self.m_handCard2:setPosition(67, 13) 
    self.m_handCard2:showBack()
    self.m_handCards:addChild(self.m_handCard2)
    
    self.m_handsChipScrolText =  ListItemTextMsg:create("", 148, 84)
    self.m_publicChipScrolText  = ListItemTextMsg:create("", 148, 84)
    self.m_turnChipScrolText = ListItemTextMsg:create("", 148, 84)
    self.m_riverChipScrolText = ListItemTextMsg:create("", 148, 84)

    self.m_handCardsChip:addChild(self.m_handsChipScrolText)
    self.m_publicCardsChip:addChild(self.m_publicChipScrolText)
    self.m_turnCardsChip:addChild(self.m_turnChipScrolText)
    self.m_riverCardsChip:addChild(self.m_riverChipScrolText)
    local posx, posy = self.m_handCardsChip:getPosition()
    print("m_handsChipScrolText", posx, posy)
end

function ReviewDetailListItem:updateView(data)
    self.m_winMoneyLabel:setVisible(false)
    self.m_loseMoney_label:setVisible(false)
    if data then
	local userNameSize = self.m_nameLabel:getContentSize()
	self.m_nameLabel:setString(g_StringLib.limitLength(data.name,24,userNameSize.width))
        if(data.isWin) then
            self.m_winnerIcon:setVisible(true);
            self.m_winMoneyLabel:setString("+" .. string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.winChip))) 
            self.m_winnerIcon:setScale(1.0, 1.0)
            if(data.isBigWinner) then
                self.m_winnerIcon:setScale(1.0, 1.0)
            else
                self.m_winnerIcon:setScale(0.7, 0.7)
            end
            self.m_winMoneyLabel:setVisible(true)
        else
            self.m_loseMoney_label:setVisible(true)
            self.m_winnerIcon:setVisible(false);
            self.m_loseMoney_label:setString("-" .. string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.betInChips)))
        end
        --jf  textview 设置数据
        -- 手牌下注
        local str1 = "";
        for i = 1, #data.beforeFlopOperation[data.seatId].gameBetDataVct do
            local oprType = data.beforeFlopOperation[data.seatId].gameBetDataVct[i].operationType
            local text = ""
            if(oprType ==   ReviewDetailListItem.SEAT_WAIT) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[1];--"等待下一轮";
            elseif(oprType ==   ReviewDetailListItem.SEAT_READY) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[2];--"等待下注";
            elseif(oprType ==   ReviewDetailListItem.SEAT_FOLD) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[3];--"弃牌";
            elseif(oprType ==   ReviewDetailListItem.SEAT_ALLIN) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[4] .. g_MoneyUtil.formatMoney(tostring(i <= 1 and data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips or data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips - data.beforeFlopOperation[data.seatId].gameBetDataVct[i - 1].betInChips))
            elseif(oprType ==   ReviewDetailListItem.SEAT_CALL) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[5] .. g_MoneyUtil.formatMoney(tostring(i <= 1 and data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips or data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips - data.beforeFlopOperation[data.seatId].gameBetDataVct[i - 1].betInChips))
            elseif(oprType ==   ReviewDetailListItem.SEAT_SMALLBLIND) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[6] .. g_MoneyUtil.formatMoney(data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips)
            elseif(oprType ==   ReviewDetailListItem.SEAT_BIGBLIND) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[7] .. g_MoneyUtil.formatMoney(data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips)
            elseif(oprType ==   ReviewDetailListItem.SEAT_CHECK) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[8];
            elseif(oprType ==   ReviewDetailListItem.SEAT_RAISE) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[9] .. g_MoneyUtil.formatMoney(tostring(i <= 1 and data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips or data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips - data.beforeFlopOperation[data.seatId].gameBetDataVct[i - 1].betInChips))
            elseif(oprType ==   ReviewDetailListItem.MUST_RAISE) then
                text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[5] .. g_MoneyUtil.formatMoney(data.beforeFlopOperation[data.seatId].gameBetDataVct[i].betInChips)
            end
            if str1 == "" then
                str1 = text;
            else
                str1 = str1 .. "\n" .. text;
            end
        end
        self.m_handsChipScrolText:updateView(str1);

        -- 公共牌下注
        local flopCardOperationData = data.flopCardOperation[data.seatId]
        local dataString1 =  self:dealData(flopCardOperationData)
        self.m_publicChipScrolText:updateView(dataString1);

        -- 转牌下注
        local turnCardOperationData =  data.turnCardOperation[data.seatId]
        local dataString2 =  self:dealData(turnCardOperationData)
        self.m_turnChipScrolText:updateView(dataString2);

        -- 河牌下注
        local riverCardOperationData =  data.riverCardOperation[data.seatId]
        local dataString3 =  self:dealData(riverCardOperationData)
        self.m_riverChipScrolText:updateView(dataString3)

        --玩家手牌
        self.m_handCard1:showBack()
        self.m_handCard2:showBack()
        for k, v in pairs(data.gameOverData.playerList) do
            if data.gameOverData.playerList[k].seatId == data.seatId then
                self.m_handCard1:setCard(data.gameOverData.playerList[k].handCard1)
                self.m_handCard1:showCard()
                self.m_handCard2:setCard(data.gameOverData.playerList[k].handCard2)
                self.m_handCard2:showCard()
            end
        end
        if data.seatId == data.selfSeatId then
            self.m_handCard1:setCard(data.selfCard1);
            self.m_handCard1:showCard();
            self.m_handCard2:setCard(data.selfCard2);
            self.m_handCard2:showCard();
        end

    end
end

function ReviewDetailListItem:dealData(data)
    local str = ""
    for i = 1, #data.gameBetDataVct do
        local dataTem = data.gameBetDataVct[i]
        local oprType = dataTem.operationType;
        local text = "";
        if(oprType ==   ReviewDetailListItem.SEAT_WAIT) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[1];--"等待下一轮";
        elseif(oprType ==   ReviewDetailListItem.SEAT_READY) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[2];--"等待下注";
        elseif(oprType ==   ReviewDetailListItem.SEAT_FOLD) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[3];--"弃牌";
        elseif(oprType ==   ReviewDetailListItem.SEAT_ALLIN) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[4] .. g_MoneyUtil.formatMoney(dataTem.betInChips)
        elseif(oprType ==   ReviewDetailListItem.SEAT_CALL) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[5] .. g_MoneyUtil.formatMoney(dataTem.betInChips)
        elseif(oprType ==   ReviewDetailListItem.SEAT_SMALLBLIND) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[6] .. g_MoneyUtil.formatMoney(dataTem.betInChips)
        elseif(oprType ==   ReviewDetailListItem.SEAT_BIGBLIND) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[7] .. g_MoneyUtil.formatMoney(dataTem.betInChips)
        elseif(oprType ==   ReviewDetailListItem.SEAT_CHECK) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[8];
        elseif(oprType ==   ReviewDetailListItem.SEAT_RAISE) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[9] .. g_MoneyUtil.formatMoney(dataTem.betInChips)
        elseif(oprType ==   ReviewDetailListItem.MUST_RAISE) then
            text =  ReviewDetailListItem.STR_ROOM_OPERATION_TYPE[5] .. g_MoneyUtil.formatMoney(dataTem.betInChips)
        end
        if str == "" then
            str = text;
        else
            str = str .. "\n" .. text;
        end
    end
    return  str

end

ReviewDetailListItem.STR_ROOM_OPERATION_TYPE = { --操作類型
	[1] = GameString.get("str_room_operation_type_0");
	[2] = GameString.get("str_room_operation_type_1");
	[3] = GameString.get("str_room_operation_type_2");
	[4] = GameString.get("str_room_operation_type_3");
	[5] = GameString.get("str_room_operation_type_4");
	[6] = GameString.get("str_room_operation_type_5");
	[7] = GameString.get("str_room_operation_type_6");
	[8] = GameString.get("str_room_operation_type_7");
	[9] = GameString.get("str_room_operation_type_8");
    [10] =GameString.get("str_room_operation_type_9");
}
ReviewDetailListItem.SEAT_WAIT       = 0; --等待下一轮
ReviewDetailListItem.SEAT_READY      = 1; --等待下注
ReviewDetailListItem.SEAT_FOLD       = 2; --弃牌
ReviewDetailListItem.SEAT_ALLIN      = 3; --ALL IN
ReviewDetailListItem.SEAT_CALL       = 4; --跟注
ReviewDetailListItem.SEAT_SMALLBLIND = 5; --小盲
ReviewDetailListItem.SEAT_BIGBLIND   = 6; --大盲
ReviewDetailListItem.SEAT_CHECK      = 7; --看牌
ReviewDetailListItem.SEAT_RAISE      = 8; --加注
ReviewDetailListItem.MUST_RAISE      = 9; --打必场必下注

return ReviewDetailListItem
