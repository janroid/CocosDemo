--[[
    author:{JanRoid}
    time:2019-1-4
    Description: 老虎机数据类
]] 

local SlotInfo = class("SlotInfo")
 
addProperty(SlotInfo, "slotIp")
addProperty(SlotInfo, "slotPort")
addProperty(SlotInfo, "maxBet")  -- 最大额度
addProperty(SlotInfo, "multiBet")  -- 忙注系数
addProperty(SlotInfo, "luckMultiple") -- 幸运牌翻倍数
addProperty(SlotInfo, "luckPoker") -- 幸运牌
addProperty(SlotInfo, "callWins")
addProperty(SlotInfo, "autoPlay") -- 自动玩
addProperty(SlotInfo, "winMoney") -- 上局赢的钱
addProperty(SlotInfo, "betMoney",0) -- 下注额度
addProperty(SlotInfo, "betConfig") -- 下注额度配置


function SlotInfo:init(info)
    if not info or next(info) == nil then
        Log.e("SlotInfo.init data is nil!")
        return
    end
    
    self:setSlotIp(getStrFromTable(info, "proxyip"))
    self:setSlotPort(getNumFromTable(info, "TIGER_PORT", 0))
    self:setMaxBet(getNumFromTable(info,"TIGER_MAX",0))
    self:setMultiBet(getNumFromTable(info,"TIGER_SB",1))
end


return SlotInfo