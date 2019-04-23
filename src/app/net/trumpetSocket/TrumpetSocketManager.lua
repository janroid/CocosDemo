local TrumpetSocket = require("trumpetSocket.TrumpetSocket")

local TrumpetSocketManager = class("TrumpetSocketManager")
TrumpetSocketManager.TAG = "TrumpetSocketManager"
local DailyTaskManager = import("app.scenes.dailyTask").DailyTaskManager;

function TrumpetSocketManager.getInstance()
    if not TrumpetSocketManager.s_instance then
        TrumpetSocketManager.s_instance = TrumpetSocketManager:create()
    end

    return TrumpetSocketManager.s_instance
end

function TrumpetSocketManager:ctor()
    self.m_socket = TrumpetSocket:create()
    self.m_level = 0
    self.m_gloryId = 0
    self.m_expInfo  = 0

    self.m_socket:setReceiveHandler(self, self.onReceiveMsg)
end

function TrumpetSocketManager:dtor()
    self:closeSocket()
    if self.m_socket then
        delete(self.m_socket)
        self.m_socket = nil
    end
    TrumpetSocketManager.s_instance = nil
    g_EventDispatcher:unRegisterAllEventByTarget(self)
end

function TrumpetSocketManager.delete()
    if  TrumpetSocketManager.s_instance then
        delete(TrumpetSocketManager.s_instance)
        TrumpetSocketManager.s_instance = nil
    end
end

function TrumpetSocketManager:openSocket()
    self.m_socket:connect()
end

function TrumpetSocketManager:closeSocket()
    Log.d("TrumpetSocketManager:closeSocket --> ")
    self.m_socket:disConnect()
end

function TrumpetSocketManager:cmdPrint(cmd)
	if g_SocketCmd.TrumpetSocketMap[cmd] ~= nil then
		Log.s("TrumpetSocketManager", string.format("0x%02x", cmd), " :", g_SocketCmd.TrumpetSocketMap[cmd]);
	else
		Log.d("TrumpetSocketManager", string.format("cmd=0x%x", cmd));
	end
end

