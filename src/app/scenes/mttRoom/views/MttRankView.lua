--[[--ldoc desc
@module MttRankView
@author RyanXu

Date   2018-12-24
]]
local MttRankView = class("MttRankView",cc.Node);

local MttRankViewCell = require('.views.MttRankViewCell')

-- 配置事件监听函数
MttRankView.s_eventFuncMap = {
}

function MttRankView:ctor()
	-- PopupBase.ctor(self);
	-- self:bindCtr(require("views.MttRebuyAddonCtr"))

	self.m_rankArr = {}
	Log.d('getUserChips',g_RoomInfo:getUserChips())
	self:init()
end

function MttRankView:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/mttRoom/layout/mttRankView.ccreator");
	self:addChild(self.m_root)

	self.m_bg		= g_NodeUtils:seekNodeByName(self.m_root, 'bgRank')
	self.m_btnRight = g_NodeUtils:seekNodeByName(self.m_root, 'btnRight')
	self.m_iconOpend = g_NodeUtils:seekNodeByName(self.m_root, 'btnArrowRight')
	self.m_txNoSignin = g_NodeUtils:seekNodeByName(self.m_root, 'txNoSignin')
	self.m_iconClosed = g_NodeUtils:seekNodeByName(self.m_root, 'btnArrowLeft')
	self.m_viewRankInfo = g_NodeUtils:seekNodeByName(self.m_root, 'view_rank_info')
	self.m_viewSelfRankInfo = g_NodeUtils:seekNodeByName(self.m_root, 'view_self_rank_info')
	
	self.m_txNoSignin:setVisible(false)
	self.m_txNoSignin:setString(GameString.get("str_new_mtt_not_inmatch"))

	self.m_bgOriginPos = cc.p(self.m_bg:getPosition())
	self.m_bgContentSize = self.m_bg:getContentSize()

	self.m_isOpen = false

	self:initRankInfoTable()
	self:initSelfRankInfo()
	self:setupBtnClickEvent()

	self.m_isUnwatchData = false
	g_Model:watchData(g_ModelCmd.NEW_MTT_ROOM_MATCH_INFO,self,self.setMyInfoRank,false)
	g_Model:watchData(g_ModelCmd.NEW_MTT_MY_SEATCHIPS,self,self.updateMySeatChip,true)
end

-- 设置按钮点击事件
function MttRankView:setupBtnClickEvent()
	local btnsActions = {
		{ btn = self.m_btnRight,       cmds = self.onBtnRightClick },      
	}

	for i,value in ipairs(btnsActions) do
		value.btn:addTouchEventListener(function(sender, eventType)
			if (eventType == ccui.TouchEventType.ended) then -- up
				value.cmds(self)
			end
		end)
	end
end

function MttRankView:initSelfRankInfo()
    self.m_selfRankInfo = MttRankViewCell:create()
    self.m_viewSelfRankInfo:addChild(self.m_selfRankInfo)

    self.m_myRankVO = {};
    self.m_myRankVO.uid = g_AccountInfo:getId();
    self.m_myRankVO.un = g_AccountInfo:getNickName();
    self.m_myRankVO.pic = g_AccountInfo:getSmallPic();
    self.m_myRankVO.rank = 1;

	self.m_selfRankInfo:updateCell(self.m_myRankVO)
	if import("app.scenes.normalRoom").SeatManager.getInstance():selfInSeat() then
		self.m_selfRankInfo:setVisible(true)
		-- self.m_txNoSignin:setVisible(false)
	else
		self.m_selfRankInfo:setVisible(false)
		-- self.m_txNoSignin:setVisible(true)
	end
end

function MttRankView:initRankInfoTable()
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
			cell = MttRankViewCell:create()
        end
		if self.m_rankArr then
			self.m_rankArr[idx+1].rank = idx+1
			cell:updateCell(self.m_rankArr[idx+1])
		end
        return cell
	end

    self.m_tableRankInfo:setBounceable(true)
    self.m_tableRankInfo:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableRankInfo:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableRankInfo:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
end

