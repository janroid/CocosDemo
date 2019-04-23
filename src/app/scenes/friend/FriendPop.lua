--[[--ldoc desc
@module FriendPop
@author ReneYang

Date   2018-11-19
]]
local FriendConfig = require('FriendConfig')
local FriendUtil = require('FriendUtil')
local FriendItem = require("FriendItem")
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local FriendPop = class("FriendPop",PopupBase);
BehaviorExtend(FriendPop);

-- 配置事件监听函数
FriendPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
	[g_SceneEvent.FRIEND_REQUEST_FRIEND_LIST]	 =  "showFriendList",
	[g_SceneEvent.FRIEND_DELETE_FRIEND_SUCCESS]  = "onDeleteFriendSuccess",
	[g_SceneEvent.FRIEND_REFRESH_ITEM_DATA]      =  "onItemDataRefresh",
	[g_SceneEvent.FRIEND_RECALL_SUCCESS]    	 = "onRecallSuccess";
}

function FriendPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("FriendCtr"))
	self:bindBehavior(BehaviorMap.DownloadBehavior);
	self:init()
end

function FriendPop:onEnter()
	PopupBase.onEnter(self, true)
end
function FriendPop:onExit()
	PopupBase.onExit(self, true)
end
function FriendPop:show()
	PopupBase.show(self)
	self:registerEvent()
end
function FriendPop:onCleanup()
	PopupBase.onCleanup(self)
	self:cancelDownloadTask()
end

function FriendPop:hidden()
	PopupBase.hidden(self)
	self:unRegisterEvent()
	self.m_currentFriend = nil
	self.m_lastCheckeddItem = nil
	self.m_lastShowDeleteItem = nil
	self.m_rightUser:setVisible(false)
	self.m_rightInvite:setVisible(true)
end

function FriendPop:init()
	-- do something
	
	-- 加载布局文件
	self:loadLayout("creator/friend/friend.ccreator");

	self.m_titleImg =  g_NodeUtils:seekNodeByName(self,'titleImg') 
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btnClose')

	self.m_labelInvite = g_NodeUtils:seekNodeByName(self, 'labelInvite')
	self.m_btnInvite = g_NodeUtils:seekNodeByName(self, 'btnLeftInvite')
	self.m_rightInvite = g_NodeUtils:seekNodeByName(self, 'rightInvite')
	self.m_btnFBInvite = g_NodeUtils:seekNodeByName(self, 'btnFBInvite')
	self.m_labelFBInvite = g_NodeUtils:seekNodeByName(self, 'labelFBInvite')
	self.m_labelFBInviteReward = g_NodeUtils:seekNodeByName(self, 'FBInviteReward')

	self.m_rightUser = g_NodeUtils:seekNodeByName(self, 'rightUser')
	self.m_imgUserIconFrame = g_NodeUtils:seekNodeByName(self, 'userIconFrame')
	self.m_imgUserIcon = g_NodeUtils:seekNodeByName(self, 'userIcon')
	self.m_imgVip = g_NodeUtils:seekNodeByName(self, 'imgVip')
	self.m_imgSex = g_NodeUtils:seekNodeByName(self, 'imgSex')
	self.m_labelNickName = g_NodeUtils:seekNodeByName(self, 'labelNickname')
	self.m_labelLevel = g_NodeUtils:seekNodeByName(self, 'labelLevel')
	self.m_rtChips = g_NodeUtils:seekNodeByName(self, 'richTextChips')
	self.m_labelPlayNum = g_NodeUtils:seekNodeByName(self, 'labelPlayNum')
	self.m_labelWinRate = g_NodeUtils:seekNodeByName(self, 'labelWinRate')
	self.m_labelFriendStatus = g_NodeUtils:seekNodeByName(self, 'labelUserStatus')
	self.m_btnTrace = g_NodeUtils:seekNodeByName(self, 'btnTrace')
	self.m_labelTrace = g_NodeUtils:seekNodeByName(self, 'labelTrace')
	self.m_btnRecall = g_NodeUtils:seekNodeByName(self, 'btnRecall')
	self.m_labelRecall = g_NodeUtils:seekNodeByName(self, 'labelRecall')
	self.m_btnSendChip = g_NodeUtils:seekNodeByName(self, 'btnSendChip')
	self.m_labelSendChip = g_NodeUtils:seekNodeByName(self, 'labelSendChip')
	self.m_btnSendGift = g_NodeUtils:seekNodeByName(self, 'btnSendGift')
	self.m_labelSendGift = g_NodeUtils:seekNodeByName(self, 'labelSendGift')

	self.m_titleImg:setTexture(switchFilePath("friend/imgs/friend_title.png"))
	g_NodeUtils:convertTTFToSystemFont(self.m_labelNickName)

	
	self:initString()
	self:setListener()
