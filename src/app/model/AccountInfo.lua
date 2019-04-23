--[[
    author:{JanRoid}
    time:2018-12-3
    Description: 玩家账号信息
]] 
local AccountInfo = {}

AccountInfo.S_LOGIN_FROM = {
    FACEBOOK = 1, -- facebook登录
    GUEST    = 2, -- 游客登录
    EMAIL    = 3, -- 邮箱登录
}

function AccountInfo:init(data)
    Log.d("AccountInfo ",data)
    Log.d("AccountInfo ",data.firstin)
    self.m_id = data.uid -- 玩家mid/uid
    self.m_nickname = data.nick -- 玩家昵称
    self.m_sex = data.sex or "m"-- 玩家性别 f:女  m:男
    self.m_loginFrom = data.from -- 登录来源 LOGIN_FROM.FACKBOOK = 1; LOGIN_FROM.GUEST = 2; LOGIN_FROM.EMAIL = 3;
    self.m_smallPic = data.s_picture -- 玩家头像 小
    self.m_middlePic = data.m_picture -- 玩家头像 中
    self.m_bigPic = data.b_picture -- 玩家头像 大
    self.m_vip = data.vip -- VIP 0:无vip 1:铜 2：银 3：金 4：钻
    self.m_vipExpire = data.vip_expire -- VIP过期时间
    self.m_cdnUrl = data.CNDURL -- cdn服务器地址

    self.m_status = data.status -- 等于3为禁言

    self.m_loginReward = g_JsonUtil.decode(data.loginReward) 

    self.m_coalaa = data.coalaa -- 
    self.m_money = data.money -- 籌碼
    self.m_experience = data.experience -- 經驗值
    self.m_level = data.level  -- 等級
    self.m_maxmoney = data.maxmoney -- 最高资产
    self.m_maxaward=  data.maxaward  --最大赢取 
    self.m_bestpoker = data.bestpoker  --  最佳牌型 "84a3a1a1535"
    self.m_winNum = data.win    -- 赢牌场数
    self.m_loseNum = data.lose  -- 输牌场数
    self.m_mtkey = data.mtkey  -- key
    if self.m_winNum and self.m_loseNum then
        local totalNum = self.m_winNum + self.m_loseNum
        if totalNum <= 0 then 
            self:setWinRate(0)
        else
            self:setWinRate(self.m_winNum/totalNum)
        end
    end
    self:setTreasureSb(data.treasureSb)
    self:setRoomAct(data.RoomAct)
    self:setGiftDownloadUrl(data.GIFT_ROOT_LUA)
    self:setGiftSWFURL(data.SWFURL)
    self:setUserUseGiftId(data.user_gift)
    self.m_callbackReward = data.CALLBACK_REWARD -- 召回好友奖励
    self.m_callbackCgiRoot = data.CALLBACK_CGI_ROOT -- 召回专属url
    self.m_blowup = tonumber(data.blowup ) -- FB邀请好友奖励
    self.m_payConfigAndroid = data.PAY_CONF_LUA
    self.m_channel = data.channel
    self.m_userPropsUrl = data.PROPS_ROOT_LUA
    self.m_PROPSURL = data.PROPSURL
    self.m_aTicket = data.aTicket 
    self.m_isSupportPaymentCenter = data.isSupportPaymentCenter  -- 是否支持支付中心 1支持
    self.m_score = tonumber(data.score) -- 用户积分
    self.m_title = data.title -- 称号
    self.m_siteuid = data.siteuid -- 站点uid
    self.m_userGift = data.user_gift -- 禮物
    self.m_bankMoney = data.bank_money -- 保險箱钱
    self.m_defaultHeguan = data.defaultHeguan

    self.m_superLottoSB = data.superLottoSB

    self.m_hallIcon = data.hallIcon -- 活动信息(url, icon, open)
    self.m_CGIRoot = data.CGI_ROOT -- 购买商品后的发货路径
    self.m_langfix = data.langfix -- 语言前缀
    self.m_today = data.today or 0
    self.m_broadcastIp = data.BROADCAST_IP
    self.m_broadcastPort = data.BROADCAST_PORT
    self.m_newCourse = data.newCourse -- 新手教程奖励
    self.m_firstin = tonumber(data.firstin) or 0 -- 是否第一次进入游戏 1：是
    self.m_loginRewardStep = data.loginRewardStep or -1 -- 新手奖励领取多少天了
    self.m_dollOpen = data.dollOpen --玩偶玩牌收集
    self.m_diamond = data.diamond --钻石大赢家统计钻石
    self.m_itemDiscount = data.itemDiscount or {}
    self.m_localpayoff = data.localpayoff or 0
    self.m_freeChipList = data.freeChipList or {} --游戏小弹框要显示的内容
    
    self.m_cancelMoney = data.CANCEL_MONEY 
    self.m_tableMoneyLimit = data.TABLE_MONEY_LIMIT
    self.m_chujichangLimit = data.chujichang_limit 
    self.m_cancelLevelLimit= data.CANCEL_LEVEL_LIMIT 
    
    if data.from == 2 and data.email == 1 and DEBUG == 0 then
        NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_GUEST_BINDED_EMAIL, {bindedEmail = true})
        g_EventDispatcher:dispatch(g_SceneEvent.UPGRADE_ACCOUNT_HIDE_UPGRADE_BTN)
        g_AppManager.m_guestBindedEmail = true
    end
