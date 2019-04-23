--[Comment]
--用户排名数据
local UserRankingData = class();

UserRankingData.ctor = function(self)
    self.count      = 0;--当前人数
    self.ranking    = 0;--当前排名
    self.selfChip   = 0;--当前剩余筹码
    self.differChip = 0;--与前一名的差距
end

UserRankingData.dtor = function(self)
end
return UserRankingData