local NotificationNode = class("NotificationNode",cc.Node)

function NotificationNode:ctor()
    self:setContentSize(cc.size(display.width,display.height))

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(false)
    self.m_pListener:registerScriptHandler(self.onTouchesBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
    -- eventDispatcher:addEventListenerWithFixedPriority(self.m_pListener,-1)
    self:initKeyboardEvent()
end

function NotificationNode:initKeyboardEvent()
    local function onPressed(code, event)
		if code == cc.KeyCode.KEY_BACK then
            self.m_backDown = true
        elseif code == cc.KeyCode.KEY_HOME then
            -- cc.Director:getInstance():endToLua()
        end
    end
    local function onRelease(code, event)
		if code == cc.KeyCode.KEY_BACK then
            if self.m_backDown then
                g_EventDispatcher:dispatch(g_SceneEvent.EVENT_BACK)
            end
            self.m_backDown = false
        elseif code == cc.KeyCode.KEY_HOME then
            -- cc.Director:getInstance():endToLua()
        end
    end
    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onRelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
end

function NotificationNode:setSwallowTouches(isSwallowTouches)
    self.m_pListener:setSwallowTouches(isSwallowTouches)
end

function NotificationNode:onTouchesBegan()
    return true
end

return NotificationNode