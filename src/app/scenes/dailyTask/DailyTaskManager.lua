local DailyTaskManager = class("DailyTaskManager")
DailyTaskManager.TAG = "DailyTaskManager";
local TaskVO = require("TaskVO")

DailyTaskManager.getInstance = function()
    if not DailyTaskManager.s_instance then
        DailyTaskManager.s_instance = DailyTaskManager:create();
    end
    return DailyTaskManager.s_instance;

    
end

DailyTaskManager.releaseInstance = function()
    delete(DailyTaskManager.s_instance);
    DailyTaskManager.s_instance = nil;
end

function DailyTaskManager:ctor() 
    self.m_currentPayCount          = 0.0;	    --当前充值数额
    self.m_currentPokerCount        = 0;		--当前玩牌次数
    self.m_dollCurrentPokerCount    = 0;        --玩偶收集玩牌次数
    self.m_currentWinCount          = 0;		--当前获胜次数
    self.m_twoWinningStreak         = 0;		--当前2连胜次数
    self.m_threeWinningStreak       = 0;	    --当前3连胜次数
    self.m_seniorWinCount           = 0;		--高级场胜利次数
    self.m_middleWinCount           = 0;		--中级场胜利次数
    self.m_roundWinChips            = 0;		--某局赢取筹码 
    self.m_usePropCount             = 0;		--使用互动道具次数 
    self.m_sendTableGifts           = 0;		--赠送牌桌礼物次数 
    self.m_enterIntoKnockout        = 0;		--参加单桌淘汰赛次数
    self.m_winKnockout              = 0;		--参加单桌淘汰赛夺冠次数
    self.m_enterIntoTournament      = 0;	    --参加多桌锦标赛次数
    self.m_currentBoxCount          = 0;		--开启宝箱次数
    self.m_useSmallLabasCount       = 0;		--使用小喇叭次数
    self.m_superLottoCount          = 0;		--参加夺金岛次数
    self.m_inviteFriendsCount       = 0;		--邀请好友次数
    self.m_sharesCount              = 0;		--分享次数
    self.m_levelNum                 = 0;        --等级
        
    --春节活动牌局统计
    self.m_newYearPrimaryPokerCount = 0;	    --初级场
    self.m_newYearIntermediatePokerCount = 0;   --中级场
    self.m_newYearSeniorPokerCount  = 0;		--高级场
        
    self.m_allTaskV                 = {};
    self.m_specialTask              = {};
    self.m_roomTaskV                = {};
    self.m_paysTask                 = {};
    self.m_winsTask                 = {};       --赢牌任务
    self.m_twoWinningStreakTask     = {};       --两连胜任务
    self.m_threeWinningStreakTask   = {};       --三连胜任务
    self.m_pokersTask               = {};       --打牌任务
    self.m_roundWinChipsTask        = {};       --赢钱任务
    self.m_middleWinsTask           = {};       --中级场赢牌任务
    self.m_seniorWinsTask           = {};       --高级场赢牌任务
    self.m_giftsTask                = {};       --牌桌送礼任务
    self.m_usePropsTask             = {};       --使用互动道具任务
    self.m_joinKnockoutsTask        = {};       --参加淘汰赛任务
    self.m_joinTournamentsTask      = {};       --参加锦标赛任务
    self.m_winKnockoutsTask         = {};       --赢取淘汰赛任务
    self.m_boxsTask                 = {};       --开宝箱任务
    self.m_useSmallLabasTask        = {};       --使用小喇叭任务
    self.m_superLottosTask          = {};       --夺金岛任务
    self.m_invitesTask              = {};       --邀请任务
    self.m_sharesTask               = {};       --分享任务
    self.m_upgrateLevelTask         = {};       --升级奖励任务
        
    self.m_winningStreak1           = 0;        -- 用于统计连胜
    self.m_winningStreak2           = 0;        -- 用于统计连胜
    self.m_winningStreak3           = 0;        -- 用于一分钟刷分上报
    self.m_winningStreak4           = 0;        -- 用于十连胜刷分上报
    self.m_winningStreak5           = 0;        -- 用于统计五连胜
    self.m_winningStreak6           = 0;        -- 用于统计七连胜
    self.m_currentTime              = 0;
        
    self.m_reGetTimes               = 0;
    self.m_isLoggedIn               = false;
    self.m_finishTask               = 0;
        
    self.m_taskButton               = nil;
    self.m_taskItem                 = nil;
    
    self.m_currentUid               = "";       --当前用户id
    self.m_usedUids                 = {};

    self:initData()

    -- g_Model:watchData(g_ModelCmd.CURRENRT_FINISHED_TASK, self, self.onFinishedTask, false);

    self:regEvents()
end
function DailyTaskManager:dtor()
    self:unregEvents()
    self:cancelWinShceduler()
end


--event

function DailyTaskManager:regEvents()
    g_EventDispatcher:register(g_SceneEvent.UPDATE_USER_LEVEL,self,self.onEventUpdateUserLevel)
    g_EventDispatcher:register(g_SceneEvent.DAILYTASK_EVENT_SHARE_SUCCESS,self,self.onEventShareSuccess)
    g_EventDispatcher:register(g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC,self,self.onEventPropSuccess)
    g_EventDispatcher:register(g_SceneEvent.GIFT_SEND_GIFT_SUCC,self,self.onEventSendGiftSuccess)
    g_EventDispatcher:register(g_SceneEvent.ROOM_CHAT_SMALLL_TRUMPET_SUCCESS,self,self.onEventSendSmallTrumpetSuccess)
    
    
    g_Model:watchData(g_ModelCmd.LOTTO_BUY_SUCCEED,self, self.lottoBuySucceed, false)
