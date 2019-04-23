--[[--ldoc desc
@module ChatPop
@author %s

Date   %s
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ChatPop = class("ChatPop",PopupBase);
local ChatFaceViewCell = require("ChatFaceViewCell")
local QuickChatItem = require("QuickChatItem")
local expressions_pin_map = require("expression_pin_map")
local ChatHistoryItem = require("ChatHistoryItem")


BehaviorExtend(ChatPop);


local CHAT_MAX_WORD_COUNT = 30
-- 配置事件监听函数
ChatPop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
	[g_SceneEvent.ROOM_REMOVE_CHAT_POP] = "hidden";
	[g_SceneEvent.ROOM_CHAT_SEND_EXPRESSION] = "onSendExpression";
	[g_SceneEvent.ROOM_CHAT_SEND_QUICK_MESSAGE] = "sendQuickMessage";
}

ChatPop.S_TABVIEW = {
	FaceView   = 1;
	QuickChatView = 2;
	HistoryView = 3;
};

ChatPop.S_FACETAB = {
	Normal = 1;
	Kolar = 2;
	Bear = 3;
}

ChatPop.S_CHATTYPE = {
	Normal = 1;
	SmallSpeaker = 2;
	BigSpeaker = 3;
}

ChatPop.S_CHATTYPEICON = {
	"creator/chatPop/imgs/chat_icon.png";
	"creator/chatPop/imgs/small_speaker.png";
	"creator/chatPop/imgs/big_speaker.png";
}

ChatPop.VIP_BEAR_INDEX =
{
    [10101] = "0002";
    [10102] = "0002";
    [10103] = "0003";
    [10104] = "0005";
    [10105] = "0002";
    [10106] = "0005";
    [10107] = "0001";
    [10108] = "0004";
    [10109] = "0002";
    [10110] = "0002";
    [10111] = "0003";
    [10112] = "0003";
};
ChatPop.TEXTCOUNT = 19;

function ChatPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("ChatCtr"))
	self:init()
	self:initListener()
	self:setShadeTransparency(true)
end

function ChatPop:show()
	PopupBase.show(self)

	if (not self.m_curTab) then
		-- self.m_curTab = ChatPop.S_TABVIEW.FaceView
		self:onFaceViewTabClick()
	else		
		if self.m_curTab == ChatPop.S_TABVIEW.QuickChatView then
			self:onQuickChatTabClick()
		elseif self.m_curTab == ChatPop.S_TABVIEW.HistoryView then
			self:updateHistoryView();
		end
	end
	
    self:refreshChatType()
	self:updateData()	
end

function ChatPop:updateData()
	
	g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_PROP_DATA)
end

function ChatPop:refreshChatType()

	self.m_curType = ChatPop.S_CHATTYPE.Normal
	self.m_btnchatType:loadTextures(ChatPop.S_CHATTYPEICON[self.m_curType],ChatPop.S_CHATTYPEICON[self.m_curType])
end

function ChatPop:hidden()
	self.m_viewChatType:setVisible(false)
	-- g_PopupManager:hidden(g_PopupConfig.S_POPID.ROOM_CHAT_POP)
	PopupBase.hidden(self)
end

