--[[--ldoc desc
@module SNGRoomResultPop
@author %s

Date   %s
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SNGRoomResultPop = class("SNGRoomResultPop",PopupBase);
BehaviorExtend(SNGRoomResultPop);

-- 配置事件监听函数
SNGRoomResultPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function SNGRoomResultPop:ctor()
	PopupBase.ctor(self);
    self:bindCtr(require("SNGRoomResultCtr"))
    self:loadLayout("creator/sngRoom/sngResultPop.ccreator");
	self:init()
end

function SNGRoomResultPop:show(rank)
    self.m_txRankTips:setString(string.format(GameString.get("str_sng_result_rank"),tostring(rank)))
	PopupBase.show(self)
end

function SNGRoomResultPop:hidden()
	PopupBase.hidden(self)
end

function SNGRoomResultPop:init()
    PopupBase:setClickShadeClose(false)

    self.m_btnClose = g_NodeUtils:seekNodeByName(self,"btn_close")
    self.m_txTitle = g_NodeUtils:seekNodeByName(self,"label_title")
    self.m_txRankTips = g_NodeUtils:seekNodeByName(self,"label_rank")
    self.m_txResultTips = g_NodeUtils:seekNodeByName(self,"label_result_tips")
    self.m_btnBack = g_NodeUtils:seekNodeByName(self,"btn_back")
    self.m_txBack = g_NodeUtils:seekNodeByName(self,"label_back")
    self.m_btnPlayAgain = g_NodeUtils:seekNodeByName(self,"btn_play_again")
    self.m_txPlayAgain = g_NodeUtils:seekNodeByName(self,"label_play_again")

    self.m_txTitle:setString(GameString.get("str_sng_result_title"))
    self.m_txResultTips:setString(GameString.get("str_sng_result_pop_result_tips"))
    self.m_txBack:setString(GameString.get("str_sng_reward_pop_back"))
    self.m_txPlayAgain:setString(GameString.get("str_sng_reward_pop_play_again"))

    self:addClickListener()    
end

function SNGRoomResultPop:addClickListener()
    self.m_btnClose:addClickEventListener(handler(self,self.onBtnCloseClick))
    self.m_btnBack:addClickEventListener(handler(self,self.onBtnBackClick))
    self.m_btnPlayAgain:addClickEventListener(handler(self,self.onBtnPlayAgainClick))
end

---------------click func-----------------
function SNGRoomResultPop:onBtnCloseClick()
    g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SNG_RESULT_POP_CLOSE)
    self:hidden()
end

function SNGRoomResultPop:onBtnBackClick()
    g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SNG_END_BACK_TO_LOBBY)
end

function SNGRoomResultPop:onBtnPlayAgainClick()
    g_EventDispatcher:dispatch(g_SceneEvent.ROOM_SNG_END_PLAY_AGAIN)
    self:hidden()
end

------------------------------------------

function SNGRoomResultPop:onCleanup()
	PopupBase.onCleanup(self)
end


return SNGRoomResultPop;