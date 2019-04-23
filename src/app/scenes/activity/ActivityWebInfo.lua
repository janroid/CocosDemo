--[[  --ldoc 网页配置模型
@module ActivityWebInfo
@author LoyalwindPeng

Date   2019-1-10
]]

local ActivityWebInfo = class("ActivityWebInfo")

function ActivityWebInfo:ctor(url)
    self.url = url
    self.forcedDisplay = true -- 默认强制显示
end

---**********   存储型属性、方法     ***************-------
function ActivityWebInfo:setReCreate(reCreate)
    self.reCreate = reCreate
end

function ActivityWebInfo:getReCreate()
    return self.reCreate
end

function ActivityWebInfo:setForcedDisplay(forcedDisplay)
    self.forcedDisplay = forcedDisplay
end

function ActivityWebInfo:getForcedDisplay()
    return self.forcedDisplay
end

function ActivityWebInfo:setFull(full)
    self.full = full
end

function ActivityWebInfo:getFull()
    return self.full
end

function ActivityWebInfo:setX(x)
    self.x = x
end
-- webView的x坐标
function ActivityWebInfo:getX()
    return self.x or display.width * 0.5
end

function ActivityWebInfo:setY(y)
    self.y = y
end
-- webView的y坐标
function ActivityWebInfo:getY()
    return self.y or display.height * 0.5
end

function ActivityWebInfo:setWidth(width)
    self.width = width
end
-- webView的宽度
function ActivityWebInfo:getWidth()
    if self.full then
        return display.width
    end
    return self.width or display.width * 0.8
end

function ActivityWebInfo:setHeight(height)
    self.height = height
end
-- webView的高度
function ActivityWebInfo:getHeight()
    if self.full then
        return display.height
    end
    return self.height or display.height * 0.8
end

function ActivityWebInfo:setUrl(url)
    self.url = url
end

function ActivityWebInfo:getUrl()
    return self.url
end

function ActivityWebInfo:setCallJS(callJS)
    self.callJS = callJS
end

function ActivityWebInfo:getCallJS()
    return self.callJS
end

---**********   计算型属性、方法     ***************-------
--是否有效
--@return bool 是否有效
function ActivityWebInfo:getValid()
    return type(self.url) == 'string' and self.url ~= ''
end

-- webView的位置
function ActivityWebInfo:getPosition()
    return cc.p(self:getX(), self:getY())
end
-- webView的大小
function ActivityWebInfo:getSize()
    return cc.size(self:getWidth(), self:getHeight())
end

-- 生成一份默认的calljs的数据
--@return string
function ActivityWebInfo:defaultCallJs()
    local requestParam = {}
    requestParam.id       = g_AccountInfo: getId()
    requestParam.mid      = g_AccountInfo: getId()
    requestParam.php      = g_HttpManager: getDefaultParam() -- 主要是这个可能有变化
    requestParam.CGI_ROOT = g_AccountInfo: getCGIRoot()
    requestParam.CDN_ROOT = g_AccountInfo: getCDNUrl()
    requestParam.langfix  = g_AccountInfo: getLangFix()
    local callJS = string.format("mb2js(1, '%s')", g_JsonUtil.encode(requestParam))
    return callJS
end

-- 更新默认的calljs的数据
function ActivityWebInfo:updateDefaultCallJs()
    local callJS = self:defaultCallJs()
    self:setCallJS(callJS)
end

-- 生成泰语本地支付的网页页面html
--@url string
--@return string html 字符串
function ActivityWebInfo:createContentHtml(url)
    local urlString = url
    local idx = string.find(url, '?')
    local params = g_HttpManager:getDefaultParam()
    if (idx ~= nil) then
        urlString = string.sub(url, 1, idx - 1)
        local arr = g_StringKit.split(string.sub(url, idx + 1), '&')
        for k, v in pairs(arr) do
            local key_value = g_StringKit.split(v, '=')
            if (#key_value == 2) then
                local key = key_value[1]
                local value = key_value[2]
                params[key] = value
            end
        end
    end
    local html =
        '<html xmlns="http://www.w3.org/1999/xhtml">' ..
        '<head><meta http-equiv="Content-Type" content="text/html;charset=utf-8"></head>' .. '<body>' .. '<form action="' .. urlString .. '" method="POST" >'
    for k, v in pairs(params) do
        html = html .. '<input type="hidden" name="' .. k .. '" value="' .. tostring(v) .. '" />'
    end
    html = html .. '</form>' .. '</body>' .. '<script type="text/javascript" language="javascript">' .. 'document.forms[0].submit();' .. '</script>' .. '</html>'
    return html
end

return ActivityWebInfo