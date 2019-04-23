local MTTListVO = class();

MTTListVO.ctor = function (self)
    self.mid = 0; --比赛场次ID
    self.name = ""; --比赛场次名称
    self.state = 0;--1报名中 2进行中 3已结束
    self.time = 0; --比赛开始时间戳
    self.delay = 0; --延迟进入时间，秒
    self.beftime = 0; --提前进入时间 单位秒
    self.now = 0; --现在时间时间戳
    self.img = ""; --图片
    self.num = 0; --报名人数
    self.ip = "";
    self.port = "";
    self.rebuy = 0; --支持rebuy  0否 1是
    self.addon = 0; --支持addon  0否 1是
    self.chips = ""; --报名费-筹码【报名费+服务费】以竖线隔开
    self.coalaa = ""; --报名费-卡拉币【报名费+服务费】以竖线隔开
    self.point = 0; --报名费-积分
    self.ticketType = 0; --门票类型
    self.btn = 0; --按钮的状态1等待开始 2未开放  3报名 4取消报名 5进入 6观看 7结果
    self.mtype = 0; --比赛类型 0日赛 1周赛  2月赛	
    self.signup = ""; --报名方式 多个以逗号隔开，数字顺序显示报名方式  6:免费,4:参赛券,1:筹码,3:积分,2:卡拉币
    self.sdesc = "";--'筹码1000或者报名卡', 报名费用
    self.prize = "";--[1,2],1保底  2动态奖池逗号隔开
    self.fixed = 0;--保底奖池
    self.rate = "";--获奖人数比例
    self.init = 0;--初始盲注
    self.upblind = {};--涨盲列表
    self.rebuyMax = 0;--可以rebuy最多次数
    self.addonMax = 0; --可以addon最多次数
    self.opentime = 0; --赛前开放时间 单位小时
    self.light = 0;--热门赛事  1是 0否
    self.push = false;
    self.max_num = 0;--最多参赛人数
    self.min_num = 0;--最少参赛人数
    self.dynamic = 0;--动态奖池类型 0无动态奖池  1报名费  2rebuy+addon  3报名费+rebuy+addon
end

MTTListVO.dtor = function (self)
end

MTTListVO.parseData = function(value)
    local vo = MTTListVO:create()
    if not g_TableLib.isEmpty(value) then
        for k,v in pairs(value) do
            if(vo[k] ~= nil) then
                vo[k] = value[k];
            end
        end
    end
    return vo;
end

return MTTListVO