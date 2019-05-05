--[[
    author:{JanRoid}
    time:2019-4-28
    Description: 封装cocos自定义监听事件
]] 

local EventDispatcher = class("EventDispatcher")

function EventDispatcher.getInstance()
    if not EventDispatcher.s_instance then
        EventDispatcher.s_instance = EventDispatcher.new()
    end

    return EventDispatcher.s_instance
end

function EventDispatcher:ctor()
    self.m_eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    self.m_eventObjMap = {}
end

--[[
    @desc: 注册监听事件
    author:{author}
    time:2019-04-28 17:33:11
    --@event: 事件ID，必须定义在CustomEvent.lua中
	--@obj: 回调函数类
	--@func: 回调函数
	--@priority: 优先级，可为Node类 或者数字 或者为nil,为nil时默认为1
    @return:
]]
function EventDispatcher:register(event, obj, func, priority)
    self.m_eventObjMap[event] = obj

    local listener = cc.EventListenerCustom:create(event, function(event)
        func(obj, unpack(event._usedata))
    end)
    
    if type(priority) ~= "userdata" then
        self.m_eventDispatcher:addEventListenerWithFixedPriority(listener, priority or 1)
    else
        self.m_eventDispatcher:addEventListenerWithSceneGraphPriority(listener, priority)
    end
end

function EventDispatcher:dispatchEvent(eventName, ... )
    local data = { ... }
    local event = cc.EventCustom:new(eventName)
    event._usedata = data

    self.m_eventDispatcher:dispatchEvent(event)
end

--[[
    @desc: 移除自定义事件
    author:{author}
    time:2019-04-28 17:47:31
    --@event: 
    @return:
]]
function EventDispatcher:remove(event)
    self.m_eventDispatcher:removeCustomEventListeners(event)
    if self.m_eventObjMap[event] then
        self.m_eventObjMap[event] = nil
    end
end

--[[
    @desc: 移除所有自定义事件
    author:{author}
    time:2019-04-28 17:47:51
    @return:
]]
function EventDispatcher:removeAllCustom()
    for k, v in pairs(self.m_eventObjMap) do
        self.m_eventDispatcher:removeCustomEventListeners(k)
    end

    self.m_eventObjMap = {}
end

function EventDispatcher:removeListenersByTarget(target)
    if target then
        self.m_eventDispatcher:removeEventListenersForTarget(target)
    end
    
end

return EventDispatcher