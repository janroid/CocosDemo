--[[--ldoc desc
@module OtherInfoCtr
@author MenuZhang
Date   2018-10-25
]]
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local OtherInfoCtr = class("OtherInfoCtr",PopupCtr);
BehaviorExtend(OtherInfoCtr);

---配置事件监听函数
OtherInfoCtr.s_eventFuncMap =  {
	
	-- [g_SceneEvent.USERINFOPOP_SEND_PROP] = "startHddj",
}

function OtherInfoCtr:ctor()
	PopupCtr.ctor(self);
end


function OtherInfoCtr:onCleanup()
	PopupCtr.onCleanup(self);
end

function OtherInfoCtr:getUserInfo(uid)
    Log.d("OtherInfoCtr:getUserInfo")
	-- g_Progress.getInstance():show():setBgClickEnable(false)
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_OTHER_MAIN)
	params.puid = uid
	g_HttpManager:doPost(params,self,self.onUserInfoResp)
end

function OtherInfoCtr:onUserInfoResp(isSuccess, result, params)
    -- g_Progress.getInstance():dismiss()
	Log.d("OtherInfoCtr:onUserInfoResp",isSuccess,result)
	if isSuccess and not g_TableLib.isEmpty(result) then
		result.uid = params.puid
		self:updateView(g_SceneEvent.RANKPOP_GET_USER_INFO_RESPONSE1,result)
		-- g_EventDispatcher:dispatch(g_SceneEvent.RANKPOP_GET_USER_INFO_RESPONSE1,result)
	else
		--self:updateView(g_SceneEvent.RANKPOP_GET_USER_INFO_RESPONSE1,result)
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_bad_network"))
	end
end

return OtherInfoCtr