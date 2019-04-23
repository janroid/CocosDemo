--[[
    大厅的socket消息头格式
]]

local struct = import("framework.utils").struct;
local HeadBehavior = class("HeadBehavior",BehaviorBase)
HeadBehavior.className_  = "HeadBehavior";

function HeadBehavior:ctor()
    HeadBehavior.super.ctor(self, "HeadBehavior", nil, 1)
end

function HeadBehavior:dtor()

end

local ver = 1; -- 协议版本号

---对外导出接口
local exportInterface = {
    "onWriteHead",
    "onReadHead",
    "getHeadConfig",
}

function HeadBehavior:bind(object)
    for i,v in ipairs(exportInterface) do
        object:bindMethod(self, v, handler(self, self[v]),true);
    end
end

function HeadBehavior:unBind(object)
    for i,v in ipairs(exportInterface) do
        object:unbindMethod(self, v);
    end
end

---对外暴露的接口
function HeadBehavior:onWriteHead(object,byteWrite,bodyLen,headConfig)
    byteWrite:writeByte(string.byte('R')); -- rpc协议类型标记
    byteWrite:writeByte(string.byte('P'));
    byteWrite:writeByte(string.byte('C'));
    byteWrite:writeByte(1)--self:getHeadConfig().ver); -- 协议版本号
    byteWrite:writeShort(bodyLen); -- 设置body长度
end

---对外暴露的接口
function HeadBehavior:onReadHead(object,readObj,headConfig)
    local R = readObj:readByte();
    local P = readObj:readByte();
    local C = readObj:readByte();
    local ver = readObj:readByte();
    local len = readObj:readShort(); -- 获取body的长度
    return len;
end

-- 获取消息头的定义
function HeadBehavior:getHeadConfig()
    return {len = 6, ver = 1};
end

function HeadBehavior:reset(object)

end

return HeadBehavior;
