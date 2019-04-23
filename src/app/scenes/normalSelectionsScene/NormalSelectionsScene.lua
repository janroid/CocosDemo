--[[--ldoc desc
@module NormalSelectionsScene
@author RyanXu

Date   2018-11-9
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local NormalSelectionsScene = class("NormalSelectionsScene",ViewScene);
local BehaviorMap = import("app.common.behavior").BehaviorMap
BehaviorExtend(NormalSelectionsScene);

local TabarView = import('app.common.customUI').TabarView
local RefreshListView = import('app.common.customUI').RefreshListView
local NormalSelectionsCtr = require('NormalSelectionsCtr')

local SceneConfig = require('config.SceneConfig')
local PrivatePopType = import("app.scenes.privateHall").PrivatePopType

local StoreConfig = import("app.scenes.store").StoreConfig

local NormalSelectionsItemCell = require('NormalSelectionsItemCell')
local NormalSelectionsTableCell = require('NormalSelectionsTableCell')

NormalSelectionsScene.s_eventFuncMap = {
	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_DISPLAY]				= "onUpdateDisplay",
	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_GRAPH_INFO]			= "onUpdateGraphInfo",
	[g_SceneEvent.NORMAL_SELECTIONS_UPDATE_LIST_INFO]			= "onUpdateListInfo",
	[g_SceneEvent.UPDATE_USER_HEAD_ICON] 						= "updateUserInfo";
	[g_SceneEvent.UPDATE_USER_DATA]								= "updateUserInfo";
}

NormalSelectionsScene.s_graphTableConfig = {
	offsetY = -40,
	titleOffsetY = 180,
	verticalMargin = -50,
	horizontalMargin = -550,
	disableScrollOther = 10,
}


function NormalSelectionsScene:ctor()
	ViewScene.ctor(self);
	self:bindCtr(require(".NormalSelectionsCtr"));
	self:init();
	self.m_index = NormalSelectionsScene._index 
end

function NormalSelectionsScene:onEnter()
	ViewScene.onEnter(self)
end

function NormalSelectionsScene:onCleanup()
	ViewScene.onCleanup(self);
end

function NormalSelectionsScene:init()
	self:initRoot()
	self:initUI()
end

function NormalSelectionsScene:initRoot()
	if not self.m_root then
		self.m_root = self:loadLayout('creator/normalSelectionsScene/layout/normalSelectionsScene.ccreator')
		self:addChild(self.m_root)
	end
end

