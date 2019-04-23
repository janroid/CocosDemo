local animation = import("app.common.animation")
local ChipAnim = animation.ChipAnim
local PopupLayer = require "scenes.layers.PopupLayer"



local TestPokerProbability = class("TestPokerProbability", PopupLayer)

function TestPokerProbability:ctor()
	PopupLayer.ctor(self)
	
	self:init()

end

function TestPokerProbability:dtor()

end

function TestPokerProbability:init()
	local menuRequest = cc.Menu:create()
    menuRequest:setPosition(cc.p(0,0))
    self:addChild(menuRequest)

	local function onDownloadFileClicked()
		--self:test()
		self:testChipAni()
		self.m_labelStatus:setString("waiting...")
	end

	local labelGet  = cc.Label:createWithSystemFont("Test Poker", "", 30)
    labelGet:setAnchorPoint(cc.p(0.5, 0.5))
    local itemGet  =  cc.MenuItemLabel:create(labelGet)
    itemGet:registerScriptTapHandler(onDownloadFileClicked)
    itemGet:setPosition(display.width / 2, display.height/2)
	menuRequest:addChild(itemGet)
	

	self.m_labelStatus = cc.Label:createWithSystemFont("", "", 30)
	self.m_labelStatus:setPosition(display.width / 2,display.height/2-50)
	self:addChild(self.m_labelStatus)


	self.m_nodeFrom = cc.Label:createWithSystemFont("from", "", 30)
	self:addChild(self.m_nodeFrom)
	self.m_nodeFrom:setPosition(300,400)

	self.m_nodeTo = cc.Label:createWithSystemFont("to", "", 30)
	self:addChild(self.m_nodeTo)
	self.m_nodeTo:setPosition(300,50)
end

function TestPokerProbability:test()

	local ins = g_PokerManager.getInstance()
	
	local pokers = {}
	pokers[1] = ins:createPokerData(2,10)
	pokers[2] = ins:createPokerData(1,2)
	pokers[3] = ins:createPokerData(1,3)
	pokers[4] = ins:createPokerData(1,4)
	pokers[5] = ins:createPokerData(1,5)
	pokers[6] = ins:createPokerData(2,11)
	--pokers[7] = ins:createPokerData(3,5)

	local q1 = {}
	for k,v in pairs(pokers) do
		q1[k] = v:getByteValue()
	end

	g_PokerManager.getInstance():getPokersProbability(q1)
end


function TestPokerProbability:testChipAni()
	local ani = ChipAnim:create()

	self:addChild(ani,1000000)
	ani:setPosition(0,0)
	ani:playWidthNode(self.m_nodeFrom,self.m_nodeTo)
end


return TestPokerProbability
