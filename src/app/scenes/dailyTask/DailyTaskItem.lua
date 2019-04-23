local DailyTaskItem  = class("DailyTaskItem",cc.TableViewCell)
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local BehaviorMap = import("app.common.behavior").BehaviorMap;
local NetImageView = import("app.common.customUI").NetImageView;
local DailyTaskManager = require("DailyTaskManager");
local TaskVO = require("TaskVO")
DailyTaskItem.DEFAULT_TASK_ICON= "creator/dailyTask/imgs/icon_unload.png"

BehaviorExtend(DailyTaskItem)

function DailyTaskItem:ctor(data,special)   
    self:bindBehavior(BehaviorMap.DownloadBehavior);
    self:init(data,special)
end 

function DailyTaskItem:dtor()

end

function DailyTaskItem:init(data,special)   
    local root = g_NodeUtils:getRootNodeInCreator('creator/dailyTask/dailyTaskItem.ccreator')
    self.m_root = g_NodeUtils:seekNodeByName(root,"root");
    self:addChild(self.m_root)
    local s = self.m_root:getContentSize()
    self.m_root:setPosition(s.width/2,s.height/2)

    self.m_imgItemBg            = g_NodeUtils:seekNodeByName(self.m_root,'img_item_bg');
    self.m_imgIconBg            = g_NodeUtils:seekNodeByName(self.m_root,'img_icon_bg');
    self.m_imgTaskIcon          = g_NodeUtils:seekNodeByName(self.m_root,'img_task_icon');
    self.m_imgSpecialMark       = g_NodeUtils:seekNodeByName(self.m_root,'img_star_mark');
    self.m_txTaskName           = g_NodeUtils:seekNodeByName(self.m_root,'label_task_name');
    self.m_txTaskDec            = g_NodeUtils:seekNodeByName(self.m_root,'label_task_describe');
    self.m_txReward             = g_NodeUtils:seekNodeByName(self.m_root,'label_reward');
    self.m_imgDouble            = g_NodeUtils:seekNodeByName(self.m_root,'img_double');
    self.m_nodeProgress         = g_NodeUtils:seekNodeByName(self.m_root,'img_progress_bg');
    self.m_imgProgress          = g_NodeUtils:seekNodeByName(self.m_root,'img_progress_fg');
    self.m_txProgress           = g_NodeUtils:seekNodeByName(self.m_root,'label_progress');
    self.m_btnGetReward         = g_NodeUtils:seekNodeByName(self.m_root,'btn_get_reward');
    self.m_txGetReward          = g_NodeUtils:seekNodeByName(self.m_root,'label_get_reward');
    self.m_txtUnderWay          = g_NodeUtils:seekNodeByName(self.m_root,'label_under_way');
    self.m_txtFinished          = g_NodeUtils:seekNodeByName(self.m_root,'label_finished');

    self.m_imgSpecialMark:setVisible(false)
    self.m_imgDouble:setVisible(false)
    self.m_btnGetReward:setVisible(false)
    self.m_nodeProgress:setVisible(false)
    self.m_txtUnderWay:setVisible(false)
    self.m_txtFinished:setVisible(false)

    self.m_txGetReward:setString(GameString.get("str_task_recieve_reward"))
    self.m_txtUnderWay:setString(GameString.get("str_task_running"))
    self.m_txtFinished:setString(GameString.get("str_task_finished"))

    local size = self.m_imgProgress:getContentSize()
    size.width = 0
    self.m_imgProgress:setContentSize(size)
    self.m_txProgress:setString("0/0")
    self.m_txProgress:setTextColor(cc.c4b(255,255,255,255))

    self.m_btnGetReward:addClickEventListener(function(sender)
        self:onBtnGetRewardClick()
    end)
    
    self:setSpecial(special)
end

function DailyTaskItem:setSpecial(special)
    if special == nil then
        special = false;
    end
    local colorName =cc.c3b(255,255,255)
    local colorDes =cc.c3b(149,219,210)
    if special then
        self.m_imgItemBg:setTexture("creator/dailyTask/imgs/list_top_item_bg.png")
        
    else
        self.m_imgItemBg:setTexture("creator/dailyTask/imgs/list_item_bg.png")
        colorName = cc.c3b(196,234,246)
        colorDes =cc.c3b(103,168,249)
    end
    


    self.m_txTaskName:setColor(colorName)
    self.m_txTaskDec:setColor(colorDes)

   
    self.m_txReward         :setColor(cc.c3b(242,238,140))
    

    -- self.m_txtReward2       : setColor(self:getSpecialColor(special, 0x7c452c, 0xff7e00));
    -- self.m_txtReward3       : setColor(self:getSpecialColor(special, 0x7c452c, 0xff7e00));
    self.m_txtUnderWay      : setTextColor(cc.c4b(self:getSpecialColor(special, 0x67D0EE, 0x67D0EE)));
    self.m_txtFinished      : setTextColor(cc.c4b(self:getSpecialColor(special, 0x67D0EE, 0x67D0EE)));

    self.m_imgSpecialMark   : setVisible(special);
    self.m_imgDouble        : setVisible(special)
    -- self.m_imgDivision      : setVisible(not special);