end

function AccountInfo:reset()
    self.m_id = nil -- 玩家mid/uid
    self.m_nickname = nil -- 玩家昵称
    self.m_sex = nil -- 玩家性别 f:女  m:男
    self.m_loginFrom = nil -- 登录来源 LOGIN_FROM.FACKBOOK = 1; LOGIN_FROM.GUEST = 2; LOGIN_FROM.EMAIL = 3;
    self.m_smallPic = nil -- 玩家头像 小
    self.m_middlePic = nil -- 玩家头像 中
    self.m_bigPic = nil -- 玩家头像 大
    self.m_vip = nil -- VIP
    self.m_vipExpire = nil -- VIP过期时间
    self.m_cdnUrl = "" -- cdn服务器地址
    self.m_coalaa = nil
    self.m_money = nil
    self.m_experience = nil
    self.m_level = nil
    self.m_maxmoney = nil
    self.m_maxaward = nil
    self.m_bestpoker = nil
    self.m_winNum  = nil
    self.m_loseNum = nil
    self.m_callbackReward = 0
    self.m_callbackCgiRoot = nil
    self.m_blowup = 0
    self.m_payConfigAndroid = nil
    self.m_channel = nil
    self.m_userPropsUrl = nil
    self.m_PROPSURL = nil
    self.m_aTicket = nil
    self.m_isSupportPaymentCenter = nil
    self.m_score = 0
    self.m_giftDownloadUrl = nil
    self.m_giftSWFURL = nil
    self.m_UserUseGiftId = nil
    self.m_loginReward = nil
    self.m_hallIcon = nil
    self.m_CGIRoot = nil
    self.m_langfix = nil
    self.m_broadcastIp = nil
    self.m_broadcastPort = nil
    self.m_dollOpen = nil
    self.m_diamond= nil
    self.m_isGetRegistReward = nil
    self.m_itemDiscount = nil
    self.m_localpayoff = nil
    self.m_freeChipList = nil
    self.m_cancelMoney = nil 
    self.m_tableMoneyLimit = nil 
    self.m_chujichangLimit = nil 
    self.m_cancelLevelLimit = nil 
end




function AccountInfo:isForbiddenWords(id)
    return self.m_status == 3
end

-- 玩家mid/uid
function AccountInfo:setId(id)
    self.m_id = id
end
function AccountInfo:getId()
    return self.m_id
end

-- 玩家rank 房间个人信息缓存,登录未返回
function AccountInfo:setRank(rank)
    self.m_rank = rank
end
function AccountInfo:getRank()
    return self.m_rank or ""
end

-- 玩家昵称
function AccountInfo:setNickname(nickname)
    self.m_nickname = nickname
end
function AccountInfo:getNickName()
    return self.m_nickname
end

-- 玩家性别 f:女  m:男
function AccountInfo:setSex(sex)
    self.m_sex = sex or "m"
end
function AccountInfo:getSex()
    return self.m_sex
end

-- 登录来源 LOGIN_FROM_FACKBOOK = 1; LOGIN_FROM_GUEST = 2; LOGIN_FROM_EMAIL = 3;
function AccountInfo:setLoginFrom(from)
    self.m_loginFrom = from
end
function AccountInfo:getLoginFrom()
    return self.m_loginFrom
end

-- 玩家头像 小
function AccountInfo:setSmallPic(smallPic)
    self.m_smallPic = smallPic
end
function AccountInfo:getSmallPic()
    return self.m_bigPic
end

-- 玩家头像 中
function AccountInfo:setMiddlePic(middlePic)
    self.m_middlePic = middlePic
end
function AccountInfo:getMiddlePic()
    return self.m_bigPic
end

-- 玩家头像 大
function AccountInfo:setBigPic(bigPic)
    self.m_bigPic = bigPic
end
function AccountInfo:getBigPic()
    return self.m_bigPic
end

-- VIP
function AccountInfo:setVip(vip)
    self.m_vip = vip
    g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_DATA)
end
function AccountInfo:getVip()
    return self.m_vip
