local AlertDialog = class("AlertDialog",cc.Node);

AlertDialog.S_BUTTON_TYPE = {
	ONE_BUTTON     = 1,      --只有ok按钮
	TWO_BUTTON    = 2,      --ok，cancel按钮都有的
    NONE_BUTTON     = 0,      -- 没有按钮
}
AlertDialog.TAG = 1000

function AlertDialog.getInstance()
    if not AlertDialog.s_instance then 
        AlertDialog.s_instance = AlertDialog:create()
    end

    return  AlertDialog.s_instance
end

function  AlertDialog.releaseInstance()
    AlertDialog.s_instance:dismiss()
	AlertDialog.s_instance:removeSelf()
	AlertDialog.s_instance = nil;
end

function AlertDialog:show()
    local notificationNode = cc.Director:getInstance():getNotificationNode();
    local child = notificationNode:getChildByTag(AlertDialog.TAG)
    if not child then
        notificationNode:addChild(self)
        self:setTag(AlertDialog.TAG)
        self:setLocalZOrder(KZOrder.Alert)
        self:setVisible(true);
    else
        self:setVisible(true);
    end
	self.m_isForever = forever;
    -- self:removeSelf();
    self:showView();
    self:initBtn()
    g_EventDispatcher:register(g_SceneEvent.EVENT_BACK,self,self.onEventBack)
    AlertDialog.m_isShow = true;
	return self
end

function AlertDialog:showView()
    self.m_titleTx = self.m_titleTx or "";
    self.m_contentTx = self.m_contentTx or "";
    self.m_centerBtnTxStr = self.m_centerBtnTxStr or GameString.get("str_logout_btn_confirm");
    self.m_leftBtnTxStr = self.m_leftBtnTxStr or "";
    self.m_rightBtnTxStr = self.m_rightBtnTxStr or "";
    self.m_alertTitle:setString(self.m_titleTx)
    self.m_alertContent:setString(self.m_contentTx)
    self.m_btnCenterTxt:setString(self.m_centerBtnTxStr)
    self.m_btnLeftTxt:setString(self.m_leftBtnTxStr)
    self.m_btnRightTxt:setString(self.m_rightBtnTxStr)
end

function AlertDialog:initBtn()
    if not self.m_showBtnsIndex then
        self.m_showBtnsIndex = self.S_BUTTON_TYPE.ONE_BUTTON
    end   
    if self.m_showBtnsIndex == self.S_BUTTON_TYPE.ONE_BUTTON then
        self.m_btnCenter:setVisible(true)
        self.m_btnRight:setVisible(false)
        self.m_btnLeft:setVisible(false)
    elseif self.m_showBtnsIndex == self.S_BUTTON_TYPE.TWO_BUTTON then
        self.m_btnCenter:setVisible(false)
        self.m_btnRight:setVisible(true)
        self.m_btnLeft:setVisible(true)
    elseif self.m_showBtnsIndex == self.S_BUTTON_TYPE.NONE_BUTTON then
        self.m_btnCenter:setVisible(false)
        self.m_btnRight:setVisible(false)
        self.m_btnLeft:setVisible(false)
    end

    if self.m_closeBtnVisible then 
        self.m_closeBg:setVisible(true)
    else
        self.m_closeBg:setVisible(false)
    end
end

function AlertDialog:ctor()
    self:retain()
    self.m_root= g_NodeUtils:getRootNodeInCreator("creator/alertDialog/alertDialog.ccreator")
    self:addChild(self.m_root)

    self.m_transbg = g_NodeUtils:seekNodeByName(self.m_root,"transparency_bg")
    self.m_bg = g_NodeUtils:seekNodeByName(self.m_root,"bg")
    self.m_btnClose = g_NodeUtils:seekNodeByName(self.m_root,"btn_close")
    self.m_closeBg  = g_NodeUtils:seekNodeByName(self.m_root,"close_bg")
    self.m_alertTitle = g_NodeUtils:seekNodeByName(self.m_root,"alert_title")
    self.m_alertContent = g_NodeUtils:seekNodeByName(self.m_root,"alert_content")
    self.m_btnCenter = g_NodeUtils:seekNodeByName(self.m_root,"btn_center")
    self.m_btnCenterTxt = g_NodeUtils:seekNodeByName(self.m_root,"btn_center_txt")
    self.m_btnRight = g_NodeUtils:seekNodeByName(self.m_root,"btn_right")
    self.m_btnRightTxt = g_NodeUtils:seekNodeByName(self.m_root,"btn_right_txt")
    self.m_btnLeft = g_NodeUtils:seekNodeByName(self.m_root,"btn_left")
    self.m_btnLeftTxt = g_NodeUtils:seekNodeByName(self.m_root,"btn_left_txt")
    self:initListener()
    self.m_closeBtnVisible = true
	self.m_autoDismiss = true
