--[[--ldoc desc
@module ResetPwdUI
@author ReneYang

Date   2018-10-29
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ResetPwdUI = class("ResetPwdUI",PopupBase);
BehaviorExtend(ResetPwdUI);

function ResetPwdUI:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".ResetPwdCtr"));
	self:init();
end


function ResetPwdUI:init()
	-- do something
	
	-- 加载布局文件
	self:loadLayout("creator/login/resetPwdScene.ccreator");
	

	self.m_edtEmail =  g_NodeUtils:seekNodeByName(self,'editEmail') 
	self.m_imgCorrect =  g_NodeUtils:seekNodeByName(self,'imgCorrect') 
	self.m_labelTips =  g_NodeUtils:seekNodeByName(self,'labelTips') 
	self.m_btnCommit =  g_NodeUtils:seekNodeByName(self,'btnCommit') 
	self.m_labelCommit =  g_NodeUtils:seekNodeByName(self,'labelCommit') 
	self.m_btnClose =  g_NodeUtils:seekNodeByName(self,'btnClose') 
	self.m_txTitle = g_NodeUtils:seekNodeByName(self,'title')
	
	self.m_btnCommit:setEnabled(false)

	self:initString()
	self:initListener()
end

function ResetPwdUI:initString()
	self.m_edtEmail:setText(cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.ACCOUNT_EMAIL,""))
	self.m_labelTips:setString(GameString.get("str_login_reset_pwd_content"))
	self.m_labelCommit:setString(GameString.get("str_login_reset_pwd_commit"))
	self.m_edtEmail:setPlaceHolder(GameString.get("str_login_email_account_hint"))
	self.m_txTitle:setString(GameString.get("str_login_reset_pwd_title"))
	if string.isRightEmail(self.m_edtEmail:getText()) then
		self.m_imgCorrect:setTexture("creator/common/symbol/tick.png")
		self.m_imgCorrect:setVisible(true)
		self.m_btnCommit:setEnabled(true)
	end
end

function ResetPwdUI:initListener()
	self.m_btnCommit:addClickEventListener(
		function (sender) 
			if string.isRightEmail(self.m_edtEmail:getText()) then
				self:doLogic(g_SceneEvent.LOGIN_RESET_PWD, g_StringLib.trim(self.m_edtEmail:getText()))
			else
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_email_format_error"))
				self.m_imgCorrect:setTexture("creator/common/symbol/cross.png")
				self.m_imgCorrect:setVisible(true)
			end

		end
	)
	self.m_btnClose:addClickEventListener(
		function(sender)
			self:hidden()
		end
	)
	local function editboxEventHandler(eventType)
		if eventType == "began" then
			-- 点击编辑框,输入法显示
			self.m_btnCommit:setEnabled(false)
		elseif eventType == "ended" then
			-- 当编辑框失去焦点并且键盘消失的时候被调用
			if self.m_edtEmail:getText()=="" or self.m_edtEmail:getText()==nil then
				return
			end
			if string.isRightEmail(self.m_edtEmail:getText()) then
				self.m_imgCorrect:setTexture("creator/common/symbol/tick.png")
				self.m_btnCommit:setEnabled(true)
			else
				self.m_imgCorrect:setTexture("creator/common/symbol/cross.png")
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_email_format_error"))
				self.m_btnCommit:setEnabled(false)
			end
			self.m_imgCorrect:setVisible(true)
		elseif eventType == "changed" then
			-- 输入内容改变时调用
		elseif eventType == "return" then
			-- 用户点击编辑框的键盘以外的区域，或者键盘的Return按钮被点击时所调用
		end
	end
	self.m_edtEmail:registerScriptEditBoxHandler(editboxEventHandler)
end


return ResetPwdUI;