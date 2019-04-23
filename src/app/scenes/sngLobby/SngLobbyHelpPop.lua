--[[--ldoc desc
@module SngLobbyHelpPop
@author %s

Date   %s
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SngLobbyHelpPop = class("SngLobbyHelpPop",PopupBase);
BehaviorExtend(SngLobbyHelpPop);

-- 配置事件监听函数
SngLobbyHelpPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function SngLobbyHelpPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("SngLobbyHelpCtr"))
	self:init()
end

function SngLobbyHelpPop:onEnter()
	PopupBase.onEnter(self, false)
    self:initString()	
end

function SngLobbyHelpPop:show()
	PopupBase.show(self)
end

function SngLobbyHelpPop:hidden()
	PopupBase.hidden(self)
end

function SngLobbyHelpPop:init()
    self:loadLayout('creator/sngLobbyScene/SngLobbyHelpPop.ccreator');

    self.m_btnClose = g_NodeUtils:seekNodeByName(self,"btn_close")
    self.m_txTitle = g_NodeUtils:seekNodeByName(self,"popup_title")
    self.m_txRule = g_NodeUtils:seekNodeByName(self,"rule_describe")
    self.m_txTips = g_NodeUtils:seekNodeByName(self,"rule_tips")
    self:addListener()
end

function SngLobbyHelpPop:initString()
    self.m_txTitle:setString(GameString.get("str_sng_lobby_help_pop_title"))
    self.m_txRule:setString(GameString.get("str_sng_lobby_help_pop_rule"))
    self.m_txTips:setString(GameString.get("str_sng_lobby_help_pop_tips"))

end

function SngLobbyHelpPop:addListener()
    self.m_btnClose:addClickEventListener(function(sender)
		self:hidden()
    end)
end

function SngLobbyHelpPop:onCleanup()
	PopupBase.onCleanup(self)
end


return SngLobbyHelpPop;