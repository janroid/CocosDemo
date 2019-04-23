local MTTUtil = {}

MTTUtil.timeUtils = function(self,value)
	local result = value;
	if string.len(result) < 2 then
		result = "0" .. result;
	end
	return result;
end
		
MTTUtil.culTime = function(self,beginTime,nowTime,_flag)
	local beginDate = os.date("*t",beginTime/1000);
    local nowDate = os.date("*t",nowTime/1000); 
	local ret = "";
	local temp = beginTime - nowTime + (nowDate.hour*60*60 + nowDate.min*60 + nowDate.sec)*1000
    local flag = false;
    if _flag then
        flag = true;
    end
	if temp >=0 then
		local hour = math.floor((temp/1000)/60/60);
		if hour >=72 then
			-- ret = beginDate.month .. "-" .. beginDate.day .. "-";
            ret = beginDate.month .. GameString.get("str_new_mtt_month") .. beginDate.day..GameString.get("str_new_mtt_day") .. " "
            flag = true;
		elseif hour < 72 and hour >= 48 then
			ret = GameString.get("str_new_mtt_the_day_after_tomorrow");--后天
		elseif hour <48 and hour>= 24 then
			ret = GameString.get("str_new_mtt_tomorrow");--"明天"
		else
			ret = GameString.get("str_new_mtt_today");--"今天";
        end
    else
		if beginDate.day == nowDate.day then
			ret = GameString.get("str_new_mtt_today"); --"今天";
		else
			-- ret = beginDate.month .. "-" .. beginDate.day .. "-";
            ret = beginDate.month .. GameString.get("str_new_mtt_month") .. beginDate.day..GameString.get("str_new_mtt_day") .. " "
            flag = true;
		end
	end
    if flag then
        ret = ret .. self:timeUtils(tostring(beginDate.hour)) .. ":" .. self:timeUtils(tostring(beginDate.min));
    end
	return ret;
end
		
MTTUtil.getMttDataByMid = function(mid,time)
	local ret = nil;
	local mttListArray = g_Model:getData(g_ModelCmd.NEW_MTT_ALL_LIST_DATA);
	if mttListArray then
		local listLength = #mttListArray;
        for i = 1, listLength do
            if time then
                if tostring(mid) == tostring(mttListArray[i].mid) and tostring(time) == tostring(mttListArray[i].time) then
                    ret = mttListArray[i];
                    break;
                end
            else
                if tostring(mid) == tostring(mttListArray[i].mid) then
                    ret = mttListArray[i];
                    break;
                end
            end
		end
	end
	return ret;
end


MTTUtil.sortSignupArr = function(signup)
    if signup and g_TableLib.isTable(signup) then
        local arr = {}-- 6:免费,4:参赛券,3:积分,1:筹码,2:卡拉币
        for i,v in ipairs({"6","4","3","1","2"}) do
            for i,v1 in ipairs(signup) do
                if v==v1 then
                    table.insert(arr,v)
                end
            end
        end
        return arr
    end
end

MTTUtil.getUserSignupWay = function(data)
    local sign = data.payType or 0;
    local signArr = {sign}
	if sign == 0 then
        signArr = g_StringLib.split(data.signup,",");
    else
        return signArr
    end
    if #signArr==1 then -- 只有一种
        return signArr
    else
        local payArr = {}
        for i,sign in ipairs(signArr) do
            local num 
            if sign == "1" then --筹码
                local arr = g_StringLib.split(data.chips,"|");
                if arr[2] and arr[2] ~= 0 then
                    num = tonumber(arr[1])+ tonumber(arr[2])
                else
                    num = tonumber(arr[1])
                end
                if tonumber(g_AccountInfo:getMoney()) >= num then
                    table.insert(payArr, sign);
                end
        
            elseif sign == "2" then	--卡拉币
                local arr1 = g_StringLib.split(data.coalaa,"|");
                if arr1[2] and arr1[2] ~= 0 then
                    num = tonumber(arr1[1])+ tonumber(arr1[2])
                else
                    num = tonumber(arr1[1])
                end
                if tonumber(g_AccountInfo:getUserCoalaa()) >= num then
                    table.insert(payArr, sign);
                end
        
            elseif sign == "3" then--积分
                if tonumber(g_AccountInfo:getScore()) >= tonumber(data.point) then
                    table.insert(payArr, sign);
                end
        
            elseif sign == "4" then--门票
        
                local allTicket = g_AccountInfo:getATicket()
                if allTicket and not g_TableLib.isEmpty(allTicket) then
                    for key, value in pairs(allTicket) do
                        if data and tostring(data.ticketType) == tostring(key) then
                            if tonumber(value) >= 1 then
                                table.insert(payArr, sign);
                            end
                        end
                    end
                end
        
            else --免费
                return {sign}
            end
        end
        if g_TableLib.isEmpty(payArr) then --都不满足
                
            for i,v in ipairs(signArr) do
                if v==1 then
                    table.insert(payArr,v); -- 都不满足 有筹码 显示筹码
                    return payArr
                end
            end
            table.insert(payArr,signArr[1]); -- 都不满足 无筹码 就只显示第一个
        end
        return payArr
    end
end

MTTUtil.getDisplaySignupWay = function (data)
	local str = "";
    local signupArr = MTTUtil.getUserSignupWay(data)
    signupArr = MTTUtil.sortSignupArr(signupArr)
    local sign = tonumber(signupArr[1]);
    if sign == 1 then --筹码
		local arr = g_StringLib.split(data.chips,"|");
		if arr[2] and arr[2] ~= 0 then
			str = g_MoneyUtil.formatMoney(tonumber(arr[1])) .. " + " .. g_MoneyUtil.formatMoney(tonumber(arr[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr[1]));
        end

    elseif sign == 2 then	--卡拉币
		local arr1 = g_StringLib.split(data.coalaa,"|");
		if arr1[2] and arr1[2] ~= 0 then
			str =  g_MoneyUtil.formatMoney(tonumber(arr1[1])) .. " + " ..  g_MoneyUtil.formatMoney(tonumber(arr1[2]));
		else
			str = g_MoneyUtil.formatMoney(tonumber(arr1[1]));
        end

    elseif sign == 3 then--积分
        str = g_StringLib.substitute(GameString.get("str_new_mtt_sign_up_point"),data.point)

    elseif sign == 4 then--门票

        str = GameString.get("str_new_mtt_sign_up_ticket")

    else --免费
        str = GameString.get("str_new_mtt_list_free")

	end

	return str
end


return MTTUtil