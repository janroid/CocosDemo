--[[--ldoc 该模块内的网络请求基本都放在这里
@module PrivateHallCtr
@author LoyalwindPeng
Date   2018-12-26
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local PrivateHallCtr = class("PrivateHallCtr",PopupCtr);
BehaviorExtend(PrivateHallCtr);

local BlindCarryCfgDatas = require("BlindCarryCfgDatas")

---配置事件监听函数
PrivateHallCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
	[g_SceneEvent.PRIVATE_HALL_CFG_REQUEST]    = "requestPrivateHallCfg";  -- 请求私人房大厅配置数据
	[g_SceneEvent.PRIVATE_ROOM_CREATE_REQUEST] = "requestPrivateRoomCreate";  -- 请求创建私人房
	[g_SceneEvent.PRIVATE_ROOM_CHECK_PASSWORD] = "requestPrivateRoomCheckPwd";  -- 检查密码
	[g_SceneEvent.PRIVATE_ROOM_GET_PWD_REQUEST] = "requestPrivateRoomGetPwd"; -- 私人房間密码信息
	[g_SceneEvent.PRIVATE_ROOM_MOTIFY_PWD_REQUEST] = "requestPrivateRoomMotifyPwd"; -- 修改私人房間密码
}

function PrivateHallCtr:ctor()
	PopupCtr.ctor(self);
end

function PrivateHallCtr:show()
	PopupCtr.show(self)
end

function PrivateHallCtr:hidden()
	PopupCtr.hidden(self)
end

function PrivateHallCtr:requestPrivateHallCfg()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.PRIVATE_HALL_CFG)
	g_HttpManager:doPost(params, self, self.responsePrivateHallCfg, function()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
	end);
end

function PrivateHallCtr:responsePrivateHallCfg(isSuccess,data)
	if (not isSuccess) or g_TableLib.isEmpty(data) then
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		return
	end

	self.m_blindCarryCfgDatas = BlindCarryCfgDatas.new(data)
	self:updateView(g_SceneEvent.PRIVATE_HALL_CFG_RESPONSE, self.m_blindCarryCfgDatas:getDataLists())
end

--@desc: 网络请求创建私人房
--@params: 参数
function PrivateHallCtr:requestPrivateRoomCreate(params)
	assert(type(params)=="table", "请求创建私人房的参数不能为空")
	local cmdCfg = HttpCmd:getMethod(HttpCmd.s_cmds.PRIVATE_ROOM_CREATE)
	params.mod = cmdCfg.mod
	params.act = cmdCfg.act
	g_Progress.getInstance():show()
	g_HttpManager:doPost(params, self, self.responsePrivateRoomCreate, function()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		g_Progress.getInstance():dismiss()
	end);
end

--@desc: 创建私人房网络请求回调
--@isSuccess: bool 是否成功
--@data: 响应数据
function PrivateHallCtr:responsePrivateRoomCreate(isSuccess, data)
	Log.d("responsePrivateRoomCreate", data)
	if not self:_handleRequestFailure(isSuccess, data) then return end

	--[[
	data = {
		"tableinfo": {
			"tableconfig": "{\"bet_time\":20,\"field\":2,\"flag\":9,\"max_bring\":200000,\"min_bring\":10000,\"onlooker_cap\":30,\"owner\":5959,\"password\":\"123\",\"player_cap\":5,\"s_blind\":500,\"sid\":7110,\"status\":0,\"table_name\":\"\相\茜\的\房\間\",\"table_type\":1,\"tid\":1000}",
			"serverconfig": {
				"ip": "192.168.56.101",
				"port": 12345
			}
		},
		"ret": 0
	} 
	]]
	local ret = tonumber(data.ret)
	if ret == 0 then -- 去进入房间
		if (g_TableLib.isEmpty(data.tableinfo) or g_TableLib.isEmpty(data.tableinfo.serverconfig))
		then
			return
		end
		local tableconfig, flag = g_JsonUtil.decode(data.tableinfo.tableconfig)
		if(not flag) then
			return
		end

		-- local tableconfig  = data.tableinfo.tableconfig
		local serverconfig = data.tableinfo.serverconfig
		local roomInfo = {tid = tableconfig.tid,  ip = serverconfig.ip,  port = serverconfig.port, password = tableconfig.password, owner = tableconfig.owner};
		self:enterPrivateRoom(roomInfo, true)

	elseif ret == -7 then -- 不是vip, 提示去开通vip
		g_AlertDialog.getInstance()
		:setTitle(GameString.get("tips"))
        :setContent(GameString.get("str_private_create_failure"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_common_back"))
		:setRightBtnTx(GameString.get("str_become_vip"))
        :setRightBtnFunc(function() -- 打開商城進入vip頁面，關閉私人房創建頁面
			local StoreConfig = import("app.scenes.store").StoreConfig
			g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE, StoreConfig.STORE_POP_UP_VIP_PAGE)
		end)
        :show()
	else
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
	end
end

function PrivateHallCtr:requestPrivateRoomCheckPwd(data)
	Log.d("requestPrivateRoomCheckPwd",data)
	assert(type(data)=="table", "请求私人房核对密码的参数不能为空")
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.PRIVATE_ROOM_CHECKPWD)
	params.tid = data.tid
	params.password = data.password
	params.ip = data.ip
	params.port = data.port
	g_Progress.getInstance():show()
	g_HttpManager:doPost(params, self, self.responsePrivateRoomCheckPwd, function()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		g_Progress.getInstance():dismiss()
	end);
