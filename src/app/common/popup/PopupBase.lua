--[[
    author:{JanRoid}
    time:2018-10-30 15:09:35
    Description:
]] 

local ViewBase = cc.load("mvc").ViewBase;

local PopupBase = class("PopupBase",ViewBase)

-- 配置事件监听函数
PopupBase.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
}

function PopupBase:ctor(globalLife)
	ViewBase.ctor(self)
	self:retain()
	self:setLocalZOrder(KZOrder.POP)
	self.m_globalLife = globalLife
end

function PopupBase:onEnter(registerBySelf)
	ViewBase.onEnter(self)
	if registerBySelf ~= true then
		self:registerEvent()
	end
end
function PopupBase:onExit(unregisterBySelf)
	ViewBase.onExit(self)
	if unregisterBySelf ~= true then
		self:unRegisterEvent()
	end
end
function PopupBase:onEnterTransitionFinish()
	ViewBase.onEnterTransitionFinish(self)
end
function PopupBase:onExitTransitionStart()
	ViewBase.onExitTransitionStart(self)
end


--[[
    @desc: 初始化布局
    author:{JanRoid}
    time:2018-11-08 15:49:09
    --@viewLayout: 布局文件
	--@globalLife:  true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--              false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
]]
function PopupBase:loadLayout(viewLayout)
	local root,animManager = g_NodeUtils:getRootNodeInCreator(viewLayout)
	self.m_root = root
    self:add(root)
	self:setVisible(false)
	
	self:initShade()
	return animManager
end

function PopupBase:setClickShadeClose(canClose)
	self.m_clickShadeClose = canClose
end

function PopupBase:setShadeTransparency(isBlank)
	local imgPath = "creator/common/dialog/pop_transparency_bg.png"
	if isBlank then
		imgPath = "creator/common/dialog/blank1.png"
	end
	self.m_shadeImgPath = imgPath
	self:setShade(imgPath)
end

function PopupBase:setShade(imgPath)
	if not self.m_shade then return end
	imgPath = imgPath or "creator/common/dialog/pop_transparency_bg.png"
	Log.d("setShade", imgPath)
	self.m_shade:loadTextures(imgPath,imgPath)
end

function PopupBase:initShade()
	if self.m_shade then return end
	self.m_clickShadeClose = true
	local size = self.m_root:getContentSize()
	self.m_shade = ccui.Button:create(self.m_shadeImgPath  or "creator/common/dialog/pop_transparency_bg.png")
	self.m_shade:setContentSize(size)
		:ignoreContentAdaptWithSize(false)
		:addTo(self.m_root, -1):setPosition(size.width / 2, size.height / 2)
		:addClickEventListener(function(sender)
		if self.m_clickShadeClose then
			self:hidden()
		end
	end)
end

function PopupBase:show()
    if not self:isVisible() then
        self:setVisible(true)
	end

	if self.mCtr and self.mCtr.show then
		self.mCtr:show()
	end
end

function PopupBase:hidden()
    if self:isVisible() then
        self:setVisible(false)
	end

	if self.mCtr and self.mCtr.hidden then
		self.mCtr:hidden()
	end
	g_EventDispatcher:dispatch(g_CustomEvent.POP_HIDDEN,self.m_popupID)
end

function PopupBase:onCleanup()
	self:hidden()
	g_EventDispatcher:dispatch(g_CustomEvent.POP_DESTORY,self.m_popupID)
	if self.m_isretain ~= true then
		if self.mCtr then
			self.mCtr:onCleanup()
		end
		self:unBindCtr()
		self:release()
	end
end

function PopupBase:setPopupId(ID)
	self.m_popupID = ID
end

function PopupBase:getPopupId()
	return self.m_popupID
end

function PopupBase:seekNodeByName(view,name)
	if name then
		return g_NodeUtils:seekNodeByName(view,name)
	else
		return g_NodeUtils:seekNodeByName(self,view)
	end
end

--- 触发逻辑处理
function PopupBase:doLogic(mEvent, ...)
	g_EventDispatcher:dispatch(mEvent, ...)
end

return PopupBase