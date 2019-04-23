--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local StatisticReportTool = {};
StatisticReportTool.TAG = "StatisticReportTool";

StatisticReportTool.loginEvent      = "iPoker_Login";
StatisticReportTool.FBInviteEvent   = "iPoker_Invite";
StatisticReportTool.homeEvent       = "iPoker_Home";
StatisticReportTool.FriendEvent     = "iPoker_Friend";

StatisticReportTool.templet ='{"{0}":{1}}';--上报模板

StatisticReportTool.reportData = function (eventId,data,num)
    g_HttpManager:doPost(
                    {["mod"] = "dc",
                        ["act"] = "sendEvent",
                        ["aEventId"] = eventId,
                        ["aEventData"] = g_StringUtils.substitute(StatisticReportTool.templet, data, num or 1)
                    }, 
                    StatisticReportTool,StatisticReportTool.onReportResp)--StatisticReportTool.reportSucc, StatisticReportTool.reportErr, StatisticReportTool.reportTimeout);
end

StatisticReportTool.onReportResp = function(isSuccess,data,param)
    if not isSuccess then
		StatisticReportTool.reportErr()
		return
    end
    
    StatisticReportTool:reportSucc()
end

StatisticReportTool.reportFriend = function(data)
    StatisticReportTool.reportData(StatisticReportTool.FriendEvent,data);
end

StatisticReportTool.reportFBInvite = function(data,num)
    StatisticReportTool.reportData(StatisticReportTool.FBInviteEvent,data,num); 
end

StatisticReportTool.reportHome = function(data)
    StatisticReportTool.reportData(StatisticReportTool.homeEvent,data);
end

StatisticReportTool.reportLogin = function (data)
    StatisticReportTool.reportData(StatisticReportTool.loginEvent,data);      
end

StatisticReportTool.reportSucc = function(self,data)
    Log.d(StatisticReportTool.TAG,"reportSucc",data);
end

StatisticReportTool.reportErr = function(self,data)
    Log.d(StatisticReportTool.TAG,"reportErr");
end

StatisticReportTool.reportTimeout = function(self,data)
    Log.d(StatisticReportTool.TAG,"reportTimeout");
end

return StatisticReportTool

--endregion
