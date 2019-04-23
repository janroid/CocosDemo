--[[--ldoc desc
@module RankCtr
@author ReneYang
Date   2018-11-30
]]
local RankingVO = require('RankingVO')
local HttpCmd = import("app.config.config").HttpCmd
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local RankCtr = class("RankCtr",PopupCtr);
BehaviorExtend(RankCtr);

RankCtr.SORT_BY_MONEY             = "SORT_BY_MONEY";
RankCtr.SORT_BY_EXP               = "SORT_BY_EXP";
RankCtr.SORT_BY_LEVEL             = "SORT_BY_LEVEL";
RankCtr.SORT_BY_MTT               = "SORT_BY_MTT";

---配置事件监听函数
RankCtr.s_eventFuncMap =  {
	-- ["EventKey"] = "FuncName"
	-- EventKey必须定义在SceneEvent.lua中
    -- 与UI的通信调用参见PopupCtr.updateView函数	
    [g_SceneEvent.RANKPOP_TAB_CHANGED] = "onRankingTabChanged";
}

function RankCtr:ctor()
    PopupCtr.ctor(self);
    self.m_myAchiData              = 0;
    self.m_myMttData               = 0;
    self.m_myCompAchiData          = nil;
end

function RankCtr:show()
	PopupCtr.show(self)
    self:getData()
end

function RankCtr:hidden()
	PopupCtr.hidden(self)
end

function RankCtr:onCleanup()
	PopupCtr.onCleanup(self);
	-- xxxxxx
end

function RankCtr:getData()
	self:getAllRankingData()
end

-- 获取全部排行数据
function RankCtr:getAllRankingData()
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.RANK_MAIN)
	g_HttpManager:doPost(params, self, self.onAllRankingDataResp)
