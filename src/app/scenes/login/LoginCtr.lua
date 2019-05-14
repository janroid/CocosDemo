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
	g_NetManager.getInstance():getSender():sendRegister(data)
end

function LoginCtr:reqLogin(data)
	g_NetManager.getInstance():getSender():sendLogin(data)
end

function LoginCtr:onLoginRps(data)
	local result = getNumFromTable(data,"error",-1)

	if result == 0 then

	elseif result == -1 then
		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error1")):show()
	elseif result == -2 then
		g_NoticePop.getInstance():setContent(GameString.get("str_noitce_title1"), GameString.get("str_login_error2")):show()
	end
end

function LoginCtr:onRegisterRps(data)

end

function LoginCtr:onEnter()
	-- do something
	--[[
		场景被加载显示后被调用，包括第一次加载场景和通过popScene加载场景
		这个方法可以可以放置相关和场景显示相关变量的初始化代码
		该方法可以理解为公司引擎：resume方法
		不用可删除
	]]
	
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