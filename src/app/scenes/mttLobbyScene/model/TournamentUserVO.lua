local TournamentUserVO = class();

TournamentUserVO.ctor = function (self)
    self.rank   = 0;
    self.chip   = 0;
    self.uid    = 0;
    self.tid    = 0;
    self.name   = "";
    self.picUrl = "";
end

TournamentUserVO.dtor = function (self)
end

--xml其实是一个table
TournamentUserVO.parseXML = function(xml, index)
    local  tournamentUserVO = TournamentUserVO:create()
    tournamentUserVO.rank = index;
    if xml["cp"] ~= nil then
        tournamentUserVO.chip = tonumber(xml.cp);--当前排名数据
    end
    tournamentUserVO.uid    = tonumber(xml.uid);
    tournamentUserVO.tid    = tonumber(xml.tid);
    tournamentUserVO.name   = tostring(xml.un);
    tournamentUserVO.picUrl = tostring(xml.pic);
    
    return tournamentUserVO;
end
return TournamentUserVO