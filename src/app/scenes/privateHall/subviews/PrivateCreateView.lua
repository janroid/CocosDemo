--[[--ldoc 创建私人房视图
@module PrivateCreateView
@author:LoyalwindPeng
 date: 2018-12-26
]]

local ViewBase = cc.load("mvc").ViewBase;
local PrivateCreateView = class("PrivateCreateView", ViewBase)
local BlindCarryItem = require("subviews.BlindCarryItem")

PrivateCreateView.RoomType = {
    Primary = 2;
    Medium  = 3;
    Senior  = 4;
}

PrivateCreateView.Player = {
    Five = 5;
    Nine = 9;
}

PrivateCreateView.Speed = {
    Quickly = 10;
    Normal  = 20;
}
PrivateCreateView.TBFrame = {
    x = 0;
    y = 10;
    width = 666;
    height = 190;
}

PrivateCreateView.s_eventFuncMap = {
    [g_SceneEvent.PRIVATE_HALL_CFG_RESPONSE] = "privateHallCfgResponse";
}

function PrivateCreateView:ctor(closeFunc, createFunc)
    ViewBase.ctor(self)
    self.m_closeFunc = closeFunc
    self.m_createFunc = createFunc
    self.m_blindCarryAllDatas = {
        [PrivateCreateView.RoomType.Primary] = {};
        [PrivateCreateView.RoomType.Medium]  = {};
        [PrivateCreateView.RoomType.Senior]  = {};
    }
    self.m_blindCarryListData = {}
    self.m_blindCarrySelectedData = {}

    self:initRoot()
	self:initUI()
    self:initString()
    self:initListener()
    -- 请求盲注携带配置数据
    self:doLogic(g_SceneEvent.PRIVATE_HALL_CFG_REQUEST)
end

-- @desc: 获取添加root
function PrivateCreateView:initRoot()
    if not self.m_root then   
        self.m_root = g_NodeUtils:getRootNodeInCreator("creator/privateHall/privateCreate.ccreator")
        self:addChild(self.m_root)
    end
end

