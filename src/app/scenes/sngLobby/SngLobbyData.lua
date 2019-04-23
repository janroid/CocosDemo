local SngLobbyData = class("SngLobbyData")

SngLobbyData.MATCH_SNG = 1
SngLobbyData.MATCH_NOT_FOUND = 100

function SngLobbyData:ctor()
    self.m_isLoading = false
    self.m_sngListData = nil
    self.m_dataPool = {}
    self.m_timeoutIdV = {}

    -- self.m_mid               = -1;      --作为比赛的唯一标识 
    -- self.m_type              = 0;       --比赛类型	
    -- self.m_applyCharge       = 0;       --买入费
    -- self.m_serviceCharge     = 0;       --服务费
    -- self.m_applyPoints       = 0;       --买入积分
    -- self.m_isFree            = false;   --是否免费
    -- self.m_playerCount       = 0;       --当前类型淘汰赛总在玩人数
    -- self.m_detailedReward    = {};      --比赛详细奖励 	
    -- self.m_ip                = "";      
    -- self.m_port              = 0;       
    -- self.m_tableNum          = 0;       --几人桌

end

function SngLobbyData:parseData(data)
    local sngData = {}
    sngData.m_tableNum         = tonumber(data.max_num) or 0;
    sngData.m_type             = tonumber(data.ty) or 0;
    sngData.m_applyCharge      = tonumber(data.applyCharge) or 0;
    sngData.m_serviceCharge    = tonumber(data.serviceCharge) or 0;
    sngData.m_applyPoints      = tonumber(data.points) or 0;
    sngData.m_playerCount      = tonumber(data.sit_num) or 0;
    sngData.m_ip               = tostring(data.ip) or "";
    sngData.m_port             = tonumber(data.port) or 0;
    sngData.m_detailedReward   = g_StringUtils.split(data.prize, "/") or {}
    return sngData
end

function SngLobbyData:parseXML(data)
    local xmlData = {}
    xmlData.ranking = tostring(data.rank)
    xmlData.distance = tostring(data.dits)
    xmlData.inCome = tostring(data.inCome)
    xmlData.chain = tostring(data.chain or 0)
    xmlData.prize = tostring(data.prize)
    xmlData.soc = tostring(data.soc)
    return xmlData

end

function SngLobbyData:getSngListData()
    return self.m_sngListData
end

function SngLobbyData:setSngListData(data)
    self.m_sngListData = data
    g_Model:setData(g_ModelCmd.SNG_HALL_CURRENT_MATCH_DATA,self.m_sngListData)
end

function SngLobbyData:getIsLoading()
    return self.m_isLoading
end

function SngLobbyData:setIsLoading(data)
    self.m_isLoading = data
    g_Model:setData(g_ModelCmd.SNG_HALL_IS_LOADING,self.m_isLoading)
end

return SngLobbyData