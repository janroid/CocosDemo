
-- 数据包，init中声明外部可访问的信息
local init = {
	SafeBoxPop = require(".SafeBoxPop");
	SafeBoxSetPasswordPop = require(".SafeBoxSetPassword.SafeBoxSetPasswordPop");
	SafeBoxPasswordPop = require(".SafeBoxPassword.SafeBoxPasswordPop");
}

return init
