--[[
    author:{JanRoid}
    time:2019-5-6 
    Description: 提示弹框
]] 

local ViewBase = cc.load("mvc").ViewBase;

local NoticePop = class("NoticePop",ViewBase)

function NoticePop.getInstance( )
    if not NoticePop.s_instance then
        NoticePop.s_instance = NoticePop.new()
    end

    return NoticePop.s_instance
end

function NoticePop:ctor()
    ViewBase.ctor(self)
    self:init()
end

function NoticePop:init(viewLayout)
	local root = g_NodeUtils:getRootNodeInCreator("creator/layout/notice.ccreator")
    self:add(root)
    self:setVisible(false)

    self.m_lbTitle = self:seekNodeByName("lb_title")
    self.m_txContent = self:seekNodeByName("tx_content")
    self.m_btnOK = self:seekNodeByName("btn_ok")
    self.m_btnTrans = self:seekNodeByName("btn_trans")
    
    self.m_btnOK:addClickEventListener(function()
        self:onOkBtnClick()
    end)

    self.m_btnTrans:addClickEventListener(function()
        
    end)

    local node = cc.Director:getInstance():getNotificationNode()
    if node then
        node:add(self)
    end
end

function NoticePop:setContent(title, content)
    if title then
        self.m_lbTitle:setString(title)
    end

    if content then
        self.m_txContent:setXMLData(content)
    end

    return self
end

function NoticePop:addBtnListener(obj,func)
    self.m_obj = obj
    self.m_func = func

    return self
end

function NoticePop:onOkBtnClick( )
    if self.m_func then
        self.m_func(self.m_obj)
    end

    self:hidden()
end


function NoticePop:show()
    if not self:isVisible() then
        self:setVisible(true)
	end

end

function NoticePop:hidden()
    if self:isVisible() then
        self:setVisible(false)
    end
    
    self:clear()
end

function NoticePop:clear( )
    self.m_func = nil
    self.m_obj = nil
end



return NoticePop