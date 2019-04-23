---正在下载更新的模型信息
--@module UpdateDownloadInfo
--@author Loyalwind
--Date   2018/8/16

local UpdateDownloadInfo = class("UpdateDownloadInfo")

function UpdateDownloadInfo:ctor(info)
    self.filePath = info.filePath
    self.type     = info.type
    self.mode     = info.mode
    self.fileCfg  = info.fileCfg
    self.appVersion    = info.appVersion
    self.newestLuaVersion = info.newestLuaVersion
    self.downloadTimes = info.downloadTimes
    self.regionalID = info.fileCfg.regionalID
end

--- 热更新包保存的路径
function UpdateDownloadInfo:getFilePath()
    return self.filePath
end

function UpdateDownloadInfo:getAppVersion()
    return self.appVersion
end

function UpdateDownloadInfo:getNewestLuaVersion()
    return self.newestLuaVersion
end

--- 热更新类型
--- UpdateEnum.Type.Lua, UpdateEnum.Type.Diff, UpdateEnum.Type.App
function UpdateDownloadInfo:getType()
    return self.type
end

--- 热更新方式
--- UpdateEnum.Mode.Silent, UpdateEnum.Mode.Optional, UpdateEnum.Mode.Forced
function UpdateDownloadInfo:getMode()
    return self.mode
end

--- 当前下载文件信息
function UpdateDownloadInfo:getFileCfg()
    return self.fileCfg
end

--- 热更新文件下载地址
function UpdateDownloadInfo:getUrl()
    return self.fileCfg.url
end

--- 当前下载的文件hash值
function UpdateDownloadInfo:getHash()
    return self.fileCfg.hash
end

--- 当前下载的文件大小
function UpdateDownloadInfo:getSize()
    return self.fileCfg.size
end

--- 当前下载的区域ID
function UpdateDownloadInfo:getRegionalID()
    return self.fileCfg.regionalID
end

return UpdateDownloadInfo