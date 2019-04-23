local TaskVO = class("TaskVO");

TaskVO.STATUS_UNDER_WAY             = 0;
TaskVO.STATUS_CAN_REWARD            = 1;
TaskVO.STATUS_FINISHED              = 2;
TaskVO.ID_UPGRATE_AWARDS_ITEM       = 10000;

TaskVO.ctor = function (self)
    self.m_id            = 0;
    self.m_name          = "";
    self.m_desc          = "";      --任务内容描述
    self.m_reward        = "";      --任务奖励描述
    self.m_progress      = 0;       --当前进度
    self.m_target        = 1;       --总需求
    self.m_status        = 0;       --任务状态
    self.m_special       = 0;       --置顶任务的倍数
    self.m_iconUrl       = "";
    self.m_totalProgress = 0;       --任务总进度（用于任务链）
    self.m_canGet        = false;   --等级讲咯是否可以领奖
    self.m_post          = "";      --等级奖励领奖接口
    self.m_isLevelTask   = false;   --是不是等级奖励
end

TaskVO.dtor = function (self)
end

TaskVO.parse = function(self, value)
    self.m_id       = value["id"];
    self.m_name     = TaskVO.translateStr(value["name"])
    self.m_desc     = TaskVO.translateStr(value["desc"])
    self.m_reward   = TaskVO.translateStr(value["rewardDesc"],true)
    self.m_target   = tonumber(value["target"]);
    self.m_progress      = tonumber(value["m_progress"])
    if(value["status"] ~= nil) then
        self.m_status   = value["status"];
    end
    if(value["special"] ~= nil) then
        self.m_special  = value["special"];
    end
    if(value["url"] ~= nil) then
        self.m_iconUrl  = value["url"];
    end
    if(value["canGet"] ~= nil) then
        self.m_canGet   = (value["canGet"] == 1) and true or false;
        self.m_status   = self.m_canGet and self.STATUS_CAN_REWARD or self.STATUS_UNDER_WAY
    end
    if(value["post"] ~= nil) then
        self.m_post     = value["post"];
    end

end

TaskVO.canRecieveReward = function(self)
    return TaskVO.STATUS_CAN_REWARD == self.m_status
end

TaskVO.compareStatus = function(self, taskVO1, taskVO2)
    local ret = 0;
    local temp1 = TaskVO.translateStatus(taskVO1.m_status);
    local temp2 = TaskVO.translateStatus(taskVO2.m_status);
    if temp1 > temp2 then
        ret = 1;
    elseif temp1 < temp2 then
        ret = -1;
    end
    return ret;
end

TaskVO.translateStatus = function(status)
    local ret = 0;
    local statusTemp = status;
    if statusTemp == TaskVO.STATUS_CAN_REWARD then
        ret = -1;
    elseif statusTemp == TaskVO.STATUS_FINISHED then
        ret = 1;
    elseif statusTemp == TaskVO.STATUS_UNDER_WAY then
        ret = 0;
    end
    return ret;
end

TaskVO.translateStr = function(str,isTransNewLine)
    local ret = str
    local transTable = GameString.get("str_task_trans")
    if transTable and type(transTable) == "table" and type(str) == "string" then
        for k,v in pairs(transTable) do
            ret = string.gsub( ret,v[1],v[2] )

            --ret = string.gsub( ret,"[%a,%a]","\n" )

            if isTransNewLine then
                local len = string.len(ret)
                for i=1,len do
                    if string.sub(ret,i,i) == ','  then
                        if i>1 and i < len and not tonumber(string.sub(ret,i-1,i-1)) and not tonumber(string.sub(ret,i+1,i+1) ) then
                            ret =   string.sub(ret,1,i-1).."\n".. string.sub(ret,i+1)
                        end 
                    end
                end
            end
        end
    end
    return ret
end


return TaskVO;
