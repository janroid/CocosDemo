--[[
    游戏文本管理类
    author:{author}
    time:2018-10-26 11:42:18
]]

cc.exports.GameString = {};

GameString.m_keyMap = {}

function GameString.load(filename)
    assert(filename,"GameString.load -- 项目文本文件不能传空")

    GameString.m_stringMap = require("." .. filename)
end

function GameString.get(key)
    if  type(DEBUG) == "number" and DEBUG > 0 then
        assert(key,"GameString.get -- 文本key不可以为空")
    end
    local str = GameString.m_stringMap[key]

    if type(DEBUG) == "number" and DEBUG > 0 then
        assert(str,"GameString.get -- 找不到对应文本，Key = "..key)
    end
    
    if not GameString.m_keyMap[str] then
        GameString.m_keyMap[str] = key
    end

    return str or ""
end

function GameString.createLabel(str,fontName,fontSize,...)
    if fontName == nil then 
        return cc.Label:createWithSystemFont(str, "", fontSize, ...)
    else
        return cc.Label:createWithTTF(str, fontName, fontSize, ...)
    end
end

return GameString