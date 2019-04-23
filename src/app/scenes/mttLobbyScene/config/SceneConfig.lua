--[[
	该场景下需要配置的模块
]]
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

	displayState = {
		STATE_APPLY = 1,
		STATE_ON = 2,
		STATE_END = 3,
	};
};
return SceneConfig;