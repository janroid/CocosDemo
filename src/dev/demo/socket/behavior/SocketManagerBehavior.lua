--[[
监听业务服务收到的socket消息
@module SocketManagerBehavior
@author FuYao

Date   2018-10-30
]]

---对外导出接口
local exportInterface = {
    "dispatchReceiveMsg";
};

---对外导出属性
local exportProperties = {
};

local SocketManagerBehavior = class("SocketManagerBehavior",BehaviorBase)
SocketManagerBehavior.className_  = "SocketManagerBehavior";

SocketManagerBehavior.eventFuncMap =  {
};

function SocketManagerBehavior:ctor()
    SocketManagerBehavior.super.ctor(self, "SocketManagerBehavior", nil, 1);
    self.exportProperties_ = clone(exportProperties);
    self:registerEvent();
end

function SocketManagerBehavior:dtor()
	self:unRegisterEvent();
end

-- 组件的方法绑定到object
function SocketManagerBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]), true);
    end 
end

-- object解绑组件的方法
function SocketManagerBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end 
end

function SocketManagerBehavior:getExportProperties()
    return self.exportProperties_
end

function SocketManagerBehavior:clearExportProperties()
    self.exportProperties_ = {}
end

-- 组件重置
function SocketManagerBehavior:reset(object)

end

---注册监听事件
function SocketManagerBehavior:registerEvent()
    if self.eventFuncMap then
        for k,v in pairs(self.eventFuncMap) do
            assert(self[v],"配置的回调函数不存在")
            g_EventDispatcher:register(k,self,self[v])
        end
    end
end

---取消事件监听
function SocketManagerBehavior:unRegisterEvent()
    if g_EventDispatcher then
        g_EventDispatcher:unRegisterAllEventByTarget(self)
    end 
end

-- 广播收到的socket消息
function SocketManagerBehavior:dispatchReceiveMsg(obj,msgData)
    local rpc = msgData.rpc;
    local data = self:_analyseData(msgData.msg);
    dump(data,"收到的socket消息-------------")
    g_EventDispatcher:dispatch(rpc,data);
end

-- 解析pb数据，过滤__message内容
function SocketManagerBehavior:_analyseData(data)
    if g_TableLib.isTable(data) then
        data = checktable(data);
        local temp = {};
        for k, v in pairs(data) do
            if v ~= nil and k~="___message" then 
                if type(v) == "table" then
                    temp[k] = self:_analyseData(v);
                elseif type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                    temp[k] = v;
                else
                    dump(data,"svr返回了异常的数据类型");
                end
            end
        end
        return temp;
    else
        return data;
    end
end

return SocketManagerBehavior;