function ChatPop:init()
	-- do something
	
	-- 加载布局文件
	-- 第一个参数为布局文件，
	-- 第二个参数为boolean，
	--       true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--       false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
	-- self:loadLayout("aa.creator",isGlobal);
	self:loadLayout('creator/chatPop/chatPop.ccreator')
	self.m_faceTabs = {}
	self.m_chatPopBg  		= g_NodeUtils:seekNodeByName(self,'img_chat_pop_bg')
	self.m_viewFace			= g_NodeUtils:seekNodeByName(self,'view_face')
	self.m_viewFaceItem		= g_NodeUtils:seekNodeByName(self,'view_face_item')
	self.m_viewFaceList		= g_NodeUtils:seekNodeByName(self,'view_face_list')
	self.m_viewQuickChat 	= g_NodeUtils:seekNodeByName(self,'view_quick_chat')
	self.m_viewHistory		= g_NodeUtils:seekNodeByName(self,'view_chat_history')
	self.m_viewChat 		= g_NodeUtils:seekNodeByName(self,'view_chat')
	
	self.m_viewLeftTab 		= g_NodeUtils:seekNodeByName(self,'view_left_tab')
	self.m_imgTabSelected 	= g_NodeUtils:seekNodeByName(self,'img_selected_tab')
	self.m_viewFaceTab 		= g_NodeUtils:seekNodeByName(self,'view_face_tab')
	self.m_imgFaceIcon		= g_NodeUtils:seekNodeByName(self,'img_face_icon')
	self.m_faceTabSelected	= g_NodeUtils:seekNodeByName(self,'img_face_tab_selected')
	self.m_faceTabs[ChatPop.S_FACETAB.Normal]		= g_NodeUtils:seekNodeByName(self,'img_face_tab_normal')
	self.m_faceTabs[ChatPop.S_FACETAB.Kolar]			= g_NodeUtils:seekNodeByName(self,'img_face_tab_vip_bear')
	self.m_faceTabs[ChatPop.S_FACETAB.Bear]		= g_NodeUtils:seekNodeByName(self,'img_face_tab_vip2')

	self.m_viewMessageTab	= g_NodeUtils:seekNodeByName(self,'view_message_tab')
	self.m_imgMessageIcon	= g_NodeUtils:seekNodeByName(self,'img_message_icon')
	self.m_viewHistoryTab 	= g_NodeUtils:seekNodeByName(self,'view_history_tab')
	self.m_imgHistoryIcon	= g_NodeUtils:seekNodeByName(self,'img_history_icon')

	self.m_viewChatInput	= g_NodeUtils:seekNodeByName(self,'view_chat_input')
	self.m_editBox			= g_NodeUtils:seekNodeByName(self,'editbox')
	self.m_btnchatType		= g_NodeUtils:seekNodeByName(self,'btn_chat_type')
	self.m_btnSend			= g_NodeUtils:seekNodeByName(self,'btn_send')
	self.m_labelSend		= g_NodeUtils:seekNodeByName(self,'label_send')

	self.m_viewChatType 	= g_NodeUtils:seekNodeByName(self,'view_chat_type_select')
	self.m_btChatTypeBg 	= g_NodeUtils:seekNodeByName(self,'bt_chat_type_bg')
	self.m_tipBg			= g_NodeUtils:seekNodeByName(self,'tip_bg')
	self.m_btnNormalType 	= g_NodeUtils:seekNodeByName(self,'btn_normal_type')
	self.m_btnSmallSpeakerType 	= g_NodeUtils:seekNodeByName(self,'btn_small_speaker')
	self.m_smallSpeakerCount 	= g_NodeUtils:seekNodeByName(self,'label_small_speaker_count')
	self.m_btnBigSpeakerType 	= g_NodeUtils:seekNodeByName(self,'btn_big_speaker')
	self.m_bigSpeakerCount 		= g_NodeUtils:seekNodeByName(self,'label_big_speaker_count')
	self.m_btnBuySpeaker		= g_NodeUtils:seekNodeByName(self,'btn_buy_speaker')
	self.m_lableBuySpeaker		= g_NodeUtils:seekNodeByName(self,'label_buy_speaker')
	
	self.m_tipBg:setSwallowTouches(true)
	self.m_btnNormalType:setTitleText(GameString.get("str_chatPop_normal_type"))
	self.m_btnNormalType:setTitleFontSize(24)
	self.m_btnSmallSpeakerType:setTitleText(GameString.get("str_chatPop_smallSpeaker_type"))
	self.m_btnSmallSpeakerType:setTitleFontSize(24)
	self.m_btnBigSpeakerType:setTitleText(GameString.get("str_chatPop_bigSpeaker_type"))
	self.m_btnBigSpeakerType:setTitleFontSize(24)
	self.m_lableBuySpeaker:setString(GameString.get("str_chatPop_buy_speaker"))

	self.m_btnchatType:loadTextures(ChatPop.S_CHATTYPEICON[1],ChatPop.S_CHATTYPEICON[1])
	self.m_curType = 1
	self.m_viewChatType:setVisible(false)
    self.m_smallSpeakerCount:setString(tostring("x "..0));--小喇叭
    self.m_bigSpeakerCount:setString(tostring("x "..0));--大喇叭

	local x,y = self.m_imgFaceIcon:getPosition();
	self.m_imgTabSelected:setPosition(x,y);

	local x,y = self.m_faceTabs[ChatPop.S_FACETAB.Normal]:getPosition();
	self.m_faceTabSelected:setPosition(x,y);

	self.m_faceTabPos = {}
	self.m_chatData ={}
	-- self.m_chatPopBg:setSwallowTouches(true)
	self:updateChatView(true,false,false)

	self.m_editBox:setPlaceHolder(GameString.get("str_chatPop_edit_hint"))
	self.m_editBox:setPlaceholderFontSize(g_AppManager:getAdaptiveConfig().RoomChat.EditBoxPlaceholderFontSize or 24)
	self.m_editBox:setMaxLength(26)
	self:initFaceData()
	self:initFaceView()
	self:createQuickChatList()
	 self:createHistoryList()

	self.m_sTrumpetCount = 0
	self.m_bTrumpetCount = 0
	self:updateLabelString()

