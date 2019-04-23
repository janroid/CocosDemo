--Progress.lua
--Author:JohnsonZHang
--Data:2018.12.7
--Description: progress动画，用于需要耗时等待的场景
-- function Progress:getInstance():setTips("Game start"):setLoadingPos(60,60)
--            :setAreaPos(200,200):setAreaSize(400,300):setBgClickEnable(false):show();
-- 调用的话采用这种方式，默认的话 背景不可点击且全局显示菊花,
-- notice: 设置菊花的位置必须在设置完文本 后才能使文本的位置不偏差
-- 需要修改的话就根据自己需要自定义

local ViewBase = cc.load("mvc").ViewBase;
local Progress = class("Progress",ViewBase);
-- 菊花转一格的时间
Progress.s_ms = 1;
-- 菊花最长时间
Progress.MAX_TIMER = 20;
Progress.S_FILE_LOGO = "creator/loading/loading_fixed_img.png";
Progress.S_FILE_LOADING = "creator/loading/loading_rotate_img.png";
Progress.s_loadingImgWidth = 66;
Progress.s_loadingImgHeight = Progress.s_loadingImgWidth;
Progress.s_tipsFontSize = 26;
Progress.S_TAG = 1001;

Progress.BlurIDs = {
    RoomBlur = g_GetIndex();
}

Progress.BlurConfig = {
	[Progress.BlurIDs.RoomBlur] = {
		DirName    = 'images/';
		FileName   = 'roomBlur.jpg';
		FileFormat = cc.IMAGE_FORMAT_JPEG;
		IsRGBA     = false;
	};
}



-- Progress.s_eventFuncMap = {
-- 	[g_SceneEvent.ON_SCENE_ENTER] = "onSceneEnter";
-- }
local function getBlurFileFullPath(dirName, fileName)
	local dirPath = cc.FileUtils:getInstance():getWritablePath() .. dirName
	
	if not cc.FileUtils:getInstance():isDirectoryExist(dirPath) then
		cc.FileUtils:getInstance():createDirectory(dirPath)
	end
	return dirPath .. fileName
end

function Progress.getInstance()
	if not Progress.s_instance then
	    Progress.s_instance = Progress:create()
	end
	return Progress.s_instance;
end

function Progress:onExit()
end

function Progress:onCleanup()
	self:stop()
end

-- -- 场景切换成功
-- function Progress:onSceneEnter()
-- 	-- if self:isVisible() then
-- 	-- 	self:dismiss()
-- 	-- 	local runningScene = cc.Director:getInstance():getRunningScene()
-- 	-- 	local childProgress = runningScene:getChildByTag(Progress.S_TAG)
-- 	-- 	if not childProgress then
-- 	-- 		self:removeFromParent()
-- 	-- 	end
-- 	-- 	self:show()
-- 	-- end
-- end

function Progress:onEnter()
end

function Progress.releaseInstance()
	if Progress.s_instance then
		Progress.s_instance:removeSelf()
	end
	Progress.s_instance = nil;
end

function Progress:ctor()
	ViewBase.ctor(self)
	self:setContentSize(cc.size(display.width, display.height))
	self:retain()
	self:load();
	g_EventDispatcher:register(g_SceneEvent.EVENT_BACK,self,self.onEventBack)
end

function Progress:onEventBack()
	self:dismiss()
end

function Progress:dtor()
	self:stop();
	cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end

-- 设置提示
function Progress:setTips(tips, fontSize,r,g,b)
	local mr = r or 255;
	local mg = g or 255;
	local mb = b or 255;
    fontSize = ((fontSize and type(fontSize) == "number" and fontSize > 0) and fontSize) or Progress.s_tipsFontSize
	if tips and type(tips) == "string" and string.len(tips) ~= 0 then
        if not self.m_loadingTx then
            self.m_loadingTx = cc.Label:createWithSystemFont(tips, nil, fontSize)
	        self.m_loadingTx:setTextColor(cc.c3b(mr,mg,mb))
            self:addChild(self.m_loadingTx);
            g_NodeUtils:arrangeToCenter(self.m_loadingTx)
		else
            self.m_loadingTx:setString(tips);
            self.m_loadingTx:setTextColor(cc.c3b(mr,mg,mb))
		end
		self.m_loadingTx:setVisible(true);
    end
    local txSize =  self.m_loadingTx:getContentSize();
    local w,h = txSize.width,txSize.height
    local loadingImgSize=  self.m_loadingImg:getContentSize();
    local imgH = loadingImgSize.height
    local posY = self.m_loadingTx:getPositionY()
	self.m_loadingTx:setPositionY(posY-imgH/2-h/2);
	return self;
end

-- 設置超時囘調
function Progress:setOverTimeCallback(obj,func)
	self.m_overTimerFunc = func;
	self.m_overTimerObj = obj;

	return self;
