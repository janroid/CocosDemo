--[[--ldoc 修改私人房密码视图
@module MotifyPasswordView
@author:LoyalwindPeng
 date: 2018-12-26
]]

local ViewBase = cc.load("mvc").ViewBase;
local MotifyPasswordView = class("MotifyPasswordView", ViewBase)

MotifyPasswordView.s_eventFuncMap = {
    [g_SceneEvent.PRIVATE_ROOM_GET_PWD_RESPONSE] = "privateHallGetPwdResponse";
}

function MotifyPasswordView:ctor(closeFunc, confirmFunc)
    ViewBase.ctor(self)
    self.m_closeFunc = closeFunc
    self.m_confirmFunc = confirmFunc
    self:initRoot()
    self:initUI()
    self:initString()
    self:initListener()
end

function MotifyPasswordView:initRoot()
    if not self.m_root then
        self.m_root = g_NodeUtils:getRootNodeInCreator('creator/privateHall/motifyPassword.ccreator')
        self:addChild(self.m_root)
    end
end

function MotifyPasswordView:initUI()
    self.m_closeBtn       = g_NodeUtils: seekNodeByName(self.m_root, 'closeBtn')
    self.m_titleLabel     = g_NodeUtils: seekNodeByName(self.m_root, 'titleLabel')

    local oldPwdContainer = g_NodeUtils: seekNodeByName(self.m_root,'oldPwdContainer');
    self.m_oldPwdLabel    = g_NodeUtils: seekNodeByName(oldPwdContainer,'oldPwdLabel');
    self.m_oldPwdTxt      = g_NodeUtils: seekNodeByName(oldPwdContainer,'oldPwdTxt');
    
    local newPwdContainer = g_NodeUtils: seekNodeByName(self.m_root,'newPwdContainer');
    self.m_pwdLabel       = g_NodeUtils: seekNodeByName(newPwdContainer,'pwdLabel');
    self.m_pwdEditbox     = g_NodeUtils: seekNodeByName(newPwdContainer,'pwdEditbox');

    self.m_confirmBtn       = g_NodeUtils: seekNodeByName(self.m_root,'confirmBtn');
    self.m_confirmLabel     = g_NodeUtils: seekNodeByName(self.m_confirmBtn,'confirmLabel');
end

function MotifyPasswordView:initString()
    self.m_titleLabel:   setString(GameString.get("str_private_motify_pwd"))
    self.m_confirmLabel: setString(GameString.get("str_logout_btn_confirm"))
    self.m_oldPwdLabel:  setString(GameString.get("str_private_pwd"))
    self.m_oldPwdTxt:    setString("")
    self.m_pwdLabel:     setString(GameString.get("str_private_input_new_pwd"))
    self.m_pwdEditbox:   setPlaceHolder(GameString.get("str_private_motify_pwd_placeholder"))
    self.m_pwdEditbox:setPlaceholderFontSize(g_AppManager:getAdaptiveConfig().PrivateRoom.MotifyPwdPlaceholderFontSize or 20)
end

function MotifyPasswordView:initListener()
    -- 关闭
    self.m_closeBtn:addClickEventListener(handler(self, self.onClose))
    -- 修改密码
    self.m_confirmBtn:addClickEventListener(handler(self, self.onConfirm))
end

--@desc: override, 为了注册和取消注册事件
--@isVisible: bool
--@tid: 房间ID
function MotifyPasswordView:setVisible(isVisible, tid)
    cc.Node.setVisible(self, isVisible)
    if isVisible then
        self:registerEvent()
        self:doLogic(g_SceneEvent.PRIVATE_ROOM_GET_PWD_REQUEST, {["tid"] = tid})
    else
        self:unRegisterEvent()
    end
end

function MotifyPasswordView:onClose()
    self.m_pwdEditbox:setText("") -- 清空输入
    self.m_oldPwdTxt:setString("")
    self.m_closeFunc()
end

function MotifyPasswordView:onConfirm()
    local password = self.m_pwdEditbox:getText() or ""
    -- 密码校验
    if (not g_StringUtils.isOnlyNumberOrChar(password)) or #password > 16 then 
        g_AlarmTips.getInstance():setText(GameString.get("str_private_pwd_format_err")):show()
        return
    end

    self.m_pwdEditbox:setText("") -- 清空输入
    self.m_oldPwdTxt:setString("")
    local param = {password = password}
    self:doLogic(g_SceneEvent.PRIVATE_ROOM_MOTIFY_PWD_REQUEST, param)
    self.m_confirmFunc(param)
end

function MotifyPasswordView:privateHallGetPwdResponse(password)
    password = password or ""
    self.m_oldPwdTxt:setString(password)
end

return  MotifyPasswordView