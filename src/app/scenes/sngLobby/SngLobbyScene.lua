--[[--ldoc desc
@module SngLobbyScene
@author PatricLiu
Date   20180117
]]
local ViewScene = import("framework.scenes").ViewScene;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SngLobbyScene = class("SngLobbyScene",ViewScene);
local SngLobbyData = require("SngLobbyData")
local SngLobbyItem = require("SngLobbyItem")
local StoreConfig = import("app.scenes.store").StoreConfig
BehaviorExtend(SngLobbyScene);

SngLobbyScene.PLAYER_NUM1 =5;
SngLobbyScene.PLAYER_NUM2 =9;
---配置事件监听函数
SngLobbyScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
	[g_SceneEvent.UPDATE_USER_HEAD_ICON] = "updateUserData";
	[g_SceneEvent.UPDATE_USER_DATA]   = "updateUserData";
}

function SngLobbyScene:ctor()
	ViewScene.ctor(self)
	self:bindCtr(require("SngLobbyCtr"))

	self:init()
end

function SngLobbyScene:onEnter()
	ViewScene.onEnter(self)
	self:initListener()
	self:bindDataWatcher()
	self:doLogic(g_SceneEvent.SNG_REQ_USER_INFO_DATA)	
	self:doLogic(g_SceneEvent.GET_SNG_MTT_REFRESH,2)	
	
end

function SngLobbyScene:onExit()
	self:unBindDataWatcher()
end

function SngLobbyScene:init()
	self.m_root = self:loadLayout('creator/sngLobbyScene/sngLobbyScene.ccreator')
	self:addChild(self.m_root)
	self.m_stageWidth = cc.Director:getInstance():getWinSize().width

	self.m_txTitleTips			= g_NodeUtils:seekNodeByName(self.m_root,"label_title_tips")
	self.m_btnBack				= g_NodeUtils:seekNodeByName(self.m_root,"btn_back")
	self.m_txCurTime			= g_NodeUtils:seekNodeByName(self.m_root,"label_time")
	self.m_ticketNum			= g_NodeUtils:seekNodeByName(self.m_root,"label_ticket_count")
	self.m_btnHelp				= g_NodeUtils:seekNodeByName(self.m_root,"btn_help")
	self.m_txChipNum  			= g_NodeUtils:seekNodeByName(self.m_root, 'tx_chip_num')
	self.m_addChipBtn 			= g_NodeUtils:seekNodeByName(self.m_root, 'bg_currency_num')

	self.m_viewTab				= g_NodeUtils:seekNodeByName(self.m_root,"view_tab")
	self.m_btnFive				= g_NodeUtils:seekNodeByName(self.m_root,"btn_five")
	self.m_btnNine				= g_NodeUtils:seekNodeByName(self.m_root,"btn_nine")
	self.m_ListViewContainer  	= g_NodeUtils:seekNodeByName(self.m_root,"view_list_container")

	self.m_viewBottom			= g_NodeUtils:seekNodeByName(self.m_root,"view_bottom")
	self.m_txRank 				= g_NodeUtils:seekNodeByName(self.m_root,"label_badge_level")
	self.m_txScore				= g_NodeUtils:seekNodeByName(self.m_root,"label_jifen")	
	self.m_txScoreLack			= g_NodeUtils:seekNodeByName(self.m_root,"label_jifen_lack")
	self.m_txIncomeChip 		= g_NodeUtils:seekNodeByName(self.m_root,"label_income_chip")
	self.m_txIncomeChipNum		= g_NodeUtils:seekNodeByName(self.m_root,"label_income_chip_num")
	self.m_txEnterMatchCount	= g_NodeUtils:seekNodeByName(self.m_root,"label_total_enter_count")
	self.m_txFirstCount			= g_NodeUtils:seekNodeByName(self.m_root,"label_first_count")
	self.m_txSecondCount		= g_NodeUtils:seekNodeByName(self.m_root,"label_second_count")
	self.m_txThirdCount			= g_NodeUtils:seekNodeByName(self.m_root,"label_third_count")

	self.m_viewTab:setVisible(false)
	
	self.m_txScoreLack:setSystemFontSize(g_AppManager:getAdaptiveConfig().SNGLobby.RankGapWithPreviousFontSize or 24)
	self.m_txIncomeChip:setSystemFontSize(g_AppManager:getAdaptiveConfig().SNGLobby.MonthMatchIncomeFontSize or 24)
	
	self.m_txTitleTips:setString(string.format(GameString.get("str_sng_lobby_tips"),tostring(SngLobbyScene.PLAYER_NUM1)))
	self.m_txIncomeChip:setString(GameString.get("str_sng_lobby_income"))
	
	local txTitle = g_NodeUtils:seekNodeByName(self.m_root, "label_title")
	txTitle:setVisible(false)

	local label = GameString.createLabel(GameString.get("str_sng_lobby_title"), g_AppManager:getAdaptiveConfig().SNGLobby.TitleFontName, 42)
	txTitle:getParent():addChild(label)
	label:setPosition(txTitle:getPosition())
	label:setColor(txTitle:getColor())
	label:enableBold()
	self.m_txTitle = label
	
	--self.m_txTitle:enableOutline(cc.c4b(255,255,255,255),2)
	
	self.m_itemVector ={}	
	self.m_curShowedNum = 0
	self.m_player = SngLobbyScene.PLAYER_NUM1
	self:initItem()
	self:hideItems();
	self.m_cupVector = {
		[1] = self.m_txFirstCount;
		[2] = self.m_txSecondCount;
		[3] = self.m_txThirdCount;
	}

	self.m_viewBottom:setOpacity(0)
	local x,y = self.m_viewBottom:getPosition()
	self.m_viewBottom:setPosition(cc.p(x,-y))
	self:hideItems();
	--播放Item和底部信息栏动画
	self:initTabarView()
	self:playAnim()
    self:updateTime()
    self:updateUserData()