end

function FriendPop:initString()
	self.m_labelInvite:setString(GameString.get("str_friend_invite"))
	self.m_labelFBInvite:setString(GameString.get("str_friend_invite_fb_title"))
	self.m_labelSendGift:setString(GameString.get("str_friend_send_gift"))
	self.m_labelTrace:setString(GameString.get('str_friend_trace'))
	self.m_labelRecall:setString(GameString.get('str_friend_callback'))
	self.m_labelFBInviteReward:setString(GameString.get("str_friend_invite_fb_desc"))
end

function FriendPop:setListener()
	self.m_btnClose:addClickEventListener(function()
		g_PopupManager:hidden(g_PopupConfig.S_POPID.FRIEND_POP)
	end)
	self.m_btnInvite:addClickEventListener(function()
		self.m_rightInvite:setVisible(true)
		self.m_rightUser:setVisible(false)
	end)
	self.m_btnFBInvite:addClickEventListener(function() 
		if g_AccountInfo:getLoginFrom() ~= g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
			g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_friend_invite_only_fb"))
		else
			self:doLogic(g_SceneEvent.FRIEND_INVITE_FACEBOOK_FRIENDS, params)
		end
	end)
	self.m_btnSendChip:addClickEventListener(function()
        self.m_btnSendChip:setEnabled(false);
		self:doLogic(g_SceneEvent.FRIEND_GIVE_CHIPS, self.m_currentFriend)
	end)
	self.m_btnSendGift:addClickEventListener(function()
		self:doLogic(g_SceneEvent.FRIEND_GIVE_GIFT, self.m_currentFriend.uid)
	end)
	self.m_btnTrace:addClickEventListener(function()
		self:doLogic(g_SceneEvent.FRIEND_TRACK, self.m_currentFriend)
		self:hidden()
	end)
	self.m_btnRecall:addClickEventListener(function()
		self:doLogic(g_SceneEvent.FRIEND_RECALL, self.m_currentFriend.uid)
	end)
	g_NodeUtils:seekNodeByName(self,'bg'):addClickEventListener(function() end)
end

function FriendPop:showFriendList(data)
	self.m_data = data
	local rankListView = g_NodeUtils:seekNodeByName(self,'friendList'); 
	rankListView:removeAllChildren()
	local size = rankListView:getContentSize();
	-- ListView
    self.m_friendListView = ccui.ListView:create()
    self.m_friendListView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)     -- 设置方向为垂直方向  
    self.m_friendListView:setBounceEnabled(true)                             -- 滑动惯性
    self.m_friendListView:setContentSize(size)  
    self.m_friendListView:setItemsMargin(0)                                 -- item间距
    self.m_friendListView:setScrollBarEnabled(false)                         -- 设置滚动条隐藏
	rankListView:addChild(self.m_friendListView)
	-- 创建10个item
    for i = 1,#data do
		local item = FriendItem:create();
		item:refreshData(data[i])
		item:setContentSize(cc.size(354,94))
		item:addClickEventListener(function(target)
			self:onItemClicked(target)
		end)
		item:addTouchEventListener(function(target,event)
			if event == 0 then
				self.m_touchBeganPos = target:getTouchBeganPosition()
				if self.m_lastShowDeleteItem and self.m_lastShowDeleteItem.refreshDeleteBtnVisible then
					self.m_lastShowDeleteItem:refreshDeleteBtnVisible(false)
				end
			elseif event == 1 then
				self.m_touchMovePos = target:getTouchMovePosition()
				if self.m_touchBeganPos.x - self.m_touchMovePos.x>50
					and math.abs(self.m_touchBeganPos.y - self.m_touchMovePos.y) < 50 then
					target:refreshDeleteBtnVisible(true)
					self.m_lastShowDeleteItem = target
					self:onItemClicked(target)
				end
			end
			-- Log.d("addTouchEventListener^&^&^&^&^&", event)
		end)
        self.m_friendListView:pushBackCustomItem(item)
	end
