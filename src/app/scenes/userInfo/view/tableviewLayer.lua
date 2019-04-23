local TableViewLayer = class("TableViewLayer")
TableViewLayer.__index = TableViewLayer

--这里是为了让layer能调用TableViewLayer的方法
function TableViewLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, TableViewLayer)
    return target
end

--滚动事件
function TableViewLayer.scrollViewDidScroll(view)
    --print("滚动事件")
end

function TableViewLayer.scrollViewDidZoom(view)
    print("scrollViewDidZoom")
end

--cell点击事件
function TableViewLayer.tableCellTouched(table,cell)
    print("点击了cell：" .. cell:getIdx())
end

--cell的大小，注册事件就能直接影响界面，不需要主动调用
function TableViewLayer.cellSizeForTable(table,idx) 
    return 150,150
end

--显示出可视部分的界面，出了裁剪区域的cell就会被复用
function TableViewLayer.tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    print("数据加载"..strValue)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
        print("创建了新的cell")
        cell = cc.TableViewCell:new()

        --添加cell内容
        local sprite = cc.Sprite:create("res/tablecell.png")
        sprite:setAnchorPoint(cc.p(0,0))
        sprite:setPosition(cc.p(0, 0))
        cell:addChild(sprite)

        label = cc.Label:createWithSystemFont(strValue, "Helvetica", 40)
        label:setPosition(cc.p(0,0))
        label:setAnchorPoint(cc.p(0,0))
        label:setColor(cc.c3b(255,0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        print("使用已经创建过的cell")
        label = cell:getChildByTag(123)
        if nil ~= label then
            label:setString(strValue)
        end
    end

    return cell
end

--设置cell个数，注册就能生效，不用主动调用
function TableViewLayer.numberOfCellsInTableView(table)
   return 100
end

function TableViewLayer:init()

    local winSize = cc.Director:getInstance():getWinSize()

    --创建TableView
    local tableView = cc.TableView:create(cc.size(600,200))
    --设置滚动方向  水平滚动
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setPosition(cc.p(20, winSize.height / 2 - 150))
    tableView:setDelegate()
    self:addChild(tableView)
    --registerScriptHandler functions must be before the reloadData funtion
    --注册脚本编写器函数必须在reloadData函数之前（有道自动翻译）

    --cell个数
    tableView:registerScriptHandler(TableViewLayer.numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    --滚动事件
    tableView:registerScriptHandler(TableViewLayer.scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(TableViewLayer.scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    --cell点击事件
    tableView:registerScriptHandler(TableViewLayer.tableCellTouched,cc.TABLECELL_TOUCHED)
    --cell尺寸、大小
    tableView:registerScriptHandler(TableViewLayer.cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    --显示出可视部分的cell
    tableView:registerScriptHandler(TableViewLayer.tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    --调用这个才会显示界面
    tableView:reloadData()


    -----------------------------------------------------------
    --跟上面差不多，这里是创建一个“垂直滚动”的TableView
    tableView = cc.TableView:create(cc.size(200, 350))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(cc.p(winSize.width - 150, winSize.height / 2 - 150))
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self:addChild(tableView)
    tableView:registerScriptHandler(TableViewLayer.scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(TableViewLayer.scrollViewDidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(TableViewLayer.tableCellTouched,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(TableViewLayer.cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(TableViewLayer.tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(TableViewLayer.numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    
    

    return true
end

--这里是为了让layer能调用TableViewLayer的方法
function TableViewLayer.create()
    local layer = TableViewLayer.extend(cc.Layer:create())
    if nil ~= layer then
        layer:init()
    end

    return layer
end

--运行测试场景
function runTableViewTest()
    local newScene = cc.Scene:create()
    local newLayer = TableViewLayer.create()
    newScene:addChild(newLayer)
    cc.Director:getInstance():replaceScene(newScene)
    --return newScene
end

runTableViewTest()

return TableViewLayer