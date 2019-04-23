--[[--ldoc desc
@module NormalSelectionsTableCell
@author RyanXu

Date   2018-12-24
]]
-- local ViewScene = import("framework.scenes").ViewScene;
local NormalSelectionsTableCell = class("NormalSelectionsTableCell",ccui.Layout)

local SceneConfig = require('config.SceneConfig')
local BehaviorMap = import("app.common.behavior").BehaviorMap

local PrivatePopType = import("app.scenes.privateHall").PrivatePopType
-- 配置事件监听函数
NormalSelectionsTableCell.s_eventFuncMap = {
}

function NormalSelectionsTableCell:ctor(viewSize)
	self:init(viewSize)
end


function NormalSelectionsTableCell:init(viewSize)

	self.m_root = g_NodeUtils:getRootNodeInCreator("creator/normalSelectionsScene/layout/graphRoom.ccreator");
	self:add(self.m_root)
	local size = self.m_root:getContentSize()
	self:setContentSize(size)
	self.m_root:setPosition(cc.p(viewSize.width/2,viewSize.height/2))

	self.m_player5Seat = g_NodeUtils:seekNodeByName(self.m_root, '5_player_seat')
	self.m_player9Seat = g_NodeUtils:seekNodeByName(self.m_root, '9_player_seat')

	self.m_txBlind = g_NodeUtils:seekNodeByName(self.m_root, 'tx_blind')

	self.m_pbPlayerNum = g_NodeUtils:seekNodeByName(self.m_root, 'pb_player_num')
	self.m_txPlayerNum = g_NodeUtils:seekNodeByName(self.m_root, 'tx_player_num')
	self.m_txRoomId = g_NodeUtils:seekNodeByName(self.m_root, 'tx_room_id')

	self.m_5PlayerSeatArray = {}

	for i=1,5 do
		local seatNode = g_NodeUtils:seekNodeByName(self.m_player5Seat, 'sit_'.. i)
		local seatImg = g_NodeUtils:seekNodeByName(seatNode, 'img_sit')
		BehaviorExtend(seatImg)
		seatImg:bindBehavior(BehaviorMap.HeadIconBehavior)

		local playerName = g_NodeUtils:seekNodeByName(seatNode, 'tx_name')
		g_NodeUtils:convertTTFToSystemFont(playerName)
		self.m_5PlayerSeatArray[(i*2-1)] = {name = playerName, header = seatImg}
	end
	
	self.m_9PlayerSeatArray = {}

	for i=1,9 do
		local seatNode = g_NodeUtils:seekNodeByName(self.m_player9Seat, 'sit_'.. i)
		local seatImg = g_NodeUtils:seekNodeByName(seatNode, 'img_sit')
		BehaviorExtend(seatImg)
		seatImg:bindBehavior(BehaviorMap.HeadIconBehavior)

		local playerName = g_NodeUtils:seekNodeByName(seatNode, 'tx_name')
		
		g_NodeUtils:convertTTFToSystemFont(playerName)
		self.m_9PlayerSeatArray[i] = {name = playerName, header = seatImg}
	end

	self.m_btnClick = g_NodeUtils:seekNodeByName(self.m_root, 'bg_table') 
	self.m_btnClick:setSwallowTouches(false)
	
    self.m_btnClick:addTouchEventListener(function(sender, eventType)
    	local x = self:getParent():getPositionX()
    	local y = self:getParent():getParent():getParent():getParent():getPositionY()
        if (eventType == ccui.TouchEventType.began) then
        	self.m_beginX = x
        	self.m_beginY = y 
        end
        if (eventType == ccui.TouchEventType.ended) then -- up
        	if math.abs(x - self.m_beginX) < 5 and  math.abs(y - self.m_beginY) < 5 then
        		self:onCellClick()
        	end
        end
    end)	
end

function NormalSelectionsTableCell:onCellClick()
	local isPrivateRoom = tonumber(self.m_data.flag) == 9
	if isPrivateRoom then
		local roomInfo = {ip = self.m_data.ip, tid = self.m_data.tid, port = self.m_data.port, flag = self.m_data.flag}
		g_PopupManager:show(g_PopupConfig.S_POPID.PRIVATE_HALL_POP, PrivatePopType.InputPassword, roomInfo)
	else
        if self.m_data.ip and self.m_data.port and self.m_data.tid then -- 高级级场
        	self:requestStart()
        end
	end
end

function NormalSelectionsTableCell:requestStart()
	g_RoomInfo:setRoomIp(self.m_data.ip)
	g_RoomInfo:setRoomPort(self.m_data.port)
	g_RoomInfo:setTid(self.m_data.tid)

	local normalRoomScene = import('app.scenes.normalRoom').scene
	cc.Director:getInstance():pushScene(normalRoomScene:create())
end

function NormalSelectionsTableCell:errorRequestQuickStart()

    g_AlertDialog.getInstance()
        :setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_common_network_problem"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_common_retry"))
        :setRightBtnTx(GameString.get("str_common_back"))
        :setCloseBtnVisible(false)
        :setLeftBtnFunc(
            function ()
                self:requestStart()
            end)
        :setRightBtnFunc(
            function ()    
            end)
        :show()
end

function NormalSelectionsTableCell:updateRankGraphItem(data)
	self.m_data = data
	local clipPath = "creator/normalSelectionsScene/img_sit.png"

	local tableNum = 0
	local seatArray = nil
	if data.all == 5 then
		self.m_player5Seat:setVisible(true)
		self.m_player9Seat:setVisible(false)
		tableNum = 5
		seatArray = self.m_5PlayerSeatArray
	elseif data.all ==  9 then
		self.m_player5Seat:setVisible(false)
		self.m_player9Seat:setVisible(true)
		tableNum = 9
		seatArray = self.m_9PlayerSeatArray
	end

	for k,v in pairs(seatArray) do
		v.header:removeIcon()
		v.name:setString('')
	end

	for i=1, #data.players do
	 	local playerData = data.players[i]
	 	local seat = seatArray[playerData.seat+1]
	 	local iconUrl = playerData.img
		 seat.header:setHeadIcon(iconUrl,nil,nil,clipPath)
		 
		-- seat.name:setString(playerData.nick)
		seat.name:setString(g_StringLib.limitLength(playerData.nick,20,88))
	end

	self.m_txRoomId:setString(tostring(data.tid))
	self.m_txBlind:setString(string.format('%s/%s',g_MoneyUtil.formatMoney(data.sb),g_MoneyUtil.formatMoney(data.bb)))
	self.m_txPlayerNum:setString(tostring(data.pc))

	local percentage = (data.pc/ data.all)*100
	self.m_pbPlayerNum:setPercent(percentage)
end

return NormalSelectionsTableCell;