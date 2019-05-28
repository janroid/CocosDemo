--[[--ldoc desc
@module LoginCtr
@author %s
Date   %s
]]

local ViewCtr = require("framework.scenes.ViewCtr");
local LoginCtr = class("LoginCtr",ViewCtr);

---配置事件监听函数
LoginCtr.s_eventFuncMap =  {
	[g_CustomEvent.LOGIN_REGISTER] = "reqRegister";
	[g_CustomEvent.LOGIN_LOGIN] = "reqLogin";
	[g_CustomEvent.LOGIN_RPS_LOGIN] = "onLoginRps";
	[g_CustomEvent.LOGIN_RPS_REGISTER] = "onRegisterRps"
}

function LoginCtr:ctor(scene)
	ViewCtr.ctor(self, scene);	
end

function LoginCtr:reqRegister(data)
	local param = {
		Name = data[1],
		Password = data[2]
	}
	g_NetManager.getInstance():sendSocketMsg(g_GamePb.method.ReqRegister, param)
end

function LoginCtr:reqLogin(data)
	local param = {
		Name = data[1],
		Password = data[2]
	}
	g_NetManager.getInstance():sendSocketMsg(g_GamePb.method.ReqLogin, param)
end

function LoginCtr:onLoginRps(data)
	local result = getNumFromTable(data,"Result",g_ServerConfig.LOGIN_ERR.ERRLOGIN)

	if result == g_ServerConfig.LOGIN_ERR.LGOINSUCC then
		g_AccountInfo.getInstance():init(data)
		self:toHall()
	else
		self:processErr(result)
	end
end

function LoginCtr:onRegisterRps(data)
	local result = getNumFromTable(data,"Result",g_ServerConfig.LOGIN_ERR.ERRLOGIN)
	if result == g_ServerConfig.LOGIN_ERR.REGISTERSUCC then
		g_AccountInfo.getInstance():init(data)

		self:toHall()
	else
		self:processErr(result)
	end
end

function LoginCtr:processErr(err)
	if err == g_ServerConfig.LOGIN_ERR.ERRNULL then
		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error1")):show()
	elseif err == g_ServerConfig.LOGIN_ERR.ERRNOUSER
		or err == g_ServerConfig.LOGIN_ERR.ERRLOGIN then

		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error2")):show()
	elseif err == g_ServerConfig.LOGIN_ERR.ERRHAVEUSER then
		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error3")):show()
	elseif err == g_ServerConfig.LOGIN_ERR.ERRFORBID then
		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error6")):show()
	elseif err == g_ServerConfig.LOGIN_ERR.ERRSHORT then
		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error5")):show()
	end
end

function LoginCtr:toHall()
	local hallScene = require("app.scenes.hall.HallScene")
	cc.Director:getInstance():replaceScene(hallScene:create())
end

function LoginCtr:onEnter()
	g_NetManager.getInstance():openGameSocket()
end


function LoginCtr:onExit()
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
		不用可删除
	]]
end


function LoginCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用ViewCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	ViewCtr.onCleanup(self);
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
		不用可删除
	]]

end



return LoginCtr;