end

function DailyTaskItem:getSpecialColor(special,color1,color2)
    local r, g, b = 0, 0, 0;
    local a = 255
    if special then
        r, g, b = g_RGBUtil.getRGB(color1);
    else
        r, g, b = g_RGBUtil.getRGB(color2);
    end
    return r, g, b, a;
end

function DailyTaskItem:updateCell(data)
    -- {
    --     "m_isLevelTask": false,
    --     "m_target": 6,
    --     "m_status": 0,
    --     "m_progress": 0,
    --     "m_name": "充值有奖",
    --     "m_desc": "累计充值6元",
    --     "m_id": "300",
    --     "m_iconUrl": "",
    --     "m_post": "",
    --     "m_special": 0,
    --     "m_canGet": false,
    --     "m_totalProgress": 0,
    --     "m_reward": "奖励1500筹码"
    -- }
    self.m_data = data or TaskVO:create()
    self.m_imgTaskIcon:removeAllChildren()
    -- TaskIconCache.getInstance():addIcon(self.m_data, self.m_imgTaskIcon, size.width,size.height);
    self:addIcon(self.m_data,self.m_imgTaskIcon,size)
    self.m_txTaskName:setString(self.m_data.m_name or "")
    self.m_txTaskDec:setString(self.m_data.m_desc or "")
    --self.m_txReward:setString(  DailyTaskManager.getInstance():convertToFormatString(self.m_data.m_reward) )
    self.m_txReward:setScale(1)
    self.m_txReward:setString(  self.m_data.m_reward or "" )


    self.m_nodeProgress     : setVisible(false);
    self.m_txtUnderWay      : setVisible(false);
    self.m_btnGetReward     : setVisible(false);
    self.m_txtFinished      : setVisible(false);

    if self.m_data.m_status == TaskVO.STATUS_UNDER_WAY then -- 任务状态 进行中 已完成
        if self.m_data.m_target <= 0 then
            self.m_txtUnderWay:setVisible(true);

        elseif not self.m_data.m_isLevelTask then
            -- self.m_progress:setMaxValue(self.m_data.m_target);
            -- self.m_progress:setProgress(self.m_data.m_progress / self.m_data.m_target);
            -- self.m_progress:setVisible(true);
            local size = self.m_nodeProgress:getContentSize()
            size.width = size.width * (self.m_data.m_progress / self.m_data.m_target)
            self.m_imgProgress:setContentSize(size)
           
            local x = self.m_data.m_progress
            if math.floor(x)<x then
                self.m_txProgress:setString(string.format( "%.2f/%d",x,self.m_data.m_target))
            else
                self.m_txProgress:setString(self.m_data.m_progress .. "/" .. self.m_data.m_target)
            end
            
            self.m_nodeProgress:setVisible(true)
        elseif self.m_data.m_isLevelTask then
            self.m_txtUnderWay:setVisible(true);
        end
    
    elseif self.m_data.m_status == TaskVO.STATUS_FINISHED then
            self.m_txtFinished:setVisible(true);

    elseif self.m_data.m_status == TaskVO.STATUS_CAN_REWARD then
            self.m_btnGetReward:setVisible(true);
    end

    if self.m_special then
        self.m_imgSpecialMark:setVisible(true);
        self.m_imgDouble:setVisible(true);
    end
    
end

function DailyTaskItem:addIcon(data,view)
    local size = view:getContentSize()
    local url = self:getIconUrl(data);
    self:downloadImg(url,function(self,data)
        if data.isSuccess then 
            local src = data.fullFilePath;
            Log.d("DailyTaskItem src = ",src)
            view:setTexture(src);
        else
            view:setTexture(DailyTaskItem.DEFAULT_TASK_ICON)
        end
        view:setContentSize(size) 
     end)
end

