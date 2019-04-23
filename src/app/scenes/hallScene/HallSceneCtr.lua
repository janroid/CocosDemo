--[[--ldoc desc
@module HallSceneCtr
@author WuHuang
Date   2018-10-25
]]

local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HallSceneCtr = class("HallSceneCtr",ViewCtr);
local HallScene = require(".HallScene")
BehaviorExtend(HallSceneCtr);

---配置事件监听函数
HallSceneCtr.s_eventFuncMap =  {
	[g_SceneEvent.HALL_REQUEST_BANNER]			= "requestBannerImages",
}


function HallSceneCtr:ctor()
	ViewCtr.ctor(self);
end

function HallSceneCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

function HallSceneCtr:onEnter()
	print("HallSceneCtr:onEnter")
end

---刷新UI
-- function HallSceneCtr:updateView(data)
-- 	local ui = self:getUI();
-- 	if ui and ui.updateView then
-- 		ui:updateView(data);
-- 	end
-- end

-- UI触发的逻辑处理
function HallSceneCtr:haldler(status,...)
	-- if status == "onMailBtnClicked" then
		-- print(status)
	-- end
	if HallSceneCtr.s_controlFuncMap[tonumber(status)] then
		HallSceneCtr.s_controlFuncMap[tonumber(status)](self, ...)
	end
end

function HallSceneCtr:requestBannerImages()
	g_HttpManager:doPost({["mod"] = "banner", ["act"] = "show"}, self, self.BannerCallBack, self.BannerCallBack, "getBannerData");
end

function HallSceneCtr:BannerCallBack(data)
    if data ~= nil then
        local bannerData, flag = g_JsonUtil.decode(data);
		self:updateView(g_SceneEvent.HALL_REQUEST_BANNER_SUCCESS,bannerData or {})
    end
end

return HallSceneCtr;