end

function SngLobbyScene:initListener()
	self.m_addChipBtn:addClickEventListener(handler(self,self.onBtnBuyChipClick))
	self.m_btnBack:addClickEventListener(handler(self,self.onBtnBackClick))
	self.m_btnFive:addClickEventListener(handler(self,self.onBtnFiveClick))
	self.m_btnNine:addClickEventListener(handler(self,self.onBtnNineClick))
    self.m_btnHelp:addClickEventListener(handler(self,self.onBtnHelpClick))
	for i = 1,#self.m_itemVector do
		self.m_itemVector[i]:addClickEventListener(function(sender)
			self:onSngItemClick(sender)			
		end)
	end
end
function SngLobbyScene:updateUserData()
	self.m_txChipNum:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
	local w = self.m_txChipNum:getContentSize().width
	w = w<140 and 140 or w
	self.m_addChipBtn:setContentSize(w + 49,40)
	if w > 150 then
		self.m_addChipBtn:setAnchorPoint(0,0)
		self.m_addChipBtn:setPosition(cc.p(150-w,0))
	end
end

function SngLobbyScene:initTabarView()
	self.m_btnFive:setOpacity(255)
	self.m_btnNine:setOpacity(1)
	self.m_curTab = 1
end

function SngLobbyScene:bindDataWatcher()
	if self.watchProperyArr == nil then
        self.watchProperyArr ={
            {g_ModelCmd.USER_DATA, "money"    ,  self, self.watchMoney    , true};    --钱
            {g_ModelCmd.USER_DATA, "ticket"   ,  self, self.watchTicket   , true};    --票
        };
        g_Model:watchPropertyList(self.watchProperyArr);
    end

    if(self.watchDataList == nil) then
        self.watchDataList =
        {
             {g_ModelCmd.SNG_MTT_DATA,self,self.initBottomInfo, false};--这里不能立即触发，否则可能会受锦标赛影响
            --  {g_ModelCmd.SNG_HALL_IS_LOADING, self,self.isLoading, false};
             {g_ModelCmd.SNG_HALL_CURRENT_MATCH_DATA,self,self.currentMatchData,};
        };
        g_Model:watchDataList(self.watchDataList);
    end
end

function SngLobbyScene:unBindDataWatcher()
	if(self.watchProperyArr ~= nil) then
        g_Model:unwatchPropertyList(self.watchProperyArr);
        self.watchProperyArr = nil;
    end
    if(self.watchDataList ~= nil) then
        g_Model:unwatchDataList(self.watchDataList);
        self.watchDataList = nil;
    end
end

