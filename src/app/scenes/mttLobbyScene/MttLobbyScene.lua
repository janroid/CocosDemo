--[[--ldoc desc
@module MttLobbyScene
@author CavanZhou

Date   2019-1-2
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MttLobbyScene = class("MttLobbyScene",ViewScene);
BehaviorExtend(MttLobbyScene);

local TabarView = import('app.common.customUI').TabarView

local SceneConfig = require('config.SceneConfig')
local MTLobbyTableViewCell = require('.views.MTLobbyTableViewCell')

MttLobbyScene.s_eventFuncMap = {
	[g_SceneEvent.MTT_REFRESH_SUCC]           		= "enableLoadingTouch",   --下拉刷新 完成
	[g_SceneEvent.UPDATE_USER_DATA]           		= "updateUserData",   --更新界面用户数据
}

function MttLobbyScene:updateUserData()

	self.m_txChipNum:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
	local w = self.m_txChipNum:getContentSize().width
	w = w<140 and 140 or w
	self.m_txRankNum:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getScore()))
	local w1 = self.m_txRankNum:getContentSize().width 
	w1 = w1<80 and 80 or w1
	self.m_addChipBtn:setContentSize(w + 49,40)
	self.m_bgRankView:setContentSize(w1 + 49,40)
	if w > 150 then
		self.m_addChipBtn:setAnchorPoint(0,0)
		self.m_addChipBtn:setPosition(cc.p(150-w,0))
	end
end

function MttLobbyScene:ctor()
	ViewScene.ctor(self,nil,"MttLobbyScene");
	self:bindCtr(require(".MttLobbySceneCtr"));
	self:init();
end

function MttLobbyScene:onEnter()
	ViewScene.onEnter(self)
	self:watchData()
	if MttLobbyScene.s_needGetList then
		self:doLogic(g_SceneEvent.MTT_GET_LIST_REQUEST)
	end
	MttLobbyScene.s_needGetList = true
	self:setCurrentTime();
end

function MttLobbyScene:onCleanup()
	MttLobbyScene.s_needGetList = false
	self:unwatchData()
	ViewScene.onCleanup(self);
	self:doLogic(g_SceneEvent.MTT_DELETE_LIST_EVENT)-- cell 不會被銷毀?
	
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
	MttLobbyScene.s_needOpenMid = nil
	MttLobbyScene.s_needOpenTabBarIndex = nil
end

function MttLobbyScene:init()
	self:initRoot()
	self:initUI()
end

function MttLobbyScene:initRoot()
	if not self.m_root then
		self.m_root = self:loadLayout('creator/mttLobbyScene/layout/mttLobbyScene.ccreator')
		self:addChild(self.m_root)
	end
end

function MttLobbyScene:initUI()

	self.m_imgTabar   = g_NodeUtils:seekNodeByName(self.m_root, 'bg_tagbar')
	self.m_btnBack    = g_NodeUtils:seekNodeByName(self.m_root, 'btn_back')
	self.m_btnHelp    = g_NodeUtils:seekNodeByName(self.m_root, 'btn_help')
	self.m_txChipNum  = g_NodeUtils:seekNodeByName(self.m_root, 'tx_chip_num')
	self.m_addChipBtn = g_NodeUtils:seekNodeByName(self.m_root, 'bg_currency_num')
	self.m_bgRankView = g_NodeUtils:seekNodeByName(self.m_root, 'bg_currency_num1')
	self.m_txRankNum  = g_NodeUtils:seekNodeByName(self.m_root, 'tx_rank_num')
	self.m_txtTime    = g_NodeUtils:seekNodeByName(self.m_root, 'tx_time')
	self.m_viewList   = g_NodeUtils:seekNodeByName(self.m_root, 'view_list')
	self.m_txNoMatch  = g_NodeUtils:seekNodeByName(self.m_root, 'txNoMatch')
	self.m_imgNoMatch = g_NodeUtils:seekNodeByName(self.m_root, 'icon-empty')
	self.m_txMatch    = g_NodeUtils:seekNodeByName(self.m_root, 'txMatch')
	self.m_txRoomInfo = g_NodeUtils:seekNodeByName(self.m_root, 'tx_room_info')
	self.m_txBlindInfo = g_NodeUtils:seekNodeByName(self.m_root, 'tx_blind_num')
	self.m_txJoinMoney = g_NodeUtils:seekNodeByName(self.m_root, 'tx_join_money')

	self:initTabar();
	self:setupBtnClickEvent();
	-- self:setCurrentTime();

	self.m_txNoMatch:setString(GameString.get("str_new_mtt_hall_label7"))
	self.m_txMatch:setString(GameString.get("str_new_mtt_hall_label8"))
	self.m_txRoomInfo:setString(GameString.get("str_new_mtt_hall_label2"))
	self.m_txBlindInfo:setString(GameString.get("str_new_mtt_hall_label3"))
	self.m_txJoinMoney:setString(GameString.get("str_new_mtt_hall_label4"))
	self.m_txNoMatch:setVisible(false)
	self.m_imgNoMatch:setVisible(false)

	self:updateUserData()
end

--[Comment]
--获取当前时间:时：分
function MttLobbyScene:setCurrentTime()
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
    self.m_scheduleTask = g_Schedule:schedule(function()
		self.m_txtTime:setString(os.date("%H")..":".. os.date("%M")); 
	end,1,0, 1000)
end