end
function RankCtr:onAllRankingDataResp(isSuccess,data)
    local jsonObj, flag = data,isSuccess
    if flag and g_TableLib.isTable(jsonObj) then
        self:getFriendRankingData()
        if jsonObj ~= nil then
            local rankingVO = nil;
            if not g_TableLib.isEmpty(jsonObj.money) then
                self.m_moneyRankList = {};
                for _, obj in pairs(jsonObj.money.list) do
                    rankingVO = RankingVO:create(obj)
                    table.insert(self.m_moneyRankList, rankingVO);
                end

                local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_ALL_MONEY_RANKLIST)
                self:cacheRankInfo(g_UserDefaultCMD.RANK_ALL_MONEY_RANKLIST, self.m_moneyRankList)
                --比较得出升降
		        self:compareRankingOrder(cache, self.m_moneyRankList);
                if self.m_moneyRankList and #self.m_moneyRankList > 0 then
                    self.m_moneyRanking = (jsonObj.money.rank ~= nil and tonumber(jsonObj.money.rank) <= 10000) and jsonObj.money.rank or ">10000";
                    self.m_moneyRankingDesc = self:formateEnc(
                        g_MoneyUtil.skipMoney(jsonObj.money.c_d - jsonObj.money.data), 
                        jsonObj.money.c_r, 
                        jsonObj.money.rank, 0, 0);
                end
            end
                
            if not g_TableLib.isEmpty(jsonObj.exp) then
                self.m_expRankList = {};
                for _, obj in pairs(jsonObj.exp.list) do
                    rankingVO = RankingVO:create(obj)
                    table.insert(self.m_expRankList, rankingVO);
                end

                local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_ALL_LEVEL_RANKLIST)
                self:cacheRankInfo(g_UserDefaultCMD.RANK_ALL_LEVEL_RANKLIST, self.m_expRankList)
                --比较得出升降
		        self:compareRankingOrder(cache, self.m_expRankList);

                if self.m_expRankList ~= nil and #self.m_expRankList > 0 then
                    self.m_expRanking = (jsonObj.exp.rank ~= nil and tonumber(jsonObj.exp.rank) <= 10000) and jsonObj.exp.rank or ">10000";
                    if jsonObj.exp.c_d == nil then
                        if jsonObj.exp.data == nil then
                            jsonObj.exp.c_d = 0;
                            jsonObj.exp.data = 0;
                        else
                            jsonObj.exp.c_d = jsonObj.exp.data;
                        end
                    end
                    self.m_expRankingDesc = self:formateEnc(
                        g_MoneyUtil.skipMoney(jsonObj.exp.c_d - jsonObj.exp.data), jsonObj.exp.c_r, jsonObj.exp.rank, 1, 0);
                end
            end
                
            if not g_TableLib.isEmpty(jsonObj.achi) then
                self.m_achiRankList = {};
                for _, obj in pairs(jsonObj.achi.list) do
                    self.m_rankingVO = RankingVO:create(obj)
                    table.insert(self.m_achiRankList, self.m_rankingVO);
                end

                local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_ALL_ACHIEVEMENT_RANKLIST)
                self:cacheRankInfo(g_UserDefaultCMD.RANK_ALL_ACHIEVEMENT_RANKLIST, self.m_achiRankList)
                --比较得出升降
		        self:compareRankingOrder(cache, self.m_achiRankList);

                if self.m_achiRankList ~= nil and #self.m_achiRankList > 0 then
                    self.m_achiRanking = (jsonObj.achi.rank ~= nil and tonumber(jsonObj.achi.rank) <= 10000) and jsonObj.achi.rank or ">10000";
                    self.m_achiRankingDesc = self:formateEnc(
                        g_MoneyUtil.skipMoney(jsonObj.achi.c_d - jsonObj.achi.data), 
                        jsonObj.achi.c_r, 
                        jsonObj.achi.rank, 2, 0);
                    
                    self.m_myAchiData = jsonObj.achi.data;
                    
                    if self.m_myCompAchiData ~= nil then
                        self.m_myAchiOfFriendDesc = self:formateEnc(
                            g_MoneyUtil.skipMoney(self.m_myCompAchiData.m_ach - self.m_myAchiData), 
                            self.m_myCompAchiData.friendRanking, 
                            (self.m_myCompAchiData.m_uid == tonumber(g_AccountInfo:getId())) and 1 or self.m_myCompAchiData.friendRanking, 2, 1);
                    end
                end
            end

            self.m_mttRankList = {};
            self.m_mttRanking = 0;
            if not g_TableLib.isEmpty(jsonObj.mtt) then
                for _, obj in pairs(jsonObj.mtt.list) do
                    self.m_rankingVO = RankingVO:create(obj)
                    table.insert(self.m_mttRankList, self.m_rankingVO);
                end

                local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_ALL_MTT_RANKLIST)
                self:cacheRankInfo(g_UserDefaultCMD.RANK_ALL_MTT_RANKLIST, self.m_mttRankList)
                --比较得出升降
                self:compareRankingOrder(cache, self.m_mttRankList);
                
                if self.m_mttRankList ~= nil and #self.m_mttRankList > 0 then
                    self.m_mttRanking = (jsonObj.mtt.rank ~= nil and tonumber(jsonObj.mtt.rank) <= 10000) and jsonObj.mtt.rank or ">10000";
                    local tempDiff = jsonObj.mtt.c_d - jsonObj.mtt.data;
                    if tempDiff == 0 and jsonObj.mtt.rank > 1 then
                        tempDiff = 1;
                    end
                    self.m_mttRankingDesc = self:formateEnc(
                        g_MoneyUtil.skipMoney(tempDiff),
                        jsonObj.mtt.c_r, 
                        jsonObj.mtt.rank, 3, 0);
                end

                self.m_myMttData = jsonObj.mtt.data;
                if self.m_myCompMttData ~= nil then
                    local tempDiff = self.m_myCompMttData.m_score - self.m_myMttData;
                    if tempDiff == 0 and self.m_myCompMttData.friendRanking > 1 then
                        tempDiff = 1;
                    end
                    self.m_myMttOfFriendDesc = self:formateEnc(
                        g_MoneyUtil.skipMoney(tempDiff),
                        self.m_myCompMttData.friendRanking,
                        (self.m_myCompMttData.m_uid == tonumber(g_AccountInfo:getId())) and 1 or self.m_myMttOfFriendRanking, 3, 1);
                end
            end

        end
        self:onRankingTabChanged(1,1)
    else
        Log.e(self.TAG, "onRefreshRankingDataResult", "decode json has an error occurred!");
    end
end

-- 获取好友排行数据
function RankCtr:getFriendRankingData()
    local params = HttpCmd:getMethod(HttpCmd.s_cmds.FRIEND_LIST)
    g_HttpManager:doPost(params,self, self.onFriendRankingDataResp)
