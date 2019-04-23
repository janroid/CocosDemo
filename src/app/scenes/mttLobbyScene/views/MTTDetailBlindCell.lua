--[[--ldoc desc
@module MTTDetailBlindCell
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local MTTDetailBlindCell = class("MTTDetailBlindCell",cc.TableViewCell)

-- 配置事件监听函数
MTTDetailBlindCell.s_eventFuncMap = {
}

function MTTDetailBlindCell:ctor()
	self:init()
end


function MTTDetailBlindCell:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/mttLobbyScene/layout/mttDetailBlindCell.ccreator");
	self:add(self.m_root)

	self.m_isCur = g_NodeUtils:seekNodeByName(self,'is_cur');
	self.m_txLevel = g_NodeUtils:seekNodeByName(self,'tx_level');
	self.m_txBlind = g_NodeUtils:seekNodeByName(self,'tx_blind');
	self.m_txAnti = g_NodeUtils:seekNodeByName(self,'tx_anti');
	self.m_txRiseTime = g_NodeUtils:seekNodeByName(self,'tx_rise_time');

	self.m_iconR = g_NodeUtils:seekNodeByName(self,'icon_r');
	self.m_iconA = g_NodeUtils:seekNodeByName(self,'icon_a');

	self.m_highlightColor = cc.c4b(196,214,236,255)
	self.m_normalColor = cc.c4b(75,143,227,255)
	
end

function MTTDetailBlindCell:updateCell(data,index, curBlind)
	data = data or {}

	self.m_txLevel:setString(index)
	self.m_txBlind:setString(g_MoneyUtil.formatMoney(tonumber(data.b)) .. '/' .. g_MoneyUtil.formatMoney(tonumber(data.b*2)))
	self.m_txAnti:setString(g_MoneyUtil.formatMoney(tonumber(data.ante)))
	self.m_txRiseTime:setString(g_StringLib.substitute(GameString.get("str_new_mtt_raise_time_num"),data.t))

	if data.r == 0 then
		self.m_iconR:setVisible(false)
	else
		self.m_iconR:setVisible(true)
	end

	if data.a == 0 then
		self.m_iconA:setVisible(false)
	else
		self.m_iconA:setVisible(true)
	end

	if tonumber(data.b) == curBlind then
		self.m_isCur:setVisible(true)
		self.m_txLevel:setTextColor(self.m_highlightColor)
		self.m_txBlind:setTextColor(self.m_highlightColor)
		self.m_txAnti:setTextColor(self.m_highlightColor)
		self.m_txRiseTime:setTextColor(self.m_highlightColor)
	else
		self.m_isCur:setVisible(false)
		self.m_txLevel:setTextColor(self.m_normalColor)
		self.m_txBlind:setTextColor(self.m_normalColor)
		self.m_txAnti:setTextColor(self.m_normalColor)
		self.m_txRiseTime:setTextColor(self.m_normalColor)
	end
end

return MTTDetailBlindCell;