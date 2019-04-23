--[[--ldoc desc
@module NormalSelectionsItemCell
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local NormalSelectionsItemCell = class("NormalSelectionsItemCell",ccui.Layout)
local TableLimit = import("app.scenes.normalRoom").TableLimit

local SceneConfig = require('config.SceneConfig')

local PrivatePopType = import("app.scenes.privateHall").PrivatePopType
-- 配置事件监听函数
NormalSelectionsItemCell.s_eventFuncMap = {
}

function NormalSelectionsItemCell:ctor()
	self:init()
	self:registerScriptHandler(function(state)
		if state == "enter" then
			--self:onEnter_()
		elseif state == "exit" then
			self:onExit()
		elseif state == "enterTransitionFinish" then
			--self:onEnterTransitionFinish_()
		elseif state == "exitTransitionStart" then
			--self:onExitTransitionStart_()
		elseif state == "cleanup" then
			--self:onCleanup_()
		end
	end)
end


function NormalSelectionsItemCell:init()

	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/normalSelectionsScene/layout/roomListItem.ccreator");
	self:add(self.m_root)
	local size = self.m_root:getContentSize()
	self:setContentSize(cc.size(size.width,100))

	self.m_bgLowRank = g_NodeUtils:seekNodeByName(self.m_root, 'bg_lowRank_listItem')
	self.m_bgMiddleRank = g_NodeUtils:seekNodeByName(self.m_root, 'bg_middleRank_listItem')
	self.m_bgHighRank = g_NodeUtils:seekNodeByName(self.m_root, 'bg_highRank_listItem')

	self.m_iconFivePlayer = g_NodeUtils:seekNodeByName(self.m_root, 'icon_five_person')
	self.m_iconNinePlayer = g_NodeUtils:seekNodeByName(self.m_root, 'icon_nine_person')

	self.m_txRoomNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_roomNum')
	self.m_txBlind = g_NodeUtils:seekNodeByName(self.m_root, 'tx_blind')
	self.m_txCarry = g_NodeUtils:seekNodeByName(self.m_root, 'tx_carry_chip')
	self.m_txBonusNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_bonus_num')
	self.m_txPlayerNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_player_num')

	self.m_iconPlayerNum = g_NodeUtils:seekNodeByName(self.m_root, 'icon_player_num')
	self.m_pbPlayerNum = g_NodeUtils:seekNodeByName(self.m_root, 'pb_player_num')

	self.m_iconFastPlayer = g_NodeUtils:seekNodeByName(self.m_root, 'icon_fast_play')
	self.m_iconExpDouble = g_NodeUtils:seekNodeByName(self.m_root, 'icon_exp_double')
	self.m_iconPrivateRoom = g_NodeUtils:seekNodeByName(self.m_root, 'icon_private_room')
	self.m_iconMustPlay = g_NodeUtils:seekNodeByName(self.m_root, 'icon_must_play')
	self.m_iconMustFastPlay = g_NodeUtils:seekNodeByName(self.m_root, 'icon_must_play_and_fast')

	self.m_btnClick = g_NodeUtils:seekNodeByName(self.m_root, 'btn_click') 
	self.m_btnClick:setSwallowTouches(false)
	
    self.m_btnClick:addTouchEventListener(function(sender, eventType)
        if (eventType == ccui.TouchEventType.began) then
        	self.m_beginY = self:getParent():getPositionY()
        end
        if (eventType == ccui.TouchEventType.ended) then -- up
        	if math.abs(self:getParent():getPositionY() - self.m_beginY) < 5 then
        		self:onCellClick()
        	end
        end
    end)	
end

function NormalSelectionsItemCell:onCellClick()
-- 9是设置了密码，8是无密码
	local flag = tonumber(self.m_data.flag)
	if flag == g_RoomInfo.ROOM_TYPE_PRIVATE then
		local roomInfo = {ip = self.m_data.ip, tid = self.m_data.roomID, port = self.m_data.port, flag = g_RoomInfo.ROOM_TYPE_PRIVATE}
		g_PopupManager:show(g_PopupConfig.S_POPID.PRIVATE_HALL_POP, PrivatePopType.InputPassword, roomInfo)
	elseif flag == 8 then
		local data = {
			ip = self.m_data.ip,
			port = self.m_data.port,
			tid = self.m_data.roomID,
			passwordChecked = true;
			flag = g_RoomInfo.ROOM_TYPE_PRIVATE,
		}
		self:enterRoom(data)
	else
		if TableLimit.checkAccess(self.m_data.field,g_RoomInfo.ROOM_TYPE_NORMAL,true) then
			if self.m_data.ip and self.m_data.port and self.m_data.roomID then -- 高级级场
				local data = {
					ip   = self.m_data.ip;
					port = self.m_data.port;
					tid  = self.m_data.roomID;
				}
				self:enterRoom(data)
			else -- 初级和中级场
				self:requestQuickStart()
			end
		end
	end
end

function NormalSelectionsItemCell:requestQuickStart()
	g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.TABLE_QUICKIN)
    param.field = self.m_data.field
    param.sb = self.m_data.sb
    param.flag = 1
	g_HttpManager:doPost(param, self, self.onQuickStartResponse)
end

function NormalSelectionsItemCell:onQuickStartResponse(isSuccess, data)
	g_Progress.getInstance():dismiss()
    if not isSuccess then
        self:errorRequestQuickStart()
		return
	end
	Log.d("NormalSelectionsItemCell:onQuickStartResponse",data)

	local roomData = {
		ip   = data.ip;
		port = data.port;
		tid  = data.tid;
	}
	self:enterRoom(roomData)
end

function NormalSelectionsItemCell:enterRoom(data)

	local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(data)
end

function NormalSelectionsItemCell:errorRequestQuickStart()

    g_AlertDialog.getInstance()
        :setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_common_network_problem"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_common_retry"))
        :setRightBtnTx(GameString.get("str_common_back"))
        :setCloseBtnVisible(false)
        :setLeftBtnFunc(
            function ()
                -- self:requestQuickStart(4)
            end)
        :setRightBtnFunc(
            function ()    
            end)
        :show()
