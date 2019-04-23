--[[--ldoc desc
@module PropItem
@author RyanXu

Date   2018-12-12
]]

local PropItem = class("PropItem", cc.Node)
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
BehaviorExtend(PropItem);

PropItem.s_type = {
	{img = 'creator/bigWheel/img/prop_chip_100.png', title = GameString.get('str_bigWheel_item1'), winid = 1, scale = 0.7, probability = "23%"},
	{img = 'creator/bigWheel/img/prop_exp_double.png', title = GameString.get('str_bigWheel_item2'), winid = 9, scale = 0.7, probability = "6%"},
	{img = 'creator/bigWheel/img/prop_chip_5k.png', title = GameString.get('str_bigWheel_item3'), winid = 4, scale = 0.7, probability = "1%"},
	{img = 'creator/bigWheel/img/prop_prop.png', title = GameString.get('str_bigWheel_item4'), winid = 8, scale = 0.7, probability = "5%"},
	{img = 'creator/bigWheel/img/prop_exp_10.png', title = GameString.get('str_bigWheel_item5'), winid = 11, scale = 0.7, probability = "7%"},
	{img = 'creator/bigWheel/img/prop_chip_1k.png', title = GameString.get('str_bigWheel_item6'), winid = 3, scale = 0.7, probability = "11%"},
	{img = 'creator/bigWheel/img/prop_chip_500.png', title = GameString.get('str_bigWheel_item7'), winid = 2, scale = 0.7, probability = "19%"},
	{img = 'creator/bigWheel/img/prop_prop.png', title = GameString.get('str_bigWheel_item8'), winid = 6, scale = 0.7, probability = "3.99%"},
	{img = 'creator/bigWheel/img/prop_chip_3k.png', title = GameString.get('str_bigWheel_item9'), winid = 10, scale = 0.7, probability = "8%"},
	{img = 'creator/bigWheel/img/prop_prop.png', title = GameString.get('str_bigWheel_item10'), winid = 7, scale = 0.7, probability = "7%"},
	{img = 'creator/bigWheel/img/prop_chip_10m.png', title = GameString.get('str_bigWheel_item11'), winid = 5, scale = 0.7, probability = "0.01%"},
	{img = 'creator/bigWheel/img/prop_again.png', title = GameString.get('str_bigWheel_item12'), winid = 12, scale = 1.0, probability = "9%"},
}

function PropItem:ctor(propType)
	self:init(propType)
end

function PropItem:cleanUp()

end

function PropItem:init(propType)
	if type(propType) == 'number' and propType > 0 and propType < 13 then
		self:setAnchorPoint(cc.p(0.5,0))
		local config = PropItem.s_type[propType]
		local icon = display.newSprite(config.img)
		icon:setPosition(cc.p(0,170))
		icon:setScale(config.scale)
		self:addChild(icon)
		self.m_iconPath = config.img

		local title = cc.Label:createWithSystemFont(config.title,"",18);
		title:setPosition(cc.p(0,220))
		title:setColor(cc.c3b(179,189,255))
		self:addChild(title)
		self.m_title = config.title

		self.m_angle = 360/12*(propType-1)
		self:setRotation(self.m_angle)
		self.m_winId = config.winid

		self.m_imgScale = config.scale
	end
end

function PropItem:getWinId()
	return self.m_winId
end

function PropItem:getAngle()
	return self.m_angle
end

function PropItem:getIconPath()
	return self.m_iconPath
end

function PropItem:getTitle( )
	return self.m_title
end

function PropItem:getImgScale()
	return self.m_imgScale
end

return PropItem;