end

function DailyTaskManager:unregEvents()

    g_EventDispatcher:unregister(g_SceneEvent.UPDATE_USER_LEVEL,self,self.onEventUpdateUserLevel)
    g_EventDispatcher:unregister(g_SceneEvent.DAILYTASK_EVENT_SHARE_SUCCESS,self,self.onEventShareSuccess)
    g_EventDispatcher:unregister(g_SceneEvent.USERINFOPOP_SEND_PROP_SUCC,self,self.onEventPropSuccess)
    g_EventDispatcher:unregister(g_SceneEvent.GIFT_SEND_GIFT_SUCC,self,self.onEventSendGiftSuccess)
    g_EventDispatcher:unregister(g_SceneEvent.ROOM_CHAT_SMALLL_TRUMPET_SUCCESS,self,self.onEventSendSmallTrumpetSuccess)

    g_Model:unwatchData(g_ModelCmd.LOTTO_BUY_SUCCEED,self, self.lottoBuySucceed)
end



function DailyTaskManager:lottoBuySucceed()
    self:addSuperLottoCount()
end

function DailyTaskManager:onEventUpdateUserLevel()
    --self:addSuperLottoCount()
    self:updateUserLevel()
end

function DailyTaskManager:onEventShareSuccess()
    self:addShareCount()
end

function DailyTaskManager:onEventPropSuccess(param)
    if param and param.uid == g_AccountInfo:getId() then
        self:setUsePropCount(self:getUsePropCount()+1)
    end
end

function DailyTaskManager:onEventSendGiftSuccess(param)

    local playerList = g_RoomInfo:getPlayerList()
    if playerList then
        local playerData = playerList[param.sendSeatId]
        if playerData then
            if playerData.uid == g_AccountInfo:getId() then
                self:setSendTableGifts(self:getSendTableGifts()+1)
             end
        end
    end
end

function DailyTaskManager:onEventSendSmallTrumpetSuccess()
    self:setUseSmallLabasCount(self:getUseSmallLabasCount()+1)
end



--event end


function DailyTaskManager:initData()
    local oldDateString =  cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.REPORTER_RECORD_DATE, "");
    local year = os.date("%Y");
    local month = os.date("%m");
    local day = os.date("%d");
    local dateString = year..month..day;

    if oldDateString ~= dateString then
        local usedUidsString =  cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.REPORTER_USED_UIDS, nil);
        if usedUidsString ~= nil then
            local usedUidsList = g_StringUtils.split(usedUidsString, ",");
            for i = 1, #usedUidsList do
                local uid = usedUidsList[i];
                
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_PAY_COUNT .. uid, 0)               
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_POKER_COUNT .. uid, 0)               
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_WIN_COUNT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_TWO_WINNING_STREAK .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_THREE_WINNING_STREAK .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_MIDDLE_WIN_COUNT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SENIOR_WIN_COUNT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_ROUND_WIN_CHIPS .. uid, 0);
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_USE_PROP_COUNT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SEND_TABLE_GIFTS .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_ENTER_INTO_KNOCKOUT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_ENTER_INTO_TOURNAMENT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_WIN_KNOCKOUT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_OPEN_BOX .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SMALL_LABA .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SUPER_LOTTO .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_INVITE_FRIEND .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SHARES_COUNT .. uid, 0)
                 cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_LEVEL_COUNT .. uid, 0)
                        
                -- -- OG相关
                --  cc.UserDefault:getInstance():deleteValueForKey(g_UserDefaultCMD.SENDED_MASTER_OG               .. uid);
                --  cc.UserDefault:getInstance():deleteValueForKey(g_UserDefaultCMD.SENDED_SLOT_OG                 .. uid);
                --  cc.UserDefault:getInstance():deleteValueForKey(g_UserDefaultCMD.SENDED_TOURNAMENT_OG           .. uid);
            end 
             cc.UserDefault:getInstance():deleteValueForKey(g_UserDefaultCMD.REPORTER_USED_UIDS);
        end
                
        self.m_usedUids = {};
         cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.REPORTER_RECORD_DATE, dateString);
    else
        local usedUidsStr =  cc.UserDefault:getInstance():getStringForKey(g_UserDefaultCMD.REPORTER_USED_UIDS, "");
        self.m_usedUids = {};
        if usedUidsStr ~= nil then
            self.m_usedUids = g_StringUtils.split(usedUidsStr, ",");
        end
    end
            
    g_Model:watchData(g_ModelCmd.CURRENRT_FINISHED_TASK, self, self.onFinishedTask, false);
end

