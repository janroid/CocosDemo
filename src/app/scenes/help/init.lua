-- local view = require("mainview.helpContainerView")
local config = require("config")
local viewExport = {"move","addTo"}

-- local function createView(...)
-- 	local instance = view:create(...)
-- 	local exportViewInstance = class("exportViewInstance")
-- 	for i,v in ipairs(viewExport) do
-- 		exportViewInstance[v] = function(_,...)
-- 			local ret1,ret2,ret3 = instance[v](instance,...)
-- 			if ret1 == instance then
-- 				ret1 = exportViewInstance
-- 			end
-- 			return ret1,ret2,ret3
-- 		end
-- 	end
	
-- 	return exportViewInstance
-- end

local init = {
	-- createView = createView,
	HelpPop = require("mainview.helpContainerView");
	ShowType = config.showType
};

return init;