end

function ChatPop:updateLabelString()
	self.m_labelSend:setString(GameString.get("str_send"))
end

function ChatPop:initListener()
	self.m_editBox:registerScriptEditBoxHandler(
		function(eventType)
			if eventType == "ended" then
				-- 当编辑框失去焦点并且键盘消失的时候被调用
				--do something

			end
		end
	)

	self.m_btnSend:addTouchEventListener(function(obj,touchType)
		if touchType == ccui.TouchEventType.began then 
			self:onBtnSendClick()
		end
	end)
	--self.m_btChatTypeBg:setSwallowTouches(false)
	self.m_btChatTypeBg:addClickEventListener(function(sender)
		self:showSelectTypeView()
		 end)

	self.m_btnchatType:addClickEventListener(function()
		self:showSelectTypeView()
	end)

	self.m_btnNormalType:addClickEventListener(function()
		self:onBtnChatTypeClick(1)
	end)

	self.m_btnSmallSpeakerType:addClickEventListener(function()
		self:onBtnChatTypeClick(2)
	end)

	self.m_btnBigSpeakerType:addClickEventListener(function()
		self:onBtnChatTypeClick(3)
	end)

	self.m_btnBuySpeaker:addClickEventListener(function()
		self:onBtnBuySpeakerClick()
	end
	)

	

	self.m_faceTabs[ChatPop.S_FACETAB.Normal]:addClickEventListener(function()
		self:onFaceTabClick(ChatPop.S_FACETAB.Normal)
	end)
	self.m_faceTabs[ChatPop.S_FACETAB.Kolar]:addClickEventListener(function()
		self:onFaceTabClick(ChatPop.S_FACETAB.Kolar)
	end)
	self.m_faceTabs[ChatPop.S_FACETAB.Bear]:addClickEventListener(function()
		self:onFaceTabClick(ChatPop.S_FACETAB.Bear)
	end)

	self.m_viewFaceTab:addClickEventListener(function()
		self:onFaceViewTabClick()
	end)

	self.m_viewMessageTab:addClickEventListener(function()
		self:onQuickChatTabClick()
	end)

	self.m_viewHistoryTab:addClickEventListener(function()
		self:onHistoryTabClick()
	end)

    g_Model:watchData(g_ModelCmd.ROOM_CHAT_HISTORY, self, self.updateHistoryView);
    g_Model:watchData(g_ModelCmd.ROOM_USER_PROP_DATA,self,self.getUserPropData)
end

