--[[--ldoc desc
@module AchievementTongji
@author MenuZhang

Date   2018-11-1
]]
local ViewBase = cc.load("mvc").ViewBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local AchievementTongji = class("AchievementTongji",ViewBase);
BehaviorExtend(AchievementTongji);

AchievementTongji.tab_config = {
	GameString.get("str_statistic_top_tab1"),
	GameString.get("str_statistic_top_tab2"),
	GameString.get("str_statistic_top_tab3"),
	GameString.get("str_statistic_top_tab4"),
	GameString.get("str_statistic_top_tab5"),
}

AchievementTongji.content_config = {
	{
		key = GameString.get("str_statistic_content_title_overview"),
		items = {
			GameString.get("str_statistic_content_title_overview_sub1"),
			GameString.get("str_statistic_content_title_overview_sub2"),
		},
	},
	{
		key = GameString.get("str_statistic_content_title_special"),
		items = {
			GameString.get("str_statistic_content_title_special_sub_1"),
			GameString.get("str_statistic_content_title_special_sub_2"),
		},
	},
	{
		key = GameString.get("str_statistic_content_title_game"),
		items = {
			GameString.get("str_statistic_content_title_game_sub_1"),
			GameString.get("str_statistic_content_title_game_sub_2"),
			GameString.get("str_statistic_content_title_game_sub_3"),
			GameString.get("str_statistic_content_title_game_sub_4"),
			GameString.get("str_statistic_content_title_game_sub_5"),
		},
	},
	{
		key =  GameString.get("str_statistic_content_title_win"),
		items = {
			GameString.get("str_statistic_content_title_win_sub_1"),
			GameString.get("str_statistic_content_title_win_sub_2"),
			GameString.get("str_statistic_content_title_win_sub_3"),
			GameString.get("str_statistic_content_title_win_sub_4"),
			GameString.get("str_statistic_content_title_win_sub_5"),
		},
	},
	{
		key = GameString.get("str_statistic_content_title_oprate"),
		items = {
			GameString.get("str_oprate_fold"),
			GameString.get("str_oprate_check"),
			GameString.get("str_oprate_call"),
			GameString.get("str_oprate_raise"),
			GameString.get("str_oprate_anti_raise"),
		},
	},
	{
		key = GameString.get("str_statistic_content_title_fold"),
		items = {
			GameString.get("str_statistic_content_title_fold_sub_1"),
			GameString.get("str_statistic_content_title_fold_sub_2"),
			GameString.get("str_statistic_content_title_fold_sub_3"),
			GameString.get("str_statistic_content_title_fold_sub_4"),
			GameString.get("str_statistic_content_title_fold_sub_5"),
		},
	}
}

function AchievementTongji:ctor()
	ViewBase.ctor(self);
	-- self:bindCtr(require(".AchievementCtr"));
	self:init();
end

function AchievementTongji:onCleanup()
	self:unBindCtr();
end

function AchievementTongji:init()
	-- do something
	self.select_tab = 1
	-- 加载布局文件
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/achievement/achievementTongji.ccreator')
	self.m_root:setPosition(0,0)
	self:add(self.m_root);
	self:findView()
	self:createTab()
	self:createContent()
end

function AchievementTongji:findView()
	self.select_btn = g_NodeUtils:seekNodeByName(self.m_root, "select_btn")
	
end

