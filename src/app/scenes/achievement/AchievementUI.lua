--[[--ldoc desc
@module AchievementUI
@author MenuZhang

Date   2018-11-1
]]
local ViewUI = import("framework.scenes").ViewUI
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AchievementUI = class("AchievementUI",ViewUI);
BehaviorExtend(AchievementUI);

function AchievementUI:ctor()
	ViewUI.ctor(self);
	self:bindCtr(require(".AchievementCtr"));
	self:init();
end

function AchievementUI:onCleanup()
	self:unBindCtr();
end

function AchievementUI:init()
	-- do something
	self.select_tab = 1
	-- 加载布局文件
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/achievement/achievement.ccreator')
	self:add(self.m_root);
	
	self:findView()
end

function AchievementUI:findView()
	local shiled = g_NodeUtils:seekNodeByName(self.m_root, "shiled")
	shiled:move(0,0)
	shiled:setContentSize(display.size)
	shiled:setTouchEnabled(true)
	shiled:setSwallowTouches(true)

	local content = g_NodeUtils:seekNodeByName(self.m_root, "content")
	content:move(display.center)

	self.pop_middle_left_bg = g_NodeUtils:seekNodeByName(self.m_root, "pop_middle_left_bg")

	local Tab1 = require(".view.AchievementCareer")
	self.tab1 = Tab1:create(self)
	self.tab1:setPosition(283, 20)
	content:add(self.tab1)

	local Tab2 = require(".view.AchievementMatchRecord")
	self.tab2 = Tab2:create(self)
	self.tab2:setPosition(283, 20)
	content:add(self.tab2)
	self.tab2:setVisible(false)

	local Tab3 = require(".view.AchievementTongji")
	self.tab3 = Tab3:create(self)
	self.tab3:setPosition(270, 10)
	content:add(self.tab3)
	self.tab3:setVisible(false)

	self:createLeftTab()
end

function AchievementUI:createLeftTab()
	local config = {
		{
			key = "成就",
			content = {
				"生涯",
				"战绩",
			}
		},
		{
			key = "统计",
			content = {
				"数据统计",
			}
		}
	}

	local flag = 1
	local parent = self.pop_middle_left_bg
	local height = parent:getContentSize().height - 15
	for k,v in pairs(config) do
		local title = self:createLeftTabTitle(v.key)
		title:setPositionY(height)
		parent:add(title)

		height = height - title:getContentSize().height
		local divide = cc.Sprite:create()
		divide:setTexture("creator/common/dialog/left_item_divide.png")
		divide:setPosition(107, height)
		parent:add(divide)

		for k1,v1 in pairs(v.content) do
			local text_layout = self:createLeftTabButton(v1)
			text_layout:setTouchEnabled(true)
			text_layout.tag = flag
			text_layout:addClickEventListener(function (sender)
				self:onClickLeftTab(sender)
			end)
			local size = text_layout:getContentSize()
			text_layout:setPosition(size.width/2, height - size.height/2)
			parent:add(text_layout, 2)
			flag = flag + 1

			if not self.left_select_img then
				local item_checked = cc.Sprite:create()
				item_checked:setTexture("creator/common/dialog/left_item_checked.png")
				item_checked:setPosition(107, height - 39)
				parent:add(item_checked, 1)
				self.left_select_img = item_checked
			end

			height = height - 78
			local divide = cc.Sprite:create()
			divide:setTexture("creator/common/dialog/left_item_divide.png")
			divide:setPosition(107, height)
			parent:add(divide)
		end
	end
end

function AchievementUI:createLeftTabTitle(title_str)
	title_str = title_str or ""
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0,1))
	layout:setBackGroundImage("creator/achievement/res/title_bottom.png")
	layout:setContentSize(214,48)

	local decoration_img = cc.Sprite:create()
	decoration_img:setTexture("creator/achievement/res/title_decoration.png")
	decoration_img:setPosition(107,24)
	layout:add(decoration_img)

	local title = GameString.createLabel(title_str, g_DefaultFontName, 22, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	title:setTextColor(cc.c4b(103,168,249,255))
	title:setPosition(107,24)
	layout:add(title)

	return layout
end

function AchievementUI:createLeftTabButton(title_str)
	title_str = title_str or ""
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0.5,0.5))
	layout:setContentSize(214,78)

	local title = GameString.createLabel(title_str, g_DefaultFontName, 26, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	title:setTextColor(cc.c4b(254,254,254,255))
	title:setPosition(107,36)
	layout:add(title)

	return layout
end

function AchievementUI:createRightSubview()
	
end

---刷新界面
function AchievementUI:updateView(data)
	data = checktable(data);
end

function AchievementUI:onClickLeftTab(sender)
	if self.select_tab == sender.tag then return end
	self["tab"..self.select_tab]:setVisible(false)
	self.select_tab = sender.tag
	local x, y = sender:getPosition()
	self.left_select_img:moveTo({x=x, y=y,time = 0.15})

	if self["tab"..sender.tag] then
		self["tab"..sender.tag]:setVisible(true)
	end
end

return AchievementUI;