function DailyTaskManager:userLoggeIn()
    self.m_currentUid = g_AccountInfo:getId()
    if not g_TableLib.indexof(self.m_usedUids,tostring(self.m_currentUid)) then
        table.insert(self.m_usedUids, tostring(self.m_currentUid));
        local usedUidsStr = g_StringUtils.join(self.m_usedUids, ",");
        cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.REPORTER_USED_UIDS, usedUidsStr);
    end
    self.m_currentPayCount        = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_PAY_COUNT                  .. self.m_currentUid);
    self.m_currentPokerCount      = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_POKER_COUNT                .. self.m_currentUid);
    self.m_dollCurrentPokerCount  = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.DOLL_COLLECT_REPORTER_CURRENT_POKER_COUNT   .. self.m_currentUid);
    self.m_currentWinCount        = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_WIN_COUNT                  .. self.m_currentUid);
    self.m_twoWinningStreak       = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_TWO_WINNING_STREAK                 .. self.m_currentUid);
    self.m_threeWinningStreak     = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_THREE_WINNING_STREAK               .. self.m_currentUid);
    self.m_middleWinCount         = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_MIDDLE_WIN_COUNT                   .. self.m_currentUid);
    self.m_seniorWinCount         = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_SENIOR_WIN_COUNT                   .. self.m_currentUid);
    self.m_roundWinChips          = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_ROUND_WIN_CHIPS                     .. self.m_currentUid);
    self.m_usePropCount           = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_USE_PROP_COUNT                     .. self.m_currentUid);
    self.m_sendTableGifts         = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_SEND_TABLE_GIFTS                   .. self.m_currentUid);
    self.m_enterIntoKnockout      = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_ENTER_INTO_KNOCKOUT                .. self.m_currentUid);
    self.m_enterIntoTournament    = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_ENTER_INTO_TOURNAMENT              .. self.m_currentUid);
    self.m_winKnockout            = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_WIN_KNOCKOUT                       .. self.m_currentUid);
    self.m_currentBoxCount        = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_OPEN_BOX                           .. self.m_currentUid);
    self.m_useSmallLabasCount     = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_SMALL_LABA                         .. self.m_currentUid);
    self.m_superLottoCount        = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_SUPER_LOTTO                        .. self.m_currentUid);
    self.m_inviteFriendsCount     = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_INVITE_FRIEND                      .. self.m_currentUid);
    self.m_sharesCount            = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_SHARES_COUNT                       .. self.m_currentUid);
    self.m_levelNum               = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.REPORTER_LEVEL_COUNT                        .. self.m_currentUid);

    self.m_newYearPrimaryPokerCount         = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.NEW_YEAR_PRIMARY_ROOM_COUNTS      .. self.m_currentUid);
    self.m_newYearIntermediatePokerCount    = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.NEW_YEAR_INTERMEDIATE_ROOM_COUNTS .. self.m_currentUid);
    self.m_newYearSeniorPokerCount          = cc.UserDefault:getInstance():getIntegerForKey(g_UserDefaultCMD.NEW_YEAR_SENIOR_ROOM_COUNTS       .. self.m_currentUid);
            
    self.m_finishTask = 0;
    self.m_reGetTimes = 5;
    self:getTaskListAll();
end

DailyTaskManager.getFinishedTask = function(self)
    return g_Model:getData(g_ModelCmd.CURRENRT_FINISHED_TASK);
end
            
DailyTaskManager.onFinishedTask = function(self, num)
    if num ~= nil and num >= 1 then
        if self.m_taskButton ~= nil then
            self.m_taskButton:startGlow();
        end
        if self.m_taskItem ~= nil then
            self.m_taskItem:setItemTips( tostring(num) );
        end
    else
        if self.m_taskButton ~= nil then
            self.m_taskButton:stopGlow();
        end
        if self.m_taskItem ~= nil then
            self.m_taskItem:setItemTips("");
        end
    end
end

function DailyTaskManager:getTaskListAll()
    -- HttpService.post({
    -- ["mod"] = "taskNew", ["act"] = "list"}, self, self.getTaskListCallback, self.getTaskListCallback, "getTaskList");
    local params = HttpCmd:getMethod(HttpCmd.s_cmds.DAILY_TASK_INFO)
    g_HttpManager:doPost(params, self, self.onDailyTaskListResponse)
end

function DailyTaskManager:getTaskListTryAgain()
    if self.m_reGetTimes > 0 then
        -- HttpService.post({
        -- ["mod"] = "taskNew", ["act"] = "list"}, self, self.getTaskListCallback, self.getTaskListTryAgain);
        local params = HttpCmd:getMethod(HttpCmd.s_cmds.DAILY_TASK_INFO)
        g_HttpManager:doPost(params, self, self.onDailyTaskListResponse)
		self.m_reGetTimes = self.m_reGetTimes - 1;
    end
end

