--[[--ldoc desc
@module PlayInfoPop
@author ReneYang

Date   2018-12-4
]]
local FriendConfig = import('app.scenes.friend').FriendConfig
local FriendUtil = import('app.scenes.friend').FriendUtil
local FriendVO = import('app.scenes.friend').FriendVO
local FriendManager = import('app.scenes.friend').FriendManager
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local PlayInfoPop = class("PlayInfoPop",PopupBase);
BehaviorExtend(PlayInfoPop);

-- 配置事件监听函数
PlayInfoPop.s_eventFuncMap = {
	[g_SceneEvent.RANKPOP_GET_USER_INFO_RESPONSE] = "updateInfo",
}

function PlayInfoPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".playerInfo.PlayerInfoCtr"))
	self:init()
end

function PlayInfoPop:show(data,isInRoom)
	PopupBase.show(self)
	self.m_isInRoom = isInRoom or false
	-- 房间里面玩家自己用 座位上的数据
	if self.m_isInRoom then
		self:updateRoomUserInfo(data)
		self:updateSelfNode(data)
		data = data.uid
	end
	g_EventDispatcher:dispatch(g_SceneEvent.RANKPOP_GET_USER_INFO, data,isInRoom)
end

function PlayInfoPop:hidden()
	PopupBase.hidden(self)
	self.m_headNode:setVisible(false)
	self.m_userInfoNode:setVisible(false)
	self.m_nodeOther:setVisible(false)
	self.m_nodeSelf:setVisible(false)
end

function PlayInfoPop:init()
	-- 加载布局文件
	self:loadLayout("creator/rank/rankPlayerInfo/rankPlayerInfo.ccreator");
	self.m_closeBtn = g_NodeUtils:seekNodeByName(self, 'closeBtn')
	self.m_headNode = g_NodeUtils:seekNodeByName(self, 'headFront')
	self.m_labelUID = g_NodeUtils:seekNodeByName(self, 'UID')
	self.m_imgSex = g_NodeUtils:seekNodeByName(self, 'sex_icon')
	self.m_vipImg = g_NodeUtils:seekNodeByName(self, 'vip_icon')

	self.m_labelName = g_NodeUtils:seekNodeByName(self, 'name')
	self.m_labelMoney = g_NodeUtils:seekNodeByName(self, 'money')
	self.m_labelLevel = g_NodeUtils:seekNodeByName(self, 'level')
	self.m_labelRank = g_NodeUtils:seekNodeByName(self, 'rank')
	self.m_labelScore = g_NodeUtils:seekNodeByName(self, 'score')
	self.m_labelWinRate = g_NodeUtils:seekNodeByName(self, 'successRate')

	self.m_nodeSelf = g_NodeUtils:seekNodeByName(self, 'mySelfNode')
	self.m_btnMyFriend = g_NodeUtils:seekNodeByName(self, 'btnMyFriend')
	self.m_labelMyFriend = g_NodeUtils:seekNodeByName(self, 'labelMyFriend')
	self.m_btnMyProps = g_NodeUtils:seekNodeByName(self, 'btnMyProps')
	self.m_labelMyProps = g_NodeUtils:seekNodeByName(self, 'labelMyProps')
	self.m_btnMyGifts = g_NodeUtils:seekNodeByName(self, 'btnMyGifts')
	self.m_labelMyGifts = g_NodeUtils:seekNodeByName(self, 'labelGifts')

	self.m_nodeOther = g_NodeUtils:seekNodeByName(self, 'otherNode')
	self.m_btnLeft = g_NodeUtils:seekNodeByName(self, 'btnLeft')
	self.m_labelLeft = g_NodeUtils:seekNodeByName(self, 'labelLeft')
	self.m_labelStatus = g_NodeUtils:seekNodeByName(self, 'labelStatus')
	self.m_btnRight = g_NodeUtils:seekNodeByName(self, 'btnRight')
	self.m_labelRight = g_NodeUtils:seekNodeByName(self, 'labelRight')
	self.m_userInfoNode = g_NodeUtils:seekNodeByName(self, 'infoNode')
	self.m_btnNode = g_NodeUtils:seekNodeByName(self, 'btnNode')
	
	self.m_btnNode:setVisible(false)

	g_NodeUtils:convertTTFToSystemFont(self.m_labelName)

	self.m_btnRight:setPressedActionEnabled(true)
	self.m_btnRight:setZoomScale(-0.04)

	BehaviorExtend(self.m_headNode)
	self.m_headNode:bindBehavior(BehaviorMap.HeadIconBehavior);
	
	self.m_headNode:setVisible(false)
	self.m_userInfoNode:setVisible(false)
	self.m_nodeOther:setVisible(false)
	self.m_nodeSelf:setVisible(false)

	self:initListener()