function NormalSelectionsScene:initUI()

	self.m_imgTabar      = g_NodeUtils:seekNodeByName(self.m_root, 'bg_tagbar')
	self.m_btnBack      = g_NodeUtils:seekNodeByName(self.m_root, 'btn_back')
	self.m_btnHelp      = g_NodeUtils:seekNodeByName(self.m_root, 'btn_help')

	self.m_btnPrivateRoom = g_NodeUtils:seekNodeByName(self.m_root, 'btn_private_room')
	self.m_btnSearch = g_NodeUtils:seekNodeByName(self.m_root, 'btn_search')
	self.m_btnFilter      = g_NodeUtils:seekNodeByName(self.m_root, 'btn_filter')
	self.m_btnList = g_NodeUtils:seekNodeByName(self.m_root, 'btn_list')
	self.m_btnTable = g_NodeUtils:seekNodeByName(self.m_root, 'btn_table')

	self.m_btnBlindOrder = g_NodeUtils:seekNodeByName(self.m_root, 'btn_blind_num')
	self.m_txBlindNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_blind_num')
	self.m_imgBlindTriangle = g_NodeUtils:seekNodeByName(self.m_root, 'img_blind_order_by')

	self.m_btnCarryOrder = g_NodeUtils:seekNodeByName(self.m_root, 'btn_carry_num')
	self.m_txCarryNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_carry_num')
	self.m_imgCarryTriangle = g_NodeUtils:seekNodeByName(self.m_root, 'img_carry_order_by')

	self.m_btnSeatOrder = g_NodeUtils:seekNodeByName(self.m_root, 'btn_seat_num')
	self.m_txSeatNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_seat_num')
	self.m_imgSeatTriangle = g_NodeUtils:seekNodeByName(self.m_root, 'img_seat_order_by')

	self.m_btnBonusPointHelp =  g_NodeUtils:seekNodeByName(self.m_root, 'btn_bonus_point_help') 

	self.m_bgHeadline = g_NodeUtils:seekNodeByName(self.m_root, 'img_shadow') 

	self.m_btnHeadBg   = g_NodeUtils:seekNodeByName(self.m_root, 'btn_head_bg')
	self.m_imgHead   = g_NodeUtils:seekNodeByName(self.m_root, 'img_head')
	self.m_imgVip		 = g_NodeUtils:seekNodeByName(self.m_root, 'img_vip')

	self.m_txUserName = g_NodeUtils:seekNodeByName(self.m_root, 'tx_user_name')
	self.m_txChipNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_chip_num')
	self.m_txCoalaaNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_coalaa_num')

	self.m_txRoomNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_room_num')
	self.m_txBonusNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_bonus_num')

	self.m_viewList = g_NodeUtils:seekNodeByName(self.m_root, 'view_list')

	self.m_btnAddChip =  g_NodeUtils:seekNodeByName(self.m_root, 'btn_add_chip') 
	self.m_btnAddBonus =  g_NodeUtils:seekNodeByName(self.m_root, 'btn_add_bonus') 
	self.m_btnFastStart =  g_NodeUtils:seekNodeByName(self.m_root, 'btn_fast_start') 

	self.m_viewChipNum =  g_NodeUtils:seekNodeByName(self.m_root, 'view_chip_num') 
	self.m_viewCoalaaNum =  g_NodeUtils:seekNodeByName(self.m_root, 'view_coalaa_num') 

	self.m_txList =  g_NodeUtils:seekNodeByName(self.m_root, 'tx_list') 
	self.m_txTable =  g_NodeUtils:seekNodeByName(self.m_root, 'tx_table') 
	self.m_txPrivateRoom =  g_NodeUtils:seekNodeByName(self.m_root, 'tx_private_room') 
	self.m_txSearch =  g_NodeUtils:seekNodeByName(self.m_root, 'tx_search') 
	self.m_txFilter =  g_NodeUtils:seekNodeByName(self.m_root, 'tx_filter')


	g_NodeUtils:convertTTFToSystemFont(self.m_txUserName)

	BehaviorExtend(self.m_imgHead)
	self.m_imgHead:bindBehavior(BehaviorMap.HeadIconBehavior)
	self:updateRoomOrderDisplay()

	self:initBottomButton();
	self:initListView();
	self:initTabar();
	self:initGraphTable();
	self:setupBtnClickEvent();
	self:updateUserInfo()

	self.m_txRoomNum:setString(GameString.get('str_normal_selections_room_num'))
	self.m_txBlindNum:setString(GameString.get('str_normal_selections_blind_num'))
	self.m_txCarryNum:setString(GameString.get('str_normal_selections_carry_num'))
	self.m_txBonusNum:setString(GameString.get('str_normal_selections_bonus_num'))
	self.m_txSeatNum:setString(GameString.get('str_normal_selections_player_num'))

	self.m_txList:setString(GameString.get('str_normal_selections_list')) 
	self.m_txTable:setString(GameString.get('str_normal_selections_table')) 
	self.m_txPrivateRoom:setString(GameString.get('str_normal_selections_private_room')) 
	self.m_txSearch:setString(GameString.get('str_normal_selections_search')) 
	self.m_txFilter:setString(GameString.get('str_normal_selections_filter'))

	self:showVip()

	self.m_roomOrderBy = SceneConfig.roomOrderByType.blind_forward
	self:onBtnBlindOrderClick()
end

function NormalSelectionsScene:updateUserIcon()
	local pic = g_AccountInfo:getSmallPic()
	local size = self.m_imgHead:getContentSize()
	local border = 4
	local clipPath = "creator/hall/header_bg.png"
	self.m_imgHead:setHeadIcon(pic, size.width - border, size.height - border, clipPath)
end

function NormalSelectionsScene:showVip()
	local vip = tonumber(g_AccountInfo:getVip())
	if vip and vip > 0 and vip < 5  then
		self.m_imgVip:setTexture(string.format("creator/common/vip/vip_icon_%d.png", vip))
		self.m_imgVip:setVisible(true)
	else
		self.m_imgVip:setVisible(false)
	end
end

function NormalSelectionsScene:initBottomButton()
	self.m_privateRoomPosition = cc.p(self.m_btnPrivateRoom:getPosition())
	self.m_searchPosition = cc.p(self.m_btnSearch:getPosition())
end

function NormalSelectionsScene:initListView()

	local size = self.m_viewList:getContentSize()
	self.m_viewListSize = size
	self.m_listView = RefreshListView:create()
	self.m_listView:setContentSize(size);
	self.m_listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_listView:setBounceEnabled(true);
	self.m_listView:setItemsMargin(10)
	self.m_listView:setScrollBarEnabled(false)
	self.m_viewList:addChild(self.m_listView)

    self.m_listView:addRefreshEventListener(function (sender)
    	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_FORCE_UPDATE)
    end)
end

function NormalSelectionsScene:initTabar()
	local param = {
		bgFile = "creator/hall/blank4x4.png",
		imageFile = "creator/normalSelectionsScene/tabar.png",
		tabarSize = {width = 500, height = 66},
		text = {
			name = {
				GameString.get("str_normal_selections_low_rank"),
				GameString.get("str_normal_selections_middle_rank"),
				GameString.get("str_normal_selections_high_rank")
			},
			fontSize = g_AppManager:getAdaptiveConfig().NormalSelections.TabarFontSize,
			color = {on = {r = 255, g = 255, b = 255}, off = {r = 215, g = 239, b = 248}},
			bold = false,
		},
		index = 1,
		isMove = true,
		grid9 = {sx = 10, ex = 10, sy = 10, ey = 10},
		tabClickCallbackObj = self,
		tabClickCallbackFunc = self.onTabarClickCallback,
	}
	self.m_tabarView = TabarView:create(param)
	self.m_imgTabar:addChild(self.m_tabarView)
	g_NodeUtils:arrangeToCenter(self.m_tabarView)
