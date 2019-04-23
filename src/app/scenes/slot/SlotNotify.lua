--[[
    author:{JanRoid}
    time:2019-1-28 15:09:35
    Description:老虎机通知弹框，继承至notice
]] 
local AlarmTips = import("app/common/customUI").AlarmTips

local SlotNotify = class("SlotNotify",AlarmTips)

SlotNotify.S_NOTICE_DURATION = 3.0; --消失时间

function SlotNotify:getInstance( )
    if not SlotNotify.s_slotNotify  then
		SlotNotify.s_slotNotify = SlotNotify:create()
	end

	return SlotNotify.s_slotNotify
end

function SlotNotify:loadLayout( )
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/slot/ly_slot_notify.ccreator')   
    self:addChild(self.m_root)
    self.m_background = g_NodeUtils:seekNodeByName(self.m_root,"background")
    self.m_textView = g_NodeUtils:seekNodeByName(self.m_background,"txMsg")
    self.m_background:setAnchorPoint(cc.p(0,1))
end

function SlotNotify:show( )
    if not self:checkShow() then
        return
    end
    self:setIsShow(true)
    local data = self:removeByQueue()
    local content = data.content

    self.m_textView:setXMLData(content or "")

    self:setVisible(true);

    self:runAnim(-1)
end


return SlotNotify