function TrumpetSocketManager:onReceiveMsg(cmd)
    cmd = bit.band(cmd, 0xffff)
	self:cmdPrint(cmd)
    if	cmd == g_SocketCmd.TrumpetSocketCMD.LB_SVR_CMD_SINGLE then--用户相关
        local uid = self.m_socket:readInt();
        local types = self.m_socket:readInt();
        self:cmdPrint(types)
        --用户升级
        if types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_LEVEL_UP then
            self:levelUp();
            
        --成就完成
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_GLORY_FINISH then
            self:gloryFinish();
            
        --任务完成
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_TASK_FINISH then
            self:taskFinish();
            
        --坐下加经验
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_EXP then
            self:sitDownExp();
                
        --维护积分
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_EDIT_SCORE then
            self:editScore();
            
        --新消息
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MESSAGE then
            -- EventDispatcher.getInstance():dispatch(CommandEvent.s_event, CommandEvent.s_cmd.NEW_MESSAGE_NOTICE);
            --g_AlarmTips.getInstance():setText(GameString.get("str_common_get_new_message")):show()
            local params = { ["mod"] = "msg", ["act"] = "get" }
            local onLoadMsgList = function(self,isSuccess,data)
               local message =  self:parseNewMessageData(data)
               if message then
                    g_AlarmTips.getInstance():setText(message):show()
               end
            end

            g_HttpManager:doPost(params, self, onLoadMsgList)

        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_DOSH_BOARD_MESSAGE then
            -- EventDispatcher.getInstance():dispatch(CommandEvent.s_event, CommandEvent.s_cmd.NEW_DOSH_BOARD_MESSAGE_NOTICE);
            
        --校验本地资产
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_EDIT_CHIP then
            Log.d("wshwsh","LB_SVR_TYPE_EDIT_CHIP");
            self:editChip();
            
        -- enter match room notification
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MATCH_PROMPT then
            -- self:matchPrompt(); -- 据说弃用了
            
        --邀请打牌
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_INVITE_PLAY then
            self:receiveInvitePlay();
            
        --点亮vip
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_GET_VIP then
            local str = self.m_socket:readString();
            local data, flag = g_JsonUtil.decode(str);
            if flag then
                if g_TableLib.isTable(data) then
                    -- g_Model:setProperty(g_ModelCmd.USER_DATA, "vip", data.vip_level);
                    -- UserInfoModule:loadUserDetailInfo(true);
                    g_AccountInfo:setVip(data.vip_level)
                end
            else
                Log.d(self.TAG, "socketInputHandler", "g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_GET_VIP", "decode json has an error occurred!");--解析JSON出现错误
            end
            
        --玩家人数
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_PLAYER_NUM then
            
        -- 老虎机幸运牌型
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_SLOT_REWARD then
            self:slotLuckyPoker();
            
        -- 活动server通知打牌活动完成
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_SUCCESS_ACT then
            local serverId = self.m_socket:readInt();-- act server id
             if self.m_socket:readInt() == 1 then
            --     EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.SYSTEM_NOTICE_TASK_FINISHED, -1);
            --     EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.SHOW_TOP_TIP, {
            --         ["type"] = "BROADCAST",
            --         ["message"] = STR_COMMON_GAME_ACTIVITY_COMPLETE_TIPS
            --     });
             end
            
        
        -- /* 移动专属Type */
        --打折信息
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_DISCOUNT then
            self:getDiscount();
            
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_ITEM_DISCOUNT then
            self:getItemDiscount();
            
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_DOLL_ACQUIRE_PROMPT then
            local dollName = self.m_socket:readString();
            local doll	   = self.m_socket:readInt();
            -- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.ROOM_FACEBOOK_SHARE, {
            --     ["title"]  	= StringKit.substitute(STR_SOCIAL_COLLECT_GIFT_SHARE_TITLE, dollName), 
            --     ["feedId"]	= "collectGift", 
            --     ["image"]	= "collectGift", 
            --     ["callBack"] = function (data)
            --         data.message = StringKit.substitute(data.message, dollName);
            --         data.picture = StringKit.substitute(data.picture, dollId);
            --     end
            -- });
            
        --移动系统消息（活动完成时推送）
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_SYS_MSG then
            
            --============任务完成系统通知
            local actId	  = self.m_socket:readInt();--php会推送完成的活动id，每个活动有相对应的id
            local message = self.m_socket:readString();
            local actType = self.m_socket:readString();
            -- if actType ~= "play" or actType == "other" then
            --     EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.SHOW_TOP_TIP, {
            --         ["type"] = "BROADCAST",
            --         ["message"] = message
            --     });
            -- end
            
        --用户充值（统计任务）
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_USER_PAY then
            DailyTaskManager.getInstance():reportUserPay(tonumber(self.m_socket:readString()) or 0)
            
        --后台通知消息，前端展示消息，不做其他用
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_SINGLE_MESSAGE then
            local message =  self.m_socket:readString()
            if message then
                 g_AlarmTips.getInstance():setText(message):show()
            end
            
        --公共弹框消息
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_COMMON_MESSAGE_PROMPT then
            local messageStr 	    = self.m_socket:readString();
            local messageData, flag	= g_JsonUtil.decode(messageStr);
            if flag and g_TableLib.isTable(messageData) then
                if messageData ~= nil and messageData.type ~= nil then
                    if messageData.type == "1" then
                        -- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.OPEN_DIALOG,{
                        --     ["message"] = messageData.msg
                        -- });
                    
                    elseif messageData.type == "2" then
                        -- EventDispatcher.getInstance():dispatch(CommandEvent.s_event, CommandEvent.s_cmd.ROOM_LEFT_BOTTOM_MESSAGE_NOTICE,{
                        --     ["title"] = messageData.msg, 
                        --     ["image"] = "iniviteCodeImage" 
                        -- });
                    end
                end
            else
                Log.d(self.TAG, "socketInputHandler", "g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_COMMON_MESSAGE_PROMPT", "decode json has an error occurred!");--解析JSON出现错误
            end

        --新年活动得到红包
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_MB_ACCEPT_RED_PACKS then
            local packNumstr = self.m_socket:readString();
            -- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.ROOM_FACEBOOK_SHARE,{
            --     ["title"] = StringKit.substitute(STR_ACTIVITY_NEW_YEAR_ACT_RED_PACK_FEED_TEXT,packNumstr), 
            --     ["feedId"] = "newYearRedPack", 
            --     ["image"] = "newYearRedPack" 
            -- });
            
        --系统推送消息
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_PUSH_MATCH_MESSAGE then
            self:doPushMessage();

        --有玩家修改了礼物的消息 
        --elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_UPDATE_GIFT then
            --self:playerUpdateGift();
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_UPDATE_TICKETS then
            self:updateMttTickets();
        else
