
local GameReviewDataManager = class("GameReviewDataManager")
GameReviewDataManager.MAX_DATA_COUNT = 16

function GameReviewDataManager:ctor()
    self.m_gameReviewVct = {}
    self.m_publicCardArr = {0x0, 0x0, 0x0, 0x0, 0x0}
end

function GameReviewDataManager:getInstance()
	if not GameReviewDataManager.s_instance then
		GameReviewDataManager.s_instance = GameReviewDataManager:create()
	end
	return GameReviewDataManager.s_instance
end

function GameReviewDataManager:gameStartDataDeal(data)
    if g_TableLib.isEmpty(data) then
        return
    end
    for k, v in pairs(data:getPlayerList()) do
        local SeatManager = import("app.scenes.normalRoom").SeatManager.getInstance()
		local userSeat = SeatManager:getSeat(k);
		if userSeat ~= nil and userSeat:isSelf() then
            -- 牌局回顾数据
            if g_FeatureConfig.STR_ROOM_GAME_REVIEW_POP_UP_IS_OPEN then
                self.gameReviewDataOpen = true
                local GameReviewData = require(".roomGameReviewData.GameReviewData")
                self.gameReviewData = GameReviewData:create()
                local date = os.date("*t")
                self.gameReviewData.gameStartTime1 = string.format("%d-%d-%d", date.year, date.month, date.day);
                self.gameReviewData.gameStartTime2 = string.format("%d:%02d", date.hour, date.min);
                self.gameReviewData.dealerSeatId = data:getDealerSeatId();
                self.gameReviewData.selfSeatId = userSeat:getSeatId();
                self.gameReviewData.selfHandCard1 = data:getHandCard()[1];
                self.gameReviewData.selfHandCard2 = data:getHandCard()[2];
            end
		end
	end
	if self.gameReviewData and self.gameReviewDataOpen then
        for k, v in pairs(data:getPlayerList()) do
            local SeatManager = import("app.scenes.normalRoom").SeatManager.getInstance()
            local userSeat = SeatManager:getSeat(k);
            if userSeat ~= nil and not g_TableLib.isEmpty(userSeat) then
                local GameReviewPlayerListData = require(".roomGameReviewData.GameReviewPlayerListData")
                local playerData = GameReviewPlayerListData:create();
                playerData.name = userSeat:getSeatData().name;
                playerData.seatId = userSeat:getSeatData().seatId;
                playerData.uid = userSeat:getSeatData().uid;
                playerData.seatChips = userSeat:getSeatData().seatChips;
                table.insert(self.gameReviewData.playerList, playerData);
            end
        end
    end
end

function GameReviewDataManager:operationResultDataDeal(data)
    if g_TableLib.isEmpty(data) then
        return
    end
    if(self.gameReviewDataOpen) then
        local OperationResultData = require(".roomGameReviewData.OperationResultData")
        local operationdata = OperationResultData:create();
        operationdata.betInChips = data.betInChips;
        operationdata.operationType = data.operationStatus;
        operationdata.seatId = data.seatId;
        if(self.gameReviewData.gameStatus == 0) then
            table.insert(self.gameReviewData.beforeFlopOperation[data.seatId].gameBetDataVct, operationdata);
        elseif(self.gameReviewData.gameStatus == 1) then
            table.insert(self.gameReviewData.flopCardOperation[data.seatId].gameBetDataVct, operationdata);
        elseif(self.gameReviewData.gameStatus == 2) then
            table.insert(self.gameReviewData.turnCardOperation[data.seatId].gameBetDataVct, operationdata);
        elseif(self.gameReviewData.gameStatus == 3) then
            table.insert(self.gameReviewData.riverCardOperation[data.seatId].gameBetDataVct, operationdata);
        end
    end
end


function GameReviewDataManager:GameOverDataDeal(data)
    -- Log.d("jf==========GameReviewDataManager:GameOverDataDeal", data)
    self:refresh()
    if g_TableLib.isEmpty(data) then
        return
    end
    --牌局回顾数据
    if(self.gameReviewDataOpen and g_FeatureConfig.STR_ROOM_GAME_REVIEW_POP_UP_IS_OPEN) then
        self.gameReviewData.gameOverData = g_TableLib.copyTab(data);
        -- self.gameReviewData.publicCardArr = self.m_publicCardArr;
        self.gameReviewData:caculateWinChips();
        if(#self.m_gameReviewVct >= GameReviewDataManager.MAX_DATA_COUNT) then--最多存16局
            table.remove(self.m_gameReviewVct, 1);
        end
        table.insert(self.m_gameReviewVct, self.gameReviewData);
        self.gameReviewDataOpen = false;
    end
end

function GameReviewDataManager:cardHandleDataDeal(index, data)

    if index == 3 then
        self.m_publicCardArr[1] = data[1];
        self.m_publicCardArr[2] = data[2];
        self.m_publicCardArr[3] = data[3];
    end
    if index == 4 then
        self.m_publicCardArr[4] = data[4];
    end
    if index == 5 then
        self.m_publicCardArr[5] = data[5];
    end
    if(self.gameReviewDataOpen) then
		self.gameReviewData.publicCardArr = g_TableLib.copyTab(self.m_publicCardArr);
        self.gameReviewData.gameStatus = index - 2;
    end
end

function GameReviewDataManager:getData()
    return self.m_gameReviewVct
end

function GameReviewDataManager:refresh()
    self.m_publicCardArr = {0x0, 0x0, 0x0, 0x0, 0x0}
end

function GameReviewDataManager:clear()
    self.m_gameReviewVct = {}
    self.m_publicCardArr = {0x0, 0x0, 0x0, 0x0, 0x0}
end


return GameReviewDataManager