function DailyTaskManager:onDailyTaskListResponse(isSuccess,data)
    Log.d("DailyTaskManager taskList data = ",data)
    -- local userData = g_Model:getData(g_ModelCmd.USER_DATA);
    if data ~= nil then
        -- local flag, jsonObj = g_JsonUtil.decode(data);
        if g_TableLib.isTable(data) then
            local list = {};
            local condition = data.conditions
            if data.ret == 0 and data.list ~= nil then
                list = data.list;
                self.m_allTaskV = {};
                self.m_roomTaskV = {};
                
                if list.pays ~= nil then
                    self.m_paysTask = TaskVO:create();
                    self:parseData(self.m_paysTask, list.pays,condition.pays);
                end
            
                if list.wins ~= nil then
                    self.m_winsTask = TaskVO:create();
                    self:parseData(self.m_winsTask, list.wins,condition.wins);
                    self.m_currentWinCount = condition.wins
                end
            
                if list.twoWinningStreak ~= nil then
                    self.m_twoWinningStreakTask = TaskVO:create();
                    self:parseData(self.m_twoWinningStreakTask, list.twoWinningStreak,self.m_twoWinningStreak);
                end

                if list.threeWinningStreak ~= nil then
                    self.m_threeWinningStreakTask = TaskVO:create();
                    self:parseData(self.m_threeWinningStreakTask, list.threeWinningStreak,self.m_threeWinningStreak);
                end

                if list.pokers ~= nil then
                    self.m_pokersTask = TaskVO:create();
                    self:parseData(self.m_pokersTask, list.pokers,condition.UserDailyPoker);
                    self.m_currentPokerCount = self.m_pokersTask.m_progress
                end

                if list.maxWinChips ~= nil then
                    self.m_roundWinChipsTask = TaskVO:create();
                    self:parseData(self.m_roundWinChipsTask, list.maxWinChips,self.m_roundWinChips);
                end

                if list.middleWins ~= nil then
                    self.m_middleWinsTask = TaskVO:create();
                    self:parseData(self.m_middleWinsTask, list.middleWins,condition.middleWins);
                end

                if list.seniorWins ~= nil then
                    self.m_seniorWinsTask = TaskVO:create();
                    self:parseData(self.m_seniorWinsTask, list.seniorWins,condition.seniorWins);
                end

                if list.gifts ~= nil then
                    self.m_giftsTask = TaskVO:create();
                    self:parseData(self.m_giftsTask, list.gifts,condition.gifts);
                    self.m_sendTableGifts =  self.m_giftsTask.m_progress
                end

                if list.props ~= nil then
                    self.m_usePropsTask = TaskVO:create();
                    self:parseData(self.m_usePropsTask, list.props,condition.props)
                    self.m_usePropCount = self.m_usePropsTask.m_progress
                end

                if list.matches ~= nil then
                    self.m_joinKnockoutsTask = TaskVO:create();
                    self:parseData(self.m_joinKnockoutsTask, list.matches,self.m_enterIntoKnockout);
                end

                if list.joinTournaments ~= nil then
                    self.m_joinTournamentsTask = TaskVO:create();
                    self:parseData(self.m_joinTournamentsTask, list.joinTournaments,self.m_enterIntoTournament);
                end

                if list.winKnockouts ~= nil then
                    self.m_winKnockoutsTask = TaskVO:create();
                    self:parseData(self.m_winKnockoutsTask, list.winKnockouts,self.m_winKnockout);
                end

                if list.boxs ~= nil then
                    self.m_boxsTask = TaskVO:create();
                    self:parseData(self.m_boxsTask, list.boxs,self.m_currentBoxCount);
                end

                if list.speakers ~= nil then
                    self.m_useSmallLabasTask = TaskVO:create();
                    self:parseData(self.m_useSmallLabasTask, list.speakers,condition.speakers);
                    self.m_useSmallLabasCount = self.m_useSmallLabasTask.m_progress
                end

                if list.lottos ~= nil then
                    self.m_superLottosTask = TaskVO:create();
                    self:parseData(self.m_superLottosTask, list.lottos,self.m_superLottoCount);
                end

                if list.invites ~= nil then  --邀请好友
                    self.m_invitesTask = TaskVO:create();
                    self:parseData(self.m_invitesTask, list.invites,self.m_inviteFriendsCount);
                end

                if list.shares ~= nil then  --分享
                    self.m_sharesTask = TaskVO:create();
                    self:parseData(self.m_sharesTask, list.shares,self.m_sharesCount);
                end

                if list.levels ~= nil then
                    self.m_upgrateLevelTask = TaskVO:create();
                    self.m_upgrateLevelTask.m_isLevelTask = true;
                    self:parseData(self.m_upgrateLevelTask, list.levels, g_AccountInfo:getUserLevel(), true);
                end
                    
                g_Model:setData(g_ModelCmd.CURRENRT_FINISHED_TASK, self.m_finishTask);
                self:__sort();
            end
        else
            self:getTaskListTryAgain();
        end
    else
        self:getTaskListTryAgain();
    end
	
    local count = 0; --可领取奖励任务数
    for k,v in pairs(self.m_allTaskV) do
        if v.m_status == TaskVO.STATUS_CAN_REWARD then
            count = count + 1;
        end
    end
    local spTask = g_Model:getData(g_ModelCmd.TASK_SPECIAL) or {};
	if spTask.m_status == TaskVO.STATUS_CAN_REWARD then
		count = count + 1;
	end
    g_Model:setData(g_ModelCmd.HOME_TASK_SWARDS,count);

    g_EventDispatcher:dispatch(g_SceneEvent.HALL_UPDATE_RED_POINT)
end


function DailyTaskManager:getSuperLottoCount()
    return self.m_superLottoCount or 0
end

function DailyTaskManager:setSuperLottoCount( value)
    if value then
        self.m_superLottoCount = value
        cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SUPER_LOTTO.. self.m_currentUid,value)
        self:reportData( self.m_superLottosTask,self.m_superLottoCount)
    end
end

function DailyTaskManager:addSuperLottoCount(addValue)

    addValue = addValue or 1
    self:setSuperLottoCount(self:getSuperLottoCount()+addValue)
end

function DailyTaskManager:setShareCount( value)
    if value then
        self.m_sharesCount = value
        cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SHARES_COUNT.. self.m_currentUid,value)
        self:reportData(self.m_sharesTask,self.m_sharesCount)
    end
end

function DailyTaskManager:getShareCount()
    return self.m_sharesCount or 0
end

function DailyTaskManager:addShareCount(addValue)

    addValue = addValue or 1
     
    self:setShareCount(self:getShareCount()+addValue)
end


function DailyTaskManager:__sort()
    --排序
    local n = #self.m_allTaskV - 1;
    local i = 0;
    local temp = nil;
    g_TableLib.quickSort(self.m_allTaskV, TaskVO, TaskVO.compareStatus);
    Log.d("DailyTaskManager set task data")
    g_Model:setData(g_ModelCmd.ALL_TASK_LIST, self.m_allTaskV);

    g_TableLib.quickSort(self.m_roomTaskV, TaskVO, TaskVO.compareStatus);
    g_Model:setData(g_ModelCmd.ROOM_TASK_LIST, self.m_roomTaskV);
end
        