function SngLobbyScene:initItem()
	self.m_primaryItem = g_NodeUtils:seekNodeByName(self.m_root,"img_primary")
	table.insert(self.m_itemVector, self.m_primaryItem);
	self.m_imgTitlePrimary = g_NodeUtils:seekNodeByName(self.m_primaryItem, "item_title_primary")
	self.m_imgTitlePrimary:setTexture(switchFilePath('sngLobbyScene/imgs/txt_primary.png'))

	self.m_middleItem = g_NodeUtils:seekNodeByName(self.m_root,"img_middle")
	table.insert(self.m_itemVector, self.m_middleItem);
	self.m_imgTitleMiddle = g_NodeUtils:seekNodeByName(self.m_middleItem, "item_title_middle")
	self.m_imgTitleMiddle:setTexture(switchFilePath("sngLobbyScene/imgs/txt_mid_level.png"))

	self.m_highItem = g_NodeUtils:seekNodeByName(self.m_root,"img_high")
	table.insert(self.m_itemVector, self.m_highItem);
	self.m_imgTitleHigh = g_NodeUtils:seekNodeByName(self.m_highItem, "item_title_high")
	self.m_imgTitleHigh:setTexture(switchFilePath("sngLobbyScene/imgs/txt_high_level.png"))

	self.m_masterItem = g_NodeUtils:seekNodeByName(self.m_root,"img_master")
	table.insert(self.m_itemVector, self.m_masterItem);
	self.m_imgTitleMaster = g_NodeUtils:seekNodeByName(self.m_masterItem, "item_title_master")
	self.m_imgTitleMaster:setTexture(switchFilePath("sngLobbyScene/imgs/txt_master.png"))

	self.m_itemPos = {}
	for i = 1, #self.m_itemVector do
		local item = SngLobbyItem:create()
		self.m_itemVector[i]:addChild(item)
		item:setTag(100)
		local temp = {}
		temp.x,temp.y = self.m_itemVector[i]:getPosition()
		table.insert(self.m_itemPos, temp)
	end

	self:setItems()
end

function SngLobbyScene:initBottomInfo(data)
	if g_TableLib.isEmpty(data) or  not data.ranking then 
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		return 
	end

	self.m_txScore:setString(data.soc or "0")
	self.m_txRank:setString(tostring(data.ranking) == "0" and "-" or data.ranking);
	
	local rank = tonumber(data.ranking)
	if rank == nil then
		rank = 0
	end
	self.m_txRank:setString(rank>999 and "-" or data.ranking)
	local scoreStr = g_StringLib.substitute(GameString.get("str_sng_lobby_score_lack"),data.distance)
	self.m_txScoreLack:setString(scoreStr)

	self.m_txIncomeChipNum:setString("+"..tostring(data.inCome))

	if data.prize == nil or data.prize =="" then return end
	local prizeCount = g_StringUtils.split(data.prize,",")
	self.m_txEnterMatchCount:setString(g_StringLib.substitute(GameString.get("str_sng_lobby_total_entries"),prizeCount[1]));
	for i = 2,#prizeCount do
		self.m_cupVector[i-1]:setString(prizeCount[i])
	end
end

function SngLobbyScene:setItems()
	for i,v in pairs(self.m_itemVector) do
        v:setOpacity(0)
        v:setPosition(cc.p(self.m_stageWidth,self.m_itemPos[i].y));
    end
end

function SngLobbyScene:playAnim()
--	local fadeAction = cc.FadeTo:create(1,255)
--	self.m_btnHelp:runAction(fadeAction)

    local delayframes = {0, 3, 7, 13};
	for i=1,#self.m_itemVector do
        local actDelay  = cc.DelayTime:create(delayframes[i]/60);
        local actMove   = cc.MoveTo:create(0.3, cc.p(self.m_itemPos[i].x,self.m_itemPos[i].y));
        local actAlpha  = cc.FadeTo:create(0.3,255);
		local action    = cc.Sequence:create(actDelay,actMove, actAlpha,
		cc.CallFunc:create(function (  )
			self.m_itemVector[i]:setEnabled(true)
		end)
	);
		
		self.m_itemVector[i]:setEnabled(false)
		self.m_itemVector[i]:runAction(action)
	end

	local x,y = self.m_viewBottom:getPosition()
    local actDelay = cc.DelayTime:create(20/60);
    local actMove = cc.MoveTo:create(0.4, cc.p(x,-y));
    local actAlpha = cc.FadeTo:create(0.4, 255);
	local action = cc.Sequence:create(actDelay,actMove,actAlpha);
	self.m_viewBottom:runAction(action)
	local userData = g_AccountInfo:getMoney()

    self:showMark(userData or 0);

	--刷新数据
	self:doLogic(g_SceneEvent.SNG_LOBBY_REFRESH_DATA)	
	--self:doLogic(g_SceneEvent.GET_SNG_MTT_REFRESH,1)
	
	
    -- EventDispatcher.getInstance():dispatch(CommandEvent.s_event, CommandEvent.s_cmd.NEWKNOCKOUT_REFRESH);
    -- EventDispatcher.getInstance():dispatch(CommandEvent.s_event, CommandEvent.s_cmd.GET_SNG_MTT_REFRESH, 2);
