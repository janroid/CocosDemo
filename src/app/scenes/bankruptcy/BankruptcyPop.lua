--[[--ldoc desc
@module BankruptcyUI
@author AllenLuo

Date   2018-11-8
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BankruptcyPop = class("BankruptcyPop",PopupBase);
local StoreManager = import("app.scenes.store").StoreManager
local StorePop = import("app.scenes.store").StorePop
local StoreConfig = import("app.scenes.store").StoreConfig
local PopupConfig = import('app.common.popup').PopupConfig
local PopupManager = import('app.common.popup').PopupManager
BehaviorExtend(BankruptcyPop);

BankruptcyPop.s_eventFuncMap = {
	[g_SceneEvent.STORE_DISCOUNT_UPDATE1]		= "updateDiscount",
}


function BankruptcyPop:ctor(data)
	PopupBase.ctor(self);
	self:bindCtr(require("BankruptcyCtr"));
	self:init(data);
    --刷新商城数据
    StoreManager.getInstance():requestBankruptData()
end

function BankruptcyPop:show(data)
	PopupBase.show(self)
	self.times = data.times
    self:updateDiscount(data)
end

function BankruptcyPop:init(data)
	-- do something
	
	-- 加载布局文件
	-- 第一个参数为布局文件，
	-- 第二个参数为boolean，
	--       true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--       false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
	self:loadLayout("creator/store/layout/layout_bankruptcy.ccreator");
    self:setClickShadeClose(false)
	self.times = data.times
    self.subsidizeChips = data.subsidizeChips or 0 -- 补贴筹码
    
    self.m_txtTime      = g_NodeUtils:seekNodeByName(self,'txt_time')
    self.m_timeBG       = g_NodeUtils:seekNodeByName(self,'img_time_bg')
    self.m_percentBG    = g_NodeUtils:seekNodeByName(self,'img_percent_bg')
    self.m_txtTitle     = g_NodeUtils:seekNodeByName(self,'txt_title')
    self.m_txtBuyChips  = g_NodeUtils:seekNodeByName(self,'txt_buy_chips')
    self:notHasDiscount()

    self.m_txtReason = cc.Label:createWithSystemFont("",  "fonts/arial.ttf", 24,cc.size(355,128),cc.TEXT_ALIGNMENT_LEFT,cc.TEXT_ALIGNMENT_CENTER)
    self.m_txtReason:setColor(cc.c3b(173, 198, 229))
    g_NodeUtils:seekNodeByName(self,'bg'):addChild(self.m_txtReason)
    self.m_txtReason:setString(GameString.get("str_bankrupt_desc_text3"));
    g_NodeUtils:arrangeToRightCenter(self.m_txtReason,-45,15)

    self.m_txtTitle:setString(GameString.get("str_bankrupt_title"));
    self.m_txtBuyChips:setString(GameString.get("str_bankrupt_buy_chips_test"));


    self:updateDiscount(data)

    self.m_btnBuyChip = g_NodeUtils:seekNodeByName(self,'btn_buy_chips')
    self.m_btnBuyChip:addClickEventListener(function(sender)
		self:onBtnClickBuyChip()
    end)

    self.m_close = g_NodeUtils:seekNodeByName(self,'btn_close')
    self.m_close:addClickEventListener(function(sender)
		-- self:exitPopupStyleOne()
		self:hidden()
    end)
end

function BankruptcyPop:updateDiscount(data)

    self.countDown = data.countDown or 0
    self.percent = data.percent or 0

    if self.times == 1 then
        self:hasDiscount()
        self.m_txtReason:setString(string.format(GameString.get("str_bankrupt_desc_text1"),self.subsidizeChips));
    elseif self.times == 2 then 
        self:hasDiscount()
        self.m_txtReason:setString(string.format(GameString.get("str_bankrupt_desc_text2"),self.subsidizeChips));
    elseif self.times == 3 then
        if self.countDown > os.time() then
            self:hasDiscount()
            self.m_txtReason:setString(GameString.get("str_bankrupt_desc_text3"));
        else
            self:notHasDiscount()
            self.m_txtReason:setString(GameString.get("str_bankrupt_desc_text4"));
        end
    else
        self:notHasDiscount()
        self.m_txtReason:setString(GameString.get("str_bankrupt_desc_text4"));
    end
end

function BankruptcyPop:hasDiscount()
    if not self.countDown or self.countDown < os.time() then
        self:notHasDiscount()
    else
        self.m_timeBG:setVisible(true)
        self.m_percentBG:setVisible(true)
        self:beginCountDown()
        self:addPercentNum()
    end
end

function BankruptcyPop:notHasDiscount()
    self.m_timeBG:setVisible(false)
    self.m_percentBG:setVisible(false)
end

function BankruptcyPop:beginCountDown()
    
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil;
    end

    local curentTime  = os.time()
    local remainTime = self.countDown - curentTime
    local hour = math.modf(remainTime/3600)
    local minute = (remainTime%3600)/60
    local second = remainTime%60
    local strTime = string.format("%02d:%02d:%02d",hour,minute,second);
    self.m_txtTime:setString(strTime)
    local scheduler  = cc.Director:getInstance():getScheduler()
    self.schedulerID = scheduler:scheduleScriptFunc(function()
        if not self or not self.m_txtTime then
            if self.schedulerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                self.schedulerID = nil;
            end
            return
        end
        hour = math.modf(remainTime/3600)
        minute = (remainTime%3600)/60
        second = remainTime%60
        strTime = string.format("%02d:%02d:%02d",hour,minute,second);
        self.m_txtTime:setString(strTime)
        if remainTime <= 0 then
            self.m_timeBG:setVisible(false)
            self.m_percentBG:setVisible(false)
            StoreManager.getInstance():requestStoreData(StoreConfig.STORE_POP_UP_CHIPS_PAGE)
            if self.schedulerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
                self.schedulerID = nil;
            end
        end
        remainTime = remainTime - 1
    end,1.0,false)
end

function BankruptcyPop:addPercentNum()
    local offx = 25
    local width = 13
    local percent = self.percent

    local len = string.len(tostring(percent))
    local num_11 = cc.Sprite:create("creator/store/goldNum/gold_num_11.png")
    self.m_percentBG:addChild(num_11)
    g_NodeUtils:arrangeToLeftCenter(num_11,offx)

    for i = 1, len do
        local goldNum = math.modf(percent/math.pow(10,len - i))
        percent = percent - goldNum * math.pow(10,len - i)
        local num_pic = cc.Sprite:create("creator/store/goldNum/gold_num_"..goldNum..".png")
        self.m_percentBG:addChild(num_pic)
        g_NodeUtils:arrangeToLeftCenter(num_pic,offx + i*width)
    end
    local num_10 = cc.Sprite:create("creator/store/goldNum/gold_num_10.png")
    self.m_percentBG:addChild(num_10)
    g_NodeUtils:arrangeToLeftCenter(num_10,offx + (len + 1)*width)
end

function BankruptcyPop:onBtnClickBuyChip()
	self:hidden()
	PopupManager.getInstance():show(PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_CHIPS_PAGE)
end

function BankruptcyPop:hidden()
	self.times = 0
	PopupBase.hidden(self)
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
        self.schedulerID = nil;
    end
end

---刷新界面
function BankruptcyPop:updateView(data)
	data = checktable(data);
end

return BankruptcyPop;