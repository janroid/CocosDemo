local ServerManager = class("ServerManager")

local DataCenter = import("DataCenter")

function ServerManager:ctor(receive)
    if not receive then
        Log.d("ServerManager:ctor - receive is nil")
        return
    end

    self.m_receive = receive
    self.m_dataCenter = DataCenter.new()
end



return ServerManager