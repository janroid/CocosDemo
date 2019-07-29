local ViewScene = require("framework.scenes.ViewScene");
local GameScene = class("GameScene",ViewScene);
local GameCtr = import("GameCtr")

local Player = import("Player")
local FloorFactory = import("FloorFactory")
local BatMask = import("BitMask")

---配置事件监听函数
GameScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
}

function GameScene:ctor()
	ViewScene.ctor(self)
	self:initWithPhysics()

	self:bindCtr(LoginCtr)

	self:initListener()

	self:init()

	self:updateFrame()
end

function GameScene:init()
	self:loadLayout("creator/aavg/levelmap/levelOne.ccreator")
	 
	self.m_layerFloor = self.m_levelOne:getLayer("layer_floor")
	self.m_layerPlant = self.m_levelOne:getLayer("layer_plant")
	self.m_layerTrap = self.m_levelOne:getLayer("layer_trap")
	self.m_layerSlope = self.m_levelOne:getLayer("layer_floor_slope")
	self.m_layerStairs = self.m_levelOne:getLayer("layer_floor_stairs")

	self.m_player = Player:create("creator/aavg/player/nemo_sprite.png")
	self.m_player:setPosition(100,100)
	self.m_player:setLocalZOrder(1)
	self.m_root:add(self.m_player)

	self.m_winSize = cc.Director:getInstance():getWinSize()
	self.m_startX, self.m_startY = self.m_root:getPosition()
	self.m_maxSize = self.m_levelOne:getContentSize()
	self.m_offsetX = 0
	self.m_offsetY = 0
	Log.d("******************************** - ",self.m_levelOne:getContentSize())
	self:initPhysics()

	local contactListener = cc.EventListenerPhysicsContact:create()
	contactListener:registerScriptHandler(function(contact)
			local b = contact:getShapeA():getBody()
			local a = contact:getShapeB():getBody()

			local data = contact:getContactData()
			local angle = 90

			if a:getCategoryBitmask() == BatMask.C_PLAYER and b:getCategoryBitmask() == BatMask.C_FLOOR then
				self.m_player:resetJump()
				Log.d("*************************** a = ",a:getCategoryBitmask(),", b = ",b:getCategoryBitmask())
			elseif a:getCategoryBitmask() == BatMask.C_PLAYER and b:getCategoryBitmask() == BatMask.C_SLOPE then
				self.m_player:resetJump()
				if self.m_player:getMoveType() == 1 then
					angle = 45
				else
					angle = 135
				end
				Log.d("*************************** a = ",a:getCategoryBitmask(),", b = ",b:getCategoryBitmask())
			end
			self.m_player:setAngle(angle)
			
			return true
		end, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)

	contactListener:registerScriptHandler(function(contact)
			local data = contact:getContactData()
		end, cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)
	
	g_EventDispatcher.getInstance():addListener(contactListener, self.m_player)

end

function GameScene:initPhysics( )
	local size = self.m_layerFloor:getLayerSize()
	for i = 0, size.width-1 do
		for j = 0, size.height-1 do
			local m = self.m_layerFloor:getTileAt(cc.p(i,j))
			if m ~= nil then
				local body = cc.PhysicsBody:createEdgeBox(m:getContentSize())
				body:setCategoryBitmask(BatMask.C_FLOOR)
				body:setCollisionBitmask(BatMask.CL_FLOOR)
				body:setContactTestBitmask(BatMask.CT_FLOOR)
				m:setPhysicsBody(body);		
			end
		end
	end

	local factory = FloorFactory:create()

	size = self.m_layerSlope:getLayerSize()
	for i = 0, size.width-1 do
		for j = 0, size.height-1 do
			local m = self.m_layerSlope:getTileAt(cc.p(i,j))
			if m ~= nil then
				local body = factory:createSlopeBody()
				m:setPhysicsBody(body);		
			end
		end
	end

	size = self.m_layerStairs:getLayerSize()
	for i = 0, size.width-1 do
		for j = 0, size.height-1 do
			local m = self.m_layerStairs:getTileAt(cc.p(i,j))
			if m ~= nil then
				local body = factory:createStairsBody()
				m:setPhysicsBody(body);		
			end
		end
	end	
end

function GameScene:onEnter()
	ViewScene.onEnter(self)
end

function GameScene:onExit()
	ViewScene.onExit(self)
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
	]]
end
 

function GameScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]

end

function GameScene:updateFrame( )
	self:scheduleUpdate(function(dt)
		local x,y = self.m_player:getPosition()
		local w = self.m_winSize.width
		local h = self.m_winSize.height
		local maxW = self.m_maxSize.width * 0.4
		local maxH = self.m_maxSize.height * 0.4

		self.m_offsetX = x - w/2
		self.m_offsetY = y - h/2

		if self.m_offsetX < 0 then
			self.m_offsetX = 0
		end

		if self.m_offsetY < 0 then
			self.m_offsetY = 0
		end
		Log.d("************************* offsetX = ",(self.m_offsetX + self.m_startX + w/2))
		if (self.m_offsetX + self.m_startX + w/2) > maxW then
			
			self.m_offsetX = self.m_offsetX - ((self.m_offsetX + self.m_startX + w/2) - maxW)
		end

		if (self.m_offsetY + self.m_startY + h/2) > maxH then
			self.m_offsetY = self.m_offsetY - ((self.m_offsetY + self.m_startY + h/2) - maxH)
		end

		self.m_root:setPosition(self.m_startX - self.m_offsetX,self.m_startY - self.m_offsetY)

    end)
end

function GameScene:showTips(msg)
	if not msg or string.len(msg) < 1 then
		Log.d("GameScene.showTips : msg is nil or too short")
		return
	end

	g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), msg):show()
end


function GameScene:initListener()
	local keyListener = cc.EventListenerKeyboard:create()
	keyListener:registerScriptHandler(function(kcode, event)
			self.m_player:runing(0)
			Log.d("**************************松开 ",kcode,event)
		end, cc.Handler.EVENT_KEYBOARD_RELEASED)

	keyListener:registerScriptHandler(function(kcode,event)
			if  kcode == cc.KeyCode.KEY_LEFT_ARROW then			
				self.m_player:runing(-1)
			elseif kcode == cc.KeyCode.KEY_RIGHT_ARROW then
				self.m_player:runing(1)
			elseif kcode == cc.KeyCode.KEY_UP_ARROW then
				self.m_player:jump()
			end
		end, cc.Handler.EVENT_KEYBOARD_PRESSED)

	g_EventDispatcher.getInstance():addListener(keyListener, self.m_player)
end

return GameScene;