end

function AlertDialog:onEventBack()
    if AlertDialog.m_isShow and self.m_closeBtnVisible then
        self:dismiss()
    end
end


function AlertDialog:initListener()
    self.m_transbg:addClickEventListener(function()
        -- body
    end)
    self.m_bg:addClickEventListener(function()
        -- body
    end)
    self.m_btnClose:addClickEventListener(function()
        self:onCloseBtnClick()
    end)
    self.m_btnCenter:addClickEventListener(function()
        self:onCenterBtnClick()
    end)
    self.m_btnRight:addClickEventListener(function()
        self:onRightBtnClick()
    end)
    self.m_btnLeft:addClickEventListener(function()
        self:onLeftBtnClick()
    end)
end

--设置标题
-- @param title 标题文字
-- @param fontSize 标题文字大小
-- @param r,g,b 标题文字颜色
-- @param textAlign 标题文字对齐方式 默认cc.TEXT_ALIGNMENT_CENTER
function AlertDialog:setTitle(title, fontSize,r,g,b, textAlign)
    local mr = r or 215
    local mg = g or 239
    local mb = b or 248
    local mfontSize = fontSize or 30
    local mtextAlign = textAlign or cc.TEXT_ALIGNMENT_CENTER
    self.m_alertTitle:setTextColor(cc.c3b(mr,mg,mb))
    self.m_alertTitle:setSystemFontSize(mfontSize)
    self.m_alertTitle:setAlignment(mtextAlign)
    self.m_titleTx = title;
    self.m_alertTitle:setString(self.m_titleTx)
    return self
end

--设置内容文本
-- @param title 内容文字
-- @param fontSize 内容文字大小
-- @param r,g,b 内容文字颜色
-- @param textAlign 内容文字对齐方式 默认cc.TEXT_ALIGNMENT_CENTER
function AlertDialog:setContent(content, fontSize, r,g,b, textAlign)
    local mr = r or 196
    local mg = g or 214
    local mb = b or 236
    local mfontSize = fontSize or 24
    local mtextAlign = textAlign or cc.TEXT_ALIGNMENT_CENTER
    self.m_alertContent:setTextColor(cc.c3b(mr,mg,mb))
    self.m_alertContent:setSystemFontSize(mfontSize)
    self.m_alertContent:setAlignment(mtextAlign)
    self.m_contentTx = content;
    self.m_alertContent:setString(self.m_contentTx)
	return self;
end

-- 设置显示按钮1为只显示okBtn，2为只显示ok,cancelBtn，默认为显示两个。0 不显示按钮
function AlertDialog:setShowBtnsIndex(index)
	if not index or index < 0 or index >= 3 then
		return self;
	end
	self.m_showBtnsIndex = index;
	return self;
end

-- 设置CenterBtn的点击回调
-- func为回调函数
-- obj为回调func时作为参数传入的对象
function AlertDialog:setCenterBtnFunc(func, ...)
	self.m_centerBtnFunc = func;
	self.m_centerArgs = ...;
	return self;
end

function AlertDialog:setCenterBtnTx(text, fontSize, r, g, b)
    local mr = r or 255
    local mg = g or 255
    local mb = b or 255
    local mfontSize = fontSize or 26
    self.m_btnCenterTxt:setTextColor(cc.c3b(mr,mg,mb))
    self.m_btnCenterTxt:setSystemFontSize(mfontSize)
    self.m_centerBtnTxStr = text;
    self.m_btnCenterTxt:setString(self.m_centerBtnTxStr)
    return self
