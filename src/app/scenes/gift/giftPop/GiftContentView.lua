
local GiftManager = require(".GiftManager");
local GiftPopLeftTableViewCell = require(".giftPop.GiftPopLeftTableViewCell")
local GiftPopRightTableViewCell = require(".giftPop.GiftPopRightTableViewCell")
local GiftContentView = class("GiftContentView",cc.Node)
local viewLayout = 'creator/gift/layout/giftContentView.ccreator'
function GiftContentView:ctor(pageType,data)
    self.m_data = data
    self.m_pageType = 0
    self.m_friendId = nil
    self:init()
end

function GiftContentView:init()

	-- 加载布局文件
	self.m_root = g_NodeUtils:getRootNodeInCreator(viewLayout)
    self:addChild(self.m_root)

    self.m_leftViewBg = g_NodeUtils:seekNodeByName(self.m_root, "bg_bottom_left")
    self.m_rightViewBg = g_NodeUtils:seekNodeByName(self.m_root, "bg_bottom_right")
    self.m_rightScrollView = g_NodeUtils:seekNodeByName(self.m_rightViewBg, "rightScrollView")
    self.m_buttonOnekeySell = g_NodeUtils:seekNodeByName(self.m_rightViewBg, "buttonOnekeySell")
    self.m_buttonOnekeySellLabel = g_NodeUtils:seekNodeByName(self.m_buttonOnekeySell, "Label")
    self.m_touchView = g_NodeUtils:seekNodeByName(self.m_root, "touchView")
    self.m_buttonOnekeySellLabel:setString(GameString.get("str_gift_sale_all_due_gift_hint"))
    self.m_buttonOnekeySell:setOpacity(0)
    self.m_buttonOnekeySell:setTouchEnabled(false)
    self.m_buttonOnekeySell:addClickEventListener(
        function(sender)
            self:onBtnOnekeySellClick()
        end
    )
    -- test Data
    self.m_listData = {}
    self.m_mailData = GameString.get("str_gift_pop_chip_title")
    self.m_itemNum = 4

    self:setTouchEvent()
    self:createLeftTableView()
    self:initListView()

end

function GiftContentView:createLeftTableView()
    local tableW = 235
    local tableH = self.m_leftViewBg:getContentSize().height   
    local cellH = 78

    self.m_leftTableView = cc.TableView:create(cc.size(tableW,tableH))
    self.m_leftTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_leftTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    local x = self.m_leftViewBg:getContentSize().width/2 - tableW/2 - 7
    local y = self.m_leftViewBg:getContentSize().height/2 - tableH/2 

    self.m_leftTableView:setPosition(cc.p(x,y))
    self.m_leftTableView:setDelegate()
    self.m_leftViewBg:addChild(self.m_leftTableView)

    local function cellSizeForTable(view,idx)
        return tableW, cellH
    end

    local function numberOfCellsInTableView(view)
        return #self.m_mailData
    end

    local function tableCellAtIndex(view,idx)
        local data = self.m_mailData[idx + 1]
        local cell = view:dequeueCell()
        if not cell then
            cell = GiftPopLeftTableViewCell:create()
        end
        cell:updateCell(data,view.curentSelectCellIdx==idx)
        return cell
    end
    --cell点击事件
    local function ontableViewCellTouch(table,cell)
        if table.curentSelectCellIdx == cell:getIdx() then return end
        if table.curentSelectCellIdx == nil then
            table.curentSelectCellIdx = 0
        end
        local selCell = self.m_leftTableView:cellAtIndex(table.curentSelectCellIdx+1)
        if selCell then
            selCell:onCellTouch(false)
        end
        table.curentSelectCellIdx = cell:getIdx()
        cell:onCellTouch(true)
        table:reloadData()
        g_EventDispatcher:dispatch(g_SceneEvent.GIFT_EVENT_LEFT_TAB_CHANGED, table.curentSelectCellIdx+1);
    end
    self.m_leftTableView:setBounceable(false)
    self.m_leftTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_leftTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_leftTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_leftTableView:registerScriptHandler(ontableViewCellTouch, cc.TABLECELL_TOUCHED)
    self.m_leftTableView:reloadData()

    self.m_leftTableView.curentSelectCellIdx = 0
    local selCell = self.m_leftTableView:cellAtIndex(self.m_leftTableView.curentSelectCellIdx)
    if selCell then
        selCell:onCellTouch(true)
    end
    
end

