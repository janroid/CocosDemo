--[[--ldoc desc
@module ChatPopCtr
@author %s
Date   %s
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local ChatPopCtr = class("ChatPopCtr",PopupCtr);
BehaviorExtend(ChatPopCtr);

---配置事件监听函数
ChatPopCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数
	[g_SceneEvent.REQUEST_USER_PROP_DATA] = "requestUserPropData";
}

function ChatPopCtr:ctor()
	PopupCtr.ctor(self);
end

function ChatPopCtr:show()
	PopupCtr.show(self)
end

function ChatPopCtr:requestUserPropData()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_PROP_DATA)
    g_HttpManager:doPost(params, self, self.onRequestUserPropDataSuccess)
end

function ChatPopCtr:onRequestUserPropDataSuccess(isSuccess,data)
	if not isSuccess then
		Log.e("request user prop data failed")
		return 
	end

	-- local flag, propArr = g_JsonUtil.decode(data);
	-- if (not flag or not table.isTable(propArr)) then
	-- 	propArr = {};
	-- end
	g_Model:setData(g_ModelCmd.ROOM_USER_PROP_DATA, data);
end

function ChatPopCtr:hidden()
	PopupCtr.hidden(self)
end

function ChatPopCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

return ChatPopCtr;