function ChatPop:setChatLog(data)
	if (data) then
        self.m_scrollChatLog:removeAllChildren();
          local index = #data - 50;
          if index <= 0 then
            index = 1;
          end
          for i = index, #data do
            local item = new(ChatRecordItemRender, data[i]);
            self.m_scrollChatLog:addChild(item);
          end
--        for _,v in pairs(data) do
--            local item = new(ChatRecordItemRender, v);
--            self.m_scrollChatLog:addChild(item);
--        end
    end
end

function ChatPop:initFaceData()
	local faceData = {}
	local data = {}
	local j = 1 ;
	for i=1,30 do
		data[j] = { id=i,texture = expressions_pin_map["expression_" .. i .. "_0001.png"], textureName="expression_" .. i .. "_0001.png"};
		j = j + 1;
	end
	-- self:addExpressions(data, self.m_tabsExpression[1]);
	table.insert(faceData,data)

	local data = {};
	local j = 1;
	for i=61,90 do
		data[j] = { id=i, texture = expressions_pin_map["expression_" .. i .. "_0001.png"], textureName="expression_" .. i .. "_0001.png"};
		j = j + 1;
	end
	table.insert(faceData,data)

	local data = {};
	local j = 1;
	for i=10101,10112 do
		local mcIndex = "0001";
		if(ChatPop.VIP_BEAR_INDEX[i] ~= nil) then
			mcIndex = ChatPop.VIP_BEAR_INDEX[i];
		end
		data[j] = { id=i, texture = expressions_pin_map["racoon_expression_" .. i .. "_" .. mcIndex .. ".png"],textureName="racoon_expression_" .. i .. "_" .. mcIndex .. ".png"};
		j = j + 1;
	end
	table.insert(faceData,data)
	self.m_faceData = faceData
	self.m_curFaceTab = self.m_curFaceTab or self.S_FACETAB.Normal
	self.m_curFaceData = self.m_faceData[self.m_curFaceTab]
end

function ChatPop:initFaceView()
	local size = self.m_viewFaceList:getContentSize()

	local scrollView = g_NodeUtils:seekNodeByName(self.m_viewFaceList,'scrollView_face') 
	scrollView:setScrollBarEnabled(false)
  	local container = scrollView:getInnerContainer()

  	local nodeArrange = g_NodeUtils:seekNodeByName(container,'layout_arrange') 
  	nodeArrange:setAnchorPoint(cc.p(0,1))
  	nodeArrange:removeAllChildren(true)

	local len = #self.m_curFaceData

	for i=1,len do
		local data = self.m_curFaceData[i]
		local item = ChatFaceViewCell:create()
		nodeArrange:addChild(item)
		item:updateCell(data)
	end


	nodeArrange:forceDoLayout()
	local arrangeSize = nodeArrange:getContentSize()
	local scrollViewSize = scrollView:getContentSize()
	local y = arrangeSize.height
	if y < scrollViewSize.height then
		y = scrollViewSize.height
	end
	  
	nodeArrange:setPosition(0,y)
	 
	scrollView:setInnerContainerSize(cc.size(scrollViewSize.width,y))
	scrollView:jumpToTop()

	--self.m_faceViewList = cc.TableView:create(cc.size(size.width,size.height))
	--self.m_faceViewList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
	--self.m_faceViewList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	--self.m_viewFaceList:addChild(scrollView)
	--scrollView:setAnchorPoint(0,0)

--[[	local cellH = 140
	local cellW = 115
	self.m_itemNum = 4

	local function cellSizeForTable(view,idx)
        return size.width, cellH
    end

    local function numberOfCellsInTableView(view)
        local x1 = #self.m_curFaceData - 1
        local y1 = self.m_itemNum
        return #self.m_curFaceData == 0 and 0 or  math.modf(x1/y1) + 1
    end

    local function tableCellAtIndex(view,idx)
        local cell = view:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
            for i=1,self.m_itemNum do
                local cellItem = ChatFaceViewCell:create();
                cell:addChild(cellItem);
				cellItem:setTag(i);
				cellItem:setAnchorPoint(cc.p(0,0))
                cellItem:setPosition(i*cellW-cellW,0);
            end
        end
        --refresh
        for i=1,self.m_itemNum do
            local cellItem  = cell:getChildByTag(i)
            if #self.m_curFaceData < idx*self.m_itemNum + i then
				cellItem:updateCell();
            else
                -- cellItem:setEnabled(true);
				local data = self.m_curFaceData[idx*self.m_itemNum + i]
                cellItem:updateCell(data);
            end
        end
        return cell
	end
    self.m_faceViewList:setBounceable(true)
    self.m_faceViewList:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_faceViewList:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_faceViewList:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_faceViewList:reloadData()
	]]
