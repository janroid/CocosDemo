--[[--ldoc desc
@module HallScene
@author %s

Date   %s
]]
local ViewScene = require("framework.scenes.ViewScene");
local HallScene = class("HallScene",ViewScene);
local HallCtr = import("HallCtr")

---配置事件监听函数
HallScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
}

function HallScene:ctor()
	ViewScene.ctor(self)
	self:bindCtr(HallCtr)

	self:init()
end

function HallScene:init()
	self:loadLayout("creator/layout/hall.ccreator")

	
end

function HallScene:onEnter()
	
	
end

function HallScene:onEnterTransitionDidFinish()
	-- do something
	--[[
		进入场景过渡动画播放结束时被调用
		如果场景没有过渡动画，该方法不会被调用
	]]
end

function HallScene:onExit()
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
	]]
end

function HallScene:onExitTransitionDidStart()
	-- do something
	--[[
		退出场景动画播放前会被调用
		如果场景没有过渡动画，该方法不会被调用
	]]
end

function HallScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]

end

return HallScene;