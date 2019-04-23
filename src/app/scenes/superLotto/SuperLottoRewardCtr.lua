--[[--ldoc desc
@module SuperLottoRewardCtr
@author RyanXu
Date   2018-12-24
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SuperLottoRewardCtr = class("SuperLottoRewardCtr",PopupCtr);
BehaviorExtend(SuperLottoRewardCtr);

---配置事件监听函数
SuperLottoRewardCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function SuperLottoRewardCtr:ctor()
	PopupCtr.ctor(self);
end

function SuperLottoRewardCtr:show()
	PopupCtr.show(self)
end

function SuperLottoRewardCtr:hidden()
	PopupCtr.hidden(self)
end

function SuperLottoRewardCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function SuperLottoRewardCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function SuperLottoRewardCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return SuperLottoRewardCtr;