function DailyTaskManager:parseData(taskVO, data,progress,isRoom)
    if isRoom == nil then
        isRoom = true;
    end
    taskVO:parse(data);
    -- taskVO.m_totalProgress = progress;
    local curProgress = nil

    if not progress then
        curProgress = 0 
    elseif data.type == "speakers" then
        curProgress = progress["602"] or 0
    elseif data.type == "props" then
        curProgress = progress["601"] or 0
    else
        curProgress = progress or 0
    end
    
    curProgress = tonumber(curProgress) or 0
    if  taskVO.m_status == TaskVO.STATUS_UNDER_WAY or taskVO.m_status == TaskVO.STATUS_CAN_REWARD then
        if curProgress >= tonumber(taskVO.m_target) then
            self.m_finishTask   = self.m_finishTask + 1;
            taskVO.m_progress   = taskVO.m_target;
            taskVO.m_status     = TaskVO.STATUS_CAN_REWARD;
        
        elseif taskVO.m_isLevelTask and taskVO.m_canGet then
            self.m_finishTask   = self.m_finishTask + 1;
            taskVO.m_status     = TaskVO.STATUS_CAN_REWARD;
        else
            taskVO.m_progress   = curProgress;
        end
    end

    if taskVO.m_special ~= nil and tostring(taskVO.m_special) ~= "0" then
        g_Model:setData(g_ModelCmd.TASK_SPECIAL, taskVO);
        self.m_specialTask = taskVO
    else
        table.insert(self.m_allTaskV, taskVO);
    end

    if isRoom then
        table.insert(self.m_roomTaskV, taskVO);
    end

    taskVO.m_progress  = taskVO.m_progress  or 0
end

function DailyTaskManager:hasUnrecieveReward()
    for k,v in pairs (self.m_allTaskV) do
        if v:canRecieveReward() then
            return true
        end
    end

    if not g_TableLib.isEmpty(self.m_specialTask) then
        if self.m_specialTask:canRecieveReward() then
            return true
        end
    end


    return false
end

function DailyTaskManager:convertToFormatString(str)
    if not str then
        return ""
    end
    local temp = string.gsub( str,"[^%d]","")
    temp = g_MoneyUtil.skipMoney(tonumber(temp))
   local ret = GameString.get("str_common_reward")..temp..GameString.get("str_common_chip")
    return  ret
end

   -- self.m_reward = "奖励1,000筹码"
   





function DailyTaskManager:reportGameOverByParam(param)
   
    self:reportGameOver(
        param.tableId, 
        param.roomType, 
        param.tableLevel, 
        param.roundCount, 
        param.winChip
        );
 
    --self:getTaskListAll()
end

function DailyTaskManager:reportGameOver(tableId, roomType, tableLevel, roundCount, winChip)
 
    if roomType ~= g_RoomInfo.ROOM_TYPE_NORMAL and roomType ~= g_RoomInfo.ROOM_TYPE_PROFESSIONAL then
        return
    end

    self:setCurrentPokerCount(self:getCurrentPokerCount() + 1)
    if winChip > 0 then
        self.m_winningStreak1 = self.m_winningStreak1 + 1
        self.m_winningStreak2 = self.m_winningStreak2 + 1
        self:setCurrentWinCount(self:getCurrentWinCount() + 1)
        self:setRoundWinChips(winChip)

        if self.m_winningStreak3 == 0 then
            self.m_currentTime = os.time();
            self.m_winningStreak3 = self.m_winningStreak3 + 1
        else
            if os.time() - self.m_currentTime > 60 * 1000 then
                self.m_winningStreak3 = 0
            elseif self.m_winningStreak3 == 3 then
                -- 一分钟连赢四局，需上报
                self.m_winningStreak3 = 0
                local params = HttpCmd:getMethod(HttpCmd.s_cmds.TJ_GAME_REPORT)
                params.tid = tableId
                params.table = tableLevel
                params.pid = roundCount
                params.type = 1
                g_HttpManager:doPost(params)
            else
                self.m_winningStreak3 = self.m_winningStreak3 + 1
            end
        end

        self.m_winningStreak4 = self.m_winningStreak4 + 1
        if self.m_winningStreak4 == 10 then
            -- 连赢十局，需上报
            self.m_winningStreak4 = 0
            local params = HttpCmd:getMethod(HttpCmd.s_cmds.TJ_GAME_REPORT)
            params.tid = tableId
            params.table = tableLevel
            params.pid = roundCount
            params.type = 2
            g_HttpManager:doPost(params);
        end

        self.m_winningStreak5 = self.m_winningStreak5 + 1
        if self.m_winningStreak5 == 5 then
            self.m_winningStreak5 = 0
            -- g_EventDispatcher:dispatch(g_SceneEvent.ROOM_FACEBOOK_SHARE, {
            --     ["title"]       = g_StringLib.substitute(STR_SOCIAL_WINNING_STREAK_SHARE_TITLE, "5"), 
            --     ["feedId"]      = "winningStreak", 
            --     ["image"]       ="fiveWinningStreak", 
            --     ["callBack"]    = function(data)
            --         data.message = g_StringLib.substitute(data.message, "5");
            --         data.picture = g_StringLib.substitute(data.picture, "fiveWinningStreak");
            --     end
            -- });
        end

        self.m_winningStreak6 = self.m_winningStreak6 + 1;
        if self.m_winningStreak6 == 7 then
            self.m_winningStreak6 = 0;
            -- g_EventDispatcher:dispatch(g_SceneEvent.s_cmd.ROOM_FACEBOOK_SHARE, {
            --     ["title"]   = g_StringLib.substitute(STR_SOCIAL_WINNING_STREAK_SHARE_TITLE, "7"), 
            --     ["feedId"]  = "winningStreak", 
            --     ["image"]   = "sevenWinningStreak", 
            --     ["callBack"]= function(data)
            --         data.message = g_StringLib.substitute(data.message, "7");
            --         data.picture = g_StringLib.substitute(data.picture, "sevenWinningStreak");
            --     end
            -- });
        end
    else
        self.m_winningStreak1 = 0;
        self.m_winningStreak2 = 0;
        self.m_winningStreak3 = 0;
        self.m_winningStreak4 = 0;
        self.m_winningStreak5 = 0;
        self.m_winningStreak6 = 0;
    end
    --self:reportWinningStreak();

    if winChip > 0 then
        if tableLevel == g_RoomInfo.ROOM_LEVEL_INTERMEDIATE then
            self:setMiddleWinCount(self:getMiddleWinCount() + 1)

        elseif tableLevel == g_RoomInfo.ROOM_LEVEL_SENIOR then
            self:setSeniorWinCount(self:getSeniorWinCount() + 1)
        end
    end

   
