--[Comment]
--经验相关工具类
local ExpUtil = {};
ExpUtil.levelXmlList = nil;
ExpUtil.levelMax = nil;
        
ExpUtil.initialize = function()
    ExpUtil.levelXmlList = GameString.get("str_xml_resource_level_list");
    ExpUtil.levelMax = # ExpUtil.levelXmlList;
end
        
--[Comment]
--根据经验值获得头衔
--@param exp 经验值
ExpUtil.getTitleByExp = function(exp)
    if ExpUtil.levelMax == nil then
        ExpUtil.initialize();
    end
    local title = nil;
    local index = 0;
    for i = 1, ExpUtil.levelMax do
        index = i;
        if exp < ExpUtil.levelXmlList[i].c then
            break;
        end
    end
    if exp <= 0 then
        index = 1;
    end
    title = ExpUtil.levelXmlList[index].b;
    return title;
end
        
--[Comment]
--根据经验值获得等级
--@param exp 经验值
--@return 等级
ExpUtil.getLevelByExp = function(exp)
    exp = exp or 0;
    if ExpUtil.levelMax == nil then
        ExpUtil.initialize();
    end
    local level = 0;
    local index = 0;
    for i = 1, ExpUtil.levelMax do
        if exp < ExpUtil.levelXmlList[i].c then
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
ExpUtil.getLevelProgressPercent = function(exp)
    local ret = 100;
    if exp ~= nil then
        if ExpUtil.levelMax == nil then
            ExpUtil.initialize();
        end
    
        local level = ExpUtil.getLevelByExp(exp);
        if level < ExpUtil.levelMax then
            local thisLevelExp = ExpUtil.levelXmlList[level].c;
            local nextLevelExp = ExpUtil.levelXmlList[level + 1].c;
            ret = math.floor((exp - thisLevelExp) * 100 / (nextLevelExp - thisLevelExp));
        end
    end
    return ret;
end
        
ExpUtil.getLevelProgressLabel = function(exp)
    if ExpUtil.levelMax == nil then
        ExpUtil.initialize();
    end
    local ret = "0/0";
    local level = ExpUtil.getLevelByExp(exp);
    if level < ExpUtil.levelMax then
        local thisLevelExp = ExpUtil.levelXmlList[level].c;
        local nextLevelExp = ExpUtil.levelXmlList[level + 1].c;
        ret = (exp - thisLevelExp).."/"..(nextLevelExp - thisLevelExp);
    else
        local thisLevelExp = ExpUtil.levelXmlList[level].c;
        ret = thisLevelExp.."/"..thisLevelExp;
    end
    return ret;
end

return ExpUtil