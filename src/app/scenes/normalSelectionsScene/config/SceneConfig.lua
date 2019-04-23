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

	roomRankType = {
		lowRank = 2,
		middleRank = 3,
		highRank = 4,
	};

	displayType = {
		list = 1,
		graph = 2,
	};

	roomOrderByType = {
		blind_forward = 1,
		blind_backward = 2,
		carry_forward = 3,
		carry_backward = 4,
		seat_forward = 5,
		seat_backward = 6,
	};
};
return SceneConfig;