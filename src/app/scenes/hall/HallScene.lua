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

	self.m_btnQuick = self:seekNodeByName("btn_quick")



	self.m_btnQuick:addClickEventListener(function()
		
	end)

end

function HallScene:onEnter()
	ViewScene.onEnter(self)
end

function HallScene:onExit()
	ViewScene.onExit(self)
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
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