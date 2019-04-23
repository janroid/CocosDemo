--[[--ldoc desc
@module NoviceRewardCtr
@author ReneYang
Date   2019-1-22
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local NoviceRewardCtr = class("NoviceRewardCtr",PopupCtr);
BehaviorExtend(NoviceRewardCtr);

---配置事件监听函数
NoviceRewardCtr.s_eventFuncMap =  {
	[g_SceneEvent.NOVICE_REWARD_RECEIVE] = "receiveReward";
}

function NoviceRewardCtr:ctor()
	PopupCtr.ctor(self);
end

function NoviceRewardCtr:show()
	PopupCtr.show(self)
	self:requestData()
end

function NoviceRewardCtr:requestData()
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.REGISTER_REWARD)
    g_HttpManager:doPost(param, self, self.callBackFunc);
end
function NoviceRewardCtr:callBackFunc(isSuccess, data)
	if not g_TableLib.isEmpty(data) then
		if tonumber(data.ret) == 0 then
			local formatData = {}
			for i=1,3 do
				table.insert(formatData, data[tostring(i)])
			end
			self:updateView(g_SceneEvent.NOVICE_REWARD_REFRESH, formatData)
		end
	end
end

-- 领奖
function NoviceRewardCtr:receiveReward(x, y)

	local param = HttpCmd:getMethod(HttpCmd.s_cmds.REGISTER_REWARD_RECEIVE)
    g_HttpManager:doPost(param, self, self.onReceiveReward);
end
function NoviceRewardCtr:onReceiveReward(isSuccess, data)
	Log.d("NoviceRewardCtr.onReceiveReward", isSuccess, data)
	if data and data.ret then
		if data.ret == 2 then
			self:updateView(g_SceneEvent.NOVICE_REWARD_RECEIVE_SUCCESS)
			local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_MAIN)
			g_HttpManager:doPost(params,self,function (self, isSuccess, data)
				if isSuccess and tonumber(data.money) then
					g_AccountInfo:setMoney(data.money)
				end
			end)
			return
		end
	end
	g_PopupManager:hidden(g_PopupConfig.S_POPID.NOVICE_REWARD_POP)
end
return NoviceRewardCtr;