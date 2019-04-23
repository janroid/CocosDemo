local RewardAnim = class("RewardAnim",cc.Node)
local MailRewardItem = require(".RewardItem")

function RewardAnim:ctor(data) 
    if g_TableLib.isEmpty(data) or (not data) or #data <1 then
        return 
    end    
    self:registEvent() 	
    self.m_root =  g_NodeUtils:getRootNodeInCreator("creator/mailBox/layout/mail_reward.ccreator")
    self:addChild(self.m_root)
    self:setLocalZOrder(KZOrder.Anim)
    self:initScene()
    self:initEvent()
    self:updateView(data)
    g_EventDispatcher:register(g_SceneEvent.EVENT_BACK,self,self.onEventBack,1)
end

function RewardAnim:onEventBack()
    --self:dismiss()
   return true
end

function  RewardAnim:initScene()
    self.mailSpriteFrame = cc.SpriteFrameCache:getInstance()
    self.mailSpriteFrame:addSpriteFrames("creator/mailBox/mail_title_anim.plist")
    self.m_bg = g_NodeUtils:seekNodeByName(self.m_root,"pop_transparency_bg")
    self.m_btnGetReward = g_NodeUtils:seekNodeByName(self.m_root,"btn_get_reward")
    self.m_btnGetRewardTxt = g_NodeUtils:seekNodeByName(self.m_root,"txt_get_reward")
    self.m_rewardScrollView = g_NodeUtils:seekNodeByName(self.m_root,"reward_scroll_view")
    self.m_rewardLightBottom = g_NodeUtils:seekNodeByName(self.m_root,"reward_light_bottom")
    self.m_rewardLightBlue = g_NodeUtils:seekNodeByName(self.m_root,"reward_light_blue")
    self.m_rewardLightUp = g_NodeUtils:seekNodeByName(self.m_root,"reward_light_up")
    self.m_rewardTransLight1 = g_NodeUtils:seekNodeByName(self.m_root,"reward_trans_light1")
    self.m_rewardTransLight2 = g_NodeUtils:seekNodeByName(self.m_root,"reward_trans_light2")
    self.m_rewardTransLight3 = g_NodeUtils:seekNodeByName(self.m_root,"reward_trans_light3")
    self.m_rewardTitleBg = g_NodeUtils:seekNodeByName(self.m_root,"reward_title_bg")
    self.m_rewardTitle = g_NodeUtils:seekNodeByName(self.m_root, "reward_title")
    
    self.m_rewardTitle:setTexture(switchFilePath("mailBox/reward_title.png"))

    self.m_rewardTransLight1:setVisible(false)
    self.m_rewardTransLight2:setVisible(false)
    self.m_rewardTransLight3:setVisible(false)
    self.m_rewardScrollView:setVisible(false)
    self.m_rewardTitleBg:setVisible(false)
    self.m_rewardScrollView:setBounceEnabled(false)
    self.m_btnGetRewardTxt:setString(GameString.get("str_logout_btn_confirm"))
end

function RewardAnim:registEvent()
    local function onNodeEvent(event)     
        if event == "enter" then                                       
            self:onEnter()                            
        elseif event == "exit" then                                      
            self:onExit()                       
        elseif event == "cleanup" then                                   
            self:onCleanup()                                      
        end  
    end 
    self:registerScriptHandler(onNodeEvent) 
end

function RewardAnim:initEvent()
    self.m_bg:addClickEventListener(function() end)
    self.m_btnGetReward:addClickEventListener(function() 
        self:dismiss()
    end)
end

function RewardAnim:updateView(data)
    local viewSize = self.m_rewardScrollView:getContentSize()
    local containerWidth = viewSize.width
    local containerHeight = viewSize.height
    local dy,dx = 10, 30
    local container = self.m_rewardScrollView:getInnerContainer()
    local itemSizeW,itemSizeH
    local len = #data
    -- len = 8
    local line = 0
    local arrangeNode = cc.Node:create()
    arrangeNode:setTag(1)
    container:addChild(arrangeNode)
    arrangeNode:setAnchorPoint(cc.p(0,0))
    for i=0, len-1 do
        local itemNode = MailRewardItem:create(data[i+1])
        local itemSize = itemNode:getContentSize()
        itemSizeW = itemSize.width
        itemSizeH = itemSize.height
        itemNode:setAnchorPoint(cc.p(0,0))
        itemNode:setTag(i)
        arrangeNode:addChild(itemNode)
        local itemSize = itemNode:getContentSize()
        -- itemNode:setReward("第".. i .. "个")
        local mod = math.mod(i,3)
        if math.mod(i,3) == 0 then 
            line = line+1
        end
        local x,y
        if math.mod(len,3) == 1 then
            if i == len-1 then
                x, y =dx+dx+itemSizeW, -line*(itemSizeH+dy)
            else
                x, y =dx+(dx+itemSizeW)*mod, -line*(itemSizeH+dy)
            end
        elseif  math.mod(len,3) == 2 then
            if i == len -1 or i == len -2 then
                x, y =100+dx+(dx+itemSizeW)*mod, -line*(itemSizeH+dy)
            else
                x, y =dx+(dx+itemSizeW)*mod, -line*(itemSizeH+dy)
            end
        else
            x, y =dx+(dx+itemSizeW)*mod, -line*(itemSizeH+dy)
        end
        itemNode:setPosition(cc.p(x, y))
	end
    
    local height = line*(itemSizeH+dy)
    if height < containerHeight then
        height = containerHeight
	end
    arrangeNode:setPosition(cc.p(10,height))
    self.m_rewardScrollView:setInnerContainerSize(cc.size(containerWidth,height))
    self.m_rewardScrollView:setScrollBarWidth(0)
    self.m_rewardScrollView:jumpToTop()
    self:showAnim()
