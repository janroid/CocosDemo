--[[
    author:{JanRoid}
    time:2019-1-29 10:09:35
    Description:广播消息通知栏，继承至AlarmTips
]] 
local AlarmTips = require("AlarmTips")

local BroadcastNotify = class("BroadcastNotify",AlarmTips)

BroadcastNotify.S_NOTICE_DURATION = 5.0; --消失时间

BroadcastNotify.S_FILE_LABA = "creator/common/dialog/trumper.png"

function BroadcastNotify:getInstance( )
    if not BroadcastNotify.s_broadcastNotify  then
		BroadcastNotify.s_broadcastNotify = BroadcastNotify:create()
	end

	return BroadcastNotify.s_broadcastNotify
end

function BroadcastNotify:loadLayout( )
    self.m_root = g_NodeUtils:getRootNodeInCreator('creator/common/layout/broadcast_tips.ccreator')   
    self:addChild(self.m_root)
    self.m_background = g_NodeUtils:seekNodeByName(self.m_root,"background")
    self.m_textView = g_NodeUtils:seekNodeByName(self.m_background,"txMsg")
    self.m_btnJump = g_NodeUtils:seekNodeByName(self,"btn_jump")
    self.m_txJump = g_NodeUtils:seekNodeByName(self,"tx_jump")
    self.m_imgTitle = g_NodeUtils:seekNodeByName(self,"img_title")

    self.m_btnJump:setVisible(false)
    self.m_background:setAnchorPoint(cc.p(0,1))
end

--[[
    @desc: 设置内容
    --@data: {
        text = "", 
        img = “”,  传图片地址，nil表示隐藏，-1表示显示小喇叭图标，
        btnTx = "", callBack = function()  必须同时传入，nil表示隐藏btn
        }
    @return:
]]
function BroadcastNotify:setText(data)
    if data and next(data) ~= nil then
        self:addToQueue({obj = self, content = data})
    end

    return self
end

function BroadcastNotify:show( )
    if not self:checkShow() then
        return
    end
    self:setIsShow(true)
    local data = self:removeByQueue()
    local content = data.content
    local text = content.text or ""
    local img = content.img
    local btnTx = content.btnTx
    local callBack = content.callBack

    self.m_textView:setString(text)
    -- 图标
    if img then
        self.m_imgTitle:setVisible(true)
        if img == -1 then
            self.m_imgTitle:setTexture(BroadcastNotify.S_FILE_LABA)
        else
            self.m_imgTitle:setTexture(img)
        end
    else
        self.m_imgTitle:setVisible(false)
    end
    -- 按钮
    if callBack then
        self.m_txJump:setString(btnTx)
        self.m_btnJump:addClickEventListener(function()
            callBack()
        end)
        self.m_btnJump:setVisible(true)
    else
        self.m_btnJump:setVisible(false)
    end

    self:setVisible(true);
    self:runAnim(-1)
end


return BroadcastNotify