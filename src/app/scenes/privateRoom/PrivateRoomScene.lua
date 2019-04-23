--[[--ldoc 私人房房间
@module PrivateRoomScene
@author LoyalwindPeng

Date   2019-1-16
]]
local ViewScene = import('app.scenes.normalRoom').scene -- 继承normalRoomScene
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local PrivateRoomScene = class("PrivateRoomScene",ViewScene);
BehaviorExtend(PrivateRoomScene);

local PrivateRoomCtr = require("PrivateRoomCtr")
local PrivatePopType = import('app.scenes.privateHall').PrivatePopType

---配置事件监听函数
PrivateRoomScene.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与ctr的通信调用参见ViewScene.doLogic函数
	[g_SceneEvent.PRIVATE_ROOM_OWNER_CHANGED] = "roomOwnerChanged"; -- 私人房主变化了
}

-- @desc: 构造方法
--@data.createToEnter: bool 是否正常创建进来。 true: 通过普通场大厅自己创建进来的， false:自己创建了，但是后来通过掉线重连等进来的
--@RefType [com.app]
function PrivateRoomScene:ctor(data)
	ViewScene.ctor(self, data)
	if g_TableLib.isTable(data) then
		self.m_createToEnter = data.createToEnter
	end
end

function PrivateRoomScene:getCtrClass()
	return PrivateRoomCtr
end

function PrivateRoomScene:init()
	-- 由于继承自normalRoomScene ，所以必须调用父类init初始化
	ViewScene.init(self)
	-- do something
end

function PrivateRoomScene:onMotifyPwd(sender)
	g_PopupManager:show(g_PopupConfig.S_POPID.PRIVATE_HALL_POP, PrivatePopType.MotifyPassword, {tid = g_RoomInfo:getTid()})
end

function PrivateRoomScene:roomOwnerChanged(ownerUID, isLeave)

	-- 自己不是房主
	local uid = tostring(g_AccountInfo:getId())
	if tostring(ownerUID) ~= uid then
		if isLeave and tostring(self.m_ownerUID) ~= tostring(uid) then -- true 表示房主离开房间
			g_AlertDialog.getInstance():setTitle(GameString.get("tips"))
			:setContent(GameString.get("str_private_owner_leave_room"))
			:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
			:setCenterBtnTx(GameString.get("str_room_confirm"))
			:show()
		end
		return 
	end
	-- 记录房主
	self.m_ownerUID = uid
	g_RoomInfo:setOwner(uid)
	-- 显示修改密码按钮
	self:showMotifyPwdBtn(true)
	-- 更新房间密码
	self:requestUpdateRoomPwd()
	-- 提示创建成功
	if self.m_createToEnter then
		self.m_createToEnter = false
		g_Schedule:schedulerOnce(function()
			-- 提示创建房间成功
			g_PopupManager:show(g_PopupConfig.S_POPID.PRIVATE_HALL_POP, PrivatePopType.CreateSuccess, {tid = g_RoomInfo:getTid()})
		end,0.25)
	end
end

function PrivateRoomScene:requestUpdateRoomPwd()
	local cmdCfg = HttpCmd:getMethod(HttpCmd.s_cmds.PRIVATE_ROOM_GET_PWD)
	local params = {}
	params.mod = cmdCfg.mod
	params.act = cmdCfg.act
	params.tid = g_RoomInfo:getTid()
	g_HttpManager:doPost(params, nil, function(_, isSuccess, data)
		if (not isSuccess) then return end
		if data and tonumber(data.flag) == 9 then
			g_RoomInfo:setPassword(data.password)
		end
	end, nil);
end

function PrivateRoomScene:onEnter()
	ViewScene.onEnter(self)
	self:roomOwnerChanged(g_RoomInfo:getOwner())
	self.m_enableSuperLotto = false
end

--@desc: override
function PrivateRoomScene:overrideExitRoomTipsIfNeed()
	if tostring(g_RoomInfo:getOwner()) ~= tostring(g_AccountInfo:getId()) then -- 自己不是房主
		ViewScene.overrideExitRoomTipsIfNeed(self) -- 调用父类方法做提示
		return
	end
	g_AlertDialog.getInstance()
		:setTitle(GameString.get("tips"))
		:setContent(GameString.get("str_private_room_dismiss_operator"))
		:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
		:setLeftBtnTx(GameString.get("str_common_cancel"))
		:setRightBtnTx(GameString.get("str_common_confirm"))
		:setRightBtnFunc(function()
			self:doLogic("back")-- 这里直接退出
		end)
		:show()
end

-- 禁止活动网页入口
function PrivateRoomScene:overrideForbidWebEntrance()
    return true
end

--@desc: 控制修改密码按钮显示状态
--@isShow: bool 是否显示
function PrivateRoomScene:showMotifyPwdBtn(isShow)
	if not self.m_motifyPwdBtn then
		if not isShow then return end
		-- 添加修改密码按钮
		local detal = self:overrideForbidWebEntrance() and 200 or 280
		local motifyPwdBtn = ccui.Button:create("creator/normalRoom/img/motifyPwd.png"):addTo(self:getRoot())
		:align(display.RIGHT_TOP , cc.p(display.right-detal, display.top - 15))
		motifyPwdBtn:addClickEventListener(handler(self, self.onMotifyPwd))
		self.m_motifyPwdBtn = motifyPwdBtn
	end
	self.m_motifyPwdBtn:setVisible(isShow)
end

function PrivateRoomScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]
end

return PrivateRoomScene;