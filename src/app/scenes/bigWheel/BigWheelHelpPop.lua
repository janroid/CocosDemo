--[[--ldoc desc
@module BigWheelHelpPop

Date   2019-04-22
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BigWheelHelpPop = class("BigWheelHelpPop",PopupBase);
BehaviorExtend(BigWheelHelpPop);

local PrizeProbabilityItem = require('PrizeProbabilityItem')
local PropItem = require("PropItem")

-- 配置事件监听函数
BigWheelHelpPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

BigWheelHelpPop.s_PrizeProbability = g_TableLib.copyTab(PropItem.s_type)

function BigWheelHelpPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("BigWheelHelpCtr"))
	self:initUI()
end

function BigWheelHelpPop:onCleanup()
	PopupBase.onCleanup(self)
end

function BigWheelHelpPop:show()
	PopupBase.show(self)
end

function BigWheelHelpPop:hidden()
	PopupBase.hidden(self)
end

function BigWheelHelpPop:initUI()
	self:loadLayout("creator/bigWheel/bigWheelHelp.ccreator");

	self.m_bg = g_NodeUtils:seekNodeByName(self, 'bg')
	self.m_btnClose = g_NodeUtils:seekNodeByName(self.m_bg, 'btn_close')
	self.m_btnClose:addClickEventListener(function(sender) self:hidden() end)

	self.m_labelTitle = g_NodeUtils:seekNodeByName(self.m_bg, 'label_title')
	self.m_labelPrize = g_NodeUtils:seekNodeByName(self.m_bg, "label_prize")
	self.m_labelProbability = g_NodeUtils:seekNodeByName(self.m_bg, "label_probability")

	self.m_labelTitle:setString(GameString.get("str_bigWheel_help_title"))
	self.m_labelPrize:setString(GameString.get("str_bigWheel_help_prize"))
	self.m_labelProbability:setString(GameString.get("str_bigWheel_help_probability"))

	self.m_tableviewContainer = g_NodeUtils:seekNodeByName(self.m_bg, "tableview_container")
	local size = self.m_tableviewContainer:getContentSize()
	-- 创建tableview
	local tableView = cc.TableView:create(size)
	tableView:setPosition(0, 0)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
	self.m_tableView = tableView
	self.m_tableviewContainer:add(tableView)

	tableView:registerScriptHandler(handler(self, self.tablecellSizeForIndex), cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function BigWheelHelpPop:numberOfCellsInTableView(tbview)
    return #self.s_PrizeProbability
end

function BigWheelHelpPop:tablecellSizeForIndex(tbview, idx)
	return 500, 65
end

function BigWheelHelpPop:tableCellAtIndex(tbview, idx)
	local cell = tbview:dequeueCell()
	if not cell then
		cell = PrizeProbabilityItem:create()
	end
	local prizeProbability = self.s_PrizeProbability[idx + 1]
	cell:updateCell(prizeProbability)
	return cell
end

return BigWheelHelpPop;