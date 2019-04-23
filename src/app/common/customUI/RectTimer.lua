


local RectTimer = class("RectTimer", cc.Node)

function RectTimer:ctor(width, height)
	self.m_width = width or 200
	self.m_height = height or 300
	self.m_borderWidth = 15
	self.m_brushSize = 25
	self:init(self.m_width, self.m_height, self.m_borderWidth)
end

function RectTimer:dtor()

end

function RectTimer:init(width, height)
	self.m_borderW = 128
	self.m_borderH = 176
	self.m_draw = cc.Sprite:create("creator/normalRoom/img/win/small-win-seat-frame.png")
	self.m_draw:setPosition(width / 2, height / 2)
	self.m_draw:setContentSize(self.m_borderW, self.m_borderH)
	
	self:addChild(self.m_draw)

	--self:drawNodeRoundRect(self.m_draw,cc.rect(0,0,width,height),borderWidth,8,cc.c4f(1, 1, 1, 1) )
	
	-- create a render texture, this is what we are going to draw into
	self.m_target = cc.RenderTexture:create(self.m_borderW + self.m_borderWidth, self.m_borderH + self.m_borderWidth, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	self.m_target:setPosition(width / 2, height / 2)
	self:addChild(self.m_target)
	self.m_target:setClearColor( cc.c4b(0,0,0,0));
	
	self.m_spriteBrush = cc.Sprite:create("creator/common/icon/icon_must_play.png")
	self.m_spriteBrush:setColor(cc.c3b(255, 0, 0))
	self.m_spriteBrush:setOpacity(0)
	self.m_spriteBrush:setContentSize(15,15)
	self.m_spriteBrush:setPosition(self.m_borderW / 2 + self.m_brushSize / 2, self.m_borderH + self.m_borderWidth/2- 5)
	self.m_spriteBrush:setBlendFunc(gl.ONE,gl.ZERO)
	self.m_target:addChild(self.m_spriteBrush)

	self.m_rectPoints = {
		 ptl = cc.p(self.m_brushSize/2+2,self.m_borderH + self.m_borderWidth/2-5),
		 ptr = cc.p(self.m_borderW +self.m_brushSize / 2-8 ,self.m_borderH +self.m_borderWidth/2-5),
		 pbr = cc.p(self.m_borderW +self.m_brushSize / 2-8 , self.m_borderWidth/2+5),
		 pbl = cc.p(self.m_brushSize / 2+2,self.m_borderWidth/2+5),
		 ptm = cc.p(self.m_borderW / 2 + self.m_brushSize / 2,self.m_borderH + self.m_borderWidth/2-5),
	}
	
	self:setCascadeColorEnabled(true)
	self:setCascadeOpacityEnabled(true)
end

function RectTimer:stop()
	self.m_spriteBrush:stopAllActions()
	self:unscheduleUpdate()
end


function RectTimer:start(moveEnd,time)
	self.m_startTime = os.time()
	self.m_preTime = self.m_startTime
	self.m_time = time

	self.m_spriteBrush:setPosition(self.m_borderW / 2 + self.m_brushSize / 2, self.m_borderH + self.m_borderWidth /2-5)
	self.m_target:clear(0,0,0,0)
	
	local totalLen = 2 * self.m_borderW + 2 * self.m_borderH
	local time1 = self.m_borderW / 2 / totalLen * self.m_time
	local time2 = self.m_borderH /  totalLen * self.m_time
	local action = cc.Sequence:create(
			cc.MoveBy:create(time1,cc.p(self.m_borderW / 2 - self.m_brushSize / 2+ 5,0)),
			cc.MoveBy:create(time2,cc.p(0,-self.m_borderH + 10)),
			cc.MoveBy:create(time1 * 2,cc.p(-self.m_borderW + self.m_borderWidth - 5,0)),
			cc.MoveBy:create(time2,cc.p(0,self.m_borderH - 5)),
			cc.MoveBy:create(time1,cc.p(self.m_borderW / 2 + self.m_brushSize / 2 + 5,0)),
			cc.CallFunc:create(moveEnd))

	self.m_spriteBrush:runAction(action)
	
	local cosTime = 0
	local onUpdate = function(dt)

		local curTime = os.time() 
		local dtime = curTime - self.m_preTime
		self.m_preTime = curTime
		if dtime > 2  then
			local t = curTime - self.m_startTime + 0.5
			if t > 0 and t < self.m_time then
				self:preStartBrashes(self.m_rectPoints,self.m_time,t)
				self:startWithPastTime(moveEnd,self.m_time,t)
			end
		end

		if cosTime == 0 then
			self.m_draw:setVisible(true)
		end
		cosTime = cosTime + dt
		self.m_spriteBrush:setVisible(true)
		
		self.m_target:begin()
		self.m_draw:setPosition(self.m_width / 2 + self.m_borderWidth, self.m_height/2 + self.m_borderWidth)
		self.m_draw:visit()
		self.m_spriteBrush:visit()
		self.m_target:endToLua()
		
		self.m_spriteBrush:setVisible(false)
		self.m_draw:setVisible(false)
		
		local proc = cosTime / time * 255
		self.m_target:getSprite():setColor(cc.c3b(proc,255 - proc,0))
	end
	
	self:scheduleUpdate(onUpdate)
end


function RectTimer:startWithPastTime(moveEnd,time,pastTime)

	local ptr = self.m_rectPoints.ptr
	local pbr = self.m_rectPoints.pbr
	local pbl = self.m_rectPoints.pbl
	local ptl = self.m_rectPoints.ptl
	local ptm = self.m_rectPoints.ptm

	local dtime = time/4
	--local dtime2 = dtime*0.5

	local action = nil
	if pastTime > dtime*3.5 then
		local rt = 4.0*dtime - pastTime
		rt = rt > 0 and rt or 0.01
		action = cc.Sequence:create(
		cc.MoveTo:create(rt,ptm),
		cc.CallFunc:create(moveEnd))
	elseif pastTime > dtime*2.5 then
		
		local rt = dtime*3.5 - pastTime
		rt = rt > 0 and rt or 0.01
		action = cc.Sequence:create(cc.MoveTo:create(rt,ptl),cc.MoveTo:create(0.5*dtime,ptm),cc.CallFunc:create(moveEnd))
	elseif pastTime > dtime*1.5 then
		local rt = dtime*2.5-pastTime
		action = cc.Sequence:create(
		cc.MoveTo:create(rt,pbl),
		cc.MoveTo:create(dtime*1.0,ptl),
		cc.MoveTo:create(dtime*0.5,ptm),
		cc.CallFunc:create(moveEnd))
	elseif pastTime > dtime*0.5 then
		local rt = dtime*1.5-pastTime
		action = cc.Sequence:create(cc.MoveTo:create(rt,pbr),
		cc.MoveTo:create(dtime*1.0,pbl),
		cc.MoveTo:create(dtime*1.0,ptl),
		cc.MoveTo:create(dtime*0.5,ptm),
		cc.CallFunc:create(moveEnd))
	else
		local rt = dtime*0.5-pastTime
		action = cc.Sequence:create(cc.MoveTo:create(rt,ptr),cc.MoveTo:create(dtime*1.0,pbr),
		cc.MoveTo:create(dtime*1.0,pbl),
		cc.MoveTo:create(dtime*1.0,ptl),
		cc.MoveTo:create(dtime*0.5,ptm),
		cc.CallFunc:create(moveEnd))
	end

	
	self.m_spriteBrush:stopAllActions()
	self.m_spriteBrush:runAction(action)
end

function RectTimer:createBrash()
	local spriteBrush = cc.Sprite:create("creator/common/icon/icon_must_play.png")
	spriteBrush:setColor(cc.c3b(255, 0, 0))
	spriteBrush:setOpacity(0)
	spriteBrush:setContentSize(15,15)
	spriteBrush:setBlendFunc(gl.ONE,gl.ZERO)
	self.m_target:addChild(spriteBrush)
	return spriteBrush
end


function RectTimer:doBrashes(point,leftTime,rightTime,startTime,dx,dy)

	if startTime> leftTime then
		local ltime = startTime > rightTime and rightTime or startTime
		local x = point.x
		local y = point.y
		for i=leftTime,ltime, 0.1 do
			local brush = self:createBrash()
			brush:setPosition(x,y)
			brush:visit()
			table.insert( self.m_brushes,brush) 
			
			x = x + dx
			y = y + dy
			self.m_spriteBrush:setPosition(x,y)
		end
	end
end


function RectTimer:preStartBrashes(ps,totalTime,startTime)

	local ptr = ps.ptr
	local pbr = ps.pbr
	local pbl = ps.pbl
	local ptl = ps.ptl

	local dtime = totalTime/4
	local dx = ((ptr.x - ptl.x)/dtime)*0.1
	local dy = ((ptr.y - pbr.y)/dtime)*0.1

	if self.m_brushes then
		for k,v in pairs(self.m_brushes) do
			v:removeFromParent()
		end
	end

	self.m_brushes = {}
	local mid = {}
	mid.x = (ptl.x+ ptr.x)*0.5
	mid.y = ptl.y
	self.m_spriteBrush:setPosition(mid)


	self.m_target:begin()

	
	self:doBrashes(mid,0,dtime*0.5,startTime,dx,0)
	self:doBrashes(ptr,dtime*0.5,dtime*1.5,startTime,0,-dy)
	self:doBrashes(pbr,dtime*1.5,dtime*2.5,startTime,-dx,0)
	self:doBrashes(pbl,dtime*2.5,dtime*3.5,startTime,0,dy)
	self:doBrashes(ptl,dtime*3.5,dtime*4.0,startTime,dx,0)
	self.m_target:endToLua()
end


-- 传入DrawNode对象，画圆角矩形
-- segments表示圆角的精细度，值越大越精细
function RectTimer:drawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)
	if fillColor == nil then
		fillColor = cc.c4f(255, 0, 0, 0)
	end
	
	local segments = 100
	
	local origin = cc.p(rect.x, rect.y)  
	
	local destination = cc.p(rect.x + rect.width, rect.y - rect.height)  
	
	local points = {}  
	
	-- 算出1/4圆  
	
	local coef = math.pi / 2 / segments  
	
	local vertices = {}  
	
	for i=0, segments do
		local rads = (segments - i) * coef
		local x = radius * math.sin(rads)
		local y = radius * math.cos(rads)
		table.insert(vertices, cc.p(x, y))
	end  
	
	local tagCenter = cc.p(0, 0)  
	
	local minX = math.min(origin.x, destination.x)
	local maxX = math.max(origin.x, destination.x)
	local minY = math.min(origin.y, destination.y)
	local maxY = math.max(origin.y, destination.y)
	
	local pPolygonPtArr = {}
	
	-- 左上角
	tagCenter.x = minX + radius;
	tagCenter.y = maxY - radius;
	for i=0, segments do
		local x = tagCenter.x - vertices[i + 1].x
		local y = tagCenter.y + vertices[i + 1].y
		table.insert(pPolygonPtArr, cc.p(x, y))
	end
	
	-- 右上角
	tagCenter.x = maxX - radius;
	tagCenter.y = maxY - radius;
	for i=0, segments do
		local x = tagCenter.x + vertices[#vertices - i].x
		local y = tagCenter.y + vertices[#vertices - i].y
		table.insert(pPolygonPtArr, cc.p(x, y))
	end  
	
	-- 右下角
	tagCenter.x = maxX - radius;
	tagCenter.y = minY + radius;
	for i=0, segments do
		local x = tagCenter.x + vertices[i + 1].x
		local y = tagCenter.y - vertices[i + 1].y
		table.insert(pPolygonPtArr, cc.p(x, y))
	end
	
	-- 左下角
	tagCenter.x = minX + radius;
	tagCenter.y = minY + radius;
	for i=0, segments do
		local x = tagCenter.x - vertices[#vertices - i].x
		local y = tagCenter.y - vertices[#vertices - i].y
		table.insert(pPolygonPtArr, cc.p(x, y))
	end
	
	drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
	
end

return RectTimer
