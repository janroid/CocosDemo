local  RewardItem = class("RewardItem",cc.Node)
local NetImageView = import("app.common.customUI").NetImageView

function RewardItem:ctor(data)
    self.m_root =  g_NodeUtils:getRootNodeInCreator("creator/mailBox/layout/mail_reward_item.ccreator")
    self:addChild(self.m_root)
    self.m_root:setPosition(0,0)
    self.mailSpriteFrame = cc.SpriteFrameCache:getInstance()
    self:setContentSize(self.m_root:getContentSize())
    self.m_rewardCount = g_NodeUtils:seekNodeByName(self.m_root,"reward_count")
    self.m_rewardItemBg = g_NodeUtils:seekNodeByName(self.m_root,"reward_item_bg")
    self.m_rewardItemLightBg = g_NodeUtils:seekNodeByName(self.m_root,"reward_item_light_bg")
    self.m_rewardImgContainer = g_NodeUtils:seekNodeByName(self.m_root,"reward_img_container")
    self.m_rewardItemNameBg = g_NodeUtils:seekNodeByName(self.m_root,"reward_item_name_bg")
    self.m_rewardItemName = g_NodeUtils:seekNodeByName(self.m_root,"reward_item_name")
    self.m_rewardImgContainer:setVisible(false)
    self.m_data = data
    Log.d("RewardItem:ctor  data = ",data)
    self:updateView(data)
end

function RewardItem:updateView(data)
    if data.type == "props" then
        self.m_rewardCount:setString("x".. data.val .. data.unit)
    else
        self.m_rewardCount:setString("x".. data.val)
    end
    -- self:setReward("x".. data.val)
    self.m_rewardItemName:setString(data.name)
    if data and data.pic then
        -- local  url = "http://bigfile-ak-static.boyaagame.com/ipk/" .. data.pic
        local  url =  g_AccountInfo:getCDNUrl() .. data.pic
        self.m_rewardIcon = NetImageView:create(url)
        local size = self.m_rewardImgContainer:getContentSize()
        local width = size.width
        local height = size.height
        local x,y = self.m_rewardImgContainer:getPosition()
        self.m_rewardIcon:ignoreContentAdaptWithSize(false) 
        self.m_rewardIcon:setContentSize(cc.size(126,126))
        self.m_rewardIcon:setPosition(cc.p(width/2,height/2))
        self.m_rewardIcon:setAnchorPoint(cc.p(0.5,0.5))
        self.m_rewardImgContainer:addChild(self.m_rewardIcon)
    elseif data and data.lpic then
        
        self.m_rewardIcon = cc.Sprite:create(data.lpic)
        local size = self.m_rewardImgContainer:getContentSize()
        local width = size.width
        local height = size.height
        local x,y = self.m_rewardImgContainer:getPosition()
        self.m_rewardIcon:setContentSize(cc.size(126,126))
        self.m_rewardIcon:setPosition(cc.p(width/2,height/2))
        self.m_rewardIcon:setAnchorPoint(cc.p(0.5,0.5))
        self.m_rewardImgContainer:addChild(self.m_rewardIcon)
    end
end

-- function RewardItem:setReward(str)
--     self.m_rewardCount:setString(str)
-- end

function RewardItem:showItemAnim(callback)
    self.m_spriteFrame = cc.Sprite:createWithSpriteFrameName("mail_item_anim_1.png")
    self.m_spriteFrame:setContentSize(cc.size(210,209))
    self.m_root:addChild(self.m_spriteFrame)
    self.m_spriteFrame:setVisible(false)
    g_NodeUtils:arrangeToTopCenter(self.m_spriteFrame,0,25)
    self.m_rewardCount:setOpacity(0)
    self.m_rewardItemNameBg:setOpacity(0)
    self.m_rewardItemBg:setScale(0.5)

    self.m_rewardItemLightBg:setOpacity(0)
    local actionFadeIn = cc.FadeIn:create(0.4)
    local actionFadeOut = cc.FadeOut:create(0.1)
    self.m_rewardItemLightBg:runAction(cc.Sequence:create(actionFadeIn, actionFadeOut))

    local actionScale1 = cc.ScaleTo:create(0.2,1.1)
    local actionScale2 = cc.ScaleTo:create(0.2,1)
    local seqScale1 = cc.Sequence:create(actionScale1,cc.CallFunc:create(function()
        self.m_rewardImgContainer:setVisible(true)
        self.m_spriteFrame:setVisible(true)
        local animation = cc.Animation:create()   
        for i = 1,3 do
            local frameName = string.format("mail_item_anim_%s.png",i)                                                      
            local spriteFrame = self.mailSpriteFrame:getSpriteFrame(frameName)    
            animation:addSpriteFrame(spriteFrame)                                                                 
        end
        animation:setDelayPerUnit(0.04)          --设置两个帧播放时间 
        animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态
        local action =cc.Animate:create(animation)  
        local seq = cc.Sequence:create(action,cc.CallFunc:create(function()
            self.m_spriteFrame:setVisible(false) 
            self.m_rewardItemBg:setScale(1)
            -- self.m_rewardItemLightBg:setVisible(false)  
            if callback then
                callback()
            end 
        end))
        self.m_spriteFrame:runAction(seq)

        local nameBgFadeIn = cc.FadeIn:create(0.2)
        local rewardCountFadeIn = cc.FadeIn:create(0.2)
        self.m_rewardItemNameBg:runAction(nameBgFadeIn)
        self.m_rewardCount:runAction(rewardCountFadeIn)
             
        
    end),actionScale2,cc.CallFunc:create(function()
        self.m_rewardCount:setVisible(true)
        self.m_rewardItemNameBg:setVisible(true)
        self.m_rewardItemName:setVisible(true)
    end))
    self.m_rewardItemBg:runAction(seqScale1)
end

function RewardItem:stopActions()
    if self.m_rewardCount then
        self.m_rewardCount:stopAllActions()
    end
    if self.m_rewardItemNameBg then
        self.m_rewardItemNameBg:stopAllActions()
    end
    if self.m_rewardItemBg then
        self.m_rewardItemBg:stopAllActions()
    end
    if self.m_rewardItemLightBg then
        self.m_rewardItemLightBg:stopAllActions()
    end
    if  self.m_spriteFrame then
        self.m_spriteFrame:stopAllActions()
    end
end

return RewardItem