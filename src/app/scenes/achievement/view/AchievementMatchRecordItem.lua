
local AchievementMatchRecordItem = AchievementMatchRecordItem or class("AchievementMatchRecordItem",ccui.Layout)

function AchievementMatchRecordItem:ctor()
	self.is_selected = false

	local bg = ccui.ImageView:create("creator/achievement/res/achieve_item.png", ccui.TextureResType.localType)
	bg:setAnchorPoint(0,0)
	self.bg = bg
	self:setContentSize(158,125)

	local title = GameString.createLabel("", g_DefaultFontName, 16, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	title:setTextColor(cc.c4b(136,192,255,255))
	-- title:setTextColor(cc.c4b(255,255,255,255))
	title:setPosition(63,23)
	bg:add(title)
	self.title = title

	local mark = ccui.ImageView:create("creator/achievement/res/glory/glory_1001-1.png", ccui.TextureResType.localType)	
	mark:setPosition(63,95)
	bg:add(mark)
	self.mark = mark

	local pro_bg = cc.Scale9Sprite:create(cc.rect(0,0,1,3), "creator/achievement/res/progress.png")
	pro_bg:setAnchorPoint(0,0)
	local width = 125 * 0.5
	pro_bg:setContentSize(cc.size(width,3))
	pro_bg:setPositionY(3);
	bg:add(pro_bg)
	self.progress_pic = pro_bg

	local btn = ccui.Button:create()
	btn:loadTextureNormal("creator/achievement/res/achieve_btn.png", ccui.TextureResType.localType)
	btn:setTitleFontName(g_DefaultFontName)
	btn:setTitleFontSize(16)
	btn:setTitleText(GameString.get("str_achi_get_reward"))
	btn:setAnchorPoint(0,0)
	btn:setPositionY(4)
	btn:setZoomScale(-0.04)
	btn:addClickEventListener(function (sender)
			self:onClickGetBtn(sender)
		end)
	bg:add(btn)

	self:add(bg)
	self:setContentSize(158,125)
	self:setTouchEnabled(true)
	self:setSwallowTouches(false)
end

function AchievementMatchRecordItem:updateView(data)	
	if data == nil then
		self:setVisible(false)
		return
	else
		self:setVisible(true)
	end
	-- self.title:setString("第".. flag .."次升级") 
	-- self.mark:loadTexture("creator/achievement/res/right_title_bg.png", ccui.TextureResType.localType)
	-- self.bg:loadTexture("creator/achievement/res/right_title_bg.png", ccui.TextureResType.localType)
	-- local width = 125 * 0.5
	-- self.progress_pic:setContentSize(cc.size(width,3))
	
end

function AchievementMatchRecordItem:onClickGetBtn(sender)
	local tag = self:getTag()
	print("点击后直接通用信息提示获得。显示获得道具即可",tag)
end

return AchievementMatchRecordItem