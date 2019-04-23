local SettingConfig = class("SettingConfig")

--背景音乐开关 默认打开
function SettingConfig.setBGMSwitch(BGMSwitch)
    cc.UserDefault:getInstance():setBoolForKey("BGMSwitch",BGMSwitch)
end

function SettingConfig.getBGMSwitch()
    return cc.UserDefault:getInstance():getBoolForKey("BGMSwitch",true)
end

--震动开关 默认打开
function SettingConfig.setShakeSwitch(shakeSwitch)
    cc.UserDefault:getInstance():setBoolForKey("shakeSwitch",shakeSwitch)
end

function SettingConfig.getShakeSwitch()
    return cc.UserDefault:getInstance():getBoolForKey("shakeSwitch",true)
end

--是否自动坐下 默认打开
function SettingConfig.setAutoSitSwitch(autoSitSwitch)
    cc.UserDefault:getInstance():setBoolForKey("autoSitSwitch",autoSitSwitch)
end

function SettingConfig.getAutoSitSwitch()
    return cc.UserDefault:getInstance():getBoolForKey("autoSitSwitch",true)
end

--是否自动买入 默认打开
function SettingConfig.setAutoBuyInSwitch(autoBuyInSwitch)
    cc.UserDefault:getInstance():setBoolForKey("autoBuyInSwitch",autoBuyInSwitch)
end

function SettingConfig.getAutoBuyInSwitch()
    return cc.UserDefault:getInstance():getBoolForKey("autoBuyInSwitch",true)
end

--玩牌统计提示 默认打开
-- function SettingConfig.setPlayTipsSwitch(playTipsSwitch)
--     cc.UserDefault:getInstance():setBoolForKey("playTipsSwitch",playTipsSwitch)
-- end

-- function SettingConfig.getPlayTipsSwitch()
--     return cc.UserDefault:getInstance():getBoolForKey("playTipsSwitch",true)
-- end

-- 音量 默认100
function SettingConfig.setSliderPercent(sliderPercent)
    cc.UserDefault:getInstance():setIntegerForKey("sliderPercent",sliderPercent)
end

function SettingConfig.getSliderPercent()
    return cc.UserDefault:getInstance():getIntegerForKey("sliderPercent",100)
end

return SettingConfig