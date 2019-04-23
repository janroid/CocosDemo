--[[--ldoc desc
@module CardCalculatorPop
@author CavanZhou

Date   %s
]]

local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local CardCalculatorPop = class("CardCalculatorPop", PopupBase)
BehaviorExtend(CardCalculatorPop)
-- 配置事件监听函数
CardCalculatorPop.s_eventFuncMap = {
	-- [g_SceneEvent.HIDE_GIFT_DIALOG]	 =  "hidden";
}

function CardCalculatorPop:ctor()
    PopupBase.ctor(self)
    self:bindCtr(require(".CardCalculatorCtr"))
    self:init()
    self:setShadeTransparency(true)
end


function CardCalculatorPop:onCleanup()
    PopupBase.onCleanup(self)
end

function CardCalculatorPop:show(data)
    self.m_ratio = self:getRatio()
    self:watchData();
    PopupBase.show(self)
end

function CardCalculatorPop:hidden()
    self:unwatchData()
    PopupBase.hidden(self)
end

function CardCalculatorPop:init()
    
    self:loadLayout("creator/cardCalculator/layout/cardCalculator.ccreator")
    self.m_bg = g_NodeUtils:seekNodeByName(self, "pop_transparency_bg")
    self.m_background = g_NodeUtils:seekNodeByName(self, "bg")
    self.m_viewTopBg = g_NodeUtils:seekNodeByName(self, "bg_top")
    self.m_title = g_NodeUtils:seekNodeByName(self, "title")
    self.m_layoutView = g_NodeUtils:seekNodeByName(self, "layoutView")
    self.m_title = g_NodeUtils:seekNodeByName(self, "title")
    
    self.m_title:setString(GameString.get("str_cardCalculator_title"))
    self.m_ratio = self:getRatio()
    
    self:setBtnClickListener()
end

CardCalculatorPop.iconMap = {
    "creator/cardCalculator/imgs/huanJia.png",
    "creator/cardCalculator/imgs/tongHuaShun.png",
    "creator/cardCalculator/imgs/siTiao.png",
    "creator/cardCalculator/imgs/huLu.png",
    "creator/cardCalculator/imgs/tongHua.png",
    "creator/cardCalculator/imgs/shunZi.png",
    "creator/cardCalculator/imgs/sanTiao.png",
    "creator/cardCalculator/imgs/liangDui.png",
}
function CardCalculatorPop:initString(index)
    
    local str = "item" .. tostring(index)
    local isGray = not self:isMaxRatio(index,self.m_ratio)
    local node = g_NodeUtils:seekNodeByName(self.m_layoutView, str)
    local nameBgSel = g_NodeUtils:seekNodeByName(node, "nameBgSel")
    local nameBgHi = g_NodeUtils:seekNodeByName(node, "nameBgHi")
    local cardTypeText = g_NodeUtils:seekNodeByName(node, "cardType")
    local probabilityTex = g_NodeUtils:seekNodeByName(node, "probabilityTex")
    local probabilitynum = g_NodeUtils:seekNodeByName(node, "probabilitynum")
    local cardTypeIcon = g_NodeUtils:seekNodeByName(node, "cardTypeIcon")
    
    cardTypeIcon:setTexture(CardCalculatorPop.iconMap[index])
    nameBgSel:setVisible(not isGray)
    nameBgHi:setVisible(not isGray)
    probabilityTex:setString(GameString.get("str_room_type_probability"))
    probabilitynum:setString(self.m_ratio[index] .."%")
    cardTypeText:setString(GameString.get("str_room_card_type")[index])
    probabilityTex:setTextColor(isGray and cc.c4b(85,116,179,255) or cc.c4b(255,187,41,255))
    cardTypeText:setTextColor(isGray and cc.c4b(175,195,236,255) or cc.c4b(73,32,9,255))
    probabilitynum:setTextColor(isGray and cc.c4b(112,185,236,255) or cc.c4b(255,187,41,255)) 
end

function CardCalculatorPop:setRatio(data)
    self.m_ratio = data 
    if not data or g_TableLib.isEmpty(data) then
        self.m_ratio = self:getRatio()
    end
    
    for i=1,8 do
        self:initString(i)
    end
end

function CardCalculatorPop:setCardType(cardType)
    cardType = tonumber(cardType)
    self.m_ratio = self:getRatio();
    if(cardType ~= nil) then
        local index = 12 - cardType;
        if index >= 1 and index <= 8 then
            self.m_ratio[index] = 100.0;
        end
        for i=1,8 do
            self:initString(i)
        end
    end
end

function CardCalculatorPop:setBtnClickListener()
    self.m_background:addClickEventListener(
        function(sender)
        end
    )
    self.m_bg:addClickEventListener(
        function(sender)
            self:hidden()
        end
    )
end

function CardCalculatorPop:watchData()
    g_Model:watchData(g_ModelCmd.ROOM_CALCULATOR_DATA,self, self.setRatio, true);
    g_Model:watchData(g_ModelCmd.ROOM_CARD_TYPE,      self, self.setCardType, true);
end

function CardCalculatorPop:unwatchData()
    g_Model:unwatchData(g_ModelCmd.ROOM_CALCULATOR_DATA,self, self.setRatio);
    g_Model:unwatchData(g_ModelCmd.ROOM_CARD_TYPE,      self, self.setCardType);
end

function CardCalculatorPop:isMaxRatio(index,data)
    data = data or self:getRatio();
    local maxValue = math.max(unpack(data));
    if maxValue and maxValue >0 then
        return data[index]==maxValue
    end
    return false
end

--获取概率
function CardCalculatorPop:getRatio()
    local ret = g_Model:getData(g_ModelCmd.ROOM_CALCULATOR_DATA) or {}
    if g_TableLib.isEmpty(ret) then 
        for i = 1, 8 do
            ret[i] = 0.0;
        end
    end
    return ret;
 end

return CardCalculatorPop
