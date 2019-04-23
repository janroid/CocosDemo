--[[--ldoc desc
@module MttDetailPop
@author RyanXu

Date   2018-12-24
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MttDetailPop = class("MttDetailPop",PopupBase);
BehaviorExtend(MttDetailPop);

local TabarView = import('app.common.customUI').TabarView
local MTTDetailBlindCell = require('.views.MTTDetailBlindCell')
local MTTDetailRewardCell = require('.views.MTTDetailRewardCell')
local MTTDetailRewardExtItem = require('.views.MTTDetailRewardExtItem')
local MTTDetailRankCell = require('.views.MTTDetailRankCell')

local MTTUtil = require('.MTTUtil')

-- 配置事件监听函数
MttDetailPop.s_eventFuncMap = {
	[g_SceneEvent.MTT_SHOW_ALLPY_SUCC_POP]		 = "onSignupSucc",   -- 报名成功
	[g_SceneEvent.MTT_CANCEL_SIGN_SCUU]		 	 = "onCancelSignSucc",   -- 取消报名成功
	[g_SceneEvent.MTT_DETAIL_CLOSE_POP]		 	 = "hidden",   -- 关闭弹窗
}

function MttDetailPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("MttDetailCtr"))
	self:init()
end

function MttDetailPop:show(data,index, blind)
	self.m_curBlind = blind
	self.m_data = data
	self.m_blindData = data.upblind
	self.m_rewardArr = nil
	self.m_extRewardArr = nil
	self.m_rankArr = nil
	self:initDetail()
	self.m_tableBlindStruct:reloadData()

	-- Log.d('data------',data)
	
	if index then
		self.m_tabarView:setTabarStateImmediately(index)
	else
		self.m_tabarView:setTabarStateImmediately(1)
	end

	-- g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT,{mid = self.m_data.mid,time = self.m_data.time})

	PopupBase.show(self)
end

function MttDetailPop:hidden()
	PopupBase.hidden(self)
end

