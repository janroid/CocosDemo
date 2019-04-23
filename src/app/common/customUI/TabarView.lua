-- create  demo
-- local param = {  bgFile = "creator/hall/blank4x4.png", 
                -- imageFile = "creator/common/dialog/tab_item_two_bg.png", -- 按钮图片，需和text数组一样个数，可以为nil
                -- tabarSize = {width = 560, height = 55},              --tabarView的宽高
                -- text = {name = {"button1", "button2"},               --按钮文字数组，传多少就多少个按钮
                --         fontSize = 24,
                --         color = {on = {r = 255, g = 255, b = 255}, off = {r = 127, g = 127, b = 127}},文本选中高亮状态颜色
                --         bold = false
                --         },
                -- index = 1,                                           --传入tabarView初始化index，不传默认为1号位置 从左到右
                -- isMove = false,                                      --按钮是否有滑动效果
                -- grid9 = {sx = 120, ex = 120, sy = 20, ey = 20},      --传入9宫格图片 不传 grid9_bg（背景） grid9_fg（按钮） 默认都用grid9
                -- tabClickCallbackObj = self,                          --tabarView初始化的时候要传入回调函数，默认会回调初始化时index的回调事件
                -- tabClickCallbackFunc = self.onTabarClickCallBack     --tabarView初始化的时候要传入回调函数，默认会回调初始化时index的回调事件
                -- };


local TabarView = class("TabarView",cc.Scale9Sprite);
TabarView.s_min_cell_idx = 1;
TabarView.s_AnimTime = 200;
TabarView.s_tabar_list = {  bgFile = "creator/hall/blank4x4.png", 
                            imageFile = "creator/common/dialog/tab_item_four_bg.png", 
                            tabarSize = {width = 660, height = 52}, 
                            text = {name = {"button1", "button2"}, 
                                    fontSize = 24,
                                    color = {on = {r = 255, g = 255, b = 255}, off = {r = 127, g = 127, b = 127}},
                                    bold = false
                                    },
                            isMove = false,
                            grid9 = {sx = 25, ex = 25, sy = 30, ey = 30},
                            tabClickCallback = {func = nil,obj = nil}
                        };
                        
TabarView.ctor = function(self, param)
    local param = self:initParam(param); 
    self:initData(param)
end

--- prive ---
TabarView.initParam = function(self, param)    ---  别用 not  还是用回nil判断  遇到条件表达式赋值 有潜在问题
    if param.bgFile == nil or param.bgFile == "" then
	    param.bgFile = TabarView.s_tabar_list.bgFile;
	end

    if not param.imageFile or (type(param.imageFile) == "string" and param.imageFile == "")  then
        param.imageFile = TabarView.s_tabar_list.imageFile;
    end

    if param.tabarSize == nil or g_TableLib.isEmpty(param.tabarSize) then
	    param.tabarSize = TabarView.s_tabar_list.tabarSize;
	end

    if param.imageSize == nil or g_TableLib.isEmpty(param.imageSize) then
        param.imageSize = {};
    end

    if param.text== nil or g_TableLib.isEmpty(param.text) then
	    param.text = TabarView.s_tabar_list.text;
	end
    if param.text.name == nil or g_TableLib.isEmpty(param.text.name) then
	    param.text.name = TabarView.s_tabar_list.text.name;
	end
    if param.text.fontSize == nil then
        param.text.fontSize = TabarView.s_tabar_list.text.fontSize.name;
    end
    if param.text.color == nil or g_TableLib.isEmpty(param.text.color) then
	    param.text.color = TabarView.s_tabar_list.color;
	end
    if param.text.color.on == nil or g_TableLib.isEmpty(param.text.color.on) then
        param.text.color.on = TabarView.s_tabar_list.color.on;
    end
    if param.text.bold == nil or g_TableLib.isEmpty(param.text.bold) then
        param.text.bold = TabarView.s_tabar_list.bold;
    end

    if param.imagePos == nil then
        param.imagePos = {};
    end

    if param.isMove == nil then
        param.isMove = true;
    end

    if g_TableLib.isEmpty(param.grid9_bg) == false then
	    param.grid9_bg = param.grid9_bg;
    else
        if g_TableLib.isEmpty(param.grid9) == false then
            param.grid9_bg = param.grid9;
        else
            param.grid9_bg = TabarView.s_tabar_list.grid9;
	    end
	end

    if g_TableLib.isEmpty(param.grid9_fg) == false then
	    param.grid9_fg = param.grid9_fg;
    else
        if g_TableLib.isEmpty(param.grid9) == false then
            param.grid9_fg = param.grid9;
        else
            param.grid9_fg = TabarView.s_tabar_list.grid9;
	    end
    end

    return param;
end

