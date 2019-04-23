local NumberLib = require("NumberLib");
local TableLib = require("TableLib");

local TimeLib = {};

TimeLib.TIME_DAY       = 24 * 60 * 60;
TimeLib.TIME_HOUR      = 60 * 60;
TimeLib.TIME_MIN       = 60;

--@brief 获取当天0时0分0秒的时间戳
function TimeLib.getDayStartTime(timestamp)
    local timeTable = os.date("*t", timestamp);
    timeTable.hour = 0;
    timeTable.sec = 0;
    timeTable.min = 0; 
    return os.time(timeTable) or 0;
end

--@brief 获取二个时间戳相隔多少天
function TimeLib.getDayInterval(timestampA, timestampB)
    local timeA = TimeLib.getDayStartTime(timestampA);
    local timeB = TimeLib.getDayStartTime(timestampB);
    local secondADay = 24 * 3600;
    local day = math.floor((timeB - timeA) / secondADay);
    return day;
end


--@brief 判断timestampA和timestampB是否为同一天
function TimeLib.isSameDay(timestampA, timestampB)
    local timeTableA = os.date("*t", timestampA);
    local timeTableB = os.date("*t", timestampB);
    if timeTableA.year == timeTableB.year and 
        timeTableA.month == timeTableB.month and 
        timeTableA.day == timeTableB.day then
        return true;
    end
    return false;
end

--@brief 判断timestampA和timestampB是否为同一月
function TimeLib.isSameTimeLibonth(timestampA, timestampB)
    local timeTableA = os.date("*t", timestampA);
    local timeTableB = os.date("*t", timestampB);
    if timeTableA.year == timeTableB.year and 
        timeTableA.month == timeTableB.month then
        return true;
    end
    return false;    
end

-- 获取当前日期格式
-- return {
--  hour  时
--  min   分
--  wday  星期几(1 - 7)
--  day   日
--  month  月
--  year  年
--  sec   秒
--  yday  年内天数
--  isdst  是否夏令时    
--}
function TimeLib.getToday()
    local times = os.date("*t",os.time());
    local week = times.wday;
    week = week -1;
    if week == 0 then
        week = 7;
    end
    times.wday = week;

    return times;
end

-- 把秒转换为时间格式
-- return {
--  hour  时
--  min   分
--  wday  星期几(1 - 7)
--  day   日
--  month  月
--  year  年
--  sec   秒
--  yday  年内天数
--  isdst  是否夏令时    
--}
function TimeLib.getTimerBySecond(second)
    local times = os.date("*t",second);
    local week = times.wday;
    week = week -1;
    if week == 0 then
        week = 7;
    end
    times.wday = week;

    return times;
end

-- 将long转换成日期格式
-- @param regex 日期格式
--   %Y 年
--   %m 月
--   %d 日
--   %H 时
--   %M 分
--   %S 秒
-- 例：getTimeYMDHMS("%Y年%m月%d日 - %H:%M:%S"), 输出："2018年12月1日 - 12:30:20"
function TimeLib.getTimeYMDHMS(regex,time)
    local days = "";
    if time and tonumber(time) then
        local timeNum = tonumber(time);
        timeNum = math.abs(timeNum);
        days = os.date(regex,timeNum);
    end
    return days;
end

function TimeLib.getRegularDate(time)
    local days = "";
    if time and tonumber(time) then
        local date = os.date("*t",time)
        days = date.year .. '-' .. date.month.. '-' .. date.day
    end
    return days;
end


-- 拆分时间
function TimeLib.skipTimeHMS(time)
    local times = nil;
    local hour = nil;
    local min  = nil;
    local sec  = nil;
    if time then
        local timeNum = tonumber(time);
        if timeNum and timeNum > 0 then
            hour = os.date("*t",timeNum).hour - 8;
            min  = os.date("*t",timeNum).min;
            sec  = os.date("*t",timeNum).sec;

            hour = string.format("%02d",hour);
            min = string.format("%02d",min);
            sec = string.format("%02d",sec);
        end
    end
    return hour,min,sec;
end

--输入两个时间的秒数，获取两个时间差
--输出格式time = {sec=0, min=0, hour= 0, day=1}
function TimeLib.timeDiff(long_time,short_time)
    local diff = {sec=0, min=0, hour= 0, day=0};  
    if not long_time or not short_time then
        return diff
    end
    local diff_time  = long_time - short_time
    if diff_time <= 0 then
        return diff
    end
    local n_diff_time  = os.date('*t',diff_time)
    for i,v in ipairs({'sec','min','hour','yday'}) do  
       if v == "yday" then
           diff.day = n_diff_time[v] - 1
       elseif v == "hour" then
               diff.hour = n_diff_time[v] - 8
       else
           diff[v] = n_diff_time[v]
       end 
    end

    return diff  
end 

-- 获取x天后剩余秒数
function TimeLib.getRemainSecondsByDays(days)
    local curTime = TimeLib.getToday();
    local hour = curTime.hour;
    local minutes = curTime.min;
    local curCostSeconds = hour * TimeLib.TIME_HOUR + minutes * TimeLib.TIME_MIN + curTime.sec;
    local totalDays = days or 1;
    local remainSeconds = TimeLib.TIME_DAY * totalDays - curCostSeconds;
    return remainSeconds;
end

function TimeLib.seconds2hhmmss(seconds)
    local  strTime = "";
    if seconds >= 60*60 then
        local hour = math.floor(seconds / (60*60));
        local min = math.floor((seconds - hour * 60*60) / 60);
        local second = seconds%60;
        strTime = string.format("%02d:%02d:%02d", hour, min, second);
    else
        local min = math.floor(seconds / 60);
        local second = seconds%60;
        strTime = string.format("%02d:%02d", min, second);
    end
    return strTime;
end

--[[
返回当前的系统时区（单位：秒）
--]]
function TimeLib.getTimeZone()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end

function TimeLib.secondTo0M0S(value)
    value = value<0 and 0 or value
    local second = math.modf(value % 60);
    local minute = math.floor(value / 60);
    local result = (minute < 10 and "0" or "")..minute..":"..(second < 10 and "0" or "")..second;
    return result;
end
TimeLib.secondTo0H0M = function(value)
    local minute = math.floor( math.modf(value % 3600) / 60);
    local hour = math.floor(value / 3600);
    local result = hour..":"..(minute < 10 and "0" or "")..minute;
    return result;
end

TimeLib.secondTo0M = function(value)
    local minute = math.floor(value / 60);
    return (minute < 10 and "0" or "")..minute;
end

TimeLib.secondTo0S = function(second)
    second = second % 60;
    return (second < 10 and "0" or "")..second;
end

return TimeLib;