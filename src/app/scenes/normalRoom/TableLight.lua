local TableLight = class("TableLight");

TableLight.s_enable = true;

function TableLight:ctor(lightView)
    self.m_view = lightView
    local size = self.m_view:getContentSize();
    self.m_defaultHeight = size.height;
    self.m_sizeX = size.width;
    --self:setPos((System.getScreenScaleWidth() - self.m_sizeX)/2 , System.getScreenScaleHeight()/2-35);
end

function TableLight:setVisible(visible)
    self.m_view:setVisible(visible)
end

-- 设置角度，Y轴缩放系数
-- @param targetPoint	目标点
-- @param isTween		是否有动画
function TableLight:setRotation(targetPoint, tweenDuration)
    if(not TableLight.s_enable) then
        return;
    end
    local xThis,yThis = self.m_view:getPosition()
    --计算Y轴缩放
    local scaleYValue = math.sqrt((targetPoint.x - xThis) * (targetPoint.x - xThis) + (targetPoint.y - yThis) * (targetPoint.y - yThis)) / self.m_defaultHeight;
    
    
    --计算偏移角度
    local rotationValue = 90;
    if (targetPoint.y == yThis) then
        rotationValue = targetPoint.x > xThis and -math.pi * 0.5 or math.pi * 0.5;
    elseif (targetPoint.x == xThis) then
        rotationValue = targetPoint.y > yThis and 0 or math.pi;
    else
        rotationValue = math.atan((xThis - targetPoint.x) / (targetPoint.y - yThis));
        if (targetPoint.x > xThis) then
            rotationValue = rotationValue > 0 and (-math.pi + rotationValue) or rotationValue;
        else
            rotationValue = rotationValue > 0 and rotationValue or (math.pi + rotationValue);
        end
    end
    
    if (tweenDuration ~= 0) then
        local tempRotation1 = self.m_view:getRotation() * math.pi / 180;
        if (tempRotation1 < 0) then
            tempRotation1 = tempRotation1 + math.pi * 2;
        end
        if (rotationValue < 0) then
            rotationValue = rotationValue + math.pi * 2;
        end
        --校正目标ratation
        if (math.abs(tempRotation1 - rotationValue) > math.pi) then
            if (rotationValue > math.pi) then
                rotationValue = rotationValue - math.pi * 2;
            end
        else
            if (rotationValue > math.pi + self.m_view:getRotation() * math.pi / 180) then
                rotationValue = rotationValue - math.pi * 2;
            end
        end
        
        local rotateAction = cc.RotateTo:create(tweenDuration, 180 - rotationValue * 180 / math.pi)
        local scaleAction = cc.ScaleTo:create(tweenDuration, 1.5, scaleYValue)
        self.m_view:runAction(rotateAction)
        self.m_view:runAction(scaleAction)
    else
        self.m_view:setRotation(180 - rotationValue * 180 / math.pi);
        self.m_view:setScale(1.5, scaleYValue);
    end
end

return TableLight