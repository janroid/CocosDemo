--[[--ldoc desc
@module StoreCtr
@author JohnsonZhang
Date   2018-11-7
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local StoreCtr = class("StoreCtr",ViewCtr);
BehaviorExtend(StoreCtr);

---配置事件监听函数
StoreCtr.s_eventFuncMap =  {
	[g_SceneEvent.STORE_REQ_USER_MONEY] 			= "requestUserInfo",
}

function StoreCtr:ctor(delegate)
	ViewCtr.ctor(self,delegate);
end

function StoreCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

function StoreCtr:requestUserInfo()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_MAIN)
	g_HttpManager:doPost(params,self,self.onUserInfoCallBack)
end

function StoreCtr:onUserInfoCallBack(isSuccess, data)
	if isSuccess and next(data) ~= nil then
		if data and not g_TableLib.isEmpty(data) then
			if tonumber(data.money) then
				g_AccountInfo:setMoney(data.money)
			end
		end
    else
        Log.e("StoreCtr:onUserInfoCallBack", "decode json has an error occurred!");
    end
end

return StoreCtr;