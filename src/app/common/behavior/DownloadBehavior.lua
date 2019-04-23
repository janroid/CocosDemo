--[[
    下载
    用法：
        local BehaviorMap = import("app.common.behavior").BehaviorMap;
        obj:bindBehavior(BehaviorMap.DownloadBehavior);
        obj:downloadImg(url,callbackFunc,filePath,fileName,isFullPath);
]]

---对外导出接口
local exportInterface = {
    "downloadImg";
    "downloadFile";
    "cancelDownloadTask",
};

local DB = import("app.model").DB;
local DownloadBehavior = class("DownloadBehavior",BehaviorBase)
DownloadBehavior.className_  = "DownloadBehavior";

function DownloadBehavior:ctor()
    DownloadBehavior.super.ctor(self, "DownloadBehavior", nil, 1);
    --self.m_downloader = cc.Downloader.new()
    self.m_callbackFuncs = {}
end

function DownloadBehavior:dtor()
end

function DownloadBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end 
end

function DownloadBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--url: 图片地址
--callFunc：图片下载完成后的回调函数，返回数据：{isSuccess = true,fullFilePath = fullFilePath},fullFilePath:全路径
--filePath：指定路径，可不传，默认路径 cc.FileUtils:getInstance():getWritablePath().."images/"
--fileName: 指定图片名,可不传，默认为当前时间戳
--isFullPath:是否为全路径，传入的路径如果不是全路径会默认拼上cc.FileUtils:getInstance():getWritablePath()
--forceDownload:是否强制下载 true:即使有文件也会下载新的进行覆盖 false/nil:已经下载过就不会再次下载
function DownloadBehavior:downloadImg(object,url,callFunc,filePath,fileName,isFullPath,forceDownload)
    self:download(object,url,callFunc,filePath,fileName,isFullPath,"images/",".png",forceDownload)
end 

function DownloadBehavior:downloadFile(object,url,callFunc,filePath,fileName,isFullPath,suffix,forceDownload)
    self:download(object,url,callFunc,filePath,fileName,isFullPath,"file/",suffix,forceDownload)
end 


function  DownloadBehavior:getFileFullPath(url,filePath,fileName,isFullPath,defaultPath,suffix)
    local path = defaultPath;          
    if filePath then 
        filePath = tostring(filePath);
        if g_StringLib.isEmpty(filePath) then
            isFullPath = false;
        else                 
            path = filePath;
        end 
    end
    if filePath and isFullPath then 
    else
        filePath = cc.FileUtils:getInstance():getWritablePath()..path;
    end 
    if not cc.FileUtils:getInstance():isDirectoryExist(filePath) then 
        cc.FileUtils:getInstance():createDirectory(filePath);
    end 
    fileName = fileName or NativeCall.lcc_getMD5Hash(url)..suffix;
    local fullFileName = filePath .. fileName;
    return fullFileName
end

function DownloadBehavior:onDownloadComplete(url, path, isSuccess)
    if self.m_callbackFuncs[url] and self.m_callbackFuncs[url].func then
        self.m_callbackFuncs[url].func(self.m_callbackFuncs[url].obj, {isSuccess = isSuccess,fullFilePath = path})
    end
    g_EventDispatcher:unregister(url, self, self.onDownloadComplete)
end

function  DownloadBehavior:download(object,url,callFunc,filePath,fileName,isFullPath,defaultPath,suffix,forceDownload)

    if g_StringLib.isEmpty(url) then
        print("downloadImg url is empty",url)
        if callFunc then
            callFunc(object,{isSuccess = false});
        end
        return;
    end
    local cb = {func = callFunc, obj = object}
    self.m_callbackFuncs[url] = cb
    g_EventDispatcher:register(url, self, self.onDownloadComplete)
    local path = self:getFileFullPath(url,filePath,fileName,isFullPath,defaultPath,suffix or "")
    g_DownloadUtil:download(url, path, forceDownload)
end

function DownloadBehavior:cancelDownloadTask(object,url)
    if url then
        g_EventDispatcher:unregister(url, self, self.onDownloadComplete)
    else
        g_EventDispatcher:unRegisterAllEventByTarget(self)
    end
end


return DownloadBehavior;