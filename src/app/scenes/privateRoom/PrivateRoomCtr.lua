--[[--ldoc desc
@module PrivateRoomCtr
@author LoyalwindPeng
Date   2019-1-16
]]

local NormalRoomSceneCtr = import('app.scenes.normalRoom').NormalRoomSceneCtr
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local PrivateRoomCtr = class("PrivateRoomCtr",NormalRoomSceneCtr);
BehaviorExtend(PrivateRoomCtr);

---配置事件监听函数
PrivateRoomCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见NormalRoomSceneCtr.updateView函数
}

function PrivateRoomCtr:ctor(view)
	NormalRoomSceneCtr.ctor(self, view)

end

--@isOwnerDisbandRoom: bool 是否是房主解散房间
function PrivateRoomCtr:popScene(isOwnerDisbandRoom)
	NormalRoomSceneCtr.popScene(self)
	if isOwnerDisbandRoom then
		g_Schedule:schedulerOnce(function()
			g_AlertDialog.getInstance():setTitle(GameString.get("tips"))
			:setContent(GameString.get("str_private_owner_close_room"))
			:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
			:setCenterBtnTx(GameString.get("str_room_confirm"))
			:show()
		end, 0.15)
	end
end

function PrivateRoomCtr:onCleanup()
	-- 如果子类复写父类onCleanup()方法且不调用NormalRoomSceneCtr.onCleanup(self)请加上这个变量赋值，用于网络请求判断该对象是否还需要回调
	-- self._isCleanup = true
	NormalRoomSceneCtr.onCleanup(self);
end

function PrivateRoomCtr:onLoginRoomSuccess()
	g_RoomInfo:setFlag(g_RoomInfo.ROOM_TYPE_PRIVATE)
	g_RoomInfo:setRoomType(g_RoomInfo.ROOM_TYPE_PRIVATE)
	NormalRoomSceneCtr.onLoginRoomSuccess(self)
end


return PrivateRoomCtr;