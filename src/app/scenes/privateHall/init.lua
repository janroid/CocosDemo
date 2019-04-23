
local SceneConfig = require("config.SceneConfig")

-- 数据包，init中声明外部可访问的信息
local init = {
	PrivateHallPop = require("PrivateHallPop");
	PrivatePopType = g_TableLib.copyTab(SceneConfig.PrivatePopType);
}

return init
