--[[--ldoc desc
@module TutorialCtr
@author ReneYang
Date   2019-1-4
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TutorialCtr = class("TutorialCtr",ViewCtr);
BehaviorExtend(TutorialCtr);

---配置事件监听函数
TutorialCtr.s_eventFuncMap =  {
	[g_SceneEvent.BEGINNER_TUTORIAL_DO_PRIVIOUS] 	= "doPriviousStep";
	[g_SceneEvent.BEGINNER_TUTORIAL_DO_NEXT] 		= "doNextStep";
	[g_SceneEvent.BEGINNER_TUTORIAL_COMPLETE_LEARNING] 	= "onCompleteLearing";
	[g_SceneEvent.BEGINNER_TUTORIAL_EXIT] = "exit";
}

function TutorialCtr:ctor()
	ViewCtr.ctor(self);
	local dealerList = g_Model:getData(g_ModelCmd.DEALER_LIST)
	if dealerList == nil then
		self.m_retryTimes = 3
		local params = HttpCmd:getMethod(HttpCmd.s_cmds.DEALER_GET_INFO)
		g_HttpManager:doPost(params,self, self.onGetDealerInfoResponse, self.getDealerInfoError)
	end
end
function TutorialCtr:onGetDealerInfoResponse(isSuccess, result)
    if isSuccess == true and result then
    	self.m_retryTimes = 3
        g_Model:setData(g_ModelCmd.DEALER_LIST, result)
    elseif (self.m_retryTimes >= 0) then
        self:getDealerInfoError();
    end
end

function TutorialCtr:getDealerInfoError()
    if self.m_retryTimes > 0 then
		local params = HttpCmd:getMethod(HttpCmd.s_cmds.DEALER_GET_INFO)
        g_HttpManager:doPost(param, self, self.onGetDealerInfoResponse, self.getDealerInfoError);
        self.m_retryTimes = self.m_retryTimes - 1;
    else
    	g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_login_bad_network'))
    end
end

function TutorialCtr:onEnterTransitionFinish()
	self.curStep = 1
	self:processOperate()
end

function TutorialCtr:processOperate()
	self:updateView(g_SceneEvent.BEGINNER_TUTORIAL_OPERATIONAL, self.curStep)
end

function TutorialCtr:doPriviousStep()
	self.curStep = self.curStep - 1
	self:processOperate()
end
function TutorialCtr:doNextStep()
	self.curStep = self.curStep + 1
	self:processOperate()
end


function TutorialCtr:onCompleteLearing()
    if g_AccountInfo:getNewCourse() ~= nil then
        local tutorialObj,flag = g_JsonUtil.decode(g_AccountInfo:getNewCourse());
		if flag and g_TableLib.isTable(tutorialObj) then
			Log.d("TutorialCtr:onCompleteLearing()",(tutorialObj.bit == 0))
            if tutorialObj.bit == 0 and not g_Model:getData(g_ModelCmd.USER_RECEIVED_TUTORIAL_REWARD) then
				g_PopupManager:show(g_PopupConfig.S_POPID.TUTORIAL_REWARD_POP,2)
            else
				self:exit()
            end
        else
            Log.e(self.TAG, "onCompleteLearing", "decode json has an error occurred!");
        end
    else
        self:exit()
    end
end


function TutorialCtr:exit()
	-- local hallscene = import('app/scenes/hallScene').scene
	g_Model:setData(g_ModelCmd.DATA_HALL_SCENE_FROM, 2);
    cc.Director:getInstance():popScene()
end

return TutorialCtr;