end

function SngLobbyScene:showMark(data)
	local iMark = 0;
    if(data <= 5000000) then
        iMark = 1;
    elseif(data > 500000 and data < 2000000) then
        iMark = 2;
    elseif(data > 2000001 and data < 5000000) then
        iMark = 3;
    elseif(data > 5000001) then
        iMark = 4;
    end
    for i=1,#self.m_itemVector do
        local mark = g_NodeUtils:seekNodeByName(self.m_itemVector[i],"img_recommand");
        g_NodeUtils:seekNodeByName(mark,"label_recommand"):setString(GameString.get("str_sng_lobby_mark"));
        if(i == iMark) then
            mark:setVisible(true);
        else
            mark:setVisible(false);
        end
    end
end

function SngLobbyScene:updateTime()
    if not self.m_txCurTime then return end

    self.m_scheduleTask = g_Schedule:schedule(function()
	    self.m_txCurTime:setString(os.date("%H")..":".. os.date("%M")); 
	end,1,0, 1000)

end

function SngLobbyScene:onCleanup()
	ViewScene.onCleanup(self)
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]

end

function SngLobbyScene:watchMoney(data)
	self:updateUserData()
end

function SngLobbyScene:watchTicket()

end

function SngLobbyScene:currentMatchData(data)
	if g_TableLib.isEmpty(data) then
		return 
	end

	local tab = data.tab
	if tab == SngLobbyData.MATCH_SNG then
		self:updateItem(data.data)
	elseif tab == SngLobbyData.MATCH_NOT_FOUND then
		-- self.addTip(1)
	end
		
end

function SngLobbyScene:onItemChanged()
	local index = self.m_curTab
    local str = "";
    if index == 1 then
        self.m_player = SngLobbyScene.PLAYER_NUM1;
        str = GameString.get("str_sng_lobby_five_changed");
    else
        self.m_player = SngLobbyScene.PLAYER_NUM2;
        str = GameString.get("str_sng_lobby_nine_changed");
    end
    self.m_txTitleTips:setString(string.format(GameString.get("str_sng_lobby_tips"),tostring( self.m_player ))); 

--    self:showTips(str)
	self:hideItems();
	self:updateItem(self.m_sngListData)
    -- local self.m_curShowedNum  = self:reShowItem();
    -- if(self.m_curShowedNum  <= 0) then
    --     self:addTip(2);
    -- else
    --     self:removeTip();
    -- end
end

function SngLobbyScene:updateNine()
	if self:hasNineTable() then
		self.m_viewTab:setVisible(true)
	else
		self.m_viewTab:setVisible(false)
	end
end

function SngLobbyScene:updateItem(data)
	self.m_sngListData = data	
	self:updateNine()
	if not g_TableLib.isEmpty(self.m_sngListData) then
		local len = #self.m_sngListData
		for i = 1, len do
			local curItem = nil
			local curItemData = self.m_sngListData[i]
			if curItemData.m_tableNum == self.m_player then
				local getNum = 0
				if(curItemData.m_type > 4) then
                    getNum = curItemData.m_type - 4;
                else
                    getNum = curItemData.m_type;
                end
                if(getNum == 1) then
                    curItem = self.m_primaryItem;
                elseif(getNum == 2) then
                    curItem = self.m_middleItem;
                elseif(getNum == 3) then
                    curItem = self.m_highItem;
                elseif(getNum == 4) then
                    curItem = self.m_masterItem;
                end
                if(curItem ~= nil) then
                    curItem:setVisible(true);
                    self:updateItemInfo(curItem, curItemData);
                    self.m_curShowedNum  = self.m_curShowedNum  + 1;
				end
			end
		end
	end	