end

-- 好友列表item点击事件
function FriendPop:onItemClicked(item)
	if self.m_lastCheckeddItem and self.m_lastCheckeddItem ~= item then
		if self.m_lastCheckeddItem.refreshCheckStatus then
			self.m_lastCheckeddItem:refreshCheckStatus(false)
		end
	end
	if item then
		item:refreshCheckStatus(true)
		self:refreshUserInfo(item:getData())
	end
	
	self.m_lastCheckeddItem = item
end

function FriendPop:refreshUserInfo(user)
	self.m_currentFriend = user

	self.m_rightUser:setVisible(true)
	self.m_rightInvite:setVisible(false)
	local sex = user.sex == "m" and 0 or 1 -- 性别 0：男 1：女
	local iconUrl = user.image_large -- 用户头像
	local vip = user.vip -- vip等级
	local nickName = user.name -- 昵称
	local level = user.level --等级
	local userTitle = user.title -- 称号
	local money= g_MoneyUtil.formatMoney(user.chip or 0) -- 筹码数
	local winNum = user.win
	local loseNum = user.lose
	local playNum = winNum + loseNum -- 玩牌局数
    local winRate = 0
    if playNum ~= 0 then 
        winRate = string.format("%.2f", winNum/playNum) -- 胜率
    end
	winRate = tonumber(winRate)*100
	local sendChip = user.sendChipLimit --赠送好友筹码数
	
	self.m_labelSendChip:setString(string.format( GameString.get("str_friend_send_chips"), g_MoneyUtil.formatMoney(sendChip)))
	
	-- 设置性别相关
	self.m_imgUserIconFrame:removeChild(self.m_maleIconFrame)
	self.m_imgUserIconFrame:removeChild(self.m_femaleIconFrame)
	if sex == 0 then
		self:createUserIconMale()
		self.m_imgUserIconFrame:addChild(self.m_maleIconFrame)
		self.m_imgSex:setTexture("creator/common/icon/icon_male.png")
	else
		self:createUserIconFemale()
		self.m_imgUserIconFrame:addChild(self.m_femaleIconFrame)
		self.m_imgSex:setTexture("creator/common/icon/icon_female.png")
	end

	-- 设置好友头像
	local size = self.m_imgUserIcon:getContentSize()
	if tonumber(iconUrl) and g_HeadConfig.HEAD_IMGS[tonumber(iconUrl)] then
        self.m_imgUserIcon:setTexture(g_HeadConfig.HEAD_IMGS[tonumber(iconUrl)].path);
        self.m_imgUserIcon:setContentSize(size)
	else
		self.m_imgUserIcon:setTexture(g_HeadConfig.DEFAUT_ICON)
		self.m_imgUserIcon:setContentSize(size)
        self:downloadImg(iconUrl,function(self,data)
           if data.isSuccess then 
                local src = data.fullFilePath;
                self.m_imgUserIcon:setTexture(src);
                self.m_imgUserIcon:setContentSize(size)
           end 
        end)
	end
	
	if vip >=1 and vip <=4 then
		self.m_imgVip:setVisible(true)
		self.m_imgVip:setTexture(string.format( "creator/common/vip/vip_icon_%s.png", vip))
	else
		self.m_imgVip:setVisible(false)
	end
	self.m_labelLevel:setString("LV."..level.." "..userTitle)
	self.m_labelNickName:setString(nickName)
	self.m_rtChips:removeElement(1)
	self.m_rtChips:removeElement(0)
	local chipTip = ccui.RichElementText:create(10,cc.c3b(196,214,236),255,GameString.get("str_friend_userinfo_chips"),nil,24)
	self.m_rtChips:insertElement(chipTip, 0)
	local chips = ccui.RichElementText:create(10,cc.c3b(242,238,141),255,tostring(money),nil,24)
    self.m_rtChips:insertElement(chips, 1)
	self.m_labelPlayNum:setString(string.format( GameString.get("str_friend_userinfo_play_num"), playNum))
	self.m_labelWinRate:setString(string.format(GameString.get("str_friend_userinfo_win_rate"), winRate.."%"))
	self.m_btnSendChip:setEnabled(user.sendChipTimes > 0);
	self:setStatus(user)