end

function RewardAnim:run()
    cc.Director:getInstance():getRunningScene():addChild(self)
end

function RewardAnim:showAnim()
    
    self:showDiffusionAnim()
    self.m_rewardLightBlue:setScale(0.25)
    self.m_rewardLightBottom:setScale(0.25)
    self.m_rewardLightUp:setOpacity(0)

    local lightBlueScale = cc.ScaleTo:create(0.2,1)
    self.m_rewardLightBlue:runAction(lightBlueScale)

    local lightBottomScale1 = cc.ScaleTo:create(0.2,0.8)
    local lightBottomScale2 = cc.ScaleTo:create(0.2,1)

    local seqScale1 = cc.Sequence:create(lightBottomScale1,cc.CallFunc:create(function()
        self.m_rewardTransLight1:setVisible(true)
        self.m_rewardTransLight2:setVisible(true)
        self.m_rewardTransLight3:setVisible(true)
        self.m_rewardTransLight1:setScale(0)
        self.m_rewardTransLight2:setScale(0)
        self.m_rewardTransLight3:setScale(0)
        local lightSeq1 = cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function() 
            local actionRotate1 =  cc.RotateBy:create(8,360)
            self.m_rewardTransLight1:runAction(cc.RepeatForever:create(actionRotate1))
        end))
        local lightSeq2 = cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function() 
            local actionRotate2 =  cc.RotateBy:create(8,360)
            self.m_rewardTransLight2:runAction(cc.RepeatForever:create(actionRotate2))
        end))
        local lightSeq3 = cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.CallFunc:create(function() 
            local actionRotate3 =  cc.RotateBy:create(8,-360)
            self.m_rewardTransLight3:runAction(cc.RepeatForever:create(actionRotate3))
        end))
        self.m_rewardTransLight1:runAction(lightSeq1)
        self.m_rewardTransLight2:runAction(lightSeq2)
        self.m_rewardTransLight3:runAction(lightSeq3)
        self.m_rewardScrollView:setVisible(true)
        self:showItemAnim()
        self:showTitleAnim()
        self.m_rewardLightUp:setOpacity(255)
        local actionFadeOut = cc.FadeOut:create(0.375)
        self.m_rewardLightUp:runAction(actionFadeOut)
    end),lightBottomScale2)
    self.m_rewardLightBottom:runAction(seqScale1)

    local rewardLightUpScale1 = cc.ScaleTo:create(0.2,2)
    local rewardLightUpScale2 = cc.ScaleTo:create(0.2,1)
    local rewardLightUpScaleSeq = cc.Sequence:create(rewardLightUpScale1,rewardLightUpScale2)
    self.m_rewardLightUp:runAction(rewardLightUpScaleSeq)

    local btnGetScale1 = cc.ScaleTo:create(0.15,1.2)
    local btnGetScale2 = cc.ScaleTo:create(0.15,1)
    local btnGetSeq = cc.Sequence:create(btnGetScale1,btnGetScale2)
    self.m_btnGetReward:runAction(btnGetSeq)
end


-- 放射光线 帧动画
function RewardAnim:showDiffusionAnim()
    self.m_spriteDiffusion = cc.Sprite:create("creator/mailBox/mail_reward_diffusion_1.png")
    self.m_spriteDiffusion:setContentSize(cc.size(1280,720))
    self.m_root:addChild( self.m_spriteDiffusion)
    g_NodeUtils:arrangeToCenter( self.m_spriteDiffusion)
    local animation = cc.Animation:create()   
    for i = 1,16 do
        local frameName = string.format("creator/mailBox/mail_reward_diffusion_%s.png",i)                                                      
        local spriteFrame = cc.SpriteFrame:create(frameName,cc.rect(0,0,1280,720))    
        animation:addSpriteFrame(spriteFrame)                                                                 
    end

    animation:setDelayPerUnit(0.04)          --设置两个帧播放时间   
    animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态 

    local action =cc.Animate:create(animation)    
    self.m_spriteDiffusion:runAction(cc.Sequence:create(action,cc.CallFunc:create(function()
        self.m_spriteDiffusion:setVisible(false)
    end)))
end

