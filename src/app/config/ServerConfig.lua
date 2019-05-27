local config = {}

config.LOGIN_TYPE = {
	NONE = 0,
	LOGIN = 1,
	REGISTER = 2
}

config.LOGIN_ERR = {
	LGOINSUCC    = 1000 -- 登陆成功
	REGISTERSUCC = 1001 -- 注册成功
	ERRNOUSER    = 1002 -- 无法找到用户
	ERRHAVEUSER  = 1003 -- 账号已存在
	ERRLOGIN     = 1004 -- 用户名或密码错误
	ERRFORBID    = 1005 -- 账户被封
	ERRNULL      = 1006 -- 用户名或密码不能为空
}

return config