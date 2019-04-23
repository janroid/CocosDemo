--[[--ldoc desc
@module UserInfoPop
@author CloudKe

Date   2018-10-30
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local BehaviorMap = import("app.common.behavior").BehaviorMap
local UserInfoPop = class("UserInfoPop",PopupBase);
local NetImageView = import("app.common.customUI").NetImageView
BehaviorExtend(UserInfoPop);

function UserInfoPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".UserInfoCtr"));
	self:init();
end

UserInfoPop.s_eventFuncMap = {
	[g_SceneEvent.UPDATE_USER_HEAD_ICON] = "updateUserInfo";
	[g_SceneEvent.REQUEST_USER_INFO_SUCCESS] = "updateUserInfo";
	[g_SceneEvent.UPDATE_USER_DATA] = "updateUserInfo";
}

function UserInfoPop:onCleanup()
	PopupBase.onCleanup(self);
end

function UserInfoPop:init()
	self:loadLayout('creator/userInfo/userInfo.ccreator')

	self:initScene()
	self:initListener()
	self:initString()
	self:initHeadIcon()
	self:initBestCard()
end

function UserInfoPop:show()
	PopupBase.show(self)
	self:updateUserInfo()
	self:requestUserInfo()
end

function UserInfoPop:requestUserInfo()
	g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_INFO)
end

function UserInfoPop:initScene()
	-- body
	self.m_setHeadBtn = g_NodeUtils:seekNodeByName(self,"btn_set_head")
	self.m_bankBtn = g_NodeUtils:seekNodeByName(self,"bankBtn")
	self.m_whatBtn = g_NodeUtils:seekNodeByName(self,"whatBtn")
	self.m_btnClose = g_NodeUtils:seekNodeByName(self,"close")
	self.m_headIcon = g_NodeUtils:seekNodeByName(self,"head_icon")
	self.m_headIconBG = g_NodeUtils:seekNodeByName(self,"head_icon_bg")
	self.m_userNameTxt = g_NodeUtils:seekNodeByName(self,"user_name_txt")
	self.m_chipsTxt = g_NodeUtils:seekNodeByName(self,"chip_tx")
	self.m_uidTxt = g_NodeUtils:seekNodeByName(self,"uid_txt")
	self.m_vipIcon = g_NodeUtils:seekNodeByName(self,"vip_icon")
	self.m_coinTxt = g_NodeUtils:seekNodeByName(self,"coin_txt")
	self.m_lvTxt = g_NodeUtils:seekNodeByName(self,"lv_txt")
	self.m_matchesTxt = g_NodeUtils:seekNodeByName(self,"matches_txt")
	self.m_expText = g_NodeUtils:seekNodeByName(self,"exp_txt")
	self.m_expProgress = g_NodeUtils:seekNodeByName(self,"exp_progress")

	self.m_winRateTitle = g_NodeUtils:seekNodeByName(self,"win_rate_title")
	self.m_winRateTxt = g_NodeUtils:seekNodeByName(self,"win_rate_txt")
	self.m_maxWinTitle = g_NodeUtils:seekNodeByName(self,"max_win_title")
	self.m_maxWinTxt = g_NodeUtils:seekNodeByName(self,"max_win_txt")
	self.m_highestAssetTitle = g_NodeUtils:seekNodeByName(self,"highest_asset_title")
	self.m_highestAssetTxt = g_NodeUtils:seekNodeByName(self,"highest_asset_txt")

	self.m_bestHandCardTxt = g_NodeUtils:seekNodeByName(self,"best_hand_card_txt")
	self.m_noBestHandCard = g_NodeUtils:seekNodeByName(self,"no_best_hand_card")
	self.m_achieveTxt = g_NodeUtils:seekNodeByName(self,"achieve_txt")
	self.m_noAchievementTxt = g_NodeUtils:seekNodeByName(self,"no_achievement_txt")

	self.m_bestCardContainer = g_NodeUtils:seekNodeByName(self,"best_card_container")
	self.m_gloryContainer = g_NodeUtils:seekNodeByName(self,"glory_container")
	self.m_moreBtn = g_NodeUtils:seekNodeByName(self,"moreBtn")
	self.m_uidLayout = g_NodeUtils:seekNodeByName(self,"uidLayout")
	
	g_NodeUtils:convertTTFToSystemFont(self.m_userNameTxt)

	if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
		self.m_setHeadBtn:setVisible(false)
		self.m_headIconBG:setEnabled(false)
	end
