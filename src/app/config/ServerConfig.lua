local config = {}

config.LOGIN_TYPE = {
	NONE = 0,
	LOGIN = 1,
	REGISTER = 2
}

config.LOGIN_ERR = {
	LGOINSUCC    = 1000; -- 登陆成功
	REGISTERSUCC = 1001; -- 注册成功
	ERRNOUSER    = 1002; -- 无法找到用户
	ERRHAVEUSER  = 1003; -- 账号已存在
	ERRLOGIN     = 1004; -- 用户名或密码错误
	ERRFORBID    = 1005; -- 账户被封
	ERRNULL      = 1006; -- 用户名或密码不能为空
	ERRSHORT     = 1007; -- 用户名或密码太短
}

config.FIELDS = {
	MONEY      = 1;
	EXP        = 2;
	NAME       = 4;
	ICON       = 8;
	PLAYCOUNT  = 64;
	PLAYWIN    = 128;
	PLAYOUT    = 256;
	PLAYCREATE = 512;
	HONOR      = 1024;
	GOLD       = 2048;
	TITLE      = 4096;
	STATUS     = 8192;
}

config.USER_STATUS = {
	NONE   = 0;
	FORBID = 1;
}


return config