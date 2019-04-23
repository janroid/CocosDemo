-- BYProtobuf.lua
-- Description: protobuf编解码封装

require('protobuf')

local BYProtobuf = {}

BYProtobuf.protobufConfig = {
    -- 格式示例
    -- [key]   = {pb = protoPath, pkg = pkg, requestMsg = 'c2s_Message_Name', responseMsg = 's2c_Message_Name'}
    -- key          表的index，推荐使用server端对应的 包名+方法名
    -- pb           .proto文件使用工具生成的编码
    -- pkg          .proto文件中package的名称
    -- requestMsg   client传给server的protocol对应的message名称
    -- requestMsg   server传给client的protocol对应的message名称
}

BYProtobuf.MSG_TYPE = {
    REQUEST   = 'request',
    RESPONSE  = 'response',
}

-- 将buf编码成对应的protobuf格式
---@param rpcName string  对应配置表中的key
---@param buf table       需要解码的buffer
function BYProtobuf.encode(rpcName, buf)
    local proto = BYProtobuf.getProto(BYProtobuf.MSG_TYPE.REQUEST, rpcName);
    -- 传入消息原型和对应的table格式的数据，返回编码后的buffer。
    -- 如果编码失败，会直接报错。
    local buffer = protobuf.encode(proto, buf);
    return buffer
end

-- 解码protoBuf
---@param rpcName string  对应配置表中的key
---@param buf string       需要解码的buffer
function BYProtobuf.decode(rpcName, buf)
    local proto     = BYProtobuf.getProto(BYProtobuf.MSG_TYPE.RESPONSE, rpcName);
    local msg       = {};
    if proto then
        -- 传入消息原型和buffer，返回解码后的table。
        -- 如果解码失败，会直接报错。
        msg = protobuf.decode(proto,buf);
    end
    return msg
end

BYProtobuf.pbFile = {}

-- 获取对应的proto格式用于编解码
---@param msgType string   用于获取对应的message名称 编码:BYProtobuf.MSG_TYPE.REQUEST，解码:BYProtobuf.MSG_TYPE.RESPONSE
---@param rpcName string  对应配置表中的rpc方法名
function BYProtobuf.getProto(msgType, rpcName)
    local message = BYProtobuf.protobufConfig[rpcName]; -- 通过服务名获得该方法对应的rpc方法名称
    if not message then
        error('unknow funcName :' .. rpcName)
        return
    end
    local msg = msgType .. 'Msg';

    if BYProtobuf.pbFile[message.pb] == nil then
        local pbFile = message.pb; -- pb文件的二进制信息
        local pbFilePath = cc.FileUtils:getInstance():fullPathForFilename(pbFile)    
        local buffer = readProtobufFile(pbFilePath)
        protobuf.register(buffer); -- 注册pb文件
        BYProtobuf.pbFile[message.pb] = true;
    end
    return message[msg];
end

-- 注册自定义的配置表，格式请严格参考BYProtobuf.protobufConfig
---@param config table 自定义的配置表
function BYProtobuf.registerConfig(config)
    if not config then
        return
    end
    for rpcName, v in pairs(config) do
        assert(type(v) == "table","pb配置的格式错误")
        BYProtobuf.protobufConfig[rpcName] = v
    end
end

function BYProtobuf.unpack(pattern, buffer, length)
    return protobuf.unpack(pattern, buffer, length)
end

function BYProtobuf.pack(pattern, ...)
    return protobuf.pack(pattern, ...)
end

return BYProtobuf