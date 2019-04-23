---文件路径管理
--@module UpdateFileTool
--@author Loyalwind
--Date   2018/8/8

local UpdateHelper      = require("data.UpdateHelper")

local WritePath = UpdateHelper.getWritablePath()
local UpdateDir  = WritePath .. "assets/" -- 热更新存放目录
local RecordDir  = WritePath .. "recordDir/" -- 版本记录保存目录
local ZipSaveDir = WritePath .. "zipSaveDir/" -- zip文件下载目录

local DeleteDir = {
    "src",
    "res",
    "src64",
}

local UpdateRecord = require("data.UpdateRecord")

local UpdateFileTool = {}

---------------------------------   lua更新包解压zip文件到update目录相关       ---------------------------------
---@desc 热更新update目录路径
---@return string
function UpdateFileTool.getUpdateDir()
    -- if not UpdateHelper.existDir(UpdateDir) then 
    --     UpdateHelper.mkdir(UpdateDir)
    -- end
    -- return UpdateDir
    return WritePath
end

--- 是否存在旧版本的热更新
---@return boolean
function UpdateFileTool.isExistOldUpdate()
    if not UpdateHelper.existDir(UpdateDir) then
        return false 
    end

    for _, v in ipairs(DeleteDir) do
        local dir = UpdateDir..v
        if UpdateHelper.existDir(dir) then
            return true
        end
    end

    return false
end

--- 删除update目录下的旧版本的热更新资源
function UpdateFileTool.removeOldUpdate()
    if not UpdateFileTool.isExistOldUpdate() then
        return 
    end

    -- 删除update目录下的src, res 文件夹
    for k,v in ipairs(DeleteDir) do
        local dir = UpdateDir..v.."/"
        UpdateHelper.removedir(dir)
    end
    -- local files = UpdateHelper.lsfiles(UpdateDir)
    -- for _, v in ipairs(files) do
    --     os.remove(v)
    -- end
end

---------------------------------   lua更新包zip文件目录相关       ---------------------------------
--- 获得lua热更新zip包下载到本地的目录
---@return string
function UpdateFileTool.getZipSaveDir()
    if not UpdateHelper.existDir(ZipSaveDir) then
        UpdateHelper.mkdir(ZipSaveDir)
    end
    return ZipSaveDir
end

--- 删除下载的热更新zip文件
function UpdateFileTool.removeDownloadedZips()
    if not UpdateHelper.existDir(ZipSaveDir) then return end

    local zipFiles = UpdateHelper.lsfiles(ZipSaveDir)
    --- 清除记录，删除文件
    for i, v in ipairs(zipFiles) do
        UpdateRecord.getInstance():removeRecord(UpdateHelper.md5File(v))
        os.remove(v)
    end
end

---------------------------------    版本记录保存目录相关       ---------------------------------
--- 获得差分包热更新包下载到本地的目录
---@return string
function UpdateFileTool.getRecordSaveDir()
    if not UpdateHelper.existDir(RecordDir) then
        UpdateHelper.mkdir(RecordDir)
    end
    return RecordDir
end

---删除所有下载的资源（zip,patch,apk文件）
function UpdateFileTool.removeAllDownloadedRes()
    UpdateFileTool.removeDownloadedZips()
    --TODO删除文件的时候，顺带去删除对应的记录
end

return UpdateFileTool