end

function PlayInfoPop:initListener()
	self.m_closeBtn:addClickEventListener(function()
		self:hidden()
	end)
	g_NodeUtils:seekNodeByName(self, 'root'):addClickEventListener(function()
		self:hidden()
	end)
	g_NodeUtils:seekNodeByName(self, 'bg'):addClickEventListener(function()
	end)
end

function PlayInfoPop:updateInfo(data)

	if self.m_isInRoom then
		data.rankMoney  = data.rankMoney or 0;
		local rankStr = data.rankMoney > 10000 and --排名
						">10000" or 
						data.rankMoney				
		rankStr	= " " .. rankStr
		g_AccountInfo:setRank(rankStr)			
		self.m_labelRank:setString(string.format(GameString.get("str_rank_playerinfo2"),rankStr))

		local total    = (data.win or 0) + (data.lose or 0);
		local winrate  = total > 0 and math.modf((data.win or 0) / total * 100) or 0;				
		winrate	= " " .. winrate	
		self.m_labelWinRate:setString(string.format(GameString.get("str_rank_playerinfo4"),winrate))
		self.m_labelMoney:setString(string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.money)))
		self.m_labelLevel:setString(g_StringLib.substitute(GameString.get("str_room_userinfo_level"), data.level));
		self.m_labelScore:setString(string.format(GameString.get("str_rank_playerinfo3"), " " .. (data.score or "")))
		return
	end

	if g_TableLib.isEmpty(data) or not data.level then
		self.m_userInfoNode:setVisible(false)
		self.m_btnNode:setVisible(false)
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		return
	end
	self.m_userInfoNode:setVisible(true)
	self.m_btnNode:setVisible(true)
	self:updateUserInfo(data)
	if tostring(data.uid) == tostring(g_AccountInfo:getId()) then
		self:updateSelfNode(data)
	else
		self:updateOtherNode(data)
	end
end

function PlayInfoPop:updateRoomUserInfo(data)
	self.m_headNode:setVisible(true)
	self.m_userInfoNode:setVisible(true)
	self.m_btnNode:setVisible(true)
	local clipPath = "creator/rank/rankPlayerInfo/head_bg.png"
	local size = self.m_headNode:getContentSize()
	local border = 4
	self.m_headNode:setHeadIcon(data.photoUrl,size.width - border,size.height - border, clipPath)--,clipPlist)

	local vip = tonumber(data.vip)
	if vip and vip > 0 and vip < 5  then
		self.m_vipImg:setTexture(string.format("creator/common/vip/vip_icon_%d.png", vip))
		self.m_vipImg:setVisible(true)
	else
		self.m_vipImg:setVisible(false)
	end

	local sex = data.gender == "m" and 0 or 1
	if sex == 0 then
		self.m_imgSex:setTexture("creator/common/icon/icon_male.png")
	else
		self.m_imgSex:setTexture("creator/common/icon/icon_female.png")
	end
	self.m_labelUID:setString(string.format(GameString.get("str_rank_playerinfo5"), data.uid or ""))
	self.m_labelName:setString(g_StringLib.limitLength(data.name,24,320))
	self.m_labelMoney:setString(string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.totalChips)))
    self.m_labelLevel:setString(g_StringLib.substitute(GameString.get("str_room_userinfo_level"), require("ExpKit").getLevelByExp(data.exp)));

	self.m_labelRank:setString(string.format(GameString.get("str_rank_playerinfo2"), g_AccountInfo:getRank()))

	self.m_labelScore:setString(string.format(GameString.get("str_rank_playerinfo3"), " " .. g_AccountInfo:getScore()))
	local total    = (data.winRound or 0) + (data.loseRound or 0);
    local winrate  = total > 0 and math.modf((data.winRound or 0) / total * 100) or 0;
	self.m_labelWinRate:setString(string.format(GameString.get("str_rank_playerinfo4"), " " .. winrate))
end

