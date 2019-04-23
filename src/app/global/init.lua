--[[--ldoc desc
    author:{author}
    time:2018-12-3
    Description: 业务定义全局变量的区域，具体代码请定义到GlobalMap.lua或FunctionsEx.lua中
]]


---------------------------------------------------------------------------------------------

local Global = {}

local __require = clone(require);

local function requireCocos(path)
    return __require(path)
end
cc.exports.require1 = requireCocos;

local function StringStartWith(str, chars)
    return chars == '' or string.sub(str, 1, string.len(chars)) == chars
end

local function StringEndsWith(str, chars)
    return chars == '' or string.sub(str, -string.len(chars)) == chars
end


local pakMap = {};

-- 获取相对包的路径
local function getRelativelyPath(str)
    -- 去掉最后一个"/"或"\"后面的内容
    local function dirname(str)
        if str:match(".-/.-") then
            local name = string.gsub(str, "(.*/)(.+)", "%1")
            return name
        elseif str:match(".-\\.-") then
            local name = string.gsub(str, "(.*\\)(.+)", "%1")
            return name
        else
            return ''
        end
    end
    -- "/"和"\"转换为"."
    local function getRelPath(str)
        if str:match("/") then
            str = string.gsub(str,"/","%.")
        end
        if str:match("\\") then
            str = string.gsub(str,"\\","%.")
        end
        -- 去掉首尾所有的"."
        str = string.gsub(str, "^%.*(.-)%.*$", "%1");
        return str;
    end
    local path = dirname(str);
    return getRelPath(path);
end

-- 获取相对路径
local function getCurPath(moduleName)
    -- if string.byte(moduleName, 1) ~= 46 then
    --     return moduleName;
    -- end
    local path = debug.getinfo(3,'S').source;
    if path == "=[C]" then -- 使用pcall or xpcall执行函数时，需加一层
        path = debug.getinfo(4,'S').source
    end

    path = getRelativelyPath(path);
    local file = path;
    for k,v in pairs(pakMap) do
        if StringStartWith(path,v)  then
            local arr = string.split(v,".")
            local arr1 = string.split(path,".");
            local result = true;
            for i,j in ipairs(arr) do
                if j ~= arr1[i] then
                    result = false;
                    break;
                end
            end
            if result then
                file = k;
                break;
            end
        end
    end
    -- 防止 .. 的异常路径
    path = file .. "." .. moduleName;
    path = string.gsub(path, "(%.%.+)", "%.");
    return path;
end

-- 自定义require，修改为支持加载相对路径
local _require = require;
function require(moduleName)
    local path = moduleName;
    if StringEndsWith(moduleName,".init") then

    else
        path = getCurPath(path);
    end
    
    return _require(path)
end

-- 自定义import
local _import = import;
function import(path)
    if string.byte(path, 1) ~= 46 then
        pakMap[path] = path;
        if not StringEndsWith(path,".init") then
            path = path .. ".init"
        end
    end
    return _import(path);
end

local initData = require("GlobalMap");
-- 启动时调用，初始化global
function Global:initData()
    initData();
end

return Global;