-- @desc: 初始化UI
function PrivateCreateView:initUI()
    -- 顶部关闭按钮和，标题
    self.m_closeBtn = g_NodeUtils:seekNodeByName(self.m_root, 'closeBtn')
    self.m_titleLabel = g_NodeUtils:seekNodeByName(self.m_root, 'titleLabel')
    
    -- 中间容器
    local midContainer    = g_NodeUtils: seekNodeByName(self.m_root, 'midContainer')
    local nameContainer   = g_NodeUtils: seekNodeByName(midContainer, 'nameContainer')
    local typeContainer   = g_NodeUtils: seekNodeByName(midContainer, 'typeContainer')
    local blindContainer  = g_NodeUtils: seekNodeByName(midContainer, 'blindContainer')
    local playerContainer = g_NodeUtils: seekNodeByName(midContainer, 'playerContainer')
    local speedContainer  = g_NodeUtils: seekNodeByName(midContainer, 'speedContainer')
    local pwdContainer    = g_NodeUtils: seekNodeByName(midContainer, 'pwdContainer')

    -- 1房间名称
    self.m_roomNameLabel = g_NodeUtils: seekNodeByName(nameContainer, 'roomNameLabel')
    self.m_nameLabel     = g_NodeUtils: seekNodeByName(nameContainer, 'nameLabel')

    -- 2房间类型，初级，中级，高级
    self.m_roomTypeLabel = g_NodeUtils: seekNodeByName(typeContainer, 'roomTypeLabel')
    self.m_typeToggle    = g_NodeUtils: seekNodeByName(typeContainer, 'typeToggle')
    self.m_primaryLabel  = g_NodeUtils: seekNodeByName(self.m_typeToggle, 'primaryLabel')
    self.m_mediumLabel   = g_NodeUtils: seekNodeByName(self.m_typeToggle, 'mediumLabel')
    self.m_seniorLabel   = g_NodeUtils: seekNodeByName(self.m_typeToggle, 'seniorLabel')
    
    -- 3携带盲注
    self.m_blindLabel      = g_NodeUtils: seekNodeByName(blindContainer, 'blindLabel')
    self.m_blindSelectBtn  = g_NodeUtils: seekNodeByName(blindContainer, 'blindSelectBtn')
    self.m_tableViewBgMask = g_NodeUtils: seekNodeByName(blindContainer, 'tableViewBgMask')
    self.m_tableViewBg     = g_NodeUtils: seekNodeByName(self.m_tableViewBgMask, 'tableViewBg')
    self.m_blindTxt        = g_NodeUtils: seekNodeByName(self.m_blindSelectBtn, 'blindTxt')
    self.m_carryTxt        = g_NodeUtils: seekNodeByName(self.m_blindSelectBtn, 'carryTxt')
    self.m_arrowImg        = g_NodeUtils: seekNodeByName(self.m_blindSelectBtn, 'arrowImg')
    self.m_tableViewBgMask: setVisible(false)
    blindContainer:     setLocalZOrder(1)

    -- 4玩家人数
    self.m_playerLabel  = g_NodeUtils: seekNodeByName(playerContainer, 'playerLabel')
    self.m_playerToggle = g_NodeUtils: seekNodeByName(playerContainer, 'playerToggle')
    self.m_fiveLabel    = g_NodeUtils: seekNodeByName(self.m_playerToggle, 'fiveLabel')
    self.m_nineLabel    = g_NodeUtils: seekNodeByName(self.m_playerToggle, 'nineLabel')

    -- 5出牌速度
    self.m_speedLabel   = g_NodeUtils: seekNodeByName(speedContainer, 'speedLabel')
    self.m_speedToggle  = g_NodeUtils: seekNodeByName(speedContainer, 'speedToggle')
    self.m_quicklyLabel = g_NodeUtils: seekNodeByName(self.m_speedToggle, 'quicklyLabel')
    self.m_normalLabel  = g_NodeUtils: seekNodeByName(self.m_speedToggle, 'normalLabel')

    -- 6房间密码
    self.m_pwdLabel   = g_NodeUtils: seekNodeByName(pwdContainer, 'pwdLabel')
    self.m_pwdEditbox = g_NodeUtils: seekNodeByName(pwdContainer, 'pwdEditbox')

    -- 底部按钮容器
    local bottomContainer = g_NodeUtils: seekNodeByName(self.m_root, 'bottomContainer')
    self.m_backBtn        = g_NodeUtils: seekNodeByName(bottomContainer, 'backBtn')
    self.m_createBtn      = g_NodeUtils: seekNodeByName(bottomContainer, 'createBtn')
    self.m_backLabel      = g_NodeUtils: seekNodeByName(self.m_backBtn, 'backLabel')
    self.m_createLabel    = g_NodeUtils: seekNodeByName(self.m_createBtn, 'createLabel')

end

-- @desc: 初始化字符串显示
function PrivateCreateView:initString()
    
    self.m_titleLabel:setString(GameString.get("str_private_create_title"))
    self.m_roomNameLabel:setString(GameString.get("str_private_create_name"))
    local roomname = string.format(GameString.get("str_private_create_name_desc"), g_AccountInfo:getNickName() or "")
    self.m_nameLabel :setString(roomname)
    
    self.m_roomTypeLabel: setString(GameString.get("str_private_create_type"))
    self.m_primaryLabel:  setString(GameString.get("str_normal_selections_low_rank"))
    self.m_mediumLabel:   setString(GameString.get("str_normal_selections_middle_rank"))
    self.m_seniorLabel:   setString(GameString.get("str_normal_selections_high_rank"))

    self.m_blindLabel:setString(GameString.get("str_private_create_blind_carry"))
    self:updateBlindAndCarryText()

    self.m_playerLabel: setString(GameString.get("str_private_create_player_num"))
    self.m_fiveLabel:   setString(GameString.get("str_private_player_five"))
    self.m_nineLabel:   setString(GameString.get("str_private_player_nine"))

    self.m_speedLabel:   setString(GameString.get("str_private_create_speed"))
    self.m_quicklyLabel: setString(GameString.get("str_private_speed_quickly"))
    self.m_normalLabel:  setString(GameString.get("str_private_speed_normal"))

    self.m_pwdLabel:setString(GameString.get("str_private_create_password"))
    self.m_pwdEditbox:setPlaceHolder(GameString.get("str_private_motify_pwd_placeholder"))
    
    self.m_backLabel:setString(GameString.get("str_common_back"))
    self.m_createLabel:setString(GameString.get("str_common_confirm"))
