-- XGUIScrollView.lua


local NodeUtils =  {}


function NodeUtils:seekNodeByName(node,name)
    
    if node == nil then
        return 
    end

    if node:getName() == name then
        return node
    end
    local children = node:getChildren()


    if children ~= nil then
        for _,child in pairs(children) do
             local res = self:seekNodeByName(child,name)
            if (res ~= nil)  then
            
                return res
            end
             
        end

    end
    
end

--[[
    @desc: 自动初始化获取UI对象，省去手动调用seekNodeByName()步骤
           对UI布局有要求，ui控件命名必须加uixxx前缀,没有该前缀默认不初始化
    time:2019-05-30 10:20:12
    @return: table{ui对象}
]]
function NodeUtils:initUIobj(node,obj)
    if node == nil then
        return {}
    end

    local map = {}
    self:loopTree(node,map)
    
    for k, v in pairs(map) do
        local name = string.gsub(k, "ui", "m_")
        obj[name] = v
    end
end

function NodeUtils:loopTree(node,map)
    local name = node:getName()
    if string.find(name, "^ui") then
        if map[name] then
            Log.e("NodeUtils.initUIobj - 控件初始化错误，控件命名重复！", "name = ",name)
        end

        map[name] = node
    end

    local children = node:getChildren()

    if children ~= nil then
        for _,child in pairs(children) do
            self:loopTree(child,map)  
        end
    end
end

function NodeUtils:getRootNodeInCreator(creatorName)
    local creatorReader = creator.CreatorReader:createWithFilename(creatorName)
	creatorReader:setup()
	local scene = creatorReader:getNodeGraph()
	local root = NodeUtils:seekNodeByName(scene,'root') 
	root:removeFromParent(false)

    local aniManager =  creatorReader:getAnimationManager()
    aniManager:removeFromParent(false)

	return root, aniManager
end

function NodeUtils:arrangeToCenter(node,offx,offy)

    if node == nil or node:getParent() == nil then
        return 
    end
    local parent = node:getParent()
    local pSize = parent:getContentSize()
    local sSize = node:getContentSize()
    local anr = node:getAnchorPoint()

    node:setPosition(pSize.width*0.5 - sSize.width*(0.5 - anr.x)+ (offx or 0) ,pSize.height*0.5 - sSize.height*(0.5 - anr.y)  +(offy or 0))
end

function NodeUtils:arrangeToTopCenter(node,offx,offy)

    if node == nil or node:getParent() == nil then
        return 
    end
    local parent = node:getParent()
    local pSize = parent:getContentSize()
    local sSize = node:getContentSize()
    local anr = node:getAnchorPoint()

    node:setPosition(pSize.width*0.5 - sSize.width*(0.5 - anr.x) + (offx or 0),pSize.height - sSize.height*(1.0 - anr.y) +(offy or 0) )
end

function NodeUtils:arrangeToLeftCenter(node,offx,offy)

    if node == nil or node:getParent() == nil then
        return 
    end
    local parent = node:getParent()
    local pSize = parent:getContentSize()
    local sSize = node:getContentSize()
    local anr = node:getAnchorPoint()

    node:setPosition(sSize.width*anr.x + (offx or 0),pSize.height*0.5 - sSize.height*(0.5 - anr.y)  +(offy or 0))
end

function NodeUtils:arrangeToRightCenter(node,offx,offy)

    if node == nil or node:getParent() == nil then
        return 
    end
    local parent = node:getParent()
    local pSize = parent:getContentSize()
    local sSize = node:getContentSize()
    local anr = node:getAnchorPoint()

    node:setPosition(pSize.width - sSize.width*(1.0 - anr.y) +(offx or 0) ,pSize.height*0.5 - sSize.height*(0.5 - anr.y)  +(offy or 0))
end

function NodeUtils:arrangeToBottomCenter(node,offx,offy)

    if node == nil or node:getParent() == nil then
        return 
    end
    local parent = node:getParent()
    local pSize = parent:getContentSize()
    local sSize = node:getContentSize()
    local anr = node:getAnchorPoint()

    node:setPosition(pSize.width*0.5 - sSize.width*(0.5 - anr.x)+ (offx or 0),sSize.height*anr.y+(offy or 0) )
end

function NodeUtils:delayCall(delay,node,func)
    local temFunc = function ( dt )
        func(node)
    end
    local curAction  = cc.DelayTime:create(delay)
	local actionFunc = cc.CallFunc:create(temFunc)
    local sequenceAction = cc.Sequence:create(curAction,actionFunc)
    node:runAction(sequenceAction)
end

--需要释放scheduler
function NodeUtils:schedulerCall(inteval,node,func,bLoop)
    local scheduler  = cc.Director:getInstance():getScheduler()

    local temFunc = function ( dt )
        func(node)
    end
     local ret = scheduler:scheduleScriptFunc(temFunc, inteval, bLoop or false)
    return ret
end

function NodeUtils:convertTTFToSystemFont(label)
    if g_AppManager:getAppVer() ~= g_AppManager.S_APP_VER.FB_ZW then return end
    local s = label:getTTFConfig()
    label:setSystemFontName("")
    label:setSystemFontSize(s.fontSize)
end

function NodeUtils:getRemainTime( n)
    local res = ""
    if n >= 3600 then
        local h = n / 3600
        local r = n % 3600

        local m = r / 60
        local mr = r%60

        res = string.format("%02d:%02d:%02d",h,m,r) 
    elseif n >= 60 then
        local m = n / 60
        local r = n % 60
        res = string.format("%02d:%02d",m,r) 
    else
        res = string.format("00:%02d",n) 
    end
    return res
end

function NodeUtils:isVisible(node)
    if node then
        local parent = node:getParent()
        if parent then
            if parent:isVisible() then
                return NodeUtils:isVisible(parent)
            else
                return false
            end
        else
            return node:isVisible()
        end
    else
        return false
    end
end

return NodeUtils

