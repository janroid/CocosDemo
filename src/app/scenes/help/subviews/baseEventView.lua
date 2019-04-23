local EventInterface = {}

-- 参照Android Activity显示事件回调机制
-- pause 切换到显示区域之外
-- resume 切换到显示区域之内
-- create 创建完成
-- invisible 父节点不可见
-- visible 父节点可见

function EventInterface:customEvent(eventName)
    self:onCustomEventAll(eventName)

    if eventName == "pause" then
        self:onCustomEventPause()
    elseif eventName == "resume" then
        self:onCustomEventResume()
    elseif eventName == "create" then
        self:onCustomEventCreate()
    elseif eventName == "invisible" then
        self:onCustomEventInvisible()
    elseif eventName == "visible" then
        self:onCustomEventVisible()
    end
end

function EventInterface:onCustomEventPause()
end
function EventInterface:onCustomEventResume()
end
function EventInterface:onCustomEventCreate()
end
function EventInterface:onCustomEventInvisible()
end
function EventInterface:onCustomEventVisible()
end
function EventInterface:onCustomEventAll()
end
return EventInterface