function MttDetailPop:init()
	self:loadLayout("creator/mttLobbyScene/layout/mttDetailPop.ccreator");

	self.m_root = g_NodeUtils:seekNodeByName(self, 'root')	
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btn_close')	

	self.m_txTitle = g_NodeUtils:seekNodeByName(self, 'tx_title')
	self.m_tabbarBg = g_NodeUtils:seekNodeByName(self, 'tabar_bg')

	-- self.m_btnLeft = g_NodeUtils:seekNodeByName(self, 'btn_left')
	self.m_btnRight = g_NodeUtils:seekNodeByName(self, 'btn_right')
	-- self.m_txBtnLeft = g_NodeUtils:seekNodeByName(self, 'tx_left_btn')
	self.m_txBtnRight = g_NodeUtils:seekNodeByName(self, 'tx_right_btn')

	-- view info
	self.m_viewInfo = g_NodeUtils:seekNodeByName(self,'view_info');
	self.m_viewInfo:jumpToTop()
	self.m_txBeginTime = g_NodeUtils:seekNodeByName(self, 'tx_begin_time')
	self.m_txSignCost = g_NodeUtils:seekNodeByName(self, 'tx_sign_cost')
	self.m_txMttPool = g_NodeUtils:seekNodeByName(self, 'tx_mtt_pool')
	self.m_txPoolMoney = g_NodeUtils:seekNodeByName(self, 'tx_pool_money')
	self.m_txPlayerLimit = g_NodeUtils:seekNodeByName(self, 'tx_player_limit')
	self.m_txPlayerNum = g_NodeUtils:seekNodeByName(self, 'tx_player_num')
	self.m_txRewardNum = g_NodeUtils:seekNodeByName(self, 'tx_reward_num')
	self.m_txStartChips = g_NodeUtils:seekNodeByName(self, 'tx_start_chips')
	self.m_txRebuyInfo = g_NodeUtils:seekNodeByName(self, 'tx_rebuy_info')
	self.m_txAddonInfo = g_NodeUtils:seekNodeByName(self, 'tx_addon_info')
	-- self.m_txChipsInfo = g_NodeUtils:seekNodeByName(self, 'tx_chips_info')
	-- self.m_txCurBlind = g_NodeUtils:seekNodeByName(self, 'tx_cur_blind')
	
	----------------------

	-- view blind
	self.m_viewBlind = g_NodeUtils:seekNodeByName(self,'view_blind');
	self.m_txLevel = g_NodeUtils:seekNodeByName(self,'tx_level');
	self.m_txBlind = g_NodeUtils:seekNodeByName(self,'tx_blind');
	self.m_txAnti = g_NodeUtils:seekNodeByName(self,'tx_anti');
	self.m_txRiseTime = g_NodeUtils:seekNodeByName(self,'tx_rise_time');
	self.m_viewBlindStruct = g_NodeUtils:seekNodeByName(self,'view_blind_struct');
	------------------------------

	-- view reward
	self.m_viewReward = g_NodeUtils:seekNodeByName(self,'view_reward');
	self.m_txRewardRank= g_NodeUtils:seekNodeByName(self,'tx_reward_rank');
	self.m_txRewardTitle = g_NodeUtils:seekNodeByName(self,'tx_reward_title');
	self.m_viewRewardInfo = g_NodeUtils:seekNodeByName(self,'view_reward_info');
	self.m_viewDynamicPool = g_NodeUtils:seekNodeByName(self,'view_dynamic_pool');
	self.m_txDynamicDesc =  g_NodeUtils:seekNodeByName(self,'tx_dynamic_desc');
	self.m_txAdditional =  g_NodeUtils:seekNodeByName(self,'tx_additional'); 
	self.m_layoutRewardExt =  g_NodeUtils:seekNodeByName(self,'layout_reward_ext');
	self.m_viewDynamicPoolCtr = g_NodeUtils:seekNodeByName(self,'view_dynamic_pool_ctr') 
	------------------------------

	-- view rank
	self.m_viewRank = g_NodeUtils:seekNodeByName(self,'view_rank');
	self.m_txRankIndex= g_NodeUtils:seekNodeByName(self,'tx_rank_index');
	self.m_txPlayerName = g_NodeUtils:seekNodeByName(self,'tx_player_name');
	self.m_txChipsAmount =  g_NodeUtils:seekNodeByName(self,'tx_chips_amount');
	self.m_viewRankInfo = g_NodeUtils:seekNodeByName(self,'view_rank_info');
	self.m_viewRankUnable = g_NodeUtils:seekNodeByName(self,'view_rank_unable');
	self.m_txRankNoData = g_NodeUtils:seekNodeByName(self,'tx_no_rank_data');
	------------------------------

	self:initString()
	self:initTabar();
	self:initBlindStructTable()
	self:initRewardInfoTable()
	self:initRankInfoTable()
	self:initBtnClickEvent()

    g_Model:watchData(g_ModelCmd.TOURNAMENT_DETAIL_DATA, self, self.detailHandler, false);
    -- g_Model:watchData(g_ModelCmd.TOURNAMENT_USER_DATA, self, self.userListHandler, false);
end

function MttDetailPop:initString()
	self.m_txBeginTime:setElementText(0,GameString.get('str_new_mtt_rule_time'))
	self.m_txSignCost:setElementText(0,GameString.get('str_new_mtt_rule_apply_fee'))
	self.m_txMttPool:setElementText(0,GameString.get('str_new_mtt_rule_pool')) 
	self.m_txPoolMoney:setElementText(0,GameString.get('str_new_mtt_rule_fixed')) 
	self.m_txPlayerLimit:setElementText(0,GameString.get('str_new_mtt_rule_player_limit')) 
	self.m_txPlayerNum:setElementText(0,GameString.get('str_new_mtt_rule_apply_num')) 
	self.m_txRewardNum:setElementText(0,GameString.get('str_new_mtt_rule_reward_rate')) 
	self.m_txStartChips:setElementText(0,GameString.get('str_new_mtt_rule_origal')) 
	self.m_txRebuyInfo:setElementText(0,GameString.get('str_new_mtt_detail_rebuy')) 
	self.m_txAddonInfo:setElementText(0,GameString.get('str_new_mtt_detail_addon')) 

	self.m_txLevel:setString(GameString.get('str_new_mtt_lv'))
	self.m_txBlind:setString(GameString.get('str_new_mtt_bline'))
	self.m_txAnti:setString(GameString.get('str_new_mtt_ante'))
	self.m_txRiseTime:setString(GameString.get('str_new_mtt_raise_time'))

	self.m_txRewardRank:setString(GameString.get('str_new_mtt_rank_index'))
	self.m_txRewardTitle:setString(GameString.get('str_new_mtt_reward'))

	self.m_txDynamicDesc:setString(GameString.get('str_new_mtt_detail_dynamic_desc'))
	self.m_txAdditional:setString(GameString.get('str_new_mtt_detail_additional'))

	self.m_txRankIndex:setString(GameString.get('str_new_mtt_detail_rank_index'))
	self.m_txPlayerName:setString(GameString.get('str_new_mtt_detail_rank_player'))
	self.m_txChipsAmount:setString(GameString.get('str_new_mtt_detail_rank_chips'))

	self.m_txRankNoData:setString(GameString.get('str_new_mtt_no_rank_data'))
