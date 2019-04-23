--[[--ldoc 盲注、携带cell
@module BlindCarryItem
@author:LoyalwindPeng
 date: 2018-12-27
]]

local BlindCarryItem = class("BlindCarryItem", cc.TableViewCell)

function BlindCarryItem:ctor()
    self:initUI()
    self.m_blindCarryCfg = {}
end

function BlindCarryItem:initUI()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/privateHall/blindCarryItem.ccreator')
    self:addChild(self.m_root)
    self.m_selectedBg = g_NodeUtils: seekNodeByName(self.m_root,'selectedBg');
    self.m_blindTxt   = g_NodeUtils: seekNodeByName(self.m_root,'blindTxt');
    self.m_carryTxt   = g_NodeUtils: seekNodeByName(self.m_root,'carryTxt');

    self.m_selectedBg:setVisible(false)

end

function BlindCarryItem:updateCell(blindCarryCfg)
    blindCarryCfg = type(blindCarryCfg)=="table" and blindCarryCfg or {}
    self.m_blindCarryCfg = blindCarryCfg
    self.m_selectedBg:setVisible(blindCarryCfg.selected)
    
    local smallBlind = g_MoneyUtil.formatMoney(blindCarryCfg.smallblind)
    local bigBlind   = g_MoneyUtil.formatMoney(blindCarryCfg.smallblind*2)
    self.m_blindTxt:setString(string.format(GameString.get("str_private_create_blind_num"),smallBlind, bigBlind))

    local minbring = g_MoneyUtil.formatMoney(blindCarryCfg.minbring)
    local maxbring = g_MoneyUtil.formatMoney(blindCarryCfg.maxbring)
    self.m_carryTxt:setString(string.format(GameString.get("str_private_create_carry_num"), minbring, maxbring))
end

function BlindCarryItem:setSelected(isSelected)
    self.m_blindCarryCfg.selected = isSelected
    self.m_selectedBg:setVisible(isSelected == true)

end

return  BlindCarryItem