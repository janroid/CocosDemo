--[Comment]
--赛后用户数据
local MatchUserOutData = class();

MatchUserOutData.ctor = function(self)
    self.ranking    = 0;    --排名
    self.chip       = 0;    --奖励筹码
    self.coalaa     = 0;    --奖励卡拉币
    self.score      = 0;    --奖励积分
    self.exp        = 0;    --预留
    self.reward     = "";   --锦标赛奖励描述
    self.email      = "";   --用户电邮
    self.hasGoods   = false;--是否有实物奖励
    self.propsId    = -1;   --奖励道具id,默认没有
    self.isKnockOut = false;--是不是单桌赛
end

MatchUserOutData.dtor = function(self)
end

MatchUserOutData.refresh = function(self)
    self.ranking = 0;
    self.chip = 0;
    self.coalaa = 0;
    self.score = 0;
    self.exp = 0;
    self.reward = "";
    self.email = "";
    self.hasGoods = false;
    self.propsId = -1;
end
return MatchUserOutData
