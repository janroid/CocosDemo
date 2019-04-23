local HallRankItem = require("HallRankItem");
local HallRankCtr = require("HallRankCtr");
local ViewBase = cc.load("mvc").ViewBase;
local HallRankUI = class("HallRankUI", ViewBase);

-- 配置事件监听函数
HallRankUI.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	[g_SceneEvent.RANK_HALL_RANKLIST_RESPONSE] = "refreshRankList";
	[g_SceneEvent.FRIEND_RECALL_SUCCESS]    = "onRecallSuccess";
	[g_SceneEvent.RANK_HALL_RETURN_MYRANK]  = "onMyRankCallbak";
}

function HallRankUI:ctor()
	ViewBase.ctor(self)
	self:bindCtr(HallRankCtr)
	self:registerEvent()
	self:loadLayout();
end

function HallRankUI:loadLayout()
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/rank/hallRank/rank_hall.ccreator');
	self.m_root:removeFromParent(false);
    self.m_root:setPosition(0,0);
    self.m_root:setAnchorPoint(0,0);
	self:add(self.m_root);
	self.m_showRankListData = {{},{}};
	self:initView();
end 

function HallRankUI:initView()
	self.m_rankCrowd = 1;

	local friendRankBtn = g_NodeUtils:seekNodeByName(self.m_root,'friendRankBtn') 
	local friendLabel = g_NodeUtils:seekNodeByName(friendRankBtn,'friendRankLabel');
	local worldRankBtn = g_NodeUtils:seekNodeByName(self.m_root,'worldRankBtn') 
	local worldLabel = g_NodeUtils:seekNodeByName(worldRankBtn,'worldRankLabel');
	friendLabel:setString(GameString.get("str_rank_hallRankCrowd2")); 
	worldLabel:setString(GameString.get("str_rank_hallRankCrowd1"));

	local color = cc.c3b(255,255,255);
	local color1 = cc.c3b(128,185,221);
	worldRankBtn:setEnabled(false);
	worldLabel:setColor(color);

	friendRankBtn:setPressedActionEnabled(true)
	friendRankBtn:addClickEventListener(function(sender)
		worldRankBtn:setEnabled(true);
		sender:setEnabled(false);
		worldLabel:setColor(color1);
		friendLabel:setColor(color);

		self.m_rankCrowd = 2;

		self:refreshShowRankList();
	end);	
	
	worldRankBtn:setPressedActionEnabled(true)	
	worldRankBtn:addClickEventListener(function(sender)
		friendRankBtn:setEnabled(true);
		sender:setEnabled(false);
		worldLabel:setColor(color);
		friendLabel:setColor(color1);

		self.m_rankCrowd = 1;

		self:refreshShowRankList();
	end);
	
	self:inintClipNode();
	self:initRankListView();
	self:initEmptyFriendView();
	self:checkShowEmptyFriendView();
end 

function HallRankUI:inintClipNode()
	local clipNode = g_NodeUtils:seekNodeByName(self.m_root,'clipNode');
	local mask = cc.Sprite:create("creator/rank/hallRank/hallRank_bg.png");
	mask:setAnchorPoint(cc.p(0,0));
    local clip = cc.ClippingNode:create(mask);
    clip:setAlphaThreshold(0.25);
    clip:setInverted(false);
    clip:setAnchorPoint(cc.p(0,0));
    clipNode:addChild(clip);

    local rankListView = g_NodeUtils:seekNodeByName(self.m_root,'rankListView'); 
    rankListView:removeFromParent(false);
    clip:addChild(rankListView);
    rankListView:setName("rankListView");
end

-- 好友排行榜为空 显示玩家自己的信息
function HallRankUI:initEmptyFriendView()
	self.m_myInfoView = g_NodeUtils:seekNodeByName(self.m_root,'myInfoView');
	local item = HallRankItem:create();
	self.m_myInfoView:addChild(item);
	item:setName ("myInfoViewItem")
	local emptyTips = g_NodeUtils:seekNodeByName(self.m_root,'emptyTips');
	emptyTips:setString(GameString.get("str_ran_noFriendTips"));
	self:getMyInfo()
end

function HallRankUI:checkShowEmptyFriendView()
	local isShow = false;
	if self.m_rankCrowd == 2 and #self.m_showRankListData[2] < 1 then
		isShow = true;
	end
	local emptyFriendView = g_NodeUtils:seekNodeByName(self.m_root,'emptyFriendView');
	emptyFriendView:setVisible(isShow);

	if self.m_tableView then 
		self.m_tableView:setVisible(not isShow);
	end 
end

function HallRankUI:getMyInfo()
	-- local myData = g_rankListData:requestInterface("getMyDetailRankData");
	self:doLogic(g_SceneEvent.RANK_HALL_GET_MYRANK)
end

function HallRankUI:onMyRankCallbak(data)
	self.m_myInfoView:getChildByName("myInfoViewItem"):refreshData(data);
end

function HallRankUI:initRankListView()
	-- self:formatRankListData();

	local rankListView = g_NodeUtils:seekNodeByName(self.m_root,'rankListView'); 
	local size = rankListView:getContentSize();
	local tableView = cc.TableView:create(size);
	tableView:setPosition(0,0);
	rankListView:addChild(tableView);

	local item = HallRankItem:create();
	local itemSize = item:getDisplaySize();
	delete(item);

	local function tablecellSizeForIndex(tbview, idx) --可以根据idx设置不同的size
        return size.width, itemSize.height;
    end

    local function numberOfCellsInTableView() --总共多少数据
        return #self.m_showRankListData[self.m_rankCrowd];
    end

    local function tablecellSizeAtIndex(tbview, idx) --初始化/刷新cell
        local index = idx + 1
        local cell = tbview:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
            
            local cellItem = HallRankItem:create();
            cell:addChild(cellItem);
            cellItem:setName("cellItem");
        end
		local cellItem = cell:getChildByName("cellItem");
		local data = self.m_showRankListData[self.m_rankCrowd][index]
		data.rank = index
        cellItem:refreshData(data);
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

function HallRankUI:refreshShowRankList()
 	if self.m_tableView then 
 		self.m_tableView:reloadData();
 	end 
 	self:checkShowEmptyFriendView();
end 

function HallRankUI:refreshRankList(data)
	self.m_showRankListData[1] = data.money
	self.m_showRankListData[2] = data.friends
	self.m_showRankListData[3] = data.selfRankInfo
	if self.m_tableView then 
 		self.m_tableView:reloadData();
 	else 
 		self:initRankListView();
 	end 
 	self:checkShowEmptyFriendView();
end

function HallRankUI:onRecallSuccess(uid)
	if(not self.m_showRankListData) then return end
	for i = 1, #self.m_showRankListData do
		if not self.m_showRankListData[i] then return end
		for j = 1, #self.m_showRankListData[i] do
			if self.m_showRankListData[i][j] and uid == self.m_showRankListData[i][j].uid then
				self.m_showRankListData[i][j].pushRecallLimit = -3
			end
		end
	end
	-- if self.m_tableView then 
	-- 	self.m_tableView:reloadData();
	-- end
end



function HallRankUI:onCleanup()
	Log.d("ReneYang", "HallRankUI:onCleanup")
	self:unBindCtr()
	self:unRegisterEvent()
end

return HallRankUI
