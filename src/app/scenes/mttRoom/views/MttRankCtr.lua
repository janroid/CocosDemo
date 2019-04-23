--[[--ldoc desc
@module MttRankCtr
@author RyanXu
Date   2018-12-24
]]


local MttRankCtr = class("MttRankCtr",PopupCtr);
BehaviorExtend(MttRankCtr);

---配置事件监听函数
MttRankCtr.eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
}

function MttRankCtr:ctor()
	PopupCtr.ctor(self);
end

function MttRankCtr:show()
	PopupCtr.show(self)
end

function MttRankCtr:hidden()
	PopupCtr.hidden(self)
end

function MttRankCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function MttRankCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function MttRankCtr:onExit()
	PopupCtr.onCleanup(self, false);
	-- xxxxxx
end

return MttRankCtr;