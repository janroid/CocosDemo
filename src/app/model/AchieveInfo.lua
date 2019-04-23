--[[
    author:{JanRoid}
    time:2018-12-3
    Description: 成就缓存信息，保存成就相关数据
]] 

local AchieveInfo = class("AchieveInfo")

function AchieveInfo:ctor( )
    self.m_config = nil
end

function AchieveInfo:getConfig()
    if g_TableLib.isEmpty(self.m_config) then
        self.m_config = g_AppManager:getAdaptiveConfig().AchieveConfig
    end
    return self.m_config
end

function AchieveInfo:loadConfig(filePath)
    if not filePath or string.len(filePath) < 1 then
        return
    end

    pcall(function()
        if filePath then
            local fun = loadfile(filePath)
            if fun then
                local achieveConfig = fun()
                if not g_TableLib.isEmpty(achieveConfig) then
                    self.m_config = achieveConfig
                end
            end 
        end
    end);
    return self
end



return AchieveInfo