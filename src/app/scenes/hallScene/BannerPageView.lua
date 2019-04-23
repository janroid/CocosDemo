local BannerPageView = class("BannerPageView", cc.Node)
local BehaviorMap = import("app.common.behavior").BehaviorMap

local NetImageView = import("app.common.customUI").NetImageView

local ActivityWebInfo = import("app.scenes.activity").ActivityWebInfo

BehaviorExtend(BannerPageView)

function BannerPageView:ctor(data, aWidth, aHeight)
    self.m_data = data
    self.m_bannerViewSize = {
        width = aWidth,
        height = aHeight
	}

    if self.m_data and self.m_bannerViewSize then
        self:createUI()
    end
end

function BannerPageView:getPageView()
    if not self.m_pageView then
        self.m_pageView = ccui.PageView:create()
    end

    return self.m_pageView
end

function BannerPageView:dtor()
    if self.m_pageViewTimer then
        self.m_pageViewTimer:cancel()
        self.m_pageViewTimer = nil
    end

    if self.m_pageViewDelay then
        self.m_pageViewDelay:cancel()
        self.m_pageViewDelay = nil
    end
end

function BannerPageView:onCleanup()
	if self.m_pageViewTimer then
        self.m_pageViewTimer:cancel()
        self.m_pageViewTimer = nil
    end

    if self.m_pageViewDelay then
        self.m_pageViewDelay:cancel()
        self.m_pageViewDelay = nil
    end
end

function BannerPageView:setPageIndex(index)
	self.m_pageView:setCurPageIndex(index)
end

function BannerPageView:createUI()
    self.m_pageView = ccui.PageView:create()
    self:addChild(self.m_pageView)

	self.m_imageViews = {}
	self.m_pageLayout = {}

    -- 这里创建3页page
    for i = 1, #self.m_data do
        -- -- 创建layout,内容添加到layout
		local layout, imageView = self:createPage(i, self.m_bannerViewSize, g_AccountInfo:getCDNUrl()..self.m_data[i].picture)
		self.m_pageView:addPage(layout)

		
		table.insert(self.m_imageViews, imageView)
		table.insert(self.m_pageLayout, layout)
		
	end
	
    -- 设置PageView容器尺寸
    self.m_pageView:setContentSize(self.m_bannerViewSize.width, self.m_bannerViewSize.height)
    -- 设置可触摸 若设置为false 则不能响应触摸事件
    self.m_pageView:setTouchEnabled(true)
    self.m_pageView:setAnchorPoint(cc.p(0.5,0.5))
	self.m_pageView:setPosition(cc.p(self.m_bannerViewSize.width / 2, self.m_bannerViewSize.height / 2))
	
	-- 翻到中间页
	self.m_pageView:scrollToPage(1, 0)

	local count = self.m_pageView:getItems()

	-- 设置滑动灵敏度
	-- pageView:setCustomScrollThreshold(5)

	local flag = 1
	local lastImageTag = 0
	
	self.m_pageView:addTouchEventListener(function(sender, eventType)
		local start_pos = sender:getTouchBeganPosition()
		local end_pos = sender:getTouchEndPosition()
		if (0 == eventType)  then
			self:stopAutoTimer()
			print("pressed")
        elseif (1 == eventType)  then
			-- print("move")
        elseif (2 == eventType) then
			print("up")
			if math.abs(start_pos.x - end_pos.x) > 20 then
				self.m_move = true
			else
				self.m_move = false
			end
			self:startAutoScroll()
        elseif (3 == eventType) then
			print("cancel")	
			self:startAutoScroll()
        end
	end)
	
	self.m_pageView:addClickEventListener(function(sender)
		if self.m_move then
			self.m_move = false
		else
			local currentPage = self.m_pageView:getCurrentPageIndex()
			local itemData = self.m_data[currentPage+1]
			self:clickPageItem(currentPage, itemData)
		end
	end)

	self:startAutoScroll()
	-- 水平翻页
    -- pageView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)

    -- 垂直翻页
    -- pageView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
end

function BannerPageView:createPage(tag, size, image)
	local layout = ccui.Layout:create()
	-- layout大小
	layout:setContentSize(size.width, size.height)
	-- 相对于PageView的位置
	-- layout:setPosition(0, 0)

	-- 在layout中置入一张图片
	local imageView = NetImageView:create(image, "creator/hall/icon_normal.png")
	imageView:setPosition(cc.p(self.m_bannerViewSize.width / 2, self.m_bannerViewSize.height / 2))
	layout:addChild(imageView)
	layout:setTag(tag)

	return layout, imageView
