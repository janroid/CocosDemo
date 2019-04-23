local View = class("LevelsSystem",cc.Node)
local ItemWidth = 610

local function createTable(data)
    local node = display.newNode()
    local height = 0
    local normalHeight = 40
    local othersColor = cc.c4b(0xf2,0xee,0x8c,0xff)
    for i=#data,1,-1 do
        local value = data[i]
        local other = value.other
        local itemHeight = normalHeight
        if other and #other > 0 then
            local line = display.newSprite("creator/help/res/frame1.png")
            line:align(display.LEFT_BOTTOM,0,height):addTo(node)
            itemHeight = line:getContentSize().height
        else
            local line = display.newSprite("creator/help/res/line1.png")
            line:align(display.LEFT_BOTTOM,0,height):addTo(node)
        end 

        local color = cc.c4b(0xc4,0xd5,0xec,0xff)
        if value.fontStyle and value.fontStyle.color then
            local newColor = value.fontStyle.color
            color = cc.c4b(newColor.r,newColor.g,newColor.b,0xff)
        end

        local label1 = GameString.createLabel(value.level,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.LevelSystemFontSize)
        label1:setTextColor(color)
        label1:align(display.CENTER,36,itemHeight / 2 + height):addTo(node)

        local label2 = GameString.createLabel(value.name,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.LevelSystemFontSize)
        label2:setTextColor(color)
        local labelSize = label2:getContentSize()

        label2:setDimensions(150,labelSize.height)
        label2:setOverflow(cc.LabelOverflow.RESIZE_HEIGHT)

        label2:align(display.CENTER,145,itemHeight / 2 + height):addTo(node)

        local label3 = GameString.createLabel(value.needExp,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.LevelSystemFontSize)
        label3:setTextColor(color)
        label3:align(display.CENTER,282,itemHeight / 2 + height):addTo(node)

        local label4 = GameString.createLabel(value.targetExp,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.LevelSystemFontSize)
        label4:setTextColor(color)
        label4:align(display.CENTER,395,itemHeight / 2 + height):addTo(node)

        if value.chips ~= nil and value.chips ~= "" then
            if #other == 0 then
                local label5 = GameString.createLabel(value.chips,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.LevelSystemFontSize)
                label5:setTextColor(color)
                label5:align(display.CENTER,522,itemHeight / 2 + height):addTo(node)
            elseif #other > 0 then
                local itemsNum = #other + 1
                for index = 0,#other do
                    local content = value.chips
                    if index == 0 then
                        content = value.chips
                    else
                        content = other[index]
                    end
                    local label5 = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.LevelSystemFontSize)
                    label5:setTextColor(othersColor)
                    label5:align(display.CENTER,522,(1 - (2 * (index + 1) - 1) / (2 * itemsNum)) *  itemHeight + height):addTo(node)
                end
            end
        end
        height = height + itemHeight
    end
    node:setContentSize(cc.size(ItemWidth,height))
    return node
end

function View:ctor(...)
    self:enableNodeEvents()
    self.size = ...
    self.size.width = ItemWidth
    
    if g_AppManager:getAppVer() == g_AppManager.S_APP_VER.FB_VN then
        self:requestLevelData()
    else
        self.data = GameString.get('str_level_system_detail')
        self:initScrollView()
    end
end

function View:requestLevelData()
    local url = g_AppManager:getLoginUrl().."m.php"
    local params = HttpCmd:getMethod(HttpCmd.s_cmds.GET_LEVEL_DATA)
    g_HttpManager:doPostWithUrl(url,params, self, self.onRequestLevelDataResponse);
end

function View:onRequestLevelDataResponse(isSuccess, data)
    self.data = g_TableLib.copyTab(GameString.get('str_level_system_detail'))
    if isSuccess then
        for k,v in ipairs(data) do
            self.data[#self.data + 1] = v 
        end
    end
    self:initScrollView()
end

function View:initScrollView()
    local content = createTable(self.data)
    local gameString = cc.exports.GameString
    local scrollView = ccui.ListView:create()
    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);--方向  横－竖
    scrollView:setIgnoreAnchorPointForPosition(false)
    scrollView:setBounceEnabled(true) 
    scrollView:setContentSize(self.size) 
    scrollView:setScrollBarEnabled(false)
    scrollView:addTo(self)
    g_NodeUtils:arrangeToCenter(scrollView)

    local pageViewLayout = ccui.Layout:create()
    pageViewLayout:setContentSize(self.size.width,content:getContentSize().height)
    pageViewLayout:addChild(content)
    scrollView:pushBackCustomItem(pageViewLayout)
end

return View