--gwj            self.m_socket:readEnd();
            
        end
    elseif cmd == g_SocketCmd.TrumpetSocketCMD.LB_SVR_CMD_SYSTEM then--系统相关
        self.m_socket:readString();
        local types = self.m_socket:readInt();
        self:cmdPrint(types)
        --顶头提示
        if types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_HEAD_TIP then            

        --大喇叭
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_BIG_LABA then

             g_EventDispatcher:dispatch(g_SceneEvent.SHOW_TOP_TRUMPET_TIP,{
                 ["message"] = self:getBigLabaString();
             });
        --小喇叭
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_SMALL_LABA then
            self:getSmallLabaString();
            -- if g_Model:getData(g_ModelCmd.USER_LOGINED_ROOM) ~= nil then
            --     self:getSmallLabaString();
            -- end  
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_LOTTO_POOL then
            -- Log.d('LB_SVR_TYPE_LOTTO_POOL-----------',self.m_socket:readInt64())
            g_Model:setData(g_ModelCmd.LOTTO_POOL, self.m_socket:readInt64());  
            --系统推送消息
        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_LOTTO_REWARD then

            self:lottoReward();
            
            -- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.SHOW_TOP_TIP,{
            --     ["type"] = "BROADCAST",
            --     ["message"] = LabaSocket.getInstance():readString()
            -- })

        elseif types == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_PUSH_MESSAGE then
            self:doPushMessage() 
        else
        end
        
    elseif cmd == g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_DOUBLE_LOGIN then--重复登录
        Log.d("LB_SVR_TYPE_DOUBLE_LOGIN")
        cc.Director:getInstance():popToRootScene()
        local loginScene = import("app.scenes.login").scene
        cc.Director:getInstance():replaceScene(loginScene:create())
        g_AlarmTips.getInstance():setText(GameString.get("str_common_double_login_error")):show()
        g_AlertDialog.getInstance():dismiss()
    else
        --心跳包
        Log.d("wshwsh","laba heart");
        -- self.m_returnFlag = true;
        -- self.m_heartBeatTimeout = 0;
    end
end

function TrumpetSocketManager:doPushMessage()

    local str = self.m_socket:readString();
    Log.d(self.TAG, "doPushMessage:",str);
    
    local jsonObj, flag = g_JsonUtil.decode(str);
    if flag == true and g_TableLib.isTable(jsonObj) then
        if jsonObj.Mt == 1 then
            g_AlarmTips.getInstance():setText(jsonObj.Msg):show()

        elseif jsonObj.Mt == 2 then -- 已报名的比赛通知
            if jsonObj.Mdata ~= nil then
                g_EventDispatcher:dispatch(g_SceneEvent.MTT_MY_MATCH_TOP_TIPS,jsonObj);
            end

        elseif jsonObj.Mt == 3 then -- 全服比赛通知
            g_EventDispatcher:dispatch(g_SceneEvent.MTT_GLOBAL_MATCH_TOP_TIPS,jsonObj);
        end

    else
        Log.d(self.TAG, "doPushMessage json decode faile!");
    end
end


function TrumpetSocketManager:levelUp()
    -- local userData = g_Model:getData(ModelKeys.USER_DATA);
    self.m_level = self.m_socket:readInt();
    g_AccountInfo:setUserLevel(self.m_level)
    -- Model.setProperty(ModelKeys.USER_DATA, "level", self.m_level);
    
    -- 升级，发OG
    -- EventDispatcher.getInstance():dispatch(
    -- CommandEvent.s_event, 
    -- CommandEvent.s_cmd.SOCIAL_OG,{
    --     ["type"] = "level",
    --     ["data"] = self.m_level
    -- });
    