end

-- @desc: 初始化事件
function PrivateCreateView:initListener()
    local close = handler(self, self.closePage)

    -- 返回，关闭事件
    self.m_closeBtn:addClickEventListener(close)
    self.m_backBtn:addClickEventListener(close)

    -- 创建私人房事件
    self.m_createBtn:addClickEventListener(handler(self, self.createRoom))

    -- 选择盲注大小事件
    self.m_blindSelectBtn:addClickEventListener(function (sender)
        self:showBlindCarryList(not self.m_showBlindCarryDetail)
    end)

    -- 选择房间类型
    self.m_typeToggle:addEventListener(handler(self, self.roomTypeToggleSelect))
    
    -- 选择房间人数
    self.m_playerToggle:addEventListener(handler(self, self.playerToggleSelect))
    
    -- 选择出牌速度
    self.m_speedToggle:addEventListener(handler(self, self.speedToggleSelect))

    self.m_typeToggle:setSelectedButton(0)
    self.m_playerToggle:setSelectedButton(1)
    self.m_speedToggle:setSelectedButton(0)
end

--@desc: override, 为了注册和取消注册事件
--@isVisible: bool
function PrivateCreateView:setVisible(isVisible)
    cc.Node.setVisible(self, isVisible)
    if isVisible then
        self:registerEvent()
    else
        self:unRegisterEvent()
    end
end

------------------------     点击事件         ----------------------
--@desc: 关闭页面
--@sender: 点击的按钮
function PrivateCreateView:closePage(sender)
    self:showBlindCarryList(false)
    if type(self.m_closeFunc) == "function" then
        self.m_closeFunc()
    end
end

--@desc: 创建房间
--@sender: 点击的按钮
function PrivateCreateView:createRoom(sender)
    assert(type(self.m_createFunc)=="function", "note:[PrivateCreateView.m_createFunc] must be a function")

    local secretCode = self.m_pwdEditbox:getText() or ""
    -- 密码太长, 这里可能有问题，汉字占3个字符，泰语也是
    if (not g_StringUtils.isOnlyNumberOrChar(secretCode)) or #secretCode > 16 then 
        g_AlertDialog.getInstance()
		:setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_private_pwd_format_err"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
		:setCenterBtnTx(GameString.get("str_common_back"))
        :show()
        return
    end

    -- 钱不够
    local money = g_AccountInfo:getMoney() or 0
    local minbring = self.m_blindCarrySelectedData.minbring or 0
    if money < minbring then
        self:closePage()
		g_AlertDialog.getInstance()
		:setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_private_create_buyin_fail"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_common_back"))
		:setRightBtnTx(GameString.get("str_friend_go_to_store"))
        :setRightBtnFunc(function() -- 打開商城進入籌碼頁面
			local StoreConfig = import("app.scenes.store").StoreConfig
		    g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_CHIPS_PAGE)
		end)
        :show()
        return
    end

    -- 去请求建房
    local param = {};
    param.table_name = self.m_nameLabel: getString();
    param.s_blind    = self.m_blindCarrySelectedData.smallblind;
    param.min_bring  = minbring;
    param.max_bring  = self.m_blindCarrySelectedData.maxbring;
    param.field      = self.m_typeSelect;
    param.player_cap = self.m_playerSelect;
    param.bet_time   = self.m_speedSelect;
    param.password   = secretCode;
    self.m_pwdEditbox:setText("")
    self:doLogic(g_SceneEvent.PRIVATE_ROOM_CREATE_REQUEST,param)
    self.m_createFunc(param)