end

function NormalSelectionsItemCell:updateRankListItem(data, field,index)
	self.m_data = data

	self.m_bgLowRank:setVisible(false)
	self.m_bgMiddleRank:setVisible(false)
	self.m_bgHighRank:setVisible(false)
	self.m_iconPlayerNum:setVisible(false)
	self.m_pbPlayerNum:setVisible(false)
	self.m_iconFivePlayer:setVisible(false)
	self.m_iconNinePlayer:setVisible(false)
	
	self.m_txRoomNum:setString(tostring(data.roomID))
	self.m_txBlind:setString(string.format('%s/%s',g_MoneyUtil.formatMoney(data.sb),g_MoneyUtil.formatMoney(data.bb)))
	self.m_txCarry:setString(string.format('%s/%s',g_MoneyUtil.formatMoney(data.minb),g_MoneyUtil.formatMoney(data.maxb)))
	self.m_txBonusNum:setString(tostring(data.addPoint))
	self.m_txPlayerNum:setString(tostring(data.playing_num))

	if data.player_cap == 5 then
		self.m_iconFivePlayer:setVisible(true)
	elseif data.player_cap ==  9 then
		self.m_iconNinePlayer:setVisible(true)
	end



    if data.flag == 2 then
        self.m_iconFastPlayer:setVisible(true)
    elseif data.flag == 8 or data.flag == 9  then
        self.m_iconPrivateRoom:setVisible(true)
    else
    	self.m_iconFastPlayer:setVisible(false)
    	self.m_iconPrivateRoom:setVisible(false)
    end

	if field == SceneConfig.roomRankType.lowRank then
		self.m_bgLowRank:setVisible(true)
		self.m_iconPlayerNum:setVisible(true)
	elseif field == SceneConfig.roomRankType.middleRank then
		self.m_bgMiddleRank:setVisible(true)
		self.m_iconPlayerNum:setVisible(true)
	elseif field == SceneConfig.roomRankType.highRank then
		self.m_bgHighRank:setVisible(true)
		self.m_pbPlayerNum:setVisible(true)
		local percentage = (data.playing_num / data.player_cap)*100
		self.m_pbPlayerNum:setPercent(percentage)
	end
end

function NormalSelectionsItemCell:onExit()
	g_HttpManager:cancelRequestByObj(self)
end

return NormalSelectionsItemCell;