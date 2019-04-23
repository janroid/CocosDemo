--[[
author: 文件名
time: 创建时间
Description: 功能描述
]]
local PopupBase = import("app.common.popup").PopupBase;
local DailyTaskPop = class('DailyTaskPop',PopupBase);
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local DailyTaskItem = require("DailyTaskItem")
local TaskVO = require("TaskVO")
local DailyTaskAnim  = import("app.common.animation").RewardAnim
BehaviorExtend(DailyTaskPop);

function DailyTaskPop:ctor()
    Log.d("Patric DailyTaskPop ")
    PopupBase.ctor(self);
	self:bindCtr(require("DailyTaskCtr"))
    self:bindBehavior(BehaviorMap.DownloadBehavior);
    self.m_dailyTaskData= {}
	self:init()
end

DailyTaskPop.s_eventFuncMap =  {
    [g_SceneEvent.DAILYTASK_EVENT_REQUEST_DATA_SUCCESS]       = "onRequestDailyTaskDataSuccess";
    [g_SceneEvent.DAILYTASK_EVENT_GET_REWARD_SUCCESS]         = "onGetRewardSuccess";
};


function DailyTaskPop:show()
    PopupBase.show(self)
    self:watchDataList()
    self:requestDailyTaskData()
end

function DailyTaskPop:onCleanup()
    PopupBase.onCleanup(self)
    self:unwatchDataList()
end

function DailyTaskPop:watchDataList()
    if self.m_watchDataList == nil then
        self.m_watchDataList = {
            {g_ModelCmd.ALL_TASK_LIST,  self,  self.updateDailyTaskList,    true};
            {g_ModelCmd.TASK_SPECIAL,   self,  self.updateSpecialTask, true};
        }
    end
    g_Model:watchDataList(self.m_watchDataList);
end

function DailyTaskPop:unwatchDataList()
    if self.m_watchDataList ~= nil then
        g_Model:unwatchDataList(self.m_watchDataList);
    end
end

function DailyTaskPop:init()
    self:loadLayout("creator/dailyTask/dailyTask.ccreator");
    self.m_titleImg =  g_NodeUtils:seekNodeByName(self,'imgTitle') 
    self.m_btnClose = g_NodeUtils:seekNodeByName(self, 'btnClose')
    self.m_specialContainer = g_NodeUtils:seekNodeByName(self,'specialTaskContainer')
    self.m_taskListContainer = g_NodeUtils:seekNodeByName(self,'taskList')    
    
    self.m_titleImg:setTexture(switchFilePath("dailyTask/imgs/daily_task_title.png"))  --带文字图片，路径待调整 

    self.m_specialItem = DailyTaskItem:create(TaskVO:create(),true)
    self.m_specialContainer:addChild(self.m_specialItem)
    self:setListener()
    self:createListView()
end

function DailyTaskPop:setListener()
    self.m_btnClose:addClickEventListener(function()
		g_PopupManager:hidden(g_PopupConfig.S_POPID.DAILYTASK_POP)
    end)
end

function DailyTaskPop:createListView()
    if g_TableLib.isEmpty(self.m_dailyTaskData)  then
        return 
    end
    local listViewContainer = g_NodeUtils:seekNodeByName(self,'taskList')
    listViewContainer:removeAllChildren()
    local size = listViewContainer:getContentSize();
    self.m_DailyTaskListView = cc.TableView:create(size)
    listViewContainer:addChild(self.m_DailyTaskListView)
    
    local itemSize = {}
    itemSize.width = 826;
    itemSize.height = 110;

    local function tablecellSizeForIndex(tbview, idx) --可以根据idx设置不同的size
        if idx==0 then-- or idx==#self.m_roomTaskData-1
            return itemSize.width,itemSize.height-5
        end
        return itemSize.width,itemSize.height
    end

    local function numberOfCellsInTableView() --总共多少数据
        return #self.m_dailyTaskData;
    end

    local function tableCellAtIndex(view,idx)
        local data = self.m_dailyTaskData[idx + 1]
        local cell = view:dequeueCell()
        if not cell then
            cell = DailyTaskItem:create()
        end
        cell:updateCell(data)
        return cell
    end

    self.m_DailyTaskListView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
	self.m_DailyTaskListView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
	self.m_DailyTaskListView:registerScriptHandler(tablecellSizeForIndex, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_DailyTaskListView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.m_DailyTaskListView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_DailyTaskListView:reloadData()

end



function DailyTaskPop:requestDailyTaskData()
    g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_REQUEST_DATA)
end

function DailyTaskPop:onRequestDailyTaskDataSuccess()
    if not self:isVisible() then return end
    
    local taskData = g_Model:getData(g_ModelCmd.ALL_TASK_LIST)
    local specialData = g_Model:getData(g_ModelCmd.TASK_SPECIAL)
    self:updateDailyTaskList(taskData)
    self:updateSpecialTask(specialData)
end

function DailyTaskPop:onGetRewardSuccess(data)
    Log.d("DailyTaskPop:onGetRewardSuccess",data)
    local dailyTaskAnim = DailyTaskAnim:create(data)
    dailyTaskAnim:run()
    self.m_DailyTaskListView:reloadData()
    self.m_specialItem:updateCell(self.m_specialTaskData)
end

function DailyTaskPop:updateDailyTaskList(data)
    self.m_dailyTaskData = data
    -- Log.d("updateDailyTaskList data = ",data)
    if g_TableLib.isEmpty(self.m_dailyTaskData) then
        Log.e("updateDailyTaskList no data")
        return 
    else
        if not self.m_DailyTaskListView then
            self:createListView()
        else
            self.m_DailyTaskListView:reloadData()
        end
    end
end

function DailyTaskPop:updateSpecialTask(data)
    self.m_specialTaskData = data
    if g_TableLib.isEmpty(self.m_specialTaskData) then
        Log.e("updateSpecialTask no data")
        return 
    else
        if not self.m_specialItem then
            self.m_specialItem = DailyTaskItem:create(TaskVO:create(),true)
            self.m_specialContainer:addChild(self.m_specialItem)
        else
            self.m_specialItem:updateCell(self.m_specialTaskData)
        end
    end
end

return DailyTaskPop