end

function FriendPop:setStatus(data)
	local friendStatus,statusText = FriendUtil.getFriendStatus(data)
	local isTrack = (friendStatus == FriendConfig.FRIEND_STATUS.Trackable or friendStatus == FriendConfig.FRIEND_STATUS.Untrackable)
	local btnEnable = (friendStatus == FriendConfig.FRIEND_STATUS.Trackable or friendStatus == FriendConfig.FRIEND_STATUS.Recallable)
	self.m_btnTrace:setEnabled(friendStatus == FriendConfig.FRIEND_STATUS.Trackable)
	self.m_btnRecall:setEnabled(friendStatus == FriendConfig.FRIEND_STATUS.Recallable);
	self.m_labelFriendStatus:setString(statusText)
	self:setBtnRecallVisible(not isTrack)
	
end

-- 设置召回按钮显示状态
function FriendPop:setBtnRecallVisible(visible)
	self.m_btnRecall:setVisible(visible)
	self.m_btnTrace:setVisible(not visible)
end


-- 创建女性玩家头像框
function FriendPop:createUserIconFemale()
	self.m_femaleIconFrame = cc.Scale9Sprite:create("creator/friend/imgs/icon_female_right.png")
	self.m_femaleIconFrame:setContentSize(self.m_imgUserIconFrame:getContentSize())
	self.m_femaleIconFrame:setAnchorPoint(0,0)
end

-- 创建男性玩家头像框
function FriendPop:createUserIconMale()
	self.m_maleIconFrame = cc.Scale9Sprite:create("creator/friend/imgs/icon_male_right.png")
	self.m_maleIconFrame:setContentSize(self.m_imgUserIconFrame:getContentSize())
	self.m_maleIconFrame:setAnchorPoint(0,0)
end

-- 删除好友
function FriendPop:onDeleteFriendSuccess(index)
	-- c++中下标从0开始 故需要减去1
	self.m_friendListView:removeItem(index-1)
	self.m_friendListView:doLayout()
	self.m_rightUser:setVisible(false)
	self.m_rightInvite:setVisible(true)
	self.m_lastShowDeleteItem = nil
	self.m_lastCheckeddItem = nil
end

-- 数据源刷新
function FriendPop:onItemDataRefresh(friend)
	if self.m_friendListView and self.m_friendListView:isVisible() and #self.m_friendListView:getItems() > 0 then
		for i=1,#self.m_friendListView:getItems() do
			local item = self.m_friendListView:getItem(i)
			if item and item:getData() and item:getData().uid == friend.uid then
				item:refreshData(friend)
				-- 当前选中的好友数据刷新
				if self.m_currentFriend and self.m_currentFriend.uid == friend.uid then
					self:refreshUserInfo(friend)
				end
				return
			end
		end
	end
end

function FriendPop:onRecallSuccess(uid)
	if(not self.m_data) then return end
	for i = 1, #self.m_data do
		if self.m_data[i] and uid == self.m_data[i].uid then
			self.m_data[i].push = -3
			self:onItemDataRefresh(self.m_data[i])
		end
	end
end

return FriendPop;