end

function MttDetailPop:initBlindStructTable()
    local tableW = self.m_viewBlindStruct:getContentSize().width
    local tableH = self.m_viewBlindStruct:getContentSize().height   

    self.m_tableBlindStruct = cc.TableView:create(cc.size(tableW,tableH))
    self.m_tableBlindStruct:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_tableBlindStruct:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.m_tableBlindStruct:setPosition(cc.p(0,0))
    self.m_tableBlindStruct:setDelegate()
    self.m_viewBlindStruct:addChild(self.m_tableBlindStruct)

    local function cellSizeForTable(view,idx)
        return tableW, 40
    end

    local function numberOfCellsInTableView(view)
        return #self.m_blindData or 0
    end

    local function tableCellAtIndex(view,idx)
        local cell = view:dequeueCell()
        if not cell then
			cell = MTTDetailBlindCell:create()
        end
		cell:updateCell(self.m_blindData[idx+1],idx+1,self.m_curBlind)
        return cell
	end

    self.m_tableBlindStruct:setBounceable(true)
    self.m_tableBlindStruct:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableBlindStruct:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableBlindStruct:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
end

function MttDetailPop:initRankInfoTable()
	local tableW = self.m_viewRankInfo:getContentSize().width
    local tableH = self.m_viewRankInfo:getContentSize().height   

    self.m_tableRankInfo = cc.TableView:create(cc.size(tableW,tableH))
    self.m_tableRankInfo:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_tableRankInfo:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.m_tableRankInfo:setPosition(cc.p(0,0))
    self.m_tableRankInfo:setDelegate()
    self.m_viewRankInfo:addChild(self.m_tableRankInfo)

    local function cellSizeForTable(view,idx)
        return tableW, 55
    end

    local function numberOfCellsInTableView(view)
        return #self.m_rankArr or 0
    end

    local function tableCellAtIndex(view,idx)
        local cell = view:dequeueCell()
        if not cell then
			cell = MTTDetailRankCell:create()
        end
        cell:updateCell(self.m_rankArr[idx+1],idx+1)
        return cell
	end

    self.m_tableRankInfo:setBounceable(true)
    self.m_tableRankInfo:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableRankInfo:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableRankInfo:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
end

function MttDetailPop:initRewardInfoTable()
	local tableW = self.m_viewRewardInfo:getContentSize().width
    local tableH = self.m_viewRewardInfo:getContentSize().height   

    self.m_tableRewardInfo = cc.TableView:create(cc.size(tableW,tableH))
    self.m_tableRewardInfo:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_tableRewardInfo:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.m_tableRewardInfo:setPosition(cc.p(0,0))
    self.m_tableRewardInfo:setDelegate()
    self.m_viewRewardInfo:addChild(self.m_tableRewardInfo)

    local function cellSizeForTable(view,idx)
        return tableW, 40
    end

    local function numberOfCellsInTableView(view)
        return #self.m_rewardArr or 0
    end

    local function tableCellAtIndex(view,idx)
        local cell = view:dequeueCell()
        if not cell then
			cell = MTTDetailRewardCell:create()
        end
		cell:updateCell(self.m_rewardArr[idx+1])
        return cell
	end

    self.m_tableRewardInfo:setBounceable(true)
    self.m_tableRewardInfo:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableRewardInfo:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableRewardInfo:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
