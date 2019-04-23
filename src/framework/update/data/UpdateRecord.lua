--版本更新记录
--@module UpdateRecord
--@author Loyalwind
--Date   2018/8/10

local LuaVersionDictName = "__NewestLuaVersionCodeDict__"
local AppVersionDictName = "__AppVersionCodeDict__"
local DownloadDictName   = "__FixFileDownloadDict__"

--- 生成地区唯一标识符key
local function createKeyForRegionalID(regionalID)
    return LuaVersionDictName .. regionalID
end

--- 获得记录保存的文件目录
local function getRecordSaveDir()
    local UpdateFileTool = require("data.UpdateFileTool")
    return UpdateFileTool.getRecordSaveDir()
end

local UpdateDict = require("data.UpdateDict")

local UpdateRecord = class("UpdateRecord")

---单例方法
function UpdateRecord.getInstance()
    if not UpdateRecord.s_instance then
        UpdateRecord.s_instance = UpdateRecord.new()
    end
    return UpdateRecord.s_instance
end

function UpdateRecord:ctor()
    self._recordSaveDir = getRecordSaveDir()
end

function UpdateRecord:dtor()

end

----------------------------------  热更新版本记录信息    --------------------------------
--- 获取热更新记录字典
function UpdateRecord:_getNewestLuaVersionDict()
    if not self._newestLuaVersionDict then
        self._newestLuaVersionDict = UpdateDict.new(LuaVersionDictName, self._recordSaveDir)
        self._newestLuaVersionDict:load()
    end
    return self._newestLuaVersionDict
end

--@desc: 保存热更新版本
--@version: string 版本号
--@regionalID: string 地区标识唯一符
function UpdateRecord:saveNewestLuaVersion(version, regionalID)
    if type(regionalID) ~= "string" or regionalID == "" then
        error("regionalID 必须为长度大于1的字符串")
    end
    local dict = self:_getNewestLuaVersionDict()
    dict[createKeyForRegionalID(regionalID)] = version
    dict:save()
end

--- 根据地区标识符获得当前版本号
---@regionalID string 地区标识唯一符
function UpdateRecord:getNewestLuaVersion(regionalID)
    if type(regionalID) ~= "string" or regionalID == "" then
        return nil
    end
    local dict = self:_getNewestLuaVersionDict()
    return dict[createKeyForRegionalID(regionalID)] or ""
end

----------------------------------  商店版本记录信息    --------------------------------
--- 获取存取应用版本号的字典
function UpdateRecord:_getAppVersionDict()
    if not self._appVersionDict then
        self._appVersionDict = UpdateDict.new(AppVersionDictName, self._recordSaveDir)
        self._appVersionDict:load()
    end
    return self._appVersionDict
end

--- 保存商店热更新版本
function UpdateRecord:saveAppVersion(version)
    if type(version) ~= "string" or version == "" then
        -- error("version 必须为长度大于1的字符串")
        return
    end

    local dict = self:_getAppVersionDict()
    dict["lastVersion"]    = dict["currentVersion"]
    dict["currentVersion"] = version
    dict:save()
end

--- 获得app应用当前版本
function UpdateRecord:getAppVersion()
    local dict = self:_getAppVersionDict()
    return dict["currentVersion"] or ""
end

----------------------------------  更新包下载记录信息    --------------------------------
--- 获取存取下载的字典
function UpdateRecord:_getUpdateDownloadDict()
    if not self._updateDownloadDict then
        self._updateDownloadDict = UpdateDict.new(DownloadDictName, self._recordSaveDir)
        self._updateDownloadDict:load()
    end
    return self._updateDownloadDict
end

--- 保存下载记录
function UpdateRecord:saveDownloadRecord(key,value)
    if type(key) ~= "string" or key == "" then
        -- error("key 必须为长度大于1的字符串")
        return
    end

    local dict = self:_getUpdateDownloadDict()
    dict[key] = value
    dict:save()
end

--- 移除记录
---@param key string
function UpdateRecord:removeRecord(key)
    local dict = self:_getUpdateDownloadDict()
    if dict[key] then
        dict[key] = nil
        dict:save()
    end
end

--- 获得下载记录
function UpdateRecord:getDownloadRecord(key)
    local dict = self:_getUpdateDownloadDict()
    return dict[key]
end

return UpdateRecord