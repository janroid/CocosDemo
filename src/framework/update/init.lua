
--[[
注： 
    1. 包内所有参数名为的 updateInfo 均为 UpdateInfo 对象类型 参考 data.UpdateInfo 构造函数
    2. 包内所有参数名为的 updateDownloadInfo 均为 UpdateDownloadInfo 对象类型 参考 data.UpdateDownloadInfo 构造函数
]]

return {
    UpdateBehavior     = require("UpdateBehavior"),
    UpdateHelper       = require("data.UpdateHelper"),
    UpdateEnum         = require("data.UpdateEnum"),
    UpdateDownloadInfo = require("data.UpdateDownloadInfo"),
    UpdateInfo         = require("data.UpdateInfo"),
}