end

function MttDetailPop:initDetail()
	
    -- local remainStartTime = tonumber(self.m_data.time) * 1000 -  os.time() * 1000;
    -- local remainDelayTime = (remainStartTime + tonumber(self.m_data.delay)*1000)/1000

	-- local z = math.modf( remainDelayTime / 60 )  -- 取整数
	-- z = z == 0 and 1 or z

	-- local str = MTTUtil:culTime(self.m_data.time*1000,self.m_data.now*1000,true) or ""
	-- local dt = math.modf( tonumber(self.m_data.delay) / 60 )
	-- -- local msg = g_StringLib.substitute(GameString.get("str_new_mtt_rule_before_time_num1"),(dt-z),z ) or ""
	-- local msg = GameString.get("str_new_mtt_rule_before_time_num1") .. self:getDelayTime(remainDelayTime) .." )"
	-- if remainDelayTime<=0 or dt<=z then
	-- 	msg = ""
	-- end
	-- self.m_txBeginTime:setElementText(1,str..msg);
	self:startInterval()
	self.m_txTitle:setString(self.m_data.name)

	self.m_txSignCost:setElementText(1,MTTUtil.getDisplaySignupWay(self.m_data))

	local str = "";
    local arr = g_StringLib.split(self.m_data.prize,",");
    if arr then
        if #arr == 1 then
            if tonumber(arr[1]) == 1 then
                str = GameString.get('str_new_mtt_fixed_reward');
            elseif tonumber(arr[1]) == 2 then
                str = GameString.get('str_new_mtt_dynamic_reward');
            end
        elseif #arr == 2 then
            str = GameString.get('str_new_mtt_fixed_reward') .. "+" .. GameString.get('str_new_mtt_dynamic_reward'); --保底+动态
        end
    end
	self.m_txMttPool:setElementText(1,str)

	self.m_viewRewardInfo:setVisible(false)
	self.m_viewDynamicPool:setVisible(false)
	self.m_layoutRewardExt:setVisible(false)
	self.m_txAdditional:setVisible(false)

	self.m_txPoolMoney:setElementText(1, g_MoneyUtil.formatMoney(tonumber(self.m_data.fixed))) 
	self.m_txPlayerLimit:setElementText(1,g_StringLib.substitute(GameString.get("str_new_mtt_detail_player_limit_num"),self.m_data.min_num,self.m_data.max_num)) 
	self.m_txPlayerNum:setElementText(1,self.m_data.num .. " / " ..self.m_data.max_num) 
	self.m_txRewardNum:setElementText(1,g_StringLib.substitute(GameString.get("str_new_mtt_reward_rate"),self.m_data.rate)) 
	self.m_txStartChips:setElementText(1,g_MoneyUtil.formatMoney(tonumber(self.m_data.init))) 

	self.m_txRebuyInfo:setElementText(1,g_StringLib.substitute(GameString.get("str_new_mtt_detail_rebuy_time"),self.m_data.rebuyMax)) 
	self.m_txAddonInfo:setElementText(1,g_StringLib.substitute(GameString.get("str_new_mtt_detail_addon_time"),self.m_data.addonMax))

	self:updateApplyBtn()
end
        
MttDetailPop.stopInterval = function(self)
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
end
        
MttDetailPop.startInterval = function(self)
    self:stopInterval();
    self.m_currentTime = os.time();
    self.m_scheduleTask = g_Schedule:schedule(function()
		self:intervalHandler()
	end,1,0,10000) 
end
        

MttDetailPop.intervalHandler = function(self)
	
    local remainStartTime = tonumber(self.m_data.time) * 1000 -  os.time() * 1000;
    local remainDelayTime = (remainStartTime + tonumber(self.m_data.delay)*1000)/1000

	local dt = math.modf( tonumber(self.m_data.delay) / 60 )
	local str = MTTUtil:culTime(self.m_data.time*1000,self.m_data.now*1000,true) or ""
	local msg = GameString.get("str_new_mtt_rule_before_time_num1") .. self:getDelayTime(remainDelayTime) .." )"
	if remainDelayTime<=0 or remainStartTime>0 then
		self:stopInterval()
		self:updateApplyBtn()
		msg = ""
	end
	self.m_txBeginTime:setElementText(1,str..msg);