function PlayInfoPop:updateUserInfo(data)
	self.m_headNode:setVisible(true)
	self.m_userInfoNode:setVisible(true)
	local clipPath = "creator/rank/rankPlayerInfo/head_bg.png"
	local size = self.m_headNode:getContentSize()
	local border = 4
	self.m_headNode:setHeadIcon(data.s_picture,size.width - border,size.height - border, clipPath)--,clipPlist)

	local vip = tonumber(data.vip)
	if vip and vip > 0 and vip < 5  then
		self.m_vipImg:setTexture(string.format("creator/common/vip/vip_icon_%d.png", vip))
		self.m_vipImg:setVisible(true)
	else
		self.m_vipImg:setVisible(false)
	end

	local sex = data.sex == "m" and 0 or 1
	if sex == 0 then
		self.m_imgSex:setTexture("creator/common/icon/icon_male.png")
	else
		self.m_imgSex:setTexture("creator/common/icon/icon_female.png")
	end
	self.m_labelUID:setString(string.format(GameString.get("str_rank_playerinfo5"), data.uid or ""))
	self.m_labelName:setString(g_StringLib.limitLength(data.nick,24,320))
	self.m_labelMoney:setString(string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.money)))
	self.m_labelLevel:setString(string.format(GameString.get("str_rank_playerinfo1"), data.level))
	data.rankMoney  = data.rankMoney or 0;
	local rankStr = data.rankMoney > 10000 and --排名
					">10000" or 
					data.rankMoney
	self.m_labelRank:setString(string.format(GameString.get("str_rank_playerinfo2"), " " .. rankStr))

	self.m_labelScore:setString(string.format(GameString.get("str_rank_playerinfo3"), " " .. data.score))
	local total    = (data.win or 0) + (data.lose or 0);
    local winrate  = total > 0 and math.modf((data.win or 0) / total * 100) or 0;
	self.m_labelWinRate:setString(string.format(GameString.get("str_rank_playerinfo4"), " " .. winrate))
end


function PlayInfoPop:updateSelfNode(data)
	self.m_nodeSelf:setVisible(true)
	self.m_nodeOther:setVisible(false)
	
	self.m_labelMyFriend:setString(GameString.get('str_rank_playerinfo6'))
	self.m_labelMyProps:setString(GameString.get('str_rank_playerinfo7'))
	self.m_labelMyGifts:setString(GameString.get('str_rank_playerinfo8'))

	self.m_btnMyFriend:addClickEventListener(function()
		g_PopupManager:show(g_PopupConfig.S_POPID.FRIEND_POP)
		self:hidden()
	end)
	self.m_btnMyProps:addClickEventListener(function()
		local StoreConfig = import("app.scenes.store").StoreConfig
		g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_OWNER_PROPS_PAGE)
		self:hidden()
	end)
	self.m_btnMyGifts:addClickEventListener(function()
		local data = {}
		data.type = import("app.scenes.gift").GiftPop.s_showType.SHOW_MY_GIFT
		g_EventDispatcher:dispatch(g_SceneEvent.OPEN_GIFT_POPUP,data);
		self:hidden()
	end)
end
function PlayInfoPop:updateOtherNode(data)
	FriendManager.getInstance()
	self.m_nodeSelf:setVisible(false)
	self.m_nodeOther:setVisible(true)
	
	local isFriend = (data.fri == 1)
	local leftStr = isFriend and GameString.get('str_rank_playerinfo9') or GameString.get('str_rank_playerinfo10')
	self.m_labelLeft:setString(leftStr)
	
	if data.location then
        for k,v in pairs(data.location) do
            data[tostring(k)] = v;
        end
    end
	local friendVO = FriendVO:create()
	friendVO:parse(data)
	self:updateTrack(friendVO)
	self.m_btnLeft:addClickEventListener(function()
		if isFriend then
			-- 赠送礼物
			g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_GIVE_GIFT, friendVO.uid)

		else
			-- 加好友
			g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_ADD_FRIEND, data.uid)
		end
		self:hidden()
	end)
end
function PlayInfoPop:updateTrack(data)
	local friendStatus,statusText = FriendUtil.getFriendStatus(data)
	local isTrack = (friendStatus == FriendConfig.FRIEND_STATUS.Trackable or friendStatus == FriendConfig.FRIEND_STATUS.Untrackable)
	local btnEnable = (friendStatus == FriendConfig.FRIEND_STATUS.Trackable or friendStatus == FriendConfig.FRIEND_STATUS.Recallable)
	
	self.m_btnRight:setEnabled(btnEnable)
	self.m_labelStatus:setString(statusText)
	local rightStr = isTrack and GameString.get('str_friend_trace') or GameString.get('str_friend_callback')
	self.m_labelRight:setString(rightStr)
	self.m_btnRight:addClickEventListener(function()
		if isTrack then
			-- 好友追踪
			g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_TRACK, data)
		else
			-- 好友召回
			g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_RECALL, data.uid)
		end
		self:hidden()
	end)
end

function PlayInfoPop:onCleanup()
	PopupBase.onCleanup(self)
end


return PlayInfoPop;