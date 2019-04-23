local LoginFeedback = class("LoginFeedback",cc.Node)
local HttpCmd = import("app.config.config").HttpCmd

function LoginFeedback:ctor(...)
    self:enableNodeEvents()
    self.size = ...
    self:createUI()
    g_EventDispatcher:register(g_SceneEvent.FEEDBACK_ONSHOW,self,self.onShow)
end

function LoginFeedback:onCleanup()
    g_EventDispatcher:unregister(g_SceneEvent.FEEDBACK_ONSHOW,self,self.onShow)
end

function LoginFeedback:onShow()
    self.topContent:setString('')
    self.topEditBox:setText('')
    self.topLastValue = ''
    self.topPlaceHolderLabel:setVisible(true)
    self.middleEditBox:setText("")
    self.middleContent:setString("")
    self.middleLastValue = ""
    self.middlePlaceHolderLabel:setVisible(true)
    self.sendBtn:setEnabled(false)
end

function LoginFeedback:createUI()
    local gameString = cc.exports.GameString

    local topBgSize = cc.size(580,210)
    local contentSizeMax = cc.size(topBgSize.width - 40,topBgSize.height - 40)
    local topInputBg = display.newSprite("creator/help/res/inputBg.png",{capInsets = cc.rect(0,0,10,10),rect = cc.rect(4,4,2,2)})
    topInputBg:setContentSize(topBgSize)
    topInputBg:align(display.CENTER_TOP,0,220):addTo(self)

    self.topPlaceHolderLabel = GameString.createLabel(gameString.get("str_help_login_feedback1"),g_DefaultFontName, 22,cc.size(topBgSize.width - 40,0))
    self.topPlaceHolderLabel:align(display.LEFT_TOP,20,topBgSize.height - 20):addTo(topInputBg)
    self.topPlaceHolderLabel:setTextColor(cc.c4b(0x82,0x91,0x9b,0xff))

    local topScrollView = cc.ScrollView:create(contentSizeMax)
    topScrollView:setIgnoreAnchorPointForPosition(false)
    topScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);--方向  横－竖
    topScrollView:setDelegate()
    topScrollView:align(display.LEFT_TOP,20,topBgSize.height - 20):addTo(topInputBg)

    local topContent =  GameString.createLabel("",g_DefaultFontName, 22,cc.size(contentSizeMax.width,0))
    topContent:align(display.LEFT_BOTTOM,0,0):addTo(topScrollView)
    topContent:setTextColor(cc.c4b(0x5b,0x68,0x7c,0xff))
    self.topContent = topContent

    local topEditBox = ccui.EditBox:create(topBgSize,"creator/help/res/blank.png")
    topEditBox:align(display.LEFT_BOTTOM,0,0):addTo(topInputBg)
    topEditBox:setFontSize(22)
    topEditBox:setFontColor(cc.c4b(0x5b,0x68,0x7c,0xff))
    self.topEditBox = topEditBox

    local function updateContent(content)
        topContent:setString(content)
        local newSize = topContent:getContentSize()
        local newViewSize = clone(contentSizeMax)
        topScrollView:setBounceable(true)
        if newSize.height < contentSizeMax.height then
            newViewSize.height = newSize.height
            topScrollView:setBounceable(false)
        end
        topScrollView:setViewSize(newViewSize)
    end

    self.topLastValue = ""
    local function editboxEventHandler(eventType,sender)
        if eventType == "began" then
            self.topPlaceHolderLabel:setVisible(false)
            topScrollView:setVisible(false)
            sender:setText(self.topLastValue)
        elseif eventType == "ended" then
            self.topLastValue = sender:getText()
            sender:setText("")
            if self.topLastValue == "" or self.topLastValue == nil then
                self.topPlaceHolderLabel:setVisible(true)
                topScrollView:setVisible(false)
            else
                self.topPlaceHolderLabel:setVisible(false)
                topScrollView:setVisible(true)
            end
            updateContent(self.topLastValue)
            self:updateSendBtnStatus()
        elseif eventType == "changed" then
        elseif eventType == "return" then
        end
    end
    topEditBox:registerScriptEditBoxHandler(editboxEventHandler)
    

    local middleBgSize = cc.size(512,68)
    local middlecontentSizeMax = cc.size(middleBgSize.width - 10,middleBgSize.height - 20)
    local middleInputBg = display.newSprite("creator/help/res/inputBg.png",{capInsets = cc.rect(0,0,10,10),rect = cc.rect(4,4,2,2)})
    middleInputBg:setContentSize(middleBgSize)
    middleInputBg:align(display.CENTER,0,-37):addTo(self)

    self.middlePlaceHolderLabel = GameString.createLabel(gameString.get("str_help_login_feedback2"),g_DefaultFontName, 22,cc.size(middleBgSize.width - 10,0))
    self.middlePlaceHolderLabel:align(display.LEFT_CENTER,5,middleBgSize.height / 2):addTo(middleInputBg)
    self.middlePlaceHolderLabel:setTextColor(cc.c4b(0x82,0x91,0x9b,0xff))

    local middleContent =  GameString.createLabel("",g_DefaultFontName, 22,cc.size(middlecontentSizeMax.width,0))
    middleContent:align(display.LEFT_CENTER,5,middleBgSize.height / 2):addTo(middleInputBg)
    middleContent:setTextColor(cc.c4b(0x5b,0x68,0x7c,0xff))
    self.middleContent = middleContent

    local middleEditBox = ccui.EditBox:create(middleBgSize,"creator/help/res/blank.png")
    middleEditBox:align(display.LEFT_BOTTOM,0,0):addTo(middleInputBg)
    middleEditBox:setFontSize(22)
    middleEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    -- middleEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    middleEditBox:setFontColor(cc.c4b(0x5b,0x68,0x7c,0xff))
    self.middleEditBox = middleEditBox

    local function updateContent2(content)
        middleContent:setString(content)
    end

    self.middleLastValue = ""
    local function editboxEventHandler2(eventType,sender)
        if eventType == "began" then
            self.middlePlaceHolderLabel:setVisible(false)
            middleContent:setVisible(false)
            sender:setText(self.middleLastValue)
        elseif eventType == "ended" then
            self.middleLastValue = sender:getText()
            sender:setText("")
            if self.middleLastValue == "" or self.middleLastValue == nil then
                self.middlePlaceHolderLabel:setVisible(true)
                middleContent:setVisible(false)
            else
                self.middlePlaceHolderLabel:setVisible(false)
                middleContent:setVisible(true)
            end
            updateContent2(self.middleLastValue)
            self:updateSendBtnStatus()
        elseif eventType == "changed" then
            local middleLastValue = sender:getText()
            local result = string.find(middleLastValue,'\n')
            if result ~= nil then
                local res = string.gsub(middleLastValue,'\n',"")
                sender:setText(res)
                sender:closeKeyboard()
            end
        elseif eventType == "return" then
        end
    end
    middleEditBox:registerScriptEditBoxHandler(editboxEventHandler2)


    local red = GameString.createLabel("*",g_DefaultFontName, 40)
    red:align(display.CENTER,-276,-37):addTo(self)
    red:setTextColor(cc.c4b(0xff,0x00,0x00,0xff))

    local confirmTips = GameString.createLabel(gameString.get("str_help_login_feedback3"),g_DefaultFontName, 24)
    confirmTips:align(display.CENTER,0,-117):addTo(self)
    confirmTips:setTextColor(cc.c4b(0xc4,0xd6,0xec,0xff))

    local sendBtn = ccui.Button:create("creator/common/button/btn_blue_short_normal.png")
        :addTo(self):align(display.CENTER, cc.p(0, -183.6))
    sendBtn:loadTextureDisabled("creator/common/button/btn_blue_short_disable.png")
    sendBtn:setZoomScale(0)
    sendBtn:setEnabled(false)
    sendBtn:onTouch(function(event)
        if event.name == "began" then
            sendBtn:stopAllActions()
            sendBtn:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.96),cc.CallFunc:create(function() 
                sendBtn:setScale(1.0)
            end)))
        end
    end)
    sendBtn:addClickEventListener(function(sender)
        self:sendMsg()
    end)
    self.sendBtn = sendBtn
    local sendTips = GameString.createLabel(gameString.get("str_send"),g_DefaultFontName, 24)
    sendTips:align(display.CENTER,166 / 2,66 / 2 + 3):addTo(sendBtn)
