--[Comment]
--经验
local ExpSprite = class("ExpSprite", cc.Node)
ExpSprite.ctor = function(self)
    --self.m_root         = SceneLoader.load(layout_room_exp);
    self.m_imgExp       = cc.Sprite:create()
    self.m_txtExp       = cc.Label:createWithSystemFont("", nil, 24)
    self.m_getExpImg    = "creator/normalRoom/img/exp/room-user-increase-exp.png";    --获取经验时的图片
    self.m_lostExpImg   = "creator/normalRoom/img/exp/room-user-decrease-exp.png";    --失去经验时的图片
    self.m_getExpColor  = cc.c3b(0xFF, 0x7F, 0x01)   --获取经验时，文字的颜色
    self.m_lostExpColor = cc.c3b(0x79, 0x78, 0x76)   --失去经验时，文字的颜色
    self:addChild(self.m_imgExp)
    self:addChild(self.m_txtExp)
    self.m_txtExp:setPosition(cc.p(0, -20))
end

ExpSprite.setExp = function(self, exp)
--[[    self.m_exp = exp;
    local Y = 114;
    KTween.remove(self);
    if exp > 0 then
        self.m_imgExp:setFile(self.m_getExpImg);
        self.m_txtExp:setColor(RGBKit.getRGB(self.m_getExpColor));
        self.m_txtExp:setText("+"..exp);
        KTween.to(self, 1600, {startY = Y, y = 0,easeType = EaseType.SinOut, onComplete = self.onComplete, obj = self, delay = 500});
    elseif exp < 0 then
        self.m_imgExp:setFile(self.m_lostExpImg);
        self.m_txtExp:setColor(RGBKit.getRGB(self.m_lostExpColor));
        self.m_txtExp:setText(tostring(exp));
        KTween.to(self, 1600, {startY = 0, y = Y,easeType = EaseType.SinOut, onComplete = self.onComplete, obj = self, delay = 500});
    end

    if exp ~= 0 then
       self:setParentVisible(true);
    end
    ]]
    if(type(exp) == "number") then
        if exp > 0 then
            self.m_imgExp:setTexture(self.m_getExpImg);
            self.m_txtExp:setColor(self.m_getExpColor)
            self.m_txtExp:setString("+"..exp);
        elseif exp < 0 then
            self.m_imgExp:setTexture(self.m_lostExpImg);
            self.m_txtExp:setColor(self.m_lostExpColor)
            self.m_txtExp:setString(tostring(exp))
        end
    end
end

return ExpSprite