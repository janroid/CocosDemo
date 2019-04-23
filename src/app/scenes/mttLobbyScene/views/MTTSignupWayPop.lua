
----------------------------- cell ----------------------------------------------------

local MTTSignupWayCell  = class("MTTSignupWayCell",cc.TableViewCell)

MTTSignupWayCell.ctor = function(self)  
    self:init()
end

MTTSignupWayCell.init = function(self)

    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/mttLobbyScene/layout/mttSignupWayCell.ccreator')
    self:addChild(self.m_root)
    self.m_iconSignUp    = g_NodeUtils:seekNodeByName(self.m_root,"iconSignUp")
    self.m_txSignUpMoney = g_NodeUtils:seekNodeByName(self.m_root,"txSignUpMoney")
    self.m_txOwn         = g_NodeUtils:seekNodeByName(self.m_root,"txOwn")
    self.m_btnChose      = g_NodeUtils:seekNodeByName(self.m_root,"btnChose")
	self.m_btnChose:setVisible(false)
end

MTTSignupWayCell.updateCell = function(self,sign,isSel,data)
	self.matchData = data
    self:onCellTouch(isSel)
    local str = ""
    local strNum = ""
    local file = "creator/common/icon/icon_chip.png"
    local w = 66
    if tonumber(sign) == 1 then --筹码
		local arr = g_StringLib.split(data.chips,"|");
		if arr[2] and arr[2] ~= 0 then
			str = g_MoneyUtil.formatMoney(tonumber(arr[1])) .. " + " .. g_MoneyUtil.formatMoney(tonumber(arr[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr[1]));
        end
        str = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_chip"),str) 
        file = "creator/common/icon/icon_chip.png"
        w = 58
        strNum = g_AccountInfo:getMoney()
        strNum = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_chip1"),g_MoneyUtil.formatMoney(strNum))

    elseif tonumber(sign) == 2 then	--卡拉币
		local arr1 = g_StringLib.split(data.coalaa,"|");
		if arr1[2] and arr1[2] ~= 0 then
			str =  g_MoneyUtil.formatMoney(tonumber(arr1[1])) .. " + " ..  g_MoneyUtil.formatMoney(tonumber(arr1[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr1[1]));
        end
        str = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_coin"),str) 
        file = "creator/common/icon/icon_coin.png"
        w = 58
        strNum = g_AccountInfo:getUserCoalaa()
        strNum = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_coin1"),strNum)

    elseif tonumber(sign) == 3 then--积分
        file = "creator/mttLobbyScene/imgs/lobby/iconBigCup.png"
        str = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_point"),tostring(data.point)) 
        strNum = g_AccountInfo:getScore()
        strNum = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_point1"),strNum)

    elseif tonumber(sign) == 4 then--门票

        file = "creator/mttLobbyScene/imgs/lobby/iconBigTickt.png"
        str = g_StringLib.substitute(GameString.get("str_new_mtt_apply_ticket")," 1") 
        local allTicket = g_AccountInfo:getATicket()
        if allTicket and not g_TableLib.isEmpty(allTicket) then
            for key, value in pairs(allTicket) do
                if data and tostring(data.ticketType) == tostring(key) then
                    strNum = g_StringLib.substitute(GameString.get("str_new_mtt_list_my_ticket"),value)
                end
            end
        end
    else
        str = GameString.get("str_new_mtt_list_free")
        strNum = GameString.get("str_new_mtt_list_free")
        w = 58
    end
    
    self.m_txSignUpMoney:setString(str)
    self.m_txOwn:setString("("..strNum..")")
    self.m_iconSignUp:setTexture(file)
    self.m_iconSignUp:setContentSize(cc.size(w,58))
end

MTTSignupWayCell.onCellTouch = function(self,isSel)
	self.m_btnChose:setVisible(isSel)
end



----------- pop ------------------------------------------------------

local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local MTTSignupWayPop = class("MTTSignupWayPop",PopupBase);
BehaviorExtend(MTTSignupWayPop);

function MTTSignupWayPop:ctor(data,list)
	PopupBase.ctor(self);
	self:bindCtr(require(".views.MTTSignupWayCtr"))  
	self:loadLayout('creator/mttLobbyScene/layout/mttSignupWayPop.ccreator')
    self.m_content    = g_NodeUtils:seekNodeByName(self.m_root,"content")
    g_NodeUtils:seekNodeByName(self.m_root,"alert_title"):setString(GameString.get("str_new_mtt_hall_label4"))
    g_NodeUtils:seekNodeByName(self.m_root,"btn_center_txt"):setString(GameString.get("str_new_mtt_list_apply"))
    g_NodeUtils:seekNodeByName(self.m_root,"btn_close"):addClickEventListener(function(sender) self:hidden() end)
    g_NodeUtils:seekNodeByName(self.m_root,"bg"):addClickEventListener(function(sender) end)
	g_NodeUtils:seekNodeByName(self.m_root,"pop_transparency_bg"):addClickEventListener(function(sender) self:hidden() end)
    g_NodeUtils:seekNodeByName(self.m_root,"btn_center"):addClickEventListener(function(sender) self:onBtnSignupClick() end)
	self.m_payList = {}
	self:createTableView()
end

function MTTSignupWayPop:createTableView()
    local tableW = self.m_content:getContentSize().width 
    local tableH = self.m_content:getContentSize().height   
    local cellH = 98
	-- ccui.Button
    self.m_tableView = cc.TableView:create(cc.size(tableW,tableH))
    self.m_tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
	self.m_tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)

    self.m_tableView:setPosition(cc.p(0,0))
    self.m_tableView:setDelegate()
    self.m_content:addChild(self.m_tableView)

    local function cellSizeForTable(view,idx)
        return tableW, cellH
    end
    local function numberOfCellsInTableView(view)
        return #self.m_payList
	end
	
    local function tableCellAtIndex(view,idx)
        local data = self.m_payList[idx + 1]
        local cell = view:dequeueCell()
        if not cell then
            cell = MTTSignupWayCell:create()
		end
        cell:updateCell(data,view.curentSelectCellIdx==idx,self.m_matchData)
        return cell
    end
    --cell点击事件
    local function ontableViewCellTouch(table,cell)
        if table.curentSelectCellIdx == cell:getIdx() then return end
        if table.curentSelectCellIdx == nil then
            table.curentSelectCellIdx = 0
        end
        local selCell = self.m_tableView:cellAtIndex(table.curentSelectCellIdx+1)
        if selCell then
            selCell:onCellTouch(false)
        end
        table.curentSelectCellIdx = cell:getIdx()
        cell:onCellTouch(true)
        local size = table:getContentOffset()
        table:reloadData()
        table:setContentOffset(cc.p(size.x,size.y))
    end
    self.m_tableView:setBounceable(true)
    self.m_tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_tableView:registerScriptHandler(ontableViewCellTouch, cc.TABLECELL_TOUCHED)
    self.m_tableView:reloadData()

    self.m_tableView.curentSelectCellIdx = 0
    local selCell = self.m_tableView:cellAtIndex(self.m_tableView.curentSelectCellIdx)
    if selCell then
        selCell:onCellTouch(true)
    end  
end

function MTTSignupWayPop:updateUI(list)
	self.m_payList = list
	self.m_tableView:reloadData()
end

function MTTSignupWayPop:onBtnSignupClick(list)
    local idx = self.m_tableView.curentSelectCellIdx+1
    g_EventDispatcher:dispatch(g_SceneEvent.MTT_APPLY_REQUEST,{mid = self.m_matchData.mid,time = self.m_matchData.time,payType = self.m_payList[idx]})
	self:hidden()
end

function MTTSignupWayPop:show(data,list)
	self.m_matchData = data
    self:updateUI(list)
	PopupBase.show(self)
end

function MTTSignupWayPop:hidden()
	PopupBase.hidden(self)
end


return MTTSignupWayPop