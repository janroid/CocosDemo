local AchievementCareerItem = AchievementCareerItem or class("AchievementCareerItem",ccui.Layout)

function AchievementCareerItem:ctor()
	self.is_selected = false
	self.spriteFrame = cc.SpriteFrameCache:getInstance()
	local bg = ccui.ImageView:create("creator/achievement/res/achieve_item.png", ccui.TextureResType.localType)
	bg:setAnchorPoint(0,0)
	self.bg = bg

	local title = cc.Label:createWithSystemFont("", nil, 16, cc.size(120,23), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	title:setTextColor(cc.c4b(136,192,255,255))
	-- title:setTextColor(cc.c4b(255,255,255,255))
	title:setPosition(63,23)
	title:setOverflow(cc.LabelOverflow.SHRINK)
	bg:add(title)
	self.title = title
    local mark = cc.Sprite:create("creator/userInfo/glory/glory_" .. 1001 .. ".png");
	-- local mark = ccui.ImageView:create("creator/achievement/res/glory/glory_1001-1.png", ccui.TextureResType.localType)	
	mark:setPosition(63,95)
	mark:setContentSize(cc.size(88,88))
	bg:add(mark)
	self.mark = mark

	
	local pro_bg = cc.Scale9Sprite:create(cc.rect(0,0,1,3), "creator/achievement/res/progress.png")
	pro_bg:setAnchorPoint(0,0)
	local width = 125 * 0.5
	pro_bg:setContentSize(cc.size(width,3))
	pro_bg:setPositionY(3);
	bg:add(pro_bg)
	self.progress_pic = pro_bg

	self.m_btnReceive = ccui.Button:create()
	self.m_btnReceive:loadTextureNormal("creator/achievement/res/achieve_btn.png", ccui.TextureResType.localType)
	self.m_btnReceive:setTitleFontSize(16)
	self.m_btnReceive:setTitleText(GameString.get("str_achi_get_reward"))
	self.m_btnReceive:setAnchorPoint(0,0)
	self.m_btnReceive:setPositionY(4)
	self.m_btnReceive:setZoomScale(-0.04)
	self.m_btnReceive:addClickEventListener(function (sender)
			self:onClickGetBtn(sender)
		end)
	bg:add(self.m_btnReceive)

	self:add(bg)
	self:setContentSize(158,125)
	self:setTouchEnabled(true)
	self:setSwallowTouches(false)
end

function AchievementCareerItem:updateView(data)
	if data == nil then
		self:setVisible(false)
		return
	else
		self:setVisible(true)
	end
	self.m_data =data
	-- Log.d("AchievementCareerItem:updateView data = ",data)

	local flag = self:getTag()
	self.title:setString(data.m_title) 
	local gloryItemInfo = self:getGlory(data.m_id)
	if data.m_isLocked then
		self.mark:setTexture("creator/userInfo/glory/glory_" .. data.m_id .. "_1.png")
		self.bg:loadTexture("creator/achievement/res/achieve_item.png", ccui.TextureResType.localType)
	else
		self.mark:setTexture("creator/userInfo/glory/glory_" .. data.m_id .. ".png")
		self.bg:loadTexture("creator/achievement/res/achieve_item_light.png", ccui.TextureResType.localType)
	end

	if data.m_isLocked == false 
	and (data.m_reward and data.m_reward ~= "") 
	and data.m_hasClaimed == false then
		self.m_btnReceive:setVisible(true)
		self.title:setVisible(false)
	else
		self.m_btnReceive:setVisible(false)
		self.title:setVisible(true)
	end
	if data.m_hasProgress then
		local width = 125
		if data.m_progress < 1 then
			width = 125 * tonumber(data.m_progress)
		end
		self.progress_pic:setContentSize(cc.size(width,3))
		self.progress_pic:setVisible(true)
	else
		self.progress_pic:setVisible(false)
	end
end

function AchievementCareerItem:getGlory(id)
	local config = g_Model:getData(g_ModelCmd.DATA_ACHIEVE_INFO)
	local achieveConfig = {}
	if  config and not g_TableLib.isEmpty(config) then
		achieveConfig = config:getConfig()
	end
	local ret = {};
    if id ~= nil then
        for i = 1, #achieveConfig do
            local item = achieveConfig[i];
            if tostring(item.a) == tostring(id) then
                ret = item;
                break;
            end
        end
    end
    return ret;
end

function AchievementCareerItem:getData()
	return self.m_data or {}
end

function AchievementCareerItem:onClickGetBtn(sender)
	local tag = self:getTag()
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.USER_GETUSERACHIREWARD)
	param.cjid = self.m_data.m_id
	g_HttpManager:doPost(param,self, self.resultHandlerClosure, self.resultHandlerClosure);
end

function  AchievementCareerItem:resultHandlerClosure(isSuccess,data)
	Log.d("AchievementCareerItem:resultHandlerClosure data ",data,isSuccess)
	if isSuccess and data then
        local flag = tonumber(data);
        if(flag >= 0) then
            self.m_data.m_hasClaimed = true;
			self:updateView(self.m_data);
			g_AlarmTips.getInstance():setText(GameString.get("str_glory_reward_claim_success")):show()
		elseif(flag < 0) then
			g_AlarmTips.getInstance():setText(GameString.get("str_glory_reward_claim_fail")):show()
        end
	else
		g_AlarmTips.getInstance():setText(GameString.get("str_glory_reward_claim_fail")):show()
    end
end

return AchievementCareerItem