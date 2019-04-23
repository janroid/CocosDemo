--[[--ldoc desc
@module PlayInfoCtr
@author ReneYang
Date   2018-12-4
]]

local HttpCmd = import("app.config.config").HttpCmd
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local PlayInfoCtr = class("PlayInfoCtr",PopupCtr);
BehaviorExtend(PlayInfoCtr);

---配置事件监听函数
PlayInfoCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
	[g_SceneEvent.RANKPOP_GET_USER_INFO] = "getUserInfo",
}

function PlayInfoCtr:ctor()
	PopupCtr.ctor(self);
end


function PlayInfoCtr:getUserInfo(uid,isInRoom)
	Log.d("PlayInfoCtr:getUserInfo")
	if not isInRoom then
		g_Progress.getInstance():show():setBgClickEnable(false)
	end
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_OTHER_MAIN)-- USER_MAIN
	params.puid = uid
	g_HttpManager:doPost(params,self,self.onUserInfoResp)
end
function PlayInfoCtr:onUserInfoResp(isSuccess, result, params)
	Log.d("PlayInfoCtr:onUserInfoResp",isSuccess,result)
	g_Progress.getInstance():dismiss()
	if isSuccess and not g_TableLib.isEmpty(result) then
		result.uid = params.puid
		g_EventDispatcher:dispatch(g_SceneEvent.RANKPOP_GET_USER_INFO_RESPONSE,result)
	end
end

function PlayInfoCtr:show()
	PopupCtr.show(self)
end

function PlayInfoCtr:hidden()
	PopupCtr.hidden(self)
end

function PlayInfoCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end



return PlayInfoCtr;