end

-- 设置菊花的位置 
-- 菊花默认是跟背景居中显示的，所以设置x y是菊花中心点
function Progress:setLoadingPos( x, y )
	if not x or not y then
		return self;
	end

	if (self.m_loadingImg) then
		self.m_loadingLogo:setPosition(cc.p(x,y));
		self.m_loadingImg:setPosition(cc.p(x,y));
		if (self.m_loadingTx) then
			local txSize =  self.m_loadingTx:getContentSize();
            local w,h = txSize.width,txSize.height
            local loadingImgSize=  self.m_loadingImg:getContentSize();
            local imgH = loadingImgSize.height
			self.m_loadingTx:setPosition(cc.p(x , y-imgH/2-h/2));
		end
	end
	return self;
end

-- 设置显示区域的位置
function Progress:setAreaPos( x, y)
	self.m_areaX = x or 0;
	self.m_areaY = y or 0;

	return self;
end

-- 获取显示区域的位置
function Progress:getAreaPos()
	return self.m_areaX or 0, self.m_areaY or 0;
end

-- 设置伸缩
function Progress:setScale(scale)
	self.m_scale = scale or 1;
	return self;
end

-- 动画周期
function Progress:setAnimPeriod(time)
	self.m_animPeriod = time or Progress.s_ms;

	return self;
end

-- private
function Progress:load()
	self:setTag(Progress.S_TAG)
	self:setLocalZOrder(KZOrder.Progress)
	cc.Director:getInstance():getNotificationNode():add(self)
	g_NodeUtils:arrangeToCenter(self)
    local areaW, areaH =display.width, display.height
	self.m_loadingBg = ccui.Button:create("creator/common/dialog/blank1.png","creator/common/dialog/blank1.png")
    self.m_loadingBg:ignoreContentAdaptWithSize(false)
    self.m_loadingBg:setContentSize(cc.size(areaW,areaH))
    self:addChild(self.m_loadingBg);
    g_NodeUtils:arrangeToCenter(self.m_loadingBg)
    self.m_loadingBg:addClickEventListener(function() end)
	self.m_loadingLogo = cc.Sprite:create(Progress.S_FILE_LOGO);
	self.m_loadingLogo:setContentSize(cc.size(Progress.s_loadingImgWidth , Progress.s_loadingImgHeight));
	self.m_loadingLogo:setPosition(cc.p(areaW/2 , areaH/2));
    self:addChild(self.m_loadingLogo);
    g_NodeUtils:arrangeToCenter(self.m_loadingLogo)
	
	self.m_loadingImg = cc.Sprite:create(Progress.S_FILE_LOADING);
	self.m_loadingImg:setContentSize(cc.size(Progress.s_loadingImgWidth , Progress.s_loadingImgHeight));
	self.m_loadingImg:setPosition(cc.p(areaW/2 , areaH/2));
    self:addChild(self.m_loadingImg);
    g_NodeUtils:arrangeToCenter(self.m_loadingImg)
	self:setVisible(false);
	
end

-- 显示
function Progress:show(maxTime, isBlur, blurID)
	self.m_curRotateCount = 0;
	self.m_maxTime = maxTime or Progress.MAX_TIMER;
	if not self.m_isShowing then
		local progressW,progressH = self:getAreaSize();
		-- 大小
		self:setContentSize(cc.size(progressW, progressH))
		local x,y = self:getAreaPos();	
		-- 位置
		self:setPosition(cc.p(x,y));	
		-- 伸缩
		if self.m_scale and self.m_scale ~= 1 then
			self:setScale(self.m_scale)
		end
		
		-- 容错
		self:stop();
		
        self:setVisible(true);
        local callbackEntry = nil
        local callback = function()
            if self.callbackEntry then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.callbackEntry)
                self.callbackEntry = nil
            end
            if self.m_overTimerFunc then
                self.m_overTimerFunc(self.m_overTimerObj);
            end    
            self:dismiss();
        end
        self.callbackEntry =  cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback,self.m_maxTime,false)
        local actionRotate1 =  cc.RotateBy:create(Progress.s_ms,360)
        self.m_loadingImg:runAction(cc.RepeatForever:create(actionRotate1))		
		self.m_isShowing = true;
		
	else
		Log.d("the progress is showing");
	end
	
	self:setBlur(isBlur, blurID)
	
	cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    return self;
end

