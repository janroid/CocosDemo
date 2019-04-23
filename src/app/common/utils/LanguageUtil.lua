
local LanguageUtil = class("LanguageUtil")

function LanguageUtil.switchFilePath(filePath)
    if(type(filePath) == "string") then
        if g_AppManager and g_AppManager:getAppPlatform() then
            filePath = string.gsub(filePath,"platformFile/", "platformFile_"..g_AppManager:getAppPlatform().."/", 1);
        end
    end
    return filePath;
end

function LanguageUtil.switchResPath(resPath)
    if(type(filePath) == "string") then
        if g_AppManager and g_AppManager:getAppPlatform() then
            filePath = string.gsub(filePath,"platformRes/", "platformRes_"..g_AppManager:getAppPlatform().."/", 1);
        end
    end
    return filePath;
end

return LanguageUtil