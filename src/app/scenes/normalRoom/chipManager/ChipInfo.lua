local ChipInfo = class("ChipInfo")

ChipInfo.ctor = function(self)
    self.x = 0;--筹码x坐标
    self.y = 0;--筹码y坐标
    self.alpha = 1;--透明度
    self.number = 0;--筹码编号（1~6）
end
return ChipInfo