local AchievementTipsView = AchievementTipsView or class("AchievementTipsView",cc.Node)

function AchievementTipsView:ctor(data)
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/achievement/achievementTipsView.ccreator')
	self:add(self.m_root);
	-- self:setContentSize(display.size)
	self:findView(data)
	self:updateView(data)
end

function AchievementTipsView:findView(data)
	local shiled = g_NodeUtils:seekNodeByName(self.m_root, "shiled")
	-- shiled:move(0,0)
	shiled:setContentSize(display.size)
    shiled:setTouchEnabled(true)
	shiled:setSwallowTouches(true)
	shiled:addClickEventListener(function (sender)
		self:removeSelf()
	end)

	local content = g_NodeUtils:seekNodeByName(self.m_root, "content")
	content:setTouchEnabled(true)
	content:setSwallowTouches(true)
	content:move(display.cx + 115,display.cy-5)

	local noProgressHasReward = g_NodeUtils:seekNodeByName(self.m_root, "no_progress_has_reward")
	noProgressHasReward:setTouchEnabled(true)
	noProgressHasReward:setSwallowTouches(true)
	noProgressHasReward:move(display.cx + 115,display.cy-5)

	local hasProgressAndReword = g_NodeUtils:seekNodeByName(self.m_root, "have_progress_and_reword")
	hasProgressAndReword:setTouchEnabled(true)
	hasProgressAndReword:setSwallowTouches(true)
	hasProgressAndReword:move(display.cx + 115,display.cy-5)

	data = checktable(data);
	Log.d("AchievementTipsView:updateView data = ",data)
	local reward = data.m_reward
	local progress = data.m_progress
	local hasProgress = data.m_hasProgress
	local progressNum = data.m_progressNum
	

	if hasProgress then
		hasProgressAndReword:setVisible(true)
		noProgressHasReward:setVisible(false)
		content:setVisible(false)
		self.title = g_NodeUtils:seekNodeByName(hasProgressAndReword, "title")
		self.content_label = g_NodeUtils:seekNodeByName(hasProgressAndReword, "content_label")
		self.reward_label = g_NodeUtils:seekNodeByName(hasProgressAndReword, "label_reward")
		self.progress_bar = g_NodeUtils:seekNodeByName(hasProgressAndReword, "progress_bar")
		self.label_progress = g_NodeUtils:seekNodeByName(hasProgressAndReword, "label_progress")
	else
		if reward ~= nil and reward ~="" then
			hasProgressAndReword:setVisible(false)
			noProgressHasReward:setVisible(true)
			content:setVisible(false)
			self.title = g_NodeUtils:seekNodeByName(noProgressHasReward, "title")
			self.content_label = g_NodeUtils:seekNodeByName(noProgressHasReward, "content_label")
			self.reward_label = g_NodeUtils:seekNodeByName(noProgressHasReward, "label_reward")
		else
			hasProgressAndReword:setVisible(false)
			noProgressHasReward:setVisible(false)
			content:setVisible(true)
			self.title = g_NodeUtils:seekNodeByName(content, "title")
			self.content_label = g_NodeUtils:seekNodeByName(content, "content_label")
		end
	end
end

function AchievementTipsView:updateView(data)
	local title = data.m_title or ""
	local description = data.m_description or ""
	local reward = data.m_reward or ""
	local progress = data.m_progress
	local hasProgress = data.m_hasProgress
	local progressNum = data.m_progressNum
	self.title:setString(title)
	self.content_label:setString(description)
	if self.reward_label and reward then
		self.reward_label:setString(reward)
	end
	if self.label_progress and progressNum then
		self.label_progress:setString(progressNum)
	end
	if self.progress_bar then
		
		if tonumber(progress) then
			progress = tonumber(progress)>1 and 1 or progress
			local width = 242*tonumber(progress)
			self.progress_bar:setContentSize(cc.size(width,22))
		end
		
	end
end

return AchievementTipsView