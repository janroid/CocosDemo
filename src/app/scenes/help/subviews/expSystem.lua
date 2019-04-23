local View = class("ExpSystem",cc.Node)
local ItemWidth = 610

local function createTitle(content)
    local node = display.newNode()
    local title = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize)
    title:setTextColor(cc.c4b(0x6d,0xd0,0xee,0xff))
    title:align(display.LEFT_BOTTOM,10,10):addTo(node)
    node:setContentSize(cc.size(ItemWidth,10 + title:getContentSize().height))
    return node
end

local function createTips(contents)
    local content = ""
    for i,v in ipairs(contents) do
        content =  content .. v
        if i ~= #contents then
            content = content .. "\n"
        end
    end
    local node = display.newNode()

    local contentBg = display.newSprite("creator/help/res/feedbackItemBg.png",{capInsets = cc.rect(0,0,10,10),rect = cc.rect(4,4,2,2)})
    local content = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2,cc.size(ItemWidth - 40,0))
    content:setTextColor(cc.c4b(0x4b,0x8f,0xe3,0xff))
    contentBg:setContentSize(cc.size(610 - 20,content:getContentSize().height + 20))

    content:align(display.LEFT_BOTTOM,20,10):addTo(contentBg)
    node:setContentSize(cc.size(ItemWidth,contentBg:getContentSize().height + 20))
    contentBg:addTo(node):align(display.CENTER_BOTTOM,ItemWidth / 2,20)
    return node
end

local function createLabel(content)
    local node = display.newNode()
    local title = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2,cc.size(610 - 20,0))
    title:setTextColor(cc.c4b(0xc4,0xd6,0xec,0xff))
    title:align(display.LEFT_BOTTOM,10,10):addTo(node)
    node:setContentSize(cc.size(ItemWidth,10 + title:getContentSize().height))
    return node
end

local function createTable(data)
    local node = display.newNode()
    local height = 10
    for i=#data,1,-1 do
        local value = data[i]
        local line = display.newSprite("creator/help/res/line1.png")
        line:align(display.LEFT_BOTTOM,0,height):addTo(node)

        local color = cc.c4b(0xc4,0xd5,0xec,0xff)
        if value.fontStyle and value.fontStyle.color then
            local newColor = value.fontStyle.color
            color = cc.c4b(newColor.r,newColor.g,newColor.b,0xff)
        end

        local title1 = GameString.createLabel(value.time,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2)
        title1:setTextColor(color)
        title1:align(display.LEFT_CENTER,13,15 + height):addTo(node)

        local title1 = GameString.createLabel(value.exp,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2)
        title1:setTextColor(color)
        title1:align(display.RIGHT_CENTER,593,15 + height):addTo(node)

        height = height + 30
    end
    node:setContentSize(cc.size(ItemWidth,height))
    return node
end


function View:onCleanup()
    for i,node in ipairs(self.itemsNode) do
        node:release()
    end
end

function View:ctor(...)
    self:enableNodeEvents()
    self.size = ...
    self.size.width = ItemWidth
    local data =  GameString.get('str_exp_system_detail')
    local gameString = cc.exports.GameString
    local node1 = createTitle(gameString.get("str_help_level1"))
    local node2 = createLabel(gameString.get("str_help_level2"))
    local node3 = createTips({gameString.get("str_help_level3"),gameString.get("str_help_level4")})
    local node4 = createTitle(gameString.get("str_help_level5"))
    
    local node5 = createTable(data)
    local node6 = createTips({gameString.get("str_help_level8")})
    self.itemsNode = {node1,node2,node3,node4,node5,node6}
    for i,v in ipairs(self.itemsNode) do
        v:retain()
    end
    self:initTableView()
end

function View:initTableView()
    local function cellSize(tb,idx)
        local nodeSize = self.itemsNode[idx + 1]:getContentSize()
        local height = nodeSize.height
        if idx + 1 == #self.itemsNode then
            height = height - 20
        end
        return ItemWidth,height
    end
    local function cells()
        return #self.itemsNode
    end
    local function cellAtIndex(tb,idx)
        idx = idx + 1
        local cell = tb:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
        end
        cell:removeAllChildren(false)
        local content = self.itemsNode[idx]
        content:removeFromParent(false)
        if idx == #self.itemsNode then
            content:addTo(cell):align(display.LEFT_BOTTOM,0,-20)
        else
            content:addTo(cell):align(display.LEFT_BOTTOM,0,0)
        end
        return cell
    end
    local tableView = cc.TableView:create(self.size)
    tableView:setIgnoreAnchorPointForPosition(false)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
    tableView:registerScriptHandler(cellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(cells, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSize, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:setDelegate()
    tableView:reloadData()
    tableView:align(display.CENTER,0,0):addTo(self)
end



return View