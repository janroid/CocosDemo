--[[--ldoc desc
@module DailyTaskCtr
@author %s
Date   %s
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local DailyTaskCtr = class("DailyTaskCtr",PopupCtr);
local DailyTaskManager = require("DailyTaskManager")

local TaskVO = require("TaskVO")
BehaviorExtend(DailyTaskCtr);

---配置事件监听函数
DailyTaskCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数
	[g_SceneEvent.DAILYTASK_EVENT_REQUEST_DATA] = "requestDailyTaskList";
	-- [g_SceneEvent.DAILYTASK_EVENT_GET_REWARD] = "requestGetReward";
}

function DailyTaskCtr:ctor()
	PopupCtr.ctor(self);
end

function DailyTaskCtr:show()
	PopupCtr.show(self)
	-- 在show方法开始监听
	self:registerEvent()
	DailyTaskManager.getInstance()
end

function DailyTaskCtr:requestDailyTaskList()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.DAILY_TASK_INFO)
    g_HttpManager:doPost(params, self, self.onDailyTaskListResponse)
end


function DailyTaskCtr:onDailyTaskListResponse(isSuccess,data)
	Log.d("DailyTaskCtr taskList isSuccess data = ",isSuccess,data)
	if g_TableLib.isTable(data) then
		DailyTaskManager.getInstance():onDailyTaskListResponse(isSuccess,data)
		g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_REQUEST_DATA_SUCCESS);
	end
		
end

function DailyTaskCtr:requestGetReward(data)

end

function DailyTaskCtr:hidden()
	PopupCtr.hidden(self)
	-- 在hidden方法区取消监听
	self:unRegisterEvent()
end

function DailyTaskCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end



return DailyTaskCtr;