end

--function ChatPop:createQuickChatList()
--	if g_TableLib.isEmpty(self.m_commonTxList) then
--		self.m_commonTxList = {}
--		local commonTextCount = ChatPop.TEXTCOUNT
--		for i = 1, commonTextCount do
--			self.m_commonTxList[i] = GameString.get(string.format("str_chat_common_%d", i));
--		end
--	end

--	self.m_viewQuickChat:removeAllChildren()
--	local size = self.m_viewQuickChat:getContentSize()
--	self.m_quickChatList = cc.TableView:create(cc.size(size.width,size.height))
--	self.m_quickChatList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
--	self.m_quickChatList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--	self.m_viewQuickChat:addChild(self.m_quickChatList)
--	self.m_quickChatList:setDelegate()
--	local cellH = 64
--	local cellW = 465

--	local function cellSizeForTable(view,idx)
--        return cellW, cellH
--    end

--	local function numberOfCellsInTableView(view)
--        return #self.m_commonTxList
--	end

--	local function tableCellAtIndex(view,idx)
--        local cell = view:dequeueCell()
--		if not cell then
--			cell = QuickChatItem:create()
--		end
--		local data = self.m_commonTxList[idx+1]
--		cell:updateCell(data)
--		return cell
--	end

--	self.m_quickChatList:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
--    self.m_quickChatList:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
--    self.m_quickChatList:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
--    self.m_quickChatList:reloadData()
--end

function ChatPop:createQuickChatList()
    self.m_quickChatList = ccui.ListView:create()
	self.m_quickChatList:setContentSize(self.m_viewQuickChat:getContentSize());
	self.m_quickChatList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_quickChatList:setBounceEnabled(true);
	self.m_quickChatList:setScrollBarWidth(0)
	self.m_viewQuickChat:addChild(self.m_quickChatList)

	if g_TableLib.isEmpty(self.m_commonTxList) then
		self.m_commonTxList = {}
		local commonTextCount = ChatPop.TEXTCOUNT
		for i = 1, commonTextCount do
			self.m_commonTxList[i] = GameString.get(string.format("str_chat_common_%d", i));
		end
	end

	--	local cellH = 64
--	local cellW = 465

	for i = 1,#self.m_commonTxList do
		local item = QuickChatItem:create();
		item:refreshData(self.m_commonTxList[i])
		item:addClickEventListener(function(target)
			Log.d("click func onItemClicked")
			self:onItemClicked(target)
		end)
		item:addTouchEventListener(function(target,event)
			if event == 0 then
               Log.d("item touch begin")
				self.m_touchBeganPos = target:getTouchBeganPosition()
			elseif event == 1 then
               Log.d("item moved",self.m_touchBeganPos,self.m_touchMovePos)
				self.m_touchMovePos = target:getTouchMovePosition()
				
            elseif event == 2 then
                if not self.m_touchMovePos then return end
                if math.abs(self.m_touchBeganPos.x - self.m_touchMovePos.x)<50
					and math.abs(self.m_touchBeganPos.y - self.m_touchMovePos.y) < 50 then
                    Log.d("touch func onItemClicked")
					self:onItemClicked(target)
				end
			end
		end)
		self.m_quickChatList:pushBackCustomItem(item)
	end
end

