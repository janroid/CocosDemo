--[[
    author:{JanRoid}
    time:2018-10-30 11:37:04
    Description: 弹框管理类，管理项目中所有弹框的显示，动画，层级，销毁，缓存等。
]]

local PopupManager = class("PopupManager")

local popConfig = require("PopupConfig")

function PopupManager.getInstance()
    if not PopupManager.s_instance then
        PopupManager.s_instance = PopupManager.create()
    end

    return PopupManager.s_instance
end

function PopupManager:ctor()
    self.m_popupList = {}
    self.m_showingPopupList = {}
    self.m_popFiles = popConfig.S_FILES

    g_EventDispatcher:register(g_SceneEvent.POP_DESTORY,self,self.onCleanup)
    g_EventDispatcher:register(g_SceneEvent.POP_HIDDEN,self,self._onHidden)
    g_EventDispatcher:register(g_SceneEvent.EVENT_BACK,self,self.onEventBack)
end

function PopupManager:onEventBack()
    if not g_AlertDialog.isShow() then
        if #self.m_showingPopupList > 0 then
            self.isShowingPop = true
            local curShowingPopup = self.m_showingPopupList[#self.m_showingPopupList]
            if curShowingPopup and curShowingPopup.blockBackBtn ~= true then
                curShowingPopup:hidden()
            end
        else
            self.isShowingPop = false
        end
    end
end

function PopupManager:hasShowingPop()
    return self.isShowingPop
end

--- PopupManager:show
-- 用来展示指定弹窗，包含未加载，已加载，正在显示的弹窗
-- 注意正在展示的弹窗需刷新数据需要重写update方法
-- @param popupId 弹窗id，用来唯一确定某个弹窗
-- @param ... 可选参数，传递到具体弹窗中ctor、show或update方法中去。
function PopupManager:show(popupId, ...)
    print(" PopupManager:show  popupId " .. popupId)
    if nil == popupId then
        printInfo("lua","PopupManager.show, nil == popupID !")
        return nil
    end

    -- 弹窗是否已经加载过
    local popupObj, pos = self:getPop(popupId)
    if not popupObj then
        popupObj = self:createPop(popupId, ...)
    end
    
    if popupObj then
        if not popupObj.m_globalLife then
            local scene = cc.Director:getInstance():getRunningScene();
            local parentName =  popupObj:getParent() and popupObj:getParent().__cname
            local curSceneName = scene.__cname
            if not parentName or parentName ~= curSceneName then
                popupObj:removeFromParent(false)
                scene:add(popupObj);
            end
        end

        self:_addShowingPopup(popupObj)
        popupObj:show(...)
        
        return popupObj
    end
end

--- 用来创建指定弹窗
-- @param popupId 弹窗id，用来唯一确定某个弹窗
-- @param ... 可选参数，传递到具体弹窗中ctor方法中去。
function PopupManager:createPop(popupId, ...)
    if not self.m_popFiles or next(self.m_popFiles) == nil then
        printInfo("PopupManager.createPop, requireFile is lost")
        return nil
    end
    print("PopupManager.createPop, popupId = " .. popupId)
    local classType = import(self.m_popFiles[popupId].path)[self.m_popFiles[popupId].name]
    if classType then
        local popupObj = classType.new(...)
        popupObj:setPopupId(popupId)
        self.m_popupList[#self.m_popupList + 1] = popupObj
        if popupObj.m_globalLife then
            cc.Director:getInstance():getNotificationNode():addChild(popupObj)
        end
        return popupObj
    else
        print("PopupManager.createPop, classType is nil ", self.m_popFiles[popupId].path, self.m_popFiles[popupId].name)
    end
    return nil
end

--- PopupManager:hidden
-- 用来隐藏指定弹窗
-- @param popupId 弹窗id，用来唯一确定某个弹窗
function PopupManager:hidden(popupId)
    if nil == popupId then
        printInfo("PopupManager.hide, nil == popupID !")
        return nil
    end
    
    local obj = self:getPop(popupId)
    if obj then
        obj:hidden()
    end
end

--- PopupManager:hiddenAllPops
-- 用来隐藏所有弹窗
function PopupManager:hiddenAllPops()
    if next(self.m_popupList) == nil then return end
    for i = #self.m_popupList, 1, -1 do
        self.m_popupList[i]:hidden()
    end
end

--- PopupManager:update
-- 用来更新指定弹窗
-- @param popupId 弹窗id，用来唯一确定某个弹窗
-- @param ... 可选参数，传递到具体弹窗中update方法中去。
function PopupManager:updateView(popupId, ...)
    local popobj = self:getPop(popupId)
    if popobj then
        popobj:updateView(...)
    end
end

--- PopupManager:clearAllPops
-- 销毁所有已保存的弹窗
function PopupManager:clearAllPops() 
    while true do
        local popupObj = table.remove(self.m_popupList)
        if popupObj then  
            popupObj:hidden()
            popupObj:removeFromParent(true)
        end
    end
end

--- PopupManager:clearPop
-- 销毁指定弹窗
-- @param popupId 弹窗id，可为数值或者table类型，用来唯一确定某个弹窗
function PopupManager:clearPop(popupId)
    if type(popupId) == "table" then
        for i = #popupId, 1, -1 do
            self:clearPop(popupId[i])
        end
    else
        for i = 1, #self.m_popupList do
            if self.m_popupList[i] and self.m_popupList[i]:getPopupId() == popupId then
                local popupObj = table.remove(self.m_popupList, i)
                popupObj:hidden()
                popupObj:removeFromParent(true)
                return
            end
        end
    end
end

--- PopupManager:preLoadPop
-- 预加载指定弹窗，注意popupWindow对象中预加载逻辑不要加进度条
-- @param popupId 弹窗的id
-- @param ... 可选参数，传递到具体弹窗中ctor方法中去。
function PopupManager:preLoadPop(popupId, ...)
    local popupObj = self:createPop(popupId, ...)
    if popupObj then
        popupObj.m_popupId = popupId
        self.m_popupList[#self.m_popupList + 1] = popupObj;
    end
end

--- PopupManager:isShowing
-- 弹窗是否正在显示
-- @param popupId 弹窗id
-- @return true:正在显示,  false:未显示
function PopupManager:isShowing(popupId)
    local popupObj,_  = self:getPop(popupId)
    if popupObj then
        return popupObj:isVisible()
    end
    return false
end

--- PopupManager:getPop
-- 用于通过popupId获取popupWindow对象
-- @param popupId 弹窗id
-- @return popupObj 返回弹窗对象
-- @return index 返回弹窗对象在堆栈的位置
function PopupManager:getPop(popupId)
    if not popupId then
        return 
    end

    for k, v in pairs(self.m_popupList) do
        local pid = v:getPopupId()
        if pid and pid == popupId then
            return v, k
        end
    end
end

--- PopupManager:getLastPop
-- 用于获取最后一次显示的popupWindow对象
-- @return popupObj 返回弹窗对象
function PopupManager:getLastPop()
    if next(self.m_showingPopupList) == nil then return end
    return self.m_showingPopupList[#self.m_showingPopupList];
end

function PopupManager:onCleanup(popupId)
    for i = 1, #self.m_popupList do
        if self.m_popupList[i] and self.m_popupList[i]:getPopupId() == popupId then
            if self.m_popupList[i].m_isretain then
                return
            end

            local popupObj = table.remove(self.m_popupList, i)
            return
        end
    end
end


-- 设置正在显示弹窗的层级
function PopupManager:_setShowingPopsZorder()
    for i = 1, #self.m_showingPopupList do
        self.m_showingPopupList[i]:setLocalZOrder(KZOrder.POP+i)
    end
end
-- 添加弹窗到显示弹窗列表
function PopupManager:_addShowingPopup(popupObj)
    Log.d("PopupManager:_addShowingPopup", popupObj:getPopupId())
    if popupObj:isVisible() then
        self:_removeShowingPopup(popupObj:getPopupId())
    end
    table.insert(self.m_showingPopupList, popupObj)
    self:_setShowingPopsZorder()
end
-- 从列表中移除显示中的弹窗
function PopupManager:_removeShowingPopup(popupId)
    for i = 1, #self.m_showingPopupList do
        if self.m_showingPopupList[i] and self.m_showingPopupList[i]:getPopupId() == popupId then
            table.remove(self.m_showingPopupList, i)
            break
        end
    end
end
-- 弹窗隐藏从显示列表中移除
function PopupManager:_onHidden(popupId)
    Log.d("PopupManager:_onHidden", popupId, self.m_popFiles[popupId].name)
    self:_removeShowingPopup(popupId)
end
return PopupManager