end
function RankCtr:onFriendRankingDataResp(isSuccess,data)
    local jsonObj, flag = data, isSuccess
    if flag and g_TableLib.isTable(jsonObj) then
		if(g_AppManager:isDebug() and g_SystemInfo:getDevice() == "win32") then
			local f = io.open("d:/home_ranking2.txt", "w");
			if(f) then
				f:write(tostring(g_JsonUtil.encode(data)));
				f:close();
			end
        end
        
        
		local rankingVO, selfVO
		self.m_friendMoneyRankList  = {};
		self.m_friendExpRankList    = {};
		self.m_friendAchiRankList   = {};
		self.m_friendMttRankList    = {};
		
		for _, obj in ipairs(jsonObj) do 
			rankingVO = RankingVO:create(obj,0,nil,1);
			table.insert(self.m_friendMoneyRankList, rankingVO);
		end
		
		for _, obj in ipairs(jsonObj) do
			rankingVO = RankingVO:create(obj, 1);
			table.insert(self.m_friendExpRankList, rankingVO);
		end
		
		for _, obj in ipairs(jsonObj) do
			rankingVO = RankingVO:create(obj, 2);
			table.insert(self.m_friendAchiRankList, rankingVO);
		end
		
		for _, obj in ipairs(jsonObj) do
			rankingVO = RankingVO:create(obj, 3);
			table.insert(self.m_friendMttRankList, rankingVO);
		end				
		
		--加入自己再排序（资产排序）
		rankingVO, selfVO = self:addSelfAndSort(self.m_friendMoneyRankList, self.SORT_BY_MONEY,0);
        local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_MONEY_RANKLIST)
        self:cacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_MONEY_RANKLIST, self.m_friendMoneyRankList)
        --比较得出升降
		self:compareRankingOrder(cache, self.m_friendMoneyRankList);
		self.m_myMoneyOfFriendDesc = self:formateEnc(
			g_MoneyUtil.skipMoney((rankingVO.m_chipTotal or 0) - (g_AccountInfo:getMoney() or 0)), 
			rankingVO.friendRanking,
            selfVO.friendRanking , 0, 1);
				
		--加入自己再排序（等级排序）
		rankingVO, selfVO = self:addSelfAndSort(self.m_friendExpRankList, self.SORT_BY_EXP, 1);
        
        local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_LEVEL_RANKLIST)
        self:cacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_LEVEL_RANKLIST, self.m_friendExpRankList)
		--比较得出升降
        self:compareRankingOrder(cache, self.m_friendExpRankList);
        local dexp = rankingVO.m_exp - g_AccountInfo:getUserExp()
       -- print("dexp ",dexp,rankingVO.m_exp,g_AccountInfo:getUserExp())
        dexp = dexp > 0 and dexp or - dexp
		self.m_myExpOfFriendDesc = self:formateEnc(
			g_MoneyUtil.skipMoney(dexp),
			rankingVO.friendRanking,
            selfVO.friendRanking, 1, 1);
				
		--加入自己再排序（成就排序）
		rankingVO, selfVO = self:addSelfAndSort(self.m_friendAchiRankList, self.SORT_BY_LEVEL, 2);
        
        local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_ACHIEVEMENT_RANKLIST)
        self:cacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_ACHIEVEMENT_RANKLIST, self.m_friendAchiRankList)
		--比较得出升降
		self:compareRankingOrder(cache, self.m_friendAchiRankList);
		self.m_myCompAchiData = rankingVO;
		self.m_myAchiOfFriendDesc = self:formateEnc(
			g_MoneyUtil.skipMoney(rankingVO.m_ach - self.m_myAchiData), 
			rankingVO.friendRanking,
            selfVO.friendRanking, 2, 1);
		
		--加入自己再排序（成就排序）
		rankingVO, selfVO = self:addSelfAndSort(self.m_friendMttRankList, self.SORT_BY_MTT, 3);
        
        local cache = self:getCacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_MTT_RANKLIST)
        self:cacheRankInfo(g_UserDefaultCMD.RANK_FRIEND_MTT_RANKLIST, self.m_friendAchiRankList)
		--比较得出升降
		self:compareRankingOrder(cache, self.m_friendMttRankList);
		self.m_myCompMttData = rankingVO;
		local tempDiff = rankingVO.m_score - self.m_myMttData;
		if tempDiff == 0 and rankingVO.friendRanking > 1 then
			tempDiff = 1;
		end
		self.m_myMttOfFriendDesc = self:formateEnc(
			g_MoneyUtil.skipMoney(tempDiff),
			rankingVO.friendRanking, 
            (rankingVO.uid == tostring(g_AccountInfo:getId())) and 1 or self.m_myMttOfFriendRanking, 3, 1);
    end
end

function RankCtr:ToStringEx(value)
    if type(value)=='table' then
       return self:TableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end
function RankCtr:TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..self:ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..self:ToStringEx(key).."]="..self:ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..self:TableToStr(getmetatable(key)).."*e".."="..self:ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..self:ToStringEx(value)
                end
            end
        end

        i = i+1
    end

     retstr = retstr.."}"
     return retstr
