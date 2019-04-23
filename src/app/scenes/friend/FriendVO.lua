local FriendConfig = require('FriendConfig')
local FriendVO = class();	

FriendVO.ctor = function(self)
    self.uid             = "";
    self.name            = "";
    self.isSelf          = false;   --是否是自己 	
    self.pid             = "";      --平台id(如:facebook id ) 	
    self.chip            = 0;       --筹码数 
    self.experience      = 0;       --经验值
    self.achievement     = 0;       --成就值 
    self.status          = 0;       --当前状态: 在玩,在线,离线 
    self.vip             = 0;       --vip等级  0为非vip 
    self.isPlatFriend    = false;   --是否为平台好友 
    self.level           = 0;       --等级	
    self.win             = 0;       --胜利场数 	
    self.lose            = 0;       --失败场数
    self.hometown        = "";      --家乡
    self.sex             = "";      --性别 
    self.image           = "";      --头像地址
    self.image_large     = "";      --大头像地址
    self.offLineDays     = 0;       --离线天数
    self.tableName       = "";      --房间名称
    self.tid             = 0;       --所在房间tid
    self.ip              = "";      --所在房间ip
    self.port            = 0;       --所在房间端口
    self.tableType       = 0;       --所在房间类型
    self.tableLevel      = 0;       --所在房间级别
    self.roomFlag        = 0;       --所在房间标志
    self.smallBlind      = 0;       --所在房间小盲
    self.title           = "";      --等级称号
    self.flag            =false;    --好友是否被选中	
    self.winPercent      = 0;       --胜率
    self.isOperate       = false;   --是否已被邀请或召回
    self.isMobile        = false;   --是否在移动设备上登陆
    self.sendChipLimit   = 0;       --可赠送筹码额度
    self.sendChipTimes   = 0;       --可赠送筹码次数
    self.isSitdown       = false;   --是否在房间内坐下
end

FriendVO.dtor = function(self)
end


FriendVO.parse = function(self, item)
    self.uid = item.uid;
    self.name = item.nick;
    self.pid = item.siteid;
    self.chip = tonumber(item.money);
    self.experience = tonumber(item.exp);
    self.achievement = tonumber(item.ach);
    self.status = tonumber(item["type"]);---关键字冲突
    self.vip = tonumber(item.vip);
    if item.fri ~= 2 then  -- 用户类型，1表示牌友，2表示fb好友，0表示没有关系

        self.isPlatFriend = true;
    else
        self.isPlatFriend =  false;
    end             
    self.level = tonumber(item.level);
    self.title = item.title;
    self.win = tonumber(item.win);
    self.lose = tonumber(item.lose);
    self.hometown = item.ht;
    self.sex = item.sex;
    self.image = item.img;
    self.image_large = item.b_picture or item.img;
    self.offLineDays = 0;
    if self.status == FriendConfig.STATUS.AT_PLAY then
        self.tid = tonumber(item.tid);
        self.tableName = item.tn;
        self.ip = item.ip;
        self.port = item.port;
        self.tableType = tonumber(item.tab);
        self.tableLevel = tonumber(item.fld);
        self.roomFlag = tonumber(item.flag);
        self.smallBlind = tonumber(item.sb);
    elseif self.status == FriendConfig.STATUS.OFF_LINE or self.status == nil then
        self.offLineDays = tonumber(item.od);
    end
    self.isSelf = false;
    if item.mobile == 1 then
        self.isMobile = true;
    else
        self.isMobile =  false;
    end
    self.sendChipLimit = tonumber(item.sdchip);
    self.sendChipTimes = tonumber(item.send);
    if item.status == 1 then
        self.isSitdown = false;
    elseif item.status == 2 then
        self.isSitdown = true;
    end
    if item.ispri == 1 then
        self.isPri = true;
        self.mflag = item.flag;
        self.mtid = item.m_tid;
        self.mip = item.m_ip;
        self.mport = item.m_port;
    elseif item.ispri == 0 then
        self.isPri = false;
    end
    if self.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_TOURNAMENT then
        self.mttid = item.mttid;
        self.mttname = item.mttname;
        self.mttstart = item.mttstart;
    end
    self.push = item.pushRecallLimit or 1;
end

FriendVO.isSupportTable = function (self)
    if self.status ~= FriendConfig.STATUS.AT_PLAY  then
        return false;
    end
    local isSupport = false;
    if self.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_PROFESSIONAL then
        isSupport = false;
    elseif self.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_TOURNAMENT then
        isSupport = false;
    elseif self.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_KNOCKOUT then
        isSupport = false;
    elseif self.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_PROMOTION then
        isSupport = false;
    elseif self.tableType == FriendConfig.TABLE_TYPE.ROOM_TYPE_NORMAL
        -- 暂时注释 写房间模块后补充 and RoomFlag.isSupportFlag(self.roomFlag) 
         then
        isSupport = true;
    end
    return isSupport;
end

return FriendVO