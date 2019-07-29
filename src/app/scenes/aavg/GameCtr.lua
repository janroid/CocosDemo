local ViewCtr = require("framework.scenes.ViewCtr");
local GameCtr = class("GameCtr",ViewCtr);

---配置事件监听函数
GameCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见ViewCtr.updateView函数
}

function GameCtr:ctor()
	ViewCtr.ctor(self);

	
end

function GameCtr:onEnter()
	-- do something
	--[[
		场景被加载显示后被调用，包括第一次加载场景和通过popScene加载场景
		这个方法可以可以放置相关和场景显示相关变量的初始化代码
		该方法可以理解为公司引擎：resume方法
		不用可删除
	]]
end

function GameCtr:onEnterTransitionDidFinish()
	-- do something
	--[[
		进入场景过渡动画播放结束时被调用
		如果场景没有过渡动画，该方法不会被调用
		不用可删除
	]]
end

function GameCtr:onExit()
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
		不用可删除
	]]
end

function GameCtr:onExitTransitionDidStart()
	-- do something
	--[[
		退出场景动画播放前会被调用
		如果场景没有过渡动画，该方法不会被调用
		不用可删除
	]]
end

function GameCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用ViewCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	ViewCtr.onCleanup(self);
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
		不用可删除
	]]

end



return GameCtr;