function DailyTaskItem:getIconUrl(data)
    local CNDURL = g_AccountInfo:getCDNUrl()
    if CNDURL == nil then
        CNDURL = "";
    end
    local iconUrl = CNDURL .. "images/mobileTask/"..((data.m_iconUrl ~= nil and string.len(data.m_iconUrl) > 0) and data.m_iconUrl or data.m_id);
    if string.find(iconUrl,".png") == nil and string.find(iconUrl,".jpg") == nil then
        iconUrl = iconUrl..".png";
    end
    return iconUrl;
end

function DailyTaskItem:getDisplaySize()
    return self.m_root:getContentSize();
end

function DailyTaskItem:onBtnGetRewardClick()
    if self.m_data ~= nil then
        if self.m_data.m_canGet and self.m_data.m_post then
            self.m_data_last = self.m_data;
--            EventDispatcher.getInstance():dispatch(
--                UIEvent.s_event,
--                UIEvent.s_cmd.OPEN_DIALOG,{
--                    ["message"] = StringKit.substitute(STR_ACTIVITY_NEW_YEAR_ACT_GET_REWARD_TITLE, self.m_data.m_reward);
--                    ["confirm"] = STR_COMMON_CONFIRM,
--                    ["obj"]     = self,
--                    ["callback"]= self.onConfirm
--                }
--            );
            local postStr = self.m_data.m_post;
            local arr = g_StringLib.split(postStr, "_");
            if arr ~= nil and #arr == 2 then
                local param = {
                    ["mod"]     = arr[1],
                    ["act"]     = arr[2],
                    ["id"]      = self.m_data.m_id,
                    ["target"]  = self.m_data.m_target
                }
                g_HttpManager:doPost(param, self, self.onGetRewardCallback);
            end

        else
            self.m_btnGetReward:setVisible(false);
            local param = {
                ["mod"] = "taskNew", 
                ["act"] = "reward",
                ["id"]  = self.m_data.m_id
            };
            if(self.m_data.m_post ~= nil) then
                local postStr = self.m_data.m_post;
                local arr = g_StringLib.split(postStr, "_");
                if arr ~= nil and #arr == 2 then
                    param.mod = arr[1];
                    param.act = arr[2];
                    param.target = self.m_data.m_target;
                end
            end
            g_HttpManager:doPost(param, self, self.onGetRewardCallback);
        end
    end
end

function DailyTaskItem:onGetRewardCallback(isSuccess,data)
    if g_TableLib.isTable(data) then
        -- 领奖成功
        Log.d("DailyTask get reward success!") --動畫資源暫無
        --[[
            ret == 0 --其他情况
            ret == 1 --领取成功
            ret == -7 --奖励已经领取过了/每日支付没有达到要求/送他人礼物任务没达到次数/道具类任务没达到次数/今日玩牌不够
        ]]
        if data.ret == 1 or data.ret == 0 then 
            DailyTaskManager.getInstance():showReward(data)
                    
        else
            if data.ret == -7 then
                self.m_btnGetReward:setVisible(false);
            else
                self.m_btnGetReward:setVisible(true);
            end
            return;
        end
                
        if data.task ~= nil and data.ret == 0 then
            --还有后续任务了
            local oldProgress = self.m_data.m_target;
            self.m_data:parse(data.task);
            self.m_data.m_progress = oldProgress;
            if data.task.canGet ~= nil and data.task.canGet == 1 then
                self.m_data.m_status = TaskVO.STATUS_CAN_REWARD;
            else
                self.m_data.m_status = TaskVO.STATUS_UNDER_WAY;
            end

        elseif data.ret == 1 then
            -- --没有后续任务了，任务链完成
            self.m_data.m_status  = TaskVO.STATUS_FINISHED;
            local allTaskV        = g_Model:getData(g_ModelCmd.ALL_TASK_LIST);
            local index           = g_TableLib.indexof(allTaskV, self.m_data);
            if index ~= false then
                g_ArrayUtils.splice(allTaskV, index, 1);
                local temp = g_ArrayUtils.pop(allTaskV);
                g_ArrayUtils.push(allTaskV, self.m_data);
                g_ArrayUtils.push(allTaskV, temp);
            end
                    
            local roomTaskV = g_Model:getData(g_ModelCmd.ROOM_TASK_LIST);
            index = g_TableLib.indexof(roomTaskV, self.m_data);
            if index ~=  false then
                g_ArrayUtils.splice(roomTaskV, index, 1);
                g_ArrayUtils.push(roomTaskV, self.m_data);
            end
        end
        DailyTaskManager.getInstance():getTaskListAll();
    else
        self.m_btnGetReward:setVisible(true);
        g_AlarmTips.getInstance():setTextAndShow(GameString.get('str_common_network_recieve_fail'))
    end
end

return DailyTaskItem