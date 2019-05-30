--[[--ldoc desc
@module HallScene
@author %s

Date   %s
]]
local ViewScene = require("framework.scenes.ViewScene");
local HallScene = class("HallScene",ViewScene);
local HallCtr = import("HallCtr")

---配置事件监听函数
HallScene.s_eventFuncMap =  {
	[g_CustomEvent.UPDATE_USERINFO] = "initInfo"
}

function HallScene:ctor()
	ViewScene.ctor(self)
	self:bindCtr(HallCtr)

	self:init()
end

function HallScene:init()
	self:loadLayout("creator/layout/hall.ccreator")  

	self.m_btnQuick:addClickEventListener(function()
		local id = g_AccountInfo.getInstance():getUid()
		local param = {
			Uid = id,
			Fields = 0
		}
		g_NetManager.getInstance():sendSocketMsg(g_GamePb.method.ReqUserInfo, param)
	end)

	self.m_btnMsg:addClickEventListener(function()

	end)

	self.m_btnJob:addClickEventListener(function()
		
	end)

end

function HallScene:initInfo()
	local u = g_AccountInfo.getInstance()
	self.m_txName:setString(u:getName())
	self.m_txMid:setString(u:getUid())
	self.m_txMoney:setString(u:getMoney())
	self.m_txDiamon:setString(u:getGold())

	local lev, progress = u:getLevel()
	self.m_txLevel:setString(lev)

	self.m_ldLevel:setPercent(progress)

	self.m_btnIcon:loadTextureNormal(u:getIcon())
end

function HallScene:onEnter()
	ViewScene.onEnter(self)
	self:initInfo()
end

function HallScene:onExit()
	ViewScene.onExit(self)
	-- do something
	--[[
		退出当前场景时会被调用
		和onEnter方法相对应
		该方法可以理解为公司引擎：pause方法
	]]
end


function HallScene:onCleanup()
	ViewScene.onCleanup(self)
	--[[
		场景销毁前会被调用
		资源销毁相关代码可以放置于该方法内。	
	]]

end

return HallScene;