end
-- VIP过期时间
function AccountInfo:setVipExpire(vipExpire)
    self.m_vipExpire = vipExpire
end
function AccountInfo:getVipExpire()
    return self.m_vipExpire
end

function AccountInfo:setGiftDownloadUrl(url)
    self.m_giftDownloadUrl= url
end
function AccountInfo:getGiftDownloadUrl()
    return self.m_giftDownloadUrl
end

function AccountInfo:setTreasureSb(v)
    self.m_treasureSb= v
end
function AccountInfo:getTreasureSb()
    return self.m_treasureSb
end

function AccountInfo:setRoomAct(v)
    self.m_roomAct= v
end
function AccountInfo:getRoomAct()
    return self.m_roomAct
end

function AccountInfo:setGiftSWFURL(url)
    self.m_giftSWFURL= url
end
function AccountInfo:getGiftSWFURL()
    return self.m_giftSWFURL
end
-- 當前使用的禮物
function AccountInfo:setUserUseGiftId(id)
    self.m_UserUseGiftId= tonumber(id)
end
function AccountInfo:getUserUseGiftId()
    return self.m_UserUseGiftId
end

function AccountInfo:setCDNUrl(url)
    self.m_cdnUrl = url
end
function AccountInfo:getCDNUrl()
    return self.m_cdnUrl
end

-- 玩家克拉币
function AccountInfo:getUserCoalaa()
    return self.m_coalaa
end

function AccountInfo:setUserCoalaa(coalaa)
    self.m_coalaa = coalaa
end

-- 玩家筹码
function AccountInfo:getMoney()
    return self.m_money or 0
end

function AccountInfo:setMoney(money)
    self.m_money = money
    g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_DATA)
end

-- 玩家經驗值
function AccountInfo:getUserExp()
    return self.m_experience
end

function AccountInfo:setUserExp(experience)
    self.m_experience = experience
end

-- 玩家等级
function AccountInfo:getUserLevel()
    return self.m_level
end

function AccountInfo:setUserLevel(level)
    self.m_level= level
    g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_LEVEL)
end

-- 玩家最高资产
function AccountInfo:getMaxMoney()
    return self.m_maxmoney
end

function AccountInfo:setMaxMoney(maxmoney)
    self.m_maxmoney = maxmoney
end

-- 玩家最大赢取
function AccountInfo:getMaxAward()
    return self.m_maxaward
end

function AccountInfo:setMaxAward(maxaward)
    self.m_maxaward = maxaward
end


-- 玩家最佳牌型
function AccountInfo:getBestPoker()
    return self.m_bestpoker
end

function AccountInfo:setBestPoker(bestpoker)
    self.m_bestpoker = bestpoker
end

-- 玩家胜率
function AccountInfo:getWinRate()
    return  self.m_winRate
end

function AccountInfo:setWinRate(winRate)
    self.m_winRate = winRate
end

function AccountInfo:getBankMoney()
    return self.m_bankMoney
end

function AccountInfo:setBankMoney(bankMoney)
    self.m_bankMoney = bankMoney
end

function AccountInfo:getBankToken()
    return self.m_bankToken
end

function AccountInfo:setBankToken(bankToken)
    self.m_bankToken = bankToken
end

--- 保险箱是否设置密码
function AccountInfo:getIsSetBankPassword()
    return self.m_isSetBankPassword
end

function AccountInfo:setIsSetBankPassword(isSetBankPassword)
    self.m_isSetBankPassword = isSetBankPassword
end

-- 召回好友奖励
function AccountInfo:setCallbackReward(reward)
    self.m_callbackReward = reward
end
function AccountInfo:getCallbackReward()
    return self.m_callbackReward
end

-- 召回专属url
function AccountInfo:setCallbackCgiRoot(url)
    self.m_callbackCgiRoot = url
end
function AccountInfo:getCallbackCgiRoot()
    return self.m_callbackCgiRoot
end

function AccountInfo:setBlowup(blowup)
    self.m_blowup = blowup
end
function AccountInfo:getBlowup()
    return self.m_blowup
end

function AccountInfo:getPayConfigAndroid()
    return self.m_payConfigAndroid
end

function AccountInfo:setPayConfigAndroid(payConfigAndroid)
    self.m_payConfigAndroid = payConfigAndroid
end

function AccountInfo:getChannel()
    return self.m_channel
end

function AccountInfo:setChannel(channel)
    self.m_channel = channel
end

function AccountInfo:getATicket()
    return self.m_aTicket
end
function AccountInfo:setATicket(aTicket )
    self.m_aTicket = aTicket 
end

function AccountInfo:getPropsUrl()
    return self.m_PROPSURL