end

--function DailyTaskManager:callBackFun(isSuccess,data)
--    if not isSuccess then
--        Log.d("spring report failed!")
--        return
--    end
--    Log.d( "spring_report callback value:", data)
--end

DailyTaskManager.reportUserPay = function(self, value)
    self:setCurrentPayCount(self:getCurrentPayCount() + value);
end

function DailyTaskManager:updateUserLevel()
    self:reportData(self.m_upgrateLevelTask,g_AccountInfo:getUserLevel())
end

        
--DailyTaskManager.reportUseProp = function(self)
--    self:setUsePropCount(self:getUsePropCount() + 1);
--end
        
--DailyTaskManager.reportSendTableGifts = function(self)
--    self:setSendTableGifts(self:getSendTableGifts() + 1);
--end

--DailyTaskManager.reportEnterIntoMatch = function(self, roomType)
--    if roomType == g_RoomInfo.ROOM_TYPE_KNOCKOUT then
--        self:setEnterIntoKnockout(self:getEnterIntoKnockout() + 1);
--    elseif roomType == g_RoomInfo.ROOM_TYPE_TOURNAMENT then
--        self:setEnterIntoTournament(self:getEnterIntoTournament() + 1);
--    end
--end

--DailyTaskManager.getEnterIntoTournament = function(self)
--    return self.m_enterIntoTournament;
--end

--DailyTaskManager.setEnterIntoTournament = function(self, value)
--    if self.m_joinTournamentsTask ~= nil then
--        self.m_enterIntoTournament = value;
--        self.m_joinTournamentsTask.m_totalProgress = value;
--        if self.m_joinTournamentsTask.m_status ~= TaskVO.STATUS_FINISHED then
--            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_ENTER_INTO_TOURNAMENT .. self.m_currentUid, self.m_enterIntoTournament);
--        end
--        self:reportData(self.m_joinTournamentsTask, self.m_enterIntoTournament);
--    end
--end

--DailyTaskManager.reportWinningStreak = function(self)
--    if self.m_winningStreak1 >= 2 then
--        self:setTwoWinningStreak(self:getTwoWinningStreak() + 1);
--        self.m_winningStreak1 = 0;
--    end

--    if self.m_winningStreak2 >= 3 then
--        self:setThreeWinningStreak(self:getThreeWinningStreak() + 1);
--        self.m_winningStreak2 = 0;
--    end
--end

--DailyTaskManager.reportWinKnockout = function(self)
--    self:setWinKnockout(self:getWinKnockout() + 1);
--end

--DailyTaskManager.reportOpenBox = function(self)
--    self:setCurrentBoxCount(self:getCurrentBoxCount() + 1);
--end

--DailyTaskManager.reportSmallLaba = function(self)
--    self:setUseSmallLabasCount(self:getUseSmallLabasCount() + 1);
--end

--DailyTaskManager.reportSuperLotto = function(self)
--    self:setSuperLottoCount(self:getSuperLottoCount() + 1);
--end
        
DailyTaskManager.reportInviteFriend = function(self, inviteNum)
    self:setInviteFriendsCount(self:getInviteFriendsCount() + inviteNum);
end

function DailyTaskManager:getInviteFriendsCount()
    return self.m_inviteFriendsCount or 0
end

function DailyTaskManager:setInviteFriendsCount(value)
    if self.m_invitesTask ~= nil then
        self.m_inviteFriendsCount = value;
        self.m_invitesTask.m_totalProgress  = value;
        if self.m_invitesTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_INVITE_FRIEND .. self.m_currentUid, self.m_inviteFriendsCount)
        end
        self:reportData(self.m_invitesTask, self.m_inviteFriendsCount);
    end
end
        
DailyTaskManager.reportShare = function(self)
    self:setSharesCount(self:getSharesCount() + 1);
end
   
--[Comment]
-- 当前充值额度		
DailyTaskManager.getCurrentPayCount = function(self)
    return self.m_currentPayCount or 0
end

DailyTaskManager.setCurrentPayCount = function(self, value)
    if self.m_paysTask ~= nil then
        self.m_currentPayCount = value;
        self.m_paysTask.m_totalProgress = value;
        if self.m_paysTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_PAY_COUNT .. self.m_currentUid, self.m_currentPayCount);
        end
        self:reportData(self.m_paysTask, self.m_currentPayCount);
    end
end

--[Comment]
--使用互动道具次数 
DailyTaskManager.getUsePropCount = function(self)
    return self.m_usePropCount or 0
end

