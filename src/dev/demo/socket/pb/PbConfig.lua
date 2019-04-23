local pbInfo = "framework/socket/pb/socket.pb";
local pkg = "socket_rpc";
local config = {};

-- RPC服务对应的方法名
config.method = {
	RPC = "socket_rpc.req",
};

-- pb配置
config.protoConfig = {
    [config.method.RPC] = {pb = pbInfo, pkg = pkg, requestMsg = "RpcReq", responseMsg = "RpcRsp"};
};

-- pb协议注册
g_Protobuf.registerConfig(config.protoConfig);

return config;