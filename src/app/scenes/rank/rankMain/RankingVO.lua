--[Comment]
--排行榜值对象
local RankingVO = class();
RankingVO.ctor = function(self, data, types, index,isfriendData)
    types                   = types or 0;
    self.m_index            = 0;    --排名
    self.m_uid              = "";   --用户ID
    self.m_chipTotal        = 0;	--筹码数
    self.m_siteid           = "";	--facebook id
    self.m_nick             = "";   --名字
    self.m_img              = "";	--头像图片
    self.m_levelName        = "";   --等级称号
    self.m_level            = 1;	--等级
    self.m_winPercent       = "";   --胜率
    self.m_upOrDown         = "";	--上升还是下降
    self.m_friendRanking    = 0;    --好友中的排名
    self.m_ach              = 0;    --玩家成就
    self.m_ip               = "";   -- ip,port用于玩家追踪
    self.m_port             = "";
    self.m_tid              = "";
    self.m_score            = 0;    --玩家mtt积分
    self.m_exp              = 0
    
    if not g_TableLib.isEmpty(data) then
        self.m_index        = index;
        self.m_uid          = data.uid;
        self.m_chipTotal    = self:__chipTotal(data, types,isfriendData);
        self.m_siteid       = string.format("%.0f", data.siteid or 0);
        self.m_nick         = data.nick;
        self.m_img          = data.img;
        self.m_levelName    = data.title or "";
        self.m_level        = data.level or 1;
        self.m_winPercent   = self:__winPercent(data, types);
        self.m_upOrDown     = self:__upOrDown(data);
        self.m_ach          = data.ach or 0;
        self.m_ip           = data.ip or "";
        self.m_port         = data.port or "";
        self.m_tid          = data.tid or "";
        self.m_score        = tonumber(data.score) or 0;
        self.m_exp          = data.exp
    end
end

RankingVO.__chipTotal = function(self, data, types,isfriendData)  --為嘛({["mod"] = "friend",["act"] = "list"}和["mod"] = "rank", ["act"] = "main"}返回的数据结构不一样，chip的key一个是score一个是money？
    local chipTotal = 0;
    isfriendData = isfriendData or 0;
    if types == 0 then
        if isfriendData == 1 then
           chipTotal = data.money;
        else
           chipTotal = data.score ~= nil and tonumber(data.score);
        end
        
    elseif types == 1 then
        chipTotal = data.level;
    elseif types == 2 then
        chipTotal = data.ach;
    elseif types == 3 then
        chipTotal = tonumber(data.score);
    end
    return chipTotal;
end

RankingVO.__upOrDown = function(self, data)
    local upOrDown = 0;
    if data.stat == 1 then
        upOrDown = "up";
    else
        upOrDown = (data.stat == -1) and "down" or ""; 
    end
    return upOrDown;
end


RankingVO.__winPercent = function(self, data)
    local winPercent = "0";
    if data.win ~= nil and data.lose ~= nil then
        local total = (data.win + data.lose);
        if total ~= 0 then
            winPercent = string.format("%d", data.win * 100 / (data.win + data.lose));
        else
            winPercent = "0";
        end
    end
    return winPercent;
 end
 return RankingVO