end

function NormalSelectionsScene:enableLoadingTouch(isEnable)
	if self.m_tabarView then
		self.m_tabarView:setTouchEnabled(isEnable)
	end
	self.m_listView:setTouchEnabled(isEnable)
	if isEnable == true and self.m_listView:isRefreshing() then
		self.m_listView:refreshComplete()
	end
end

function NormalSelectionsScene:initGraphTable()

	local config = NormalSelectionsScene.s_graphTableConfig
    
	local viewSize = self.m_viewList:getContentSize()
	local viewPosX, viewPosY = self.m_viewList:getPosition()

	self.m_graphTable = ccui.PageView:create()
	self.m_graphTable:setContentSize(cc.size(viewSize.width,viewSize.height));
	self.m_graphTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_graphTable:setPosition(cc.p(viewPosX,viewPosY))
	self.m_graphTable:setAnchorPoint(cc.p(0.5,0.5))
	self.m_graphTable:setBounceEnabled(true);
	self.m_graphTable:setScrollBarEnabled(false)
	self.m_graphTable:setItemsMargin(config.verticalMargin)
	self.m_graphTable:setTouchEnabled(false)
	self.m_root:addChild(self.m_graphTable)

  	local graphTableTouchLayer = cc.Layer:create()
	graphTableTouchLayer:setContentSize(cc.size(viewSize.width,viewSize.height))
	graphTableTouchLayer:setPosition(cc.p(0,viewPosY - viewSize.height/2))
	self.m_root:addChild(graphTableTouchLayer)
	self.m_operationFlag = 0

    local function onTouchBegan(touch, event)
    	local touchPoint = touch:getLocation()
    	local box = graphTableTouchLayer:getBoundingBox()
    	if cc.rectContainsPoint(box,touchPoint) then
    		self.m_graphTable:onTouchBegan(touch, event)
    		local curPageIndex = self.m_graphTable:getCurrentPageIndex();
    		local curPage = self.m_graphTable:getItem(curPageIndex)
    		if curPage == nil then
    			return false
    		end
    		local subPageView = curPage:getChildByTag(2)
    		subPageView:onTouchBegan(touch,event)

    		local graphTabelHeight = self.m_graphTable:getContentSize().height
    		local pageViewContainerPosY = self.m_graphTable:getInnerContainerPosition().y;
    		local pageViewCenterDis = pageViewContainerPosY % (graphTabelHeight + config.verticalMargin )
    		pageViewCenterDis = math.min(pageViewCenterDis, graphTabelHeight - pageViewCenterDis)


    		local subPageViewWidth = subPageView:getContentSize().width
    		local subPageContainerPosX = subPageView:getInnerContainerPosition().x;
    		local subPageCenterDis = subPageContainerPosX % (subPageViewWidth + config.horizontalMargin )
    		subPageCenterDis = math.min(subPageCenterDis, subPageViewWidth - subPageCenterDis)
    		

    		if self.m_operationFlag == 1 and pageViewCenterDis > config.disableScrollOther then 
				self.m_operationFlag = 1;
			elseif self.m_operationFlag == 2 and subPageCenterDis > config.disableScrollOther then
				self.m_operationFlag = 2
			else
				self.m_operationFlag = 0
			end
			return true;
    	end
    	return false
    end
    local function onTouchMoved(touch, event)
    	local delta = touch:getDelta()
		if self.m_operationFlag == 0 then
			if math.abs(delta.x/delta.y) < 1 then
				self.m_operationFlag = 1
			else
				self.m_operationFlag = 2
			end
		end
		if self.m_operationFlag == 1 then
			self.m_graphTable:onTouchMoved(touch, event)
		elseif self.m_operationFlag == 2 then
			local curPageIndex = self.m_graphTable:getCurrentPageIndex();
    		local subPageView = self.m_graphTable:getItem(curPageIndex):getChildByTag(2)
    		subPageView:onTouchMoved(touch, event);
		end
	end
    local function onTouchEnded(touch, event)
    	if self.m_operationFlag == 1 then
    		self.m_graphTable:onTouchEnded(touch, event)
    	elseif self.m_operationFlag == 2 then
    		local curPageIndex = self.m_graphTable:getCurrentPageIndex();
    		local subPageView = self.m_graphTable:getItem(curPageIndex):getChildByTag(2)
    		subPageView:onTouchEnded(touch, event);
    	end
    end

	self.m_graphTableTouchListener = cc.EventListenerTouchOneByOne:create()
    self.m_graphTableTouchListener:setSwallowTouches(false)
    self.m_graphTableTouchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_graphTableTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_graphTableTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self.m_graphTableTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()

    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_graphTableTouchListener, graphTableTouchLayer)
	
    self:hideGraphTable()
end