DailyTaskManager.setUsePropCount = function(self, value)
    if self.m_usePropsTask ~= nil then
        self.m_usePropCount = value;
        self.m_usePropsTask.m_totalProgress = value;
        if self.m_usePropsTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_USE_PROP_COUNT .. self.m_currentUid, self.m_usePropCount);
        end
        self:reportData(self.m_usePropsTask, self.m_usePropCount);
    end
end

DailyTaskManager.getSendTableGifts = function(self)
    return self.m_sendTableGifts or 0
end

DailyTaskManager.setSendTableGifts = function(self, value)
    if self.m_giftsTask ~= nil then
        self.m_sendTableGifts = value;
        self.m_giftsTask.m_totalProgress = value;
        if self.m_giftsTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SEND_TABLE_GIFTS .. self.m_currentUid, self.m_sendTableGifts);
        end
        self:reportData(self.m_giftsTask, self.m_sendTableGifts);
    end
end

--DailyTaskManager.getEnterIntoKnockout = function(self)
--    return self.m_enterIntoKnockout;
--end

--DailyTaskManager.setEnterIntoKnockout = function(self, value)
--    if self.m_joinKnockoutsTask ~= nil then
--        self.m_enterIntoKnockout = value;
--        self.m_joinKnockoutsTask.totalProgress = value;
--        if self.m_joinKnockoutsTask.m_status ~= TaskVO.STATUS_FINISHED then
--            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_ENTER_INTO_KNOCKOUT .. self.m_currentUid, self.m_enterIntoKnockout);
--        end
--        self:reportData(self.m_joinKnockoutsTask, self.m_enterIntoKnockout);
--    end
--end


--当前玩牌局数 		
DailyTaskManager.getCurrentPokerCount = function(self)
    return self.m_currentPokerCount or 0
end
        

DailyTaskManager.setCurrentPokerCount = function(self, value)
    if self.m_pokersTask then
        self.m_currentPokerCount = value;
        self.m_pokersTask.m_totalProgress = value;
        if self.m_pokersTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_POKER_COUNT .. self.m_currentUid, self.m_currentPokerCount);
        end
        g_Schedule:schedulerOnce(function()
            self:reportData(self.m_pokersTask, self.m_currentPokerCount)
        end, 5)
    end
end


--当前获胜局数 

DailyTaskManager.cancelWinShceduler = function(self)
    if self.m_winScheduler then
        local scheduler  = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self.m_winScheduler)
        self.m_winScheduler = nil
    end
end

DailyTaskManager.getCurrentWinCount = function(self)
    return self.m_currentWinCount or 0
end

DailyTaskManager.setCurrentWinCount = function(self, value)
    if self.m_winsTask ~= nil then
       self.m_currentWinCount = value;
        self.m_winsTask.m_totalProgress = value;
        if self.m_winsTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_CURRENT_WIN_COUNT .. self.m_currentUid, self.m_currentWinCount);
        end
        self:cancelWinShceduler()
        self.m_winScheduler =  g_NodeUtils:schedulerCall(7,nil,function()
            self:reportData(self.m_winsTask, self.m_currentWinCount)
        end)
        
    end
end

DailyTaskManager.setRoundWinChips = function(self, value)
    if self.m_roundWinChipsTask ~= nil and value > self.m_roundWinChips then
        self.m_roundWinChips = value;
        self.m_roundWinChipsTask.m_totalProgress = value;
        if self.m_roundWinChipsTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_ROUND_WIN_CHIPS .. self.m_currentUid, self.m_roundWinChips);
        end
        self:reportData(self.m_roundWinChipsTask, self.m_roundWinChips);
    end
end

--DailyTaskManager.setTwoWinningStreak = function(self, value)
--    if self.m_twoWinningStreakTask then
--        self.m_twoWinningStreak = value;
--        self.m_twoWinningStreakTask.m_totalProgress  = value;
--        if self.m_twoWinningStreakTask.m_status ~= TaskVO.STATUS_FINISHED then
--            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_TWO_WINNING_STREAK .. self.m_currentUid, self.m_twoWinningStreak);
--        end
--        self:reportData(self.m_twoWinningStreakTask, self.m_twoWinningStreak);
--    end
--end

DailyTaskManager.getMiddleWinCount = function(self)
    return self.m_middleWinCount or 0
end

DailyTaskManager.setMiddleWinCount = function(self, value)
    if self.m_middleWinsTask ~= nil then
        self.m_middleWinCount = value;
        self.m_middleWinsTask.totalProgress = value;
        if self.m_middleWinsTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_MIDDLE_WIN_COUNT .. self.m_currentUid, self.m_middleWinCount);
        end
        self:reportData(self.m_middleWinsTask, self.m_middleWinCount);
    end
end

----[Comment]
--高级场胜利次数
DailyTaskManager.getSeniorWinCount = function(self)
    return self.m_seniorWinCount or 0
end

DailyTaskManager.setSeniorWinCount = function(self, value)
    if self.m_seniorWinsTask ~= nil then
        self.m_seniorWinCount = value;
        self.m_seniorWinsTask.m_totalProgress = value;
        if self.m_seniorWinsTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SENIOR_WIN_COUNT .. self.m_currentUid, self.m_seniorWinCount);
        end
        self:reportData(self.m_seniorWinsTask, self.m_seniorWinCount);
    end
end

--DailyTaskManager.getWinKnockout = function(self)
--    return self.m_winKnockout;
--end

--DailyTaskManager.setWinKnockout = function(self, value)
--    if self.m_winKnockoutsTask ~= nil then
--        self.m_winKnockout = value;
--        self.m_winKnockoutsTask.m_totalProgress = value;
--        if self.m_winKnockoutsTask.m_status ~= TaskVO.STATUS_FINISHED then
--            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_WIN_KNOCKOUT .. self.m_currentUid, self.m_winKnockout);
--        end
--        self:reportData(self.m_winKnockoutsTask, self.m_winKnockout);
--    end
--end


