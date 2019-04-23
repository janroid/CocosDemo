--[[--ldoc 版本更新管理
@module UpdateManager
@author Loyalwind
date   2018/7/30
]]

-- 1.重新启动先进入UpdateScene界面进行检测更新
-- 2.在UpdateScene中进行 UpdateManager的检测调用

local UpdateRecord      = require("data.UpdateRecord")
local UpdateFileTool    = require("data.UpdateFileTool")
local UpdateEnum        = require("data.UpdateEnum")
local UpdateHelper      = require("data.UpdateHelper")
local UpdateLuaOperator = require("operator.UpdateLuaOperator")
---@class 版本更新管理
local UpdateManager = class("UpdateManager")

---单例方法
function UpdateManager.getInstance()
    if not UpdateManager.s_instance then
        UpdateManager.s_instance = UpdateManager.new()
    end
    return UpdateManager.s_instance
end

function UpdateManager:ctor()
    -- Lua更新操作者
    self._updateLuaOperator = UpdateLuaOperator.new(self)
end

function UpdateManager:dtor()

end

-- 添加一个响应者
function UpdateManager:addResponder(responder)
    local responderType = type(responder)
    if (responderType ~= "table") and (responderType ~= "userdata") then return end

    local isValid = true
    for _, funcName in pairs(UpdateEnum.ResponderFunc) do
        if (type(responder[funcName]) ~= "function") then
            isValid = false
            break
        end
    end
    if isValid then
        self._responder = responder
    end
end

-- 移除响应者
function UpdateManager:removeResponder(responder)
    if responder == self._responder then
        self._responder = nil
    end
end

--- 初始化,检查版本，热更新之类的
function UpdateManager:initializeUpdate()
    -- 当前应用程序的版本
    local appVersion = UpdateHelper.appVersion()
    -- 保存起来的应用程序版本
    local saveVersion = UpdateRecord.getInstance():getAppVersion()

    if saveVersion == "" then -- 是首次安装使用
        UpdateRecord.getInstance():saveAppVersion(appVersion)
        return
    end

    -- 比较版本
    local ret = UpdateHelper.compareVersion(appVersion, saveVersion)
    if ret == 1 or ret == -1 then  -- 1:appVersion > saveVersion 高版本覆盖; -1: appVersion < saveVersion 低版本覆盖
        -- 保存新版本
        UpdateRecord.getInstance():saveAppVersion(appVersion)
        if UpdateFileTool.isExistOldUpdate() then
            -- 删除旧版本的资源
            UpdateFileTool.removeOldUpdate()
            UpdateFileTool.removeAllDownloadedRes()
            if g_SystemInfo:isWindows() then -- windows 下进行重启引擎， iOS/Android 在c++层已进行了旧资源删除操作，
                -- 重启引擎
                UpdateHelper.restart()
            end
        end
    end
 end
 
--@desc: 检查是否有更新
--@url: http地址 必填
--@params: table, {regionalID=区域标识符(必填), xx = xxx}
--@callBack: 回调方法 function(bool_ret) end
function UpdateManager:checkUpdate(url, params, callBack)
    assert(type(callBack) == 'function', "callBack must be a function")
    params = g_TableLib.checktable(params)

    g_HttpManager:doPostWithUrl(url, params, nil, function(_, isSuccess, data, params)
        callBack(isSuccess, data, params)
    end, function()
        callBack(false, nil, params)
    end)
end

--@desc 下载更新
--@updateInfo UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateManager:prepareUpdate(updateInfo)
    self._updateInfo = updateInfo;

    -- lua更新
    if updateInfo.type == UpdateEnum.Type.Lua then 
        if updateInfo.mode == UpdateEnum.Mode.Optional then
             -- lua 可选
            self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onPreparedLuaOptional, updateInfo)
        elseif updateInfo.mode == UpdateEnum.Mode.Silent then
             -- lua 静默
            self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onPreparedLuaSilent, updateInfo)
            self._updateLuaOperator:startUpdate(updateInfo)
        else  -- lua 强制
            self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onPreparedLuaForced, updateInfo)
            self._updateLuaOperator:startUpdate(updateInfo)
        end
    -- app更新
    else 
        -- app可选
        if updateInfo.mode == UpdateEnum.Mode.Optional then 
            self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onPreparedAppOptional, updateInfo)
        else
            -- app 强制
            self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onPreparedAppForced, updateInfo)
        end
    end
end

--- 确定更新
--@updateInfo: UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
function UpdateManager:confirmUpdate(updateInfo)
    updateInfo = g_TableLib.checktable(updateInfo)
    if updateInfo.type == UpdateEnum.Type.Lua then -- lua可选更新点击确定
        self._updateLuaOperator:startUpdate(updateInfo)
    else --到商店下载
        UpdateHelper.gotoAppStore()
    end
end

--- 取消更新
function UpdateManager:cancleUpdate()

end

--- 删除旧版本包留下的热更新资源
function UpdateManager:removeOldUpdate()
    UpdateFileTool.removeOldUpdate()
end

--@desc: 更新下载进度的回调
--@operator:更新操作者
--@downloadInfo:下载信息
--@bytesReceived:下载速度
--@totalBytesReceived:已经下载的大小
--@totalBytesExpected: 总共要下载的大小
function UpdateManager:onUpdateProgress(operator, downloadInfo, bytesReceived, totalBytesReceived, totalBytesExpected)
    downloadInfo = g_TableLib.checktable(downloadInfo)
    if downloadInfo.mode == UpdateEnum.Mode.Silent then -- 静默更新，不需要去通知代理
        return
    end

    self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onUpdateProgress, downloadInfo, bytesReceived, totalBytesReceived, totalBytesExpected)
end

--@desc: 更新成功的回调
--@operator:更新操作者
--@downloadInfo:下载信息
function UpdateManager:onUpdateSuccess(operator, downloadInfo)
    downloadInfo = g_TableLib.checktable(downloadInfo)
    if downloadInfo.mode == UpdateEnum.Mode.Silent then -- 静默更新，不需要去通知代理
        return
    end
    self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onUpdateSuccess, downloadInfo, true)
end

--@desc: 更新出错的回调
--@operator:更新操作者
--@downloadInfo:下载信息
--@errorCode: 错误码枚举值 UpdateEnum.ErrorCode
--@errorCodeInternal:内部错误码
--@errorStr: 错误信息
function UpdateManager:onUpdateError(operator, downloadInfo, errorCode, errorCodeInternal, errorStr)
    downloadInfo = g_TableLib.checktable(downloadInfo)
    if downloadInfo.mode == UpdateEnum.Mode.Silent then -- 静默更新，不需要去通知代理
        return
    end
    self:_responderSafeCallFunc(UpdateEnum.ResponderFunc.onUpdateError, downloadInfo, errorCode, errorCodeInternal, errorStr)
end

function UpdateManager:_responderSafeCallFunc(funcName, ...)
    if self:_responderIsResponseFunc(funcName) then
        return self._responder[funcName](self._responder, ...)
    end
end

function UpdateManager:_responderIsResponseFunc(funcName)
    if type(funcName) ~= "string" or funcName == "" then
        return false
    end
    local responderType = type(self._responder)
    if (responderType == "table" or responderType == "userdata") and type(self._responder[funcName]) == "function" then
        return true
    end
    return false
end

return UpdateManager