--    DailyTaskManager.getInstance():reportUserLevel(self.m_level);
    local exp = tonumber(g_AccountInfo:getUserExp())
    local newTitle = g_ExpUtils.getTitleByExp(exp)
    if newTitle ~= nil and g_AccountInfo:getTitle() ~= newTitle then
        g_AccountInfo:setTitle(newTitle)
    end
    -- local newTitle = g_ExpUtils.getTitleByExp(userData.experience);
--    local newTitle = g_ExpUtils.getTitleByExp(g_AccountInfo:getUserExp());
--    if newTitle ~= nil and userData["title"] ~= newTitle then
--        g_AccountInfo:setUserExp(newTitle)
--    end
end

function TrumpetSocketManager:gloryFinish()
    self.m_gloryId = self.m_socket:readInt();
    g_Model:setData(g_ModelCmd.USER_GLORY_FINISH, self.m_gloryId);
    --获得成就，延迟12秒推送tip
    g_Schedule:schedulerOnce(function()
        local imagePath = "creator/userInfo/glory/glory_"..self.m_gloryId..".png";
        
        local achieve = g_Model:getData(g_ModelCmd.DATA_ACHIEVE_INFO)
        local config = achieve and achieve:getConfig()
        local desc = ""
        for _, v in pairs(config) do
            if v.a == tostring(self.m_gloryId) then
                desc = v.b
                break
            end
        end

        local message = GameString.get("str_common_get_new_glory") .. " \n★ " .. desc .. " ★";
        
        local data = {
            text = message,
            needImg = true,
            imgPath = imagePath,
        }
        if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
            data.needBtn = true
            data.btnTx = GameString.get("str_common_share")
            data.callBack = function()
                local param = g_TableLib.copyTab(GameString.get('str_social_config').gloryGot)
                param.message = string.format(param.message, " ★ " .. desc .. " ★ ")
                param.link = g_AppManager:getFBAppLink()
                NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_SHARE_FACEBOOK, param, self, function (self, response)
                    if response and tonumber(response.result)  == 1 then
                        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_success'))
                        g_EventDispatcher:dispatch(g_SceneEvent.DAILYTASK_EVENT_SHARE_SUCCESS)
                    elseif tonumber(response.result) == 3 then
                        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_cancel'))
                    else
                        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_fb_share_failed'))
                    end
                end)
            end
        end
        g_TopTips:getInstance():setData(data):show()
        Log.d("TrumpetSocketManager:gloryFinish", imagePath, message)
    end,2)
end

function TrumpetSocketManager:taskFinish()
    --nothing
end

function TrumpetSocketManager:sitDownExp()
    -- local userData = Model.getData(ModelKeys.USER_DATA);
    -- self.m_expInfo = self.m_socket:readInt();
    -- local expInfo = userData.experience + self.m_expInfo;
    -- Model.setProperty(ModelKeys.USER_DATA, "experience", expInfo);

    self.m_expInfo = self.m_socket:readInt()
    g_AccountInfo:setUserExp((self.m_expInfo + g_AccountInfo:getUserExp() ))
end

function TrumpetSocketManager:editScore()
    local str = self.m_socket:readString();
    local scoreObj, flag = g_JsonUtil.decode(str);
    if flag and g_TableLib.isTable(scoreObj) then
        -- Model.setProperty(ModelKeys.USER_DATA, "score", scoreObj["nowPoint"]);
        g_AccountInfo:setScore(scoreObj.nowPoint)
        g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_DATA) 
    else
        Log.e(self.TAG, "editScore", "decode json has an error occurred!");   --解析JSON出现错误;
    end
end

