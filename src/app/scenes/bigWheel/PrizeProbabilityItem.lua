--[[--ldoc 
@module PrizeProbabilityItem
@author:LoyalwindPeng
 date: 2019-04-22
]]

local PrizeProbabilityItem = class("PrizeProbabilityItem", cc.TableViewCell)

function PrizeProbabilityItem:ctor()
    self:initUI()
    self.m_blindCarryCfg = {}
end

function PrizeProbabilityItem:initUI()
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/bigWheel/prizeProbabilityItem.ccreator')
    self:addChild(self.m_root)
    self.m_imgPrize = g_NodeUtils: seekNodeByName(self.m_root,'img_prize');
 
    self.m_labelPrize   = g_NodeUtils: seekNodeByName(self.m_root,'label_prize');
    self.m_labelProbability = g_NodeUtils: seekNodeByName(self.m_root,'label_probability');

end

function PrizeProbabilityItem:updateCell(prizeProbability)
    self.m_prizeProbability = prizeProbability

    self.m_labelPrize:setString(prizeProbability.title)
    self.m_labelProbability:setString(prizeProbability.probability)
    self.m_imgPrize:setTexture(prizeProbability.img)
    self.m_imgPrize:setScale(prizeProbability.scale)

end


return  PrizeProbabilityItem