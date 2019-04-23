--[[--ldoc desc
@module RoomGameReviewDetail
@author JamesLiang

Date   2019/01/04
]]

local GameReviewSeatview = require("roomGameReviewPop.GameReviewSeatview")
local GameReviewTable  = class("GameReviewTable",cc.Node)

function GameReviewTable:ctor()
    self.m_reviewSeatview = {}
    self.m_seatNodeAll = {}
    self.m_publicCardV = {}
    self:initScene()
    self:creatSeatView()
    self:createPublicCards()
end

function GameReviewTable:initScene()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/roomGameReview/roomGameReviewTable.ccreator')
    local rootSize = self.m_root:getContentSize()
    self.m_width = rootSize.width
    self.m_height = rootSize.height
    self:setContentSize(rootSize)
    self:addChild(self.m_root)
    self.m_root:setPosition(cc.p(self.m_width/2, self.m_height/2))

    self.m_timeBg = g_NodeUtils:seekNodeByName(self.m_root,"time_bg")
    self.m_day = g_NodeUtils:seekNodeByName(self.m_root,"day")
    self.m_hour = g_NodeUtils:seekNodeByName(self.m_root,"hour")
    self.m_publicCardBg = g_NodeUtils:seekNodeByName(self.m_root,"publicCard_bg")

    for i = 1, 9 do
        local seatNodeName = "seat"..i
        local seatNode = g_NodeUtils:seekNodeByName(self.m_root,seatNodeName)
        self.m_seatNodeAll[i] = seatNode
    end
end

function GameReviewTable:creatSeatView()
    self.m_reviewSeatview = {}
    for i = 1, 9 do
        self.m_reviewSeatview[i] = GameReviewSeatview:create(i)
        self.m_reviewSeatview[i]:setSeatId(i)
        -- reviewSeatview:setPosition(cc.p(size.width/2, size.height/2))
        local size = self.m_seatNodeAll[i]:getContentSize()
        self.m_seatNodeAll[i]:addChild(self.m_reviewSeatview[i])
        self.m_reviewSeatview[i]:setPosition(cc.p(size.width/2, size.height/2))
        self.m_reviewSeatview[i]:setVisible(false)
    end
end

function GameReviewTable:createPublicCards()
    for i = 1, 5 do
        self.m_publicCardV[i] = g_PokerCard:create()
        self.m_publicCardV[i]:setScale(0.6)
        self.m_publicCardV[i]:setVisible(false)
        self.m_publicCardV[i]:showBack()
        self.m_publicCardV[i]:setPosition(((i-1) * (g_PokerCard.CARD_WIDTH + 8) + g_PokerCard.CARD_WIDTH/2) *0.6 , 0.6*g_PokerCard.CARD_HEIGHT/2)
        self.m_publicCardBg:addChild(self.m_publicCardV[i])
    end
end

function GameReviewTable:updateView(data)
    --更新公共牌数据
    self:reset()
    if data.publicCardArr and #data.publicCardArr > 0 then
        for i = 1, #data.publicCardArr do
            if data.publicCardArr[i] ~= 0 then
                self.m_publicCardV[i]:setCard(data.publicCardArr[i])
                self.m_publicCardV[i]:showCard(data.publicCardArr[i])
                
            end
        end
    end
    --显示高亮牌
    if #data.gameOverData.chipsPotsInfo > 0 then
        for i = 1, 5 do
            local card = "card"..i
            local cardData =  data.gameOverData.chipsPotsInfo[1].winner[1][card]
            local value   = bit.band(cardData, 0xFF);
            local variety = bit.rshift(cardData, 8);
            for i = 1, 5 do
                if(self.m_publicCardV[i].m_cardValue == value and self.m_publicCardV[i].m_cardType == variety) then
                    self.m_publicCardV[i]:showHighLight();
                    break;
                end
            end
        end
    end

    --更新时间
    self.m_day:setString(tostring(data.gameStartTime1))
    self.m_hour:setString(tostring(data.gameStartTime2))
    
    -- 刷新位置数据
    -- local dis = 5 - data.selfSeatId;
    -- local index = (self.m_data.playerList[i].seatId - 1 + dis + 9) % 9 + 1 -- 根据seatId 得到界面上的位置
    -- local index = (da - 1 + dis + 9) % 9 + 1 -- 根据seatId 得到界面上的位置
    -- local index = (data.playerList[i].seatId - 1 + dis + 9)%9 + 1


    for i = 1, 9 do
        self.m_reviewSeatview[i]:setVisible(false)
        self.m_reviewSeatview[i]:reset()
    end

    local len1 = #data.playerList
    local len2 = #data.gameOverData.playerList
    local selfId = data.selfSeatId
    for i = 1, len1 do
        if data.playerList[i] then
            local seatId = data.playerList[i].seatId
            local dis = 5 - selfId
            local index = (data.playerList[i].seatId - 1 + dis + 9) % 9 + 1
            self.m_reviewSeatview[index]:setVisible(true)
            self.m_reviewSeatview[index]:setName(data.playerList[i].name or "")
            if data.playerList[i].isWin then
                self.m_reviewSeatview[index]:showCardResult(false)
            end
            for k, v in pairs(data.gameOverData.playerList) do
                local player = data.gameOverData.playerList[k]
                local gameoverSeatId = data.gameOverData.playerList[k].seatId
                if player and gameoverSeatId == seatId then
                    --手牌数据更新
                    self.m_reviewSeatview[index]:updateView(data.gameOverData.playerList[k])
                    if not data.playerList[i].isWin then
                        self.m_reviewSeatview[index]:showFadeCard()
                    end

                    --牌型数据更新
                    if data.gameOverData.playerList[k].cardType>0 and data.gameOverData.playerList[k].cardType<11 then
                        self.m_reviewSeatview[index]:showCardResult(true, data.gameOverData.playerList[k].cardType)
                    else
                        self.m_reviewSeatview[index]:showCardResult(false)
                    end
                end
            end

            if(data.playerList[i].seatId == data.selfSeatId and not data.playerList[i].isWin) then
                local dataTemp = {}
                dataTemp.handCard1 = data.selfHandCard1
                dataTemp.handCard2 = data.selfHandCard2
                self.m_reviewSeatview[index]:updateView(dataTemp)
                self.m_reviewSeatview[index]:showFadeCard()
            end

            --刷新输赢状态
            if data.playerList[i].isWin then
                if data.playerList[i].isBigWinner then
                    self.m_reviewSeatview[index]:showHighLight(data.gameOverData.chipsPotsInfo[1].winner[1])
                end
                self.m_reviewSeatview[index]:setWinAndWinchip(true, data.playerList[i].winChip)
            else
                self.m_reviewSeatview[index]:setWinAndWinchip(false, data.playerList[i].betInChips)
            end




        end
    end
end


function GameReviewTable:reset()
    for i = 1, 5 do
        -- self.m_publicCardV[i]:setVisible(false)
        self.m_publicCardV[i]:removeCardOverlay()
        self.m_publicCardV[i]:refresh()
    end
end


return  GameReviewTable