function AchievementTongji:createTab()
	local tongji_tab_bg = g_NodeUtils:seekNodeByName(self.m_root, "tongji_tab_bg")
	local btn_width = 116
	local offset_x = (609 - btn_width* #self.tab_config) / 2
	self.select_btn:setPositionX(offset_x)
	for k,v in pairs(self.tab_config) do
		local layout = ccui.Layout:create()
		layout:setContentSize(btn_width, 44)
		layout:setTouchEnabled(true)
		layout.tag = k
		layout:addClickEventListener(function (sender)
			self:onClickTab(sender)
		end)

		local title = cc.Label:createWithSystemFont(v, nil, 24, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		title:setTextColor(cc.c4b(254,254,254,255))
		title:setPosition(58,22)
		layout:add(title):addTo(tongji_tab_bg)
		local x = offset_x + btn_width * (k-1)
		layout:setPositionX(x)
	end
end

function AchievementTongji:createContent(flag, sender)
	local scroll = cc.ScrollView:create(cc.size(603,413))
	scroll:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	scroll:setPosition(5,10)
	self.m_root:add(scroll)

	local subviews = {}
	self.subViewsContent = {}
	for k,v in pairs(self.content_config) do
		local bg = ccui.ImageView:create("creator/achievement/res/right_bg.png", ccui.TextureResType.localType)
		bg:setScale9Enabled(true)
		bg:setAnchorPoint(0,0)
		bg:setCapInsets(cc.rect(1,1,8,8))
		table.insert(subviews,bg)

		local title_bg = ccui.ImageView:create("creator/achievement/res/right_title_bg.png", ccui.TextureResType.localType)
		title_bg:setAnchorPoint(0,1)
		bg:add(title_bg)
		scroll:add(bg)

		local title = cc.Label:createWithSystemFont(v.key, nil, 24, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		title:setTextColor(cc.c4b(254,254,254,255))
		title:setAnchorPoint(0,0)
		title:setPosition(19,6)
		title_bg:add(title)

		local item_count, margin_h = #v.items, 10
		local height = item_count * (20 + margin_h) + 60
		local bg_width = 596
		bg:setContentSize(bg_width,height)
		title_bg:setPosition(-6,height)
		local contents = {}
		for k1,v1 in pairs(v.items) do
			local contentItem = {}
			local pos_y = (item_count - k1 + 1) * (20 + margin_h) - 5
			local subTitle = cc.Label:createWithSystemFont(v1, nil, 20, cc.size(0,0), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			subTitle:setTextColor(cc.c4b(196,214,236,255))
			local text_width = subTitle:getContentSize().width
			subTitle:setPosition(13 + text_width/2,pos_y)
			bg:add(subTitle)
			
			local times = cc.Label:createWithSystemFont("0", nil, 20, cc.size(0,0), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			times:setTextColor(cc.c4b(196,214,236,255))
			times:setPosition(bg_width-250,pos_y)
			bg:add(times)
			contentItem.times = times
			local percent = cc.Label:createWithSystemFont("0", nil, 20, cc.size(0,0), cc.TEXT_ALIGNMENT_RIGHT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			percent:setTextColor(cc.c4b(196,214,236,255))
			text_width = percent:getContentSize().width
			percent:setPosition(bg_width-20-text_width,pos_y)
			bg:add(percent)
			contentItem.percent = percent
			table.insert(contents,contentItem)
		end
		table.insert(self.subViewsContent,contents)
	end

	local sub_count = #subviews
	local pos_y = 15
	for i=sub_count,1,-1 do
		subviews[i]:setPosition(6,pos_y)
		local height = subviews[i]:getContentSize().height
		pos_y = pos_y + height + 30
	end
	scroll:setContentSize(0,pos_y - 30)
	scroll:setContentOffset(cc.p(0,-pos_y + 413 + 30))
end


function AchievementTongji:onClickTab(sender)
	if self.select_tab == sender.tag then return end
	self.select_tab = sender.tag
	self.select_btn:moveTo({x = sender:getPositionX(), time = 0.15})
	self:setStatData(self.select_tab)
end

---刷新界面
function AchievementTongji:updateView(data)
	data = checktable(data);
	-- Log.d("AchievementTongji:updateView data = ", data )
	if self.subViewsContent then
		for i = 1,#self.subViewsContent do
			local contentsData = data[i]
			local contents = self.subViewsContent[i]
			if contents then
				for j =1,#contents do
					local contentItemData = contentsData.children[j]
					local contentItem = contents[j]
					if contentItem then
						if contentItem.times then
							contentItem.times:setString(string.format(GameString.get("str_common_number"), contentItemData.m_times or 0))
						end
						if contentItem.percent then
							contentItem.percent:setString(contentItemData.m_progress .. "%" )
						end
					end
				end
			end
		end
	end
end

function AchievementTongji:setData(data)
	Log.d(" AchievementTongji:setData data = ",data)
	self.m_data = data
	self:setStatData(self.select_tab)
end


--a今天b最近一周c最近一个月d最近三个月e最近半年f最近半年g最近半年
function  AchievementTongji:setStatData(index)
-- Log.d("AchievementTongji:setStatData index = ",index,self.m_data)
	if not g_TableLib.isEmpty(self.m_data) then
		if index == 1 then
			self:setStatWindowData(self.m_data.a)
		elseif  index == 2 then
			self:setStatWindowData(self.m_data.b)
		elseif  index == 3 then
			self:setStatWindowData(self.m_data.c)
		elseif  index == 4 then
			self:setStatWindowData(self.m_data.d)
		elseif  index == 5 then
			self:setStatWindowData(self.m_data.e)
		elseif  index == 6 then
			self:setStatWindowData(self.m_data.f)
		elseif  index == 7 then
			self:setStatWindowData(self.m_data.g)
		end
	end
end

function AchievementTongji:setStatWindowData(statData)
	Log.d("AchievementTongji:setStatWindowData  statData = ",statData)
	if g_TableLib.isEmpty(statData) then
		return
	end
	
	local groupData = self:getClearedStatGroupData();
    groupData[1].children[1].m_times        = statData.a;
    groupData[1].children[1].m_progress     = (statData.a   > 0) and "100" or "0";	                                                        
    groupData[1].children[2].m_times        = statData.b;   
    groupData[1].children[2].m_progress     = (statData.a   > 0) and string.format("%d", (statData.b / statData.a * 100)) or "0";
	
	groupData[2].children[1].m_times        = statData.c;   
    groupData[2].children[1].m_progress     = (statData.c   > 0) and "100" or "0";
    groupData[2].children[2].m_times        = statData.d;   
    groupData[2].children[2].m_progress     = (statData.c   > 0) and string.format("%d", (statData.d / statData.c * 100)) or "0";
	
	groupData[3].children[1].m_times        = statData.e;   
    groupData[3].children[1].m_progress     = (statData.a   > 0) and string.format("%d", (statData.e / statData.a * 100)) or "0";
    groupData[3].children[2].m_times        = statData.f;   
    groupData[3].children[2].m_progress     = (statData.a   > 0) and string.format("%d", (statData.f / statData.a * 100)) or "0";
    groupData[3].children[3].m_times        = statData.g;   
    groupData[3].children[3].m_progress     = (statData.a   > 0) and string.format("%d", (statData.g / statData.a * 100)) or "0";
    groupData[3].children[4].m_times        = statData.h;   
    groupData[3].children[4].m_progress     = (statData.a   > 0) and string.format("%d", (statData.h / statData.a * 100)) or "0";
    groupData[3].children[5].m_times        = statData.i;   
    groupData[3].children[5].m_progress     = (statData.a   > 0) and string.format("%d", (statData.i / statData.a * 100)) or "0";
	
	groupData[4].children[1].m_times        = statData.j;   
    groupData[4].children[1].m_progress     = (statData.b   > 0) and string.format("%d", (statData.j / statData.b * 100)) or "0";
    groupData[4].children[2].m_times        = statData.k;   
    groupData[4].children[2].m_progress     = (statData.b   > 0) and string.format("%d", (statData.k / statData.b * 100)) or "0";
    groupData[4].children[3].m_times        = statData.l;   
    groupData[4].children[3].m_progress     = (statData.b   > 0) and string.format("%d", (statData.l / statData.b * 100)) or "0";
    groupData[4].children[4].m_times        = statData.m;   
    groupData[4].children[4].m_progress     = (statData.b   > 0) and string.format("%d", (statData.m / statData.b * 100)) or "0";
    groupData[4].children[5].m_times        = statData.n;   
    groupData[4].children[5].m_progress     = (statData.b   > 0) and string.format("%d", (statData.n / statData.b * 100)) or "0";
    
    local caozuo_total = statData.o + statData.p + statData.q + statData.r;
    groupData[4].children[1].m_times        = statData.o;
    groupData[4].children[1].m_progress     = (caozuo_total > 0) and string.format("%d", (statData.o / caozuo_total * 100)) or "0";
    groupData[4].children[2].m_times        = statData.p;
    groupData[4].children[2].m_progress     = (caozuo_total > 0) and string.format("%d", (statData.p / caozuo_total * 100)) or "0";
    groupData[4].children[3].m_times        = statData.q;
    groupData[4].children[3].m_progress     = (caozuo_total > 0) and string.format("%d", (statData.q / caozuo_total * 100)) or "0";
    groupData[4].children[4].m_times        = statData.r;
    groupData[4].children[4].m_progress     = (caozuo_total > 0) and string.format("%d", (statData.r / caozuo_total * 100)) or "0";
    groupData[4].children[5].m_times        = statData.s;
    groupData[4].children[5].m_progress     = (caozuo_total > 0) and string.format("%d", (statData.s / caozuo_total * 100)) or "0";
	
	groupData[5].children[1].m_times        = statData.t;
    groupData[5].children[1].m_progress     = (statData.a   > 0) and string.format("%d", (statData.t / statData.a * 100))   or "0";
    groupData[5].children[2].m_times        = statData.u;   
    groupData[5].children[2].m_progress     = (statData.a   > 0) and string.format("%d", (statData.u / statData.a * 100))   or "0";
    groupData[5].children[3].m_times        = statData.v;   
    groupData[5].children[3].m_progress     = (statData.a   > 0) and string.format("%d", (statData.v / statData.a * 100))    or "0";
    groupData[5].children[4].m_times        = statData.w;   
    groupData[5].children[4].m_progress     = (statData.a   > 0) and string.format("%d", (statData.w / statData.a * 100))   or "0";
    groupData[5].children[5].m_times        = statData.x;   
    groupData[5].children[5].m_progress     = (statData.a   > 0) and string.format("%d", (statData.x / statData.a * 100))   or "0";

    groupData[6].children[1].m_times        = statData.t;
	groupData[6].children[1].m_progress     = (statData.a > 0) and string.format("%d", (statData.t / statData.a * 100)) or "0";
	groupData[6].children[2].m_times        = statData.u;
	groupData[6].children[2].m_progress     = (statData.a > 0) and string.format("%d", (statData.u / statData.a * 100)) or "0";
	groupData[6].children[3].m_times        = statData.v;
	groupData[6].children[3].m_progress     = (statData.a > 0) and string.format("%d", (statData.v / statData.a * 100)) or "0";
	groupData[6].children[4].m_times        = statData.w;
	groupData[6].children[4].m_progress     = (statData.a > 0) and string.format("%d", (statData.w / statData.a * 100)) or "0";
	groupData[6].children[5].m_times        = statData.x;
	groupData[6].children[5].m_progress     = (statData.a > 0) and string.format("%d", (statData.x / statData.a * 100)) or "0";
	self:updateView(groupData)
end

function AchievementTongji:getClearedStatGroupData()
	local groups= {};
	g_ArrayUtils.push(groups, self:createStatGroup(1, 2, 1));
	g_ArrayUtils.push(groups, self:createStatGroup(2, 2, 2));
	g_ArrayUtils.push(groups, self:createStatGroup(3, 5, 3));
	g_ArrayUtils.push(groups, self:createStatGroup(4, 5, 4));
	g_ArrayUtils.push(groups, self:createStatGroup(5, 5, 5));
	g_ArrayUtils.push(groups, self:createStatGroup(6, 5, 6));
	return groups
end

function AchievementTongji:createStatGroup(index, num, menuIndex)
	local group    = {};
    local children = {};
    for i = 1, num do
		local stat   = {}
		stat.m_times    = "0";
		stat.m_progress = "0.0";
        g_ArrayUtils.push(children, stat);
    end
    group.children = children;
    return group;
end

return AchievementTongji