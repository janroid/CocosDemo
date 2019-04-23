local View = class("",cc.Node)
local ItemWidth = 610

function View:ctor(...)
    self.size = ...
    self.size.width = ItemWidth
    self.initData = {}
    self:createUI()
    self:initTableView()
    self:enableNodeEvents()
end


local function createTitle(title)
    local image = display.newSprite("creator/help/res/ruleTitleBg.png")
    local bgSize = image:getContentSize()
    local title = GameString.createLabel(title,g_DefaultFontName, g_AppManager:getAdaptiveConfig().Help.SubViewFontSize)
    title:setTextColor(cc.c4b(0xda,0xe5,0xf1,0xff))
    title:align(display.LEFT_CENTER,18,bgSize.height / 2):addTo(image)
    return image
end

local function createCommon(title,content)
    local node = display.newNode()
    local title = createTitle(title)
    local titleSize = title:getContentSize()
    local content = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize,cc.size(610 - 34,0))
    content:setTextColor(cc.c4b(0xc4,0xd6,0xec,0xff))
    local nodeSize = cc.size(610,16 + titleSize.height + 8 + content:getContentSize().height + 16)
    node:setContentSize(nodeSize)
    content:align(display.LEFT_BOTTOM,17,16):addTo(node)
    title:align(display.LEFT_TOP,0,nodeSize.height - 16):addTo(node)
    return node
end

function View:createUI()
    local gameString = cc.exports.GameString
    local firstNode = display.newNode()
    local firstTitleBg = createTitle(gameString.get("str_help_rule_dec9"))
    firstTitleBg:align(display.LEFT_TOP,-305,0):addTo(firstNode)
    local firstTitleBgSize = firstTitleBg:getContentSize()
    local firstContent = display.newSprite("creator/help/res/ruleDetailTopBg.png")
    firstContent:align(display.CENTER_TOP,0,0 - firstTitleBgSize.height - 5):addTo(firstNode)

    local function addSprite(sprite,align,pos,title)
        local sprite = display.newSprite(sprite):align(align,pos.x,pos.y):addTo(firstContent)
        if title then
            local spriteSize = sprite:getContentSize()
            local title = GameString.createLabel(title,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2)
            title:setTextColor(cc.c4b(0xff,0xff,0xff,0xff))
            title:align(display.CENTER,spriteSize.width / 2,spriteSize.height / 2):addTo(sprite)
        end
    end
    addSprite("creator/help/res/rulePlayerA.png",display.CENTER_BOTTOM,cc.p(30,102))
    addSprite("creator/help/res/rulePlayerB.png",display.CENTER_BOTTOM,cc.p(395,102))
    addSprite("creator/help/res/rulePlayerA.png",display.CENTER,cc.p(-22,28))
    addSprite("creator/help/res/rulePlayerB.png",display.CENTER,cc.p(461,28))
    addSprite("creator/help/res/ruleLoseBg.png",display.CENTER,cc.p(-58,28),gameString.get("str_help_rule_dec14"))
    addSprite("creator/help/res/ruleWinBg.png",display.CENTER,cc.p(494,28),gameString.get("str_help_rule_dec15"))

    local function addLabel(content,align,pos,color)
        local title = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2)
        title:setTextColor(color)
        title:align(align,pos.x,pos.y):addTo(firstContent)
    end
    addLabel(gameString.get("str_help_rule_dec10"),display.LEFT_CENTER,cc.p(15,230),cc.c4b(0x67,0xd0,0xee,0xff))
    addLabel(gameString.get("str_help_rule_dec11"),display.LEFT_CENTER,cc.p(135,180),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec11"),display.RIGHT_CENTER,cc.p(300,180),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec12"),display.CENTER,cc.p(30,82),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec13"),display.CENTER,cc.p(395,82),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec16"),display.CENTER_TOP,cc.p(13,-5),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec17"),display.CENTER_TOP,cc.p(425,-5),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec18"),display.CENTER_TOP,cc.p(123,-5),cc.c4b(0xc4,0xd6,0xec,0xff))
    addLabel(gameString.get("str_help_rule_dec19"),display.CENTER_TOP,cc.p(314,-5),cc.c4b(0xc4,0xd6,0xec,0xff))
    local height = firstTitleBgSize.height + 10 + firstContent:getContentSize().height + 25
    firstNode:setContentSize(cc.size(305 * 2,height))
    -- firstNode:addTo(self):align(display.CENTER,305,height)

    local node1 = createCommon(gameString.get("str_help_rule_dec1"),gameString.get("str_help_rule_dec2"))
    local node2 = createCommon(gameString.get("str_help_rule_dec3"),gameString.get("str_help_rule_dec4"))
    local node3 = createCommon(gameString.get("str_help_rule_dec5"),gameString.get("str_help_rule_dec6"))
    local node4 = createCommon(gameString.get("str_help_rule_dec7"),gameString.get("str_help_rule_dec8"))
    
    self.itemsNode = {firstNode,node1,node2,node3,node4}
    for i,node in ipairs(self.itemsNode) do
        node:retain()
    end
end

function View:initTableView()
    local function cellSize(tb,idx)
        local nodeSize = self.itemsNode[idx + 1]:getContentSize()
        return ItemWidth,nodeSize.height
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
        local size = content:getContentSize()
        content:setIgnoreAnchorPointForPosition(false)
        if idx == 1 then
            content:addTo(cell):align(display.LEFT_BOTTOM,0 + ItemWidth / 2,size.height)
        else
            content:addTo(cell):align(display.LEFT_BOTTOM,0,0)
        end
        return cell
    end
    local tableView = cc.TableView:create(self.size)
    -- tableView:setBounceable(false)
    tableView:setIgnoreAnchorPointForPosition(false)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置滑动方向
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN) --设置填充方向
    tableView:registerScriptHandler(cellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(cells, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSize, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(cellSize, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:setDelegate()
    tableView:reloadData()
    tableView:align(display.CENTER,0,0):addTo(self)
    self.tableView = tableView
end

function View:onCleanup()
    for i,node in ipairs(self.itemsNode) do
        node:release()
    end
end

return View