end

-- 缓存排行信息
function RankCtr:cacheRankInfo(key, data)
    if g_TableLib.isEmpty(data) or not key then
        return
    end
    local cacheList = {}
    for i=1,#data do
        if data[i] then
            local temp = {
                uid = data[i].m_uid,
                rank = i,
            }
            table.insert(cacheList, temp)
        end
    end
    local str = g_JsonUtil.encode(cacheList)
    cc.UserDefault:getInstance():setStringForKey(key,tostring(str))
end
function RankCtr:getCacheRankInfo(key)
    local data = cc.UserDefault:getInstance():getStringForKey(key, "")
    if data then
        return g_JsonUtil.decode(data)
    end
    return nil
end

--[Comment]
-- mainTab 0:筹码，1：经验， 2：等级，3：积分
-- 新版全服排行榜的鼓励文字
function RankCtr:formateEnc(value, comRank, myRank, mainTab, viceTab)
    local comRankText = tostring(comRank);
    local text = nil;
	local key = 1
	if tonumber(myRank) == 1 then
        if mainTab == 0 then
            key = (viceTab == 0) and 1 or 2
        elseif mainTab == 1 then
            key = (viceTab == 0) and 3 or 4
        elseif mainTab == 2 then 
            key = (viceTab == 0) and 5 or 6
        else
            key = (viceTab == 0) and 13 or 14
        end
		text = GameString.get("str_rank_ranking_format_resource_"..key)
    elseif comRank == 1 then
        if mainTab == 0 then
            key = 7
        elseif mainTab == 1 then
            key = 8
        elseif mainTab == 2 then
            key = 9
        else
            key = 15
        end
		text = g_StringLib.substitute(GameString.get("str_rank_ranking_format_resource_"..key), value, comRankText)
    else
        if mainTab == 0 then
            key = 10
        elseif mainTab == 1 then
            key = 11
        elseif mainTab == 2 then
            key = 12
        else 
            key = 16
		end
		text = g_StringLib.substitute(GameString.get("str_rank_ranking_format_resource_"..key), value, comRankText)
    end
	
    return text;
end

function RankCtr:getSelfInfo()
    local selfTable = {
        money     = g_AccountInfo:getMoney(),
        img       = g_AccountInfo:getSmallPic(),
        level     = g_AccountInfo:getUserLevel(),
        nick      = g_AccountInfo:getNickName(),
        title     = g_AccountInfo:getTitle(),
        uid       = g_AccountInfo:getId(),
        ach       = self.m_myAchiData;
        score     = self.m_myMttData;
    }
    return selfTable
end

function RankCtr:addSelfAndSort(list,sortType, index)
    local rankingVO           = RankingVO:create()
    rankingVO.m_chipTotal     = g_AccountInfo:getMoney()
    rankingVO.m_img           = g_AccountInfo:getSmallPic()
    rankingVO.m_level         = g_AccountInfo:getUserLevel()
    rankingVO.m_nick          = g_AccountInfo:getNickName()
    rankingVO.m_levelName     = g_AccountInfo:getTitle()
    rankingVO.m_siteid        = tostring(g_AccountInfo:getSiteuid());
    rankingVO.m_uid           = tostring(g_AccountInfo:getId());
    rankingVO.m_winPercent    = g_AccountInfo:getWinRate()
    rankingVO.m_ach           = self.m_myAchiData;
    rankingVO.m_score         = self.m_myMttData;
    rankingVO.m_exp = g_AccountInfo:getUserExp()
    self.m_rankingVO = rankingVO;
    
    if index == 1 then
        rankingVO.m_chipTotal     = rankingVO.m_level
    elseif index == 2 then
        rankingVO.m_chipTotal     = rankingVO.m_ach
    elseif index == 3 then
        rankingVO.m_chipTotal     = rankingVO.m_score
    end
    
    --把自己加进去
    table.insert(list, rankingVO);
    
    self.m_sortType = (sortType == "") and  self.SORT_BY_MONEY or sortType;

    --进行一下排序
    list =  g_TableLib.quickSort(list, self, self.__sortFunc);
            
    --找到自己的位置
    local retData = nil;
    local found = false;
    for i = 1, #list do
        list[i].friendRanking = i;
        if not found and list[i] == self.m_rankingVO then
            found = true;
            if sortType == "" or self.m_sortType == self.SORT_BY_MONEY then
                self.m_myMoneyOfFriendRanking = tostring(i);
            
            elseif sortType == self.SORT_BY_EXP then
                self.m_myExpOfFriendRanking = tostring(i);
            
            elseif sortType == self.SORT_BY_LEVEL then
                self.m_myAchiOfFriendRanking = tostring(i);

            elseif sortType == self.SORT_BY_MTT then
                self.m_myMttOfFriendRanking = tostring(i);
            end

            if i > 30 then          
                retData = list[30];-- 三十名开外，跟30
            elseif i == 1 then 
                retData = list[1];-- 第一名返回自己
            else
                retData = list[i - 1]; --否则返回前一名
            end
        end
    end
    
    list[31] = nil;
    return retData, rankingVO;