function MttRankView:getMttInfo()
	local data = g_Model:getData(g_ModelCmd.ROOM_TOURNAMENT_DATA) or {};
    local params = HttpCmd:getMethod(HttpCmd.s_cmds.MTT_MATCH_DETAIL)
    params.mid = data.mid
    params.time = data.time
    g_HttpManager:doPost(params, self, self.onGetMttRankResponse,self.onGetMttRankResponse,2);
end

function MttRankView:onGetMttRankResponse( isSuccess, result )
	Log.d(':onGetMttRankResponse( isSuccess, result )',result)
	if self.m_isUnwatchData == false then
		self.m_isUnwatchData = true
		g_Model:unwatchData(g_ModelCmd.NEW_MTT_MY_SEATCHIPS,self,self.updateMySeatChip)
	end
	if isSuccess == true then
		local plrList = result["plr"]
		local selfInRank = false
		self.m_rankArr = plrList or {}
		self.m_tableRankInfo:reloadData()
		if plrList and not g_TableLib.isEmpty(plrList) then
			for k,v in ipairs(plrList) do
				if tonumber(v.uid) == tonumber(g_AccountInfo:getId()) then
					self.m_selfRankInfo:updateRank(k)
					self.m_selfRankInfo:updateChip(v.cp)
					selfInRank = true
				end
			end
		end
		
		if selfInRank  then -- 在排行榜
			self.m_selfRankInfo:setVisible(true)
			-- self.m_txNoSignin:setVisible(false)
		elseif import("app.scenes.normalRoom").SeatManager.getInstance():selfInSeat() then -- 在座不在榜
			self.m_selfRankInfo:updateRank()
			self.m_selfRankInfo:setVisible(true)
		else
			self.m_selfRankInfo:setVisible(false)
			-- self.m_txNoSignin:setVisible(true)
		end
	end
end

function MttRankView:onBtnRightClick()
	self.m_isOpen = not self.m_isOpen
	local endPos
	self.m_btnRight:setEnabled(false)
	if self.m_isOpen == true then
		endPos = cc.p(self.m_bgOriginPos.x - self.m_bgContentSize.width, self.m_bgOriginPos.y)
		self:getMttInfo()
	else
		endPos = self.m_bgOriginPos
	end
	
	local endCall = cc.CallFunc:create(function(sender)
		if self.m_isOpen == true then
			self.m_iconOpend:setVisible(true)
			self.m_iconClosed:setVisible(false)
			if import("app.scenes.normalRoom").SeatManager.getInstance():selfInSeat() then
				self:updateMySeatChip(tonumber(g_Model:getData(g_ModelCmd.NEW_MTT_MY_SEATCHIPS)))
			end
		else
			self.m_iconOpend:setVisible(false)
			self.m_iconClosed:setVisible(true)
		end
		self.m_btnRight:setEnabled(true)
	end)
	local moveAction = cc.MoveTo:create(0.5, endPos)	
	local sequenceAction = cc.Sequence:create(moveAction,endCall)
	self.m_bg:runAction(sequenceAction)
end

function MttRankView:setMyInfoRank(value)
	self.m_selfRankInfo:updateRank(value.rank)
end

function MttRankView:updateMySeatChip(value)
	self.m_selfRankInfo:updateChip(value)
end

function MttRankView:clearAndHidden()
	self.m_rankArr = {}
	if self.m_tableRankInfo then
		self.m_tableRankInfo:reloadData()
	end

	if self.m_selfRankInfo then
		local cp = tonumber(g_Model:getData(g_ModelCmd.NEW_MTT_MY_SEATCHIPS))
		self:updateMySeatChip(cp)
		self.m_selfRankInfo:setVisible(false)
		self.m_selfRankInfo:updateRank(1)
	end

	if self.m_isOpen == true then
		self:onBtnRightClick()
	end
end

function MttRankView:onCleanup()
	g_Model:unwatchData(g_ModelCmd.NEW_MTT_ROOM_MATCH_INFO,self,self.setMyInfoRank)
	if self.m_isUnwatchData == false then
		g_Model:unwatchData(g_ModelCmd.NEW_MTT_MY_SEATCHIPS,self,self.updateMySeatChip)
	end
end


return MttRankView;