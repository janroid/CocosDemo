--[[--ldoc desc
@module MttLobbyScene
@author CavanZhou

Date   2019-1-2
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local MttLobbySceneCtr = class("MttLobbySceneCtr",ViewCtr);
MttLobbySceneCtr.s_nowTime = 0;	--全局的倒计 秒

---配置事件监听函数
MttLobbySceneCtr.s_eventFuncMap =  {
}

function MttLobbySceneCtr:ctor(view)
	ViewCtr.ctor(self);
	require("MttManager").getInstance():clear()
end

function MttLobbySceneCtr:onCleanup()
	require("MttManager").getInstance():clear()
	ViewCtr.onCleanup(self);
end

-- UI触发的逻辑处理
function MttLobbySceneCtr:haldler(status,...)
	if MttLobbySceneCtr.s_controlFuncMap[tonumber(status)] then
		MttLobbySceneCtr.s_controlFuncMap[tonumber(status)](self, ...)
	end
end

return MttLobbySceneCtr;