end

function LoginFeedback:updateSendBtnStatus()
    local contanct = self.middleContent:getString()
    local content = self.topContent:getString()

    self.sendBtn:setEnabled(false)
    if contanct ~= "" and content ~= "" then
        self.sendBtn:setEnabled(true)
    end
end

function LoginFeedback:checkPhoneOrEmailValid()
    local contanct = self.middleContent:getString()
    if contanct then
        return (contanct)
    end
    return false
end

function LoginFeedback:sendMsg()

    local contanct = self.middleContent:getString()
    local content = self.topContent:getString()

    local mac = g_SystemInfo:getMacAddr() or ""
    local openUDID = g_SystemInfo:getOpenUDID()

    self.m_type = mac or openUDID;

    local secret = g_Base64.encode("t7z^d~d!Dliji!4o|"..self.m_type)

    if require("config").checkContactValid(contanct) then
        local param =  {
            ["secret"] = secret,
            ["mod"] = "feedback",
            ["act"] = "setBeforeLogin",
            ["type"] = 8000,
            ["content"] = content.." V" .. g_SystemInfo:getVersionName() .. " ##:" .. contanct
        }
        g_HttpManager:doPostWithUrl(g_AppManager:getLoginUrl().."mobilespecial.php", param, self, self.onSendMsgSuccess, self.onSendMsgFailed);
    else
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_help_login_feedback_error"))
    end
end

function LoginFeedback:onSendMsgSuccess(isSuccess)
    Log.d('onSendMsgSuccess',isSuccess)
    if not isSuccess then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_network_err"))
    else
        g_AlarmTips.getInstance():setTextAndShow(tips)
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_help_feedback_sucess"))
        self.topContent:setString("")
        self.topEditBox:setText("")
        self.topLastValue = ""
        self.topPlaceHolderLabel:setVisible(true)
        self.middleEditBox:setText("")
        self.middleContent:setString("")
        self.middleLastValue = ""
        self.middlePlaceHolderLabel:setVisible(true)
        self.sendBtn:setEnabled(false)
    end
end

function LoginFeedback:onSendMsgFailed(response)
    Log.d('onSendMsgFailed',response)
    g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_network_err"))
end

return LoginFeedback