function Progress:setBlur(isBlur, blurID)
	if not isBlur then
		if self.m_blur then
			self.m_blur:setVisible(false)
		end
		return self
	end	

	local ID = Progress.BlurIDs[blurID] or Progress.BlurIDs.RoomBlur
	if ID == self.m_blurID and self.m_blur then -- 如果每次显示的都是旧的
		self.m_blur:setVisible(true)
		return self;
	end
	
	-- 移除旧的模糊背景
	if self.m_blur then
		self.m_blur:removeFromParent()
	end

	local CurrentBlurCfg = Progress.BlurConfig[ID]
	local path = getBlurFileFullPath(CurrentBlurCfg.DirName, CurrentBlurCfg.FileName)
	local tmpBlur = nil

	if io.exists(path) then
		tmpBlur = cc.Sprite:create(path)
		self.m_blurID = ID
	else
		Log.d('show blur')
		-- 截取当前场景背景
		local target = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
		target:setPosition(cc.p(display.width / 2, display.height / 2))
		target:begin()
		cc.Director:getInstance():getRunningScene():visit()
		target:endToLua()

		-- 根据当前场景背景生成模糊一张图片
		local SpriteBlur = import('app.common.customUI').SpriteBlur
		local sb = SpriteBlur:create()
		sb:initWithTexture(target:getSprite():getTexture(), cc.rect(0, 0, display.width, display.height))
		sb:setScale(1, -1)
		cc.Director:getInstance():getRunningScene():addChild(sb)
		g_NodeUtils:arrangeToCenter(sb)

		--把模糊图片添加到当前场景，并生成一张模糊图片保存起来
		local blurSave = cc.RenderTexture:create(display.width, display.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
		blurSave:begin()
		cc.Director:getInstance():getRunningScene():visit()
		blurSave:endToLua()
		blurSave:saveToFile(CurrentBlurCfg.DirName .. CurrentBlurCfg.FileName, CurrentBlurCfg.FileFormat, CurrentBlurCfg.IsRGBA)
		sb:removeFromParent()
		if io.exists(path) then -- 这样做是为了保证第一次生成时，也不至于那么卡
			tmpBlur = cc.Sprite:create(path)
		end
		if not tmpBlur then 
			tmpBlur = sb
		end
	end
	self:addChild(tmpBlur, -1)
	g_NodeUtils:arrangeToCenter(tmpBlur)
	-- 记录当前模糊，以及ID
	self.m_blur = tmpBlur
	return self
end

-- 设置背景可点击
function Progress:setBgClickEnable(isEnable )
	if self.m_loadingBg then
		self.m_loadingBg:setVisible(isEnable and true or false );
	end
	return self;
end

-- 设置 显示区域的大小
function Progress:setAreaSize(width, height )
	if (not width or not height) then return; end
	self.m_areaWidth = width;
	self.m_areaHeight = height;
	self:setContentSize(cc.size(self.m_areaWidth,self.m_areaHeight));
	
	self.m_loadingImg:setPosition(cc.p(self.m_areaWidth/2 , self.m_areaHeight/2));
	self.m_loadingLogo:setPosition(cc.p(self.m_areaWidth/2 , self.m_areaHeight/2));

	return self;
end

-- 隐藏菊花
function Progress:hideChrysanthemum()
	self.m_loadingImg:setVisible(false);
	self.m_loadingLogo:setVisible(false);
	
	return self;
end

-- 获取显示区域大小
function Progress:getAreaSize()
    local size = self:getContentSize()
	self.m_areaWidth, self.m_areaHeight = size.width,size.height;
	if (self.m_areaWidth <= 0 ) then
		self.m_areaWidth = display.width;
	end
	if (self.m_areaHeight <= 0) then
		self.m_areaHeight = display.height;
	end
	return self.m_areaWidth, self.m_areaHeight;
end

function Progress:getIsVisible()
	return self.m_isShowing and true or false;
end

-- 隐藏
function Progress:dismiss()
	if self.m_isShowing then
		self:setVisible(false);
		self:stop();
		self.m_isShowing = false;
	end

	self.m_loadingImg:setVisible(true);
	self.m_loadingLogo:setVisible(true);

	self:setContentSize(cc.size(display.width,display.height));
	self:setPosition(cc.p(0,0));
	self.m_loadingBg:setVisible(true);
	
	self:reSet();
	cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end

-- private
function Progress:stop()
      if self.m_loadingImg then
        self.m_loadingImg:stopAllActions()
  	end

    if self.callbackEntry then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.callbackEntry)
        self.callbackEntry = nil
    end
end

function Progress:reSet()
	local areaW, areaH = display.width, display.height;
	self.m_loadingImg:setPosition(areaW/2 , areaH/2 );
	self.m_loadingLogo:setPosition(areaW/2  , areaH/2 );
	self.m_areaX = 0;
	self.m_areaY = 0;
	self.m_scale = 1;
	self.m_animPeriod =Progress.s_ms;
	self.m_areaWidth = 0;
	self.m_areaHeight = 0;

	self.m_overTimerFunc = nil;
	self.m_overTimerObj = nil;

	if self.m_loadingTx then
		self.m_loadingTx:setVisible(false);
	end
end

return Progress