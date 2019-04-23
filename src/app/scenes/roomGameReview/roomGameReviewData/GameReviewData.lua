local GameReviewBetData = require(".roomGameReviewData.GameReviewBetData")
local GameReviewData = class("GameReviewData");

GameReviewData.ctor = function(self)
    --[Comment]
    -- 0:发前三张牌之前
    -- 1:发flop牌
    -- 2:发turn牌
    -- 3:发river牌
    self.gameStatus = 0;
    self.gameStartTime1 = "";
    self.gameStartTime2 = "";
    self.dealerSeatId = -1;	--庄家座位
    self.selfSeatId = 0;
    self.selfHandCard1 = 0;
    self.selfHandCard2 = 0;
    self.playerList = {};--在玩人数座位列表,数组存放用户信息
    self.beforeFlopOperation = {};
    self.flopCardOperation = {};
    self.turnCardOperation = {};
    self.riverCardOperation = {};
    self.gameOverData = nil;
    self.publicCardArr = {0x0, 0x0, 0x0, 0x0, 0x0};--公共牌数组

    for i=1,9 do
        self.beforeFlopOperation[i] = GameReviewBetData:create();
    end
    for i=1,#self.beforeFlopOperation do
        self.flopCardOperation[i] = GameReviewBetData:create();
    end
    for i=1,#self.beforeFlopOperation do
        self.turnCardOperation[i] = GameReviewBetData:create();
    end
    for i=1,#self.beforeFlopOperation do
        self.riverCardOperation[i] = GameReviewBetData:create();
    end
end

GameReviewData.caculateWinChips = function(self)
    if(self.gameOverData) then
        for k=1,#self.playerList do
            self.playerList[k].isBigWinner = false;
            self.playerList[k].isWin = false;
            self.playerList[k].winChip = 0;
        end
        local arrLength = #self.gameOverData.chipsPotsInfo;
        for i=1,arrLength do
            local winnerArray = self.gameOverData.chipsPotsInfo[i].winner;
            for j=1,#winnerArray do
                local seatId = self.gameOverData.chipsPotsInfo[i].winner[j].seatId;
                for k=1,#self.playerList do
                    if(self.playerList[k].seatId == seatId) then
                        if(i == 1 and j == 1) then
                            self.playerList[k].isBigWinner = true;
                        end
                        self.playerList[k].isWin = true;
                        self.playerList[k].winChip = self.playerList[k].winChip + self.gameOverData.chipsPotsInfo[i].perMoney;
                    end
                end

                if(g_TableLib.isEmpty(self.gameOverData.playerList) and self.gameOverData.chipsPotsInfo[i].winner[j].seatId == self.selfSeatId) then
                    local gameOverPlayerData = {seatId = self.gameOverData.chipsPotsInfo[i].winner[j].seatId, handCard1 = self.selfHandCard1, handCard2 = self.selfHandCard2, cardType = self.gameOverData.chipsPotsInfo[i].winner[j].cardType};
                    self.gameOverData.playerList[#self.gameOverData.playerList+1] = gameOverPlayerData;
                end
            end
        end
        
        for i=1,#self.playerList do
            self.playerList[i].betInChips = 0;
        end

        for i=1,#self.playerList do
            while(true) do
                local id = self.playerList[i].seatId;

                if(not self.playerList[i]) then
                    break;
                end
                self.playerList[i].betInChips = 0;
                if(self.beforeFlopOperation ~= nil and self.beforeFlopOperation[id] ~= nil and #self.beforeFlopOperation[id].gameBetDataVct > 0) then
                    self.playerList[i].betInChips = self.beforeFlopOperation[id].gameBetDataVct[#self.beforeFlopOperation[id].gameBetDataVct] and self.beforeFlopOperation[id].gameBetDataVct[#self.beforeFlopOperation[id].gameBetDataVct].betInChips or 0;
                end
                if(self.flopCardOperation ~= nil and self.flopCardOperation[id] ~= nil and #self.flopCardOperation[id].gameBetDataVct > 0) then
                    self.playerList[i].betInChips = self.playerList[i].betInChips + (self.flopCardOperation[id].gameBetDataVct[#self.flopCardOperation[id].gameBetDataVct] and self.flopCardOperation[id].gameBetDataVct[#self.flopCardOperation[id].gameBetDataVct].betInChips or 0);
                end
                if(self.turnCardOperation ~= nil and self.turnCardOperation[id] ~= nil and #self.turnCardOperation[id].gameBetDataVct > 0) then
                    self.playerList[i].betInChips = self.playerList[i].betInChips + (self.turnCardOperation[id].gameBetDataVct[#self.turnCardOperation[id].gameBetDataVct] and self.turnCardOperation[id].gameBetDataVct[#self.turnCardOperation[id].gameBetDataVct].betInChips or 0);
                end
                if(self.riverCardOperation ~= nil and self.riverCardOperation[id] ~= nil and #self.riverCardOperation[id].gameBetDataVct > 0) then
                    self.playerList[i].betInChips = self.playerList[i].betInChips + (self.riverCardOperation[id].gameBetDataVct[#self.riverCardOperation[id].gameBetDataVct] and self.riverCardOperation[id].gameBetDataVct[#self.riverCardOperation[id].gameBetDataVct].betInChips or 0);
                end
                break;
            end
        end
    end
end
return GameReviewData