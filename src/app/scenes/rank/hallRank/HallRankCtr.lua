local FriendManager = import('app.scenes.friend').FriendManager
local RankingVO = import('app.scenes.rank.rankMain').RankingVO
local HttpCmd = import("app.config.config").HttpCmd
local ViewCtr = import("framework.scenes").ViewCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HallRankCtr = class("HallRankCtr",ViewCtr);
BehaviorExtend(HallRankCtr);
---配置事件监听函数
HallRankCtr.s_eventFuncMap =  {
	[g_SceneEvent.RANK_HALL_RANKLIST_REQUEST]       = "requestRankList";
	[g_SceneEvent.RANK_HALL_GET_MYRANK]      		= "getMyRankData";
}

function HallRankCtr:ctor()
	ViewCtr.ctor(self);
	self.m_dataUpdateTime = 0
	self.m_hallRankList = {}
	self:requestRankList()
	self:requestOnlineList()
	FriendManager.getInstance() -- 初始化FriendManager
end

function HallRankCtr:onCleanup()
	ViewCtr.onCleanup(self);
	-- xxxxxx
end

function HallRankCtr:requestOnlineList()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_ONLINE_LIST)
	g_HttpManager:doPost(params, self, self.onHallRankOnlineListResp)
end
        
function HallRankCtr:onHallRankOnlineListResp(isSuccess,response)
    if isSuccess and not g_TableLib.isEmpty(response) then
        local rankingVO = nil;
        local uidList   = {};
        for _, item in pairs(response) do
            rankingVO = RankingVO:create(item)
            table.insert(uidList, tostring(rankingVO.m_uid));
        end
        g_Model:setData(g_ModelCmd.FRIEND_UID_LIST, uidList);
    else
        g_Model:setData(g_ModelCmd.FRIEND_UID_LIST, {});
    end
end

function HallRankCtr:requestRankList()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.RANK_MFMONEY)
	params.dataUpdateTime = self.m_dataUpdateTime or 0
	g_HttpManager:doPost(params, self, self.onHallRankListResp)
end

function HallRankCtr:onHallRankListResp(isSuccess,response)
    local rankData,flag = response, isSuccess
	if rankData and not g_TableLib.isEmpty(rankData) and rankData.ret == 1 then
		self.m_dataUpdateTime = rankData.dataUpdateTime;
		if flag and g_TableLib.isTable(rankData) then
            self.m_hallRankList = rankData
			self:updateView(g_SceneEvent.RANK_HALL_RANKLIST_RESPONSE, self.m_hallRankList)
        else
            Log.e(self.TAG, "rankData error, data: ", data, ", err:", err);
        end
    end
end

-- 获取玩家自己的排行榜数据
function HallRankCtr:getMyRankData()
    --if not self.m_myDetailRankData then
		local t = self:getDefaultListData();
		t.uid = g_AccountInfo:getId();
		t.nick = g_AccountInfo:getNickName();
		t.img = g_AccountInfo:getSmallPic() or g_AccountInfo:getMiddlePic() or g_AccountInfo:getBigPic();
		t.rank = 1;
		t.money = g_AccountInfo:getMoney();
		t.level = g_AccountInfo:getUserLevel();
		-- t.ach = math.random(100,200);
		t.score = g_AccountInfo:getScore();
		t.operate = 0;
		self.m_myDetailRankData = t;
	--end
	self:updateView(g_SceneEvent.RANK_HALL_RETURN_MYRANK, self.m_myDetailRankData)
end
function HallRankCtr:getDefaultListData()
	local data = {
		uid          = 0;--用户ID
		nick         = "";--名字
		img          = "";--头像图片
		siteid       = 0;--facebook id
		money        = 0;--玩家筹码
		level        = 0;--玩家等级
		ach          = 0;--玩家成就
		score        = 0;--玩家积分
		stat         = 0;
		ip           = 0;--ip,port用于玩家追踪
		port         = 0;
		tid          = 0;
		win	     	 = 0;--玩家赢的次数
		lose	     = 0;--玩家输的次数
		title	     = 0;--玩家称号
		redis_score  = 0;
	};
	return data;
end
return HallRankCtr;