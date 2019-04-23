--[[--ldoc desc
@module SngLobbyItem
@author PatricLiu
Date   20180117
]]

local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SngLobbyItem = class("SngLobbyItem",cc.Node);


function SngLobbyItem:ctor()
	self:init()
end


function SngLobbyItem:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/sngLobbyScene/sngLobbyItem.ccreator')
	self:addChild(self.m_root)
	self.m_root:setPosition(0,0)
	self:setContentSize(self.m_root:getContentSize())
	self:setAnchorPoint(cc.p(0,0))
	self:setCascadeColorEnabled(true)
	self:setCascadeOpacityEnabled(true)
	--self.m_labelStatus = cc.Label:createWithSystemFont("ggggg", "", 30)
	--self:addChild(self.m_labelStatus)

	self.m_txFirstPrize  = g_NodeUtils:seekNodeByName(self.m_root,"label1")
	self.m_txSecondPrize = g_NodeUtils:seekNodeByName(self.m_root,"label2")
	self.m_txSignFee     = g_NodeUtils:seekNodeByName(self.m_root,"label3")
	self.m_layoutMan     = g_NodeUtils:seekNodeByName(self.m_root,"layout_man")
	self.m_txPlayerCount     = g_NodeUtils:seekNodeByName(self.m_layoutMan,"label_man_count")
	

end

function SngLobbyItem:getData()
	return self.m_data
end

function SngLobbyItem:updateItemInfo(data)
	self.m_data = data

	local firstPrize = g_MoneyUtil.formatMoney(tonumber(data.m_detailedReward[1]))
	local secondPrize = g_MoneyUtil.formatMoney(tonumber(data.m_detailedReward[2]))
	local signFee = g_MoneyUtil.formatMoney(tonumber(data.m_applyCharge))
	local serviceFee = g_MoneyUtil.formatMoney(tonumber(data.m_serviceCharge))
	local signMoney = signFee.."+"..serviceFee

	self.m_txFirstPrize:setString(tostring(firstPrize))
	self.m_txSecondPrize:setString(tostring(secondPrize))
	self.m_txSignFee:setString(signMoney)
	self.m_txPlayerCount:setString(tostring(data.m_playerCount))
	self.m_layoutMan:forceDoLayout()

end



return SngLobbyItem