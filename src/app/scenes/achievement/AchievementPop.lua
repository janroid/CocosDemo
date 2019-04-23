--[[--ldoc desc
@module AchievementPop
@author MenuZhang

Date   2018-11-1
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AchievementPop = class("AchievementPop",PopupBase);
BehaviorExtend(AchievementPop);

AchievementPop.PAGE = {
	AchievementCareer  =1;
	AchievementMatchRecord  =2;
	AchievementTongji  =3;
}

AchievementPop.s_eventFuncMap = {
	[g_SceneEvent.REQUEST_USER_GLORY_SUCCESS] = "loadGlorySuccess";
	[g_SceneEvent.REQUEST_USER_STATISTICS_SUCCESS] = "loadStatisticSuccess";
}

function AchievementPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".AchievementCtr"));
	self:init();
end

function AchievementPop:onCleanup()
	PopupBase.onCleanup(self);
end

function AchievementPop:init()
	-- do something
	self.select_tab = 1
	-- 加载布局文件
	self:loadLayout('creator/achievement/achievement.ccreator')
	-- self:add(self);
	
	self:findView()
end

function AchievementPop:show()
	PopupBase.show(self)
	self:loadGlory()
	self:loadStatistic()
end

function AchievementPop:findView()
	local content = g_NodeUtils:seekNodeByName(self, "pop_middle_bg")
	-- content:move(display.center)
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, "close_btn")
	self.m_btnClose:addClickEventListener(function(sender)
		self:hidden()
	end)
	self.pop_middle_left_bg = g_NodeUtils:seekNodeByName(self, "pop_middle_left_bg")
	self.m_titleImg = g_NodeUtils:seekNodeByName(self, "title_img")
	self.m_titleImg:setTexture(switchFilePath("achievement/title_img.png"))
	
	local AchievementCareer = require(".view.AchievementCareer")
	self.m_achievementCareer = AchievementCareer:create(self)
	self.m_achievementCareer:setPosition(283, 20)
	content:add(self.m_achievementCareer)

	local AchievementMatchRecord = require(".view.AchievementCareer")
	self.m_achievementMatchRecord = AchievementMatchRecord:create(self)
	self.m_achievementMatchRecord:setPosition(283, 20)
	content:add(self.m_achievementMatchRecord)
	self.m_achievementMatchRecord:setVisible(false)

	local AchievementTongji = require(".view.AchievementTongji")
	self.m_achievementTongji = AchievementTongji:create(self)
	self.m_achievementTongji:setPosition(270, 10)
	content:add(self.m_achievementTongji)
	self.m_achievementTongji:setVisible(false)

	self:createLeftTab()
end

function AchievementPop:createLeftTab()
	local config = {
		{
			key = GameString.get("str_achi_title_achieve"),
			content = {
				GameString.get("str_achi_title_life"),
				GameString.get("str_achi_title_record"),
			}
		},
		{
			key = GameString.get("str_achi_title_stic"),
			content = {
				GameString.get("str_achi_title_data_stic"),
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

function AchievementPop:createLeftTabTitle(title_str)
	title_str = title_str or ""
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0,1))
	layout:setBackGroundImage("creator/achievement/res/title_bottom.png")
	layout:setContentSize(214,48)

	local decoration_img = cc.Sprite:create()
	decoration_img:setTexture("creator/achievement/res/title_decoration.png")
	decoration_img:setPosition(107,24)
	layout:add(decoration_img)

	local title = cc.Label:createWithSystemFont(title_str,nil, 22, cc.size(80,40), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	title:setTextColor(cc.c4b(103,168,249,255))
	title:setPosition(107,24)
	title:setOverflow(cc.LabelOverflow.SHRINK)
	layout:add(title)

	return layout
end

function AchievementPop:createLeftTabButton(title_str)
	title_str = title_str or ""
	local layout = ccui.Layout:create()
	layout:setAnchorPoint(cc.p(0.5,0.5))
	layout:setContentSize(214,78)

	local title = cc.Label:createWithSystemFont(title_str, nil, 26, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	title:setTextColor(cc.c4b(254,254,254,255))
	title:setPosition(107,36)
	layout:add(title)

	return layout
end

function AchievementPop:createRightSubview()
	
end

---刷新界面
function AchievementPop:updateView(data)
	data = checktable(data);
end

function AchievementPop:onClickLeftTab(sender)
	if self.select_tab == sender.tag then return end
	self.select_tab = sender.tag
	local x, y = sender:getPosition()
	self.left_select_img:moveTo({x=x, y=y,time = 0.15})

	if sender.tag ==  AchievementPop.PAGE.AchievementCareer then
		self.m_achievementCareer:setVisible(true)
		self.m_achievementMatchRecord:setVisible(false)
		self.m_achievementTongji:setVisible(false)
	elseif sender.tag ==  AchievementPop.PAGE.AchievementMatchRecord then
		self.m_achievementCareer:setVisible(false)
		self.m_achievementTongji:setVisible(false)
		self.m_achievementMatchRecord:setVisible(true)
	elseif sender.tag ==  AchievementPop.PAGE.AchievementTongji then
		self.m_achievementCareer:setVisible(false)
		self.m_achievementMatchRecord:setVisible(false)
		self.m_achievementTongji:setVisible(true)
	end
end

-- 请求
function AchievementPop:loadGlory()
	g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_GLORY)
end

function AchievementPop:loadGlorySuccess(data)
	local gloryData = data.gloryData or {}
	local matchData = data.matchData or {}
	if self.m_achievementCareer then 
		self.m_achievementCareer:updateView(gloryData)
	end
	if self.m_achievementMatchRecord then 
		self.m_achievementMatchRecord:updateView(matchData)
	end
end

-- 请求
function AchievementPop:loadStatistic()
	g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_STATISTICS)
end

function AchievementPop:loadStatisticSuccess(data)
	Log.d("AchievementPop:loadStatisticSuccess data = ",data)
	if self.m_achievementTongji then 
		self.m_achievementTongji:setData(data)
	end
end

return AchievementPop;