local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local OtherInfoPop = class("OtherInfoPop",PopupBase);
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local SeatManager = import("app.scenes.normalRoom").SeatManager:getInstance()
local ExpKit = require("ExpKit")
BehaviorExtend(OtherInfoPop);
-- 写死的
OtherInfoPop.s_propMap = {
   16,17,18,19,20,7,2,4,3,1,5,6,8,9,10,11,12,13,
};

---配置事件监听函数
OtherInfoPop.s_eventFuncMap =  {
	[g_SceneEvent.RANKPOP_GET_USER_INFO_RESPONSE1] = "updateView",
}

function OtherInfoPop:ctor()
	PopupBase.ctor(self)
	self:bindCtr(require(".otherInfo.OtherInfoCtr"))
	self:init()
end

function OtherInfoPop:show(data)
	if g_TableLib.isEmpty(data) then
		return
	end
	g_EventDispatcher:dispatch(g_SceneEvent.GET_USER_HDDJ_NUMBER)
	self.m_myFriend = false;
	self.m_data = data
	g_NodeUtils:seekNodeByName(self.m_root,"slider"):setPercent(50)
    self.m_sendChip = 500 * self.m_currencyMultiple
	self.m_labelgiveChipNum:setString(g_MoneyUtil.formatMoney(tostring(self.m_sendChip)))
	PopupBase.show(self)
	self.mCtr:getUserInfo(data.uid)
	self:isFriend(self.m_data)
	self:updateUserInfo(self.m_data)
end

function OtherInfoPop:init()
	-- 默認500
    self.m_currencyMultiple = tonumber(GameString.get("str_common_currency_multiple")) or 1;
    self.m_sendChip = 500 * self.m_currencyMultiple
	self:loadLayout('creator/userInfo/otherInfo.ccreator');

	self:setupUI()
end

function OtherInfoPop:setupUI()
	-- body
	local close = g_NodeUtils:seekNodeByName(self.m_root,"close")

	self.m_viewBg = g_NodeUtils:seekNodeByName(self, 'bgView')
	self.m_labelUID = g_NodeUtils:seekNodeByName(self, 'UID')
	self.m_labelName = g_NodeUtils:seekNodeByName(self, 'name')
	self.m_labelLevel = g_NodeUtils:seekNodeByName(self, 'level')
	self.m_labelWinRate = g_NodeUtils:seekNodeByName(self, 'win')
	self.m_labelRank = g_NodeUtils:seekNodeByName(self, 'rank')

	self.m_imgSex = g_NodeUtils:seekNodeByName(self, 'sexIcon')
	self.m_vipImg = g_NodeUtils:seekNodeByName(self, 'vip_icon')

	self.m_btnGiveChip = g_NodeUtils:seekNodeByName(self.m_root,"giveChipBtn")
	self.m_labelgiveChip = g_NodeUtils:seekNodeByName(self.m_root,"giveChipLabel")
	self.m_labelgiveChipNum = g_NodeUtils:seekNodeByName(self.m_root,"giveChipNum")
	self.m_labelMoney = g_NodeUtils:seekNodeByName(self.m_root, 'chips')
	self.m_headNode = g_NodeUtils:seekNodeByName(self.m_root, 'headFront')
	BehaviorExtend(self.m_headNode)
	self.m_headNode:bindBehavior(BehaviorMap.HeadIconBehavior);
	self.m_btnAddFriend = g_NodeUtils:seekNodeByName(self.m_root,"giveBtn")
	self.m_labelAddFriend = g_NodeUtils:seekNodeByName(self.m_root,"LabelGiveBtn")

	g_NodeUtils:convertTTFToSystemFont(self.m_labelName)

	self.m_btnAddFriend:addClickEventListener(function (sender)
			self:onAddFriendBtnClick()
		end)
	self.m_btnGiveChip:addClickEventListener(function (sender)
				self:onSendChipBtnClick()
			end)
	close:addClickEventListener(function (sender)
			self:onCloseheadBtnClick()
		end)

	local touchBG = g_NodeUtils:seekNodeByName(self.m_root,"touchBG")
	touchBG:addClickEventListener(function (sender)
		self:hidden()
	 end)
	 g_NodeUtils:seekNodeByName(self,'bg'):addClickEventListener(function() end)

	self.m_labelgiveChip:setString(GameString.get("str_rank_playerinfo16"))
	self.m_labelAddFriend:setString(GameString.get("str_friend_send_gift"))
	
	--赠送礼物滑动条
	local slider = g_NodeUtils:seekNodeByName(self.m_root,"slider")
	slider:loadProgressBarTexture("creator/userInfo/room/pig.png")
	slider:setMaxPercent(100)
	slider:setPercent(50)
	self.m_labelgiveChipNum:setString(g_MoneyUtil.formatMoney(tostring(self.m_sendChip)))
	slider:addEventListener(function ( node, event )
		-- body
		self.m_sendChip = math.floor(self.m_currencyMultiple * 1000 * (slider:getPercent() / 100))
		if(self.m_sendChip <= 0) then
			self.m_sendChip = 1;
		end
		self.m_labelgiveChipNum:setString(g_MoneyUtil.formatMoney(tostring(self.m_sendChip)))
	end)
	self:initProp()
