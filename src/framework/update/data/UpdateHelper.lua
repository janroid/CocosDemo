--[[--ldoc 函数扩展
@module 
@author:LoyalwindPeng
 date: 2019-01-22
]]

local UpdateHelper = class("UpdateHelper")
-- @desc: 获得可写的路径
-- @return: string
function UpdateHelper.getWritablePath()
    return cc.FileUtils:getInstance():getWritablePath()
end

-- @desc: 是否是绝对路径
--@path: string 路径
--@return: bool
function UpdateHelper.isAbsolutePath(path)
    return cc.FileUtils:getInstance():isAbsolutePath(path)
end

-- @desc: 是否存在文件
--@path: string 绝对路径 /avc/sf/abc.xx
--@return: bool
function UpdateHelper.existFile(path)
    -- if type(dir) ~= "string" or dir == "" then
    --     return false
    -- end
    -- if not UpdateHelper.isAbsolutePath(dir) then
    --     return false
    -- end
    -- return cc.FileUtils:getInstance():isFileExist(path)
    return io.exists(path)
end

--@desc: 是否存在目录
--@dir: string  绝对路径 /xx1/xx2/
--@return: bool
function UpdateHelper.existDir(dir)
    if type(dir) ~= "string" or dir == "" then
        return false
    end
    if not UpdateHelper.isAbsolutePath(dir) then
        return false
    end
    return cc.FileUtils:getInstance():isDirectoryExist(dir)
end

--@desc: 创建目录（递归）
--@dir: string  绝对路径 /xx1/xx2/
--@return: bool 是否创建成功
function UpdateHelper.mkdir(dir)
    if type(dir) ~= "string" or dir == "" then
        return false
    end
    if not UpdateHelper.isAbsolutePath(dir) then
        return false
    end
    return cc.FileUtils:getInstance():createDirectory(dir)
end

-- @desc: 列出目录下的所有文件和文件夹
--@dir: string 绝对路径 /xx1/xx2/
--@return: table
function UpdateHelper.lsfiles(dir)
    if type(dir) ~= "string" or dir == "" then
        return nil
    end
    -- if not UpdateHelper.existDir(dir) then
    --     return nil
    -- end
    local paths = g_TableLib.checktable(cc.FileUtils:getInstance():listFiles(dir))
    if device.platform == 'win32' and #paths > 2 then
       table.remove(paths, 1, 2)
    end
    return paths
end

-- @desc 删除目录文件夹
-- @dir string 绝对路径
-- @return bool true if the directory have been removed successfully, otherwise it will return false.
function UpdateHelper.removedir(dir)
    if type(dir) ~= "string" or dir == "" then
        return false
    end
    return cc.FileUtils:getInstance():removeDirectory(dir)
end

function UpdateHelper.unZip(srcPath, desDir, password)
    return projectx.lcc_unCompress(srcPath, desDir or "", password or "")
end

function UpdateHelper.appVersion()
    return g_SystemInfo:getVersionName()
end

function UpdateHelper.luaVersion(regionalID)
    local nativeLuaVersion = tonumber(g_SystemInfo:getLuaVersion()) or 1
    local UpdateRecord = require("data.UpdateRecord")

    local localLuaVersion = tonumber(UpdateRecord.getInstance():getNewestLuaVersion(regionalID)) or 0
    return nativeLuaVersion > localLuaVersion and nativeLuaVersion or localLuaVersion
end

-- string extension 
--- 比较版本大小
---@return number -1：v1 < v2; 0:v1 == v2, 1:v1 > v2
function UpdateHelper.compareVersion(v1, v2)
    if v1 == nil or v1 == "" then
        -- error("v1不能为空串")
        v1 = "0.0.0"
    end

    if v2 == nil or v2 == "" then
        -- error("v2不能为空串")
        v2 = "0.0.0"
    end

    -- 去除包含的字母，比如'v'
    v1 = string.gsub(v1, "%a+", "")
    v2 = string.gsub(v2, "%a+", "")

    local arr1 = string.split(v1 or "0", ".")
    local arr2 = string.split(v2 or "0", ".")

    local len1 = #arr1
    local len2 = #arr2
    local longestLen = len1
    if (len1 < len2) then
        for i = len1 + 1, len2 do
            arr1[i] = 0
        end
        longestLen = len2
    elseif (len1 > len2) then
        for i = len2 + 1, len1 do
            arr2[i] = 0
        end
        longestLen = len1
    end

    for i = 1, longestLen do
        if tonumber(arr1[i]) > tonumber(arr2[i]) then
            return 1
        elseif tonumber(arr1[i]) < tonumber(arr2[i]) then
            return -1
        end
    end
    return 0
end

---格式化文件路径，把所有'\'都转成 '/'，etc : a\\b/c\d//e --> a/b/c/d/e
function UpdateHelper.formatFilePath(filePath)
    if type(filePath) ~= "string" or filePath == "" then
        return filePath
    end

    filePath = string.replaceAll(filePath,[[\+]], "/")
    return string.replaceAll(filePath, [[/+]], "/")
end

--@desc: 获得文件路径的最后一部分
--@filePath: string
--@return: string  src/dec/ok.lua -> ok.lua、 src/dec/ok -> ok
function UpdateHelper.lastPathComponent(filePath)
    if type(filePath) ~= "string" or filePath == "" then
        return ""
    end

    local path = string.gsub(filePath, "\\", "/")
    if path[#path] == "/" then
        path = string.sub(path, 0, #path - 1)
    end
    local ret = string.split(path, "/")
    return ret[#ret]
end

--@desc: 获取路径的信息
--@path: string 
--@return:the table has fields: dirname, filename, basename, extname
function UpdateHelper.pathInfo(path)
    return io.pathinfo(path)
end

-- @desc: 计算字符串的md5 值
--@str: string 
--@return:string 
function UpdateHelper.md5String(str)
    return projectx.lcc_getMD5Hash(str)
end

-- @desc: 计算文件的md5 值
--@file: string 绝对路径
--@return:string 
function UpdateHelper.md5File(file)
    return projectx.lcc_getMD5HashFromFile(file)
end

-- 跳转到appstore
--@return:bool 
function UpdateHelper.gotoAppStore()
    return g_AppManager:gotoAppStore()
end

function UpdateHelper.restart()
    if fix_restart_lua then
        fix_restart_lua()
    end
end

return UpdateHelper