TabarView.initData = function (self, param)
    self:setTexture(param.bgFile)
    self:setCapInsets(cc.rect(param.grid9_bg.sx, param.grid9_bg.ex, param.grid9_bg.sy, param.grid9_bg.ey))
    self:setContentSize(cc.size(param.tabarSize.width, param.tabarSize.height));
    self.m_isMove = param.isMove;
    self.m_isMoving = false
    self.m_cellCount = #param.text.name;
    if param.index then
        self.m_cellIdx = param.index;
    else
        self.m_cellIdx = TabarView.s_min_cell_idx;
    end

    self.m_textColor = param.text.color;
    self.m_sizeX = param.imageSize.width or param.tabarSize.width / self.m_cellCount;
    self.m_sizeY = param.imageSize.height or param.tabarSize.height;
    self.m_imageFile = param.imageFile;
    self.m_dividerImgFile = param.dividerImgFile; 
    self:createImage(param.imageFile, param.grid9_fg);
    self:createLabels(param.text)
    self:creatTouchListener()

    self.m_tabClickCallbackFunc = param.tabClickCallbackFunc
    self.m_tabClickCallbackObj = param.tabClickCallbackObj
    if self.m_tabClickCallbackObj and self.m_tabClickCallbackFunc then
        self.m_tabClickCallbackFunc(self.m_tabClickCallbackObj,self.m_cellIdx)
    end
end

TabarView.createImage = function (self, imageFile, grid9)
    local file = imageFile;
    if type(imageFile) == "table" then
        file = imageFile[1];
    end

    local x = self.m_sizeX * (self.m_cellIdx - 1);
    local y = 0;

    self.m_image = cc.Scale9Sprite:create(file)
    self.m_image:setCapInsets(cc.rect(grid9.sx, grid9.ex, grid9.sy, grid9.ey))
    self.m_image:setContentSize(self.m_sizeX, self.m_sizeY);
    self.m_image:setAnchorPoint(cc.p(0,0))
    self.m_image:setPosition(x,y);
    self:addChild(self.m_image);
end

TabarView.createLabels = function (self,text)
    self.labelList = {}
    local x = 0;
    local y = 0;
    for k,name in ipairs(text.name) do
        x = self.m_sizeX * (k - 1);
        local btnLabel = cc.Label:createWithSystemFont("",  "fonts/arial.ttf", text.fontSize,cc.size(self.m_sizeX,self.m_sizeY),cc.TEXT_ALIGNMENT_CENTER,cc.TEXT_ALIGNMENT_CENTER)
        btnLabel:setString(name)
        btnLabel:setAnchorPoint(cc.p(0,0))
        btnLabel:setPosition(x,y);
        if self.m_cellIdx == k then
            btnLabel:setColor(cc.c3b(text.color.on.r,text.color.on.g,text.color.on.b))
        else
            btnLabel:setColor(cc.c3b(text.color.off.r,text.color.off.g,text.color.off.b))
        end
        self:addChild(btnLabel);
        table.insert(self.labelList, btnLabel)
    end
end

TabarView.setTabarState = function (self,index)
    self.m_cellIdx = index
    if self.m_tabClickCallbackObj and self.m_tabClickCallbackFunc then
        self.m_tabClickCallbackFunc(self.m_tabClickCallbackObj,self.m_cellIdx)
    end
    for _,btnLabel in ipairs(self.labelList) do
        btnLabel:setColor(cc.c3b(self.m_textColor.off.r, self.m_textColor.off.g, self.m_textColor.off.b));
    end
    self.labelList[self.m_cellIdx]:setColor(cc.c3b(self.m_textColor.on.r, self.m_textColor.on.g, self.m_textColor.on.b));
    self:changeFGImgPos()
end

TabarView.changeFGImgPos = function (self)
    if self.m_isMove then
        local animateMove = cc.MoveTo:create(TabarView.s_AnimTime/1000,cc.p(self.m_sizeX * (self.m_cellIdx - 1),0))-- 上移
        local animateMoveCallback = function()
            self.m_isMoving = false
        end
        self.m_isMoving = true
        -- cc.Sequence:create(animateMove,cc.CallFunc:create(animateMoveCallback))
        self.m_image:runAction(cc.Sequence:create(animateMove,cc.CallFunc:create(animateMoveCallback)))
    else
        self.m_image:setPosition(self.m_sizeX * (self.m_cellIdx - 1),0);
    end
end

TabarView.setTabarStateImmediately = function (self,index)
    local oldIsMove = self.m_isMove
    self.m_isMove = false
    self:setTabarState(index)
    self.m_isMove = oldIsMove
end

TabarView.creatTouchListener = function (self)
    local eventDispatcher = self:getEventDispatcher()
    local function onTouchBegan(touch, event)
        if not g_NodeUtils:isVisible(self) then
            return false
        end
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        local s = self:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            return true
        end

        return false    
    end
    local  function onTouchEnded(touch, event)
        local locationInNode = self:convertToNodeSpace(touch:getLocation())
        local s = self:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)

        if cc.rectContainsPoint(rect, locationInNode) then
            local index = math.modf(locationInNode.x/self.m_sizeX) + 1
            if self.m_cellIdx == index or self.m_isMoving then return end
            self.m_cellIdx = index
            self:setTabarState(index)
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    self._listener = listener
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

TabarView.setTouchEnabled = function (self, isEnabled)
     self._listener:setEnabled(isEnabled)
end

TabarView.getCurrentIndex = function (self)
    return self.m_cellIdx
end

TabarView.dtor = function(self)
    if (self.m_image) then
        self.m_image:removeFromParent()
        self.m_image = nil;
    end

    if self.m_tabClickCallback.func  then
        self.m_tabClickCallback.func = nil;
    end
    if self.m_tabClickCallback.obj then
        self.m_tabClickCallback.obj = nil;
    end

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self._listener)
end

return TabarView