
local PopupLayer = require "scenes.layers.PopupLayer"


local TestCreatorRichText = class("TestCreatorRichText", PopupLayer)

function TestCreatorRichText:ctor()
	PopupLayer.ctor(self)

	self:init()
end

function TestCreatorRichText:dtor()

end


function TestCreatorRichText:createExitBt()
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

function TestCreatorRichText:createRenderTexture()

	 
end

function TestCreatorRichText:init()

	self.m_colorLayer:setOpacity(255)
	self:createExitBt()

	self:createBLTest2()
	
end


function  TestCreatorRichText:createRichText()
	local richText = CreatorRichText:create()
	richText:setAnchorPoint(cc.p(0,0))
	richText:setFontSize(20)
	richText:setFontFace(g_DefaultFontName)
	richText:setWrapMode(1)
	richText:setVerticalSpace(2)
	--ignoreContentAdaptWithSize 表示是否自动根据内容设置contentsize
	--richText:ignoreContentAdaptWithSize(false)
	richText:setContentSize(cc.size(200,60))

	
	return richText
end



function  TestCreatorRichText:createBLTest(data)
	

	self.m_richtext = self:createRichText()

	local newElement = ccui.RichElementText:create(0,ccc3(255,255,255),255,"one",g_DefaultFontName,20)
	self.m_richtext:pushBackElement(newElement)
	
	newElement = ccui.RichElementText:create(1,ccc3(255,0,255),255,"(two)",g_DefaultFontName,20)
    self.m_richtext:pushBackElement(newElement)

	local newElementLine = ccui.RichElementNewLine:create(2,ccc3(255,0,255),255)
	self.m_richtext:pushBackElement(newElementLine)
	
	newElement = ccui.RichElementText:create(3,ccc3(255,0,255),255,"three",g_DefaultFontName,40)
    self.m_richtext:pushBackElement(newElement)
	


	 newElementLine = ccui.RichElementNewLine:create(2,ccc3(255,0,255),255)
	self.m_richtext:pushBackElement(newElementLine)

	newElement = ccui.RichElementText:create(1,ccc3(255,0,255),255,"four",g_DefaultFontName,20)
    self.m_richtext:pushBackElement(newElement)

	--调用 formatText 会重新计算位置和大小
	
	self.m_richtext:formatText()
	self:addChild(self.m_richtext)

	return self.m_richtext
end

function  TestCreatorRichText:createBLTest2(data)

	self.m_richtext = self:createRichText()


	self.m_richtext:setXMLData("<color=#00ff00>Rich</color><color=#0fffff>Text</color>")


	--调用 formatText 会重新计算位置和大小
	
	self.m_richtext:formatText()
	self:addChild(self.m_richtext)

	return self.m_richtext
end

return TestCreatorRichText