function GiftContentView:initListView()
    local tableW = self.m_rightScrollView:getContentSize().width 
    local tableH = self.m_rightScrollView:getContentSize().height   
    local cellH = 161 
    local cellW = 154

    self.m_rightTableView = cc.TableView:create(cc.size(tableW,tableH))
    self.m_rightTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_rightTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.m_rightTableView:setPosition(cc.p(0,0))
    self.m_rightTableView:setDelegate()
    self.m_rightScrollView:addChild(self.m_rightTableView)

    local function cellSizeForTable(view,idx)
        return tableW, cellH
    end

    local function numberOfCellsInTableView(view)
        local x1 = #self.m_listData - 1
        local y1 = self.m_itemNum
        return #self.m_listData == 0 and 0 or  math.modf(x1/y1) + 1
    end

    local function tableCellAtIndex(view,idx)
        local cell = view:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
            for i=1,self.m_itemNum do

                local cellItem = GiftPopRightTableViewCell:create();
                cell:addChild(cellItem);
                cellItem:setTag(i);
                cellItem:setPosition(i*cellW-cellW,0);
            end
        end
        --refresh
        for i=1,self.m_itemNum do
            local cellItem  = cell:getChildByTag(i)
            if #self.m_listData < idx*self.m_itemNum + i then
                cellItem:setEnabled(false);
            else
                cellItem:setEnabled(true);
                local data = self.m_listData[idx*self.m_itemNum + i]
                cellItem:updateCell(data);
            end
        end
        return cell
    end
    --cell点击事件
    local function ontableViewCellTouch(table,cell)
        for i=1,self.m_itemNum do

            local cellItem  = cell:getChildByTag(i)       
            local pos = cellItem:convertTouchToNodeSpace(self.m_currentTouch)
            local size = cellItem.m_root:getContentSize()
            local rect = cc.rect(0, 0, size.width, size.height);

            if cc.rectContainsPoint(rect,pos) then
                cellItem:showDetailePop(self.m_pageType,self.m_friendId)
                return
            end
        end
    end
    self.m_rightTableView:setBounceable(true)
    self.m_rightTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_rightTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_rightTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_rightTableView:registerScriptHandler(ontableViewCellTouch, cc.TABLECELL_TOUCHED)
    self.m_rightTableView:reloadData()
end

function GiftContentView:updateListItem(data)
    local tableW = self.m_rightScrollView:getContentSize().width 
    local tableH = self.m_rightScrollView:getContentSize().height 
    local h = tableH*2/3 + 40
    if GiftManager:getInstance().m_selectedCategory == "mygift" and GiftManager:getInstance().m_myGiftSelectedTag =="1"  then -- 选中已过期tab
        self.m_rightTableView:setViewSize(cc.size(tableW,h))
        self.m_rightTableView:setPosition(cc.p(0,tableH-h))
    else
        self.m_rightTableView:setViewSize(cc.size(tableW,tableH))
        self.m_rightTableView:setPosition(cc.p(0,0))
    end

    self.m_listData = data
    self.m_rightTableView:reloadData()
    if table.getn(data) == 0 then
        self.m_buttonOnekeySell:setOpacity(0)
        self.m_buttonOnekeySell:setTouchEnabled(false)
    end
end

function GiftContentView:updateTabListItem(data,index)
    if self.m_leftTableView.curentSelectCellIdx+1 ~= index then
        local selCell = self.m_leftTableView:cellAtIndex(self.m_leftTableView.curentSelectCellIdx)
        if selCell then
            selCell:onCellTouch(false)
        end
        self.m_leftTableView.curentSelectCellIdx = index-1
        selCell = self.m_leftTableView:cellAtIndex(self.m_leftTableView.curentSelectCellIdx)
        selCell:onCellTouch(true)
    end
    self.m_mailData = data
    local itemData = self.m_mailData[index]
    if itemData == GameString.get("str_mygift_left_category_item")[2] then
        self.m_buttonOnekeySell:setOpacity(255)
        self.m_buttonOnekeySell:setTouchEnabled(true)
    else
        self.m_buttonOnekeySell:setOpacity(0)
        self.m_buttonOnekeySell:setTouchEnabled(false)
    end
    self.m_leftTableView:reloadData()
end

GiftContentView.setTouchEvent=function(self)
    local function onTouchBegan(touch, event)
        if not self or not g_NodeUtils:isVisible(self.m_touchView) then
            return false
        end
        self.m_currentTouch = touch
    end
    -- begin,moved,ended,cancel, must按順序執行 定義
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self.m_touchView:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_touchView)
end

--------------------------click evnt --------------------------------

function GiftContentView:onBtnOnekeySellClick(data)
    GiftManager:getInstance():qucikSaleAllDueGift()
end

return GiftContentView