--function ChatPop:createHistoryList()	
--	local size = self.m_viewHistory:getContentSize()
--	self.m_viewHistory:removeAllChildren()
--	self.m_historyList = cc.TableView:create(cc.size(size.width,size.height))
--	self.m_historyList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
--	self.m_historyList:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--	self.m_viewHistory:addChild(self.m_historyList)
--	self.m_historyList:setDelegate()

--	local cellH = 64
--	local cellW = 465
--	local function cellSizeForTable(view,idx)
--		local data = self.m_chatData[idx+1]
--		local label = cc.Label:createWithSystemFont(data.message,"",20)
--		label:setOverflow(cc.LabelOverflow.RESIZE_HEIGHT)
--		local labelH = 20
--		if string.len(data.message) > 20 then
--			label:setWidth(340)
--			size = label:getContentSize()
--			labelH = size.height 
--		else
--			cellH = 64
--		end
--		local line = labelH / 20
--		if line <= 1 then 
--			line = 1
--		end
--		self.m_chatData[idx+1].cellW = cellW
--		self.m_chatData[idx+1].cellH = cellH+(line-1)*20
--		-- delete(label)
--		return self.m_chatData[idx+1].cellW,self.m_chatData[idx+1].cellH
--        -- return cellW, cellH+(line-1)*20
--    end

--	local function numberOfCellsInTableView(view)
--        return #self.m_chatData
--	end

--	local function tableCellAtIndex(view,idx)
--        local cell = view:dequeueCell()
--		if not cell then
--			cell = ChatHistoryItem:create()
--		end
--		local data = self.m_chatData[idx+1]
--		cell:updateCell(data)
--		return cell
--	end

--	self.m_historyList:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
--    self.m_historyList:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
--    self.m_historyList:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
--    self.m_historyList:reloadData()
--end

function ChatPop:createHistoryList()
   --[[self.m_viewHistory:removeAllChildren()
    self.m_historyList = ccui.ListView:create()
	self.m_historyList:setContentSize(self.m_viewQuickChat:getContentSize());
	self.m_historyList:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);
	self.m_historyList:setBounceEnabled(true);
	self.m_historyList:setScrollBarWidth(0)
	self.m_viewHistory:addChild(self.m_historyList)
    local size = nil
    local cellH = 64
    local cellW = 465
    
    for i = 1,#self.m_chatData do
		local item = ChatHistoryItem:create();
        local itemData = self.m_chatData[i]
		item:refreshData(self.m_chatData[i])
		local label = cc.Label:createWithSystemFont(itemData.message,"",20)
	    label:setOverflow(cc.LabelOverflow.RESIZE_HEIGHT)
        
		local labelH = 20
		if string.len(itemData.message) > 20 then
			label:setWidth(340)
			size = label:getContentSize()
			labelH = size.height
		else
			cellH = 64
		end
		local line = labelH / 20
		if line <= 1 then 
			line = 1
		end
		local width = cellW
		local height = cellH+(line-1)*20
        item:setContentSize(cc.size(width,height))
		delete(label)
--		return self.m_chatData[idx+1].cellW,self.m_chatData[idx+1].cellH
        -- return cellW, cellH+(line-1)*20

		self.m_historyList:pushBackCustomItem(item)
	end
	self.m_historyList:jumpToBottom()
	]] 






	local scrollView = g_NodeUtils:seekNodeByName(self.m_viewHistory,'scrollView_chat') 
	scrollView:setScrollBarEnabled(false)
  	local container = scrollView:getInnerContainer()

  	local nodeArrange = g_NodeUtils:seekNodeByName(container,'layout_arrange') 
  	nodeArrange:setAnchorPoint(cc.p(0,1))
  	nodeArrange:removeAllChildren(true)

	local len = #self.m_chatData

	for i=1,len do
		local data = self.m_chatData[i]
		local item = ChatHistoryItem:create()
		nodeArrange:addChild(item)
		item:refreshData(data)
	end


	nodeArrange:forceDoLayout()
	local arrangeSize = nodeArrange:getContentSize()
	local scrollViewSize = scrollView:getContentSize()
	local y = arrangeSize.height
	if y < scrollViewSize.height then
		y = scrollViewSize.height
	end
	  
	nodeArrange:setPosition(0,y)
	 
	scrollView:setInnerContainerSize(cc.size(scrollViewSize.width,y))
	scrollView:jumpToBottom()