function NormalSelectionsScene:showHelpPop()
	if self.m_helpPop == nil then
		self.m_helpPop = self:loadLayout('creator/normalSelectionsScene/layout/helpPop.ccreator')
		self.m_root:addChild(self.m_helpPop);

		self.m_helpPopBody = g_NodeUtils:seekNodeByName(self.m_helpPop, 'help_body')
		self.m_helpPopBg = g_NodeUtils:seekNodeByName(self.m_helpPop, 'btn_bg')

		local txFastTitle = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_fast_title')
		local txFastDesc = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_fast_desc')
		local txMustTitle = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_must_title')
		local txMustDesc = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_must_desc')
		local txMustFastTitle = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_must_fast_title')
		local txMustFastDesc = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_must_fast_desc')
		local txExpTitle = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_exp_title')
		local txExpDesc = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_exp_desc')
		local txPrivateTitle = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_private_title')
		local txPrivateDesc = g_NodeUtils:seekNodeByName(self.m_helpPop, 'tx_private_desc')

		txFastTitle:setString(GameString.get('str_normal_selections_fast_title'));
		txFastDesc:setString(GameString.get('str_normal_selections_fast_desc'));
		txMustTitle:setString(GameString.get('str_normal_selections_must_title'));
		txMustDesc:setString(GameString.get('str_normal_selections_must_desc'));
		txMustFastTitle:setString(GameString.get('str_normal_selections_must_fast_title'));
		txMustFastDesc:setString(GameString.get('str_normal_selections_must_fast_desc'));
		txExpTitle:setString(GameString.get('str_normal_selections_exp_title'));
		txExpDesc:setString(GameString.get('str_normal_selections_exp_desc'));
		txPrivateTitle:setString(GameString.get('str_normal_selections_private_title'));
		txPrivateDesc:setString(GameString.get('str_normal_selections_private_desc'));


		self.m_helpPopBg:addClickEventListener(
			function(sender)
				self.m_helpPop:setVisible(false)
			end
		)
		local bx,by = self.m_btnHelp:getPosition()
		self.m_helpPopBody:setPosition(cc.p(bx,by-50))
	else
		self.m_helpPop:setVisible(true)
	end
end

function NormalSelectionsScene:showSearchPop()
	if self.m_searchPop == nil then
		self.m_searchPop = self:loadLayout('creator/normalSelectionsScene/layout/searchPop.ccreator')
		self.m_root:addChild(self.m_searchPop);

		local btnSearch = g_NodeUtils:seekNodeByName(self.m_searchPop, 'btn_search')
		local txSearch = g_NodeUtils:seekNodeByName(self.m_searchPop, 'tx_search')
		local edRoomID = g_NodeUtils:seekNodeByName(self.m_searchPop, 'eb_room_id')

		txSearch:setString(GameString.get('str_normal_selections_search'));
		edRoomID:setPlaceHolder(GameString.get('str_normal_selections_enter_roomID'));

		self.m_searchPopBody = g_NodeUtils:seekNodeByName(self.m_searchPop, 'search_pop')
		self.m_searchPopBg = g_NodeUtils:seekNodeByName(self.m_searchPop, 'btn_bg')

		local function searchRoomFunc(sender)
			local input = edRoomID:getText()
			if input and g_StringUtils.isOnlyNumberOrChar(input) then
				edRoomID:setText("")
				self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_SEARCH_ROOM,tonumber(input))
				self.m_searchPop:setVisible(false)
			else
				g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_normal_selections_enter_num'))
			end
		end
		local function closeSearchFunc(sender)
			self.m_searchPop:setVisible(false)
		end
		self.m_searchPopBg:addClickEventListener(closeSearchFunc)
		btnSearch:addClickEventListener(searchRoomFunc)

		local bx,by = self.m_btnSearch:getPosition()
		self.m_searchPopBody:setPosition(cc.p(bx,by+30))
	else
		local bx,by = self.m_btnSearch:getPosition()
		self.m_searchPopBody:setPosition(cc.p(bx,by+30))
		self.m_searchPop:setVisible(true)
	end
end

function NormalSelectionsScene:showBonusDescPop()
	if self.m_bonusDescPop == nil then
		self.m_bonusDescPop = self:loadLayout('creator/normalSelectionsScene/layout/bonusDescriptionPop.ccreator')
		self.m_root:addChild(self.m_bonusDescPop);

		local txDesc = g_NodeUtils:seekNodeByName(self.m_bonusDescPop, 'tx_desc')

		txDesc:setString(GameString.get('str_normal_selections_bonusPop_desc'));

		self.m_bonusDescPopBody = g_NodeUtils:seekNodeByName(self.m_bonusDescPop, 'bonusDescriptionPop')
		self.m_bonusDescPopBg = g_NodeUtils:seekNodeByName(self.m_bonusDescPop, 'btn_bg')

		self.m_bonusDescPopBg:addClickEventListener(
			function(sender)
				self.m_bonusDescPop:setVisible(false)
			end
		)
		local worldPoint = self.m_btnBonusPointHelp:getParent():convertToWorldSpace(cc.p(self.m_btnBonusPointHelp:getPosition())) 
		self.m_bonusDescPopBody:setPosition(cc.p(worldPoint.x,worldPoint.y-30))
	else
		self.m_bonusDescPop:setVisible(true)
	end
