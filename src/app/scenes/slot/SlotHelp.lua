--[[--ldoc desc
@module SlotHelp
@author %s

Date   %s
]]

local pokerPath = "creator/slot/poker/%s%s.png"

local ViewBase = cc.load("mvc").ViewBase;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SlotHelp = class("SlotHelp",ViewBase);
BehaviorExtend(SlotHelp);

-- 幸运牌布局坐标
local luckPokerPos = { -- size:81,112
    [1] = {{x = 110,y = 0}};
    [2] = {{x = 98,y = 0},{x = 133,y = 0}};
    [3] = {{x = 75,y = 0},{x = 110,y = 0},{x = 145,y = 0}};
    [4] = {{x = 57,y = 0},{x = 92,y = 0},{x = 127,y = 0},{x = 162,y = 0}};
}

function SlotHelp:ctor()
	ViewBase.ctor(self);
	self:init();
end

function SlotHelp:init()
	-- 加载布局文件
	local view = self:loadLayout("creator/slot/layout_slot_rule.ccreator");
	self:add(view);
	self:hidden()
end

function SlotHelp:onEnter()
    ViewBase.onEnter(self)
    self:initScene()
end

function SlotHelp:onCleanup()
	ViewBase.onCleanup(self)
end

function SlotHelp:initScene()
    self.m_btnClose = self:seekNodeByName("btn_close")
    self.m_tgUntips = self:seekNodeByName("tg_untips")
    self.m_bgOpacity = self:seekNodeByName("opacity_bg")
    self.m_btnTg = self:seekNodeByName("tg_click")

    self.m_txTitle = self:seekNodeByName("tx_title")
    self.m_txBonus = self:seekNodeByName("tx_bonus")
    self.m_txLuckwin= self:seekNodeByName("tx_luckwin")
    self.m_txLucktip = self:seekNodeByName("tx_lucktip")
    self.m_txUntips = self:seekNodeByName("tx_untips")
    self.m_txType1 = self:seekNodeByName("tx_type1")
    self.m_txMag1 = self:seekNodeByName("tx_mag1")
    self.m_txType2 = self:seekNodeByName("tx_type2")
    self.m_txMag2 = self:seekNodeByName("tx_mag2")
    self.m_txType3 = self:seekNodeByName("tx_type3")
    self.m_txMag3 = self:seekNodeByName("tx_mag3")
    self.m_txType4 = self:seekNodeByName("tx_type4")
    self.m_txMag4 = self:seekNodeByName("tx_mag4")
    self.m_txType5 = self:seekNodeByName("tx_type5")
    self.m_txMag5 = self:seekNodeByName("tx_mag5")
    self.m_txType6 = self:seekNodeByName("tx_type6")
    self.m_txMag6 = self:seekNodeByName("tx_mag6")
    self.m_txType7 = self:seekNodeByName("tx_type7")
    self.m_txMag7 = self:seekNodeByName("tx_mag7")
    self.m_txType8 = self:seekNodeByName("tx_type8")
    self.m_txMag8 = self:seekNodeByName("tx_mag8")
    self.m_txType9 = self:seekNodeByName("tx_type9")
    self.m_txMag9 = self:seekNodeByName("tx_mag9")
    self.m_viewPoker = self:seekNodeByName("view_poker")

    self.m_lv = self:seekNodeByName("lv_content")
    local x,y = self.m_lv:getPosition()

    self.m_typeMap = {
        self.m_txType1;
        self.m_txType2;
        self.m_txType3;
        self.m_txType4;
        self.m_txType5;
        self.m_txType6;
        self.m_txType7;
        self.m_txType8;
        self.m_txType9;
        self.m_txMag1;
        self.m_txMag2;
        self.m_txMag3;
        self.m_txMag4;
        self.m_txMag5;
        self.m_txMag6;
        self.m_txMag7;
        self.m_txMag8;
        self.m_txMag9;
    }

    self.m_btnClose:addClickEventListener(function()
        self:setVisible(false)
    end)
    self.m_bgOpacity:addClickEventListener(function()
        self:setVisible(false)
    end)
    self.m_btnTg:addClickEventListener(function ()
        local checked = self.m_tgUntips:isSelected()

        self.m_tgUntips:setSelected(not checked)
        g_Model:setProperty(g_ModelCmd.DATA_SLOT, "callWins",not checked)
    end)

    self.m_tgUntips:addEventListener(function(toggle, selected)
        local status = (selected == 0)
        g_Model:setProperty(g_ModelCmd.DATA_SLOT, "callWins",status)
    end)

    self.m_pokersMap = {}

    self.m_txTitle:setString(GameString.get("str_slot_reward_odds"))
    self.m_txLucktip:setString(GameString.get("str_slot_luck_tips"))
    self.m_txUntips:setString(GameString.get("str_slot_win_untips"))
    self.m_txBonus:setString(GameString.get("str_slot_bonus"))

end

function SlotHelp:initString()
    local strCardType = GameString.get("str_room_card_type")
    local config = g_AppManager:getAdaptiveConfig().SlotBounsConfig
    for i = 1, 9 do
        self.m_typeMap[i]:setString(strCardType[i])
        self.m_typeMap[i+9]:setString(string.format(GameString.get("str_slot_mag"),config[i]))
    end

    local mult = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "luckMultiple")
    self.m_txLuckwin:setXMLData(string.format(GameString.get("str_slot_luckwin"),mult))
    self.m_txLuckwin:ignoreContentAdaptWithSize(false)

end

function SlotHelp:initLuckPoker( )
    local luckyPoker = g_Model:getProperty(g_ModelCmd.DATA_SLOT, "luckPoker")
    local fileMap = {}
    local mtype = {4,3,2,1}

	for i = 1, #luckyPoker do
        local ch = luckyPoker[i];
        local tx = ""
		if(ch == "a") then
			tx = "10"
		elseif(ch == "b") then
			tx = "11"
		elseif(ch == "c") then
			tx = "12"
		elseif(ch == "d") then
			tx =  "13"
		elseif(ch == "e") then
			tx = "14"
		else
			tx = ch
		end

        fileMap[i] = string.format( pokerPath,mtype[i],tx)	
    end
    
    local config = luckPokerPos[#fileMap]
    for k = 1, 4 do
        if fileMap[k] then
            if self.m_pokersMap[k] then
                self.m_pokersMap[k]:setTexture(fileMap[k])
                self.m_pokersMap[k]:setPosition(config[k].x,config[k].y)
                self.m_pokersMap[k]:setVisible(true)
            else
                self.m_pokersMap[k] = cc.Sprite:create(fileMap[k])
                self.m_pokersMap[k]:setAnchorPoint(0,0)
                self.m_pokersMap[k]:setPosition(config[k].x,config[k].y)
                self.m_pokersMap[k]:setContentSize(cc.size(81,112))
                self.m_viewPoker:addChild(self.m_pokersMap[k])
            end
        else
            if self.m_pokersMap[k] then
                self.m_pokersMap[k]:setVisible(false)
            end
        end
    end

end

function SlotHelp:show()
    self:setVisible(true)
    self:initString()
    self:initLuckPoker()
end

function SlotHelp:hidden( )
    self:setVisible(false)
end

return SlotHelp;