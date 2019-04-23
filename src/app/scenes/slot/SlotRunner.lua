--[[
    author:{JanRoid}
    time:2018-12-29
    Description: 一个不断循环旋转的老虎机转轮
]]

local runSpeed = 400 -- 老虎机滚动速度
local floor = math.floor
local abs = math.abs
local schedule = cc.Director:getInstance():getScheduler();

local SlotRunner = class("ClotRunner",cc.Node)

local filePath = "creator/slot/run.png"


--[[
    @desc: 
    --@speed: 滚动速度
    @return:
]]
function SlotRunner:ctor()
    self:setContentSize(58,80)
    self:setAnchorPoint(0,0)
    
    self.m_index1 = cc.Sprite:create(filePath)
    self.m_turntableHeight = self.m_index1:getContentSize().height
    self.m_index1:setAnchorPoint(0,0)
    self.m_index1:setPosition(0, 0) 
    self:add(self.m_index1)

    self.m_index2 = cc.Sprite:create(filePath)
    self.m_index2:setAnchorPoint(0,0)
    self.m_index2:setPosition(0,self.m_turntableHeight)
    self:add(self.m_index2)

end

function SlotRunner:reset()
    if self.m_turnSchedule then
        schedule:unscheduleScriptEntry(self.m_turnSchedule)
        self.m_turnSchedule = nil
    end

    self.m_index1:setPosition(0, 0)
    self.m_index2:setPosition(0,self.m_turntableHeight)
    self.m_curRound = 0
end

function SlotRunner:run()
    local totalTime = 0
    self.m_turnSchedule = schedule:scheduleScriptFunc(function(dt) 
			self:drawingTruntable(dt,totalTime) --左起第一张牌
			totalTime = totalTime + dt
		end, 1/60, false)
end

function SlotRunner:drawingTruntable(dt, totalTime)
    self:resetTurnPos(totalTime)
    self:translationTurntable(dt)
end

--[[
    @desc: 滚动效果
    --@index:
	--@dt: 
    @return:
]]
function SlotRunner:translationTurntable(dt)
	local subY = dt*runSpeed
	local posY = self.m_index1:getPositionY() - subY
	self.m_index1:setPositionY(posY)

	posY = self.m_index2:getPositionY() - subY
	self.m_index2:setPositionY(posY)
end

-- 滚动过程中，重置滚动图片坐标，形成循环的表现
function SlotRunner:resetTurnPos(totalTime)
	self.m_curRound = self.m_curRound or 0

	-- 当前滚动的圈数（滚动完一张图片算一圈）
	local lap = floor((totalTime - self.m_curRound * self.m_turntableHeight/runSpeed) / ((self.m_turntableHeight)/runSpeed))
	if lap > 0 then	 -- 滚动到显示区域下面的图片重新设置到滚动区域上方位置，形成循环
		self.m_curRound = self.m_curRound + 1
		local index = self.m_curRound%2

		local mine = self.m_index1       -- 贴图
		local brothers = self.m_index2   -- 贴图
		if index == 0 then
			mine = self.m_index2
			brothers = self.m_index1
		end

		local posY = brothers:getPositionY()
		mine:setPositionY(posY + self.m_turntableHeight)
	end
end


return SlotRunner