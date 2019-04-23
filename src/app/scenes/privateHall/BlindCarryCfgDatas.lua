--[[--ldoc 数据模型类集合
@module BlindCarryCfgDatas
@author:LoyalwindPeng
 date: 2018-12-28 
]]

-- 数据模型类集合
local BlindCarryCfgDatas = class("BlindCarryCfgDatas")
function BlindCarryCfgDatas:ctor(cfgDatas)
    self:init(cfgDatas)
end

function BlindCarryCfgDatas:clearAllDataLists()
    self.m_dataLists = {}
end

function BlindCarryCfgDatas:init(cfgDatas)
    self:clearAllDataLists()
    self.m_origs = cfgDatas or {}

    for _,cfg in ipairs(cfgDatas) do
        -- 安全起见还是做一下处理
        self.m_dataLists[cfg.field] = self.m_dataLists[cfg.field] or {}
        -- local CfgData = BlindCarryCfg.new(cfg)
        table.insert(self.m_dataLists[cfg.field], cfg)
    end

    -- 排序
    for k, dataList in pairs(self.m_dataLists) do
        table.sort(dataList, function(cfg1, cfg2) 
            return cfg1.smallblind > cfg2.smallblind
        end)
    end
end

function BlindCarryCfgDatas:getDataLists()
    return self.m_dataLists
end

return  BlindCarryCfgDatas