end

function UserInfoPop:initListener()
	self.m_bankBtn:addClickEventListener(function (sender)
		self:onBankBtnClick()
	end)
	self.m_whatBtn:addClickEventListener(function (sender)
		self:onWhatBtnClick()
	end)
	self.m_btnClose:addClickEventListener(function (sender)
		self:hidden()
	end)
	self.m_setHeadBtn:addClickEventListener(function (sender)
		self:onSetHeadBtnClick()
	end)
	self.m_moreBtn:addClickEventListener(function (sender)
		self:onMoreBtnClick()
	end)
	self.m_headIconBG:addClickEventListener(function (sender)
		self:onSetHeadBtnClick()
	end)
end

function UserInfoPop:initString()
	self.m_winRateTitle:setString(GameString.get("str_userinfo_win_rate"))
	self.m_maxWinTitle:setString(GameString.get("str_userinfo_max_win"))
	self.m_highestAssetTitle:setString(GameString.get("str_userinfo_highest_asset"))
	self.m_noBestHandCard:setString(GameString.get("str_userinfo_no_best_hand_card"))
	self.m_achieveTxt:setString(GameString.get("str_userinfo_achievement"))
	self.m_noAchievementTxt:setString(GameString.get("str_userinfo_no_achievement"))
	self.m_bestHandCardTxt:setString(GameString.get("str_userinfo_best_hand_card"))
end

function UserInfoPop:initHeadIcon()
	BehaviorExtend(self.m_headIcon)
	self.m_headIcon:bindBehavior(BehaviorMap.HeadIconBehavior)
end

function UserInfoPop:initBestCard()	
	local containerSize = self.m_bestCardContainer:getContentSize()
	self.m_cards = {};
	local scale = 0.6
	local card = nil;
	local x = 2
    for i = 1, 5 do
        card = g_PokerCard:create()
		card:setScale(scale);
		local size = card:getContentSize()
		self.m_bestCardContainer:addChild(card)
		local remainWidth = containerSize.width - size.width*scale*5 - x*4
		-- g_NodeUtils:arrangeToCenter(card)
		card:setPosition(cc.p(remainWidth/2+size.width*scale/2+(i-1)*(size.width*scale+x),containerSize.height/2))
		table.insert(self.m_cards, card);
	end
	self.m_bestCardContainer:setVisible(false)
end

function UserInfoPop:initGlory(data)
	-- Log.d(" UserInfoPop:initGlory data = ",data)
	self.m_gloryContainer:removeAllChildren(true)
	local x = 60
	local containerSize = self.m_gloryContainer:getContentSize()
	local len = #data
	if len >=3 then 
		len = 3
		x = 60
	elseif len ==2 then
		x = 120
	end
	-- len = 1
	for i = 1, len do
		local item = data[i]
		local id = item.id
		local gloryItemInfo = self:getGlory(id)
		local gloryItemImg= cc.Sprite:create("creator/userInfo/glory/glory_" .. id .. ".png")
		local gloryItemTxt = cc.Label:createWithSystemFont(gloryItemInfo.b,  "fonts/arial.ttf", 16)
		gloryItemTxt:setTextColor(cc.c3b(130, 145, 155))
		gloryItemImg:addChild(gloryItemTxt)
		gloryItemImg:setContentSize(cc.size(68,68))
		g_NodeUtils:arrangeToBottomCenter(gloryItemTxt)
		local posx ,posy = gloryItemTxt:getPosition()
		gloryItemTxt:setPosition(cc.p(posx,posy-20))
		self.m_gloryContainer:addChild(gloryItemImg)
		g_NodeUtils:arrangeToCenter(gloryItemImg)
		local itemSize = gloryItemImg:getContentSize()
		gloryItemImg:setPositionX(x)
		x = itemSize.width + 60 +x
		if len == 1 then
			g_NodeUtils:arrangeToCenter(gloryItemImg)
		end
	end
end

function UserInfoPop:updateExperience(experience)
	local exp = g_ExpUtils.getLevelProgressLabel(tonumber(experience))
	-- Log.d("Johnson exp = ",exp,experience)
	self.m_expProgress:setPercent(g_ExpUtils.getLevelProgressPercent(tonumber(experience)))
	self.m_expText:setString(exp);
end

---刷新界面
function UserInfoPop:updateView(data)
	data = checktable(data);
end

