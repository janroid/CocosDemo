local MTTListTimeView = class();
local MTTUtil = require('MTTUtil')

MTTListTimeView.ctor = function(self,prop1,prop2)

    self:init();
    self.m_timeLabel = prop2
    self.m_dayLabel = prop1
end

MTTListTimeView.dtor = function(self)
    self:stopInterval();
end

MTTListTimeView.clear = function(self)
    self:stopInterval()
    self:init()
    
end

MTTListTimeView.init = function(self)
    self.m_currentTime = 0;
    self.m_remainStartTime = 0;--剩余开赛时间
    self.m_remainDelayTime = 0;--剩余延迟进入时间
    self.m_delayEnterTime = 0;--延迟进入时间
    self.m_mttData = {};
    self.TIME_START_ANIMATION = 20 * 60 * 1000;--初始化时，如果距离开赛时间20分钟内开始启动计时器用于倒计时5分钟
    self.m_needFresh = false;--是否已经主动请求刷新过列表
    self.TIME_TEN_MINITE = 10 * 60 * 1000;--距离开赛10分钟请求刷新一次列表
end

MTTListTimeView.setDataLabel = function(self,str)
    local arr = g_StringLib.split(str,"\r"); -- 过长显示不全? 繁体不会!!!
    if arr and arr[2] then
        self.m_dayLabel:setString(arr[1].." "..arr[2]);
    else
        self.m_dayLabel:setString(arr[1]);
    end
end

MTTListTimeView.setInfo = function(self,data)
    self:clear()
    self.m_mttData = data;
    self.m_mttData.beftime = tonumber(self.m_mttData.beftime);
    self.m_mttData.delay = tonumber(self.m_mttData.delay);
    self.m_nowTime = self.m_mttData.now * 1000;
    self.m_nowTime = require(".MttManager").s_nowTime * 1000;
    self.m_beginTime = self.m_mttData.time * 1000;
    self.m_nowDate = os.date("*t",self.m_nowTime/1000);
    self.m_beginDate = os.date("*t",self.m_beginTime/1000);
    self.m_remainStartTime = self.m_beginTime - self.m_nowTime;
    self.m_remainDelayTime = self.m_remainStartTime + self.m_mttData.delay*1000;
    self:setDataLabel(self:culTime(self.m_remainStartTime , (self.m_nowDate.hour*60+self.m_nowDate.min)*60*1000));

    if (self.m_remainStartTime <= self.TIME_START_ANIMATION or self.m_mttData.btn == 4) and (self.m_remainStartTime > 0 or self.m_remainDelayTime>0) then
        --第一次跑到10分钟才需要刷新一次列表 未报名的玩家不刷新列表
        if self.m_remainStartTime >= self.TIME_TEN_MINITE and self.m_mttData.btn == 4 then
            self.m_needFresh = true;
        else
            self.m_needFresh = false;
        end
        self:intervalHandler();
        self:startInterval();
                
    else

        self:stopInterval();
        self:showStaticLabel();
    end
end
            
        
        
MTTListTimeView.stopInterval = function(self)
    if self.m_scheduleTask then
        g_Schedule:cancel(self.m_scheduleTask.eventObj)
    end
end
        
MTTListTimeView.startInterval = function(self)
    self:stopInterval();
    self.m_currentTime = os.time();
    self.m_scheduleTask = g_Schedule:schedule(function()
		self:intervalHandler()
	end,1,1,1000) 
end
        

