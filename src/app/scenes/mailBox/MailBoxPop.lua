local PopupBase = import("app.common.popup").PopupBase
local TabarView  = import("app.common.customUI").TabarView
local MailBoxSysCell = require(".MailBoxSysCell")
local MailBoxMailCell = require(".MailBoxMailCell")
local MailRewardAnim = import("app.common.animation").RewardAnim

local MailBoxPop = class("MailBoxPop",PopupBase)

function MailBoxPop:ctor(data)
    PopupBase.ctor(self)
    self.m_isHaveReward = false -- 是否有獎勵
    self.m_isHaveNewMessage = false  -- 是否有新的系統消息
    self:bindCtr(require(".MailBoxCtr"));
    self:init(data)
end

MailBoxPop.s_eventFuncMap =  {
    [g_SceneEvent.MAILBOX_EVENT_REQUEST_DATA_SUCCESS]		 	 	= "requestMailBoxDataSuccess";
    [g_SceneEvent.MAILBOX_EVENT_GET_ATTACH_SUCCESS]                 = "onGetAttachSuccess";
};

function MailBoxPop:show()
    PopupBase.show(self)
    self:requestMailBoxData()
end
function MailBoxPop:hidden()
    PopupBase.hidden(self)
    self.m_isHaveReward = false
    self.m_isHaveNewMessage = false
    self:updateRedTipsVisible()
end

function MailBoxPop:init(data)
    self:loadLayout('creator/mailBox/layout/mailbox.ccreator')
    self.m_imgBG      = g_NodeUtils:seekNodeByName(self,'img_bg')
    self.m_imgTitle   = g_NodeUtils:seekNodeByName(self, "img_title")
    self.m_close      = g_NodeUtils:seekNodeByName(self,'btn_close')
    self.m_imgTabBg   = g_NodeUtils:seekNodeByName(self,'img_tab_bg')
    self.m_nodeMailBg = g_NodeUtils:seekNodeByName(self,'node_mail')
    self.m_nodeSysBg  = g_NodeUtils:seekNodeByName(self,'node_sys')
    self.m_nullMailBg = g_NodeUtils:seekNodeByName(self,'null_mail_bg')
    self.m_nullSysBg  = g_NodeUtils:seekNodeByName(self,'null_sys_bg')
    self.m_txtRemainDate  = g_NodeUtils:seekNodeByName(self,'txt_remain_date')
    self.m_btnOneKeyGet  = g_NodeUtils:seekNodeByName(self,'btn_one_key_get')
    self.m_txtNullMail = g_NodeUtils:seekNodeByName(self, 'null_mail_lab')
    self.m_txtNullSys = g_NodeUtils:seekNodeByName(self, 'null_sys_lab')
    
    self.m_imgTitle:setTexture(switchFilePath('mailBox/mailbox_title.png'))
    self.m_txtNullMail:setString(GameString.get('str_mail_null_mail_message_tip'))
    self.m_txtNullSys:setString(GameString.get('str_mail_null_sys_message_tip'))

    self.m_txtRemainDate:setString(GameString.get("str_mail_remain_date_tip"))

    self.m_txtRemainDate:setVisible(false)
    self.m_btnOneKeyGet:setVisible(false)
    self.m_close:addClickEventListener(function(sender)
		self:hidden()
    end)

    self.m_btnOneKeyGet:addClickEventListener(function(sender)
        self:onOneKeyGetClick()
    end)
    self:initTitle()   
end


function MailBoxPop:initTitle()
    self.m_mailTip = cc.Sprite:create('creator/mailBox/mail_tip.png')
    self.m_sysTip = cc.Sprite:create('creator/mailBox/sys_tip.png')
    self.m_mailTip:setVisible(false)
    self.m_sysTip:setVisible(false)

    local param = {  bgFile = "creator/hall/blank4x4.png", 
                    imageFile = "creator/common/dialog/tab_item_two_bg.png", 
                    tabarSize = {width = 560, height = 55}, 
                    text = {name = GameString.get("str_mail_pop_title"), 
                            fontSize = 24,
                            color = {on = {r = 255, g = 255, b = 255}, off = {r = 215, g = 239, b = 248}},
                            bold = false
                            },
                    index = 1,
                    isMove = true,
                    grid9 = {sx = 120, ex = 120, sy = 20, ey = 20},
                    tabClickCallbackObj = self,
                    tabClickCallbackFunc = self.onTabarClickCallBack
                };
    local tabarView = TabarView:create(param)
    self.m_imgTabBg:addChild(tabarView)
    g_NodeUtils:arrangeToCenter(tabarView)
    self.m_tabarView = tabarView

    local tabS = tabarView:getContentSize()
    self.m_mailTip:setPosition(tabS.width/2 - 60, tabS.height);
    self.m_sysTip:setPosition(tabS.width - 60, tabS.height);
    tabarView:addChild(self.m_mailTip)
    tabarView:addChild(self.m_sysTip)
end

function MailBoxPop:requestMailBoxData()
    g_EventDispatcher:dispatch(g_SceneEvent.MAILBOX_EVENT_REQUEST_DATA);
end

function MailBoxPop:requestMailBoxDataSuccess(data)
    self.m_mailData = data.mailData
    self.m_sysData = data.sysData
    self:updateView()
end

