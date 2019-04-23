--[[
	该场景下需要配置的模块
]]
local PrivatePopType = {
	InputPassword     = 1; -- 输入密码
	MotifyPassword    = 2; -- 修改密码
	CreatePrivateRoom = 3; -- 创建私人房间
	CreateSuccess     = 4; -- 创建成功
	TipBecomeVip	  = 5; -- 提示开通vip
}

local SceneConfig = {
	-- 获取用户信息模块
	moduleConfig = {
	-- [模块名称] = {
		-- file = 文件路径 stirng or {pkg = "xxx"},
		-- visible = 是否显示;
		-- props = {}; -- 属性配置
		-- behaviors = {}; -- 模块需要绑定的组件
		-- };
	};

	-- 获取数据模块
	dataConfig = {
		-- [模块名称] = {
		-- 	file = "xxx"模块路径 stirng or {pkg = "xxx"},
		-- };	
		-- data = {
		-- 	file = xxx
		-- };
	};

	PrivatePopType = PrivatePopType;
};
return SceneConfig;