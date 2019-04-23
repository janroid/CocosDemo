--[[--ldoc desc
@module ChangePwdPop
@author ReneYang

Date   2018-10-31
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ChangePwdPop = class("ChangePwdPop",PopupBase);
BehaviorExtend(ChangePwdPop);

function ChangePwdPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".ChangePwdCtr"));
	self:init();
end

function ChangePwdPop:onCleanup()
	PopupBase.onCleanup(self)
end

function ChangePwdPop:init()
	-- do something
	
	-- 加载布局文件
	self:loadLayout("creator/changePwd/changePwd.ccreator");
	

	self.m_labelTitle = g_NodeUtils:seekNodeByName(self, "labelTitle")
	self.m_btnClose = g_NodeUtils:seekNodeByName(self, "btnClose")
	self.m_etPwdNew = g_NodeUtils:seekNodeByName(self, "editboxPwd1")
	self.m_imgPwdNew = g_NodeUtils:seekNodeByName(self, "pwd1Correct")
	self.m_etPwdAgain = g_NodeUtils:seekNodeByName(self, "editboxPwd2")
	self.m_imgPwdAgain = g_NodeUtils:seekNodeByName(self, "pwd2Correct")
	self.m_btnCommit = g_NodeUtils:seekNodeByName(self, "btnCommit")
	self.m_labelCommit = g_NodeUtils:seekNodeByName(self, "labelCommit")
	
	self:initString()
	self:initListener()
end

function ChangePwdPop:initString()
	self.m_labelTitle:setString(GameString.get("str_change_pwd_title"))
	self.m_etPwdNew:setPlaceHolder(GameString.get("str_change_pwd_new_pwd"))
	self.m_etPwdAgain:setPlaceHolder(GameString.get("str_change_pwd_new_pwd_again"))
	self.m_labelCommit:setString(GameString.get("str_change_pwd_commit"))
end

function ChangePwdPop:initListener()
	self.m_btnClose:addClickEventListener(
		function()
			self:setVisible(false)
		end
	)
	self.m_btnCommit:addClickEventListener(
		function()
			local pwd1 = self.m_etPwdNew:getText()
			local pwd2 = self.m_etPwdAgain:getText()
			if pwd1 == "" or pwd2 == "" then 
				return 
			elseif pwd1 ~= pwd2 then
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_change_pwd_inconsistent"))
			else
				g_EventDispatcher:dispatch(g_SceneEvent.USER_INFO_MAIL_CHANGE_PWD, pwd1)
			end
		end
	)
	self.m_etPwdNew:registerScriptEditBoxHandler(
		
		function(eventType)
			if eventType == "ended" then
				-- 当编辑框失去焦点并且键盘消失的时候被调用
				if self:isPwdFormatCorrect(self.m_etPwdNew:getText()) then
					self.m_imgPwdNew:setVisible(true)
				else
					self.m_imgPwdNew:setVisible(false)
				end
			end
		end
	)
	self.m_etPwdAgain:registerScriptEditBoxHandler(
		
		function(eventType)
			if eventType == "ended" then
				-- 当编辑框失去焦点并且键盘消失的时候被调用
				if self:isPwdFormatCorrect(self.m_etPwdAgain:getText()) then
					self.m_imgPwdAgain:setVisible(true)
				else
					self.m_imgPwdAgain:setVisible(false)
				end
			end
		end
	)
end

function ChangePwdPop:isPwdFormatCorrect(str)
	if str ~= nil and string.trim(str) ~= "" then
		return true
	end
	return false
end

---刷新界面
function ChangePwdPop:updateView(data)
	data = checktable(data);
end

return ChangePwdPop;