function MailBoxPop:updateView()
    
    if g_TableLib.isEmpty(self.m_mailData) then
        if self.m_mailTableView then
            self.m_mailTableView:removeFromParent()
            self.m_mailTableView = nil
        end
        self.m_nullMailBg:setVisible(true)
        self.m_txtRemainDate:setVisible(false)
        self.m_btnOneKeyGet:setVisible(false)
        self.m_isHaveReward = false
    else
        for i,v in pairs(self.m_mailData) do
            if v.m_attaches and not g_TableLib.isEmpty(v.m_attaches) and not v.m_hasGetAttaches then
                self.m_isHaveReward = true
                break;
            end
        end 
        if not self.m_mailTableView then
            self:createMailTableView()
        else
            self.m_mailTableView:reloadData()
        end
        self.m_nullMailBg:setVisible(false)
        self.m_txtRemainDate:setVisible(true)
    end
    
    if g_TableLib.isEmpty(self.m_sysData) then
        if self.m_sysTableView then
            self.m_sysTableView:removeFromParent()
            self.m_sysTableView = nil
        end
        self.m_nullSysBg:setVisible(true)
        self.m_isHaveNewMessage = false
    else
        for i,v in pairs(self.m_mailData) do
            if not v.m_hasReaded then
                self.m_isHaveNewMessage = true
                break;
            end
        end
        if not self.m_sysTableView then
            self:createSysTableView()
        else
            self.m_sysTableView:reloadData()
        end
        self.m_nullSysBg:setVisible(false)
    end
    
    local index = self.m_tabarView:getCurrentIndex()
    if index == 2 then -- 当前选中的是系统消息，默认系统消息已读
        self.m_isHaveNewMessage = false
    end
    self:updateRedTipsVisible()
end

function MailBoxPop:updateRedTipsVisible()
    self.m_mailTip:setVisible(self.m_isHaveReward)
    self.m_sysTip:setVisible(self.m_isHaveNewMessage)
end

function MailBoxPop:createMailTableView()
    local mailTableWidth = 823
    local mailTableHeight = 380   -- 291 一鍵領取可見時
    local mailTableCellHeigth = 134
    self.isOneKeyGet = false
    if self.isOneKeyGet then
        mailTableHeight = 291  -- 一鍵領取可見時
    end
    self.m_mailTableView = cc.TableView:create(cc.size(mailTableWidth,mailTableHeight))
    self.m_mailTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_mailTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    local x = self.m_nodeMailBg:getContentSize().width/2 - mailTableWidth/2
    local y = self.m_nodeMailBg:getContentSize().height/2 - mailTableHeight/2 -- +40
    if self.isOneKeyGet then
        y = self.m_nodeMailBg:getContentSize().height/2 - mailTableHeight/2 + 40
    end
    self.m_mailTableView:setPosition(cc.p(x,y))
    self.m_mailTableView:setDelegate()
    self.m_nodeMailBg:addChild(self.m_mailTableView)

    local function cellSizeForTable(view,idx)
        return mailTableWidth, mailTableCellHeigth
    end

    local function numberOfCellsInTableView(view)
        return #self.m_mailData
    end

    local function tableCellAtIndex(view,idx)
        local data = self.m_mailData[idx + 1]
        local cell = view:dequeueCell()
        if not cell then
            cell = MailBoxMailCell:create()
        end
        cell:updateCell(data)
        return cell
    end
    self.m_mailTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_mailTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_mailTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_mailTableView:reloadData()
end

function MailBoxPop:createSysTableView()
    local sysTableWidth = 823
    local sysTableHeight = 391   
    local sysTableCellHeigth = 185   
    self.m_sysTableView = cc.TableView:create(cc.size(sysTableWidth,sysTableHeight))
    self.m_sysTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)    
    self.m_sysTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    local x = self.m_nodeSysBg:getContentSize().width/2 - sysTableWidth/2
    local y = self.m_nodeSysBg:getContentSize().height/2 - sysTableHeight/2 + 10
    self.m_sysTableView:setPosition(cc.p(x,y))
    self.m_sysTableView:setDelegate()
    self.m_nodeSysBg:addChild(self.m_sysTableView)

    local function cellSizeForTable(view,idx)
        return sysTableWidth, sysTableCellHeigth
    end

    local function numberOfCellsInTableView(view)
        return #self.m_sysData
    end

    local function tableCellAtIndex(view,idx)
        local data = self.m_sysData[idx + 1]
        local cell = view:dequeueCell()
        if not cell then
            cell = MailBoxSysCell:create()
        end
        cell:updateCell(data)
        return cell
    end
    self.m_sysTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.m_sysTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.m_sysTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.m_sysTableView:reloadData()
end

function MailBoxPop:onTabarClickCallBack(index)
    if 1 == index then
        self.m_nodeMailBg:setVisible(true)
        self.m_nodeSysBg:setVisible(false)
        self.m_mailTip:setVisible(false)
        self.m_isHaveReward = false
    elseif 2 == index then
        self.m_nodeMailBg:setVisible(false)
        self.m_nodeSysBg:setVisible(true)
        self.m_isHaveNewMessage = false
    end
    
    self:updateRedTipsVisible()
end

function MailBoxPop:onOneKeyGetClick()
    g_EventDispatcher:dispatch(g_SceneEvent.MAILBOX_EVENT_GET_ATTACH,-1)
end


function MailBoxPop:onGetAttachSuccess(data)
    Log.d("MailBoxPop:onGetAttachSuccess",data)
    local mailRewardAnim = MailRewardAnim:create(data)
    mailRewardAnim:run()
    -- mailRewardAnim:setData(data)
    -- 更新郵件紅色提示
    if g_TableLib.isEmpty(self.m_mailData) then
        self.m_isHaveReward = false
    else
        for i,v in pairs(self.m_mailData) do
            if v.m_attaches and not g_TableLib.isEmpty(v.m_attaches) and not v.m_hasGetAttaches then
                self.m_isHaveReward = true
                break;
            end
        end 
    end
    self:updateRedTipsVisible()
end

function MailBoxPop:dtor()

end

function MailBoxPop:onCleanup()
    PopupBase.onCleanup(self)
end

return MailBoxPop