end

function NormalSelectionsScene:onTabarClickCallback(index)
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_TABAR_INDEX,index)
end


function NormalSelectionsScene:onUpdateDisplay(roomRank, displayType)
	if roomRank == SceneConfig.roomRankType.highRank then
		self.m_btnPrivateRoom:setPosition(self.m_privateRoomPosition)
		self.m_btnSearch:setPosition(self.m_searchPosition)
		self.m_btnFilter:setVisible(true)
		if displayType == SceneConfig.displayType.list then
			self.m_btnTable:setVisible(true)
			self.m_btnList:setVisible(false)
			
			self.m_listView:setVisible(true)
			self.m_bgHeadline:setVisible(true)
			self:hideGraphTable()
		else
			self.m_btnTable:setVisible(false)
			self.m_btnList:setVisible(true)
			
			self.m_listView:setVisible(false)
			self.m_bgHeadline:setVisible(false)

			self:showGraphTable()
		end
	else
		self.m_btnPrivateRoom:setPosition(self.m_btnFilter:getPosition())
		self.m_btnSearch:setPosition(self.m_btnList:getPosition())
		self.m_btnFilter:setVisible(false)
		self.m_btnList:setVisible(false)
		self.m_btnTable:setVisible(false)

		self.m_listView:setVisible(true)
		self.m_bgHeadline:setVisible(true)
		self:hideGraphTable()
	end
end

function NormalSelectionsScene:onUpdateListInfo(data, field)

	-- Log.d('listdata',data)
	
	local items = self.m_listView:getItems()
	local data = data.listDisplay
	if #items > #data then
		local offset = #items - #data
		for i=1,offset do
			self.m_listView:removeLastItem()
		end
	end

	if #items < #data then
		local offset = #data - #items
		for i=1,offset do
	        local layout = NormalSelectionsItemCell:create()
	        self.m_listView:pushBackCustomItem(layout)
		end
	end

	items = self.m_listView:getItems()
	for i=1, #data do
		local itemData = data[i]
		local item = items[i]
		item:updateRankListItem(itemData,field,i)
	end

	self:enableLoadingTouch(true)
end


function NormalSelectionsScene:updateRankGraphItem(layout,data)
	local player5Seat = g_NodeUtils:seekNodeByName(layout, '5_player_seat')
	local player9Seat = g_NodeUtils:seekNodeByName(layout, '9_player_seat')

	local txBlind = g_NodeUtils:seekNodeByName(layout, 'tx_blind')

	local pbPlayerNum = g_NodeUtils:seekNodeByName(layout, 'pb_player_num')
	local txPlayerNum = g_NodeUtils:seekNodeByName(layout, 'tx_player_num')
	local txRoomId = g_NodeUtils:seekNodeByName(layout, 'tx_room_id')

	local clipPath = "creator/normalSelectionsScene/img_sit.png"

	local tableNum = 0
	local tableNode = nil
	if data.all == 5 then
		player5Seat:setVisible(true)
		player9Seat:setVisible(false)
		tableNum = 5
		tableNode = player5Seat
	elseif data.all ==  9 then
		player5Seat:setVisible(false)
		player9Seat:setVisible(true)
		tableNum = 9
		tableNode = player9Seat
	end

	local seatArray = {}
	local nameArray = {}

	for i=1,tableNum do
		local seatNode = g_NodeUtils:seekNodeByName(tableNode, 'sit_'.. i)
		local seatImg = g_NodeUtils:seekNodeByName(seatNode, 'img_sit')
		seatArray[i] = seatImg
		if seatImg.hasBehavior == nil or not seatImg:hasBehavior(BehaviorMap.HeadIconBehavior) then
			BehaviorExtend(seatImg)
			seatImg:bindBehavior(BehaviorMap.HeadIconBehavior)
		end
		seatImg:removeIcon()
		self.m_nameLabel:setString(g_StringLib.limitLength(name,20,88))

		local playerName = g_NodeUtils:seekNodeByName(seatNode, 'tx_name')
		g_NodeUtils:convertTTFToSystemFont(playerName)
		playerName:setString('')
		nameArray[i] = playerName
	end

	for i=1, #data.players do
	 	local playerData = data.players[i]
	 	local seatImg = seatArray[playerData.seat+1]
	 	local iconUrl = playerData.img
	 	seatImg:setHeadIcon(iconUrl,nil,nil,clipPath)

	 	local playerName = nameArray[i]
		playerName:setString(g_StringLib.limitLength(playerData.nick,20,88))
	end

	txRoomId:setString(tostring(data.roomID))
	txBlind:setString(string.format('%d/%d',data.sb,data.bb))
	txPlayerNum:setString(tostring(data.pc))

	local percentage = (data.pc/ data.all)*100
	pbPlayerNum:setPercent(percentage)

end

