local ViewCtr = require("framework.scenes.ViewCtr");
local PopupCtr = class("PopupCtr",ViewCtr);

---配置事件监听函数
PopupCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
}

function PopupCtr:ctor()
	-- ViewCtr.ctor(self);

end

function PopupCtr:onCleanup()
	self._isCleanup = true
end

function PopupCtr:show()
    -- 与UI生命周期相对应
end

function PopupCtr:hidden()
    -- 与UI生命周期相对应
end
function PopupCtr:onEnter(registerBySelf)
	if registerBySelf ~= true then
		self:registerEvent()
	end
end
function PopupCtr:onExit(unregisterBySelf)
	if unregisterBySelf ~= true then
		self:unRegisterEvent()
	end
end


--- 调用UI函数
function PopupCtr:updateView(mEvent, ...)
	g_EventDispatcher:dispatch(mEvent, ...)
end

return PopupCtr;