MTTListTimeView.intervalHandler = function(self)
    local _time = os.time();
    if self.m_currentTime == 0 then
        self.m_currentTime = _time;
    end
    self.m_remainStartTime = self.m_remainStartTime - (_time-self.m_currentTime)*1000;
    self.m_remainDelayTime = self.m_remainDelayTime - (_time-self.m_currentTime)*1000;
            
    self.m_currentTime = _time;
            
    --开赛前10分钟入场 请求刷新一次列表
    if self.m_needFresh and self.m_remainStartTime <= self.TIME_TEN_MINITE and self.m_mttData.btn == 4 then --报名的玩家才需要刷新
        self.m_needFresh = false;
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_GET_LIST_REQUEST);
    end
            
    --大于提前进入时间 不显示倒计时
    if self.m_remainStartTime > tonumber(self.m_mttData.beftime)*1000 then
        self:showStaticLabel();
    elseif self.m_remainStartTime >0 and self.m_remainStartTime <= self.m_mttData.beftime*1000 +5000 then --提前进入时间
        self:showDynamicLabel(self.m_remainStartTime);
        if self.m_remainStartTime > self.m_mttData.beftime*1000-500 and self.m_remainStartTime <= self.m_mttData.beftime*1000+500 then --达到临界值 请求数据
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_GET_LIST_REQUEST);
        end				
    elseif self.m_remainStartTime <= 0 and self.m_remainDelayTime >= 0 then--在延迟进入时间之内
        self:showDynamicLabel(self.m_remainDelayTime);
        if self.m_remainStartTime > -1000 then --达到临界值 拉取一次php数据
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_GET_LIST_REQUEST);
            self:showDynamicLabel(self.m_remainStartTime);
        end
    else
        self:stopInterval();
        g_EventDispatcher:dispatch(g_SceneEvent.MTT_GET_LIST_REQUEST);
    end
            
    if self.m_mttData.btn == 7 or self.m_mttData.btn == 6 then --出现没人报名 比赛一开始就比赛结束了 就需要停掉倒计时
        self:stopInterval();
        self:showStaticLabel();
    end
            
    -- self:setDataLabel(self:culTime(self.m_remainStartTime ));--+ (self.m_nowDate.hour*60+self.m_nowDate.min)*60*1000)
    self:setDataLabel(self:culTime(self.m_remainStartTime , (self.m_nowDate.hour*60+self.m_nowDate.min)*60*1000));
end
        
MTTListTimeView.showStaticLabel = function(self)
    local str = MTTUtil:timeUtils(tostring(self.m_beginDate.hour)) .. " : " .. MTTUtil:timeUtils(tostring(self.m_beginDate.min));
    self.m_timeLabel:setString(str);
end
        
MTTListTimeView.showDynamicLabel = function(self,time)
    local hour = MTTUtil:timeUtils(tostring(math.floor(time/1000/60)));
    local minute = MTTUtil:timeUtils(tostring(math.floor((time/1000) % 60)));
    local str = MTTUtil:timeUtils(tostring(hour)) .. " : " .. MTTUtil:timeUtils(tostring(minute));
    self.m_timeLabel:setString(str);
end

MTTListTimeView.culTime = function(self,temp,ct)
    local ret = "";
    if temp >= 0 and temp <= tonumber(self.m_mttData.beftime)*1000 and self.m_mttData.btn ~=7 then
        ret = GameString.get("str_new_mtt_coming");--"即将开始";
    elseif temp < 0 and math.abs(temp)<tonumber(self.m_mttData.delay)*1000 and self.m_mttData.btn ~=7 then
        ret = GameString.get("str_new_mtt_delay_enter");--"延迟进入";
    elseif (temp+ct) > tonumber(self.m_mttData.beftime)*1000 then
        local hour = math.floor(((temp+ct)/1000)/60/60);
        if hour >=72 then
            ret = tostring(self.m_beginDate.month) .. GameString.get("str_new_mtt_month") .. self.m_beginDate.day..GameString.get("str_new_mtt_day");
        elseif hour < 72 and hour >= 48 then
            ret = GameString.get("str_new_mtt_the_day_after_tomorrow");--"后天";
        elseif hour <48 and hour>= 24 then
            ret = GameString.get("str_new_mtt_tomorrow");--"明天";
        else
            ret = GameString.get("str_new_mtt_today");--"今天";
        end
    elseif self.m_mttData.btn ~=7 then
        ret = GameString.get("str_new_mtt_on"); --"进行中";
    else
        ret = tostring(self.m_beginDate.month) .. GameString.get("str_new_mtt_month") .. self.m_beginDate.day..GameString.get("str_new_mtt_day");
        ret =  ret .. GameString.get("str_new_mtt_end"); --"已结束";
    end
    return ret;
end
return MTTListTimeView