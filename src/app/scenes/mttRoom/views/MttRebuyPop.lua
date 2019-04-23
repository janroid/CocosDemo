--[[--ldoc desc
@module MttRebuyPop
@author CavanZhou

Date   2018-12-24
]]
local MttRebuyAddonPop = require("views.MttRebuyAddonPop")
local MttRebuyPop = class("MttRebuyPop",MttRebuyAddonPop);

function MttRebuyPop:ctor()
	MttRebuyAddonPop.ctor(self);
end

return MttRebuyPop;