end
function AccountInfo:setPropsUrl(PROPSURL)
    self.m_PROPSURL = PROPSURL
end

function AccountInfo:getUserPropUrl()
    return self.m_userPropsUrl
end

function AccountInfo:setUserPropUrl(userPropsUrl)
    self.m_userPropsUrl = userPropsUrl
end

function AccountInfo:getIsSupportPaymentCenter()
    return self.m_isSupportPaymentCenter
end

function AccountInfo:setIsSupportPaymentCenter(isSupportPaymentCenter)
    self.m_isSupportPaymentCenter = isSupportPaymentCenter
end

-- 用户积分
function AccountInfo:setScore(score)
    self.m_score = score
end
function AccountInfo:getScore()
    return self.m_score
end

-- 称号
function AccountInfo:setTitle(title)
    self.m_title = title
end
function AccountInfo:getTitle()
    return self.m_title
end

-- 站点uid
function AccountInfo:setSiteuid(siteuid)
    self.m_siteuid = siteuid
end

function AccountInfo:getSiteuid()
    return self.m_siteuid
end

function AccountInfo:setmtkey(mtkey)
    self.m_mtkey = mtkey
end

function AccountInfo:getmtkey()
    return self.m_mtkey
end

function AccountInfo:setUserGift(userGift)
    self.m_userGift = userGift
end

function AccountInfo:getUserGift()
    return self.m_userGift
end

function AccountInfo:setBankMoney(bankMoney)
    self.m_bankMoney = bankMoney
end

function AccountInfo:getBankMoney()
    return self.m_bankMoney
end

function AccountInfo:getLoginReward()
    return self.m_loginReward
end

function AccountInfo:setLoginReward(loginReward)
    self.m_loginReward = loginReward
end

function AccountInfo:setDefaultHeguan(heguan)
    self.m_defaultHeguan = heguan
end

function AccountInfo:getDefaultHeguan()
    return self.m_defaultHeguan 
end

function AccountInfo:getHallIcon()
    return self.m_hallIcon or {}
end

function AccountInfo:getCGIRoot()
    return self.m_CGIRoot
end

function AccountInfo:getLangFix()
    return self.m_langfix
end

function AccountInfo:getToday()
    return tonumber(self.m_today) or 0
end

function AccountInfo:setBroadCastIp(ip)
    self.m_broadcastIp = ip
end

function AccountInfo:getBroadCastIp()
    return self.m_broadcastIp
end

function AccountInfo:setBroadCastPort(port)
    self.m_broadcastPort = port
end

function AccountInfo:getBroadCastPort()
    return self.m_broadcastPort 
end

function AccountInfo:getNewCourse()
    return self.m_newCourse
end
function AccountInfo:setNewCourse(newCourse)
    self.m_newCourse = newCourse
end

function AccountInfo:getFirstIn()
    return self.m_firstin
end
function AccountInfo:setFirstIn(firstIn)
    self.m_firstin = firstIn 
end

function AccountInfo:getLoginRewardStep()
    return self.m_loginRewardStep
end
function AccountInfo:setLoginRewardStep(step)
    self.m_loginRewardStep = step
end

function AccountInfo:setDollOpen(open)
    self.m_dollOpen = open
end

function AccountInfo:getDoolOpen(open)
    return self.m_dollOpen
end

function AccountInfo:setDiamond(diamond)
    self.m_diamond = diamond
end

function AccountInfo:getDiamond()
    return self.m_diamond
end

function AccountInfo:getItemDiscount()
    return self.m_itemDiscount
end
function AccountInfo:setItemDiscount(itemDiscount)
    self.m_itemDiscount = itemDiscount
end

function AccountInfo:getLocalpayoff()
    return self.m_localpayoff
end
function AccountInfo:setLocalpayoff(itemDiscount)
    self.m_localpayoff = itemDiscount
end

-- 是否已領取當日註冊獎勵
function AccountInfo:isGetRegistReward()
    return self.m_isGetRegistReward
end
function AccountInfo:setIsGetRegistReward(isGetRegistReward)
    self.m_isGetRegistReward = isGetRegistReward
end
function AccountInfo:getFreeChipList()
    return self.m_freeChipList
end
function AccountInfo:setFreeChipList(freeChipList)
    self.m_freeChipList = freeChipList
end

function AccountInfo:getSuperLottoSb()
    return self.m_superLottoSB or 0
end

function AccountInfo:getCancelMoney()
    return self.m_cancelMoney
end

function AccountInfo:getTableMoneyLimit()
    return self.m_tableMoneyLimit
end

function AccountInfo:getChujichangLimit()
    return self.m_chujichangLimit
end

function AccountInfo:getCancelLevelLimit()
    return self.m_cancelLevelLimit
end

return AccountInfo