end

-- 比较上一次的排名与此次的排名是否有变化
function RankCtr:compareRankingOrder(lastData, list)
    if lastData ~= nil and list ~= nil then 
        local src  = nil;
        local desc = nil;
        local found = false;
        for i = 1, #list do
            src = list[i];
            for j = 1, #lastData do
                desc = lastData[j];
                if g_TableLib.isTable(src) then
                    if src.m_uid == desc.uid then
                        found = true;
                        src.upOrDown = (i < desc.rank) and "up" or (i > desc.rank and "down" or "");
                        break;
                    end
                end
            end
            --找不到证明之前没上榜，这次为上升
            if not found and src then
                src.upOrDown = "up";
            end
        end
    end
end

function RankCtr:__sortFunc(obj1, obj2)
    local ret = 0;
    local sub = 0; 
    if self.m_sortType == self.SORT_BY_MONEY then
        obj1.m_chipTotal = obj1.m_chipTotal or 0;
        obj2.m_chipTotal = obj2.m_chipTotal or 0;
        sub = obj1.m_chipTotal - obj2.m_chipTotal;

    elseif self.m_sortType == self.SORT_BY_EXP then
        obj1.m_exp = obj1.m_exp or 0;
        obj2.m_exp = obj2.m_exp or 0;
        sub = obj1.m_exp - obj2.m_exp;
    
    elseif self.m_sortType == self.SORT_BY_LEVEL then
        obj1.m_ach = obj1.m_ach or 0;
        obj2.m_ach = obj2.m_ach or 0;
        sub = obj1.m_ach - obj2.m_ach;

    elseif self.m_sortType == self.SORT_BY_MTT then
        obj1.m_score = obj1.m_score or 0;
        obj2.m_score = obj2.m_score or 0;
        sub = obj1.m_score - obj2.m_score;
    end

    if sub == 0 then
        --当遇到与自己筹码数目相等的，把自己放到前面
        if obj1.uid == self.m_rankingVO.uid then
            ret = - 1;
        elseif obj2.uid == self.m_rankingVO.uid then
            ret = 1;
        else
            ret = 0;
        end
    elseif sub > 0 then
        ret = -1;
    else
        ret = 1;
    end
    return ret;
end

function RankCtr:onRankingTabChanged(verticalTab, horizonTab)
    local myRank = {}
    local data = {}  
    if horizonTab == 1 then -- 世界排行
        if verticalTab == 1 then
            myRank.rank = self.m_moneyRanking
            myRank.desc = self.m_moneyRankingDesc
            data = self.m_moneyRankList
        elseif verticalTab == 2 then
            myRank.rank = self.m_expRanking
            myRank.desc = self.m_expRankingDesc
            data = self.m_expRankList
        elseif verticalTab == 3 then
            myRank.rank = self.m_achiRanking
            myRank.desc = self.m_achiRankingDesc
            data = self.m_achiRankList
        else
            myRank.rank = self.m_mttRanking
            myRank.desc = self.m_mttRankingDesc
            data = self.m_mttRankList
        end
    else -- 好友排行
        if verticalTab == 1 then
            myRank.rank = self.m_myMoneyOfFriendRanking
            myRank.desc = self.m_myMoneyOfFriendDesc
            data = self.m_friendMoneyRankList
        elseif verticalTab == 2 then
            myRank.rank = self.m_myExpOfFriendRanking
            myRank.desc = self.m_myExpOfFriendDesc
            data = self.m_friendExpRankList
        elseif verticalTab == 3 then
            myRank.rank = self.m_myAchiOfFriendRanking
            myRank.desc = self.m_myAchiOfFriendDesc
            data = self.m_friendAchiRankList
        else
            myRank.rank = self.m_myMttOfFriendRanking
            myRank.desc = self.m_myMttOfFriendDesc
            data = self.m_friendMttRankList
        end
    end
    g_Model:setProperty(g_ModelCmd.RANK_MY_INFO, "my_rank", myRank)
    g_Model:setData(g_ModelCmd.RANK_LIST_DISPLAY, data)
end
return RankCtr;