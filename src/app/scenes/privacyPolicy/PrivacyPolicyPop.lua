--[[--ldoc desc
@module PrivacyPolicyPop
@author LoyalwindPeng

Date   2019-4-9
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local PrivacyPolicyPop = class("PrivacyPolicyPop",PopupBase);
BehaviorExtend(PrivacyPolicyPop);

-- 配置事件监听函数
PrivacyPolicyPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function PrivacyPolicyPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("PrivacyPolicyCtr"))
	self:init()
	self:setClickShadeClose(false)
	self.blockBackBtn = true
end

function PrivacyPolicyPop:init()
	-- do something
	-- 加载布局文件
	-- 第一个参数为布局文件，
	-- 第二个参数为boolean，
	--       true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--       false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
	self:loadLayout("creator/privacyPolicy/privacyPolicy.ccreator");
	self.m_webContainer = g_NodeUtils:seekNodeByName(self, "web_container")

	self.m_txtTitle = g_NodeUtils:seekNodeByName(self, "txt_title")
	self.m_btnAccept = g_NodeUtils:seekNodeByName(self, "btn_accept")
	self.m_txtAccept = g_NodeUtils:seekNodeByName(self, "txt_accept")

	self.m_txtTitle:setString(GameString.get("str_privacy_policy_title"))
	self.m_txtAccept:setString(GameString.get("str_privacy_policy_agree"))

	self.m_btnAccept:addClickEventListener(handler(self, self.onBtnAcceptClick))
	
	if g_SystemInfo:isWindows() then return end

	local webView = ccexp.WebView:create()
	webView:setAnchorPoint(0, 0)
	webView:setBounces(true)
	webView:setVisible(true)
	local size = self.m_webContainer:getContentSize()
	webView:setPosition(cc.p(0, 0))
	webView:setContentSize(size)
	webView:setBackgroundTransparent()
	local htmlPath = cc.FileUtils:getInstance():fullPathForFilename("html/CoalaaPrivacyPolicy.html")
	webView:loadFile(htmlPath)
	self.m_webContainer:add(webView)
	self.m_webView = webView
end

function PrivacyPolicyPop:onBtnAcceptClick()
	cc.UserDefault:getInstance():setBoolForKey(g_UserDefaultCMD.PRIVACY_POLICY_AGREED, true)
	self:hidden()
end

function PrivacyPolicyPop:show()
	PopupBase.show(self)
	if g_SystemInfo:isWindows() then
		self:hidden()
		g_AlarmTips.getInstance():setText("win32 平台没有隐私政策"):show()
		return
	end

    if self.m_webView then
        self.m_webView:setVisible(true)
    end
end

function PrivacyPolicyPop:hidden()
    PopupBase.hidden(self)
    if self.m_webView then
        self.m_webView:setVisible(false)
    end
end

function PrivacyPolicyPop:onCleanup()
	PopupBase.onCleanup(self)
end

return PrivacyPolicyPop;