end

function ChatPop:updateHistoryView(data)
	if not g_TableLib.isEmpty(data) then
		self.m_chatData = data
        self:createHistoryList()
    else
        return 
	end

----	self.m_historyList:reloadData()
--    local items  = self.m_historyList:getItems()
--    if g_TableLib:isEmpty() then return end
--    for i = 1,#items do
--        local item = items[i]
--        item:refreshData(self.m_chatData[i])

----	local containerSize = self.m_viewHistory:getContentSize()
--	local listViewH = 0
--	for i = 1,#self.m_chatData do
--		listViewH = listViewH + self.m_chatData[i].cellH 
--	end
----	if listViewH > containerSize.height then
----		self.m_historyList:setContentOffset(cc.p(0,0))
----	end
end

function ChatPop:setCurFaceTab(nTabId)
	self.m_curFaceTab = nTabId
	
end

function ChatPop:showFaceView()
	self.m_curTab = ChatPop.S_TABVIEW.FaceView;
	self:updateFaceView();
end

function ChatPop:updateFaceView()
	self:onFaceTabClick(self.m_curFaceTab or self.S_FACETAB.Normal)
end

function ChatPop:updateQuickChatView()
--	self.m_quickChatList:reloadData()
end

function ChatPop:updateChatView(face,quickChat,history)
	self.m_viewFace:setVisible(face)
	self.m_viewQuickChat:setVisible(quickChat)
	self.m_viewHistory:setVisible(history)
end

function ChatPop:showSelectTypeView()
	local visible = self.m_viewChatType:isVisible()
	self.m_viewChatType:setVisible(not visible)
end

function ChatPop:getUserPropData(data)
	--互动道具分类
	self.m_sTrumpetCount = 0
	self.m_bTrumpetCount = 0 --初始化喇叭数量 默认为0

	if g_TableLib.isEmpty(data) then 
		self.m_smallSpeakerCount:setString(tostring("x " .. self.m_sTrumpetCount)) --小喇叭
		self.m_bigSpeakerCount:setString(tostring("x " .. self.m_bTrumpetCount)) --大喇叭
		return 
	end
 
    for i=1,#data do
        local iType = tonumber(data[i].a);
        local num = tonumber(data[i].b);
        if(iType == 30) then
            self.m_sTrumpetCount = num;
        elseif(iType == 32) then
            self.m_bTrumpetCount = num;
        end
	end	
	self.m_smallSpeakerCount:setString(tostring("x " .. self.m_sTrumpetCount)) --小喇叭
	self.m_bigSpeakerCount:setString(tostring("x " .. self.m_bTrumpetCount)) --大喇叭	
end

function ChatPop:onSendExpression(data)
	-- SocketManager:requestSendEmotion(data)
	 g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_SEND_EMOTION, data);
end

function ChatPop:sendQuickMessage(data)
	-- SocketManager:requestSendMessage(data)
	g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_SEND_MESSAGE, data);
end

function ChatPop:onCleanup()
	PopupBase.onCleanup(self)
    g_Model:setData(g_ModelCmd.ROOM_CHAT_HISTORY, {});
	g_Model:unwatchData(g_ModelCmd.ROOM_CHAT_HISTORY, self, self.updateHistoryView);
	g_Model:unwatchData(g_ModelCmd.ROOM_USER_PROP_DATA,self,self.getUserPropData)
end

function ChatPop:showTips(str)
	g_AlarmTips.getInstance():setText(str):show()
end

--------------------------click function ----------------------
function ChatPop:onFaceViewTabClick()
	if (self.m_curTab == ChatPop.S_TABVIEW.FaceView) then 
		return; 
	else
		
	end
	local x,y = self.m_viewFaceTab:getPosition()
	self.m_imgTabSelected:setPosition(cc.p(x,y))
	self:updateChatView(true,false,false)
	self:showFaceView()
