local UserChip = require("chipManager.UserChip")
local PotChip = require("chipManager.PotChip")
local BetInZone = require("chipManager.BetInZone")

local ChipManager = class("ChipManager");
local SeatManager = require(".SeatManager"):getInstance()

ChipManager.CHIP_THICK = 4;--每个筹码的厚度
ChipManager.POP_CHIP_DURATION = 0.2;--下注筹码动画时间
ChipManager.MOVE_DELAY_DURATION = 0.03;--筹码飞行间隔时间
ChipManager.MOVE_POT_DURATION = 0.5;--移动奖池动画时间
ChipManager.SPLIT_POTS_DURATION = 2;--单个奖池分奖池时间

ChipManager.CARD_TYPE_KEY = {"highCard", "onePair", "twoPair", "threeKind", "straight", "flush", "fullHouse", "fourKind", "straightFlush", "royalFlush"};
ChipManager.m_stageWidth = 0;
ChipManager.m_quadBatchOffsetY = 0;
ChipManager.m_container = nil;
ChipManager.m_userChipV = {};
ChipManager.m_betZoneSpriteV = {};
ChipManager.m_betZoneQuadBatchV = {};
ChipManager.m_potChipV = {};
ChipManager.m_potZoneSpriteV = {};
ChipManager.m_potZoneQuadBatchV = {};
ChipManager.m_chip1 = nil;--1号筹码，黑色，数值1，奇数位
ChipManager.m_chip2 = nil;--2号筹码，黄色，数值1，偶数位
ChipManager.m_chip3 = nil;--3号筹码，蓝色，数值2，奇数位
ChipManager.m_chip4 = nil;--4号筹码，紫色，数值2，偶数位
ChipManager.m_chip5 = nil;--5号筹码，红色，数值5，奇数位
ChipManager.m_chip6 = nil;--6号筹码，绿色，数值5，偶数位
ChipManager.m_chipInfoPool = nil;
ChipManager.m_dealPoolId = 0;--当前正在处理的奖池id

ChipManager.initialize = function(self, node)
    self.m_quadBatchOffsetY = 30;
    
    self.m_container = node
    self.m_container:setLocalZOrder(1)
    --加注筹码显示区
    self.m_userChipV = {};
    self.m_betZoneSpriteV = {};
    self.m_betZoneQuadBatchV = {};
    
    for i=1,9 do
        self.m_betZoneSpriteV[i] = BetInZone.new("y")--与位置id相关 下注筹码数
        self.m_betZoneSpriteV[i]:setVisible(false);
	    local x, y = g_NodeUtils:seekNodeByName(self.m_container, "betChip" .. i):getPosition()
        self.m_betZoneSpriteV[i]:setPosition(x, y);
        self.m_container:addChild(self.m_betZoneSpriteV[i]);
        
        self.m_betZoneQuadBatchV[i] = cc.Node:create()--与座位id相关      下注一堆筹码图片
        self.m_betZoneQuadBatchV[i]:setPosition(x, y + self.m_quadBatchOffsetY);
        self.m_container:addChild(self.m_betZoneQuadBatchV[i]);
        
        self.m_userChipV[i] = UserChip.new(self.m_betZoneQuadBatchV[i])
    end
    
    --奖池筹码显示区
    self.m_potChipV = {};
    self.m_potZoneSpriteV = {};
    self.m_potZoneQuadBatchV = {};
    for i=1,9 do
        self.m_potZoneSpriteV[i] = BetInZone.new("y")--与位置id相关
        self.m_potZoneSpriteV[i]:setVisible(false);
	    local x, y = g_NodeUtils:seekNodeByName(self.m_container, "potChip" .. i):getPosition()
        self.m_potZoneSpriteV[i]:setPosition(x, y);
        self.m_container:addChild(self.m_potZoneSpriteV[i]);
    end
    
    for i=9,1,-1 do
        self.m_potZoneQuadBatchV[i] = cc.Node:create()--与位置id相关
	    local x, y = g_NodeUtils:seekNodeByName(self.m_container, "potChip" .. i):getPosition()
        self.m_potZoneQuadBatchV[i]:setPosition(x, y + self.m_quadBatchOffsetY);
        self.m_container:addChild(self.m_potZoneQuadBatchV[i]);
        
        self.m_potChipV[i] = PotChip.new(self.m_potZoneQuadBatchV[i])
    end
    
    --初始化筹码对象池，改变注册点
    self.m_chip1 = "creator/normalRoom/img/pos/room_chip_odd_1.png";
    self.m_chip2 = "creator/normalRoom/img/pos/room_chip_even_1.png";
    self.m_chip3 = "creator/normalRoom/img/pos/room_chip_odd_2.png";
    self.m_chip4 = "creator/normalRoom/img/pos/room_chip_even_2.png";
    self.m_chip5 = "creator/normalRoom/img/pos/room_chip_odd_5.png";
    self.m_chip6 = "creator/normalRoom/img/pos/room_chip_even_5.png";
    
    self.m_animSequence = {}
    self.m_playIndex = 1
    self.m_addIndex = 1
    self.moving = false