function MttLobbyScene:initListView(data)
	self.m_listData = data or {}
    local tableW = self.m_viewList:getContentSize().width
    local tableH = self.m_viewList:getContentSize().height   
    local cellH = 110 
    local cellW = 1170

    self.m_tableView = cc.TableView:create(cc.size(tableW,tableH))
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.m_tableView:setPosition(cc.p(0,0))
    self.m_tableView:setDelegate()
    self.m_viewList:addChild(self.m_tableView)

    local function cellSizeForTable(view,idx)
        return tableW, cellH
    end

    local function numberOfCellsInTableView(view)
        return #self.m_listData
    end

    local function tableCellAtIndex(view,idx)
        local cell = view:dequeueCell()
        if not cell then
			cell = MTLobbyTableViewCell:create()
        end
		cell:updateCell(self.m_listData[idx+1])
        return cell
	end
	
    --cell点击事件
	local function ontableViewCellTouch(table,cell)
		cell:onCellTouch()
		-- g_PopupManager:show(g_PopupConfig.S_POPID.MTT_DETAIL_POP)
    end
    --cell
	local function ontableViewScroll(table,cell)
		if table.isRefreshing then
			return
		end
		local freshHight = 120
		local offSize = table:getContentOffset()
		local tbSize = table:getViewSize()
		local cvSize = table:getContainer():getContentSize()
		local isTouchMoved = table:isTouchMoved()
		local isDragging = table:isDragging()
		if isDragging and  offSize.y <= (tbSize.height-cvSize.height - freshHight) then
			table.isRefreshing = true
			Log.d("getInnerContainerSize 下拉刷新:",offSize.y)
			self:enableLoadingTouch(false)
			self:doLogic(g_SceneEvent.MTT_GET_LIST_REQUEST)
		elseif isDragging and ((tbSize.height<cvSize.height and offSize.y >= (freshHight)) 
							or (tbSize.height>=cvSize.height and offSize.y >= (freshHight + tbSize.height-cvSize.height)))then
			-- table.isRefreshing = true
			-- Log.d("getInnerContainerSize 上拉刷新:",offSize.y)
			-- self:enableLoadingTouch(false)
			-- self:doLogic(g_SceneEvent.MTT_GET_LIST_REQUEST)
		end
    end
    self.m_tableView:setBounceable(true)
    self.m_tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:registerScriptHandler(ontableViewCellTouch, cc.TABLECELL_TOUCHED)
	self.m_tableView:registerScriptHandler(ontableViewScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
	self.m_tableView.isRefreshing = false
    self.m_tableView:reloadData()
end

function MttLobbyScene:initTabar()
	local param = {
		-- bgFile = "creator/hall/blank4x4.png",
		imageFile = "creator/normalSelectionsScene/tabar.png",
		tabarSize = {width = 815, height = 74},
		text = {
			name = {
				GameString.get("str_new_mtt_hall_label5"),
				GameString.get("str_new_mtt_hall_label6"),
				GameString.get("str_new_mtt_on"),
				GameString.get("str_new_mtt_end"),
				GameString.get("str_new_mtt_main"),
			},
			fontSize = 26,
			color = {on = {r = 255, g = 255, b = 255}, off = {r = 75, g = 143, b = 227}},
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

function MttLobbyScene:enableLoadingTouch(isEnable)
	if self.m_tabarView then
		self.m_tabarView:setTouchEnabled(isEnable)
	end
	if self.m_tableView then
		-- body
		self.m_tableView:setTouchEnabled(isEnable)
		if isEnable == true and self.m_tableView.isRefreshing then
			self.m_tableView.isRefreshing = false
		end
	end
end

function MttLobbyScene:watchData(index)
    if self.m_watchDataList == nil then
        self.m_watchDataList = {
            {g_ModelCmd.NEW_MTT_LIST_DATA, self, self.updateMttList, false};
        }
    end
    g_Model:watchDataList(self.m_watchDataList);
end

function MttLobbyScene:unwatchData(index)
    if self.m_watchDataList ~= nil then
        g_Model:unwatchDataList(self.m_watchDataList);
    end
    self.m_watchDataList = nil;
end

function MttLobbyScene:onTabarClickCallback(index)
	self.m_curTab = index
	self:doLogic(g_SceneEvent.MTT_GET_LIST_REQUEST,index)
end

---- --------------------------------------------- event ---------------------------
--刷新 list
function MttLobbyScene:updateMttList(data)
    if not self.m_tableView then
        self:initListView(data)
	end

	if g_TableLib.isEmpty(data) and self.m_curTab==5  then
		self.m_txNoMatch:setVisible(true)
		self.m_imgNoMatch:setVisible(true)
	else
		self.m_txNoMatch:setVisible(false)
		self.m_imgNoMatch:setVisible(false)
	end
	self:stopTableViewTimer()
	self.m_listData = data
    self.m_tableView:reloadData()
end
function MttLobbyScene:stopTableViewTimer()
    if not self.m_tableView then
        return
	end

	for i=1,#self.m_listData do
		local cell = self.m_tableView:cellAtIndex(i-1)
		if cell then
			cell:stopInterval()
		end
	end
end

-- 设置按钮点击事件
function MttLobbyScene:setupBtnClickEvent()
	local btnsActions = {
		{ btn = self.m_btnBack,       cmds = self.onBtnBackClick },     
		{ btn = self.m_btnHelp,   cmds = self.onBtnHelpClick },    
		{ btn = self.m_addChipBtn,   cmds = self.onBtnAddChipClick }, 
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

function MttLobbyScene:onBtnBackClick()
	cc.Director:getInstance():popScene();
end

function MttLobbyScene:onBtnHelpClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.MTT_HELP_POP)
end

function MttLobbyScene:onBtnAddChipClick()
	print('MttLobbyScene:onBtnAddChipClick')
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,import("app.scenes.store").StoreConfig.STORE_POP_UP_CHIPS_PAGE)
end

return MttLobbyScene;