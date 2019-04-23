--[[
    AlarmTips 扩展类  能设置图片和按钮
]] 
local AlarmTips = require(".AlarmTips")
local TopTips = class("TopTips", AlarmTips)

function TopTips.getInstance()
	if not TopTips.s_TopTips then -- 单例模式下继承时，注意变量继承
		TopTips.s_TopTips = TopTips:create()
    end

	return TopTips.s_TopTips
end

function TopTips:ctor()
    AlarmTips.ctor(self)
    
    self.m_img = cc.Sprite:create()
    self.m_img:setContentSize(54, 54)
    self.m_btn = ccui.Button:create("creator/common/button/btn_blue_short_normal.png")
    
    self.m_background:addChild(self.m_img)
    self.m_background:addChild(self.m_btn)
    self.m_btn:setZoomScale(-0.04)
    self.m_btn:setSize(120, 52)
            :setTitleFontSize(24)
            :ignoreContentAdaptWithSize(false)
            :addClickEventListener(function()
            if self.m_callBack then
                self.m_btn:setEnabled(false)
                self.m_callBack()
                self:runAnim(1)
            end
    end)
    self.m_btn:getTitleRenderer():setOverflow(cc.LabelOverflow.SHRINK)
    self.m_btn:getTitleRenderer():setDimensions(115, 52)
    self.m_btn:getTitleRenderer():setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.TEXT_ALIGNMENT_CENTER)
    
    g_NodeUtils:arrangeToRightCenter(self.m_btn, -30)
    g_NodeUtils:arrangeToLeftCenter(self.m_img, 30)
    
    local width = self.m_background:getContentSize().width - self.m_btn:getContentSize().width - self.m_img:getContentSize().width - 20
    local height = self.m_background:getContentSize().height
    self.m_textView:setContentSize(cc.size(width, height))
    self.m_textRich:setContentSize(cc.size(width, height))
    g_NodeUtils:arrangeToCenter(self.m_textView)
    g_NodeUtils:arrangeToCenter(self.m_textRich)
end

function TopTips:setData(data)
    if type(data) == "table" then
        self:addToQueue({obj = self, content = data})
    end
    return self
end

function TopTips:show( )
    if not self:checkShow() then
        return
    end
    self:setIsShow(true)
    local data = self:removeByQueue()
    local content = data.content
    
    local text = content.text
    if string.find(text, "<color") then
        self.m_textRich:setXMLData(text)
        self.m_textRich:setVisible(true)
        self.m_textView:setVisible(false)
    else
        self.m_textView:setString(text)
        self.m_textRich:setVisible(false)
        self.m_textView:setVisible(true)
    end
    
    if content.needBtn then
        self.m_btn:setVisible(true)
        self.m_btn:setEnabled(true)
        self.m_btn:setTitleText(content.btnTx or GameString.get("str_common_confirm"))
        self.m_callBack = content.callBack
    else
        self.m_btn:setVisible(false)
    end
    
    if content.needImg then
        self.m_img:setVisible(true)
        self.m_img:setTexture(content.imgPath)
        self.m_img:setContentSize(54, 54)
    else
        self.m_img:setVisible(false)
    end
    self:setVisible(true);
    self:runAnim(-1)
end

return TopTips