end

ChipManager.takeOutChipInfos = function(self, value)
    local chipInfoV = {};
    local chipStr = tostring(value);
    local chipLen = string.len(chipStr);
    for i=1,chipLen do
        local number = tonumber(string.sub(chipStr, i, i));
        if number ~= nil then
            local oddOrEven = (chipLen - i) % 2 == 1 and "even" or "odd";
            if (number >= 5) then
                chipInfoV[#chipInfoV+1] = self:retriveChipInfo(5, oddOrEven);
                number = number - 5;
            end
            while (number >= 2) do
                chipInfoV[#chipInfoV+1] = self:retriveChipInfo(2, oddOrEven);
                number = number - 2;
            end
            if (number == 1) then
                chipInfoV[#chipInfoV+1] = self:retriveChipInfo(1, oddOrEven);
            end
        end
    end
    return chipInfoV;
end

ChipManager.retriveChipInfo = function(self, number, oddOrEven)
    local ChipInfo = require("chipManager.ChipInfo")
    local chip = ChipInfo.new()
    if(number == 1) then
        if (oddOrEven == "odd") then
            chip.number = 1;
        else
            chip.number = 2;
        end
    elseif(number == 2) then
        if (oddOrEven == "odd") then
            chip.number = 3;
        else
            chip.number = 4;
        end
    elseif(number == 5) then
        if (oddOrEven == "odd") then
            chip.number = 5;
        else
            chip.number = 6;
        end
    end
    return chip;
end

ChipManager.getChip = function(self, number)
    local filename = self["m_chip" .. number];
    if(filename == nil) then
        filename = self.m_chip1;
    end
    local image = cc.Sprite:create(filename)
    return image;
end

ChipManager.recycleChipInfoV = function(self, chipInfoV)
    if (chipInfoV) then
        local infoLength = #chipInfoV;
        for i=1,infoLength do
            chipInfoV[i].x = 0;
            chipInfoV[i].y = 0;
            chipInfoV[i].alpha = 1;
        end
        chipInfoV = nil;
    end
end

ChipManager.onLoginRoomSuccess = function(self, data)
    self:hideAllBet()
    self:hideAllPot()
    
    local playerList = data:getPlayerList()
    for _,player in pairs(playerList) do
        local userSeat = SeatManager:getSeat(player.seatId)
        self:refreshBet(userSeat:getPosId(), player.betInChips)
    end
    
    local potInfo = data:getChipsPots()
    if potInfo then
        self:replacePot(potInfo)
    end
end

--[Comment]
-- 处理跟注或加注筹码，根据具体筹码值，计算相应筹码并实现飞入动画
-- @param	operationNeedChips	操作需要的筹码
-- @param	totalBetInChips		总加注筹码
-- @param	userSeat			座位对象
ChipManager.popChip = function(self, operateChips, totalBetInChips, userSeat)
    local func = function()
        self.m_userChipV[userSeat:getPosId()]:moveToBet(operateChips, totalBetInChips,userSeat:getView(), function ()
            self:playSequenceAnim()
        end);
        ChipManager:modifyBet(userSeat:getPosId(), totalBetInChips)
        g_SoundManager:playEffect(g_SoundMap.effect.MovingChips)
    end
    self:addSequenceAnim(func)
end

--[Comment]
-- 处理跟注或加注筹码，根据具体筹码值，计算相应筹码并实现飞入动画
-- @param	operationNeedChips	操作需要的筹码
-- @param	totalBetInChips		总加注筹码
-- @param	userSeat			座位对象
ChipManager.popAnteChip = function(self, operateChips, totalBetInChips, userSeat)
    self.moving = true
    self.m_userChipV[userSeat:getPosId()]:moveToBet(operateChips, totalBetInChips,userSeat:getView(), function ()
        self:playSequenceAnim()
    end);
    g_SoundManager:playEffect(g_SoundMap.effect.MovingChips)
end

ChipManager.setMovingBetChipInfo = function(self)
    for i=1,9 do
        self.m_userChipV[i]:setMovingBetChipInfo();
    end
end

function ChipManager:playSequenceAnim(delay)
    if self.m_animSequence then
        if self.m_animTimer then
            g_Schedule:cancel(self.m_animTimer)
            self.m_animTimer = nil
        end
        self.m_animTimer = g_Schedule:schedulerOnce(function()
            if not self.m_animSequence then return end
            local animFuc = table.remove(self.m_animSequence,1)
            if animFuc then
                self.moving = true
                animFuc()
            else
                self.moving = false
            end
        end, delay or 0.3)
    end
end

function ChipManager:addSequenceAnim(animFuc)
    if self.moving then
        table.insert(self.m_animSequence,animFuc)
    else
        self.moving = true
        animFuc()
    end
end

ChipManager.gatherPrizePool = function(self, data)
    local count = 0
    local animFuc = function()
        for i=1,9 do
            self.m_userChipV[i]:moveToPot(function ()
                count = count + 1
                if count == 9 then
                    self:replacePot(data)
                    self:playSequenceAnim()
                end
            end)
            self:hideBetLabel(i)
        end
        local needPlay
        for i=1,9 do
            if self.m_userChipV[i] and not self.m_userChipV[i]:isEmpty() then
                needPlay = true
                break
            end
        end
        if needPlay then
            g_SoundManager:playEffect(g_SoundMap.effect.MovingChips)
        end
    end
    
    self:addSequenceAnim(animFuc)
end

--替换奖池筹码
ChipManager.replacePot = function(self, data)
    local chipInfoArr = data;
    for i=1,#chipInfoArr do
        self:refreshPot(i, chipInfoArr[i])
    end
end

--分奖池动画
ChipManager.splitAnimation = function(self, index, potInfo, callBack)
    local animFuc = function()
        local potChips = self.m_potZoneQuadBatchV[index]
        if not potChips then return end
        potChips:removeAllChildren(true)
	    
	    local winnerArr = potInfo.winner
	    local winChips = potInfo.perMoney
	    for _,winnerInfo in pairs(winnerArr) do
		    local userSeat = SeatManager:getSeat(winnerInfo.seatId)
			local seatView = userSeat:getView()
			local p = seatView:getParent():convertToWorldSpace(cc.p(seatView:getPosition()))
			local tp = potChips:convertToNodeSpace(p)
		    
		    self.m_potChipInfoV = ChipManager:takeOutChipInfos(winChips);
		    local infoLength = #self.m_potChipInfoV;
		    for i=infoLength,1,-1 do
			    local chip = ChipManager:getChip(self.m_potChipInfoV[i].number)
			    local action = cc.MoveTo:create(ChipManager.MOVE_POT_DURATION + (i-1) * ChipManager.MOVE_DELAY_DURATION, tp)
			    local actionFunc = cc.CallFunc:create(function ()
				    chip:removeFromParent(true)
				    if i == infoLength then
					    if userSeat:getSeatData() then
						    userSeat:setSeatChips(userSeat:getSeatData().seatChips + winChips)
					    end
					    if callBack then
						    callBack(winnerInfo)
					    end
					    self:playSequenceAnim()
				    end
			    end)
			    local sequenceAction = cc.Sequence:create(action,actionFunc)
			    potChips:addChild(chip)
			    chip:runAction(sequenceAction)
		    end
	    end
        self:hidePotLabel(index)
        g_SoundManager:playEffect(g_SoundMap.effect.MovingChips)
    end
    
    self:addSequenceAnim(animFuc)
end

ChipManager.setUserSeatChips = function(self, data)
    local winChips = data.winChips;
    local userSeat = data.userSeat;
    if (not userSeat:isStanded()) then
        userSeat:setSeatChips(userSeat.m_seatData.seatChips + winChips);
    end
end

ChipManager.hideBetLabel = function(self, positionId)
    self.m_betZoneSpriteV[positionId]:setChipLabel(0)
end

ChipManager.hideBet = function(self, positionId)
    self.m_betZoneSpriteV[positionId]:setChipLabel(0)
    self.m_userChipV[positionId]:refreshBet(0)
end

ChipManager.hideAllBet = function(self)
    for i=1,9 do
        self:hideBet(i)
    end
end

ChipManager.modifyBet = function(self, positionId, chips)
    self.m_betZoneSpriteV[positionId]:setVisible(true);
    self.m_betZoneSpriteV[positionId]:setChipLabel(chips);
end

ChipManager.refreshBet = function(self, positionId, chips)
    self.m_userChipV[positionId]:refreshBet(chips)
    self:modifyBet(positionId, chips)
end

ChipManager.hidePotLabel = function(self, positionId)
    self.m_potZoneSpriteV[positionId]:setChipLabel(0)
end

ChipManager.hidePot = function(self, positionId)
    self.m_potZoneSpriteV[positionId]:setChipLabel(0)
    self.m_potChipV[positionId]:refreshPot(0);
end

ChipManager.hideAllPot = function(self)
    for i=1,9 do
        self:hidePot(i)
    end
end

ChipManager.modifyPot = function(self, positionId, chips)
    self.m_potZoneSpriteV[positionId]:setVisible(true);
    self.m_potZoneSpriteV[positionId]:setChipLabel(chips);
end

ChipManager.refreshPot = function(self, positionId, chips)
    self.m_potChipV[positionId]:refreshPot(chips);
    self:modifyPot(positionId, chips)
end

ChipManager.clear = function(self)
    for i = 1,9 do
        self:refreshPot(i, 0)
        self:refreshBet(i, 0)
    end
    self.m_playIndex = 1
    self.m_addIndex = 1
    self.m_animSequence = {}
    self.moving = false
    if self.m_animTimer then
        g_Schedule:cancel(self.m_animTimer)
        self.m_animTimer = nil
    end
end

ChipManager.cleanup = function(self)
    if self.m_animTimer then
        g_Schedule:cancel(self.m_animTimer)
        self.m_animTimer = nil
    end
    for k,v in pairs(self) do
        if type(v) == "table" then
            self[k] = nil
        end
    end
end

ChipManager.get_potZoneQuadBatchV = function(self)
    return self.m_potZoneQuadBatchV;
end

ChipManager.getPool = function(self)
    local pool = 0
    for i = 1, 9 do
        pool = pool + self.m_betZoneSpriteV[i]:getChips()
        pool = pool + self.m_potZoneSpriteV[i]:getChips()
    end
    return pool
end

return ChipManager