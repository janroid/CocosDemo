--[[
    author:{JanRoid}
    time:2019-1-30
    Description: 数据类
    功能：
        1、自动创建数据类
        2、存数据（字段，数据类，表）
        3、取数据（字段，对象）
        4、数据绑定（主动，自动释放）使用消息机制
        5、属性绑定（主动，自动释放）使用消息机制
        6、清空数据

    使用场景：1、纯数据保存,不存在逻辑类

]] 

local Model = class("Model")
Model.s_dataPools = {}
Model.s_watcherPools = {}
Model.s_propertyWatcherPools = {}

function Model:ctor()

end

--[[
    @desc: 设置数据对象
    --@key:
	--@data: nil：自动根据key初始化数据类，
    @return:
]]
function Model:setData(key, data)
    if not self:checkKey(key) then
        Log.e("Model:setData - key is wrongful")
        return
    end

    if data == nil then
        if Model.s_dataPools[key] then
            Model.s_dataPools[key] = data
        else
            self:createData(key)
        end
    else
        Model.s_dataPools[key] = data
    end

    self:notifyChange(key)
end

--[[
    @desc: 获取数据对象，如果是第一次则初始化一个数据对象返回
    --@key: 
    @return:
]]
function Model:getData(key)
    if not self:checkKey(key) then
        Log.e("Model:getData - key is wrongful")
        return nil
    end

    return Model.s_dataPools[key]
end

function Model:setProperty(key, property, value)
    if not self:checkKey(key) or not property then
        Log.e("Model:setProperty - key is wrongful")
        return
    end

    local obj = nil
    if self:hasData(key) then
        obj = self:getData(key)
    else
        obj = self:createData(key)
    end
    
    obj[property] = value

    self:notifyChange(key,property)

end

function Model:getProperty(key, property)
    if not self:checkKey(key) or not property then
        Log.e("Model:getProperty - key is wrongful")
        return
    end

    local pp = nil
    if self:hasData(key) then
        pp = Model.s_dataPools[key][property]
    end

    return pp
end

function Model:clearData(key)
    if self:hasData(key) then
        self:unwatchData(key)
        Model.s_dataPools[key] = nil
    end
end

function Model:clearAllData( )
    Model.s_dataPools = {}
    Model.s_watcherPools = {}
    Model.s_propertyWatcherPools = {}
end

--[[
    @desc: 是否存在数据对象
    --@key: 
    @return:
]]
function Model:hasData(key)
    if key and Model.s_dataPools[key] ~= nil then
        return true
    end

    return false
end

--[[
    @desc: 给数据注册监听事件，数据改变时，触发事件
    --@key: 不可为nil
	--@obj: 不可为nil
	--@func: 不可为nil
	--@callNow: 是否马上调用一次
    @return:
]]
function Model:watchData(key, obj, func, callNow)
    callNow = (callNow == nil) and true or callNow

    if not obj or not func or not key then
        Log.e("Model.watchData param is wrongful")
        return
    end

    Model.s_watcherPools[key] = Model.s_watcherPools[key] or {}

    if Model.s_watcherPools[key][tostring(obj)] then
        Log.e("Model.watchData -- 重复注册回调！")
    end

    Model.s_watcherPools[key][tostring(obj)] = {func,obj}

    if callNow then
        local data = self:getData(key)
        self:__callBack(func,obj,data,key)
    end
end

--[[
    @desc: 
    author:{author}
    time:2019-02-13 18:16:49
    --@list: {{key,obj,func,callNow}, ...}
    @return:
]]
function Model:watchDataList(list)
    list = list or {}
    for k, v in pairs(list) do
        self:watchData(v[1],v[2],v[3],v[4])
    end
end

--[[
    @desc: 
    --@key:
	--@property:
	--@obj:
	--@func:
	--@callNow: 是否马上调用一次
    @return:
]]
function Model:watchProperty(key, property, obj, func, callNow)
    callNow = (callNow == nil) and true or callNow

    if not obj or not func or not key or not property then
        Log.e("Model.watchData param is wrongful")
        return
    end

    local id = self:getPropertyKey(key,property)
    Model.s_propertyWatcherPools[id] = Model.s_propertyWatcherPools[id] or {}
    
    if Model.s_propertyWatcherPools[id][tostring(obj)] then
        Log.e("Model.watchData -- 重复注册回调！")
    end

    Model.s_propertyWatcherPools[id][tostring(obj)] = {func,obj}

    if callNow then
        local data = self:getProperty(key,property)

        self:__callBack(func, obj, data,key)
    end
