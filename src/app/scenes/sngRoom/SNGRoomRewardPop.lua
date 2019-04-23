--[[--ldoc desc
@module SNGRoomRewardPop
@author %s

Date   %s
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local SNGRoomRewardPop = class("SNGRoomRewardPop",PopupBase);
BehaviorExtend(SNGRoomRewardPop);

-- 配置事件监听函数
SNGRoomRewardPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

SNGRoomRewardPop.RANK_TITLE = "creator/sngRoom/imgs/img_title_"

function SNGRoomRewardPop:ctor()
	PopupBase.ctor(self);
    self:bindCtr(require("SNGRoomRewardCtr"))
    self:loadLayout("creator/sngRoom/sngRewardPop.ccreator");
    self.m_data = nil
    self:init()
    self:addClickLisenter()
end

function SNGRoomRewardPop:show(data)
    self.m_data = data
    local rank = data.ranking
    local rankTitle = SNGRoomRewardPop.RANK_TITLE..rank..".png"
    self.m_imgRankTitle:setTexture(rankTitle)
    local userIcon = g_AccountInfo:getSmallPic()
	local size = self.m_imgHeadIcon:getContentSize()
	local border = 4
	local clipPath = "creator/hall/header_bg.png"
    self.m_imgHeadIcon:setHeadIcon(userIcon, size.width - border, size.height - border, clipPath)
    local userName = g_AccountInfo:getNickName()
    self.m_txUserName:setString(string.format(GameString.get("str_sng_reward_pop_username"),userName))
    local rankStr =string.format(GameString.get("str_sng_reward_pop_reward_tips"),tostring(data.ranking ))
    self.m_txRewardTips:setString(rankStr)
    self.m_txRewardNum:setString(tostring(g_MoneyUtil.skipMoney(data.chip)))
    self:setClickShadeClose(false)
	PopupBase.show(self)
end

function SNGRoomRewardPop:hidden()
	PopupBase.hidden(self)
end

function SNGRoomRewardPop:init()
    self.m_imgRankTitle = g_NodeUtils:seekNodeByName(self,"img_rank")
    self.m_imgHeadIcon = g_NodeUtils:seekNodeByName(self,"img_head_icon")
    self.m_txUserName = g_NodeUtils:seekNodeByName(self,"label_user_name")
    self.m_txRewardTips = g_NodeUtils:seekNodeByName(self,"label_reward_tips")
    self.m_viewReward = g_NodeUtils:seekNodeByName(self,"view_reward")
    self.m_txRewardNum = g_NodeUtils:seekNodeByName(self,"lable_chip_num")
    self.m_btnBack = g_NodeUtils:seekNodeByName(self,"btn_back")
    self.m_txBack = g_NodeUtils:seekNodeByName(self,"label_back")
    self.m_btnShare = g_NodeUtils:seekNodeByName(self,"btn_share")
    self.m_txShare = g_NodeUtils:seekNodeByName(self,"label_share")

    self.m_txBack:setString(GameString.get("str_sng_reward_pop_back"))
    self.m_txShare:setString(GameString.get("str_sng_reward_pop_share"))

    g_NodeUtils:convertTTFToSystemFont(self.m_txUserName)
    BehaviorExtend(self.m_imgHeadIcon)
	self.m_imgHeadIcon:bindBehavior(BehaviorMap.HeadIconBehavior)
end

function SNGRoomRewardPop:addClickLisenter()
    self.m_btnBack:addClickEventListener(function()
        self:onBtnBackClick()
    end)
    self.m_btnShare:addClickEventListener(function()
        self:onBtnShareClick()
    end)
end

--sng reward data =  : 
-- {"score":3,
-- "exp":0,
-- "propsId":-1,
-- "email":"",
-- "coalaa":0,
-- "isKnockOut":false,
-- "hasGoods":false,
-- "reward":"",
-- "chip":90000,
-- "ranking":1} 

function SNGRoomRewardPop:onCleanup()
	PopupBase.onCleanup(self)
end
-----------click func ----------------
function SNGRoomRewardPop:onBtnBackClick()
   -- local s = cc.Director:getInstance():getRunningScene()
    if g_RoomInfo.m_isSngMatchEnd and not g_RoomInfo.m_isSngSwitchRoom then
        g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SNG_END_BACK_TO_LOBBY)
    end
    self:hidden()
end

function SNGRoomRewardPop:onBtnShareClick()
    if g_AccountInfo:getLoginFrom() ~= g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_other_account'))
        return
    end
    local param = g_TableLib.copyTab(GameString.get('str_social_config').matchHall)
    param.message = g_StringLib.substitute(param.message,self.m_data.ranking,self.m_data.chip)
    param.link = g_AppManager:getFBAppLink()
	NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_SHARE_FACEBOOK, param, self, self.onShareComplete)
end

function SNGRoomRewardPop:onShareComplete(response)
	if response and tonumber(response.result) == 1 then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_success'))
        g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_SHARE_SUCCESS)
	elseif tonumber(response.result) == 3 then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_cancel'))
	else
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_failed'))
	end
end

--------------------------------------

return SNGRoomRewardPop;