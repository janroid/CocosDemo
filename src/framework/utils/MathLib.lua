--[[
    数学库
]]
local BitUtil = import(".Bit");
local MathLib = {};

---根据系统时间初始化随机数种子，让后续的 math.random() 返回更随机的值
function MathLib.newrandomseed()
    local seed = tostring(os.time()):reverse():sub(1, 7)
    math.randomseed(seed)
    math.random()
    math.random()
    math.random()
    math.random()
    return seed;
end

---
---对数值进行四舍五入，如果不是数值则返回 0
-- @param value 输入值
-- @return number
function MathLib.round(value)
    value = MathLib.checknumber(value)
    return math.floor(value + 0.5)
end

---
-- 角度转弧度
-- @param angle 角度值
-- @return number 弧度值
function MathLib.angle2radian(angle)
    return angle*math.pi/180
end

---
-- 弧度转角度
-- @param angle 弧度
-- @return number 角度
function MathLib.radian2angle(radian)
    return radian/math.pi*180
end

--[[--
取整
]]
function MathLib.checkint(value)
    return MathLib.round(MathLib.checknumber(value))
end

--[[--
检查是否是数字
]]
function MathLib.checknumber(value, base)
    return tonumber(value, base) or 0
end

--[[
取数字整数部分
]]
function MathLib.getIntPart(x)
    if x <= 0 then
        return math.ceil(x);
    end

    if math.ceil(x) == x then
        x = math.ceil(x);
    else
        x = math.ceil(x) - 1;
    end
    return x;
end

--[[
    取余数
]]
function MathLib.mod( a, b )
    a = a or 0;
    b = b or 1;
    return a - math.floor(a/b)*b;
end


--[[
    获取一个2进制数第几位的值 例如
    8 其二进制为 1000
    MathLib.getBinIndexValue(8,4) == 1;

]]
function MathLib.getBinIndexValue(num, index)
    local a = BitUtil.blshift(1,index - 1);
    if BitUtil.band(a,num) == a then
        return 1
    else
        return 0
    end
end

--[Comment]
--求n的阶乘
MathLib.factorial = function(n)
    if(n <= 0) then return 1; end
    if(n == 1) then return 1;
    elseif(n == 2) then return 2;
    elseif(n == 3) then return 6;
    elseif(n == 4) then return 24;
    elseif(n == 5) then return 120;
    elseif(n == 6) then return 720;
    else
        return (n-6) * MathLib.factorial(6);
    end
    return r;
end

--[Comment]
--求组合数c(m, n)
MathLib.combine = function(m, n)
    if(n > m) then return 0; end
    return MathLib.factorial(m) / (MathLib.factorial(n)*MathLib.factorial(m-n));
end

--[Comment]
--计算贝塞尔曲线的一般形式
MathLib.bezier = function(allPoints, t)
    local n = #allPoints - 1;
    local ret = {x=0,y=0};
    for i=0,n do
        local C = MathLib.combine(n, i);
        local A = math.pow(1-t, n-i) * math.pow(t, i);
        ret.x = ret.x + allPoints[i+1].x * C * A;
        ret.y = ret.y + allPoints[i+1].y * C * A;
    end
    return ret;
end

return MathLib;
