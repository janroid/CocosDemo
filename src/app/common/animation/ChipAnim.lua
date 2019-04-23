local ChipAnim = class("ChipAnim",cc.Node)

local chipPaths = {
	"creator/loginReward/img/chip_01.png",
	"creator/loginReward/img/chip_02.png",
	"creator/loginReward/img/chip_03.png",
	"creator/loginReward/img/chip_04.png",
	"creator/loginReward/img/chip_05.png",
	"creator/loginReward/img/chip_06.png",
	"creator/loginReward/img/chip_07.png",
	"creator/loginReward/img/chip_08.png",
	"creator/loginReward/img/chip_09.png",
	"creator/loginReward/img/chip_10.png",
}

local chipColorPaths = {
	"creator/normalRoom/img/pos/room_chip_even_1.png",
	"creator/normalRoom/img/pos/room_chip_even_2.png",
	"creator/normalRoom/img/pos/room_chip_even_5.png",
	"creator/normalRoom/img/pos/room_chip_odd_1.png",
	"creator/normalRoom/img/pos/room_chip_odd_2.png",
	"creator/normalRoom/img/pos/room_chip_odd_5.png",
	"creator/normalRoom/img/pos/room_chip_even_1.png",	
}



function ChipAnim:ctor() 
end

function  ChipAnim:init()
end

function  ChipAnim:playWidthNode(fromNode,toNode,cbObj,cbFunc)
    local wpFrom = fromNode:convertToWorldSpace(cc.p(0,0))
    local wpTo = toNode:convertToWorldSpace(cc.p(0,0))
    local lpFrom = self:convertToNodeSpace(wpFrom)
    local lpTo = self:convertToNodeSpace(wpTo)

	self.m_callbackObj = cbObj
	self.m_callbackFunc = cbFunc

    self:play(lpFrom,lpTo)
end

function  ChipAnim:getControls(lpFrom,lpTo,isRight)

	local dx = lpTo.x - lpFrom.x
	local dy = lpTo.y - lpFrom.y

	local np = cc.pNormalize(cc.p(-dy,dx)) 
	if not isRight then
		np = cc.pNormalize(cc.p(dy,-dx))
	end

	if dy > 0 then
		local  ad= math.random( 0, 100 )
		local dd = math.random(-50,0)/100.0

		local ax = lpFrom.x + dx*dd+np.x*ad*3
		local ay = lpFrom.y + dy*dd+np.y*ad*3

		local  bd= math.random( 0, 100 )
		local bx = lpFrom.x + dx*0.46+ np.x*bd*2
		local by = lpFrom.y + dy*0.46+ np.y*bd*2
	
		local scontrol1 = { x=ax  , y = ay  }
		local scontrol2 = { x=bx,  y = by }

		local sendPoints = {x=lpTo.x,y=lpTo.y}

		return {scontrol1,scontrol2,sendPoints}
	else
		local  ad= math.random( 0, 50 )
		local dd = -1.0--math.random(-50,0)/100.0

		local ax = lpFrom.x + dx*dd+np.x*ad
		local ay = lpFrom.y + dy*dd+np.y*ad

		local  bd= math.random( 0, 50 )
		local bx = lpFrom.x + dx*0.26+ np.x*bd
		local by = lpFrom.y + dy*0.26+ np.y*bd
	
		local scontrol1 = { x=ax  , y = ay  }
		local scontrol2 = { x=bx,  y = by }

		local sendPoints = {x=lpTo.x,y=lpTo.y}

		return {scontrol1,scontrol2,sendPoints}

	end
   
end

function  ChipAnim:play(lpFrom,lpTo)
	for i=1,12 do
        local chip = self:createChip()
		chip:setPosition(lpFrom)
		
		---if true then
		--	return 
		--end
		--chip:setScale(0.3)

       local ds = cc.pGetDistance(lpFrom,lpTo)
        
		local dtime = ds/300.0
		if dtime< 1.2 then
			dtime = 1.2
		end
		
		--local moveAction= cc.EaseSineInOut:create(cc.BezierTo:create(dtime,{scontrol1,scontrol2,sendPoints}))

		local at = math.random(30,60 )/100.0

		--local scaleTo = cc.ScaleTo:create(at/2,0.6+math.random(40)/100.0)
		
		local dp = cc.p(math.random(-60,60),math.random(-60,60))
		--local moveToAction = cc.EaseExponentialOut:create(cc.MoveBy:create(at,dp))

		--chip:setPosition(cc.p(lpFrom.x+dp.x,lpFrom.y+dp.y))

      

		--local moveToEnd = cc.EaseSineInOut:create(cc.MoveTo:create(1.0,lpTo))

		local controls = self:getControls(cc.p(lpFrom.x+dp.x,lpFrom.y+dp.y),lpTo,dp.x>0)
		local at2 = math.random(0,70 )/100.0

		if i == 10 then
			at2 = 0.71
		end

		local moveAction= cc.EaseInOut:create(cc.BezierTo:create((dtime-0.5+at2)/2,controls),0.65)--cc.EaseExponentialIn:create(cc.BezierTo:create(dtime,controls))

		local fadeOut = cc.FadeOut:create(0.1)
		local scaleOut = cc.ScaleTo:create(0.1,0)
		local spawn2 = cc.Spawn:create(fadeOut,scaleOut)


			
		--local spawn = cc.Spawn:create(moveAction,scaleTo)
		--chip:setVisible(false)
		local sequnce = cc.Sequence:create(
			--spawn,
			--cc.DelayTime:create(math.random(25)/100),
			--cc.CallFunc:create(function()
				--chip:setVisible(true)
			--end),
			moveAction,
			spawn2,
			cc.CallFunc:create(function()
				if i == 10 then
					if self.m_callbackFunc then
						self.m_callbackFunc(self.m_callbackObj)
					end
				end
			end
		),
			cc.RemoveSelf:create()
		)


		local  rotation= cc.RepeatForever:create( cc.RotateBy:create(1.0,360))	
		chip:runAction(rotation)
		--self.m_goldList[i]:runAction(moveAction)
		chip:runAction(sequnce)

    end
end

function  ChipAnim:createChip()

	--[[if math.random( 100) < 50 then

	    local chip = cc.Sprite:create("creator/loginReward/img/chip_01.png")
	
	
		local animation = cc.Animation:create()
    	for i = 1, 10 do
        	animation:addSpriteFrameWithFile(chipPaths[i])
    	end
    	
    	animation:setDelayPerUnit(0.04+math.random(0, 30 )/1000 )
    	animation:setRestoreOriginalFrame(true)

    	local action = cc.Animate:create(animation)
    	chip:runAction( cc.RepeatForever:create( cc.Sequence:create(action) ))
	
	
		self:addChild(chip)
		return chip
	else]]

		local len = #chipColorPaths
		local index = math.random(1,len)
		local chip = cc.Sprite:create(chipColorPaths[index])
	
		self:addChild(chip)
		return chip
		
	--end
    
end

return ChipAnim