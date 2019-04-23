--[[--ldoc desc
@module PrivateHallPop
@author LoyalwindPeng

Date   2018-12-26
]]
local PopupBase      = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local PrivateHallPop = class("PrivateHallPop",PopupBase);
BehaviorExtend(PrivateHallPop);

local PrivateCreateView  = require("subviews.PrivateCreateView")
local InputPasswordView  = require("subviews.InputPasswordView")
local MotifyPasswordView = require("subviews.MotifyPasswordView")
local SuccessCreateView  = require("subviews.SuccessCreateView")
local PrivatePopType    = require("config.SceneConfig").PrivatePopType

-- 配置事件监听函数
PrivateHallPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function PrivateHallPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("PrivateHallCtr"))
	self:init()
end

function PrivateHallPop:show(type, data)
	data = data or {}
	if type == PrivatePopType.InputPassword then
		self:showInputPassword(true, data)
		self:showCreatePrivate(false)
		self:showMotifyPassword(false)
		self:showSuccessCreate(false)
	elseif type == PrivatePopType.MotifyPassword then
		self:showMotifyPassword(true, data.tid)
		self:showInputPassword(false)
		self:showCreatePrivate(false)
		self:showSuccessCreate(false)
	elseif type == PrivatePopType.CreatePrivateRoom then
		self:showCreatePrivate(true)
		self:showInputPassword(false)
		self:showMotifyPassword(false)
		self:showSuccessCreate(false)
	elseif type == PrivatePopType.CreateSuccess then
		self:showSuccessCreate(true, data.tid)
		self:showCreatePrivate(false)
		self:showInputPassword(false)
		self:showMotifyPassword(false)
	elseif type == PrivatePopType.TipBecomeVip then
		self:showBecomeVip()
		PopupBase.hidden(self)
		return
	else
		PopupBase.hidden(self)
		return
	end
	PopupBase.show(self)

end

function PrivateHallPop:hidden()
	PopupBase.hidden(self)
	
	self:showCreatePrivate(false)
	self:showInputPassword(false)
	self:showMotifyPassword(false)
	self:showSuccessCreate(false)
end

function PrivateHallPop:init()
	-- 添加半透明背景
	local bgLayout = ccui.Layout:create()
	bgLayout:setBackGroundImage("creator/common/dialog/pop_transparency_bg.png", ccui.TextureResType.localType)
	bgLayout:setContentSize(cc.size(display.width, display.height)) -- 全屏
	bgLayout:setTouchEnabled(true) -- 拦截事件点击
	bgLayout:setBackGroundImageScale9Enabled(true) -- 拉伸
	self:add(bgLayout)
	self.m_transparencyBg = bgLayout

end

--  @desc: 显示创建私人房面板
--  @visible: bool 是否显示
function PrivateHallPop:showCreatePrivate(visible)
	if not self.m_privateCreateView then
		if not visible then return end
		self.m_privateCreateView = PrivateCreateView.new(handler(self, self.onClosed), handler(self, self.onCreateRoom))
		self:add(self.m_privateCreateView)
	end
	self.m_privateCreateView:setVisible(visible)	
end

--  @desc: 显示输入密码
--  @visible: bool 是否显示
--  @data: 房间信息: tid, ip, port, flag
function PrivateHallPop:showInputPassword(visible, data)
	if not self.m_inputPasswordView then
		if not visible then return end
		self.m_inputPasswordView = InputPasswordView.new(handler(self, self.onClosed), handler(self, self.onInputPassword))
		self:add(self.m_inputPasswordView)
	end
	self.m_inputPasswordView:setVisible(visible, data)	
end

--  @desc: 显示修改密码
--  @visible: bool 是否显示
--  @tid: 房间ID
function PrivateHallPop:showMotifyPassword(visible, tid)
	if not self.m_motifyPasswordView then
		if not visible then return end
		self.m_motifyPasswordView = MotifyPasswordView.new(handler(self, self.onClosed), handler(self, self.onMotifyPassword))
		self:add(self.m_motifyPasswordView)
	end
	self.m_motifyPasswordView:setVisible(visible, tid)
end

--  @desc: 显示成功創建
--  @visible: bool 是否显示
--  @tid: 房间ID
function PrivateHallPop:showSuccessCreate(visible, tid)
	if not self.m_successCreateView then
		if not visible then return end
		self.m_successCreateView = SuccessCreateView.new(handler(self, self.onClosed), handler(self, self.onClosed))
		self:add(self.m_successCreateView)
	end
	self.m_successCreateView:setVisible(visible, tid)
end

function PrivateHallPop:showBecomeVip()
	g_AlertDialog.getInstance()
	:setTitle(GameString.get("tips"))
	:setContent(GameString.get("str_private_create_failure"))
	:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
	:setLeftBtnTx(GameString.get("str_common_back"))
	:setRightBtnTx(GameString.get("str_become_vip"))
	:setRightBtnFunc(function() -- 打開商城進入vip頁面，關閉私人房創建頁面
		local StoreConfig = import("app.scenes.store").StoreConfig
		g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE, StoreConfig.STORE_POP_UP_VIP_PAGE)
	end)
	:show()
end

function PrivateHallPop:onCreateRoom(param)
	self:hidden()
end

function PrivateHallPop:onClosed()
	self:hidden()
end

function PrivateHallPop:onInputPassword(param)
	self:hidden()
end

function PrivateHallPop:onMotifyPassword(param)
	self:hidden()
end

function PrivateHallPop:onCleanup()
	PopupBase.onCleanup(self)
end

return PrivateHallPop;