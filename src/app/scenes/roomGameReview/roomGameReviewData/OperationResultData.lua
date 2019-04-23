--[Comment]
--打牌操作数据
local OperationResultData = class("OperationResultData");

OperationResultData.SEAT_WAIT       = 0; --等待下一轮
OperationResultData.SEAT_READY      = 1; --等待下注
OperationResultData.SEAT_FOLD       = 2; --弃牌
OperationResultData.SEAT_ALLIN      = 3; --ALL IN
OperationResultData.SEAT_CALL       = 4; --跟注
OperationResultData.SEAT_SMALLBLIND = 5; --小盲
OperationResultData.SEAT_BIGBLIND   = 6; --大盲
OperationResultData.SEAT_CHECK      = 7; --看牌
OperationResultData.SEAT_RAISE      = 8; --加注
OperationResultData.MUST_RAISE      = 9; --打必场必下注

OperationResultData.ctor = function(self)
    self.seatId          = -1;--下注玩家的作为ID
    self.operationType   = -1;--下注的类型
    self.betInChips      = 0; --下注的筹码数
end

OperationResultData.dtor = function(self)
end

OperationResultData.operationResultMap = {
    [OperationResultData.SEAT_WAIT]       = "--等待下一轮";
    [OperationResultData.SEAT_READY]      = "--等待下注";
    [OperationResultData.SEAT_FOLD]       = "--弃牌";
    [OperationResultData.SEAT_ALLIN]      = "--ALL IN";
    [OperationResultData.SEAT_CALL]       = "--跟注";
    [OperationResultData.SEAT_SMALLBLIND] = "--小盲";
    [OperationResultData.SEAT_BIGBLIND]   = "--大盲";
    [OperationResultData.SEAT_CHECK]      = "--看牌";
    [OperationResultData.SEAT_RAISE]      = "--加注";
    [OperationResultData.MUST_RAISE]      = "--打必场必下注";

}
return OperationResultData