end

-- 设置letfBtn的点击回调
function AlertDialog:setLeftBtnFunc(func, ...)
	self.m_leftBtnFunc = func;
	self.m_leftArgs = ...;
	return self;
end

-- 设置letfBtn的点击回调
function AlertDialog:setCloseBtnFunc(func, ...)
	self.m_closeBtnFunc = func;
	self.m_closeArgs = ...;
	return self;
end

-- 设置leftBtn上面显示的文字默认为“取消”
function AlertDialog:setLeftBtnTx(text, fontSize, r, g, b)
    local mr = r or 255
    local mg = g or 255
    local mb = b or 255
    local mfontSize = fontSize or 26
    self.m_btnLeftTxt:setTextColor(cc.c3b(mr,mg,mb))
    self.m_btnLeftTxt:setSystemFontSize(mfontSize)
    self.m_leftBtnTxStr = text;
    self.m_btnLeftTxt:setString(self.m_leftBtnTxStr)
	return self;
end


-- 设置rightBtn的点击回调
function AlertDialog:setRightBtnFunc(func, ...)
	self.m_rightBtnFunc = func;
	self.m_rightArgs = ...;
	return self;
end

-- 设置rightBtn上面显示的文字默认为“取消”
function AlertDialog:setRightBtnTx(text, fontSize, r, g, b)
    local mr = r or 255
    local mg = g or 255
    local mb = b or 255
    local mfontSize = fontSize or 26
    self.m_btnRightTxt:setTextColor(cc.c3b(mr,mg,mb))
    self.m_btnRightTxt:setSystemFontSize(mfontSize)
    self.m_rightBtnTxStr = text;
    self.m_btnRightTxt:setString(self.m_rightBtnTxStr)
	return self;
end

function AlertDialog:onCenterBtnClick()
    if self.m_centerBtnFunc then
		self.m_centerBtnFunc(self.m_centerArgs);
	end
	self:dismiss();
end

function AlertDialog:onCloseBtnClick()
    if self.m_closeBtnFunc then
		self.m_closeBtnFunc(self.m_closeArgs);
	end
	self:dismiss();
end

function AlertDialog:setAutoDismiss(isAutoDismiss)
	self.m_autoDismiss = isAutoDismiss
	return self
end

function AlertDialog:onRightBtnClick()
    if self.m_rightBtnFunc then
		self.m_rightBtnFunc(self.m_rightArgs);
	end
	if self.m_autoDismiss then
		self:dismiss();
	end
end

function AlertDialog:onLeftBtnClick()
    if self.m_leftBtnFunc then
		self.m_leftBtnFunc(self.m_leftArgs);
	end
	if self.m_autoDismiss then
		self:dismiss();
	end
end

function AlertDialog:dismiss()
    g_EventDispatcher:unRegisterAllEventByTarget(self)
    if not AlertDialog.s_instance then
		return;
    end
    AlertDialog.m_isShow = false;
	AlertDialog.s_instance:setVisible(false);
	AlertDialog.s_instance:reset();
end

-- 关闭按钮显示状态
function AlertDialog:setCloseBtnVisible(isVisible)
	self.m_closeBtnVisible = isVisible;
	return self;
end

function AlertDialog:getCloseBtnVisible()
	return self.m_closeBtnVisible;
end

-- 每次点击完按钮dismiss后重置
function AlertDialog:reset()
	self.m_showBtnsIndex = nil;
	self.m_titleTx=nil
    self.m_contentTx=nil
    self.m_centerBtnTxStr=nil
    self.m_leftBtnTxStr=nil
    self.m_rightBtnTxStr=nil

	self.m_leftBtnFunc=nil;
	self.m_centerBtnFunc=nil;
	self.m_rightBtnFunc=nil;
	self.m_leftArgs=nil;
	self.m_rightArgs=nil;
    self.m_closeBtnFunc=nil;
    self.m_closeArgs=nil;
	-- self.m_cancelBtnObj=nil;
	-- self.m_isForever = false;
	self.m_closeBtnVisible = true;
	self.m_autoDismiss = true
end

function AlertDialog.isShow()
    return AlertDialog.m_isShow
end

return AlertDialog