end

function SngLobbyScene:updateItemInfo(item,data)
	local node = item:getChildByTag(100)
	node:updateItemInfo(data)
	--[[item.m_data = data;
	local txFirstPrize = g_NodeUtils:seekNodeByName(item,"label1")
	local txSecondPrize = g_NodeUtils:seekNodeByName(item,"label2")
	local txSignFee = g_NodeUtils:seekNodeByName(item,"label3")
	local firstPrize = g_MoneyUtil.formatMoney(tonumber(data.m_detailedReward[1]))
	local secondPrize = g_MoneyUtil.formatMoney(tonumber(data.m_detailedReward[2]))
	local signFee = g_MoneyUtil.formatMoney(tonumber(data.m_applyCharge))
	local serviceFee = g_MoneyUtil.formatMoney(tonumber(data.m_serviceCharge))
	local signMoney = signFee.."+"..serviceFee
	txFirstPrize:setString(tostring(firstPrize))
	txSecondPrize:setString(tostring(secondPrize))
	txSignFee:setString(signMoney)]]
end

function SngLobbyScene:hideItems()
	for _,v in pairs(self.m_itemVector) do
        v:setVisible(false);
    end
end

function SngLobbyScene:showTips(str)
	g_AlarmTips.getInstance():setText(str):show()
end

function SngLobbyScene:hasNineTable()
	if not g_TableLib.isEmpty(self.m_sngListData) then
		local len = #self.m_sngListData
		for i = 1, len do
			local curItemData = self.m_sngListData[i]
			if curItemData.m_tableNum == 9 then
				return true
			end
		end
	end	
	return false
end

------------click func--------------
function SngLobbyScene:onBtnBackClick()
	cc.Director:getInstance():popScene();
end

function SngLobbyScene:onBtnFiveClick()
	if self.m_curTab == 1 then return end
	self.m_curTab = 1
	self.m_btnFive:setOpacity(255)
	self.m_btnNine:setOpacity(1)
	self:onItemChanged()
end

function SngLobbyScene:onBtnNineClick()
	if self.m_curTab == 2 then return end

	if self:hasNineTable() then

		self.m_curTab = 2
		self.m_btnFive:setOpacity(1)
		self.m_btnNine:setOpacity(255)
		self:onItemChanged()
	else
		g_AlertDialog.getInstance()
		:setTitle(GameString.get("str_sng_lobby_entry_tips_title"))
		:setContent(GameString.get("str_sng_lobby_no_nine_table"))
		:show()
	end
end

function SngLobbyScene:onBtnHelpClick(sender)
    g_PopupManager:show(g_PopupConfig.S_POPID.SNG_LOBBY_HELP_POP)
end

function SngLobbyScene:onSngItemClick(sender)
	local itemData = sender:getChildByTag(100):getData()-- m_data
	local port = itemData.m_port
	local userMoney = g_AccountInfo:getMoney()
	if userMoney < (itemData.m_applyCharge or 0 ) + (itemData.m_serviceCharge or 0 ) then
		g_AlertDialog.getInstance()
		-- :setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_sng_lobby_not_enough_money"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		:setRightBtnFunc(self.onBtnBuyChipClick)
		:setRightBtnTx(GameString.get("str_sng_lobby_buy_chips"))
		:setLeftBtnTx(GameString.get("str_sng_lobby_cancel"))
		:show()
	else
		g_AlertDialog.getInstance()
		:setTitle(GameString.get("str_sng_lobby_entry_tips_title"))
        :setContent(GameString.get("str_sng_lobby_rule_tips"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		:setRightBtnFunc(function()
			local params = {}
			params.playNow = false
			-- params.enterFrom = RequestLoginData.SNG_HALL 
			-- params.sceneNavEvent = SceneNavEvent.s_cmd.SNG_HALL_2_ROOM
			params.roomInfo = itemData
			params.roomInfo.tid = 0
			self:doLogic(g_SceneEvent.SNG_LOGIN_TO_ROOM,params)
		end)
		:setRightBtnTx(GameString.get("str_sng_lobby_confirm"))
		:setLeftBtnTx(GameString.get("str_sng_lobby_cancel"))
		:show()
	end
end

function SngLobbyScene:onBtnBuyChipClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_CHIPS_PAGE)
end	


------------click func end----------

return SngLobbyScene;