
local UserChip = class("UserChip");
local ChipManager
UserChip.TAG = "UserChip";

UserChip.m_quadBatch = nil;
UserChip.m_userSeat = nil;
UserChip.m_popChipInfoV = nil;
UserChip.m_previousBetChipInfoV = nil;
UserChip.m_movingBetChipInfoV = nil;
UserChip.m_betChipInfoV = nil;
UserChip.m_potChipInfoV = nil;
UserChip.m_chipThick = 0;

UserChip.s_enable = true;
local SeatAnim = require("SeatAnim")

UserChip.ctor = function(self, quadBatch, userSeat)
    ChipManager = require("chipManager.ChipManager")
    self.m_quadBatch = quadBatch;
    self.m_userSeat = userSeat;
    self.m_chipThick = ChipManager.CHIP_THICK;
    self:setBetChipStack();
    self.m_flagUpdate = 0;--1=bet, 2=pot, 3=seat
end

UserChip.createTimer = function(self)
    self.m_timer = g_Schedule:schedule(function ()
        self:updateToXXX()
    end, 1/60);
end

UserChip.destroyTimer = function(self)
    g_Schedule:cancel(self.m_timer.eventObj)
end

UserChip.updateToXXX = function(self)
    --    Log.d(UserChip.TAG, "updateToXXX:" .. self.m_flagUpdate);
    if(not UserChip.s_enable) then return; end
    if(self.m_flagUpdate == 1) then
        self:updateToBet();
    elseif(self.m_flagUpdate == 2) then
        self:updateToPot();
    elseif(self.m_flagUpdate == 3) then
        self:updateToSeat();
    end
end

UserChip.setBetChipStack = function(self)
    if(not UserChip.s_enable) then return; end
    if (self.m_betChipInfoV) then
        self.m_quadBatch:removeAllChildren(true)
        local infoLength = #self.m_betChipInfoV;
        for i=1,infoLength do
            local chip = ChipManager:getChip(self.m_betChipInfoV[i].number);
            chip:setPosition(0 , (i-1) * self.m_chipThick);
            self.m_quadBatch:addChild(chip);
        end
    end
end

UserChip.refreshBet = function(self, betChips)
    if(not UserChip.s_enable) then return; end
    --回收筹码数据
    ChipManager:recycleChipInfoV(self.m_betChipInfoV);
    self.m_betChipInfoV = ChipManager:takeOutChipInfos(betChips);
    
    --替换筹码堆
    self:setBetChipStack();
end