end

function ChatPop:onQuickChatTabClick()
	if (self.m_curTab == ChatPop.S_TABVIEW.QuickChatView) then 
		return; 
	else
		self.m_curTab = ChatPop.S_TABVIEW.QuickChatView
	end
	Log.d("quick chat click")
	local x,y = self.m_viewMessageTab:getPosition()
	self.m_imgTabSelected:setPosition(cc.p(x,y))
	self:updateChatView(false,true,false)
	self:updateQuickChatView()

end

function ChatPop:onHistoryTabClick()
	if (self.m_curTab == ChatPop.S_TABVIEW.HistoryView) then 
		return;
	else
		self.m_curTab = ChatPop.S_TABVIEW.HistoryView 
	end
	Log.d("history view click")
	local x,y = self.m_viewHistoryTab:getPosition()
	self.m_imgTabSelected:setPosition(cc.p(x,y))
	self:updateChatView(false,false,true)
--	self:updateHistoryView()
end

function ChatPop:onFaceTabClick(tab)
	
	self:setCurFaceTab(tab)
	
	local x,y = self.m_faceTabs[tab]:getPosition()
	self.m_faceTabSelected:setPosition(x,y)
	self.m_curFaceData = self.m_faceData[self.m_curFaceTab]
	--self.m_faceViewList:reloadData()
	self:initFaceView()
end

function ChatPop:onBtnChatTypeClick(type)
	self.m_curType = type
	-- local render = self.m_btnchatType:getRendererNormal()
	-- render:setSpriteFrame(ChatPop.S_CHATTYPEICON[type],cc.rect(0,0,0,0))
	-- self.m_btnchatType:loadTextureNormal(ChatPop.S_CHATTYPEICON[type])
	self.m_btnchatType:loadTextures(ChatPop.S_CHATTYPEICON[type],ChatPop.S_CHATTYPEICON[type])
	self.m_viewChatType:setVisible(false)
end

function ChatPop:onItemClicked(item)
	local data = item.m_data
	if not data then return end
	
	local cutTime = os.time()
	if not self.m_clickItemTime then
		self.m_clickItemTime= 0
	end
	if cutTime - self.m_clickItemTime > 0.9 then
		self.m_clickItemTime = cutTime
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_SEND_QUICK_MESSAGE,data)
		g_EventDispatcher:dispatch(g_SceneEvent.ROOM_REMOVE_CHAT_POP)
	else
		--self:showTips(GameString.get("str_room_chat_too_quick"))
	end
	
end

function ChatPop:onBtnSendClick()
	local text = self.m_editBox:getText()
	if string.len(string.trim(text)) > 0 then
		if not g_StringUtils.isOnlyNumberOrChar(text) then
			if g_StringUtils.len(text) > CHAT_MAX_WORD_COUNT then
				text = g_StringUtils.utf8_substring(text,0,CHAT_MAX_WORD_COUNT)
			end
		end
		self.m_editBox:setText(nil)
		if self.m_curType ==  1 then
			Log.d("send chat message :",text)
			-- SocketManager:requestSendMessage(text)
            self:hidden()
			g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_SEND_MESSAGE, text);
		elseif self.m_curType == 2 then
			Log.d("send chat message :",text)
			if self.m_sTrumpetCount > 0 then
				g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_SMALLL_TRUMPET, text);
				self:hidden()
			else 
				self:showTips(GameString.get("str_room_no_small_trumpet"))
			end
		elseif self.m_curType == 3 then
			if self.m_bTrumpetCount > 0 then
				g_EventDispatcher:dispatch(g_SceneEvent.ROOM_CHAT_BIG_TRUMPET, text);
				self:hidden()
			else 
				self:showTips(GameString.get("str_room_no_big_trumpet"))
			end
		end	
	end
end

function ChatPop:onBtnBuySpeakerClick()
	local StoreConfig = import("app.scenes.store").StoreConfig
	g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_PROPS_PAGE)
end
--------------------------click function end-------------------


return ChatPop;