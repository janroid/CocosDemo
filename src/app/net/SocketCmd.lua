local SocketCmd = {
    -- socket状态定义(c++)
	SOCKET_STATUS_NON = -1; -- 初始状态
	SOCKET_STATUS_CONNECTING = 0; -- 开始连接
	SOCKET_STATUS_CONNECTED = 1; -- 连接成功
	SOCKET_STATUS_CONNECTFAIL = 2; -- 连接失败
    SOCKET_STATUS_DISCONNECT = 3; -- 连接断开

    -- 服务器类型，解析方式不一样
    SERVER_TYPE_RUNMOUSE = 1; -- 猫鼠游戏
    
    -- 定义socket标识
	SERVER_GAME = g_GetIndex();  -- 房间socket

    -------------------- 自定义数据 ------------------
}

return SocketCmd