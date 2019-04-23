---更新的模型信息
--@module UpdateInfo
--@author Loyalwind
--Date   2018/8/15

local UpdateEnum = require("data.UpdateEnum")

local UpdateInfo = class("UpdateInfo")
--[[
info = {
    type = 1,
    mode = 1,
    appVersion    = '1.6.1',
    newestLuaVersion = 10,
    fileConfigs = {
        [1] = {
            url        = "http://mvussppk02.ifere.com/bigfile-ws/mbapk/package2.zip",
            hash       = "33fc02efdcdcd92dc850c8d36720a349",
            size       = 25782,
            regionalID = "zh", -- 区域标识符
        },
    -- [2] = {...}, -- 备留的下载
    -- [3] = {...},
    },
    description = "本次更新会增加前所未有的功能",
}
]]
function UpdateInfo:ctor(info)
    -- 进行无效值过滤
    local type = tonumber(info.type)
    local mode = tonumber(info.mode)
    if type == UpdateEnum.Type.Lua then
        if mode < UpdateEnum.Mode.Silent or mode > UpdateEnum.Mode.Forced then
            mode = UpdateEnum.Mode.Silent
        end
    else
        if mode < UpdateEnum.Mode.Optional or mode > UpdateEnum.Mode.Forced then
            mode = UpdateEnum.Mode.Optional
        end
    end

    self.type = type
    self.mode = mode
    self.appVersion    = info.appVersion
    self.newestLuaVersion = info.newestLuaVersion
    -- self.fileConfigs   = info.fileConfigs -- 本来php应该返回一个数组的，但是目前没有，只能直接仿照一个出来
    self.fileConfigs   = {}
    for i = 1, 3 do
        self.fileConfigs[i] = g_TableLib.copyTab(info.fileConfigs)
    end

    self.description   = info.description
end

--- 应用版本
function UpdateInfo:getAppVersion()
    return self.appVersion
end

--- 热更新版本
function UpdateInfo:getNewestLuaVersion()
    return self.newestLuaVersion
end

--- 热更新类型
--- UpdateEnum.Type.Lua, UpdateEnum.Type.Diff, UpdateEnum.Type.App
function UpdateInfo:getType()
    return self.type
end

--- 热更新方式
--- UpdateEnum.Mode.Silent, UpdateEnum.Mode.Optional, UpdateEnum.Mode.Forced
function UpdateInfo:getMode()
    return self.mode
end

--- 下载配置
function UpdateInfo:getFileConfigs()
    return self.fileConfigs
end

function UpdateInfo:getDescription()
    return self.description
end

return UpdateInfo