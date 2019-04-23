--[Comment]
--用户坐下数据
local UserSitDownData = {};

UserSitDownData.ERROR_SIT_CHIP_NOT_ENOUGH = 0x9102; --筹码不足
UserSitDownData.ERROR_SIT_IP_EQUAL        = 0x9103; --同一IP不能坐下
UserSitDownData.ERROR_SIT_SELF_IS_SITTING = 0x9104;	--自己已经坐下了
UserSitDownData.ERROR_SIT_BUYING          = 0x9105;	--买入不够
UserSitDownData.ERROR_SIT_SEATID          = 0x9106;	--座位id出错
UserSitDownData.ERROR_SIT_IS_HAVE_USER    = 0x9107;	--座位上已经有人了
UserSitDownData.ERROR_SIT_IS_SEATING      = 0x9108;	--用户已经坐下了
UserSitDownData.ERROR_SIT_MONEY_TOO_BIG   = 0x9109;	--钱过大，不能进入新手场
UserSitDownData.ERROR_SIT_MONEY_TOO_POOR  = 0x9110;	--钱不够，不能进入非新手场

UserSitDownData.ctor = function(self)
    self.seatId          = -1;	--用户座位ID
    self.uid             = -1;	--用户ID
    self.name            = "";	--用户名
    self.gender          = "";	--性别
    self.totalChips      = 0;	--总资产
    self.exp             = 0;	--总经验
    self.vip             = 0;	--是否VIP
    self.photoUrl        = "";	--头像url
    self.winRound        = 0;	--用户赢盘数
    self.loseRound       = 0;	--用户输盘数
    self.currentPlace    = "";	--用户所在地
    self.homeTown        = "";	--用户家乡
    self.giftId          = 0;	--用户默认礼物
    self.seatChips       = 0;	--买入坐下筹码数
end

UserSitDownData.dtor = function(self)
end

return UserSitDownData
