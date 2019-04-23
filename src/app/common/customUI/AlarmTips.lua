--[[
    author:{JanRoid}
    time:2019-1-30 15:09:35
	Description:游戏消息的基础弹框,单纯显示提示，没有按钮
				如果其他功能需要用到扩展的提示弹框，请继承该类实现，不要在这个类上面扩展
				如何继承请参考MTTNotify.lua
]] 

local AlarmTips = class("AlarmTips",cc.Node)

AlarmTips.S_NOTICE_DURATION = 4.0; --消失时间
AlarmTips.S_NOTICE_ACTION_DURATION = 0.2; --出现和消失动画时间

function AlarmTips.getInstance( )
	if not AlarmTips.s_alarmTips then -- 单例模式下继承时，注意变量继承
		AlarmTips.s_alarmTips = AlarmTips:create()
    end

	return AlarmTips.s_alarmTips
end

function AlarmTips:ctor()
    self:loadLayout()
    cc.Director:getInstance():getNotificationNode():addChild(self)	
	local function onNodeEvent(event)   
		if event == "enter" then
			self:onEnter()
        elseif event == "cleanup" then                                   
            self:onCleanup()                                   
        end  
    end  
	self:registerScriptHandler(onNodeEvent) 
    self:setLocalZOrder(9999)
    
    self:setVisible(false)
    AlarmTips.m_msgMap = {}
end

function AlarmTips:loadLayout( )
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/common/layout/alarm_tips.ccreator')   
    self:addChild(self.m_root)
    self.m_background = g_NodeUtils:seekNodeByName(self.m_root,"background")
    self.m_textView = g_NodeUtils:seekNodeByName(self.m_background,"txMsg")
    self.m_textRich = g_NodeUtils:seekNodeByName(self, "txRich")
    self.m_background:setAnchorPoint(cc.p(0,1))
    
    local MarqueeText = import("app.common.customUI").MarqueeText
    local size = self.m_background:getContentSize()
    local marText = MarqueeText:create(size.width -20, size.height)
    self.m_background:addChild(marText)
    g_NodeUtils:arrangeToCenter(marText)
    marText:setTextView(self.m_textView)
    self.m_textView = marText
    
    marText = MarqueeText:create(size.width - 20, size.height)
    self.m_background:addChild(marText)
    g_NodeUtils:arrangeToCenter(marText)
    marText:setTextView(self.m_textRich)
    self.m_textRich = marText
end

function AlarmTips:setText(str)
    if str and string.len(str) > 0 then
        self:addToQueue({obj = self, content = str})
    end

    return self
end

function AlarmTips:setTextAndShow(str)
    if str and string.len(str) > 0 then
        self:addToQueue({obj = self, content = str})
    end
    self:show()
end

function AlarmTips:show()
    if not self:checkShow() then
        return
    end
    self:setIsShow(true)
    local content = self:removeByQueue()
    local text = content.content

    local dw
    if string.find(text, "<color") then
        self.m_textRich:setXMLData(text)
        self.m_textRich:setVisible(true)
        self.m_textView:setVisible(false)
        dw = self.m_textRich:getTextSize().width - self.m_background:getContentSize().width
    else
        self.m_textView:setString(text)
        self.m_textRich:setVisible(false)
        self.m_textView:setVisible(true)
        dw = self.m_textView:getTextSize().width - self.m_background:getContentSize().width
    end

    self:setVisible(true);
    
    if dw > 0 then
        self.S_NOTICE_DURATION = AlarmTips.S_NOTICE_DURATION + dw / 200
    end
    self:runAnim(-1)
end

--[[
    @desc: 动画
    --@mtype: -1:出现动画，1：消失动画
    @return:
]]
function AlarmTips:runAnim(mtype)
    local size = self.m_background:getContentSize()
    local height = size.height * mtype
    self:clearAll()

    local moveBy = cc.MoveBy:create(self.S_NOTICE_ACTION_DURATION, cc.p(0,height))
    local callBack = cc.CallFunc:create(function()
        if mtype == 1 then
            self:hidden()
        else
            self.m_hideTimer = g_Schedule:schedulerOnce(function()
                self:runAnim(1)
            end,self.S_NOTICE_DURATION)
        end
    end)
    local action = cc.Sequence:create(moveBy, callBack)
    self.m_background:runAction(action)

end

function AlarmTips:onRightBtnClick()
    if self.m_rightBtnFunc then
		self.m_rightBtnFunc(self.m_rightArgs);
	end
	self:hidden()
end

function AlarmTips:onEnter( )
	-- body
end

function AlarmTips:onCleanup()
	self:clearAll()
end

function AlarmTips:hidden()
    self:setVisible(false)
    self:setIsShow(false)
    if #AlarmTips.m_msgMap > 0 then
        local obj = AlarmTips.m_msgMap[#AlarmTips.m_msgMap].obj
        obj:show()
    end
end

--[[
    @desc: 实现消息提示队列的功能，不可重写
    author:{JanRoid}
    --@data: 数据结构：{obj(AlarmTips或其子类实例),content(实例内部提示内容数据，可以自定义)}
    @return:
]]
function AlarmTips:addToQueue(data)
    if self.m_msgMap[1] then -- 连续相同提示信息，不加入队列，减少重复信息提示
        if type(self.m_msgMap[1]) == "table" then
            if g_TableLib.equal(self.m_msgMap[1],data) then
                return
            end
        else
            if self.m_msgMap[1] == data then
                return
            end
        end
    end

    table.insert(AlarmTips.m_msgMap,1,data)
end

--[[
    @desc: 不可重写
    author:{JanRoid}
    @return:
]]
function AlarmTips:removeByQueue( )
    return table.remove(AlarmTips.m_msgMap)
end

function AlarmTips:isShowing( )
    return AlarmTips.m_isShow
end

function AlarmTips:setIsShow(bo)
    AlarmTips.m_isShow = bo
end

function AlarmTips:checkShow()
    if self:isShowing() or #AlarmTips.m_msgMap <= 0 then
        return false
    end
    return true
end

function AlarmTips:clearAll()
    g_Schedule:cancel(self.m_hideTimer)
end


return AlarmTips
