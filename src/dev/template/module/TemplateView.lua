--[[--ldoc desc
@module TemplateUI
@author %s

Date   %s
]]
local ViewScene = require("framework.scenes.ViewScene")
local TemplateUI = class("TemplateUI",ViewScene);

---配置事件监听函数
TemplateUI.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
}

function TemplateUI:ctor()
	ViewScene.ctor(self);
	self:bindCtr(import("TemplateCtr"));
	self:init();
end

function TemplateUI:init()
	-- do something
	
	-- 加载布局文件
	-- local view = self:loadLayout("aa.creator");
	-- self:add(view);
	
end

function TemplateUI:onEnter()
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
	
end

function TemplateUI:onEnterTransitionDidFinish()
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
end

function TemplateUI:onExit()
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
end

function TemplateUI:onExitTransitionDidStart()
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
end

function TemplateUI:onCleanup()
	ViewScene.onCleanup(self)
end

return TemplateUI;