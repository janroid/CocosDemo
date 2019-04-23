--[[--ldoc desc
@module AchievementMatchRecord
@author MenuZhang

Date   2018-11-1
]]
local ViewUI = import("framework.scenes").ViewUI
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AchievementMatchRecord = class("AchievementMatchRecord",ViewUI);
BehaviorExtend(AchievementMatchRecord);

function AchievementMatchRecord:ctor(delegate)
	ViewUI.ctor(self);
	self.delegate = delegate
	-- self:bindCtr(require(".AchievementCtr"));
	self:init();
end

function AchievementMatchRecord:onCleanup()
	self:unBindCtr();
end

function AchievementMatchRecord:init()
	-- do something
	self.data = {}
	-- 加载布局文件
	self:createContent()

	self:updateView()
end

function AchievementMatchRecord:createContent(flag, sender)
	local tableView = cc.TableView:create(cc.size(578,500))
    local function tablecellSizeForIndex(tbview, index)
        return 578, 158 + 24
    end

    local function numberOfCellsInTableView()
        return math.ceil(#self.data / 4)
    end

    local function tablecellSizeAtIndex(tbview, index)
        local idx = index + 1
        local cell = tbview:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
            cell.items = {}
            for i=1, 4 do
				local AchievementCareerItem = require(".view/AchievementMatchRecordItem")
		    	local item = AchievementCareerItem:create()
		    	item:addClickEventListener(function (sender)
		    		self:onClickItem(sender)
		    	end)
		    	local x = (i-1)*(125+26)
		    	item:setPosition(x, 0)
		    	cell:add(item)
		    	cell.items[i] = item
			end
        end

        for k,v in pairs(cell.items) do
        	v:setTag(index*4 + k)
        	v:updateView(self.data[index*4 + k])
        end
        return cell
    end

    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(tablecellSizeForIndex, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(tablecellSizeAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:setDelegate()
    tableView:reloadData()
    self:add(tableView)
    self.tableView = tableView
end

---刷新界面
function AchievementMatchRecord:updateView(data)
	data = checktable(data);

	local config = {
		{},{},{},{},
		{},{},{},{},
		{},{},{},{},
		{},{},
	}
	self.data = config
	self.tableView:reloadData()
end

function AchievementMatchRecord:onClickItem(sender)
	local index = sender:getTag()
	local start_pos = sender:getTouchBeganPosition()
	local end_pos = sender:getTouchEndPosition()
	if math.abs(start_pos.y - end_pos.y) > 3 then return end

	print("onClickItem", index)
end

return AchievementMatchRecord