function RewardAnim:showTitleAnim()
    self.m_rewardTitleBg:setVisible(true)
    self.m_rewardTitleBg:setOpacity(0)
    self.m_rewardTitleBg:runAction(cc.FadeIn:create(0.4))
    self.m_titleSpriteLeft = cc.Sprite:createWithSpriteFrameName("mail_title_1.png")
    self.m_titleSpriteLeft:setContentSize(cc.size(60,40))
    self.m_rewardTitleBg:addChild(self.m_titleSpriteLeft)
    g_NodeUtils:arrangeToLeftCenter(self.m_titleSpriteLeft,60)
    local animation = cc.Animation:create()   
    for i = 1,42 do
        local frameName = string.format("mail_title_%s.png",i)                                                      
        local spriteFrame = self.mailSpriteFrame:getSpriteFrame(frameName)    
        animation:addSpriteFrame(spriteFrame)                                                                 
    end

    animation:setDelayPerUnit(0.05)          --设置两个帧播放时间                      ⑥
    animation:setRestoreOriginalFrame(true)    --动画执行后还原初始状态 

    local action =cc.Animate:create(animation)    
    self.m_titleSpriteLeft:runAction(cc.RepeatForever:create(action))

    self.m_titleSpriteRight = cc.Sprite:createWithSpriteFrameName("mail_title_1.png")
    self.m_titleSpriteRight:setContentSize(cc.size(60,40))
    self.m_titleSpriteRight:setRotation(180)
    self.m_rewardTitleBg:addChild(self.m_titleSpriteRight)
    g_NodeUtils:arrangeToRightCenter(self.m_titleSpriteRight,-60)
    local animation2 = cc.Animation:create()   
    for i = 1,42 do
        local frameName = string.format("mail_title_%s.png",i)                                                      
        local spriteFrame = self.mailSpriteFrame:getSpriteFrame(frameName) 
        animation2:addSpriteFrame(spriteFrame)                                                                 
    end

    animation2:setDelayPerUnit(0.05)          --设置两个帧播放时间      
    animation2:setRestoreOriginalFrame(true)    --动画执行后还原初始状态

    local action2 =cc.Animate:create(animation2)    
    self.m_titleSpriteRight:runAction(cc.RepeatForever:create(action2))
end

function RewardAnim:showItemAnim()
    local innerContainer = self.m_rewardScrollView:getInnerContainer()
    local nodeArrange = innerContainer:getChildByTag(1)
    self.m_children1 = nodeArrange:getChildByTag(0)	
    self.m_children2 = nodeArrange:getChildByTag(1)	
    self.m_children3 = nodeArrange:getChildByTag(2)	
    if self.m_children1 then  self.m_children1:setVisible(false) end
    if self.m_children2 then  self.m_children2:setVisible(false) end
    if self.m_children3 then  self.m_children3:setVisible(false) end
    if self.m_children1 then
        self.m_children1:setVisible(true)
        self.m_children1:showItemAnim(function()
            if self.m_children2 then
                self.m_children2:setVisible(true)
                self.m_children2:showItemAnim(function()
                    if self.m_children3 then
                        self.m_children3:setVisible(true)
                        self.m_children3:showItemAnim()
                    end
                end)
            end
        end)
    end

end

function RewardAnim:onCleanup()
    Log.d("RewardAnim:onCleanup")
    g_EventDispatcher:unregister(g_SceneEvent.EVENT_BACK,self,self.onEventBack)
   --[[ if self.m_rewardTitleBg then
        self.m_rewardTitleBg:stopAllActions()
    end
    if self.m_titleSpriteRight then
        self.m_titleSpriteRight:stopAllActions()
    end
    if  self.m_titleSpriteLeft then
        self.m_titleSpriteLeft:stopAllActions()
    end
    if self.m_spriteDiffusion then 
        self.m_spriteDiffusion:stopAllActions()
    end 
    if self.m_btnGetReward then
        self.m_btnGetReward:stopAllActions()
    end
    if self.m_rewardLightBottom then
        self.m_rewardLightBottom:stopAllActions()
    end
    if self.m_rewardLightBlue then
        self.m_rewardLightBlue:stopAllActions()
    end
    if self.m_rewardLightBottom then
        self.m_rewardLightBottom:stopAllActions()
    end
    if self.m_rewardLightUp then
        self.m_rewardLightUp:stopAllActions()
    end
    if self.m_rewardTransLight1 then
        self.m_rewardTransLight1:stopAllActions()
    end
    if self.m_rewardTransLight2 then
        self.m_rewardTransLight2:stopAllActions()
    end
    if self.m_rewardTransLight3 then
        self.m_rewardTransLight3:stopAllActions()
    end
    if self.m_children1 then  
        self.m_children1:stopActions() 
    end
    if self.m_children2 then  
        self.m_children2:stopActions() 
    end
    if self.m_children3 then  
        self.m_children3:stopActions()
     end]]
end

function RewardAnim:dismiss()
    
    self:removeFromParent()
end

return RewardAnim