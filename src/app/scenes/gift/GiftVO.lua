local GiftVO = class();
GiftVO.ctor = function(self, tab)
    tab = tab or {}
    self.id         = tostring(tab.b or "");--id
    self.name       = tostring(tab.c or "");--名称  如果字符不为空就表示赠送   如果为空表示自己购买
    self.expire     = tonumber(tab.h or 0 );--有效期
    self.price      = tonumber(tab.e or 0 );--价格
    self.tag        = tostring(tab.f or "");--类型：1 精品 2 礼物 3 节日 4 其他 5娱乐
    self.type       = tostring(tab.d or "");--购买方式： 1 游戏币购买 2卡拉币购买
    self.itemTag    = tostring(tab.g or "");--礼物特殊标记  0 空  1 new 2 hot
    self.time       = 0;                    --获得时间
    self.giftType   = ""                    --礼物
    self.isOwn      = false;                --是否拥有
end

GiftVO.dtor = function(self)
end

return GiftVO