end

function BannerPageView:updateImage(index, imageIndex)
	local imageView = self.m_imageViews[index]
	local layout = self.m_pageLayout[index]
	if imageView and layout then
		if imageIndex == -1 then
			imageView:loadTexture("creator/hall/blank4x4.png")

		elseif imageIndex <= #self.m_data then
			imageView:setUrlImage(self.m_data[imageIndex].picture)

			layout:setTag(imageIndex)
		end
	end
end

function BannerPageView:updateData(data)
	self.m_data = data
end

function BannerPageView:startAutoScroll()
	self.m_pageViewTimer = g_Schedule:schedule(function(dt)
		if not self.m_pageView then return end
		local currentPage = self.m_pageView:getCurrentPageIndex()
		currentPage = currentPage + 1 > #self.m_data - 1 and 0 or currentPage + 1
		self.m_pageView:scrollToPage(currentPage)
	end, 3, 3, -1)
end

function BannerPageView:pauseAutoTimer()
    if self.m_pageViewTimer then
        self.m_pageViewTimer:pause()
    end
end

function BannerPageView:resumeAutoTimer()
    if self.m_pageViewTimer then
        self.m_pageViewTimer:resume()
    end
end

function BannerPageView:stopAutoTimer()
    if self.m_pageViewTimer then
        self.m_pageViewTimer:cancel()
        self.m_pageViewTimer = nil
    end
end

function BannerPageView:setVisible(visibility)
	if(visibility) then
		self:startAutoScroll()
	else
		self:stopAutoTimer()
	end

end

-- 参照旧版iPoker的 NewHomeHallModule.bannerEventTouch 的实现
function BannerPageView:clickPageItem(idx, itemData)
	local event1 = tonumber(itemData.clickType)
	local event2 = itemData.clickVal

	if event1 == 1 then -- 活动中心
        if event2 and event2.actid then
            self:openAllScreenActivity(event2);
        else
			local res = g_AccountInfo:getHallIcon()
            if g_TableLib.isTable(res) and res.icon ~= nil then
				local callJS = ActivityWebInfo:defaultCallJs()				
				self:openActivity(tostring(res.url), callJS)
            end
        end
	elseif event1 == 2 then -- 商城 event2： 1筹码  2卡拉币 3道具 4vip
		-- local StoreConfig = import("app.scenes.store").StoreConfig
		g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE, tonumber(event2))
	elseif event1 == 3 then -- 去普通场大厅 event2： 1初级 2中级 3高级
		local tab = tonumber(event2) or 1;
		local NormalSelectionsScene = import("app.scenes.normalSelectionsScene").scene
		cc.Director:getInstance():pushScene(NormalSelectionsScene:create(tab))
	elseif event1 == 4 then -- 去MTT大厅
		local MttLobbyScene = import("app.scenes.mttLobbyScene").scene
		cc.Director:getInstance():pushScene(MttLobbyScene:create())
    elseif event1 == 5 then -- 去sng大厅
		local SngLobbyScene = import("app.scenes.sngLobby").SngLobbyScene
		cc.Director:getInstance():pushScene(SngLobbyScene:create())
    elseif event1 == 6 then -- 全屏网页
        self:openAllScreenActivity(event2);  
	elseif event1 == 7 then -- 休闲游戏页面
		g_EventDispatcher:dispatch(g_SceneEvent.Hall_SHOW_SUBGAMES)
    end
end

function BannerPageView:openAllScreenActivity(event)
    local res = g_AccountInfo:getHallIcon()
	if not g_TableLib.isTable(res) then return end
	
	local idT = {actid = event.actid, tid = event.tid}
	local callJS = string.format("mb2js(2, '%s')", g_JsonUtil.encode(idT))
	self:openActivity(tostring(res.url), callJS)
end

function BannerPageView:openActivity(url, callJS)
	local webInfo = ActivityWebInfo.new(url)
	webInfo:setCallJS(callJS)
	webInfo:setX(0)
	webInfo:setY(0)
	webInfo:setFull(true)
	g_PopupManager:show(g_PopupConfig.S_POPID.ACTIVITY_WEB_POP, webInfo) 
end

return BannerPageView