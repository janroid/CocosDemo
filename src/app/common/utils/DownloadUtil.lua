local DownloadUtil = class("DownloadUtil")
local DB = import("app.model").DB;

function DownloadUtil:ctor()
    
    self.m_waitingTask = {} -- 等待下载的队列
    self.m_downloadingTask = {} -- 正在下载的任务列表
    self:createDownloader()
end

function DownloadUtil:createDownloader()
    self.m_downloader = cc.Downloader.new()
    local function onTaskSuccess(task)
        self:onComplete(task.requestURL, task.identifier, true)
    end
    local function onProgress(task, bytesReceived, totalBytesReceived, totalBytesExpected)
        g_EventDispatcher:dispatch(g_SceneEvent.FILE_DOWNLOAD_PROGRESS, task.requestURL, totalBytesReceived, totalBytesExpected)
    end
    local function onTaskError(task, errorCode, errorCodeInternal, errorStr)
        Log.d("DownloadUtil:startDownload onTaskError ",task.requestURL, errorCode, errorCodeInternal, errorStr)
        self:onComplete(task.requestURL,task.identifier, false)
        os.remove(task.identifier .. ".tmp")
    end
    self.m_downloader:setOnFileTaskSuccess(onTaskSuccess)
    self.m_downloader:setOnTaskProgress(onProgress)
    self.m_downloader:setOnTaskError(onTaskError)
end

function DownloadUtil:download(url,path,forceDownload)
    if g_StringLib.isEmpty(url) then 
        self:onComplete(url, path, false)
        return;
    end
    local isExist = self:checkIsDownloaded(path);
    if isExist and forceDownload ~= true  then 
        self:onComplete(url,path,true)
        return;
    end
    
    self:addTask(url, path)
end

function DownloadUtil:addTask(url, path)
    if not self:checkIsDownloading(url, path) then
        self:startDownload(url,path)
    else
        self:addToQueue(url, path)
    end
end

function DownloadUtil:checkIsDownloading(url, path)
    for k, v in pairs(self.m_downloadingTask) do
        if v.url == url and v.path == path then
            return true
        end
    end
    return false
end

function DownloadUtil:removeFromDownloaingTask(url, path)
    for k, v in pairs(self.m_downloadingTask) do
        if v.url == url and v.path == path then
            table.remove( self.m_downloadingTask, k)
        end
    end
end

function DownloadUtil:addToQueue(url, path)
    local isInQueue = false
    for k,v in pairs(self.m_waitingTask) do
        if v.url == url and v.path == path then
            isInQueue = true
        end
    end
    if not isInQueue then
        local temp = {
            url = url,
            path = path
        }
        table.insert(self.m_waitingTask, temp)
    end
end

-- 下载完成
-- status 下载状态
function DownloadUtil:onComplete(url, path, isSuccess)
    -- notify 下载状态
    g_EventDispatcher:dispatch(url, url, path, isSuccess)
    self:removeFromDownloaingTask(url, path)
    
    self:downloadNext()
    
end

function DownloadUtil:downloadNext()
    if not g_TableLib.isEmpty(self.m_waitingTask) then
        local task = table.remove( self.m_waitingTask, 1)
        self:download(task.url, task.path)
    end
end

function DownloadUtil:startDownload(url, path)
    local task = {
        url = url,
        path = path,
    }
    table.insert( self.m_downloadingTask, task)
    self.m_downloader:createDownloadFileTask(url,path,path)
end


function DownloadUtil:checkIsDownloaded(path)
    if cc.FileUtils:getInstance():isFileExist(path) then 
        return true
    end
    return false
end

return DownloadUtil