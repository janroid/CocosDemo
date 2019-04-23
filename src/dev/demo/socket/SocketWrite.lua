--[[
    发送socket消息
]]
local pbConfig = require("pb.PbConfig");

local SocketWriter = class("SocketWriter");
BehaviorExtend(SocketWriter);

function SocketWriter:ctor(config)
    self.socketConfig = config;
    -- 绑定自定义组件
    -- local behaviors = checktable(config.behaviorConfig);
    -- local bevMap = checktable(behaviors.socketWrite);
    -- for k,v in pairs(bevMap) do
    --     if typeof(v,BehaviorBase) then
    --         self:bindBehavior(v);
    --     else
    --         error("SocketWriter中组件定义错误")
    --     end
    -- end
end

function SocketWriter:cleanup()
    self:unBindAllBehavior(); -- 删除绑定的组件
end

-- 组装发送的socket消息
function SocketWriter:writePacket(info)
    info = checktable(info);
    -- local result,data;
    -- local listeners = checktable(self:getWriteLinsteners());
    -- local func = listeners[cmd];
    -- if func and self[func] then
    --     data = self[func](self,cmd,self.mOutPacket,info);
    -- else
    --     if _DEBUG then
    --         data = self:writePbPacket(info);
    --     else
    --         result,data = pcall(self.writePbPacket,self,info);
    --     end
    -- end
    local data = self:writePbPacket(info);
    return data;
end

-- 解析pb协议
function SocketWriter:writePbPacket(info)
    local data = "";
    if info.rpc and info.param then
        local body_buf = {};
        local rpc = info.rpc;
        local param = info.param;
        local ext = tostring(info.ext) or "";
        local buffer = g_Protobuf.encode(rpc, param); -- 业务pb内容
        local temp = {
            rpc = rpc,  --第一位：rpc方法名
            body = buffer, -- 第二位：pb的buffer
            ext = ext,-- 第三位：扩展字段
        };
        data = g_Protobuf.encode(pbConfig.method.RPC,temp); -- 封装body
    else
        error("发送的socket消息格式错误");
    end
    return data;
end

return SocketWriter;