function UserInfoPop:onBankBtnClick()
	Log.d("Johnson ,"," UserInfoPop:onBankBtnClick")
	if g_AccountInfo:getIsSetBankPassword() then
		g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_PASSWORD_POP)
	else
		g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_POP)
	end
end

function UserInfoPop:onSetHeadBtnClick( )
	g_PopupManager:show(g_PopupConfig.S_POPID.SET_HEAD_POP)
end

function UserInfoPop:onWhatBtnClick( )
	local helpType = import('app.scenes.help').ShowType
g_PopupManager:show(g_PopupConfig.S_POPID.HELP_POP,helpType.showTypeHall,nil,3,2)
end

function UserInfoPop:onMoreBtnClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.ACHIEVEMENT_POP)
end

function UserInfoPop:updateUserInfo(data)
	-- Log.d(" UserInfoPop:updateUserInfo ",data)
	if data and not g_TableLib.isEmpty(data) then
		local achieve = data.achi
		-- Log.d("Johnson achieve ",achieve)
		if not g_TableLib.isEmpty(achieve) then
			self:initGlory(achieve)
			self.m_noAchievementTxt:setVisible(false)
		else
			self.m_noAchievementTxt:setVisible(true)
		end
		if tonumber(data.win) and tonumber(data.lose) then
			local total = data.win + data.lose
			if total > 0 then
				g_AccountInfo:setWinRate(data.win / total)
			end
		end
		if tonumber(data.money) then
			g_AccountInfo:setMoney(data.money)
		end
	end
	
	self:updateUserIcon()
	self.m_highestAssetTxt:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMaxMoney()))
	local winRate = string.format("%.2f", g_AccountInfo:getWinRate()*100)
	self.m_winRateTxt:setString(string.format("%s%%",winRate))
	self.m_maxWinTxt:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMaxAward()))
	local userNameSize = self.m_userNameTxt:getContentSize()
	self.m_userNameTxt:setString(g_StringLib.limitLength(g_AccountInfo:getNickName(),24,userNameSize.width))
	self.m_chipsTxt:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getMoney()))
	self.m_uidTxt:setString(g_AccountInfo:getId())
	self.m_coinTxt:setString(g_MoneyUtil.skipMoney(g_AccountInfo:getUserCoalaa()))
	self.m_lvTxt:setString(g_AccountInfo:getUserLevel())
	self.m_matchesTxt:setString( g_ExpUtils.getTitleByExp(tonumber(g_AccountInfo:getUserExp())))
	self:updateExperience(g_AccountInfo:getUserExp())

	self.m_whatBtn:setPositionX(self.m_matchesTxt:getContentSize().width+6)
	self:updateBestCard()
	local vip = g_AccountInfo:getVip() 
	if tonumber(vip) >0 and tonumber(vip) <5 then
		self.m_vipIcon:setTexture(string.format("creator/common/vip/vip_icon_%s.png",vip))
		self.m_vipIcon:setVisible(true)
	else
		self.m_vipIcon:setVisible(false)
	end
	self.m_uidLayout:requestDoLayout()
end

function UserInfoPop:updateUserIcon()
	local headIconPic = g_AccountInfo:getSmallPic()
	self.m_headIcon:setHeadIcon(headIconPic)
end

function UserInfoPop:updateBestCard()
	local bestCard = g_AccountInfo:getBestPoker()
	if bestCard ~= nil and string.len(bestCard) == 11 then
        local pokerValue = string.sub(bestCard, 2);
        for i = 1, 5 do
            local idx = 2 * (i - 1) + 1;
            local cardValue = tonumber("0x0" .. string.sub(pokerValue,idx, idx) .. "0" .. string.sub(pokerValue,idx + 1, idx + 1));
			self.m_cards[i]:setCard(cardValue);
		end
		self.m_noBestHandCard:setVisible(false)
		self.m_bestCardContainer:setVisible(true)
	else
		self.m_noBestHandCard:setVisible(true)
		self.m_bestCardContainer:setVisible(false)
	end
end

function UserInfoPop:getGlory(id)
	local config = g_Model:getData(g_ModelCmd.DATA_ACHIEVE_INFO)
	local ret = {};
	if not config or g_TableLib.isEmpty(config) then
		return ret;
	end
	local achieveConfig = config:getConfig()
    if id ~= nil then
        for i = 1, #achieveConfig do
            local item = achieveConfig[i];
            if tostring(item.a) == tostring(id) then
                ret = item;
                break;
            end
        end
    end
    return ret;
end

return UserInfoPop;