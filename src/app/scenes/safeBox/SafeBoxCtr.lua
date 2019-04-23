--[[--ldoc desc
@module SafeBoxCtr
@author MenuZhang
Date   2018-10-25
]]
local PopupCtr = import("app.common.popup").PopupCtr
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local SafeBoxCtr = class("SafeBoxCtr",PopupCtr);
BehaviorExtend(SafeBoxCtr);

---配置事件监听函数
SafeBoxCtr.s_eventFuncMap =  {
	[g_SceneEvent.SAFE_BOX_EVENT_GET_DATA] = "getBankData";
	[g_SceneEvent.SAFE_BOX_EVENT_SAVE_MONEY] = "onSaveMoney";
	[g_SceneEvent.SAFE_BOX_EVENT_DRAW_MONEY] = "onDrawMoney";
}

function SafeBoxCtr:ctor()
	PopupCtr.ctor(self)
end


function SafeBoxCtr:getBankData()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_BANKCLICK)
	g_HttpManager:doPost(params,self, self.onGetBankDataReponse)
end

function SafeBoxCtr:onGetBankDataReponse(isSuccess,data)
	Log.d("SafeBoxCtr:onGetBankDataReponse ",data)
	if isSuccess then
		g_EventDispatcher:dispatch(g_SceneEvent.SAFE_BOX_EVENT_GET_DATA_SUCCESS,data)
	end
end

function SafeBoxCtr:onSaveMoney(money)
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_BANKSAVEMONEY)
	param.token = g_AccountInfo:getBankToken()
	param.money = money
	g_HttpManager:doPost(param,self,self.onSaveCallback);	
end

function SafeBoxCtr:onDrawMoney(money)
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_BANKGETMONEY)
	param.token = g_AccountInfo:getBankToken()
	param.money = money
	g_HttpManager:doPost(param,self,self.onDrawCallback);	
end

function SafeBoxCtr:onSaveCallback(isSuccess,data)
	Log.d("SafeBoxCtr:onSaveCallback ",data,isSuccess)
	if isSuccess then		
		g_EventDispatcher:dispatch(g_SceneEvent.SAFE_BOX_EVENT_SAVE_MONEY_SUCCESS,data)
	end
end

function SafeBoxCtr:onDrawCallback(isSuccess,data)
	Log.d("SafeBoxCtr:onDrawCallback ",data,isSuccess)
	if isSuccess then
		g_EventDispatcher:dispatch(g_SceneEvent.SAFE_BOX_EVENT_DRAW_MONEY_SUCCESS,data)
	end
	
end


---刷新UI
function SafeBoxCtr:updateView(data)
	-- local ui = self:getUI();
	-- if ui and ui.updateView then
	-- 	ui:updateView(data);
	-- end
end

function SafeBoxCtr:showPasswordView(data)
	-- local ui = self:getUI();
	-- local SafeBoxSetPassword = require(".SafeBoxPassword.SafeBoxPasswordView")
	-- local view = SafeBoxSetPassword:create()
	-- ui:add(view)
end

function SafeBoxCtr:showSetPasswordView(data)
	-- local ui = self:getUI();
	-- local SafeBoxSetPassword = require(".SafeBoxSetPassword.SafeBoxSetPasswordView")
	-- local view = SafeBoxSetPassword:create()
	-- ui:add(view)
end

return SafeBoxCtr;