end

function OtherInfoPop:initProp()	-- 道具
	local headview = g_NodeUtils:seekNodeByName(self.m_root,"giveView")
	local headlayot = headview:getInnerContainer()

	for i=1,#OtherInfoPop.s_propMap do           
		local nomStr = string.format("creator/userInfo/sysHead/imgface_no.png")
		local nomStrSel = string.format("creator/userInfo/head/head_selet_s.png")
		local nomStr1 = string.format("creator/userInfo/propAtlas/hddj_%d.png",OtherInfoPop.s_propMap[i])
		
		local bg = ccui.ImageView:create(nomStr1, ccui.TextureResType.localType)
		bg:setAnchorPoint(cc.p(0.5,0.5))
		bg:setContentSize(cc.size(84,84))
		local headBtn = ccui.Button:create(nomStr,nomStrSel,ccui.TextureResType.localType)
		headBtn:addChild(bg)
		bg:setPosition(cc.p(112/2,112/2))
		bg:setLocalZOrder(99)
		
		headBtn:ignoreContentAdaptWithSize(false)
		headBtn:setContentSize(cc.size(112,112))
		local x, y = 20+(30+100)*math.mod(i-1,4), -(33+(70+66)*math.floor((i-1)/4))+590
		headBtn:setPosition(x, y):addTo(headlayot)
		headBtn:setAnchorPoint(cc.p(0,0))
		headBtn:setTag(OtherInfoPop.s_propMap[i])

		headBtn:addClickEventListener(function (sender)
			local selfSeatId = SeatManager:getSelfSeatId()
			if g_RoomInfo:getRoomType() == g_RoomInfo.ROOM_TYPE_TOURNAMENT then
				g_AlarmTips.getInstance():setText(GameString.get("str_room_match_room_not_play_hddj")):show()
				self:hidden();
				return
				
			elseif selfSeatId == -1 then    --如果在房间里，并且没有坐下不能赠送
				g_AlarmTips.getInstance():setText(GameString.get("str_room_sit_down_play_hddj")):show()
				self:hidden();
				return
			elseif  (g_Model:getData(g_ModelCmd.USER_HDDJ_NUMBER) == nil or g_Model:getData(g_ModelCmd.USER_HDDJ_NUMBER) <= 0)  then
				--互動道具次數不夠的提示
				g_AlertDialog.getInstance()
					:setTitle(GameString.get("tips"))
					:setContent(GameString.get("str_room_not_enough_hddj"))
					:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
					:setCenterBtnTx(GameString.get("str_common_buy"))
					:setCenterBtnFunc(function()
						g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,import("app.scenes.store").StoreConfig.STORE_POP_UP_PROPS_PAGE)
					end)
					:show()
					self:hidden();
					return

			end
            local hddjData = {}
            hddjData.sendSeatId = selfSeatId-1;
            hddjData.hddjId = sender:getTag();
            hddjData.receiveSeatId = self.m_data.seatId-1
            hddjData.uid = g_AccountInfo:getId()
			g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP,hddjData)
            hddjData.receiveSeatId = self.m_data.seatId
            hddjData.sendSeatId = selfSeatId
			g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC, hddjData)
			self:hidden();
		end)
	end
	headview:jumpToTop()
end

