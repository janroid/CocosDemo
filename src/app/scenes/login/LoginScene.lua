--[[--ldoc desc
@module LoginScene
@author %s

Date   %s
]]
local ViewScene = require("framework.scenes.ViewScene");
local LoginScene = class("LoginScene",ViewScene);
local LoginCtr = import("LoginCtr")

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
end

function LoginScene:onEnter()
	-- do something
	--[[
		场景被加载显示后被调用，包括第一次加载场景和通过popScene加载场景
		这个方法可以可以放置相关和场景显示相关变量的初始化代码
		该方法可以理解为公司引擎：resume方法
	]]
	
end

function LoginScene:onEnterTransitionDidFinish()
	-- do something
	--[[
		进入场景过渡动画播放结束时被调用
		如果场景没有过渡动画，该方法不会被调用
	]]
end

function LoginScene:onExit()
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
	]]
end

function LoginScene:onExitTransitionDidStart()
	-- do something
	--[[
		退出场景动画播放前会被调用
		如果场景没有过渡动画，该方法不会被调用
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