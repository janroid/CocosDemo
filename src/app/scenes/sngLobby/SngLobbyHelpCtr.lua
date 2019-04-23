--[[--ldoc desc
@module SngLobbyHelpCtr
@author %s
Date   %s
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SngLobbyHelpCtr = class("SngLobbyHelpCtr",PopupCtr);
BehaviorExtend(SngLobbyHelpCtr);

---配置事件监听函数
SngLobbyHelpCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function SngLobbyHelpCtr:ctor()
	PopupCtr.ctor(self);
end

function SngLobbyHelpCtr:show()
	PopupCtr.show(self)
end

function SngLobbyHelpCtr:hidden()
	PopupCtr.hidden(self)
end

function SngLobbyHelpCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

return SngLobbyHelpCtr;