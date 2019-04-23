---lua 热更新
--@module UpdateLuaOperator
--@author Loyalwind
--Date   2018/8/10

local UpdateRecord       = require("data.UpdateRecord")
local UpdateFileTool     = require("data.UpdateFileTool")
local UpdateEnum         = require("data.UpdateEnum")
local UpdateHelper       = require("data.UpdateHelper")
local UpdateDownloadInfo = require("data.UpdateDownloadInfo")
local KeyFormat = "%s-%s"
local UpdateLuaOperator = class("UpdateLuaOperator")

function UpdateLuaOperator:ctor(delegate)
    self._delegate = delegate
    self._downloadInfos = {}
end

function UpdateLuaOperator:dtor()
    self._downloader = nil
    self._delegate = nil
end

function UpdateLuaOperator:_getDownloader()
    if not self._downloader then
        -- local downloaderHints = {
        --     countofMaxProcessingTasks = 6;
        --     timeoutInSeconds = 120;
        --     tempFileNameSuffix = ".zip";
        -- }
        -- self._downloader = cc.Downloader.new(downloaderHints)
        self._downloader = cc.Downloader.new()
        self._downloader:setOnFileTaskSuccess(handler(self, self.onTaskSuccess))
        self._downloader:setOnTaskProgress(handler(self, self.onProgress))
        self._downloader:setOnTaskError(handler(self, self.onTaskError))
    end
    return self._downloader
end

--- 开始更新
function UpdateLuaOperator:startUpdate(updateInfo)
    -- updateInfo = g_TableLib.checktable(updateInfo)
    if not iskindof(updateInfo, "UpdateInfo") then
        -- 通知代理更新失败
        self._delegate:onUpdateError(self, nil, UpdateEnum.ErrorCode.InvalidParams, -1024, "updateInfo是一个空表")
        return 
    end

    self._updateInfo = updateInfo
    self:_reStartUpdate(1)
end

function UpdateLuaOperator:startDownloadTask(url, desPath, identifier)
    return self:_getDownloader():createDownloadFileTask(url, desPath, identifier)
end

function UpdateLuaOperator:onProgress(task, bytesReceived, totalBytesReceived, totalBytesExpected)
    if type(self._delegate.onUpdateProgress) ~= "function" then return end
    local downloadInfo = self:_getDownloadInfoForTask(task)
    -- 通知代理刷新进度
    self._delegate:onUpdateProgress(self, downloadInfo, bytesReceived, totalBytesReceived, totalBytesExpected)
end

---下载完成的回调
function UpdateLuaOperator:onTaskSuccess(task)
    -- 传递给外界的参数
    local downloadInfo = self:_getDownloadInfoForTask(task)

    local isSafe = self:_checkSafe(downloadInfo.filePath, downloadInfo.fileCfg.hash)

    if not isSafe then -- 文件有问题
        --删除下载的zip包
        os.remove(downloadInfo.filePath)
        self:_handleUpdateError(downloadInfo, UpdateEnum.ErrorCode.FileHashInvalid, nil, "文件校验失败")
        return 
    end 
    
    --解压文件到update目录下
    local toPath = UpdateFileTool.getUpdateDir()
    local success = pcall(UpdateHelper.unZip, downloadInfo.filePath, toPath)
    --删除下载的zip包
    os.remove(downloadInfo.filePath)

    if success then
        Log.i('解压成功:', downloadInfo.filePath, toPath)
        -- 版本记录
        UpdateRecord.getInstance():saveNewestLuaVersion(downloadInfo.newestLuaVersion, downloadInfo.regionalID)
        -- 通知代理完成
        self._delegate:onUpdateSuccess(self, downloadInfo)
    else
        Log.i('解压失败:', downloadInfo.filePath)
        self:_handleUpdateError(downloadInfo, UpdateEnum.ErrorCode.FileHashInvalid, nil, "文件解压失败")
    end
end

function UpdateLuaOperator:onTaskError(task, errorCode, errorCodeInternal, errorStr)
    local downloadInfo = self:_getDownloadInfoForTask(task)
    --删除下载的zip包
    os.remove(downloadInfo.filePath)
    os.remove(downloadInfo.filePath..".tmp")
    -- 处理下载出错
    self:_handleUpdateError(downloadInfo, errorCode, errorCodeInternal, errorStr)
end

--- 重新下载更新
function UpdateLuaOperator:_reStartUpdate(times)
    if #self._updateInfo.fileConfigs < times then
        Log.e("超过下载次数了。。。",times)
        self._delegate:onUpdateError(self, nil, UpdateEnum.DownloadNumberOut, -1024, "下载超过次数了")
        return 
    end

    local fileCfg = self._updateInfo.fileConfigs[times]
    local filePath = string.format("%s%s.zip", UpdateFileTool.getZipSaveDir(), UpdateHelper.md5String(fileCfg.url))
    local downloadInfo = UpdateDownloadInfo.new({
        type          = self._updateInfo.type,
        mode          = self._updateInfo.mode,
        appVersion    = self._updateInfo.appVersion,
        newestLuaVersion = self._updateInfo.newestLuaVersion,
        filePath      = filePath,
        fileCfg       = fileCfg,
        downloadTimes = times,
    })

    -- 开始下载更新资源
    self:startDownloadTask(fileCfg.url, filePath, tostring(times))
    local key = string.format(KeyFormat, UpdateHelper.md5String(fileCfg.url), tostring(times))
    self._downloadInfos[key] = downloadInfo
end

function UpdateLuaOperator:_handleUpdateError(downloadInfo, errorCode, errorCodeInternal, errorStr)
    -- 通知代理出错
    if #self._updateInfo.fileConfigs > downloadInfo.downloadTimes then -- 可供备用的下载的总次数大于当前下载了次数，则再次下载
        -- 重新下一次下载
        self:_reStartUpdate(downloadInfo.downloadTimes + 1)
    else 
        self._delegate:onUpdateError(self, downloadInfo, errorCode, errorCodeInternal, errorStr)
    end 
end

-- 文件校验
---@param file string 文件路径
---@param hash string 哈希值，MD5
function UpdateLuaOperator:_checkSafe(file, hash)
    if file == nil or hash == nil then return false end

    local md5Value = UpdateHelper.md5File(file)
    Log.i("file md5值=" .. md5Value .. ";hash=" .. hash)
    -- win32模拟器下载的md5会发生变化，且解压也有问题
    return g_SystemInfo:isWindows() or md5Value == hash
end

function UpdateLuaOperator:_getDownloadInfoForTask(task)
    local key = string.format(KeyFormat, UpdateHelper.md5String(task.requestURL), tostring(task.identifier))
    return self._downloadInfos[key]
end

return UpdateLuaOperator