function NormalSelectionsScene:hideGraphTable()
	if self.m_graphTable then
		self.m_graphTable:setVisible(false)
		self.m_graphTableTouchListener:setEnabled(false)
	end
end

function NormalSelectionsScene:showGraphTable()
	if self.m_graphTable then
		self.m_graphTable:setVisible(true)
		self.m_graphTableTouchListener:setEnabled(true)
	end
end

function NormalSelectionsScene:onUpdateGraphInfo(data)

	self:showGraphTable()
	local data = data.graphDisplay

	local config = NormalSelectionsScene.s_graphTableConfig
	local viewSize = self.m_viewList:getContentSize()
	local viewPosX, viewPosY = self.m_viewList:getPosition()

	local items = self.m_graphTable:getItems()
	if #items > #data then
		local offset = #items - #data
		for i=1,offset do
			self.m_graphTable:removeLastItem()
		end
	end

	if #items < #data then
		local offset = #data - #items
		for i=1,offset do
			local pageViewLayout = ccui.Layout:create()
	        pageViewLayout:setContentSize(viewSize.width,viewSize.height)
			self.m_graphTable:addPage(pageViewLayout)

			local imgTitleBG = cc.Sprite:create('creator/normalSelectionsScene/bg_graphTable_title.png')
			imgTitleBG:setPosition(cc.p(viewSize.width/2, viewSize.height/2+config.titleOffsetY));
			pageViewLayout:addChild(imgTitleBG) 

			local rowPage = ccui.PageView:create() 
			rowPage:setContentSize(cc.size(viewSize.width,viewSize.height));
			rowPage:setDirection(2);
			rowPage:setTag(2)
			rowPage:setBounceEnabled(true);
			rowPage:setScrollBarEnabled(false)
			rowPage:setSwallowTouches(false)
			rowPage:setTouchEnabled(false)
			pageViewLayout:addChild(rowPage)
			rowPage:setItemsMargin(config.horizontalMargin)
		end
	end

	items = self.m_graphTable:getItems()
	for i=1,#items do
		local pageViewLayout = items[i] 
		local rowPage = pageViewLayout:getChildByTag(2)
		local rowItems = rowPage:getItems()
		local itemData = data[i]
		local tables = itemData.tables

		if #rowItems > #tables then
			local offset = #rowItems - #tables
			for i=1,offset do
				rowPage:removeLastItem()
			end
		end
		
		if #rowItems < #tables then
			local offset = #tables - #rowItems
			for i=1,offset do
		        local cell = NormalSelectionsTableCell:create(viewSize)
		        rowPage:addPage(cell)
			end
		end
	end

	for i=1,#items do
		local itemData = data[i]

		local pageViewLayout = items[i] 
		pageViewLayout:removeChildByTag(1)
		local rowPage = pageViewLayout:getChildByTag(2)

		local title = ccui.RichText:create()
		title:setTag(1)
		title:setPosition(cc.p(viewSize.width/2, viewSize.height/2+config.titleOffsetY)); 
		pageViewLayout:addChild(title)

		local re1 = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, GameString.get('str_normal_selections_sb_blind'), nil, 28) 
		local re2 = ccui.RichElementText:create(2, cc.c3b(255, 216, 110), 255, " " .. g_MoneyUtil.formatMoney(itemData.sb) .. '/' .. g_MoneyUtil.formatMoney(itemData.bb) .. " ", nil, 28)
		local re3 = ccui.RichElementText:create(3, cc.c3b(255, 255, 255), 255, GameString.get('str_normal_selections_sb_carry'), nil, 28) 
		local re4 = ccui.RichElementText:create(4, cc.c3b(255, 216, 110), 255, " ".. g_MoneyUtil.formatMoney(itemData.minb) .. '-' .. g_MoneyUtil.formatMoney(itemData.maxb), nil, 28) 
		title:pushBackElement(re1)
		title:pushBackElement(re2)
		title:pushBackElement(re3)
		title:pushBackElement(re4)

		local tables = itemData.tables
		local subItems = rowPage:getItems()
		for j = 1,#subItems do
			local cell = subItems[j]
			local subItemData = tables[j]
			cell:updateRankGraphItem(subItemData)
		end
	end
end


