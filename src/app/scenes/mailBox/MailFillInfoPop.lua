local PopupBase = import("app.common.popup").PopupBase
local MailFillInfoPop = class("MailFillInfoPop",PopupBase)

function MailFillInfoPop:ctor()
    PopupBase.ctor(self)
    self:initScene()
    self:initEvent()
    self:initString()
end

MailFillInfoPop.s_eventFuncMap =  {
};

function MailFillInfoPop:show()
    PopupBase.show(self)
end

function MailFillInfoPop:initScene()
    self:loadLayout('creator/mailBox/layout/mailbox_fill_info_pop.ccreator')
    self.m_transBg = g_NodeUtils:seekNodeByName(self,"pop_transparency_bg")
    self.m_imgBG = g_NodeUtils:seekNodeByName(self,"img_bg")
    self.m_btnClose = g_NodeUtils:seekNodeByName(self,"btn_close")

    self.m_nodeEdit = g_NodeUtils:seekNodeByName(self,"node_edit")
    self.m_etMail= g_NodeUtils:seekNodeByName(self,"edit_mail")
    self.m_etPhone= g_NodeUtils:seekNodeByName(self,"edit_phone")
    self.m_mailWarm= g_NodeUtils:seekNodeByName(self,"mail_warm")
    self.m_phoneWarm= g_NodeUtils:seekNodeByName(self,"phone_warm")
    self.m_btnCommit= g_NodeUtils:seekNodeByName(self,"btn_commit")
    self.m_labelCommit= g_NodeUtils:seekNodeByName(self,"lab_commit")

    self.m_nodeConfirm= g_NodeUtils:seekNodeByName(self,"node_confirm")
    self.m_labelMail= g_NodeUtils:seekNodeByName(self,"lab_mail")
    self.m_mailIcon= g_NodeUtils:seekNodeByName(self,"detail_mail_icon")
    self.m_labelPhone= g_NodeUtils:seekNodeByName(self,"lab_phone")
    self.m_phoneIcon= g_NodeUtils:seekNodeByName(self,"detail_phone_icon")
    self.m_btnBack= g_NodeUtils:seekNodeByName(self,"btn_back")
    self.m_labelBack= g_NodeUtils:seekNodeByName(self,"lab_back")
    self.m_btnConfirm= g_NodeUtils:seekNodeByName(self,"btn_confirm")
    self.m_labelConfirm= g_NodeUtils:seekNodeByName(self,"lab_confirm")

    self.m_nodeEdit:setVisible(true)
    self.m_nodeConfirm:setVisible(false)
    
end

function MailFillInfoPop:initString()
    self.m_etMail:setPlaceHolder(GameString.get("str_fill_mail"))
    self.m_etPhone:setPlaceHolder(GameString.get("str_fill_phone"))
    self.m_labelCommit:setString(GameString.get("str_change_pwd_commit"))
    self.m_labelBack:setString(GameString.get("str_common_back"))
    self.m_labelConfirm:setString(GameString.get("str_logout_btn_confirm"))
end

function MailFillInfoPop:initEvent()
    self.m_imgBG:addClickEventListener(function()  end)
    self.m_transBg:addClickEventListener(function() self:hidden() end)
    self.m_btnClose:addClickEventListener(function() self:hidden() end)
    self.m_etMail:registerScriptEditBoxHandler(
		function(eventType)
			if eventType == "ended" then
				self:judgeMail()
			end
		end
	)
	self.m_etPhone:registerScriptEditBoxHandler(
		function(eventType)
			if eventType == "ended" then
				self:judgePhone()
			end
		end
    )
    self.m_btnCommit:addClickEventListener(function()  
        self:onCommitClick()
    end)

    self.m_btnBack:addClickEventListener(function()  
        self:onBackClick()
    end)

    self.m_btnConfirm:addClickEventListener(function()  
        self:hidden()
    end)

end

-- 提交
function MailFillInfoPop:onCommitClick()
    local mailCorrect = self:judgeMail()
    local phoneCorrect = self:judgePhone()

    if mailCorrect and phoneCorrect then
        self:onCommitResponse()
    end
end

function MailFillInfoPop:onBackClick()
    self.m_nodeEdit:setVisible(true)
    self.m_nodeConfirm:setVisible(false)
end

function  MailFillInfoPop:onCommitResponse(data)
    self.m_nodeEdit:setVisible(false)
    self.m_nodeConfirm:setVisible(true)
    self.m_labelMail:setString(string.format(GameString.get("str_mail"),self.m_etMail:getText()))
    self.m_labelPhone:setString(string.format(GameString.get("str_phone"),self.m_etPhone:getText()))
end

function MailFillInfoPop:judgeMail()
	local emailFormatResult = g_EmailUtil.judgeEmailFormat(self.m_etMail:getText())
	if emailFormatResult == g_EmailUtil.S_FORMAT_RESULT.STR_IS_EMPTY then
		g_AlarmTips.getInstance():setText(GameString.get("str_login_email_format_error")):show()
		return false
	end
	if emailFormatResult ==  g_EmailUtil.S_FORMAT_RESULT.CORRECT_FORMAT then
		return true
	else
		g_AlarmTips.getInstance():setText(GameString.get("str_login_email_format_error")):show()
		return false
	end
	return true
end

function MailFillInfoPop:judgePhone()
    local phoneNumber = self.m_etPhone:getText()
    local beginIndex, endIndex = string.find(phoneNumber, "%D");
    local n1,n2 = string.find(phoneNumber,"1");
    local valid = true;
    if (endIndex and endIndex > 1) or (not n1 ) or n1 ~= 1 then
        valid = false;
        local tips = GameString.get("str_phone_format_error");
        g_AlarmTips.getInstance():setText(tips):show();
        return valid;   
    end

    if phoneNumber and string.len(phoneNumber) > 11 then
        phoneNumber = string.sub(phoneNumber, 1, 11);
    elseif phoneNumber and string.len(phoneNumber) < 11 then
        valid = false;
        
        local tips = GameString.get("str_phone_format_error");
        g_AlarmTips.getInstance():setText(tips):show();
        return valid;
    end

    return valid;
end

function MailFillInfoPop:onCleanup()
    PopupBase.onCleanup(self)
end

return MailFillInfoPop