--[[--ldoc desc
@module RoomGameReviewPop
@author JamesLiang

Date   2018/12/27
]]

 local GameReviewDataManager = require(".roomGameReviewData.GameReviewDataManager").getInstance()
local GameReviewTable = require(".roomGameReviewPop.GameReviewTable")
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local RoomGameReviewPop = class("RoomGameReviewPop", PopupBase)
BehaviorExtend(RoomGameReviewPop)

function RoomGameReviewPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".roomGameReviewPop.RoomGameReviewPopCtr"));
	self:init();
end

function RoomGameReviewPop:init()
    self:loadLayout('creator/roomGameReview/roomGameReviewPop.ccreator')
    self:initScene()
    self:creatPageview()
end

function RoomGameReviewPop:initScene()
    self.m_transBg = g_NodeUtils:seekNodeByName(self,"pop_transparency_bg")
    self.m_imgBG = g_NodeUtils:seekNodeByName(self,"bg")
    self.m_closeBtn = g_NodeUtils:seekNodeByName(self,"close_btn")
    self.m_detailBtn = g_NodeUtils:seekNodeByName(self,"detail_btn")
    self.m_tableNode = g_NodeUtils:seekNodeByName(self,"table_node")
    self.m_previousBtn = g_NodeUtils:seekNodeByName(self,"previous_btn")
    self.m_nextBtn = g_NodeUtils:seekNodeByName(self,"next_btn")   
    self.m_titleLabel = g_NodeUtils:seekNodeByName(self,"title_label")
    
    self.m_titleLabel:setString(GameString.get("str_room_game_review_pop_up_title"))
    
    self.m_imgBG:addClickEventListener(function()  end)
    self.m_transBg:addClickEventListener(function() self:hidden() end)
    self.m_closeBtn:addClickEventListener(function (sender)
        self:hidden()
    end)

    self.m_previousBtn:addClickEventListener(function ()
        self:onPreviousBtnClick()
    end)
    self.m_nextBtn:addClickEventListener(function ()
        self:onNextBtnClick()
    end)

    self.m_detailBtn:addClickEventListener(function (sender)
        local data = GameReviewDataManager:getData()
        if #data<=0 then
            g_AlarmTips.getInstance():setText(GameString.get("str_room_game_review_pop_up_no_review_tips")):show()
            return
        end
        local index = self.m_pageView:getCurrentPageIndex()
        g_PopupManager:show(g_PopupConfig.S_POPID.ROOM_GAME_REVIEW_DETAIL, data[index + 1])
    end)

end

function RoomGameReviewPop:show(data)
    PopupBase.show(self)
    g_Progress.getInstance():show()
    local data = GameReviewDataManager:getData()
    if #data > 0  then
        self:updateView(data)
        self.m_data = data
        self.m_detailBtn:setEnabled(true)
        self.m_nextBtn:setEnabled(true)
        self.m_previousBtn:setEnabled(true)
    else
        --提示没有牌局记录
        self.m_detailBtn:setEnabled(true)
        self.m_nextBtn:setEnabled(false)
        self.m_previousBtn:setEnabled(false)
        g_AlarmTips.getInstance():setText(GameString.get("str_room_game_review_pop_up_no_review_tips")):show()
        g_Progress.getInstance():dismiss()
    end
    
end

function RoomGameReviewPop:onPreviousBtnClick()
    local currentPageIndex = self.m_pageView:getCurrentPageIndex()
    local previousPageIndex = currentPageIndex - 1
    self.m_pageView:scrollToPage(previousPageIndex)
end

function RoomGameReviewPop:onNextBtnClick()
    local currentPageIndex = self.m_pageView:getCurrentPageIndex()
    local nextPageIndex = currentPageIndex + 1
    self.m_pageView:scrollToPage(nextPageIndex)
end

function RoomGameReviewPop:creatPageview()
    local tableSize = self.m_tableNode:getContentSize()
    self.m_pageView = ccui.PageView:create()
    self.m_tableNode:addChild(self.m_pageView)
    self.m_pageView:setDirection(2)
    self.m_pageView:setContentSize(cc.size(tableSize.width, tableSize.height))
    self.m_pageView:setBounceEnabled(true);
    self.m_pageView:setScrollBarEnabled(false)
    self.m_pageView:setSwallowTouches(false)
end

function RoomGameReviewPop:updateView(data)
    self.m_pageView:removeAllPages()
    local items = self.m_pageView:getItems()
    if #items < #data then
        self.m_pageView:setVisible(false)
        local offset = #data - #items
        local tableSize = self.m_tableNode:getContentSize()
        local addIndex = 1
        local callback = function ()
            if addIndex > offset then
                if self.m_addEntry then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_addEntry)
                    self.m_addEntry = nil
                end
                self.m_pageView:jumpToRight()
                self.m_pageView:setVisible(true)
                g_Progress.getInstance():dismiss()
                return 
            end
            local layout = ccui.Layout:create()
            layout:setContentSize(cc.size(tableSize.width, tableSize.height))
            local gameReviewTable = GameReviewTable:create()
            -- g_NodeUtils:arrangeToCenter(gameReviewTable)
            -- gameReviewTable:setAnchorPoint(0,0)
            local ss =  gameReviewTable:getAnchorPoint()
            -- gameReviewTable:setPosition(cc.p(tableSize.width/2, tableSize.height/2))
            gameReviewTable:setTag(1)
            layout:addChild(gameReviewTable)
            local itemsData = data[addIndex]
            gameReviewTable:updateView(itemsData)
            self.m_pageView:addPage(layout)  
            addIndex = addIndex + 1
        end
        self.m_addEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.01, false)
    end
end
return RoomGameReviewPop