--[Comment]
--用户资产校验 		
TrumpetSocketManager.m_timeoutNum = 0;
TrumpetSocketManager.m_userChip = nil;
function TrumpetSocketManager:editChip()
    -- local userData    = Model.getData(ModelKeys.USER_DATA);
    local data = self.m_socket:readString();
    local chips, flag = g_JsonUtil.decode(data);
    if flag and g_TableLib.isTable(chips) then
        self.m_userChip   = chips;
        if not flag then
            Log.d(self.TAG, "editChip", "decode json has an error occurred!");   --解析JSON出现错误;
            return;
        end
        Log.d("LabaSocketDataProvider.editChip, data", data);
        if self.m_userChip ~= nil then
            if g_Model:getData(g_ModelCmd.IS_ACTIVITY_WHEEL_OPENED) == true then --大转盘玩家钱数不做理会

            --     self.m_timeoutNum = setTimeout(self.editChipTimeout, self, 7000);
        
            -- elseif Model.getData(ModelKeys.IS_LOGIN_REWARD_PAGE_OPENED) then --登陆奖励玩家钱数手动增加
            --     self:updateUserData(self.m_userChip);
        
            else
                -- self:updateUserMoney(self.m_userChip);
                self:updateUserData(self.m_userChip);
            end
        end
    end
end

function TrumpetSocketManager:updateUserMoney(userChip)
    -- if tonumber(userChip.chips) == nil then
    --     userChip.chips = "0";
    -- end
    -- if tonumber(userChip.money) == nil then
    --     userChip.money = 0;
    -- end
    -- if userChip ~= nil and tonumber(userChip.chips) ~= nil then
    --     local money = userChip.money + tonumber(userChip.chips) --修改本地资产
    --     local totalMoney = money;
    --     if userChip.bank_money then
    --         totalMoney = money + userChip.bank_money; 
    --     end
    --     if money < 0 then
    --        money = 0;
    --     end
    --     Model.setProperty(ModelKeys.USER_DATA, "money", money);
    --     Model.setProperty(ModelKeys.USER_DATA, "totalMoney", totalMoney);
    --     if (SeatManager.selfInSeat) then
    --         SeatManager:getSelfSeat():getSeatData().totalChips = userData.money;
    --     end
    -- end
end

function TrumpetSocketManager:updateUserData(userChip)
    if tonumber(userChip.chips) == nil then
        userChip.chips = "0";
    end
    Log.d("TrumpetSocketManager:updateUserData",userChip)
    if userChip ~= nil then
        if tonumber(userChip.coalaa) ~= nil then 
            -- AccountInfo:setMoney(money)
            g_AccountInfo:setUserCoalaa(userChip.coalaa)
            -- Model.setProperty(ModelKeys.USER_DATA, "coalaa", tonumber(userChip.coalaa));
        end

        if tonumber(userChip.exp) ~= nil and tonumber(userChip.exp) > 0 then 
            -- if userData.experience ~= userChip.exp then
            --     TaskReporter.getInstance():getTaskListAll();
            -- end
            g_AccountInfo:setUserExp(userChip.exp)
            -- Model.setProperty(ModelKeys.USER_DATA, "experience", tonumber(userChip.exp));
        end

        if tonumber(userChip.level) ~= nil and tonumber(userChip.level) > 0 then 
            g_AccountInfo:setUserLevel(userChip.level)
            -- Model.setProperty(ModelKeys.USER_DATA, "level", tonumber(userChip.level));
        end
        if userChip.money ~= nil and tonumber(userChip.money) > 0 then
            g_AccountInfo:setMoney(tonumber(userChip.money) + tonumber(userChip.chips))
        end

        local maxMoney = g_AccountInfo:getMaxMoney()           
        --判断资产是否大于历史最高资产，如是则上报给php
        if tonumber(userChip.money) ~= nil and tonumber(maxMoney) ~= nil then
            if tonumber(userChip.money) >  tonumber(maxMoney) then
                g_AccountInfo:setMaxMoney(userChip.money)
                -- Model.setProperty(ModelKeys.USER_DATA, "maxmoney", userData.money);
                g_HttpManager:doPost({
                    ["mod"] = "user",
                    ["act"] = "setMostStat",
                    ["maxmoney"] = userChip.money
                });
            end
        end

        if userChip.money ~= nil and tonumber(userChip.money) > 0 then
        else
            g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_DATA)
        end
    end
end

