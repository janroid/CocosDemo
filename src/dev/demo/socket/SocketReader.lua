--[[
    接收socket消息
]]
local pbConfig = require("pb.PbConfig");

local SocketReader = class("SocketReader");
BehaviorExtend(SocketReader);

function SocketReader:ctor(config)
    self.socketConfig = config;
    -- local behaviors = checktable(config.behaviorConfig);
    -- -- 绑定自定义组件
    -- local bevMap = checktable(behaviors.socketReader);
    -- for k,v in pairs(bevMap) do
    --     self:bindBehavior(v);
    -- end
end

function SocketReader:cleanup()
    self:unBindAllBehavior(); -- 删除绑定的组件
end

-- 读取socket数据包
function SocketReader:readPacket(bodyBuf)
    local result,data;
    -- local listeners = checktable(self:getReadLinsteners());
    -- local func = listeners[cmd];
    -- if func and self[func] then
    --     data = self[func](self, self.mReadPacket, cmd);
    -- else
        data = self:readPbPacket(bodyBuf);
    -- end
    data = checktable(data);
    return data;
end

-- 解析pb协议
--[[
    第一位：svr方法名
    第二位：pb的buffer
    第三位：ext，table格式
]]
function SocketReader:readPbPacket(bodyBuf)
    local data = g_Protobuf.decode(pbConfig.method.RPC,bodyBuf); -- 解析sockt pb内容
    local msg  = g_Protobuf.decode(data.rpc,data.body); -- 解析业务pb内容
    local info = {rpc = data.rpc, msg = msg};
    return info;
end

return SocketReader;