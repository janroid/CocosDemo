--[[
    author:{JanRoid}
    time:2019-1-25 15:09:35
    Description:Mtt通知弹框，继承至notice
]] 
local AlarmTips = import("app/common/customUI").AlarmTips

local MttNotify = class("MttNotify",AlarmTips)

MttNotify.S_NOTICE_DURATION = 6.0; --消失时间

function MttNotify:getInstance( )
    if not MttNotify.s_mttNotify then
		MttNotify.s_mttNotify = MttNotify:create()
	end

	return MttNotify.s_mttNotify
end

function MttNotify:loadLayout( )
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/mttLobbyScene/layout/mttNotify.ccreator')   
    self:addChild(self.m_root)
    self.m_background = g_NodeUtils:seekNodeByName(self.m_root,"background")
    self.m_textView = g_NodeUtils:seekNodeByName(self.m_background,"txMsg")
    self.m_btnEnter = g_NodeUtils:seekNodeByName(self.m_root,"btn_one")
    self.m_txEnter = g_NodeUtils:seekNodeByName(self.m_root, "tx_one")
    self.m_background:setAnchorPoint(cc.p(0,1))
    
    self.m_btnEnter:addClickEventListener(function()
        if type(self.callBack) == "function" then
            self.m_btnEnter:setEnabled(false)
            self.callBack()
            self:runAnim(1)
        end
    end)
end

--[[
    @desc: 设置内容
    --@data: 数据格式：{title = “”, btnTx = "", callBack = function()}
    @return:
]]
function MttNotify:setText(data)
    if data and next(data) ~= nil then
        self:addToQueue({obj = self, content = data})
    end

    return self
end

function MttNotify:show( )
    if not self:checkShow() then
        return
    end
    self:setIsShow(true)
    local data = self:removeByQueue()
    local content = data.content

    self.m_textView:setString(content.title or "")
    self.m_txEnter:setString(content.btnTx or GameString.get("str_new_mtt_list_enter"))
    
    self.callBack = content.callBack
    self:setVisible(true);
    self.m_btnEnter:setEnabled(true)
    self:runAnim(-1)
end


return MttNotify