--[[--ldoc desc
@module AchievementCtr
@author MenuZhang
Date   2018-11-1
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AchievementCtr = class("AchievementCtr",PopupCtr);
BehaviorExtend(AchievementCtr);

---配置事件监听函数
AchievementCtr.s_eventFuncMap =  {
	[g_SceneEvent.REQUEST_USER_GLORY] = "requestUserGlory";  -- 请求用户成就数据
	[g_SceneEvent.REQUEST_USER_STATISTICS] = "requestUserStatistics";  -- 请求用户统计数据
}

function AchievementCtr:ctor()
	PopupCtr.ctor(self);
end

function  AchievementCtr:requestUserGlory()
	g_Progress.getInstance():show()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_GETUSERCHENGJIU)
	g_HttpManager:doPost(params, self, self.loadUserGloryCallback, function()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
		g_Progress.getInstance():dismiss()
	end);
end

function  AchievementCtr:loadUserGloryCallback(isSuccess,data)	
	g_Progress.getInstance():dismiss()
	data = data or {}
	if isSuccess then
		-- Log.d("AchievementCtr:loadUserGloryCallback",isSuccess,data)
		local groups = {};
		local gloryGroups = {}
		local matchGroups = {}
		local context           = {};
        context.allCount        = 0;
        context.getCount        = 0;
        context.goldCount       = 0;
        context.silverCount     = 0;
        context.copperCount     = 0;
        context.goldAllCount    = 0;
        context.silverAllCount  = 0;
        context.copperAllCount  = 0;
		local config = g_Model:getData(g_ModelCmd.DATA_ACHIEVE_INFO)
		local achieveConfig = {}
		if  config and not g_TableLib.isEmpty(config) then
			achieveConfig = config:getConfig()
		end
		local ret = {};
		for i = 1, #achieveConfig do
			local item = achieveConfig[i];
			if tonumber(item.a)< 2000 then
				local gloryItem,context = self:calcGlory(item,data,context)
				table.insert( gloryGroups, gloryItem )
			end
			if tonumber(item.a) > 3000 and tonumber(item.a) < 4000 then
				local matchItem,context = self:calcGlory(item,data,context)
				table.insert( matchGroups, matchItem )
			end
		end
		groups.gloryData = gloryGroups
		groups.matchData = matchGroups
		-- Log.d("AchievementCtr,loadUserGloryCallback",groups)
		g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_GLORY_SUCCESS,groups)
		-- g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_GLORY_SUCCESS,gloryGroups)
	else
		g_Progress.getInstance():dismiss()
		g_AlarmTips.getInstance():setText(GameString.get("str_login_bad_network")):show()
    end
end


function AchievementCtr:calcGlory(item, gloryData,context)
	local gloryItem = {}
	gloryItem.m_id = tonumber(item.a);
	gloryItem.m_title         = item.b;
	gloryItem.m_description   = GameString.get("str_achi_destination") .. item.c;
	if item.f ~= nil and item.f ~= "" then
        gloryItem.m_reward    =  GameString.get("str_achi_reward") .. item.f;
	end
	gloryItem.m_isLocked = true; --  默認為true
	local flag = tonumber(item.e);
    if flag == 1 then
		gloryItem.m_type = 2;

    elseif flag == 2 then
        gloryItem.m_type = 1;

    elseif flag == 3 then
        gloryItem.m_type = 0;
	end

	for i,value in pairs(gloryData) do
		if value and type(value) == "table" and value.a == gloryItem.m_id then
			if value.c ~= 0 then
                --已经达成
                gloryItem.m_isLocked = false;
                --已经领奖
                gloryItem.m_hasClaimed = (value.b == 1);
                context.getCount = context.getCount;
                if flag == 1 then
                    context.copperCount = context.copperCount + 1;

                elseif flag == 2 then
                    context.silverCount = context.silverCount + 1;

                elseif flag == 3 then
                    context.goldCount = context.goldCount + 1;
                
                end
            else 
                --有进度未获得
                gloryItem.m_isLocked = true;
                if item.g ~= 0 then
                    gloryItem.m_progressNum = value.d .. "/" .. item.g;
                end

                if value.d ~= "" then
                    gloryItem.m_hasProgress = true;
                    local now = tonumber(value.d);
                    local all = tonumber(item.g);
                    local percent = now / all;
                    gloryItem.m_progress = tonumber(string.format("%.2f", percent));
                end
            end
		end
	end
	if flag ==  1 then
        context.copperAllCount = context.copperAllCount + 1;

    elseif flag ==  2 then
        context.silverAllCount = context.silverAllCount + 1;

    elseif flag == 3 then
        context.goldAllCount = context.goldAllCount + 1;
    end
	context.allCount = context.allCount + 1;
	
	return gloryItem,context
end

function  AchievementCtr:requestUserStatistics()
	local param = HttpCmd:getMethod(HttpCmd.s_cmds.USER_GETPOKERSTAT)
	g_HttpManager:doPost(param, self, self.loadStatCallback, self.defaultStatErrorHandler);
end

function AchievementCtr:loadStatCallback(isSuccess,data)
	-- local data, flag = g_JsonUtil.decode(data);
	
	if isSuccess and not g_TableLib.isEmpty(data) then
		-- Log.d("AchievementCtr:loadStatCallback",isSuccess,data)
		-- self:setStatData(data)
		g_EventDispatcher:dispatch(g_SceneEvent.REQUEST_USER_STATISTICS_SUCCESS,data)
    else
        Log.e("AchievementCtr", "loadStatCallback", "decode json has an error occurred!");
    end
end

function AchievementCtr:onCleanup()
	PopupCtr.onCleanup(self);
	self:unRegisterEvent()
	-- xxxxxx
end

---刷新UI
function AchievementCtr:updateView(data)
	local ui = self:getUI();
	if ui and ui.updateView then
		ui:updateView(data);
	end
end

-- UI触发的逻辑处理
function AchievementCtr:haldler(status,...)
end

return AchievementCtr;