end

function MttDetailPop:detailHandler(data)

    self.m_txPlayerNum:setElementText(1,data.inum .. " / " ..self.m_data.max_num) 
    -- Log.d('detailHandler--------',data)
end

function MttDetailPop:userListHandler(data)
	-- Log.d('userListHandler--------',data)
end


function MttDetailPop:updateApplyBtn(btnType)

	local arr = g_StringLib.split(self.m_data.signup,",");
	self.m_applyType = arr[1];
	self.m_txBtnRight:setVisible(true)
	self.m_data.btn = btnType or self.m_data.btn
    if(g_TableLib.isTable(self.m_data)) then
    	self.m_btnRight:setVisible(true)
    	self.m_signupArr = MTTUtil.getUserSignupWay(self.m_data)
    	local file
        if self.m_data.btn == 3 then --报名
            file = "creator/mttLobbyScene/imgs/lobby/btnSignUp.png"
            self.m_txBtnRight:setString(GameString.get("str_new_mtt_list_apply")) -- 
        elseif self.m_data.btn == 4 then --取消报名
            file = "creator/common/button/btn_red_short_normal.png" 
            self.m_txBtnRight:setString(GameString.get("str_new_mtt_list_cancel")) -- 
        elseif self.m_data.btn == 5 then --进入
            file = "creator/mttLobbyScene/imgs/lobby/btnEnter.png"
            self.m_txBtnRight:setString(GameString.get("str_new_mtt_list_enter")) -- 
	    elseif self.m_data.btn == 6 then--观看
            file = "creator/mttLobbyScene/imgs/lobby/btnLookOn.png"
            self.m_txBtnRight:setString(GameString.get("str_new_mtt_list_watch")) -- 
        else
        	self.m_btnRight:setVisible(false)
        end

        self.m_btnRight:loadTextureNormal(file)
        self.m_btnRight:loadTexturePressed(file)
	end
	
	if tostring(g_RoomInfo:getRoomIp())==tostring(self.m_data.ip) and tonumber(g_RoomInfo:getRoomPort())==tonumber(self.m_data.port) then
		self.m_btnRight:setVisible(false)
	end
end

function MttDetailPop:onCancelSignSucc(vo)
	self:updateApplyBtn(vo.btn);
end

function MttDetailPop:onSignupSucc(vo)
	self:updateApplyBtn(vo.mttData.btn);
end

function MttDetailPop:onBtnSignUpClick(sender)
    
    if self.m_data.btn == 3 then -- 報名
        if #self.m_signupArr>1 then
            g_EventDispatcher:dispatch(g_SceneEvent.MTT_SHOW_APPLY_WAY_POP,self.m_data,self.m_signupArr)
            return
        end
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_APPLY_REQUEST,{mid = self.m_data.mid,time = self.m_data.time,payType = self.m_applyType})

    elseif self.m_data.btn == 4 then-- 取消
        g_AlertDialog.getInstance()
            :setTitle(GameString.get("str_bigWheel_tips_title"))
            :setContent(GameString.get("str_new_mtt_cancel_apply_tip"))
            :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
            :setLeftBtnTx(GameString.get("str_new_mtt_list_cancel"))
            :setRightBtnTx(GameString.get("str_new_mtt_list_not_cancel"))
            :setLeftBtnFunc(function()
                g_EventDispatcher:dispatch(g_SceneEvent.MTT_CANCEL_REQUEST, self.m_data)
            end)
            :show()

	elseif self.m_data.btn == 5 then--进入
		if cc.Director:getInstance():getRunningScene():getName() == "RoomScene" then
			self.m_data.tid = 0
			self.m_data.tableType = g_RoomInfo.ROOM_TYPE_TOURNAMENT
			g_Model:setData(g_ModelCmd.ROOM_ENTER_MATCH_DATA, self.m_data);-- 用户在比游戏中

		else
			-- Log.d('enter----',self.m_data)
			g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT,{mid = self.m_data.mid,time = self.m_data.time})
			g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_ENTER_ROOM,{tid = 0, ip = self.m_data.ip, port = self.m_data.port})
			g_Model:setData(g_ModelCmd.ROOM_TOURNAMENT_DATA, self.m_data)  

		end
		self:hidden()
        
	elseif self.m_data.btn == 6 then--观看
        g_EventDispatcher:dispatch(g_SceneEvent.MATCH_HALL_WATCH_TOURNAMENT,{mid = self.m_data.mid,time = self.m_data.time})
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_WATCH,{mid = self.m_data.mid,time = self.m_data.time})
        g_Model:setData(g_ModelCmd.ROOM_TOURNAMENT_DATA, self.m_data)
        self:hidden()
    elseif self.m_data.btn == 7 then -- 結果
        g_EventDispatcher:dispatch(g_SceneEvent.SHOW_MTT_SINGLE_MATCH,{mttData = self.m_data,tabIndex = 4})

	end
	-- self:hidden()
