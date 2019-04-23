--[Comment]
-- 这类提供AS3对应Vector, Array的对应方法
-- Vector和Array在ActionScript3中都是数组，不同的是Vector的数组元素是相同类型，Array的数组元素可以是不同类型，

local TableLib = require("TableLib")

local ArrayKit = {};


--[Comment]
--在数组最后增加一个或多个元素
--返回值为新增元素后数组的长度
ArrayKit.push = function(arr, ...)
   local ret = 0;
   local arg = {...}
   if arr ~= nil then
       for i,v in ipairs(arg) do
            table.insert(arr, v);
       end
       ret = #arr;
   end
   return ret;
end

--[Comment]
--在数组前面增加一个或多个元素
--返回值为新增元素后数组的长度
ArrayKit.unshift = function(arr, ...)
    local ret = 0;
    if arr ~= nil then
        local arg = {...}
        local tmp = arr;
        arr = {};
        for i, v in ipairs(arg) do
            table.insert(arr, v);
        end
        for i = 1, #tmp do
            table.insert(arr, tmp[i]);
        end

        for i = 1, #arr do
            tmp[i] = arr[i];
        end

        ret = #tmp;
    end
    return ret;
end


--[Comment]
--删除数组最后一个元素,
--返回值为被删除的元素
ArrayKit.pop = function(arr)
    local ret = nil;
    if arr ~= nil then
        ret = arr[#arr];
        arr[#arr] = nil;
    end
    return ret;
end


--[Comment]
--删除数组前面一个元素,
--返回值为被删除的元素
ArrayKit.shift = function(arr)
    local ret = nil;
    if arr ~= nil then
        ret = arr[1];
        for i = 2, #arr + 1 do
            arr[i - 1] = arr[i];
        end
    end
    return ret;
end


--[Comment]
-- splice 方法可以删除数组当中的一个或多个连续的元素。
-- 一般有4个用途。
-- (1)从数组某位置开始，删除指定数目的元素，并插入一些新元素。
-- ArrayKit.splice(数组，删除点的索引，要删除的元素数目，新元素1，新元素2，...，新元素n);
--
-- (2)删除数组中某位置之后几个元素。
-- ArrayKit.splice(数组，删除点的索引，要删除的元素数目);
--
-- (3)删除数组中某位置之后所有元素。
-- ArrayKit.splice(数组，删除点的索引)。
--
-- (4)在数组中某位置之后，插入新元素。
-- ArrayKit.splice(删除点索引，0, 新元素1, 新元素2, ...，新元素n);
ArrayKit.splice = function(arr, index, num, ...)
    local ret = {};
    if arr ~= nil then
        local arg = {...}
        if index < 0 then
            index = #arr + 1 + index;
        end
        num = num or #arr;
        local tmp = arr;
        for i = index, #arr do
            if #ret < num then
                table.insert(ret, arr[i]);
            end
        end

        arr = {};

        for i = 1, #tmp do
            if i < index then
                table.insert(arr, tmp[i]);
            elseif i == index then
                if num == 0 then
                    table.insert(arr, tmp[i]);
                end
                
                for i, v in ipairs(arg) do
                    table.insert(arr, v);
                end
            elseif i >= (index + num) then
                table.insert(arr, tmp[i]);
            end
        end

        local len = math.max(#tmp, #arr);
        for i = 1, len do
            tmp[i] = arr[i];
        end
    end
    return ret;
end

--[Comment]
-- slice 可以获取数组中一段连续的元素，而不改变原有数组的内容。
-- index 截取范围起点索引, 可为负值
-- lastIndex 截取范围结束点索引， 可为负值
-- 负值就是倒数的索引，-1就是最后一个位置的索引，-2就是倒数第二个位置的索引，以此类推。
-- 返回值是截取元素组成的新数组，而且不改变原有数组的内容。
ArrayKit.slice = function(arr, index, lastIndex)
    local ret = {};
    if arr ~= nil then
        index = index or 1;
        lastIndex = lastIndex or #arr;
        if index < 0 then
            index = #arr + 1 + index;
        end

        if lastIndex < 0 then
            lastIndex = #arr + 1 + lastIndex;
        end

        if index < lastIndex then
            for i = index, #arr do
                if i < lastIndex then
                    table.insert(ret, arr[i]);
                end
            end
        end
    end
    return ret;
end

--[Comment]
--数组合并，不修改原有数组，直接返回一个新的数组
ArrayKit.concat = function(...)
    local ret = {};
    local arg = {...}
    for i, v in ipairs(arg) do
        for n = 1, #v do
            table.insert(ret, v[n]);
        end
    end
    return ret;
end

--[Comment]
--从数组中删除指定项
ArrayKit.delete = function(arr, item)
    if arr ~= nil then
        local index = ArrayKit.indexOf(arr, item);
        if index ~= -1 then
            ArrayKit.splice(arr, index, 1);
        end
    end
end

--[Comment]
--排序
ArrayKit.sort = function(arr, obj, sortFunc)
    return TableLib.quickSort(arr, obj, sortFunc);
end

--[Comment]
--反转
ArrayKit.reverse = function(arr)
    if arr ~= nil then
        local i = 1;
        local j = #arr;
        while i < j do
            arr[i], arr[j] = arr[j], arr[i];
            i = i + 1;
            j = j - 1;
        end
    end
    return arr;
end

--[Comment]
--查找指定元素在Array的位置,找到返回其位置，如果找不到返回-1。
ArrayKit.indexOf = function(arr, item, index)
    local ret = -1;
    if arr ~= nil then
        index = index or 1;
        if index < 0 then
            index = #arr + 1 + index;
        end

        for i = index, #arr do
            if item == arr[i] then
                ret = i;
                break;
            end
        end
    end
    return ret;
end

--[Comment]
--从数组后面查找指定元素在Array的位置,找到返回其位置，如果找不到返回-1。
ArrayKit.lastIndexOf = function(arr, item, index)
    local ret = -1;
    if arr ~= nil then
        index = index or #arr;
        if index < 0 then
            index = #arr + 1 + index;
        end

        for i = index, 1, -1 do
            if item == arr[i] then
                ret = i;
                break;
            end
        end
    end
    return ret;
end


return ArrayKit