end

function PrivateHallCtr:responsePrivateRoomCheckPwd(isSuccess, data, params)
	if not self:_handleRequestFailure(isSuccess, data) then return end
	local iret = tonumber(data.iret)
	local contents = ""
	if iret == 0 then -- 进入房间
		self:enterPrivateRoom(params, false);
		return
	elseif iret == -1 then -- 密码错误
		contents = GameString.get("str_private_pwd_error")
	elseif iret == -2 then -- 房间不存在
		contents = GameString.get("str_private_room_not_exist")
	end
	
	g_AlarmTips.getInstance():setText(contents):show()
end

function PrivateHallCtr:requestPrivateRoomGetPwd(params)
	assert(type(params)=="table", "请求私人房间信息的参数不能为空")
	local cmdCfg = HttpCmd:getMethod(HttpCmd.s_cmds.PRIVATE_ROOM_GET_PWD)
	params.mod = cmdCfg.mod
	params.act = cmdCfg.act
	g_Progress.getInstance():show()
	g_HttpManager:doPost(params, self, self.responsePrivateRoomGetPwd, function()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		g_Progress.getInstance():dismiss()
	end);
end

function PrivateHallCtr:responsePrivateRoomGetPwd(isSuccess, data)
	g_Progress.getInstance():dismiss()
	if (not isSuccess) then
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		return
	end
	local password = GameString.get("str_private_room_no_password")
	if data and tonumber(data.flag) == 9 then
		password = data.password
		g_RoomInfo:setPassword(password)
	end
	self:updateView(g_SceneEvent.PRIVATE_ROOM_GET_PWD_RESPONSE, password)
end

function PrivateHallCtr:requestPrivateRoomMotifyPwd(params)
	Log.d("requestPrivateRoomCheckPwd",params)
	assert(type(params)=="table", "请求修改私人房核对密码的参数不能为空")
	local cmdCfg = HttpCmd:getMethod(HttpCmd.s_cmds.PRIVATE_ROOM_MOTIFY_PWD)
	params.mod = cmdCfg.mod
	params.act = cmdCfg.act
	g_Progress.getInstance():show()
	g_HttpManager:doPost(params, self, self.responsePrivateRoomMotifyPwd, function()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		g_Progress.getInstance():dismiss()
	end);
end

function PrivateHallCtr:responsePrivateRoomMotifyPwd(isSuccess, data, params)
	Log.d("responsePrivateRoomMotifyPwd", isSuccess, data)
	g_Progress.getInstance():dismiss()
	if not self:_handleRequestFailure(isSuccess, data) then return end

	local iret = tonumber(data.iret)
	local tips = ""
	if iret == 0 then
		tips = GameString.get("str_private_motify_pwd_success")
		g_RoomInfo:setPassword(params.password)
	else
		tips = GameString.get("str_private_motify_pwd_failure")
	end
	g_AlarmTips.getInstance():setText(tips):show()
end

-- TODO:进入这个房间
function PrivateHallCtr:enterPrivateRoom(roomInfo, createToEnter)
	Log.d("enterPrivateRoom",roomInfo)

	local data = {
		createToEnter = createToEnter,
		ip        = roomInfo.ip,
		port      = roomInfo.port,
		tid       = roomInfo.tid,
		flag      = roomInfo.flag,
		tableType = g_RoomInfo.ROOM_TYPE_PRIVATE;
		password  = roomInfo.password;
		passwordChecked = true;
	}
	local RoomPresenter = import("app.presenter").RoomPresenter
	RoomPresenter:toRoom(data)
end

--@desc: 处理请求失败
--@isSuccess: 请求结果
--@data: table, 请求响应数据
--@return: bool 
function PrivateHallCtr:_handleRequestFailure(isSuccess, data)
	g_Progress.getInstance():dismiss()
	if (not isSuccess) or g_TableLib.isEmpty(data) then
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		return false
	end
	return true
end

function PrivateHallCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用PopupCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true 
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function PrivateHallCtr:onEnter()
	PopupCtr.onEnter(self, false);
	-- xxxxxx
end

function PrivateHallCtr:onExit()
	PopupCtr.onExit(self, false);
	-- xxxxxx
end

return PrivateHallCtr;