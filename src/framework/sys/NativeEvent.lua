local NativeCall = import("NativeCall")

local NativeEvent = class()

function NativeEvent.getInstance()
    if not NativeEvent.s_instance then
        NativeEvent.s_instance = NativeEvent.create()
    end
    return NativeEvent.s_instance
end

function NativeEvent.releaseInstance()
    if NativeEvent.s_instance then
        delete(NativeEvent.s_instance)
        NativeEvent.s_instance = nil
    end
end

function NativeEvent:ctor()
    self._observer = {}
end

function NativeEvent:dtor()
    self._observer = nil
end

-- 设置回调函数为监听者
-- @param method string 原生方法名
-- @param obj    object
-- @param func   function
function NativeEvent:_setObserver(index, obj, func)
    local observer = {
        ['index'] = index,
        ['func'] = func,
        ['obj']  = obj,
    }
    table.insert(self._observer, observer)
end

-- 通知回调方法
function NativeEvent:_notify(index, data)
    for k,v in pairs(self._observer) do
        if v['index'] == index then
            if v['func'] then
                v['func'](v['obj'], data)
            end
            self._observer[k] = nil
            break
        end
    end
end

NativeEvent.S_Config = {

}


-- 注册配置文件
-- 格式{key = {classPath = "java class path", method="native MethodName"}}
function NativeEvent:registerConfig(config)
    for k, v in pairs(config) do
        assert(NativeEvent.S_Config[k] == nil , "NativeEvent:rigesterConfig repeat key")
        NativeEvent.S_Config[k] = v
    end
end


-- 调用原生方法
-- @param key    NativeEvent.S_Config表的key，用于获取配置表中原生层对应的类名，方法名
-- @param data   string 传给原生的参数
-- @param obj
-- @param func   回调函数
function NativeEvent:callNative(key, data, obj, func,delay)
    data = data or ""
    local requestParams = {}
    requestParams._params = data

    if device.platform == "ios" then
        
        local iOSMethod = NativeEvent.S_Config[key]['iOSMethod']
        Log.d("callNative",iOSMethod)

        if iOSMethod == nil then return end
        requestParams._nativeIosMethod = NativeCmd.NATIVE_CONFIG[key]['iOSMethod']

        -- assert(method ~= nil, 'ios CallNativeInterface.callNative method is nil')
    else
        requestParams._nativeClassPath = NativeCmd.NATIVE_CONFIG[key]['classPath']
        requestParams._nativeClassMethod = NativeCmd.NATIVE_CONFIG[key]['method']
        local method = NativeEvent.S_Config[key]['method']
        assert(method ~= nil, 'andriod or win32 CallNativeInterface.callNative method is nil')
    end
    
    local needResponse = false -- 原生处理完后是否需要回调Lua
    if func then
        needResponse = true
        self:_setObserver(key, obj, func,delay)
    end 
    NativeCall.lcc_callSystemEvent(key, g_JsonUtil.encode(requestParams))
end

-- 原生回调lua
function NativeEvent:nativeCallLua(key, result)
    -- print("NativeEvent:nativeCallLua", result)
    local result2 = g_JsonUtil.decode(result)
    Log.d("nativeCallLua",key,result2)
    local resultTab = g_TableLib.checktable(result2)
    -- g_Schedule:schedulerOnce(function()
        self:_notify(key, resultTab)
    -- end,1)
end


return NativeEvent