--[Comment]
--收到玩牌邀請
function TrumpetSocketManager:receiveInvitePlay()
    local str 		     = self.m_socket:readString();
    local jsonObj, flag  = g_JsonUtil.decode(str);
    if flag and g_TableLib.isTable(jsonObj) then
        Log.d("receiveInvitePlay", jsonObj)
        --local SeatManager = import("app.scenes.normalRoom").SeatManager:getInstance()
        --local seat = SeatManager:getSelfSeat()
        --local isInGame = seat and seat:isInGame()
        local tips = GameString.get("str_friend_outGame_invite_tip")
        local data = {
            title = string.format(tips,jsonObj.name or ""),
            btnTx = GameString.get("str_friend_invite_accept"),
            callBack = function() self:acceptInvitation(jsonObj) end,
        }
        local MttNotify = import("app.scenes.mttLobbyScene").MTTNotice
        MttNotify.getInstance():setText(data):show()
    else
        Log.e("receiveInvitePlay", "decode json has an error occurred!：", str);
    end
end

function TrumpetSocketManager:acceptInvitation(jsonObj)
    local RoomPresenter = import("app.presenter").RoomPresenter
    jsonObj.passwordChecked = jsonObj.fromOwner
    RoomPresenter:toRoom(jsonObj)

    g_Model:setData(g_ModelCmd.RECEIVE_INVITE_DATA, jsonObj)
end

--邀请玩牌
function TrumpetSocketManager:invitePlayGame(uid)
    --邀请者信息
    local inviteUserData        = {};
    inviteUserData.uid 			= g_AccountInfo:getId()
    local roomOwner             = g_RoomInfo:getOwner()
    inviteUserData.name 		= g_AccountInfo:getNickName()
    inviteUserData.picUrl 		= g_AccountInfo:getSmallPic()

    inviteUserData.tid 			= g_RoomInfo:getTid()
    --inviteUserData.tableName 	= g_RoomInfo:getTableName()
    inviteUserData.smallBlind 	= g_RoomInfo:getSmallBlind()
    inviteUserData.ip 			= g_RoomInfo:getRoomIp()
    inviteUserData.port 		= g_RoomInfo:getRoomPort()
    inviteUserData.tableType  	= g_RoomInfo:getRoomType()
    inviteUserData.tableLevel 	= g_RoomInfo:getTableLevel()
    inviteUserData.flag 		= g_RoomInfo:getFlag()
    inviteUserData.password 	= g_RoomInfo:getPassword()
    inviteUserData.fromOwner  	= tostring(roomOwner) == tostring(g_AccountInfo:getId()); -- 是否来自房主邀请

    --如果是淘汰赛还需要额外的信息
    if inviteUserData.tableType == g_RoomInfo.ROOM_TYPE_KNOCKOUT then
        --obj.buyIn 			= knockoutData.applyCharge; --买入费
        --obj.serviceCharge 	= knockoutData.serviceCharge;  --服务费
        --obj.rewards 		= knockoutData.detailedReward;  --报酬奖励
    end
    
    local pkgStr = g_JsonUtil.encode(inviteUserData);
    self.m_socket:writeBegin()
    self.m_socket:writeInt(uid);       								--被邀请者ID
    self.m_socket:writeInt(g_SocketCmd.TrumpetSocketCMD.LB_SVR_TYPE_INVITE_PLAY);                     --type
    self.m_socket:writeString(pkgStr);
    self.m_socket:sendMsg(g_SocketCmd.TrumpetSocketCMD.LB_SVR_CMD_SINGLE)
    Log.d("TrumpetSocketManager:invitePlayGame", pkgStr, uid)
end

--[Comment]
--老虎机幸运牌型 	
TrumpetSocketManager.m_winMoney = nil;
TrumpetSocketManager.m_winTime = nil;
TrumpetSocketManager.m_retryTimes = nil;
function TrumpetSocketManager:slotLuckyPoker()
    self.m_socket:readString();-- 用户牌型
    self.m_socket:readString();-- 指定牌型
    self.m_socket:readString();-- 用户押注
    self.m_winMoney = self.m_socket:readString();-- 用户奖金
    self.m_socket:readString();-- 中奖倍数
    self.m_winTime = self.m_socket:readString();-- 获奖时间
    self.m_retryTimes = 3;
    local params = HttpCmd.getMethod(HttpCmd.s_cmds.SLOT_REWARD)
	params.winTime = self.m_winTime
	g_HttpManager:doPost(params,self,self.luckyPokerCallback)