end

function MttDetailPop:initTabar()
	local param = {
		bgFile = "creator/hall/blank4x4.png",
		imageFile = "creator/mttLobbyScene/imgs/lobby/btnSel.png",
		tabarSize = {width = 840, height = 51},
		text = {
			name = {
				GameString.get("str_new_mtt_detail_tab_race_info"),
				GameString.get("str_new_mtt_detail_tab_blind_struct"),
				GameString.get("str_new_mtt_detail_tab_reward"),
				GameString.get("str_new_mtt_detail_tab_rank"),
			},
			fontSize = 30,
			color = {on = {r = 254, g = 254, b = 254}, off = {r = 75, g = 143, b = 227}},
			bold = false,
		},
		index = 1,
		isMove = true,
		grid9 = {sx = 10, ex = 10, sy = 10, ey = 10},
		tabClickCallbackObj = self,
		tabClickCallbackFunc = self.onTabarClickCallback,
	}
	self.m_tabarView = TabarView:create(param)
	self.m_tabbarBg:addChild(self.m_tabarView)
	g_NodeUtils:arrangeToCenter(self.m_tabarView)
end

function MttDetailPop:onTabarClickCallback(index)
	self.m_viewInfo:setVisible(false)
	self.m_viewBlind:setVisible(false)
	self.m_viewReward:setVisible(false)
	self.m_viewRank:setVisible(false)
	if index == 1 then
		self.m_viewInfo:setVisible(true)
	elseif index == 2 then
		self.m_viewBlind:setVisible(true)
	elseif index == 3 then
		self.m_viewReward:setVisible(true)
		if self.m_rewardArr == nil then
	        local params = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_GET_BONUS)
	        params.mid = self.m_data.mid
	        params.time = self.m_data.time
	        g_HttpManager:doPost(params, self, self.onGetMttBonusResponse);
	    end
	else
		self.m_viewRank:setVisible(true)
		self.m_viewRankInfo:setVisible(false)
		self.m_viewRankUnable:setVisible(true)
        local params = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_GET_RANK)

        if self.m_data.btn == 7 then --是否结束
        	params = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_GET_RANK)
        	self.m_txChipsAmount:setVisible(false)
        else
        	params = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_MATCH_DETAIL)
        	self.m_txChipsAmount:setVisible(true)
        end

        params.mid = self.m_data.mid
        params.time = self.m_data.time
        g_HttpManager:doPost(params, self, self.onGetMttRankResponse,nil,2);
	end
end

function MttDetailPop:onGetMttBonusResponse( isSuccess, result )
	if isSuccess == true then
	    self.m_rewardArr = {};
    	self.m_extRewardArr = {};

		if(g_TableLib.isTable(result.ext)) then
	        local extLength = #result.ext;
	        for j=1,extLength do
	            table.insert(self.m_extRewardArr, result.ext[j]);
	        end
	        self:setRewardExtData()
	    end

	    if(result.ret == 1) then
	        if(g_TableLib.isTable(result.list)) then
	            local listLength = #result.list;
	            for i=1,listLength do
	                table.insert(self.m_rewardArr, result.list[i]);
	            end
	            self.m_rewardArr = self:combileData(self.m_rewardArr,self.m_extRewardArr)
	            self.m_tableRewardInfo:reloadData()
	            self.m_viewRewardInfo:setVisible(true)
	        else
	        	self.m_viewDynamicPool:setVisible(true)
	        end
	    else 
			self.m_viewDynamicPool:setVisible(true)
	    end
	end
