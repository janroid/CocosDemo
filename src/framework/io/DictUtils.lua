local DictUtils = {}

local UserDefault = cc.UserDefault:getInstance()

function DictUtils.setString(key,value)
    UserDefault:setStringForKey(key,value)
end

function DictUtils.getString(key,defaultValue)
    defaultValue = defaultValue or ""
    return UserDefault:getStringForKey(key,defaultValue)
end

function DictUtils.setInt(key,value)
    UserDefault:setIntegerForKey(key,value)
end

function DictUtils.getInt(key,defaultValue)
    defaultValue = defaultValue or -1
    return UserDefault:getIntegerForKey(key,defaultValue)
end

function DictUtils.setBoolean(key,value)
    UserDefault:setBoolForKey(key,value)
end

function DictUtils.getBoolean(key,defaultValue)
    defaultValue = defaultValue or false
    return UserDefault:getBoolForKey(key,defaultValue)
end

function DictUtils.setDouble(key,value)
    UserDefault:setDoubleForKey(key,value)
end

function DictUtils.getDouble(key,defaultValue)
    defaultValue = defaultValue or -1.0
    return UserDefault:getDoubleForKey(key,defaultValue)
end

function DictUtils.setFloat(key,value)
    UserDefault:setFloatForKey(key,value)
end

function DictUtils.getFloat(key,defaultValue)
    defaultValue = defaultValue or -1.0
    return UserDefault:getFloatForKey(key,defaultValue)
end

function  DictUtils.setData(key,data)
    if type(data) == "table" then
        local dataStr = g_JsonUtil.encode(data)
        Log.d(dataStr)
        DictUtils.setString(key,dataStr)
    else
        Log.e("error data type")
    end
end

function  DictUtils.getData(key,defaultData)
    local dataStr = DictUtils.getString(key)
    local dataJson = g_JsonUtil.decode(dataStr)
    defaultData = defaultData or {} 
    return dataJson or defaultData
end

--[[
    存储伴有有效期的数据
    @param key
    @param value
    @param expriedTime 过期时间 多少秒之后过期
]]
function DictUtils.setDataWithExpired(key,value,expiredTime)
    local data = {}
    if type(value) == "table" then
        value = g_JsonUtil.encode(value)  
    end 
    data[key] = value
    data.expiredTime =tonumber(expiredTime)+os.time()
    DictUtils.setData(key,data)
end

function DictUtils.getDataWithExpired(key)
    local data = DictUtils.getData(key)
    if not g_TableLib.isEmpty(data) then
        local expiredTime = tonumber(data.expiredTime)
        if expiredTime then
            local currentTime = os.time()
            if (currentTime - expiredTime<0) then
                local value,flag= g_JsonUtil.decode(data[key])
                if flag then
                    return value
                else
                    return data[key]
                end
            end
        else
            local value,flag= g_JsonUtil.decode(data[key])
            if flag then
                return value
            else
                return data[key]
            end
        end
    end
    UserDefault:deleteValueForKey(key)
    return nil
end

function DictUtils.deleteValueForKey(key)
    UserDefault:deleteValueForKey(key)
end

return DictUtils