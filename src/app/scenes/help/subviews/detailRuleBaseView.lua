local View = class("DetailRuleBaseView",cc.Node)
local ItemWidth = 610

local Item = class("BetRuleItem",cc.Node)

function Item:ctor(title,content)
    local contentBg = display.newSprite("creator/help/res/betRuleContentBg.png",{capInsets = cc.rect(0,0,10,10),rect = cc.rect(4,4,2,2)})

    local image = display.newSprite("creator/help/res/ruleTitleBg.png")
    local bgSize = image:getContentSize()
    local title = GameString.createLabel(title,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize)
    title:setTextColor(cc.c4b(0xda,0xe5,0xf1,0xff))
    title:align(display.LEFT_CENTER,18,bgSize.height / 2):addTo(image)

    local content = GameString.createLabel(content,g_DefaultFontName,g_AppManager:getAdaptiveConfig().Help.SubViewFontSize2,cc.size(ItemWidth - 30,0))
    local height = content:getContentSize().height + 20 + 5 + image:getContentSize().height
    contentBg:setContentSize(cc.size(ItemWidth - 10,height))
    contentBg:align(display.LEFT_BOTTOM,5,0):addTo(self)

    content:align(display.LEFT_BOTTOM,10,20):addTo(contentBg)
    image:align(display.LEFT_TOP,-5,height + 5):addTo(contentBg)

    self:setContentSize(cc.size(ItemWidth,height + 30))
end

function View:initView(...)
    self.size = ...
    self.size.width = ItemWidth
    self:enableNodeEvents()
    self.itemsNode = {}
end

function View:setData(data)
    self.data = data
    self:createUI()
    self:initTableView()
end

function View:createUI()
    local gameString = cc.exports.GameString
    for i,v in ipairs(self.data) do
        self.itemsNode[#self.itemsNode + 1] = Item:create(v.title,v.content)
    end
    for i,node in ipairs(self.itemsNode) do
        node:retain()
    end
end

function View:onCleanup()
    for i,node in ipairs(self.itemsNode) do
        node:release()
    end
end


function View:initTableView()
    local function cellSize(tb,idx)
        local nodeSize = self.itemsNode[idx + 1]:getContentSize()
        local height = nodeSize.height
        if idx + 1 == #self.itemsNode then
            height = height - 30
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
            content:addTo(cell):align(display.LEFT_BOTTOM,0,0)
        else
            content:addTo(cell):align(display.LEFT_BOTTOM,0,30)
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
    tableView:setDelegate()
    tableView:reloadData()
    tableView:align(display.CENTER,0,0):addTo(self)
end



return View