end

function TrumpetSocketManager:luckyPokerCallback(isSuccess,data)
    Log.d("luckyPokerCallback data = ",data)
    if not isSuccess or g_TableLib.isEmpty(data) then 
        Log.e("luckyPokerCallback failed")
        return
    end

    self.m_retryTimes = self.m_retryTimes - 1;
    local retObj, flag = g_JsonUtil.decode(data);
    if flag == true and g_TableLib.isTable(retObj) then
        if retObj.ret and retObj.ret == 0 then
            -- setTimeout(function ()
            --     EventDispatcher.getInstance():dispatch(
            --         UIEvent.s_event, 
            --         UIEvent.s_cmd.SHOW_TOP_TIP,
            --         StringKit.substitute(STR_ROOM_SLOT_LUCKY_GET_REWARD, Formatter.formatBigNumber(tonumber(self.m_winMoney))));
            -- end,nil, 3000);
        elseif self.m_retryTimes >= 0 then
            -- HttpService.post({
            --     ["mod"] = "tiger", 
            --     ["act"] = "reward", 
            --     ["winTime"] = self.m_winTime}, self, self.luckyPokerCallback, TopTipKit.badNetworkHandler, nil, " LabaSocketDataProvider.luckyPokerCallback , 111");
        end
    else
        -- if self.m_retryTimes >= 0 then
        --     HttpService.post({
        --         ["mod"] = "tiger", 
        --         ["act"] = "reward", 
        --         ["winTime"] = self.m_winTime}, self, self.luckyPokerCallback, TopTipKit.badNetworkHandler, nil, " LabaSocketDataProvider.luckyPokerCallback , 111");
        -- end
    end

end

function TrumpetSocketManager:getSmallLabaString()
    local ret = nil;
    local str = self.m_socket:readString();
    local jsonObj,flag = g_JsonUtil.decode(str);
    if flag and g_TableLib.isTable(jsonObj) then
        local chatData = {}
        chatData.senderName = jsonObj.nick
        chatData.message = jsonObj.text
        chatData.type = 2
        chatData.senderUid = jsonObj.uid
        g_Model:setData(g_ModelCmd.ROOM_SMALL_LABA_DATA, chatData);
    else
        Log.e(self.TAG, "getSmallLabaString", "decode json has an error occurred!");
    end
end

function TrumpetSocketManager:getBigLabaString()
    local ret = nil;
    local str = self.m_socket:readString();
    local jsonObj, flag = g_JsonUtil.decode(str);
    if flag and g_TableLib.isTable(jsonObj) then
        ret = jsonObj.nick .. " : " .. jsonObj.text;
    else
        Log.e(self.TAG, "getBigLabaString", "decode json has an error occurred!");
    end
    return ret;
end

function TrumpetSocketManager:lottoReward()
    local reward = {}
    reward.uid = self.m_socket:readInt();
    reward.userName = self.m_socket:readString();
    reward.photoUrl = self.m_socket:readString();
    reward.money = self.m_socket:readInt64();
    reward.cardType = self.m_socket:readInt();

    if reward.cardType == 9 then
        reward.percentage = 10
    elseif reward.cardType == 10 then
        reward.percentage = 30
    elseif reward.cardType == 11 then
        reward.percentage = 80;
    end  

    reward.cards = {}

    reward.cards[1] = self.m_socket:readShort();
    reward.cards[2] = self.m_socket:readShort();
    reward.cards[3] = self.m_socket:readShort();
    reward.cards[4] = self.m_socket:readShort();
    reward.cards[5] = self.m_socket:readShort();   

    local pool      = self.m_socket:readInt64();
    reward.rewardId = self.m_socket:readInt64();  

    g_Model:setData(g_ModelCmd.LOTTO_REWARD, reward);
end



--[Comment]
--打折 之前是繁体的谷歌支付会用到 现在繁体接入支付中心了 应该没有地方用到它了
TrumpetSocketManager.getDiscount = function(self)
    -- local userData = Model.getData(ModelKeys.USER_DATA);
    -- if userData ~= nil then
    --     userData["discount"] = self.m_socket:readInt();
    --     Model.setPropery(ModelKeys.USER_DATA, "discount", userData["discount"]);
    -- end
    
    -- log.i(self.TAG, "Discount change. current is "..userData["discount"]);
