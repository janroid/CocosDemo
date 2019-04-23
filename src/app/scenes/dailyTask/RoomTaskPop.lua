--[[--ldoc desc
@module RoomTaskPop
@author %s

Date   %s
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RoomTaskPop = class("RoomTaskPop",PopupBase);
local RoomTaskItem = require("RoomTaskItem")
local DailyTaskAnim  = import("app.common.animation").RewardAnim
BehaviorExtend(RoomTaskPop);

-- 配置事件监听函数
RoomTaskPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
    -- 在hidden方法区取消监听
    [g_SceneEvent.DAILYTASK_EVENT_GET_REWARD_SUCCESS]         = "onGetRewardSuccess";
}

function RoomTaskPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("RoomTaskCtr"))
    self:init()
    self:setShadeTransparency(true)
end

function RoomTaskPop:show()
	PopupBase.show(self)
	self:watchDataList()
    self:requestRoomTaskData()
end

function RoomTaskPop:hidden()
	PopupBase.hidden(self)
	self:unwatchDataList()
end

function RoomTaskPop:init()
	-- do something
	
	-- 加载布局文件
	-- 第一个参数为布局文件，
	-- 第二个参数为boolean，
	--       true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--       false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
    -- self:loadLayout("aa.creator",isGlobal);
    self:loadLayout("creator/dailyTask/roomTask.ccreator");
    self.m_roomTaskBg = g_NodeUtils:seekNodeByName(self, 'room_task_bg')

	self:setListener()
	self:createListView()
end

function RoomTaskPop:setListener()

end

function RoomTaskPop:watchDataList()
	if self.m_watchDataList == nil then
        self.m_watchDataList = {
            {g_ModelCmd.ROOM_TASK_LIST,  self,  self.updateRoomTaskList};
        }
    end
    g_Model:watchDataList(self.m_watchDataList);
end

function RoomTaskPop:unwatchDataList()
	if self.m_watchDataList == nil then
        self.m_watchDataList = {
            {g_ModelCmd.ROOM_TASK_LIST,  self,  self.updateRoomTaskList};
        }
    end
    g_Model:unwatchDataList(self.m_watchDataList);
end

function RoomTaskPop:createListView()
	if g_TableLib.isEmpty(self.m_roomTaskData)  then
        return 
    end
    local listViewContainer = g_NodeUtils:seekNodeByName(self,'room_task_list')
    listViewContainer:removeAllChildren()
    local size = listViewContainer:getContentSize();
    self.m_roomTaskListView = cc.TableView:create(size)
    self.m_roomTaskListView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
    self.m_roomTaskListView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
    
    listViewContainer:addChild(self.m_roomTaskListView)
    
    -- local itemSize = {}
    -- itemSize.width = 1038;
    -- itemSize.height = 68;
    local item = RoomTaskItem:create()
    local size = item:getSize()
    size.height = size.height
    local function tablecellSizeForIndex(tbview, idx) --可以根据idx设置不同的size
        if idx==0 then-- or idx==#self.m_roomTaskData-1
            return size.width,size.height
        end
        return size.width,size.height + 7
    end

    local function numberOfCellsInTableView() --总共多少数据
        return #self.m_roomTaskData;
    end

    local function tableCellAtIndex(view,idx)
        local data = self.m_roomTaskData[idx + 1]
        local cell = view:dequeueCell()
        if not cell then
            cell = RoomTaskItem:create()
        end
        cell:updateCell(data)
        return cell
    end

    
	self.m_roomTaskListView:registerScriptHandler(tablecellSizeForIndex, cc.TABLECELL_SIZE_FOR_INDEX)
	self.m_roomTaskListView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.m_roomTaskListView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	self.m_roomTaskListView:reloadData()
end

function RoomTaskPop:requestRoomTaskData()
	g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_REQUEST_DATA)
end

function RoomTaskPop:onCleanup()
	PopupBase.onCleanup(self)
end

function RoomTaskPop:updateRoomTaskList()
	self.m_roomTaskData = g_Model:getData(g_ModelCmd.ROOM_TASK_LIST)
    if g_TableLib.isEmpty(self.m_roomTaskData) then
        Log.e("updateRoomTaskList no data")
        return 
    else
        if not self.m_roomTaskListView then
            self:createListView()
        else
            self.m_roomTaskListView:reloadData()
        end
    end

    -- self.m_roomTaskListView:setContentOffset(cc.p(0,0))
end

function RoomTaskPop:onRequestRoomTaskDataSuccess() 
    local data = g_Model:getData(g_ModelCmd.ROOM_TASK_LIST)
    if self.m_roomTaskList ~= nil then
        self.m_roomTaskListView:reloadData()
    else
        self:createListView()
    end
end

function RoomTaskPop:onGetRewardSuccess(data)
    Log.d("RoomTaskPop:onGetRewardSuccess",data)
    local dailyTaskAnim = DailyTaskAnim:create(data)
    dailyTaskAnim:run()
    self.m_roomTaskListView:reloadData()
end

return RoomTaskPop;