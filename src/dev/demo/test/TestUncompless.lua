
local PopupLayer = require "scenes.layers.PopupLayer"

local testGetUrl =  "http://httpbin.org/get"


local TestUncompless = class("TestUncompless", PopupLayer)

function TestUncompless:ctor()
	PopupLayer.ctor(self)

	
	--self:init()
	self:testSpine()
end

function TestUncompless:dtor()

end

function TestUncompless:init()

	local path = cc.FileUtils:getInstance():getWritablePath().."update/"
	projectx.lcc_unCompress("E:/assets.zip",path,"")

end

function TestUncompless:testSpine()

	self.m_skeletonNode = sp.SkeletonAnimation:create("pokerani_niyingle.json", "pokerani.atlas", 1.0)

	self.m_skeletonNode:setPosition(cc.p(400, 300))
	self:addChild(self.m_skeletonNode)
	self.m_skeletonNode:setAnimation(0, "newAnimation", true)
	self.m_skeletonNode:update(0)
end



return TestUncompless
