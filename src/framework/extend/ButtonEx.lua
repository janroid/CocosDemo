

local Button = ccui.Button


function Button:addRedPoint(filename)
    filename = filename or "creator/common/button/red_point.png"
    self.m_spriteRedPoint = cc.Sprite:create(filename)
    self:addChild(self.m_spriteRedPoint)
    self:setRedPointToTR()
end


function Button:adjustRedPointPos(offX,offY)
    local x,y = self.m_spriteRedPoint:getPosition()
    self.m_spriteRedPoint:setPosition(x+offX,y+offY)
end

function Button:showRedPoint(bShow)
    self.m_spriteRedPoint:setVisible(bShow)
end

function Button:hideRedPoint()
    self.m_spriteRedPoint:setVisible(false)
end

function Button:setRedPointToTR()
    local s = self:getContentSize()
    self.m_spriteRedPoint:setPosition(s.width,s.height)
end

function Button:setRedPointToBR()
    local s = self:getContentSize()
    self.m_spriteRedPoint:setPosition(s.width,0)
end

function Button:setRedPointToTL()
    local s = self:getContentSize()
    self.m_spriteRedPoint:setPosition(0,s.height)
end

function Button:setRedPointToBL()
    local s = self:getContentSize()
    self.m_spriteRedPoint:setPosition(0,0)
end