end

function MttDetailPop:onGetMttRankResponse( isSuccess, result )
	Log.d('onGetMttRankResponse---',result)
	if isSuccess == true then
		local plrList = result["plr"]
		if plrList and not g_TableLib.isEmpty(plrList) then
			self.m_rankArr = plrList
			self.m_viewRankInfo:setVisible(true)
			self.m_viewRankUnable:setVisible(false)
			self.m_tableRankInfo:reloadData()
		end
	end
end

function MttDetailPop:setRewardExtData()
	self.m_layoutRewardExt:setVisible(true)
	self.m_layoutRewardExt:removeAllChildren()

	if #self.m_extRewardArr ~= 0 then
		self.m_txAdditional:setVisible(true)
	end

	for i=1, #self.m_extRewardArr do
		local item = MTTDetailRewardExtItem:create()
		item:updateCell(self.m_extRewardArr[i])
		self.m_layoutRewardExt:addChild(item)
	end
	self.m_layoutRewardExt:forceDoLayout()

	local scrollSize = self.m_viewDynamicPool:getContentSize()

	local size = self.m_layoutRewardExt:getContentSize()
	local x,y = self.m_layoutRewardExt:getPosition()
	local innerSize = self.m_viewDynamicPool:getInnerContainerSize()

	local ctrPY = size.height-y
	ctrPY = math.max(ctrPY,scrollSize.height)
	self.m_viewDynamicPool:setInnerContainerSize(cc.size(innerSize.width,ctrPY))
	self.m_viewDynamicPoolCtr:setPosition(cc.p(scrollSize.width/2,ctrPY))
	self.m_viewDynamicPool:jumpToTop()
end

function MttDetailPop:initBtnClickEvent()
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
	self.m_btnRight:addClickEventListener(
		function(sender)
			self:onBtnSignUpClick()
		end
	)
	self.m_root:addClickEventListener(
		function(sender)
			self:onBtnCloseClick()
		end
	)
end

function MttDetailPop:onBtnCloseClick()
	self:hidden()
end

function MttDetailPop:onCleanup()
	self:stopInterval()
	g_Model:unwatchData(g_ModelCmd.TOURNAMENT_DETAIL_DATA, self, self.detailHandler);
    -- g_Model:unwatchData(g_ModelCmd.TOURNAMENT_USER_DATA, self, self.userListHandler);
	PopupBase.onCleanup(self)
end

function MttDetailPop:combileData( arr, extArr )
    local ret = g_TableLib.copyTab(arr);
    if arr == nil or #arr == 0 or g_TableLib.isEmpty(arr) then
        return {};
    end
    if extArr == nil or #extArr == 0 then
        return arr;
    end
    for i=1,#extArr do
    	if ret[i] == nil then
    		ret[i]  = g_TableLib.copyTab(extArr[i])
    	else
    		ret[i].exp = ret[i].exp + extArr[i].exp
    		ret[i].point = ret[i].point + extArr[i].point
    		ret[i].coalaa = ret[i].coalaa + extArr[i].coalaa
    		ret[i].money = ret[i].money + extArr[i].money
    		if(ret[i].desc ~= "") then
            	ret[i].desc = ret[i].desc .. "+";
        	end
    		ret[i].desc = ret[i].desc .. extArr[i].desc
    	end
    end
    return ret;
end

    
MttDetailPop.getDelayTime = function(self,time)
    local hour = MTTUtil:timeUtils(tostring(math.floor(time/60)));
    local minute = MTTUtil:timeUtils(tostring(math.floor(time % 60)));
    local str = MTTUtil:timeUtils(tostring(hour)) .. " : " .. MTTUtil:timeUtils(tostring(minute));
    return str
end

return MttDetailPop;