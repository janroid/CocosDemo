--[[--ldoc desc
@module TemplateScene
@author %s

Date   %s
]]
local ViewScene = import("framework.scenes.ViewScene");
local TemplateScene = class("TemplateScene",ViewScene);

---配置事件监听函数
TemplateScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
}

function TemplateScene:ctor()
	ViewScene.ctor(self)
	self:bindCtr(import("TemplateCtr"))

	self:init()
end

function TemplateScene:init()
	-- do something
	--[[
		只有在创建场景时会被调用
		加载布局文件代码放置于该方法内
		只需初始化一次的变量放置于该方法内
		local view = self:loadLayout("aa.creator");
		self:add(view);
	]] 
end

function TemplateScene:onEnter()
	ViewScene.onEnter(self)
	-- do something
	--[[
		场景被加载显示后被调用，包括第一次加载场景和通过popScene加载场景
		这个方法可以可以放置相关和场景显示相关变量的初始化代码
		该方法可以理解为公司引擎：resume方法
	]]
	
end

function TemplateScene:onEnterTransitionDidFinish()
	ViewScene.onEnterTransitionDidFinish(self)
	-- do something
	--[[
		进入场景过渡动画播放结束时被调用
		如果场景没有过渡动画，该方法不会被调用
	]]
end

function TemplateScene:onExit()
	ViewScene.onExit(self)
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
	]]
end

function TemplateScene:onExitTransitionDidStart()
	ViewScene.onExitTransitionDidStart(self)
	-- do something
	--[[
		退出场景动画播放前会被调用
		如果场景没有过渡动画，该方法不会被调用
	]]
end

function TemplateScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]

end

return TemplateScene;