end

--@desc: 选择房间类型
--@sender: 点击的按钮
--@index: 点击的按钮索引位置
function PrivateCreateView:roomTypeToggleSelect(sender, index)
    if index == 0 then
        self.m_typeSelect = PrivateCreateView.RoomType.Primary
    elseif index == 1 then
        self.m_typeSelect = PrivateCreateView.RoomType.Medium
    else
        self.m_typeSelect = PrivateCreateView.RoomType.Senior
    end
    self.m_blindCarryListData = self.m_blindCarryAllDatas[self.m_typeSelect] or {}
    self:updateBlindAndCarryText(self.m_blindCarryListData[1])
    self:updateTableViewIfNeed()
end

--@desc: 选择玩家人数
--@sender: 点击的按钮
--@index: 点击的按钮索引位置
function PrivateCreateView:playerToggleSelect(sender, index)
    if index == 0 then
        self.m_playerSelect = PrivateCreateView.Player.Five
    else
        self.m_playerSelect = PrivateCreateView.Player.Nine
    end
end

--@desc: 选择出牌速度
--@sender: 点击的按钮
--@index: 点击的按钮索引位置
function PrivateCreateView:speedToggleSelect(sender, index)
    if index == 0 then
        self.m_speedSelect = PrivateCreateView.Speed.Quickly
    else
        self.m_speedSelect = PrivateCreateView.Speed.Normal
    end
end

--@desc: 显示盲注携带选择详情视图
--@isShow: bool 显示或隐藏
function PrivateCreateView:showBlindCarryList(isShow)
    if g_TableLib.isEmpty(self.m_blindCarryListData) then 
        self.m_arrowImg:setRotation(0) -- 设置为0°旋转
        return  
    end

    self.m_showBlindCarryDetail = isShow
    self.m_tableViewBgMask:setVisible(true)

    -- 播放动画
    self:playListAnim(isShow)

    -- 如果是隐藏的那么没有必要刷新的
    if not isShow then return end

    if not self.m_tableView then
        -- 创建tableview
        local tableView = cc.TableView:create(cc.size(PrivateCreateView.TBFrame.width, PrivateCreateView.TBFrame.height))
        tableView:setPosition(PrivateCreateView.TBFrame.x, PrivateCreateView.TBFrame.y)
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
        self.m_tableView = tableView
        self.m_tableViewBg:add(tableView)

        tableView:registerScriptHandler(handler(self, self.tablecellSizeForIndex), cc.TABLECELL_SIZE_FOR_INDEX)
        tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
        tableView:registerScriptHandler(handler(self, self.tableCellClickdAtIndex), cc.TABLECELL_TOUCHED)
        tableView:setVisible(true)
        tableView:setDelegate() -- 加上这句后 cc.TABLECELL_TOUCHED 才可以生效
    end

    self.m_tableView:reloadData()
end

function PrivateCreateView:playListAnim(isShow)
    -- 箭头旋转动画
    local arrowAction = cc.RotateTo:create(0.2, (isShow and 180 or 0))
    local sequenceAction = cc.Sequence:create(arrowAction)
    self.m_arrowImg:runAction(sequenceAction)

    -- 列表显示隐藏动画
    local size = self.m_tableViewBgMask:getContentSize()
    local moveAction = cc.MoveTo:create(0.2, cc.p(size.width * 0.5, (isShow and size.height * 0.5 or size.height * 1.5)))
    local actionFunc = cc.CallFunc:create(function()
        self.m_tableViewBgMask:setVisible(isShow)
    end)
    local sequenceAction2 = cc.Sequence:create(moveAction,actionFunc)
    self.m_tableViewBg:runAction(sequenceAction2)
