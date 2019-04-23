--[[--ldoc desc
@module TemplatePop
@author %s

Date   %s
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local TemplatePop = class("TemplatePop",PopupBase);
BehaviorExtend(TemplatePop);

-- 配置事件监听函数
TemplatePop.s_eventFuncMap = {
	-- ["EventKey"] = "FuncName"
	-- 在show方法开始监听
	-- 在hidden方法区取消监听
}

function TemplatePop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("TemplateCtr"))
	self:init()
end

function TemplatePop:show()
	PopupBase.show(self)
end

function TemplatePop:hidden()
	PopupBase.hidden(self)
end

function TemplatePop:init()
	-- do something
	
	-- 加载布局文件
	-- 第一个参数为布局文件，
	-- 第二个参数为boolean，
	--       true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--       false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
	-- self:loadLayout("aa.creator",isGlobal);
end

function TemplatePop:onEnter()
	PopupBase.onEnter(self, false)
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
	
end

function TemplatePop:onEnterTransitionDidFinish()
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
end

function TemplatePop:onExit()
	PopupBase.onExit(self, false)
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
end

function TemplatePop:onExitTransitionDidStart()
	-- do something
	--[[
		参考场景UI该方法说明，所在场景调用时，该方法同事触发
		不用可删除
	]]
end

function TemplatePop:onCleanup()
	PopupBase.onCleanup(self)
end


return TemplatePop;