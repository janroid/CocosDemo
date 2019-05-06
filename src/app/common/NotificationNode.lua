local NotificationNode = class("NotificationNode", cc.Node)

function NotificationNode:ctor( )
    self:setContentSize(cc.size(display.width,display.height))
end


return NotificationNode