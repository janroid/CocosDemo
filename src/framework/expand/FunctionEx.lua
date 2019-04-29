--[[
    author:{JanRoid}
    time:2018-12-04
    Description: 自定义全局方法
]] 

local funs = {}

--[[
    @desc: 添加get,set方法
    author:{JanRoid}
    time:2018-12-04 11:21:47
    --@object:  类 or 表
	--@varName: 属性名称（自动生成getVerName,setVerName方法）
	--@defaultValue: 默认值
	--@createGetter: 创建get方法，默认创建
	--@createSetter: 创建set方法，默认创建
    @return:
]]
function funs.addProperty(object, varName, defaultValue, createGetter, createSetter)
    if not object or not varName then
        Log.e("addProperty --> object or varName is nil")

        return;
    end

    createGetter = (createGetter == nil) or createGetter
    createSetter = (createSetter == nil) or createSetter
    local tempName = string.gsub(varName,"m_","")
    local propName = string.upper(string.sub(tempName, 1, 1)) .. (#tempName > 1 and string.sub(tempName, 2, -1) or "")
    object[varName] = defaultValue
     
    if createGetter then
        object[string.format("get%s", propName)] = function(self)
            return object[varName]
        end
    end
    
    if createSetter then
        object[string.format("set%s", propName)] = function(p1,p2)
            object[varName] = p2 or (p1 ~= object  and p1 or nil)
        end
    end
end


function funs.getNumFromTable(tb,key,default)
    if nil == tb or not key or type(tb) ~= "table" then
        return default 
    end
    local ret = default
    if tb[key] ~= nil then
        ret = tonumber(tb[key]);
        if ret == nil then
            ret = default;
        end
    end
    return ret;
end

function funs.getStrFromTable(tb,key,default)
    if not default then
        default = "";
    end

    if nil == tb or not key or type(tb) ~= "table" then
        return default 
    end;

    local ret = default;
    if tb[key] ~= nil then
        ret = tb[key];
        if ret == nil or type(ret) == "table" or string.len(ret) == 0 then
            ret = default;
        end
    end
    return tostring(ret);
end

function funs.getBooleanFromTable(tb,key,default)
    if not default then
        default = false;
    else
        default = true;
    end

    if nil == tb or not key or type(tb) ~= "table" then
        return default 
    end;
    local ret = default;
    if tb[key] ~= nil then
        ret = tb[key];
        if ret == nil then
            ret = default;
        else
            ret = tostring(ret);
        end
    end

    if ret == "true" then
        ret = true;
    else
        ret = false;
    end

    return ret;
end

function funs.getTabFromTable(tb,key,default)
    default = default or {};
    if type(default) ~= "table" then
        default = {};
    end

    if nil == tb or not key or type(tb) ~= "table" then
        return default 
    end;

    local ret = tb[key];

    if not ret or type(ret) ~= "table" then
        return default;
    end

    return tb[key];
end

function funs.switchFilePath(filePath)
    if(type(filePath) == "string") then
        if g_AppManager then
            filePath = "creator/lanRes/" .. "lanRes_".. g_AppManager:getAppPlatform() .. "/" .. filePath
        end
    end
    return filePath;
end

local cocosImport = import
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


--[[
    @desc: 使用相对路径require文件，目前只支持到上层路径
    author:{author}
    time:2019-04-29 12:09:45
    --@moduleName: 路径开头：1：(xxx) 表示相对当前路径，2：(.xxx)表示相对上层路径，
    @return: 
]]
function funs.import(moduleName)
    local path = debug.getinfo(2,'S').source;
    if path == "=[C]" then -- 使用pcall or xpcall执行函数时，需加一层
        path = debug.getinfo(3,'S').source
    end

    path = getRelativelyPath(path);

    if string.byte(moduleName, 1) == 46 then
        local n = string.find( path,"%.[^%.]*$")
        if n then
            path = string.sub( path, 1,n)
        end
    end

    -- 防止 .. 的异常路径
    path = path .. "." .. moduleName;
    path = string.gsub(path, "(%.%.+)", "%.");
    return require(path);
end


return funs