end
---------------- tableView事件方法   ---------------

--@desc: 点击了某个cell
--@tbView: 当前tableView
--@cell: 当前点击的cell
function PrivateCreateView:tableCellClickdAtIndex(tbView, cell)
    
    local idx = cell:getIdx()
    Log.d("tableCellClickdAtIndex:",idx)
    for i,v in ipairs(self.m_blindCarryListData) do
        v.selected = (idx+1 == i)
    end
    self:updateBlindAndCarryText(self.m_blindCarryListData[idx+1])
    -- tbView:reloadData()
    self:showBlindCarryList(false)
end

--@desc:返回idx位置中 cell的size
--@tbview: cc.TableView
--@idx: number
--@return: width, height
function PrivateCreateView:tablecellSizeForIndex(tbview, idx) 
    return PrivateCreateView.TBFrame.width, 38
end

--@desc: --总共多少数据
--@tbview: cc.TableView
--@return: 数据数量
function PrivateCreateView:numberOfCellsInTableView(tbview) 
    return #self.m_blindCarryListData;
end

--@desc: 返回idx位置中的cell
--@tbview: cc.TableView
--@idx: number 
--@return: cc.TableViewCell
function PrivateCreateView:tableCellAtIndex(tbview, idx)
    local blindCarryCfg = self.m_blindCarryListData[idx + 1]
    local cell = tbview:dequeueCell()
    if not cell then
        cell = BlindCarryItem:create()
    end
    cell:updateCell(blindCarryCfg)
    return cell
end

--@desc: 网络请求数据的响应
--@blindCarryCfgDatas: table, 所有数据数组
function PrivateCreateView:privateHallCfgResponse(blindCarryCfgDatas)
    self.m_blindCarryAllDatas = blindCarryCfgDatas or {}
 
    self.m_blindCarryListData = self.m_blindCarryAllDatas[self.m_typeSelect]

    self:updateBlindAndCarryText(self.m_blindCarryListData[1])

    self:updateTableViewIfNeed()
end

-- @desc: 如果需要的话更新tableview数据
function PrivateCreateView:updateTableViewIfNeed()
    if self.m_showBlindCarryDetail and self.m_tableView then
        self.m_tableView:reloadData()
    end
end

--@desc: 更新选中盲注，携带的内容
--@blindCarryCfg: 数据模型
function PrivateCreateView:updateBlindAndCarryText(blindCarryCfg)
    self.m_blindTxt: setVisible(true)
    self.m_carryTxt: setVisible(true)
    blindCarryCfg = blindCarryCfg or {}

    -- 清除之前选中数据选中状态
    self.m_blindCarrySelectedData.selected = false
    -- 记录当前选中的数据
    self.m_blindCarrySelectedData = blindCarryCfg
    -- 记录当前数据为选中状态
    self.m_blindCarrySelectedData.selected = true
    
    -- 安全处理
    blindCarryCfg.smallblind = blindCarryCfg.smallblind or 0
    local smallBlind = g_MoneyUtil.formatMoney(blindCarryCfg.smallblind)
    local bigBlind   = g_MoneyUtil.formatMoney(blindCarryCfg.smallblind*2)
    local minbring   = g_MoneyUtil.formatMoney(blindCarryCfg.minbring)
    local maxbring   = g_MoneyUtil.formatMoney(blindCarryCfg.maxbring)

    self.m_blindTxt:setString(string.format(GameString.get("str_private_create_blind_num"),smallBlind, bigBlind))
    self.m_carryTxt:setString(string.format(GameString.get("str_private_create_carry_num"), minbring, maxbring))
end

return  PrivateCreateView