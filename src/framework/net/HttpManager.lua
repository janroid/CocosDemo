local TableLib = import("framework.utils").TableLib
local HttpBase = require('HttpBase')

local HttpManager = class("HttpManager")

HttpManager.S_REQUEST_TYPE = {
    ["GET"] = "GET";
    ["POST"] = "POST";
}

function HttpManager.getInstance()
    if not HttpManager.s_instance then
		HttpManager.s_instance = HttpManager.create()
    end
    return HttpManager.s_instance
end

function HttpManager.release()
    HttpManager.s_instance = nil
end

function HttpManager:ctor()
    self.m_defaultParams = {} -- 默认请求参数
    self.m_defaultUrl = "" -- 默认请求地址
    self.m_defaultStaticUrl = ""--
    self.m_http = {} -- 所有http请求
end
function HttpManager:doGet(params,obj,callbackFunc,requestCustomId)
    self:doGetWithUrl(self.m_defaultUrl,params,obj,callbackFunc,requestCustomId)
end

function HttpManager:doGetWithUrl(url, params, obj, callbackFunc, requestCustomId)
    local requestUrl = self:getRequestUrl(url,params)
    self:excute(HttpManager.S_REQUEST_TYPE['GET'],url,params,nil,obj,callbackFunc,requestCustomId)
end

-- 获取get请求的url
function HttpManager:getRequestUrl(url, params)
    local param = self:table2Params(params)
    if not TableLib.isEmpty(self.m_defaultParams) then
        param = self:table2Params(self.m_defaultParams).."&"..param
    end
    if param and param ~= "" then
        return url .. "?" ..param
    end
    return url
end

--[[
    @desc: 
    author:{author}
    time:2018-11-30 11:40:43
    --@params:
	--@obj:
	--@callbackFunc: 回调函数参数callbackFunc(isSuccess, response, param)
	--@requestCustomId: 
    @return:
]]
function HttpManager:doPost(params, obj, callbackFunc, requestCustomId, decodeType)
    self:doPostWithUrl(self.m_defaultUrl,params,obj,callbackFunc,requestCustomId,decodeType)
end

function HttpManager:doPostWithUrl(url, params, obj, callbackFunc, requestCustomId,decodeType)
    local data = self:getPostData(params)
    self:excute(HttpManager.S_REQUEST_TYPE['POST'],url,params,data,obj,callbackFunc,requestCustomId,decodeType)
end

-- 获取post请求的data
function HttpManager:getPostData(params)
    local data = self:table2Params(params)
    if not TableLib.isEmpty(self.m_defaultParams) then
        data = self:table2Params(self.m_defaultParams).."&"..data
    end
    return data
end



-- requestType : 请求类型 
-- url : 请求地址
-- params : 请求参数用于响应后回传
-- data : 传给服务器的请求参数
-- obj : 响应函数的实例
-- onSuccess : 请求成功响应
-- onFail : 请求失败响应
-- requestCustomId : 自定义请求Id,用于取消对应的请求
function HttpManager:excute(requestType, url, params, data, obj, callbackFunc, requestCustomId,decodeType)
    local httpBase = HttpBase:create(url, data, requestType, cc.XMLHTTPREQUEST_RESPONSE_STRING)
    httpBase:setParams(params)
    httpBase:setDecodeType(decodeType)
    httpBase:setCallback(obj,callbackFunc)
    if(requestCustomId) then
        httpBase:setRequestId(requestCustomId)
    end
    httpBase:setListener(function()
        local http = httpBase:getObj()
        local isSuccess = false
        local response = {}
        local flag
        if not http then return end
        if http.readyState == 4 and (http.status >= 200 and http.status < 207) then
            local originDecodeType = httpBase:getDecodeType()
            if originDecodeType == 1 then
                response, flag = g_JsonUtil.decode(http.response)
                if (not flag) then -- -- json解析错误，直接返回返回值
                    Log.e("HttpManager:excute","response json error, params = ",params, http.response);
                    isSuccess = false
                    response = http.response
                else
                    isSuccess = true
                end
            else
                flag, response = g_XmlUtil.decode(http.response)
                if (not flag) then -- -- json解析错误，直接返回返回值
                    Log.e("HttpManager:excute","response xml error, params = ",params);
                    isSuccess = false
                    response = http.response
                else
                    isSuccess = true
                end
            end
        else
            response, flag = g_JsonUtil.decode(http.response)
            isSuccess = false;
            if (not flag) then -- json解析错误，直接返回返回值
                response = http.response
            end
            Log.d("HttpManager:excute", "readyState = ",http.readyState, "status = ",http.status)
        end
        local callbackFunc = httpBase:getCallBackFunc()
        if callbackFunc then
            local callbackObj = httpBase:getCallbakObj()
            if callbackObj and callbackObj._isCleanup == true then
                return 
            end
            callbackFunc(callbackObj, isSuccess, response, httpBase:getParams())
        end

        TableLib.removeByValue(self.m_http,httpBase,false)
        httpBase:clearListener()
    end)
    httpBase:excute()
    table.insert(self.m_http, httpBase)
end

-- 添加默认请求参数
function HttpManager:addDefaultParam(key, value)
    if key ~= nil then
        self.m_defaultParams[key] = value
    end
end

-- 获取默认请求参数
function HttpManager:getDefaultParam()
    return g_TableLib.copyTab(self.m_defaultParams)
end

function HttpManager:clearDefaultParams()
    self.m_defaultParams = {}
end

function HttpManager:setDefaultUrl(url)
    self.m_defaultUrl = url
end

function HttpManager:setDefaultStaticUrl(url)
    self.m_defaultStaticUrl = url
end

function HttpManager:getDefaultStaticUrl()
    return self.m_defaultStaticUrl
end

function HttpManager:table2Params(data)
    if TableLib.isEmpty(data) then
        return ""
    end
    if not TableLib.isValid(data) then
        return self:formatPlus(data)
    end
    local str = nil;
    local ret = {};
    if data ~= nil then
        for key, value in pairs(data) do
            table.insert(ret, (key .."="..self:formatPlus(value)));
        end  
    end
    str = table.concat(ret, "&");
    return str;
end

--判断里面是否有+，有的话转化为%2B
function HttpManager:formatPlus(str)
    if str then
        return string.gsub(str, "+", "%%2B");
    end
    return nil
end

-- 取消所有请求
function HttpManager:cancelAllRequest()
    if not TableLib.isEmpty(self.m_http) then
        for k,v in pairs(self.m_http) do
            v:abort()
        end
    end
end

function HttpManager:cancelRequest(requestCustomId)
    if not TableLib.isEmpty(self.m_http) then
        for k,v in pairs(self.m_http) do
            if v:getReuqestId() == requestCustomId then
                v:abort()
            end
        end
    end
end

function HttpManager:cancelRequestByObj(obj)
    if not TableLib.isEmpty(self.m_http) then
        for k,v in pairs(self.m_http) do
            if v and v:getCallbakObj() == obj then
                v:abort()
            end
        end
    end
end

return HttpManager