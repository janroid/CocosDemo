--[[--ldoc desc
@module TutorialRewardCtr
@author ReneYang
Date   2019-1-22
]]
local HttpCmd = import("app.config.config").HttpCmd
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TutorialRewardCtr = class("TutorialRewardCtr",PopupCtr);
BehaviorExtend(TutorialRewardCtr);

---配置事件监听函数
TutorialRewardCtr.s_eventFuncMap =  {
	[g_SceneEvent.BEGINNER_TUTORIAL_REWARD] = "requestReward";
	
	
}

function TutorialRewardCtr:ctor()
	PopupCtr.ctor(self);
	self.m_postCounts			= 2;
end

function TutorialRewardCtr:requestReward()
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.TUTORIAL_REWARD)
    g_HttpManager:doPost(param, self, self.callBackFunc);
end

function TutorialRewardCtr:callBackFunc(isSuccess, data)
	Log.d("callBackFunc",isSuccess, data)
    data = tonumber(data);
	if data ~= nil then
		if data == 1 then --领取成功
			g_Model:setData(g_ModelCmd.USER_RECEIVED_TUTORIAL_REWARD,true);
			--g_AlarmTips.getInstance():setText(GameString.get("str_beginner_tutorial_reveive_reward_seccuess")):show()
			self:exit(true)
		
		elseif data < 0 and self.m_postCounts > 0 then
			self.m_postCounts = self.m_postCounts - 1;
			local param = HttpCmd:getMethod(HttpCmd.s_cmds.TUTORIAL_REWARD)
			g_HttpManager:doPost(param, self, self.callBackFunc);
		
		else
			if isSuccess then
				local tutorialObj,flag = g_JsonUtil.decode(g_AccountInfo:getNewCourse());
				if flag and g_TableLib.isTable(tutorialObj) then
					if tutorialObj.bit == 0 then
						g_Model:setData(g_ModelCmd.USER_RECEIVED_TUTORIAL_REWARD,true);
					end
				end
			end
			--退出新手教程
			self:exit()
		end
	else
		g_AlarmTips.getInstance():setText(GameString.get("str_beginner_tutorial_reveive_reward_fail")):show()
	end
end

function TutorialRewardCtr:exit(isSuccess)
	g_EventDispatcher:dispatch(g_SceneEvent.BEGINNER_TUTORIAL_EXIT, isSuccess)
end

return TutorialRewardCtr;