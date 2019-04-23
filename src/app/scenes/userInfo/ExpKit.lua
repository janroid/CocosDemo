--[Comment]
--经验相关工具类
local ExpKit = {};
ExpKit.levelXmlList = nil;
ExpKit.levelMax = nil;
        
ExpKit.initialize = function()
    ExpKit.levelXmlList = GameString.get("str_xml_resource_level_list");
    ExpKit.levelMax = #GameString.get("str_xml_resource_level_list");
end
        
--[Comment]
--根据经验值获得头衔
--@param exp 经验值
ExpKit.getTitleByExp = function(exp)
    if ExpKit.levelMax == nil then
        ExpKit.initialize();
    end
    local title = nil;
    local index = 0;
    for i = 1, ExpKit.levelMax do
        index = i;
        if exp < ExpKit.levelXmlList[i].c then
            break;
        end
    end
    if exp <= 0 then
        index = 1;
    end
    title = ExpKit.levelXmlList[index].b;
    return title;
end
        
--[Comment]
--根据经验值获得等级
--@param exp 经验值
--@return 等级
ExpKit.getLevelByExp = function(exp)
    exp = exp or 0;
    if ExpKit.levelMax == nil then
        ExpKit.initialize();
    end
    local level = 0;
    local index = 0;
    for i = 1, ExpKit.levelMax do
        if exp < ExpKit.levelXmlList[i].c then
            break;
        end
        index = index + 1;
    end
    level = index;
    if exp <= 0 then
        level = 1;
    end
    return level;
end

--[Comment]
--根据经验获取等级进度百分比值
--@param exp
--@return 0 - 99 的百分比值
ExpKit.getLevelProgressPercent = function(exp)
    local ret = 100;
    if exp ~= nil then
        if ExpKit.levelMax == nil then
            ExpKit.initialize();
        end
    
        local level = ExpKit.getLevelByExp(exp);
        if level < ExpKit.levelMax then
            local thisLevelExp = ExpKit.levelXmlList[level].c;
            local nextLevelExp = ExpKit.levelXmlList[level + 1].c;
            ret = math.floor((exp - thisLevelExp) * 100 / (nextLevelExp - thisLevelExp));
        end
    end
    return ret;
end
        
ExpKit.getLevelProgressLabel = function(exp)
    if ExpKit.levelMax == nil then
        ExpKit.initialize();
    end
    local ret = "0/0";
    local level = ExpKit.getLevelByExp(exp);
    if level < ExpKit.levelMax then
        local thisLevelExp = ExpKit.levelXmlList[level].c;
        local nextLevelExp = ExpKit.levelXmlList[level + 1].c;
        ret = (exp - thisLevelExp).."/"..(nextLevelExp - thisLevelExp);
    end
    return ret;
end

return ExpKit