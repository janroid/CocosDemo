--[[--ldoc desc
@module SuperLottoRulePop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SuperLottoRulePop = class("SuperLottoRulePop",PopupBase);
BehaviorExtend(SuperLottoRulePop);

-- 配置事件监听函数
SuperLottoRulePop.s_eventFuncMap = {
}

function SuperLottoRulePop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("SuperLottoRuleCtr"))
	self:init()
end

function SuperLottoRulePop:show()
	PopupBase.show(self)
end

function SuperLottoRulePop:hidden()
	PopupBase.hidden(self)
end

function SuperLottoRulePop:init()
	self:loadLayout("creator/superLotto/superLottoRule.ccreator");

	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')	

	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	self.m_txDesc = g_NodeUtils:seekNodeByName(self, 'tx_desc')
	self.m_txRemark = g_NodeUtils:seekNodeByName(self, 'tx_remark')

	self:initString()
	self:initBtnClickEvent()
end

function SuperLottoRulePop:initString()
	self.m_txTitle:setString(GameString.get('str_superLotto_rule_title'))
	self.m_txDesc:setString(GameString.get('str_superLotto_rule_desc'))

	self.m_txRemark:setElementText(0,GameString.get('str_superLotto_rule_remark1'))
	self.m_txRemark:setElementText(1,GameString.get('str_superLotto_rule_remark2'))
	self.m_txRemark:setElementText(2,GameString.get('str_superLotto_rule_remark3'))
end

function SuperLottoRulePop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
end

function SuperLottoRulePop:onBtnCloseClick()
	self:hidden()
end

function SuperLottoRulePop:onCleanup()
	PopupBase.onCleanup(self)
end


return SuperLottoRulePop;