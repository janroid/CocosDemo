local HttpBase = class("HttpBase")

-- url:请求地址
-- data:请求的数据
-- 请求类型：get post...
-- 响应数据格式：cc.XMLHTTPREQUEST_RESPONSE_JSON cc.XMLHTTPREQUEST_RESPONSE_STRING ...
function HttpBase:ctor(url,data,requestType,responseType)
    self.m_http = cc.XMLHttpRequest:new()
    self:setUrl(url)
    self:setData(data)
    self:setRequestType(requestType)
    self:setResponseType(responseType)
end

function HttpBase:getObj()
    return self.m_http
end
function HttpBase:addHeader(field,head)
    self.m_http:setRequestHeader(field, head)
end

-- 设置请求方式 get post...
function HttpBase:setRequestType(type)
    self.m_requestType = type
end

-- 设置响应数据的类型
function HttpBase:setResponseType(type)
    self.m_responseType = type
    self.m_http.responseType = self.m_responseType
end

-- 设置请求地址
function HttpBase:setUrl(url)
    self.m_url = url
end

-- 设置请求数据
function HttpBase:setData(data)
    self.m_data = data
end

function HttpBase:excute()
    self.m_http.responseType = self.m_responseType
end

function HttpBase:setListener(listener)
    self.m_listener = listener
    
end

function HttpBase:clearListener()
    self.m_http:unregisterScriptHandler()
end

function HttpBase:excute()
    self.m_http:open( self.m_requestType, self.m_url)
    self.m_http:registerScriptHandler(self.m_listener)
    self.m_http:send(self.m_data)
end

-- 退出当前请求
function HttpBase:abort()
    if self.m_http then
        self.m_http:abort()
        --self.m_http = nil
    end
end

-- 请求参数 用于http响应后回调使用
function HttpBase:setParams(params)
    self.m_params = params
end

function HttpBase:getParams()
    return self.m_params
end

-- 用户自定义请求Id，用于取消请求
function HttpBase:setRequestId(requestId)
    self.m_requestId = requestId
end
function HttpBase:getRequestId()
    return self.m_requestId
end

function HttpBase:setCallback(obj, func)
    self.m_callbackFunc = func
    self.m_callbackObj = obj
end
function HttpBase:getCallBackFunc()
    return self.m_callbackFunc
end
function HttpBase:getCallbakObj()
    return self.m_callbackObj
end

function HttpBase:setDecodeType(decodeType)
    self.m_decodeType = decodeType or 1
end
function HttpBase:getDecodeType()
    return self.m_decodeType
end

return HttpBase