function OtherInfoPop:updateUserInfo(data)
	
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
	self.m_labelName:setString(data.name or "")
	self.m_labelMoney:setString(string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.totalChips)))
    self.m_labelLevel:setString(g_StringLib.substitute(GameString.get("str_room_userinfo_level"), ExpKit.getLevelByExp(data.exp)));		
		
	self.m_labelRank:setString(string.format(GameString.get("str_rank_playerinfo2"),""))

	local total    = (data.winRound or 0) + (data.loseRound or 0);
    local winrate  = total > 0 and math.modf((data.winRound or 0) / total * 100) or 0;				
	winrate	= " " .. winrate	
	self.m_labelWinRate:setString(string.format(GameString.get("str_rank_playerinfo4"),winrate))
	
	local str = self.m_myFriend and GameString.get("str_friend_send_gift") or GameString.get("str_rank_playerinfo10")
	self.m_labelAddFriend:setString(str)
end

---刷新界面
function OtherInfoPop:updateView(data)
	data.rankMoney  = data.rankMoney or 0;
	local rankStr = data.rankMoney > 10000 and --排名
					">10000" or 
					data.rankMoney				
	rankStr	= " " .. rankStr			
	self.m_labelRank:setString(string.format(GameString.get("str_rank_playerinfo2"),rankStr))

	local total    = (data.win or 0) + (data.lose or 0);
    local winrate  = total > 0 and math.modf((data.win or 0) / total * 100) or 0;				
	winrate	= " " .. winrate	
	self.m_labelWinRate:setString(string.format(GameString.get("str_rank_playerinfo4"),winrate))
	self.m_labelMoney:setString(string.format(GameString.get("str_rank_playerinfo15"), g_MoneyUtil.formatMoney(data.money)))
    self.m_labelLevel:setString(g_StringLib.substitute(GameString.get("str_room_userinfo_level"), data.level));	

end

function OtherInfoPop:onCloseheadBtnClick()
	self:hidden()
end

function OtherInfoPop:onSendChipBtnClick()
	local selfSeatId = SeatManager:getSelfSeatId();
	local params = {}
    params.sendChips = self.m_sendChip;
    params.recieverSeatId = self.m_data.seatId;
    params.senderSeatId = selfSeatId;
	if SeatManager.roomType == g_RoomInfo.ROOM_TYPE_NORMAL then -- 普通场
        if (selfSeatId ~= -1) then
			self:doLogic(g_SceneEvent.USERINFOPOP_SEND_CHIP, params)
        else-- 未坐下
			g_AlarmTips.getInstance():setText(GameString.get("str_room_sit_down_send_chips")):show()
        end
    else 
		g_AlarmTips.getInstance():setText(GameString.get("str_room_match_table_send_chips")):show()
    end
	self:hidden();
end

function OtherInfoPop:onAddFriendBtnClick()
	
	if self.m_myFriend then -- 是不是好友
		-- 赠送礼物
		local data = {}
		data.friend = self.m_data.uid
		data.type = import("app.scenes.gift").GiftPop.s_showType.SHOW_SEND_GIFT_ROOM
		g_EventDispatcher:dispatch(g_SceneEvent.OPEN_GIFT_POPUP,data);
	else
        --如果在座，则通过server进行广播，不在座，只发出本人看得到的加牌友动画
		g_EventDispatcher:dispatch(g_SceneEvent.FRIEND_ADD_FRIEND,self.m_data.uid)
		--播放动画
		local data = {}	
		data.sendSeatId = SeatManager:getSelfSeatId()
		data.receiveSeatId = self.m_data.seatId
		if SeatManager:getSelfSeatId()>-1 then
			g_EventDispatcher:dispatch(g_SceneEvent.USERINFOPOP_SEV_ADD_FRIEND, data)
		else
			g_EventDispatcher:dispatch(g_SceneEvent.USERINFO_PLAY_ADD_FRIEND_ANIM, data)
		end
	end
	self:hidden() 
end

function OtherInfoPop:onCloseBtnClick()
	self:hidden()
end

function OtherInfoPop:isFriend(data)
    -- 判断是否是好友
    local uid = tostring(data.uid);
    local friendList = g_Model:getData(g_ModelCmd.FRIEND_UID_LIST);
    if (friendList) then
        for n=1,#friendList do
            if (friendList[n] == uid) then
                self.m_myFriend = true;
                break;
            end
        end
	end
end

return OtherInfoPop