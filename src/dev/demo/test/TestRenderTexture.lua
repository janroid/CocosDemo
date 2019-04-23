
local PopupLayer = require "scenes.layers.PopupLayer"


local TestRenderTexture = class("TestRenderTexture", PopupLayer)

function TestRenderTexture:ctor()
	PopupLayer.ctor(self)

	
	self:init()




end

function TestRenderTexture:dtor()

end


function TestRenderTexture:createExitBt()
	local menuRequest = cc.Menu:create()
    menuRequest:setPosition(cc.p(0,0))
    self:addChild(menuRequest)

	local function onDownloadFileClicked()
		self:exitPopupLayer()
	end

	local labelGet  = cc.Label:createWithSystemFont("Exit", "", 30)
    labelGet:setAnchorPoint(cc.p(0.5, 0.5))
    local itemGet  =  cc.MenuItemLabel:create(labelGet)
    itemGet:registerScriptTapHandler(onDownloadFileClicked)
    itemGet:setPosition(display.width-50, display.height-50)
	menuRequest:addChild(itemGet)
end

function TestRenderTexture:createRenderTexture()

	    -- create a render texture, this is what we are going to draw into
		local target = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
		--target:retain()
		target:setPosition(display.center)
		
	
		--target:setAutoDraw(true);
			-- note that the render texture is a cc.Node, and contains a sprite of its texture for convenience,
			-- so we can just parent it to the scene like any other cc.Node
		self:addChild(target)
		self.m_target = target
		self.m_target:setClearColor( cc.c4b(0,0,0,0));
	
	
		self.m_spriteBrush = cc.Sprite:create("creator/common/icon/icon_must_play.png")
		self.m_spriteBrush:setColor(cc.c3b(255, 0, 0))
		self.m_spriteBrush:setOpacity(0)
		self.m_spriteBrush:setPosition(display.center)
				
		self.m_spriteBrush:setBlendFunc(gl.ONE,gl.ZERO)
		
		--self.m_spriteBrush:retain()
		target:addChild(self.m_spriteBrush)
	
		self:setCascadeColorEnabled(true)
		self:setCascadeOpacityEnabled(true)
	

		local rx,ry = self.m_spriteBrush:getPosition()

		local totalTime = 0.2
		--self.m_spriteBrush:setPosition(rx+100,ry)
		local moveEnd = function ()
			self.m_spriteBrush:setPosition(rx,ry)
			self.m_target:getSprite():setColor(cc.c3b(math.random( 1, 255 ),math.random( 1, 255 ),math.random( 1, 255 )))
			self.m_draw:setVisible(true)
			totalTime = totalTime+0.2
			if totalTime > 4.0 then
				totalTime = 4.0
			end
			self:runMove(self.m_moveEnd,totalTime)
		end
		self.m_moveEnd = moveEnd
		self:runMove(moveEnd,0.3)
	
		local onUpdate = function()
			--self.m_draw:setVisible(true)
			
			self.m_spriteBrush:setVisible(true)
			--self:setColor(cc.c3b(math.random( 1, 255 ),math.random( 1, 255 ),math.random( 1, 255 )))
			--self.m_draw:setColor(cc.c3b(math.random( 1, 255 ),math.random( 1, 255 ),math.random( 1, 255 )))
			self.m_target:begin()
	
			self.m_draw:visit()
			self.m_spriteBrush:visit()
			
			self.m_target:endToLua()
			self.m_spriteBrush:setVisible(false)
			self.m_draw:setVisible(false)
			--self.m_spriteBrush:removeFromParentAndClearUp(false)
		end
	
		self:scheduleUpdate(onUpdate)
end

function TestRenderTexture:init()

	self.m_colorLayer:setOpacity(255)
	self:createExitBt()


	self.m_spriteBG = cc.Sprite:create("creator/common/dialog/bg_small_1.png")
	self.m_spriteBG:setPosition(display.center)
			
	--self.m_spriteBrush:retain()
	self:addChild(self.m_spriteBG,-1)

	self.m_draw = cc.DrawNode:create()
	self.m_draw:setPosition(display.center)
	self:addChild(self.m_draw, 10)

	local size = cc.size(200,200)
	local points = { cc.p(size.height/4, 0), cc.p(size.width, size.height / 5), cc.p(size.width / 3 * 2, size.height) }
  --  draw:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 4, cc.c4f(0,0,1,1))
	self:drawNodeRoundRect(self.m_draw,cc.rect(0,0,200,300),8,5,cc.c4f(1, 1, 1, 1) )
	
	self:createRenderTexture()
end

