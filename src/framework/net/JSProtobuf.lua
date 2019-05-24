-- JSProtobuf.lua
-- Description: protobuf编解码封装

import('Protobuf')

local JSProtobuf = class("JSProtobuf")

function JSProtobuf:ctor( )
    self.m_registerMap = {}
    self.m_configMap = {}
end

--[[
    @desc: pb编码
    author:{author}
    time:2019-05-21 18:42:20
	--@name: GamePb.method
	--@data: 数据(Table)
    @return:
]]
function JSProtobuf:encode(name, data)
    if not name or not data then
        Log.e("JSProtobuf:encode -- name or data is nil")
        return
    end

    if not self.m_configMap[name] then
        Log.e("JSProtobuf:encode -- PBFile not register!")

        return
    end

    local pbMethod = self.m_configMap[name].method

    return protobuf.encode(pbMethod,data)
end

--[[
    @desc: pb解码
    author:{author}
    time:2019-05-21 18:53:31
    --@name: GamePb.method
	--@buf: 待解码数据
    @return:
]]
function JSProtobuf:decode(name, buf)
    if not name or not buf then
        Log.e("JSProtobuf:decode -- name or data is nil")
        return
    end

    if not self.m_configMap[name] then
        Log.e("JSProtobuf:decode -- PBFile not register!")

        return
    end

    local pbMethod = self.m_configMap[name].method

    return protobuf.decode(pbMethod,buf)
end


--[[
    @desc: 注册pb文件
    author:{author}
    time:2019-05-21 18:43:14
    --@pbObj: pb配置文件
    @return:
]]
function JSProtobuf:registerFile(pbObj)
    local filePath = pbObj.S_PATH
    if self.m_registerMap[filePath] then
        return
    end

    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(filePath)
    protobuf.register_file(fullPath)
    self.m_registerMap[filePath] = true

    local config = pbObj.config or {}
    for k,v in pairs(config) do
        self.m_configMap[k] = v
    end
end

function JSProtobuf.unpack(pattern, buffer, length)
    return protobuf.unpack(pattern, buffer, length)
end

function JSProtobuf.pack(pattern, ...)
    return protobuf.pack(pattern, ...)
end

return JSProtobuf