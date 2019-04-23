--[[

Copyright (c) 2014-2017 Chukong Technologies Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local Node = cc.Node

function Node:add(child, zorder, tag)
    if tag then
        self:addChild(child, zorder, tag)
    elseif zorder then
        self:addChild(child, zorder)
    else
        self:addChild(child)
    end
    return self
end

function Node:addTo(parent, zorder, tag)
    if tag then
        parent:addChild(self, zorder, tag)
    elseif zorder then
        parent:addChild(self, zorder)
    else
        parent:addChild(self)
    end
    return self
end

function Node:removeSelf()
    self:removeFromParent()
    return self
end

function Node:align(anchorPoint, x, y)
    self:setAnchorPoint(anchorPoint)
    return self:move(x, y)
end

function Node:show()
    self:setVisible(true)
    return self
end

function Node:hide()
    self:setVisible(false)
    return self
end

function Node:move(x, y)
    if y then
        self:setPosition(x, y)
    else
        self:setPosition(x)
    end
    return self
end

function Node:moveTo(args)
    transition.moveTo(self, args)
    return self
end

function Node:moveBy(args)
    transition.moveBy(self, args)
    return self
end

function Node:fadeIn(args)
    transition.fadeIn(self, args)
    return self
end

function Node:fadeOut(args)
    transition.fadeOut(self, args)
    return self
end

function Node:fadeTo(args)
    transition.fadeTo(self, args)
    return self
end

function Node:rotate(rotation)
    self:setRotation(rotation)
    return self
end

function Node:rotateTo(args)
    transition.rotateTo(self, args)
    return self
end

function Node:rotateBy(args)
    transition.rotateBy(self, args)
    return self
end

function Node:scaleTo(args)
    transition.scaleTo(self, args)
    return self
end

function Node:onUpdate(callback)
    self:scheduleUpdateWithPriorityLua(callback, 0)
    return self
end

Node.scheduleUpdate = Node.onUpdate

function Node:onNodeEvent(eventName, callback)
    if "enter" == eventName then
        self.onEnterCallback_ = callback
    elseif "exit" == eventName then
        self.onExitCallback_ = callback
    elseif "enterTransitionFinish" == eventName then
        self.onEnterTransitionFinishCallback_ = callback
    elseif "exitTransitionStart" == eventName then
        self.onExitTransitionStartCallback_ = callback
    elseif "cleanup" == eventName then
        self.onCleanupCallback_ = callback
    end
    self:enableNodeEvents()
end

function Node:enableNodeEvents()
    if self.isNodeEventEnabled_ then
        return self
    end

    self:registerScriptHandler(function(state)
        if state == "enter" then
            self:onEnter_()
        elseif state == "exit" then
            self:onExit_()
        elseif state == "enterTransitionFinish" then
            self:onEnterTransitionFinish_()
        elseif state == "exitTransitionStart" then
            self:onExitTransitionStart_()
        elseif state == "cleanup" then
            self:onCleanup_()
        end
    end)
    self.isNodeEventEnabled_ = true
    self.onExitCallbacks = {}
    return self
end

function Node:disableNodeEvents()
    self:unregisterScriptHandler()
    self.isNodeEventEnabled_ = false
    self.onExitCallbacks = nil
    return self
end


function Node:onEnter()
end

function Node:onExit()
end

function Node:onEnterTransitionFinish()
end

function Node:onExitTransitionStart()
end

function Node:onCleanup()
end

function Node:onEnter_()
    self:onEnter()
    if not self.onEnterCallback_ then
        return
    end
    self:onEnterCallback_()
end

function Node:onExit_()
    self:onExit()
    if self.onExitCallbacks then
        for _,callbacks in pairs(self.onExitCallbacks) do
            for _,callback in ipairs(callbacks) do
                if callback then
                    callback()
                end
            end
        end
    end
    if not self.onExitCallback_ then
        return
    end
    self:onExitCallback_()
end

function Node:onEnterTransitionFinish_()
    self:onEnterTransitionFinish()
    if not self.onEnterTransitionFinishCallback_ then
        return
    end
    self:onEnterTransitionFinishCallback_()
end

function Node:onExitTransitionStart_()
    self:onExitTransitionStart()
    if not self.onExitTransitionStartCallback_ then
        return
    end
    self:onExitTransitionStartCallback_()
end

function Node:onCleanup_()
    self:onCleanup()
    g_HttpManager:cancelRequestByObj(self)
    g_EventDispatcher:unRegisterAllEventByTarget(self)
    if not self.onCleanupCallback_ then
        return
    end
    self:onCleanupCallback_()
end


--扩展Node的方法 递归查询子结点
function Node:seekNodeByName(name)
    if self:getName() == name then
        return self
    end
    local children = self:getChildren() -- return array table
    for _,child in ipairs(children) do
        local ret = child:seekNodeByName(name)
        if ret then
            return ret
        end
    end
end

--自动释放列表
function Node:addExitCallback(name,tab)
    self.onExitCallbacks[name] = tab
end

function Node:getExitCallbackByName(name)
    return self.onExitCallbacks[name]
end

function Node:loadLayout(viewLayout)
    local root,animManager = g_NodeUtils:getRootNodeInCreator(viewLayout)
    self:add(root)
    return animManager
end

function Node:setGray(isGray)
    if isGray == false then
        self:setColor(cc.c3b(255,255,255))
    else
        self:setColor(cc.c3b(124,124,124))
    end
end
