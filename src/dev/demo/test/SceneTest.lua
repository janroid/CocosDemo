--local TestWidget = require "TestWidget"
--local TestAni = require "TestAni"
--local TestMore = require "TestMore"
--local TestServer = require "TestServer"
--local TestHttp = require "TestHttp"
local TestCreatorRichText = require "TestCreatorRichText"
local TestDownload = require "TestDownload"
local TestRenderTexture = require "TestRenderTexture"
local TestUncompless = require "TestUncompless"
local TestPokerProbability = require "TestPokerProbability"


--local TestGame = require "testGame.TestGame"

local SceneTest = class("SceneTest",cc.Scene)

local tests = {
	--{name="1_widget",create_func=TestWidget},
	--{name="2_ani",create_func=TestAni},
	--{name="3_more",create_func=TestMore},

	--{name="4_TestServer",create_func=TestServer},
	--{name="5_TestHttp",create_func=TestHttp},

	
	{name="5_TestCreatorRichText",create_func=TestCreatorRichText},
	{name="6_TestDownload",create_func=TestDownload},
	{name="7_TestRenderTexture",create_func=TestRenderTexture},
	{name="7_TestUncompless",create_func=TestUncompless},
	{name="TestPokerProbability",create_func=TestPokerProbability},
	
	
	
}




function SceneTest:ctor()
	self:init()
	self:enableNodeEvents()	

	self.m_labelStatus = cc.Label:createWithSystemFont("ggggg", "", 30)
	self.m_labelStatus:setPosition(display.width / 2,display.height/2-50)
	self:addChild(self.m_labelStatus)
end

function SceneTest:onEnter()

end

function SceneTest:init()


	self.m_scrollView = ccui.ScrollView:create()
	self:addChild(self.m_scrollView);
	self.m_scrollView:setContentSize(cc.size(display.width,display.height));
	self.m_scrollView:setPosition(display.center)
	--获取 Container
	local container = self.m_scrollView:getInnerContainer()
	

	--添加 ArrangeNode 更好的操作 scrollview
	local arrangeNode = cc.Node:create()
	self:addChild(arrangeNode)

	local dy = 50
	local len = #tests
	for i=1,len do
		local item = ccui.Button:create()
		item:setContentSize(cc.size(300,40))
		item:setTitleText(tests[i].name)		
		item:setTitleColor(cc.WHITE)--cc.c3b(_r,_g,_b))
		item:setTitleFontSize(40)
		--item:getTitleLabel():setAnchorPoint(cc.p(0.5,1))
		item:setAnchorPoint(cc.p(0,1))
		item:setPressedActionEnabled(true)
		item:addClickEventListener(function(sender)
			local layer = tests[i].create_func:create()
			cc.Director:getInstance():getRunningScene():addChild(layer)
		  end)

		arrangeNode:addChild(item)
		item:setPositionY(-(i-1)*dy)
	end



	local s = self.m_scrollView:getContentSize()
	local height = len*dy

	if height < s.height then
		height = s.height
	end

	arrangeNode:setPosition(20,height)

	self.m_scrollView:setInnerContainerSize(cc.size(s.width,height))
	--self.m_scrollView:scrollToTop(1.0,true)
	--self.m_scrollView:jumpToTop()
end

return SceneTest