end

--[[
    @desc: 
    author:{author}
    time:2019-02-13 18:19:08
    --@list: {{key,property,obj,func,callNow}, ...}
    @return:
]]
function Model:watchPropertyList(list)
    list = list or {}
    for k,v in pairs(list) do
        self:watchProperty(v[1],v[2],v[3],v[4],v[5])
    end
end


----------------------------------------- private func --------------------------------------
function Model:checkKey(key)
    if key and string.len(key) > 0 then
        return true
    end

    return false
end

--[[
    @desc: 移除数据下所有监控
    --@key: 
	--@obj: 为nil时表示移除所有监听
    @return:
]]
function Model:unwatchData(key,obj)
    if key == nil then
        Log.e("Model:unWatch -- key is nil")
        return
    end

    if not obj then
        Model.s_watcherPools[key] = nil
    else
        if Model.s_watcherPools[key] then
            Model.s_watcherPools[key][tostring(obj)] = nil
        end
    end

end

--[[
    @desc: 
    author:{author}
    time:2019-02-13 18:35:38
    --@list: {{key,obj},...}
    @return:
]]
function Model:unwatchDataList(list)
    list = list or {}
    for k, v in pairs(list) do
        self:unwatchData(v[1],v[2])
    end
end

--[[
    @desc: 移除监控
    author:{author}
    time:2019-02-13 18:39:33
    --@key:
	--@property:
	--@obj: 
    @return:
]]
function Model:unwatchProperty(key,property,obj)
    if not key or not property then
        Log.e("Model:unPropertyWatch -- key or property is nil")

        return
    end
    local id = self:getPropertyKey(key,property)
    
    if obj then
        Model.s_propertyWatcherPools[id] = nil
    else
        if Model.s_propertyWatcherPools[id] then
            Model.s_propertyWatcherPools[id][tostring(obj)] = nil
        end
    end
end

--[[
    @desc: 
    author:{author}
    time:2019-02-13 18:20:34
    --@list: {{key,property, obj}, ...}
    @return:
]]
function Model:unwatchPropertyList(list)
    list = list or {}
    for k, v in pairs(list) do
        self:unwatchProperty(v[1],v[2],v[3])
    end
end

--[[
    @desc: 初始化数据类，数据类必须定义在data目录下
    --@key: 
    @return:
]]
function Model:createData(key)
    if self:hasData(key) then
        return Model.s_dataPools[key]
    end

    local str = "data/".. key
    
    local status, value = pcall(require,str)
    if not status then
        Log.e("Model.createData -- require ",key," is nil !")

        Model.s_dataPools[key] = {}
        return Model.s_dataPools[key]
    end

    Model.s_dataPools[key] = value:create()

    return Model.s_dataPools[key]
end

--[[
    @desc: 触发数据绑定回调 
    --@key:
	--@property: 
    @return:
]]
function Model:notifyChange(key, property)
    if not self:hasData(key) then
        Log.e("Model:notifyChange -- key is nil")
        return
    end

    if property then
        if property ~= nil then
            local id = self:getPropertyKey(key,property)
            if Model.s_propertyWatcherPools[id] then
                local data = self:getProperty(key,property)
                for k,v in pairs(Model.s_propertyWatcherPools[id]) do
                    self:__callBack(v[1],v[2],data,key)
                end
            end
        end
    else
        if Model.s_watcherPools[key] ~= nil then
            local data = self:getData(key)
            local map = Model.s_watcherPools[key]
            for k,v in pairs(Model.s_watcherPools[key]) do
                self:__callBack(v[1],v[2],data,key)
            end
        end
    end
end

function Model:__callBack(func,obj,data,key)
    if func and obj then
        func(obj,data)
    else
        Log.e("Model:__callBack, func or obj is nil! key = ",key)
    end
end

function Model:getPropertyKey(key,property)
    return key .. "_" .. property
end

return Model

