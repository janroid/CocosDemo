--[[--ldoc desc
@module RoomGameReviewDetail
@author JamesLiang

Date   2018/12/21
]]

local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local ReviewDetailListItem = require(".roomGameReviewDetail.ReviewDetailListItem")
local RoomGameReviewDetail = class("RoomGameReviewDetail", PopupBase)
BehaviorExtend(RoomGameReviewDetail)

function RoomGameReviewDetail:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".roomGameReviewDetail.RoomGameReviewDetailCtr"));
	self:init();
end

function RoomGameReviewDetail:init()
    self:loadLayout('creator/roomGameReview/roomGameReviewDetail.ccreator')
    self:initScene()
    self:initPokerCard()
    self:initGameReviewList()
end

function RoomGameReviewDetail:initScene()
    self.m_closeBtn = g_NodeUtils:seekNodeByName(self,"close_btn")
    self.m_topLabel1 = g_NodeUtils:seekNodeByName(self,"top_label1")
    self.m_topLabel2 = g_NodeUtils:seekNodeByName(self,"top_label2")
    self.m_topLabel3 = g_NodeUtils:seekNodeByName(self,"top_label3")
    self.m_topLabel4 = g_NodeUtils:seekNodeByName(self,"top_label4")
    self.m_topLabel5 = g_NodeUtils:seekNodeByName(self,"top_label5")
    self.m_topLabel6 = g_NodeUtils:seekNodeByName(self,"top_label6")
    self.m_contentBg = g_NodeUtils:seekNodeByName(self,"content_bg")
    self.m_imgBG = g_NodeUtils:seekNodeByName(self,"imge_bg")
    self.m_transBg = g_NodeUtils:seekNodeByName(self,"pop_transparency_bg")
    self.m_publiCardLabel = g_NodeUtils:seekNodeByName(self,"public_card_label")
    self.m_bottomBg = g_NodeUtils:seekNodeByName(self,"bottom")
    self.m_publiCardContent = g_NodeUtils:seekNodeByName(self,"public_card_content")

    self.m_topLabel1:setString(GameString.get("str_room_game_review_players"))
    self.m_topLabel2:setString(GameString.get("str_room_game_review_handcard"))
    self.m_topLabel3:setString(GameString.get("str_room_game_review_publiccard1"))
    self.m_topLabel4:setString(GameString.get("str_room_game_review_publiccard"))
    self.m_topLabel5:setString(GameString.get("str_room_game_review_turncard"))
    self.m_topLabel6:setString(GameString.get("str_room_game_review_rivercard"))
    self.m_publiCardLabel:setString(GameString.get("str_room_game_review_public"))


    self.test = g_NodeUtils:seekNodeByName(self,"icon_win")

    self.m_closeBtn = g_NodeUtils:seekNodeByName(self,"close_btn")

    self.m_imgBG:addClickEventListener(function()  end)
    self.m_transBg:addClickEventListener(function() self:hidden() end)
    self.m_closeBtn:addClickEventListener(function (sender)
        self:hidden()
    end)
end

function RoomGameReviewDetail:initPokerCard(data)
    self.m_publicCard = {};
    for i=1,5 do
        self.m_publicCard[i] = g_PokerCard:create()
        self.m_publicCard[i]:setAnchorPoint(cc.p(0,0))
        self.m_publicCard[i]:setVisible(false)
        self.m_publicCard[i]:setScale(0.5)
        self.m_publicCard[i]:setPosition(RoomGameReviewDetail.publicCardPos[i].x, RoomGameReviewDetail.publicCardPos[i].y) 
        self.m_publiCardContent:addChild(self.m_publicCard[i])
    end
end

function RoomGameReviewDetail:initGameReviewList(data)
    local contentBgsize = self.m_contentBg:getContentSize()
    self.m_gameReviewList = ccui.ListView:create()
    self.m_gameReviewList:setContentSize(cc.size(contentBgsize.width, contentBgsize.height))
    self.m_gameReviewList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.m_gameReviewList:setBounceEnabled(true)
    self.m_gameReviewList:setScrollBarEnabled(false)

    self.m_contentBg:addChild(self.m_gameReviewList)
end


function RoomGameReviewDetail:show(data)
    PopupBase.show(self)
    self.m_reviewData = data
    self:updataView(data)
end

function RoomGameReviewDetail:updataView(data)
    --更新公共牌数据
    for i=1,5 do
        self.m_publicCard[i]:setVisible(false)
    end
    for i=1,#data.publicCardArr do
        if(data.publicCardArr[i] ~= 0) then
            self.m_publicCard[i]:setCard(data.publicCardArr[i]);
            self.m_publicCard[i]:showCard();
        end
    end

    --更新listView
    for i=1,#data.playerList do
        data.playerList[i].beforeFlopOperation = data.beforeFlopOperation;
        data.playerList[i].flopCardOperation = data.flopCardOperation;
        data.playerList[i].turnCardOperation = data.turnCardOperation;
        data.playerList[i].riverCardOperation = data.riverCardOperation;
        data.playerList[i].gameOverData = data.gameOverData;
        data.playerList[i].selfSeatId = data.selfSeatId;
        data.playerList[i].selfCard1 = data.selfHandCard1;
        data.playerList[i].selfCard2 = data.selfHandCard2;
    end

    self.m_gameReviewList:removeAllItems()
    for i=1,#data.playerList do
        local layout = ccui.Layout:create()
        local contentBgsize = self.m_contentBg:getContentSize()
        layout:setContentSize(cc.size(contentBgsize.width, 84))
        local reviewDetailListItem = ReviewDetailListItem:create(data.playerList[i]) 
        reviewDetailListItem:setTag(1)
	    layout:addChild(reviewDetailListItem)
        self.m_gameReviewList:pushBackCustomItem(layout)
    end
end

RoomGameReviewDetail.publicCardPos = {
    {x=318, y=21},--publicCard1
    {x=347, y=21},--publicCard2
    {x=376, y=21},--publicCard3
    {x=499, y=21},--TurnCard
    {x=648, y=21},--riverCard
}

return RoomGameReviewDetail