function NormalSelectionsScene:showFilterPop()
	if self.m_filterPop == nil then
		self.m_filterPop = self:loadLayout('creator/normalSelectionsScene/layout/filterPop.ccreator')
		self.m_root:addChild(self.m_filterPop); 

		local tx5Player = g_NodeUtils:seekNodeByName(self.m_filterPop, 'tx_five_player')
		local tx9Player = g_NodeUtils:seekNodeByName(self.m_filterPop, 'tx_nine_player')
		local txNormal = g_NodeUtils:seekNodeByName(self.m_filterPop, 'tx_normal_room')
		local txFast = g_NodeUtils:seekNodeByName(self.m_filterPop, 'tx_speed_room')
		local txFull = g_NodeUtils:seekNodeByName(self.m_filterPop, 'tx_full_room')
		local txEmpty = g_NodeUtils:seekNodeByName(self.m_filterPop, 'tx_empty_room')

		local toggle5Player = g_NodeUtils:seekNodeByName(self.m_filterPop, 'toggle_five_player')
		local toggle9Player = g_NodeUtils:seekNodeByName(self.m_filterPop, 'toggle_nine_player')
		local toggleNormal = g_NodeUtils:seekNodeByName(self.m_filterPop, 'toggle_normal_room')
		local toggleFast = g_NodeUtils:seekNodeByName(self.m_filterPop, 'toggle_speed_room')
		local toggleFull = g_NodeUtils:seekNodeByName(self.m_filterPop, 'toggle_full_room')
		local toggleEmpty = g_NodeUtils:seekNodeByName(self.m_filterPop, 'toggle_empty_room')

		tx5Player:setString(GameString.get('str_normal_selections_5_player'));
		tx9Player:setString(GameString.get('str_normal_selections_9_player'));
		txNormal:setString(GameString.get('str_normal_selections_normal'));
		txFast:setString(GameString.get('str_normal_selections_fast'));
		txFull:setString(GameString.get('str_normal_selections_full'));
		txEmpty:setString(GameString.get('str_normal_selections_empty'));

		self.m_filterPopBody = g_NodeUtils:seekNodeByName(self.m_filterPop, 'filter_pop')
		self.m_filterPopBg = g_NodeUtils:seekNodeByName(self.m_filterPop, 'btn_bg')
		self.m_filterPopBg:addClickEventListener(
			function(sender)
				local filterArray = {}
				filterArray.player5Cap = toggle5Player:isSelected()
				filterArray.player9Cap = toggle9Player:isSelected()
				filterArray.normalRoom = toggleNormal:isSelected()
				filterArray.fastRoom = toggleFast:isSelected()
				filterArray.fullRoom = toggleFull:isSelected()
				filterArray.emptyRoom = toggleEmpty:isSelected()
				self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_FILTER,filterArray)
				self.m_filterPop:setVisible(false)
			end
		)
		local bx,by = self.m_btnFilter:getPosition()
		self.m_filterPopBody:setPosition(cc.p(bx,by+30))
	else
		self.m_filterPop:setVisible(true)
	end
end

-- 设置按钮点击事件
function NormalSelectionsScene:setupBtnClickEvent()
	local btnsActions = {
		{ btn = self.m_btnBack,       cmds = self.onBtnBackClick },      
		{ btn = self.m_btnFilter, cmds = self.onBtnFilterClick },  
		{ btn = self.m_btnHelp,   cmds = self.onBtnHelpClick },  
		{ btn = self.m_btnBlindOrder,  cmds = self.onBtnBlindOrderClick }, 
		{ btn = self.m_btnCarryOrder,  cmds = self.onBtnCarryOrderClick }, 
		{ btn = self.m_btnSeatOrder,  cmds = self.onBtnSeatOrderClick }, 
		{ btn = self.m_btnSearch,  cmds = self.onBtnSearchClick }, 
		{ btn = self.m_btnBonusPointHelp,  cmds = self.onBtnBonusPointHelpClick }, 
		{ btn = self.m_btnTable,  cmds = self.onBtnTableClick }, 
		{ btn = self.m_btnList,  cmds = self.onBtnListCilck }, 
		{ btn = self.m_btnHeadBg,  cmds = self.onBtnHeadBgCilck }, 
		{ btn = self.m_btnPrivateRoom,  cmds = self.onBtnPrivateRoomCilck }, 	
		{ btn = self.m_btnAddChip,  cmds = self.onBtnAddChipCilck },
		{ btn = self.m_btnAddBonus,  cmds = self.onBtnAddBonusCilck },
		{ btn = self.m_btnFastStart,  cmds = self.onBtnFastStartCilck },
	}

	for i,value in ipairs(btnsActions) do
		value.btn:addTouchEventListener(function(sender, eventType)
			if (eventType == ccui.TouchEventType.ended) then -- up
				-- self:doLogic(value.cmds)
				value.cmds(self)
			end
		end)
	end
end

function NormalSelectionsScene:onBtnFastStartCilck()
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_QUICKSTART);
end

function NormalSelectionsScene:onBtnAddChipCilck()
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_CHIPS_PAGE)
end

function NormalSelectionsScene:onBtnAddBonusCilck()
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_BY_PAGE)
end

function NormalSelectionsScene:onBtnBackClick()
	cc.Director:getInstance():popScene();
end

function NormalSelectionsScene:onBtnFilterClick()
	self:showFilterPop()
end

function NormalSelectionsScene:onBtnSearchClick()
	self:showSearchPop()
end

function NormalSelectionsScene:onBtnHelpClick()
	self:showHelpPop()
end

function NormalSelectionsScene:onBtnBonusPointHelpClick()
	self:showBonusDescPop()
end

function NormalSelectionsScene:onBtnHeadBgCilck()
	g_PopupManager:show(g_PopupConfig.S_POPID.USER_INFO_POP)
end

function NormalSelectionsScene:onBtnTableClick()
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_DISPLAY_TYPE,SceneConfig.displayType.graph)
end

