
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DealerItem = class("DealerItem",ccui.Layout);
BehaviorExtend(DealerItem);

local DealerConfig = require('DealerConfig')
local NetImageView = import("app.common.customUI").NetImageView

function DealerItem:ctor(data, bgSize)

    self.m_data = data or {}

    self:setAnchorPoint(cc.p(0.5,0.5))

    self.m_root = cc.Node:create()
    self:addChild(self.m_root)

    local bgNamePosition = cc.p(bgSize.width/2,bgSize.height*0.35)
    self.m_dealer = NetImageView:create(self:getDealerURL(),"creator/common/dialog/blank4x4.png")
    local deltaY = DealerConfig.CHANGEPOP_DELTAY[data.heguan_id] or 0
    self.m_root:setPosition(cc.p(bgNamePosition.x,bgNamePosition.y+100))

    self.m_root:addChild(self.m_dealer);

    self.m_dealer:setPosition(cc.p(0,deltaY))

    self.m_bgName = display.newSprite("creator/dealer/img/nochecked_name_bg.png",{capInsets = cc.rect(40,0,40,0)});
    self.m_root:addChild(self.m_bgName);
    self.m_bgName:setPosition(cc.p(0,-80))

    self.m_bgNameSelected = display.newSprite("creator/dealer/img/checked_name_bg.png",{capInsets = cc.rect(45,0,45,0)});
    self.m_root:addChild(self.m_bgNameSelected);
    self.m_bgNameSelected:setPosition(cc.p(0,-80))
    self.m_bgNameSelected:setVisible(false)

    self.m_txName = cc.Label:createWithSystemFont(data.heguan_name, nil, 24)
    self.m_txName:setTextColor(cc.c4b(86,34,3,255))
    self.m_root:addChild(self.m_txName)
    local bgNameSize = self.m_bgName:getContentSize()
    self.m_txName:setPosition(cc.p(0,-80))

    local nameBgSize = self.m_bgName:getContentSize()
    local nameBgSelectedSize = self.m_bgNameSelected:getContentSize()
    local nameSize = self.m_txName:getContentSize()
    self.m_bgName:setContentSize(cc.size(math.max(nameSize.width+80,nameBgSize.width),nameBgSize.height))
    self.m_bgNameSelected:setContentSize(cc.size(math.max(nameSize.width+90,nameBgSelectedSize.width),nameBgSelectedSize.height))
end

function DealerItem:getDealerURL()
    return g_AccountInfo:getCDNUrl() .. (self.m_data.mbpic or '')
end

function DealerItem:getId()
    return self.m_data.heguan_id;
end

function DealerItem:setId(id)
    -- self.m_id = id;
end

function DealerItem:getDesc()
    return self.m_data.heguan_desc
end

function DealerItem:getTexture()
    return self.m_dealer:getDataPath()
end

function DealerItem:getPrice()
    return self.m_data.heguan_price
end

function DealerItem:setToSelectDealer()
    g_Model:setData(g_ModelCmd.SELECTED_DEALER,self.m_data.heguan_id)
    g_AccountInfo:setDefaultHeguan(self.m_data.heguan_id)
end

function DealerItem:scrollStart()
    self.m_bgNameSelected:setVisible(false)
    self.m_bgName:setVisible(true)
    
    self:stopAllActions()

    local scaleAction = cc.ScaleTo:create(0.2,1)
    self.m_root:runAction(scaleAction)
end

function DealerItem:scrollEnd()
    self.m_bgNameSelected:setVisible(true)
    self.m_bgName:setVisible(false)

    self.m_root:stopAllActions()

    local scaleAction = cc.ScaleTo:create(0.2,1.2)
    self.m_root:runAction(scaleAction)
end

return DealerItem