--[[
    author:{JanRoid}
    time:2018-12-11 
    Description: 游戏币格式化
]] 

local MoneyUtil = {}

--- 根据地区自动适配钱格式, ',' 与 'K'， 'M'， 'B'等方式
--- 拆分金币每3位用逗号隔开, 或者格式化游戏币等等
MoneyUtil.adaptiveMoney = function(money, special, precision)
    if g_AppManager:getAppVer() == g_AppManager.S_APP_VER.FB_VN then
        return MoneyUtil.formatMoney(money, special, precision)
    else
        return MoneyUtil.skipMoney(money)
    end
end

--拆分金币每3位用逗号隔开
MoneyUtil.skipMoney = function(curMoney)
    local formatted = tostring(tonumber(curMoney) or 0)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- 格式化游戏币
-- @param money 格式化目标
-- @special 特殊格式，如格式化后单位不是{"K", "M", "B", "T"}请传入对应的单位
-- @precision 保留小数位数
MoneyUtil.formatMoney = function(money, special, precision)
    if money == nil then
        return "";
    end
    precision = precision or 1
    local unitMap = {"K", "M", "B", "T"} or special
    local moneyStr = string.format("%.0f", money)
    local length = string.len(moneyStr)
    local num, unit
    if length > 12 then
        num = 12
        unit = unitMap[4]
    elseif length > 9  then
        num = 9
        unit = unitMap[3]
    elseif length > 6  then
        num = 6
        unit = unitMap[2]
    elseif length > 3 then
        num = 3
        unit = unitMap[1]
    else
        return moneyStr
    end
    
    local str1 = string.sub(moneyStr, 1, length - num)
    local str2 = string.sub(moneyStr, length - num + 1, length - num + precision)
    
    while string.charAt(str2, #str2) == "0" do
        str2 = string.sub(str2, 1, #str2 - 1)
    end
    if #str2 >= 1 then
        str2 = "." .. str2
    end
    
    return MoneyUtil.skipMoney(str1) .. str2 .. unit
end


-- 请使用MoneyUtil.formatMoney
-- 格式化游戏币，中文地区, 
MoneyUtil.formatChineseMoney = function(money,formatStr)
    local s = 0;
    if not money then
        return s;
    end

    if money < 10000 then
        s = MoneyUtil.skipMoney(money);

        return s;
    end


    local moneyStr = string.format("%.0f", money)
    local length = string.len(moneyStr)
    local num, unit, base

    if length > 8  then
        num = 8
        unit = GameString.get("str_unit_yi")
        base = 100000000
    elseif length > 4  then
        num = 4
        unit = GameString.get("str_unit_wan")
        base = 10000
    else
        return MoneyUtil.skipMoney(money);
    end

    local str1 = string.sub(moneyStr, 1, length - num)

    local number2 = (tonumber(string.sub(moneyStr,length - num + 1))/base)
    local str2 = string.sub(string.format(formatStr, number2), 2)

    for k = string.len(str2), 1, -1 do
        if (string.sub(str2,-1) == "0") then
            str2 = string.sub(str2,1, (string.len(str2) - 1))
        end
    end

    if str2 == "." then
        str2 = ""
    end

    return MoneyUtil.skipMoney(str1) .. str2 .. unit

end

-- 请使用MoneyUtil.formatMoney
-- 格式化筹码为规定的string形式，海外地区
MoneyUtil.formatOverseaMoney = function(money, formatStr)
    if money == nil then
        return "";
    end

    local moneyStr = string.format("%.0f", money)
    local length = string.len(moneyStr)
    local num, unit, base

    if length > 9  then
        num = 9
        unit = "B"
        base = 1000000000
    elseif length > 6  then
        num = 6
        unit = "M"
        base = 1000000
    elseif length > 3 then
        num = 3
        unit = "K"
        base = 1000
    else
        return moneyStr
    end

    local str1 = string.sub(moneyStr, 1, length - num)

    local number2 = (tonumber(string.sub(moneyStr,length - num + 1))/base)
    local str2 = string.sub(string.format(formatStr, number2), 2)

    for k = string.len(str2), 1, -1 do
        if (string.sub(str2,-1) == "0") then
            str2 = string.sub(str2,1, (string.len(str2) - 1))
        end
    end

    if str2 == "." then
        str2 = ""
    end

    return MoneyUtil.skipMoney(str1) .. str2 .. unit
end

-- 未经过格式话money
-- 金币数组转换为特定格式map,如1234,转换为432"A"1,其中"A"为逗号.
-- 函数这样写,可以通过配置ctags实现跳转.
MoneyUtil.moneyMap = function(money)
    local ret = {}
    money = tonumber(money)
    local cnt = 0
    while money ~= 0 do
        local t = money % 10
        money = math.floor(money / 10)
        cnt = cnt + 1
        ret[#ret + 1] = t 
        if cnt % 3 == 0 then
            ret[#ret + 1] = "A" -- 插入逗号
        end
    end
    -- 123456这样位数是3倍数的数字,转换后为643"A"321"A",最后一个"A"不需要,删除之.
    if ret[#ret] == "A" then
        ret[#ret] = nil
    end
    return ret
end

-- @param money 经过格式化后的money
-- reurn 金币数组转换为特定格式map,10表示“，”，12表示"K",13表示"M",14表示"B",15表示"万",16表示"亿"，11表示"."
MoneyUtil.moneyToArray = function(money)
    local wan = GameString.get("str_unit_wan");
    local yi = GameString.get("str_unit_yi");
    local numMap = {
        ["0"]  = 0;
        ["1"]  = 1;
        ["2"]  = 2;
        ["3"]  = 3;
        ["4"]  = 4;
        ["5"]  = 5;
        ["6"]  = 6;
        ["7"]  = 7;
        ["8"]  = 8;
        ["9"]  = 9;
        [","]  = 10;
        ["."]  = 11;
        ["K"]  = 12;
        ["B"]  = 13;
        ["M"]  = 14;
        [wan] = 15;
        [yi] = 16; 
    };

    local ret = {}
    local map = string.toArray(money);
    for k,v in ipairs(map) do
        local num = numMap[v];
        if not num then
            return {"0"};
        end
        ret[k] = num;
    end
    return ret
end


return MoneyUtil