local PotChip = class("PotChip");
local ChipManager

PotChip.m_quadBatch = nil;--:QuadBatch;
PotChip.m_potChipInfoV = nil;--:Vector.<ChipInfo>;
PotChip.m_chipThick = 0;

PotChip.ctor = function(self, quadBatch)
    ChipManager = require("chipManager.ChipManager")
    self.m_quadBatch = quadBatch;
    self.m_chipThick = ChipManager.CHIP_THICK;
    
    --    AppStatusChangeHandlers.instance.addToActivateHandlers(setPotChipStack);
    self:setPotChipStack();
end

PotChip.setPotChipStack = function(self)
    if (self.m_potChipInfoV) then
        local infoLength = #self.m_potChipInfoV;
        for i=1,infoLength do
            local chip = ChipManager:getChip(self.m_potChipInfoV[i].number);
            --local w,h = chip:getSize();
            --self.m_potChipInfoV[i].x = 0;
            --self.m_potChipInfoV[i].y = -(i-1) * self.m_chipThick;
            --self.m_potChipInfoV[i].alpha = 1;
            chip:setPosition(0, (i-1) * self.m_chipThick);
            --chip:setOpacity(self.m_potChipInfoV[i].alpha);
            self.m_quadBatch:addChild(chip);
        end
    end
end

PotChip.refreshPot = function(self, potChips)
    --回收筹码数据
    ChipManager:recycleChipInfoV(self.m_potChipInfoV);
    self.m_potChipInfoV = ChipManager:takeOutChipInfos(potChips);
    
    --重置QuadBatch，替换筹码堆
    self.m_quadBatch:removeAllChildren();
    self:setPotChipStack();
end

PotChip.refresh = function(self)
    ChipManager:recycleChipInfoV(self.m_potChipInfoV);
    self.m_potChipInfoV = nil;
    self.m_quadBatch:removeAllChildren();
end
return PotChip