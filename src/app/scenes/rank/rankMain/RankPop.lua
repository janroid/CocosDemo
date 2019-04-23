--[[--ldoc desc
@module RankPop
@author ReneYang

Date   2018-11-30
]]
local RankItem = require('RankItem')
local PopupBase = import("app.common.popup").PopupBase
local RankPop = class("RankPop",PopupBase);
local TabarView  = import("app.common.customUI").TabarView

-- 配置事件监听函数
RankPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function RankPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("RankCtr"))
	self:init()
end

function RankPop:show()
	PopupBase.show(self)
	g_Progress.getInstance():show()
	self:watchData()
	self.m_tabarView:setTabarStateImmediately(1)
end

function RankPop:hidden()
	PopupBase.hidden(self)
	self:unwatchData()
	self.m_rankTypeBtns[self.m_rankType]:setEnabled(true);

	self.m_rankType = 1
	self.m_rankCrowd = 1
	self.m_rankTypeBtns[1]:setEnabled(false);

	g_Model:clearData(g_ModelCmd.RANK_MY_INFO)
	g_Model:clearData(g_ModelCmd.RANK_LIST_DISPLAY)
end

function RankPop:watchData()
	g_Model:watchProperty(g_ModelCmd.RANK_MY_INFO, "my_rank",self, self.watchMyRank, false)
	g_Model:watchData(g_ModelCmd.RANK_LIST_DISPLAY, self, self.watchRankList, false)
end

function RankPop:unwatchData()
	g_Model:unwatchProperty(g_ModelCmd.RANK_MY_INFO, "my_rank",self, self.watchMyRank)
	g_Model:unwatchData(g_ModelCmd.RANK_LIST_DISPLAY, self, self.watchRankList)
end
function RankPop:watchMyRank(myRankInfo)
	local rank = myRankInfo.rank or ""
	local desc = myRankInfo.desc or ""
	local x = self.m_rankTipsPos.x;

	self.m_lableMyRankInfo:setString(string.format(GameString.get("str_rank_myRank"),rank or " "))
	self.m_lableMyRankTips:setString(desc or " ");
	self.m_lableMyRankTips:setPosition(cc.p(x,self.m_rankTipsPos.y));
end

function RankPop:watchRankList(list)
	g_Progress.getInstance():dismiss()
	self.m_data = list
	self.m_tableView:reloadData()
end

function RankPop:init()
	self:loadLayout('creator/rank/rankMain/rankMain.ccreator')
	self.m_closeBtn = g_NodeUtils:seekNodeByName(self,'closeBtn')
	self.m_btnProperty = g_NodeUtils:seekNodeByName(self,'propertyBtn')
	self.m_btnLevel = g_NodeUtils:seekNodeByName(self,'levelBtn')
	self.m_btnAcheive = g_NodeUtils:seekNodeByName(self,'acheiveBtn')
	self.m_btnGame = g_NodeUtils:seekNodeByName(self,'gameBtn')

	self.m_lableMyRankInfo = g_NodeUtils:seekNodeByName(self,'myRankInfo')
	self.m_lableMyRankTips = g_NodeUtils:seekNodeByName(self,'rankTips')

	self.m_rankListContainer = g_NodeUtils:seekNodeByName(self,'rankListView')
	self.m_imgTabBg = g_NodeUtils:seekNodeByName(self,'rightTop')
	self.m_imgTitle = g_NodeUtils:seekNodeByName(self,'title')
	
	self.m_imgTitle:setTexture(switchFilePath("rank/rankTitle.png"))
	
	self.m_rankTipsPos = cc.p(self.m_lableMyRankTips:getPosition())
	self.m_lableMyRankInfo:setString(" ")
	self.m_lableMyRankTips:setString(" ")
	

	self.m_rankType = 1
	self.m_rankCrowd = 1
	self.m_btnProperty:setEnabled(false)
	
	local param = {
	                 tabarSize = {width = 560, height = 55},
	                 text = {name = {GameString.get("str_rank_rankCrowd1"), GameString.get("str_rank_rankCrowd2")},
	                         fontSize = 24,
	                         color = {on = {r = 255, g = 255, b = 255}, off = {r = 215, g = 239, b = 248}},
	                 },
	                 index = 1,
	                 isMove = true,
	                 tabClickCallbackObj = self,
	                 tabClickCallbackFunc = self.onTabarClickCallBack
	};
	self.m_tabarView = TabarView:create(param)
	self.m_imgTabBg:addChild(self.m_tabarView)
	g_NodeUtils:arrangeToCenter(self.m_tabarView)
	
	self:initListener()
	self:initData()
	self:initRankListView()
end

function RankPop:initData()
	self.m_myRankInfoData = {};
	self.m_showRankListData = {};
	for i = 1,4 do 
		self.m_showRankListData[i] = {{},{}};
		self.m_myRankInfoData[i] = {{},{}};
	end 
end

function RankPop:initListener()
	self.m_closeBtn:addClickEventListener(function(sender)
		self:hidden()
	end);

	self.m_rankTypeBtns = {self.m_btnProperty, self.m_btnLevel, self.m_btnAcheive, self.m_btnGame};
	for k,v in ipairs(self.m_rankTypeBtns) do
		v.tabIndex = k
		v:setPressedActionEnabled(true); 
		v:addClickEventListener(function(sender)
			self.m_rankTypeBtns[self.m_rankType]:setEnabled(true);
			self.m_rankType = sender.tabIndex
			sender:setEnabled(false);
			
			g_EventDispatcher:dispatch(g_SceneEvent.RANKPOP_TAB_CHANGED, self.m_rankType, self.m_rankCrowd)
		end); 
		local name = g_NodeUtils:seekNodeByName(v,"Label");
		name:setString(GameString.get(string.format("str_rank_rankType%s",k)));  
	end
end

function RankPop:onTabarClickCallBack(index)
	self.m_rankCrowd = index
	g_EventDispatcher:dispatch(g_SceneEvent.RANKPOP_TAB_CHANGED, self.m_rankType, self.m_rankCrowd)
end

function RankPop:initRankListView()
	local size = self.m_rankListContainer:getContentSize();
	local tableView = cc.TableView:create(size);
	tableView:setPosition(0,0);
	self.m_rankListContainer:addChild(tableView);

	local item = RankItem:create();
	local itemSize = item:getDisplaySize();
	delete(item);
	
	local function tablecellSizeForIndex(tbview, idx) --可以根据idx设置不同的size
        return size.width, itemSize.height;
    end

	local function numberOfCellsInTableView() --总共多少数据
		local len= self.m_data and #self.m_data or 0
		return len > 30 and 30 or len
    end

    local function tablecellSizeAtIndex(tbview, idx) --初始化/刷新cell
        local index = idx + 1
        local cell = tbview:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
            
            local cellItem = RankItem:create();
            cell:addChild(cellItem);
            cellItem:setName("cellItem");
        end
        local cellItem = cell:getChildByName("cellItem");

		local data = self.m_data[index]
		if data then
			data.m_index = index
			cellItem:refreshData(data);
		end
        return cell
    end
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
	tableView:registerScriptHandler(tablecellSizeForIndex, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:registerScriptHandler(tablecellSizeAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:reloadData()

	self.m_tableView = tableView;
end

function RankPop:onCleanup()
	PopupBase.onCleanup(self)
end

return RankPop;