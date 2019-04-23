local NetImageView = class("NetImageView", ccui.ImageView)
local BehaviorMap = import("app.common.behavior").BehaviorMap

BehaviorExtend(NetImageView)

function NetImageView:ctor(urlImage, defaultImage, callbackObj, callbackFunc, callbackParams)
    self:setDefaultImage(defaultImage)
    self:bindBehavior(BehaviorMap.DownloadBehavior)
    self:setCallback(callbackObj, callbackFunc, callbackParams)
    self:setUrlImage(urlImage)
end

function NetImageView:setUrlImage(url)
    self:retain()

    self:cancelLastCallback(url)
    
    if self.m_defaultImage then
        self:loadTexture(self.m_defaultImage)
    end
    self.m_url = url
    self:downloadImg(url, self.onDownloadComplete)
end

function NetImageView:cancelLastCallback(url)
    if self.m_url and self.m_url == url then return end
    if not g_StringLib.isEmpty(self.m_url) then
        self:cancelDownloadTask(self.m_url)
    end
end

function NetImageView:onDownloadComplete(data)
    if data.isSuccess and data.fullFilePath then
        self.m_dataPath = data.fullFilePath
        self:loadTexture(data.fullFilePath)
        if self.m_callbackFunc then
            self.m_callbackFunc(self.m_callbackObj, self.m_callbackParams)
        end
    else
        if self.m_defaultImage then
            self:loadTexture(self.m_defaultImage)
            if self.m_callbackFunc then
                self.m_callbackFunc(self.m_callbackObj, self.m_callbackParams)
            end
        end
    end
    self:release()
end

function NetImageView:setDefaultImage(defaultImage)
    self.m_defaultImage = defaultImage
    self:loadTexture(self.m_defaultImage)
end

function NetImageView:setCallback(obj, func, params)
    self.m_callbackObj = obj
    self.m_callbackFunc = func
    self.m_callbackParams = params
end

function NetImageView:getDataPath()
    return self.m_dataPath
end

function NetImageView:dtor()
    self.m_callbackObj = nil
    self.m_dataPath = nil
    self.m_callbackFunc = nil
end

return NetImageView