function TestRenderTexture:createBrash()
	local spriteBrush = cc.Sprite:create("creator/common/icon/icon_must_play.png")
	spriteBrush:setColor(cc.c3b(255, 0, 0))
	spriteBrush:setOpacity(0)
	spriteBrush:setPosition(display.center)
			
	spriteBrush:setBlendFunc(gl.ONE,gl.ZERO)
	
	--self.m_spriteBrush:retain()
	self.m_target:addChild(spriteBrush)
	return spriteBrush
end


function TestRenderTexture:doBrashes(point,leftTime,rightTime,startTime,dx,dy)

	if startTime> leftTime then
		--self.m_spriteBrush:setPosition(point)
		local ltime = startTime > rightTime and rightTime or startTime
		local x = point.x
		local y = point.y
		for i=leftTime,ltime, 0.1 do
			local brush = self:createBrash()
			brush:setPosition(x,y)--self.m_spriteBrush:getPosition())
			brush:visit()
			table.insert( self.m_brushes,brush) 
			
			x = x + dx
			y = y + dy
			self.m_spriteBrush:setPosition(x,y)
		end
	end
end




function TestRenderTexture:preStartBrashes(ps,totalTime,startTime)

	local ptr = ps.ptr
	local pbr = ps.pbr
	local pbl = ps.pbl
	local ptl = ps.ptl

	local dtime = totalTime/4
	local dx = (ptr.x - ptl.x)/10
	local dy = (ptr.y - pbr.y)/10

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
	self:doBrashes(mid,0,dtime*0.5,startTime,dx,0)
	self:doBrashes(ptr,dtime*0.5,dtime*1.5,startTime,0,-dy)
	self:doBrashes(pbr,dtime*1.5,dtime*2.5,startTime,-dx,0)
	self:doBrashes(pbl,dtime*2.5,dtime*3.5,startTime,0,dy)
	self:doBrashes(ptl,dtime*3.5,dtime*4.0,startTime,dx,0)

end

function TestRenderTexture:runMove(moveEnd,startTime)
	

	 startTime = startTime or 0


	 local rx,ry = self.m_spriteBrush:getPosition()
	 local ptr = cc.p(rx+200,ry+0)
	 local pbr = cc.p(rx+200,ry-300)
	 local pbl = cc.p(rx,ry-300)
	 local ptl = cc.p(rx,ry)
	 local ptm = cc.p(rx+100,ry)

	--left to right 
	local updateStart = function(dt)
		self.m_target:begin()
		self.m_draw:visit()
		self:preStartBrashes({ptr=ptr,pbr=pbr,pbl=pbl,ptl=ptl},4,startTime)
		self.m_target:endToLua()
		self.m_draw:setVisible(false)
	end

	updateStart()

	local action = nil
	if startTime > 3.5 then
		local rt = 4.0 - startTime
		rt = rt > 0 and rt or 0.01
		action = cc.Sequence:create(
		cc.MoveTo:create(rt,ptm),
		cc.CallFunc:create(moveEnd))
	elseif startTime > 2.5 then
		
		local rt = 3.5 - startTime
		rt = rt > 0 and rt or 0.01
		action = cc.Sequence:create(cc.MoveTo:create(rt,ptl),cc.MoveTo:create(0.5,ptm),cc.CallFunc:create(moveEnd))
	elseif startTime > 1.5 then
		local rt = 2.5-startTime
		action = cc.Sequence:create(
		cc.MoveTo:create(rt,pbl),
		cc.MoveTo:create(1.0,ptl),
		cc.MoveTo:create(0.5,ptm),
		cc.CallFunc:create(moveEnd))
	elseif startTime > 0.5 then
		local rt = 1.5-startTime
		action = cc.Sequence:create(cc.MoveTo:create(rt,pbr),
		cc.MoveTo:create(1.0,pbl),
		cc.MoveTo:create(1.0,ptl),
		cc.MoveTo:create(0.5,ptm),
		cc.CallFunc:create(moveEnd))
	else
		local rt = 0.5-startTime
		action = cc.Sequence:create(cc.MoveTo:create(rt,ptr),cc.MoveTo:create(1.0,pbr),
		cc.MoveTo:create(1.0,pbl),
		cc.MoveTo:create(1.0,ptl),
		cc.MoveTo:create(0.5,ptm),
		cc.CallFunc:create(moveEnd))
	end

	

	self.m_spriteBrush:runAction(action)
end


-- 传入DrawNode对象，画圆角矩形

function TestRenderTexture:drawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)  

	-- segments表示圆角的精细度，值越大越精细  
	
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
	
	local dwPolygonPtMax = (segments + 1) * 4  
	
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
	
	if fillColor == nil then  
	
		fillColor = cc.c4f(0, 0, 0, 0)  
	
	end  
	

	drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
	
	end





return TestRenderTexture
