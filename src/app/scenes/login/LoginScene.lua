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

	self:init()
end

function LoginScene:init()
	self:loadLayout("creator/layout/login.ccreator")

	self.m_btnLogin = self:seekNodeByName("btn_login")
    self.m_bgLogin = self:seekNodeByName("bg_login")
    self.m_viewLogin = self:seekNodeByName("view_login")
    self.m_viewRegister = self:seekNodeByName("view_register")
    self.m_lgName = self:seekNodeByName(self.m_viewLogin,"ed_name")
    self.m_lgPwd = self:seekNodeByName(self.m_viewLogin,"ed_pwd")
    self.m_rgName = self:seekNodeByName(self.m_viewRegister,"ed_name")
    self.m_rgPwd = self:seekNodeByName(self.m_viewRegister,"ed_pwd")
    self.m_rgAgain = self:seekNodeByName(self.m_viewRegister,"ed_agin")
    self.m_goLogin = self:seekNodeByName(self.m_viewLogin,"btn_login")
    self.m_toLogin = self:seekNodeByName(self.m_viewRegister,"btn_login")
    self.m_btnRegister = self:seekNodeByName(self.m_viewLogin,"btn_register")
    self.m_goRegister = self:seekNodeByName(self.m_viewRegister,"btn_register")
	self.m_btnClose = self:seekNodeByName("btn_close")

    self:showView(VIEW_TYPE.NONE)

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

	local data = {name,pwd}
	
	self:doLogic(g_CustomEvent.LOGIN_LOGIN, data)
end

function LoginScene:goRegister( )
	local name = self.m_rgName:getText()
	local pwd = self.m_rgPwd:getText()
	local pwds = self.m_rgAgain:getText()

	local data = {name,pwd,pwds}
	
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

return LoginScene;