end

TrumpetSocketManager.getItemDiscount = function(self)

    pcall(function()

        local jsonStr = self.m_socket:readString()
        log.i( "ItemDiscount change. current is " .. jsonStr);
        local jsonObj, flag = g_JsonUtil.decode(jsonStr);
        
        if flag and table.isTable(jsonObj) then
            if userData ~= nil then
                g_AccountInfo:setItemDiscount(jsonObj)
            end
        else
            Log.d("getItemDiscount", "decode json has an error occurred!");   --解析JSON出现错误
        end
    end);
end



TrumpetSocketManager.parseNewMessageData = function (self,data)
    Log.d("parseNewMessageData =  ",data)
    local template =  g_AppManager:getMessageTemplate()
    if data and #data > 0 then
        for i = 1, 1 do
            local msg = data[i];
            if msg then
                local parseData = {}
                parseData.m_id = string.format("%.0f", msg.a or 0); -- 消息ID
                parseData.m_msgType = msg.b or "";--消息类型，101表示邀请，102表示赠送礼物，103表示索要礼物；201表示公告，202表示活动，203表示更新；301表示支付完成
                parseData.m_hasReaded =(msg.c == 1); --消息是否已读，0表示未读，1表示已读
                parseData.m_date = msg.d or 0; -- 收到消息的时间
                parseData.m_msgParam = msg.e or ""; -- 消息参数，读取消息内容时需要用到
                parseData.m_templateID = msg.f or 0; -- 消息的模版ID，读取消息内容时需要用到
                parseData.m_fbId = msg.g or 0; -- 来源用户的FB平台siteuid，（仅在j=1时有效）
                parseData.m_dollId = msg.h or 0; -- 预留（为了兼容移动旧包）
                parseData.m_userId = msg.i or 0; -- 来源用户的玩家mid，（仅在j=1时有效）
                parseData.m_fromType = msg.j or 0; -- 来源类型，0-系统，1-玩家
                parseData.m_titleTemp = msg.k or 0; -- 消息标题的模板ID
                parseData.m_attaches = msg.l or {}; --附件奖励，格式json，例如:{'money':100,'prop':1,'exp':20}
                parseData.m_hasGetAttaches = (msg.m == 1); -- 附件奖励状态，0-未领取，1-已领取
                -- parseData.m_msgTitle = msg.n or ""; -- 消息标题参数,格式与[e:消息参数]一样
                parseData.m_time = msg.o or ""; -- 获得消息时间格式
                parseData.m_img = msg.img or "";  --图片url

          
                if type(template) ~= "table" then
                    return;
                end

                local content;
                if template and template.msgtype ~= nil then
                    for _, msgs in ipairs(template.msgtype) do
                        if tonumber(msgs.id) == msg.b then
                            for _, item in ipairs(msgs) do
                                if tonumber(item.a) == msg.f and msg.f~=10015 then
                                    content = item.b;
                                    parseData.event = tonumber(item.event);
                                    parseData.eventTitle = item.eventTitle;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end

                parseData.m_message = self:parseMessage(content, msg.e);
                return parseData.m_message
            end
        end
    end
end

TrumpetSocketManager.parseMessage = function(self,tpl, str)
    if not tpl or not str then return; end
    local reg = "<#([^#]+)##([^#]+)#>";
    for k, m in string.gmatch(str, reg) do
        local key = k;
        local value = string.gsub(m, "%%", "%%%%");
        value = string.gsub(value,","," ");
        tpl = string.gsub(tpl, "{" .. key .. "}", value);
    end
    return tpl;
end


TrumpetSocketManager.updateMttTickets = function(self)
    local str = self.m_socket:readString()
    local tickets, flag = g_JsonUtil.decode(str);
    if flag and g_TableLib.isTable(tickets) then
    --    Model.setProperty(ModelKeys.USER_DATA, "aTicket", tickets);   
       g_AccountInfo:setATicket(tickets) 
    end
end

return TrumpetSocketManager