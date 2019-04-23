
---简单数据存储，不建议存大数据, 仿造BYKit 的 Dict， 但支持自定义路径存储
--版本更新记录
--@module UpdateDict
--@author Loyalwind
--Date   2018/8/13

local UpdateHelper  = require("data.UpdateHelper")

local getDictFilePath = function(dictName, path)
    if not UpdateHelper.existDir(path) then
        UpdateHelper.mkdir(path)
    end
    if not string.find(path, "/", -1, -2) then -- 如果末尾已经没有'/'了,需要再增加 '/'
        path = path .. "/"
    end
    return path .. dictName;  
end

local UpdateDict = class("UpdateDict")

--@desc 构造函数
--@dictName string 存储的文件名
--@filePath string 存储的文件路径
function UpdateDict:ctor(dictName, filePath)
    self.properties = {};
    self.dictName = dictName;
    self.filePath = filePath;
    local mete = getmetatable(self);
    mete.__newindex = function(t, k, v)
        if type(v) == "function" then
            error("不支持保存函数");
        end
        self.properties[k] = v;
    end
    
    mete.__index = function(t, k, v)
        if self.properties[k] then
            return self.properties[k]
        elseif UpdateDict[k] then
            return UpdateDict[k]
        end
    end
end

--[[
@desc:从硬盘加载数据
@usage
local UpdateDict = import("framework/update").UpdateDict;
local dictData = UpdateDict.new("testDict","/store/abc/xx");
dictData:load();--加载数据
dictData.money = 100; --修改数据
dictData:save();
]]
function UpdateDict:load()
    local dictFile = getDictFilePath(self.dictName, self.filePath);
    
    local f = io.open(dictFile, "r")
    if not f then  return end

    local str = f:read();
    f:close();
    str = g_Base64.decode(str)
    self.properties = g_JsonUtil.decode(str)
end

-- @desc: 存储数据到硬盘
function UpdateDict:save()
    local str = g_JsonUtil.encode(self.properties);
    str = g_Base64.encode(str)
    local dictFile = getDictFilePath(self.dictName, self.filePath);
    local f = io.open(dictFile, "w+")
    if f then
        f:write(str);
        f:flush();
        f:close();
    end
end

function UpdateDict:clear()
    self.properties = {};
end

return UpdateDict