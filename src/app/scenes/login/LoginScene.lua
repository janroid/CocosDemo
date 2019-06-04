--[[--ldoc desc
@module LoginScene
@author %s

Date   %s
]]
local ViewScene = require("framework.scenes.ViewScene");
local LoginScene = class("LoginScene",ViewScene);
local LoginCtr = import("LoginCtr")

local VIEW_TYPE = {
    NONE = 1;
    LOGIN = 2;
    REGISTER = 3;
}

---配置事件监听函数
LoginScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
}

function LoginScene:ctor()
	ViewScene.ctor(self)
	self:bindCtr(LoginCtr)

	local m = cc.Node:create()

	self:init()
end

function LoginScene:initText( )
	self.m_txrTitle:setString(GameString.get("str_reg_title"))
	self.m_txrName:setXMLData(GameString.get("str_reg_name"))
	self.m_txrPwd:setXMLData(GameString.get("str_reg_pwd"))
	self.m_txrAgain:setXMLData(GameString.get("str_reg_confirm"))
	self.m_txReg:setString(GameString.get("str_login_reg"))
	self.m_txReg:setString(GameString.get("str_login_reg"))
	self.m_rxLogin:setXMLData(GameString.get("str_login_tologin"))

	self.m_txRegister:setXMLData(GameString.get("str_login_toreg"))
	self.m_txName:setXMLData(GameString.get("str_login_name"))
	self.m_txPwd:setXMLData(GameString.get("str_login_pwd"))
	self.m_txLogin:setString(GameString.get("str_login_login"))
	self.m_txTitle:setString(GameString.get("str_login_title"))
end

function LoginScene:init()
	self:loadLayout("creator/layout/login.ccreator")
	self:initText()

    self:showView(VIEW_TYPE.NONE)

	self.m_count = 0
	self.m_btnLogin:addClickEventListener(function()
		self:showView(VIEW_TYPE.LOGIN)	
    end)

    self.m_goLogin:addClickEventListener(function()
        self:goLogin()
    end)

    self.m_goRegister:addClickEventListener(function()
        self:goRegister()
	end)
	
	self.m_btnClose:addClickEventListener(function()
		self:showView(VIEW_TYPE.NONE)
	end)

	self.m_btnRegister:addClickEventListener(function()
		self:showView(VIEW_TYPE.REGISTER)
	end)

	self.m_toLogin:addClickEventListener(function()
		self:showView(VIEW_TYPE.LOGIN)
	end)

end

function LoginScene:goLogin( )
	local name = self.m_lgName:getText()
	local pwd = self.m_lgPwd:getText()

	if not name or not pwd 
		or string.len(g_StringLib.trim(name)) < 1
		or string.len(g_StringLib.trim(pwd)) < 1 then
		self:showTips(GameString.get("str_login_error1"))

		return
	end

	if string.find(name, " ") ~= nil 
		or string.find(pwd, " ") ~= nil then

		self:showTips(GameString.get("str_login_error4"))

		return
	end

	local data = {name,pwd}
	
	self:doLogic(g_CustomEvent.LOGIN_LOGIN, data)
end

function LoginScene:goRegister( )
	local name = self.m_rgName:getText()
	local pwd = self.m_rgPwd:getText()
	local pwds = self.m_rgAgain:getText()

	if not name or not pwd or not pwds then
		self:showTips(GameString.get("str_login_error1"))

		return
	end

	if string.len(g_StringLib.trim(name)) < 1
		or string.len(g_StringLib.trim(pwd)) < 1
		or string.len(g_StringLib.trim(pwds)) < 1 then

		self:showTips(GameString.get("str_login_error1"))

		return
	end

	if string.find(name, " ") ~= nil 
		or string.find(pwd, " ") ~= nil 
		or string.find(pwds, " ") ~= nil then

		self:showTips(GameString.get("str_login_error4"))

		return
	end

	if pwd ~= pwds then
		self:showTips(GameString.get("str_login_error3"))

		return
	end

	if string.len(name) < g_ClientConfig.S_NAME_LEN 
		or string.len(pwd) < g_ClientConfig.S_NAME_LEN then

		self:showTips(GameString.get("str_login_error5"))

		return
	end

	local data = {name,pwd}
	
	self:doLogic(g_CustomEvent.LOGIN_REGISTER, data)
end

--[[
    @desc: 控制二级界面显示
    --@mtype: VIEW_TYPE
    @return:
]]
function LoginScene:showView(mtype)
    self.m_curViewType = mtype

    self.m_bgLogin:setVisible(mtype~=VIEW_TYPE.NONE)
    self.m_viewLogin:setVisible(mtype==VIEW_TYPE.LOGIN)
	self.m_viewRegister:setVisible(mtype==VIEW_TYPE.REGISTER)
end



function LoginScene:onEnter()
	ViewScene.onEnter(self)
end

function LoginScene:onExit()
	ViewScene.onExit(self)
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
	]]
end
 

function LoginScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]

end

function LoginScene:showTips(msg)
	if not msg or string.len(msg) < 1 then
		Log.d("LoginScene.showTips : msg is nil or too short")
		return
	end

	g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), msg):show()
end

return LoginScene;