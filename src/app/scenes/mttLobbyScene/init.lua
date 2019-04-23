
-- 数据包，init中声明外部可访问的信息
local init = {
   	scene        = require("MttLobbyScene");
   	MttHelpPop   = require("MttHelpPop");
   	MTTUtil      = require("MTTUtil");
   	MttDetailPop = require("MttDetailPop");
	MTTListVO    = require(".model.MTTListVO");
	MttManager   = require("MttManager");
	MTTNotice    = require("views.MTTNotify");
	MTTSignupSuccPop = require('.views.MTTSignupSuccPop');
	MTTSignupWayPop = require('.views.MTTSignupWayPop');
}

return init