DailyTaskManager.getUseSmallLabasCount = function(self)
    return self.m_useSmallLabasCount or 0
end

DailyTaskManager.setUseSmallLabasCount = function(self, value)
    if self.m_useSmallLabasTask ~= nil then
        self.m_useSmallLabasCount = value
        self.m_useSmallLabasTask.m_totalProgress = value
        if self.m_useSmallLabasTask.m_status ~= TaskVO.STATUS_FINISHED then
            cc.UserDefault:getInstance():setIntegerForKey(g_UserDefaultCMD.REPORTER_SMALL_LABA .. self.m_currentUid, self.m_useSmallLabasCount);
        end
        self:reportData(self.m_useSmallLabasTask, self.m_useSmallLabasCount);
    end
end


DailyTaskManager.reportData = function(self, taskVO, reportValue)
    if taskVO ~= nil and tonumber(taskVO.m_target) and tonumber(reportValue) then
        if taskVO.m_status == TaskVO.STATUS_UNDER_WAY then
            if tonumber(reportValue) >= tonumber(taskVO.m_target) then
                taskVO.m_status = TaskVO.STATUS_CAN_REWARD
                self:showTopTip(taskVO)
            end
        end
    end
end

DailyTaskManager.showTopTip = function(self,itemData)
    Log.d("task finished tips ")
    local inRoom = cc.Director:getInstance():getRunningScene():getName() == "RoomScene"
    --if inRoom then
        local content = string.gsub(itemData.m_reward,"\n","")
        content =  GameString.get("str_task_finish_tips")..itemData.m_name.." "..content
        local data = {
            title = content,
            btnTx = GameString.get("str_task_recieve_reward"),
            callBack = function() 
                if inRoom then
                    g_PopupManager:show(g_PopupConfig.S_POPID.ROOMTASK_POP)
                else
                    g_PopupManager:show(g_PopupConfig.S_POPID.DAILYTASK_POP)
                end
            end,
        }
        local MttNotify = import("app.scenes.mttLobbyScene").MTTNotice
        --string.g
   
        MttNotify.getInstance():setText(data):show()
    --end
end


DailyTaskManager.showReward = function(self,data)
    if data.reward ~= nil then

        local reward = data.reward
        local rewardData = {}
        local temp = {}
        temp.name = GameString.get("str_task_chip")--"筹码"
        temp.type = "chip"
        temp.pic = "images/1/props/chip.png"
        temp.val = g_MoneyUtil.skipMoney(reward.money or 0)
        table.insert(rewardData,temp)
        
        if reward.vip1 then
            local t = {}

            t.name = GameString.get("str_task_vip1")--"铜卡"
            t.type = "vip1"
            t.lpic = "creator/store/store_pro_small_1.png"
            t.val = g_MoneyUtil.skipMoney(reward.vip1 or 0)
            table.insert(rewardData,t)
        end

        if reward.vip2 then
            local t = {}

            t.name = GameString.get("str_task_vip2")--"银卡"
            t.type = "vip1"
            t.lpic = "creator/store/store_pro_small_6.png"
            t.val = g_MoneyUtil.skipMoney(reward.vip2 or 0)
            table.insert(rewardData,t)
        end

        if reward.vip3 then
            local t = {}

            t.name = GameString.get("str_task_vip3")--"银卡"
            t.type = "vip1"
            t.lpic = "creator/store/store_pro_small_7.png"
            t.val = g_MoneyUtil.skipMoney(reward.vip3 or 0)
            table.insert(rewardData,t)
        end

        if reward.vip4 then
            local t = {}

            t.name = GameString.get("str_task_vip4")--"银卡"
            t.type = "vip1"
            t.lpic = "creator/store/store_pro_small_8.png"
            t.val = g_MoneyUtil.skipMoney(reward.vip4 or 0)
            table.insert(rewardData,t)
        end

        if reward.double_exp then
            local t = {}

            t.name = GameString.get("str_task_double_exp")--"双倍经验"
            t.type = "exp"
            t.lpic = "creator/store/store_pro_small_3.png"
            t.val = g_MoneyUtil.skipMoney(reward.double_exp or 0)
            table.insert(rewardData,t)
        end

        if reward.fun_face then
            local t = {}

            t.name = GameString.get("str_task_funFace")--"互动道具"
            t.type = "face"
            t.lpic = "creator/store/store_pro_small_2.png"
            t.val = g_MoneyUtil.skipMoney(reward.fun_face or 0)
          
            table.insert(rewardData,t)
        end

        if reward.gift then
            local t = {}

            t.name = GameString.get("str_task_gift")--"双倍经验"
            t.type = "exp"
            t.lpic = "creator/store/gift-default.png"
            t.val = g_MoneyUtil.skipMoney(reward.double_exp or 0)
            table.insert(rewardData,t)
        end
        

        g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_GET_REWARD_SUCCESS,rewardData); 
    
    elseif data.money ~= nil then
        local rewardData = {}
        local temp = {}
        temp.name = GameString.get("str_task_chip")--"筹码"
        temp.type = "chip"
        temp.pic = "images/1/props/chip.png"
        --local rewardMoney = string.match(g_StringLib.remove(self.m_data.m_reward,","),"%d+")
        temp.val = g_MoneyUtil.skipMoney(data.money or 0)
        table.insert(rewardData,temp)      
        g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_GET_REWARD_SUCCESS,rewardData);          
    end    
end

return DailyTaskManager