--[[--ldoc desc
@module FriendCtr
@author ReneYang
Date   2018-11-19
]]
local FriendVO = require("FriendVO")
local FriendManager = require('FriendManager')
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local FriendCtr = class("FriendCtr",PopupCtr);
local HttpCmd = import("app.config.config").HttpCmd

BehaviorExtend(FriendCtr);

---配置事件监听函数
FriendCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
	-- 与UI的通信调用参见PopupCtr.updateView函数	
	[g_SceneEvent.FRIEND_GIVE_CHIPS]	 =  "sendChips",
	[g_SceneEvent.FRIEND_DELETE_FRIEND]	 =  "deleteFriend",
}

function FriendCtr:ctor()
	PopupCtr.ctor(self);
	FriendManager.getInstance() -- 初始化FriendManager
end
function FriendCtr:onEnter()
	PopupCtr.onEnter(self, true)
end
function FriendCtr:onExit()
	PopupCtr.onExit(self, true)
end

function FriendCtr:show()
	PopupCtr.show(self)
	self:registerEvent()
	self:requestFriendList()
end

function FriendCtr:hidden()
	PopupCtr.hidden(self)
	self:unRegisterEvent()
end

function FriendCtr:onCleanup()
	PopupCtr.onCleanup(self);
	
end

-- 获取好友列表
function FriendCtr:requestFriendList()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_LIST)
	g_HttpManager:doPost(params, self, self.onFriendListResponse)
end
function FriendCtr:onFriendListResponse(isSuccess,result)
	Log.d("FriendCtr:onFriendListResponse", "result = ",result)
	local friendList = {}
    if g_TableLib.isTable(result) then
        if result == nil then 
            Log.d(FriendModule.TAG, "result is nil");
            return;
        end

        local i = 1;
        for i = 1, #result do
            local vo = FriendVO:create()
            vo:parse(result[i])
            friendList[i] = vo
        end
	end
	self.m_friendList = friendList
	self:updateView(g_SceneEvent.FRIEND_REQUEST_FRIEND_LIST, friendList)
end

-- 赠送好友筹码
function FriendCtr:sendChips(friend)
	if friend then
		local params = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_GIVECHIPSNEW)
        params.touid = friend.uid
		g_HttpManager:doPost(params, self, self.giveChipCallback);
	end
end

function FriendCtr:giveChipCallback(isSuccess, result, param)
    if isSuccess and g_TableLib.isTable(result) then
        if result.ret == 0 then    
			g_AlertDialog.getInstance()
				:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
				:setContent(GameString.get("str_friend_give_chip_too_poor"))
				:setTitle(GameString.get("tips"))
				:setLeftBtnTx(GameString.get("cancel"))
				:setRightBtnTx(GameString.get('str_friend_go_to_store'))
				:setRightBtnFunc(function()
					-- 去商场  待补充

				end)
				:show()

        elseif result.ret == 1 then
			g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_friend_give_chip_count_out"))
		elseif result.ret == 2 then
			local friend, index = self:getFriendByUid(param.touid)
			if friend and index > -1 then
				-- body
				g_AlarmTips.getInstance():setTextAndShow(string.format(GameString.get("str_friend_give_chip_success"), friend.sendChipLimit))
				self.m_friendList[index].sendChipTimes = self.m_friendList[index].sendChipTimes - 1
				self:updateView(g_SceneEvent.FRIEND_REFRESH_ITEM_DATA, self.m_friendList[index])
			end
            -- self._giveChipFriend.sendChipTimes = self._giveChipFriend.sendChipTimes - 1;
            -- if self.m_data == self._giveChipFriend then
            --     self.m_btnGiveChips:setEnable(self._giveChipFriend.sendChipTimes > 0);
            -- end

		else
			local tip = GameString.get('str_login_bad_network')
			if g_AppManager:isDebug() then
				tip = tip.." FriendCtr.giveChipCallback , 111"
			end
			g_AlarmTips.getInstance():setTextAndShow(tip)
        end
	else
		local tip = GameString.get('str_login_bad_network')
			if g_AppManager:isDebug() then
				tip = tip.." FriendCtr.giveChipCallback ,222"
			end
		g_AlarmTips.getInstance():setTextAndShow(tip)
    end
    self._giveChipFriend = nil;
end

-- 删除好友
function FriendCtr:deleteFriend(friend)
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_DELPOKER)
	params.fuid = friend.uid
	g_HttpManager:doPost(params, self, self.deleteFriendCallback);
end

function FriendCtr:deleteFriendCallback(isSuccess, result, params)
	if tonumber(result) == 1 then
		local uid = params.fuid
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_friend_delete_friend_success'))
		-- 删除数据 刷新好友列表
		if g_TableLib.isTable(self.m_friendList) then
			local _, index = self:getFriendByUid(uid)
			if index > -1 then
				table.remove(self.m_friendList, index);
				self:updateView(g_SceneEvent.FRIEND_DELETE_FRIEND_SUCCESS, index)
			end
		end
		local friendList = g_Model:getData(g_ModelCmd.FRIEND_UID_LIST)
		table.removebyvalue(friendList, tostring(uid), true)
		g_Model:setData(g_ModelCmd.FRIEND_UID_LIST,friendList)
	else
		g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_friend_delete_friend_fail'))
	end
end

-- 根据uid获取好友列表中对应的好友及其在列表中的index
function FriendCtr:getFriendByUid(uid)
	if g_TableLib.isTable(self.m_friendList) then
		for i = 1, #self.m_friendList do
			if self.m_friendList[i].uid == uid then
				return self.m_friendList[i], i
			end
		end
	end
	return nil, -1
end

return FriendCtr;