--[[--ldoc desc
@module InputPasswordView
@author:LoyalwindPeng
 date: 2018-12-26
]]
local ViewBase = cc.load("mvc").ViewBase;
local InputPasswordView = class("InputPasswordView", ViewBase)

function InputPasswordView:ctor(closeFunc, confirmFunc)
    ViewBase.ctor(self)
    self.m_closeFunc = closeFunc
    self.m_confirmFunc = confirmFunc
    self:initRoot()
    self:initUI()
    self:initString()
    self:initListener()
end

-- @desc: 获取添加root
function InputPasswordView:initRoot()
    if not self.m_root then
        self.m_root = g_NodeUtils:getRootNodeInCreator('creator/privateHall/inputPassword.ccreator')
        self:addChild(self.m_root)
    end
end

function InputPasswordView:initUI()
    self.m_closeBtn         = g_NodeUtils: seekNodeByName(self.m_root, 'closeBtn')
    self.m_titleLabel       = g_NodeUtils: seekNodeByName(self.m_root, 'titleLabel')
    self.m_descriptionLabel = g_NodeUtils: seekNodeByName(self.m_root,'descriptionLabel');
    self.m_pwdEditbox       = g_NodeUtils: seekNodeByName(self.m_root,'pwdEditbox');
    self.m_confirmBtn       = g_NodeUtils: seekNodeByName(self.m_root,'confirmBtn');
    self.m_confirmLabel     = g_NodeUtils: seekNodeByName(self.m_root,'confirmLabel');
end

function InputPasswordView:initString()
    self.m_titleLabel:   setString(GameString.get("enter_psd"))
    self.m_confirmLabel: setString(GameString.get("str_logout_btn_confirm"))
    self.m_descriptionLabel: setString(string.format(GameString.get("str_private_pwd_input_tips"), 0))
    self.m_pwdEditbox:   setPlaceHolder(GameString.get("str_private_input_pwd_placeholder"))
end

function InputPasswordView:initListener()
    self.m_closeBtn:addClickEventListener(handler(self, self.m_closeFunc))
    self.m_confirmBtn:addClickEventListener(handler(self, self.onConfirm))
end

--@desc: override
--@isVisible: bool
--@data: table:房间信息 {tid=xxx, ip=xxx, port=xxx, flag =xxx}
function InputPasswordView:setVisible(isVisible, data)
    cc.Node.setVisible(self, isVisible)
    if isVisible then
        self.m_data = data
        self.m_descriptionLabel: setString(string.format(GameString.get("str_private_pwd_input_tips"), self.m_data.tid or 0))
    end
end

function InputPasswordView:onClose()
    self.m_pwdEditbox:setText("")
    self.m_closeFunc()
end

function InputPasswordView:onConfirm()
    local password = self.m_pwdEditbox:getText() or ""
    if (not g_StringUtils.isOnlyNumberOrChar(password)) or #password > 16 then 
        g_AlarmTips.getInstance():setText(GameString.get("str_private_pwd_format_err")):show()
        return
    end
    self.m_data.password = password
    self.m_pwdEditbox:setText("") -- 清空输入
    self:doLogic(g_SceneEvent.PRIVATE_ROOM_CHECK_PASSWORD, self.m_data)
    self.m_confirmFunc(self.m_data)
end

return  InputPasswordView