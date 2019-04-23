--[[--ldoc desc
@module SuccessCreateView
@author:LoyalwindPeng
 date: 2018-12-26
]]
local ViewBase = cc.load("mvc").ViewBase;
local SuccessCreateView = class("SuccessCreateView", ViewBase)

function SuccessCreateView:ctor(closeFunc, confirmFunc)
    ViewBase.ctor(self)
    self.m_closeFunc = closeFunc
    self.m_confirmFunc = confirmFunc
    self:initRoot()
    self:initUI()
    self:initString()
    self:initListener()
end

-- @desc: 获取添加root
function SuccessCreateView:initRoot()
    if not self.m_root then
        self.m_root = g_NodeUtils:getRootNodeInCreator('creator/privateHall/successCreate.ccreator')
        self:addChild(self.m_root)
    end
end

function SuccessCreateView:initUI()
    self.m_closeBtn     = g_NodeUtils: seekNodeByName(self.m_root, 'closeBtn')
    self.m_titleLabel   = g_NodeUtils: seekNodeByName(self.m_root, 'titleLabel')
    self.m_successLabel = g_NodeUtils: seekNodeByName(self.m_root, 'successLabel');
    self.m_roomIDLabel  = g_NodeUtils: seekNodeByName(self.m_root, 'roomIDLabel');
    
    self.m_descriptionLabel = g_NodeUtils: seekNodeByName(self.m_root,'descriptionLabel');
    self.m_confirmBtn       = g_NodeUtils: seekNodeByName(self.m_root,'confirmBtn');
    self.m_confirmLabel     = g_NodeUtils: seekNodeByName(self.m_confirmBtn,'confirmLabel');
end

function SuccessCreateView:initString()
    self.m_titleLabel:   setString(GameString.get("str_private_create_success_title"))
    self.m_confirmLabel: setString(GameString.get("str_logout_btn_confirm"))
    self.m_successLabel: setString(GameString.get("str_private_create_success"))
    self.m_roomIDLabel:  setString(string.format(GameString.get("str_private_room_id"), 0))
    self.m_descriptionLabel:  setString(GameString.get("str_private_create_success_desc"))
end

function SuccessCreateView:initListener()
    -- 关闭
    self.m_closeBtn:addClickEventListener(self.m_closeFunc)
    -- 确定
    self.m_confirmBtn:addClickEventListener(self.m_confirmFunc)
end

--@desc: override
--@isVisible: bool
--@tid: 房間id
function SuccessCreateView:setVisible(isVisible, tid)
    cc.Node.setVisible(self, isVisible)
    self.m_roomIDLabel: setString(string.format(GameString.get("str_private_room_id"), tid or 0))
end

return  SuccessCreateView