--[[--ldoc desc
@module MttHelpPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MttHelpPop = class("MttHelpPop",PopupBase);
BehaviorExtend(MttHelpPop);

-- 配置事件监听函数
MttHelpPop.s_eventFuncMap = {
}

function MttHelpPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("MttHelpCtr"))
	self:init()
end

function MttHelpPop:show()
	PopupBase.show(self)
end

function MttHelpPop:hidden()
	PopupBase.hidden(self)
end

function MttHelpPop:init()
	self:loadLayout("creator/mttLobbyScene/layout/mttHelpPop.ccreator");

	self.m_root = g_NodeUtils:seekNodeByName(self, 'root')	

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')	

	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	self.m_txDescTitle = g_NodeUtils:seekNodeByName(self, 'tx_desc_title')
	self.m_txDescContent = g_NodeUtils:seekNodeByName(self, 'tx_desc_content')
	self.m_txRuleTitle = g_NodeUtils:seekNodeByName(self, 'tx_rule_title')
	self.m_txRuleContent = g_NodeUtils:seekNodeByName(self, 'tx_rule_content')

	self.m_scrollView = g_NodeUtils:seekNodeByName(self,'scrollview');
	self.m_scrollView:jumpToTop()

	self:initString()
	self:initBtnClickEvent()
end

function MttHelpPop:initString()
	self.m_txTitle:setString(GameString.get('str_new_mtt_help_title'))
	self.m_txDescTitle:setString(GameString.get('str_new_mtt_help_desc_title'))
	self.m_txDescContent:setString(GameString.get('str_new_mtt_help_desc_content'))
	self.m_txRuleTitle:setString(GameString.get('str_new_mtt_help_rule_title'))
	self.m_txRuleContent:setString(GameString.get('str_new_mtt_help_rule_content'))

end

function MttHelpPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_root:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
end

function MttHelpPop:onBtnCloseClick()
	self:hidden()
end

function MttHelpPop:onCleanup()
	PopupBase.onCleanup(self)
end


return MttHelpPop;