UserChip.moveToBet = function(self, operationNeedChips, totalBetInChips, userView, callBack)
    --获取新的筹码数据
    self.m_popChipInfoV = ChipManager:takeOutChipInfos(operationNeedChips);
    self.m_betChipInfoV = ChipManager:takeOutChipInfos(totalBetInChips);
    
    local infoLength = #self.m_popChipInfoV;
    local chips = {}
    for i=1,infoLength do
        local chip = ChipManager:getChip(self.m_popChipInfoV[i].number);
        self.m_quadBatch:getParent():addChild(chip);
        chips[#chips + 1] = chip
        chip:setPosition(userView:getPosition())
        local tx, ty = self.m_quadBatch:getPosition()
        local action = cc.MoveTo:create(ChipManager.POP_CHIP_DURATION + (i-1) * ChipManager.MOVE_DELAY_DURATION, cc.p(tx, ty + (i-1) * self.m_chipThick))
        local actionFunc = cc.CallFunc:create(function ()
            if i == infoLength then
                for _, v in pairs(chips) do
                    v:removeFromParent(true)
                end
                self:setBetChipStack()
                if callBack then
                    callBack()
                end
            end
        end)
        local sequenceAction = cc.Sequence:create(action,actionFunc)
        chip:runAction(sequenceAction)
    end
end

UserChip.setMovingBetChipInfo = function(self)
    if(not UserChip.s_enable) then return; end
    self.m_movingBetChipInfoV = self.m_betChipInfoV;
end

UserChip.isEmpty = function(self)
    return self.m_quadBatch:getChildrenCount() == 0
end

UserChip.moveToPot = function(self, callBack)
    local P = ChipManager.m_potZoneQuadBatchV[1]:getParent():convertToWorldSpace(cc.p(ChipManager.m_potZoneQuadBatchV[1]:getPosition()))
    local tp = self.m_quadBatch:convertToNodeSpace(P)

    local chips = {}
    for _, chip in pairs(self.m_quadBatch:getChildren()) do
        chips[#chips + 1] = chip
    end
	local length = #chips
    if length == 0 then
        callBack()
    end
    for i = #chips, 1, -1 do
	    local chip = chips[i]
	    local action = cc.MoveTo:create(ChipManager.MOVE_POT_DURATION + (i-1) * ChipManager.MOVE_DELAY_DURATION, tp)
	    local actionFunc = cc.CallFunc:create(function ()
		    chip:removeFromParent(true)
		    if i == length then
			    if callBack then
				    callBack()
			    end
		    end
	    end)
	    local sequenceAction = cc.Sequence:create(action,actionFunc)
	    chip:runAction(sequenceAction)
    end
end

UserChip.updateToPot = function(self)
    if(not UserChip.s_enable) then return; end
    self.m_quadBatch:removeAllChildren();
    
    if (self.m_movingBetChipInfoV) then
        local infoLength = #self.m_movingBetChipInfoV;
        for i=1,infoLength do
            if (self.m_movingBetChipInfoV[i].alpha > 0.5) then
                local chip = ChipManager:getChip(self.m_movingBetChipInfoV[i].number);
                local w,h = chip:getSize();
                chip:setPosition(self.m_movingBetChipInfoV[i].x - w/2, self.m_movingBetChipInfoV[i].y - h/2);
                --chip:setOpacity(self.m_movingBetChipInfoV[i].alpha);
                self.m_quadBatch:addChild(chip);
            end
        end
    end
end

UserChip.moveToPotCompleteHandler = function(self)
    if(not UserChip.s_enable) then return; end
    self.m_flagUpdate = 0;
    --    self:destroyTimer();
    self.m_quadBatch:removeAllChildren();
    ChipManager:recycleChipInfoV(self.m_movingBetChipInfoV);
    if (self.m_betChipInfoV == self.m_movingBetChipInfoV) then
        self.m_betChipInfoV = nil;
    end
    self.m_movingBetChipInfoV = nil;
end

UserChip.moveToSeat = function(self, winChips, potId, callBack)
    if(not UserChip.s_enable) then return; end
    --self.m_quadBatch:removeAllChildren();
    
    --回收正在飞行的筹码数据
    --ChipManager:recycleChipInfoV(self.m_potChipInfoV);
    
    --获取新的筹码数据
    self.m_potChipInfoV = ChipManager:takeOutChipInfos(winChips);
    local infoLength = #self.m_potChipInfoV;
--[[    for i=1,infoLength do
        local x,y = ChipManager.m_potZoneQuadBatchV[potId]:getPos();
        y = y - 1 * self.m_chipThick;
        x,y = self.m_quadBatch:convertSurfacePointToView(x, y);
        self.m_potChipInfoV[i].x = x;
        self.m_potChipInfoV[i].y = y;
    end]]
    
    for i=infoLength,1,-1 do
        local chip = ChipManager:getChip(self.m_potChipInfoV[i].number)
        local action = cc.MoveTo:create(ChipManager.MOVE_POT_DURATION + (i-1) * ChipManager.MOVE_DELAY_DURATION, tp)
        local actionFunc = cc.CallFunc:create(function ()
            chip:removeFromParent(true)
            if i == infoLength then
                if callBack then
                    callBack()
                end
            end
        end)
        local sequenceAction = cc.Sequence:create(action,actionFunc)
        chip:runAction(sequenceAction)
--[[        local x = SeatManager.m_seatPositionV[self.m_userSeat.m_positionId].x + UserSeat.SEAT_WIDTH * 0.5;
        local y = SeatManager.m_seatPositionV[self.m_userSeat.m_positionId].y + UserSeat.SEAT_HEIGHT * 0.5;
        x,y = self.m_quadBatch:convertSurfacePointToView(x, y);
        
        local lpfnComplete = nil;
        if(i == 1) then
            lpfnComplete = self.moveToSeatCompleteHandler;
        end
        AnimKit.tweenTo(self.m_potChipInfoV[i], ChipManager.MOVE_POT_DURATION * 1000,
                {
                    delay = (infoLength - i) * ChipManager.MOVE_DELAY_DURATION * 1000,
                    alpha = 0.5,
                    x = x,
                    y = y,
                    onComplete = lpfnComplete,
                    obj= self,
                });]]
    end
    --self.m_flagUpdate = 3;
    --self:createTimer();
end

UserChip.updateToSeat = function(self)
    if(not UserChip.s_enable) then return; end
    self.m_quadBatch:removeAllChildren();
    local infoLength = self.m_potChipInfoV and #self.m_potChipInfoV or 0;
    for i=1,infoLength do
        if (self.m_potChipInfoV[i].alpha > 0.5) then
            local chip = ChipManager:getChip(self.m_potChipInfoV[i].number);
            local w,h = chip:getSize();
            chip:setPosition(self.m_potChipInfoV[i].x - w/2, self.m_potChipInfoV[i].y - h/2);
            --chip:setOpacity(self.m_potChipInfoV[i].alpha);
            self.m_quadBatch:addChild(chip);
        end
    end
end

UserChip.moveToSeatCompleteHandler = function(self)
    if(not UserChip.s_enable) then return; end
    self.m_flagUpdate = 0;
    --    self:destroyTimer();
    ChipManager:recycleChipInfoV(self.m_potChipInfoV);
    self.m_potChipInfoV = nil;
    self.m_quadBatch:removeAllChildren();
end

UserChip.refresh = function(self)
    if(not UserChip.s_enable) then return; end
    ChipManager:recycleChipInfoV(self.m_potChipInfoV);
    self.m_potChipInfoV = nil;
    ChipManager:recycleChipInfoV(self.m_betChipInfoV);
    self.m_betChipInfoV = nil;
    ChipManager:recycleChipInfoV(self.m_previousBetChipInfoV);
    self.m_previousBetChipInfoV = nil;
    ChipManager:recycleChipInfoV(self.m_movingBetChipInfoV);
    self.m_movingBetChipInfoV = nil;
    ChipManager:recycleChipInfoV(self.m_popChipInfoV);
    self.m_popChipInfoV = nil;
    
    self.m_quadBatch:removeAllChildren();
    self.m_flagUpdate = 0;
    self:destroyTimer();
end
return UserChip