function NormalSelectionsScene:onBtnListCilck()
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_DISPLAY_TYPE,SceneConfig.displayType.list)
end

function NormalSelectionsScene:onBtnBlindOrderClick()
	if self.m_roomOrderBy == SceneConfig.roomOrderByType.blind_forward then
		self.m_roomOrderBy = SceneConfig.roomOrderByType.blind_backward
	else
		self.m_roomOrderBy = SceneConfig.roomOrderByType.blind_forward
	end
	self:updateRoomOrderDisplay()
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_SORT_TYPE,self.m_roomOrderBy)
end

function NormalSelectionsScene:onBtnCarryOrderClick()
	if self.m_roomOrderBy == SceneConfig.roomOrderByType.carry_forward then
		self.m_roomOrderBy = SceneConfig.roomOrderByType.carry_backward
	else
		self.m_roomOrderBy = SceneConfig.roomOrderByType.carry_forward
	end
	self:updateRoomOrderDisplay()
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_SORT_TYPE,self.m_roomOrderBy)
end

function NormalSelectionsScene:onBtnSeatOrderClick()
	if self.m_roomOrderBy == SceneConfig.roomOrderByType.seat_forward then
		self.m_roomOrderBy = SceneConfig.roomOrderByType.seat_backward
	else
		self.m_roomOrderBy = SceneConfig.roomOrderByType.seat_forward
	end
	self:updateRoomOrderDisplay()
	self:doLogic(g_SceneEvent.NORMAL_SELECTIONS_UPDATE_SORT_TYPE,self.m_roomOrderBy)
end

-- @desc: 点击私人房按钮
function NormalSelectionsScene:onBtnPrivateRoomCilck()
	local vip = tonumber(g_AccountInfo:getVip())
	-- InputPassword     = 1; -- 输入密码
	-- MotifyPassword    = 2; -- 修改密码
	-- CreatePrivateRoom = 3; -- 创建私人房间
	-- CreateSuccess     = 4; -- 创建成功
	-- TipBecomeVip	     = 5; -- 提示开通vip
	local type = vip > 0 and PrivatePopType.CreatePrivateRoom or PrivatePopType.TipBecomeVip
	g_PopupManager:show(g_PopupConfig.S_POPID.PRIVATE_HALL_POP, type)
end

function NormalSelectionsScene:updateRoomOrderDisplay()

	local normalColor = cc.c3b(149,219,240)
	local selectdColor = cc.c3b(242,238,140)

	self.m_txBlindNum:setColor(normalColor)
	self.m_txCarryNum:setColor(normalColor)
	self.m_txSeatNum:setColor(normalColor)
	self.m_imgBlindTriangle:setVisible(false)
	self.m_imgCarryTriangle:setVisible(false)
	self.m_imgSeatTriangle:setVisible(false)

	if self.m_roomOrderBy == SceneConfig.roomOrderByType.blind_forward then
		self.m_txBlindNum:setColor(selectdColor)
		self.m_imgBlindTriangle:setVisible(true)
		self.m_imgBlindTriangle:setRotation(180)
	elseif self.m_roomOrderBy == SceneConfig.roomOrderByType.blind_backward then
		self.m_txBlindNum:setColor(selectdColor)
		self.m_imgBlindTriangle:setVisible(true)
		self.m_imgBlindTriangle:setRotation(0)
	elseif self.m_roomOrderBy == SceneConfig.roomOrderByType.carry_forward then
		self.m_txCarryNum:setColor(selectdColor)
		self.m_imgCarryTriangle:setVisible(true)
		self.m_imgCarryTriangle:setRotation(180)
	elseif self.m_roomOrderBy == SceneConfig.roomOrderByType.carry_backward then
		self.m_txCarryNum:setColor(selectdColor)
		self.m_imgCarryTriangle:setVisible(true)
		self.m_imgCarryTriangle:setRotation(0)
	elseif self.m_roomOrderBy == SceneConfig.roomOrderByType.seat_forward then
		self.m_txSeatNum:setColor(selectdColor)
		self.m_imgSeatTriangle:setVisible(true)
		self.m_imgSeatTriangle:setRotation(180)
	elseif self.m_roomOrderBy == SceneConfig.roomOrderByType.seat_backward then
		self.m_txSeatNum:setColor(selectdColor)
		self.m_imgSeatTriangle:setVisible(true)
		self.m_imgSeatTriangle:setRotation(0)
	end
end

function NormalSelectionsScene:updateUserInfo()
	self:showVip()
	self:updateUserIcon()
	self.m_txUserName:setString(g_StringLib.limitLength(g_AccountInfo:getNickName(),30,300))
	self.m_txChipNum:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
	self.m_txCoalaaNum:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getUserCoalaa()))
	self.m_viewChipNum:forceDoLayout()

	local size = self.m_viewChipNum:getContentSize()
	local y = self.m_viewCoalaaNum:getPositionY()
	self.m_viewCoalaaNum:setPosition(cc.p(self.m_viewChipNum:getPositionX() + size.width + 20, y))
end

return NormalSelectionsScene;