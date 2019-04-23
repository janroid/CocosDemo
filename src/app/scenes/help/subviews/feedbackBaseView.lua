local ViewEvent = require("subviews.baseEventView")
local BaseView = class("baseView",cc.Node,ViewEvent)
local HttpCmd = import("app.config.config").HttpCmd

local ItemSize = cc.size(580,180)
local Item = class("Item",ccui.Layout)
function Item:ctor(tab)
    self:enableNodeEvents()
    self.m_root = g_NodeUtils:getRootNodeInCreator("creator/help/subviews/feedbackItem.ccreator");
    self:add(self.m_root)

    self.m_txQuestion = g_NodeUtils:seekNodeByName(self.m_root, 'tx_question')
    self.m_txAnswer = g_NodeUtils:seekNodeByName(self.m_root, 'tx_answer')
    self.m_txTime = g_NodeUtils:seekNodeByName(self.m_root, 'tx_time')

    self.m_feedBackId = 1001

end

function Item:updateCell(data)
    self.m_txQuestion:setString(data.title)
    if data.content == nil or data.content == '' then
        self.m_txAnswer:setString(GameString.get('str_help_login_feedback_not_handle'))
    else
        self.m_txAnswer:setString(data.content)
    end
    
    self.m_txTime:setString(g_TimeLib.getRegularDate(data.time))

    self.m_bg = g_NodeUtils:seekNodeByName(self.m_root, 'feedbackItemBg')
    self.m_bg:forceDoLayout()
    local size = self.m_bg:getContentSize()
    self:setContentSize(cc.size(size.width,size.height+20))

    Log.d('size',size)
    local x,y = self.m_bg:getPosition()
    self.m_bg:setPosition(cc.p(x,y + (size.height - 111)))

end

function BaseView:initView(...)
    self.size = ...
    self:createUI()
    g_EventDispatcher:register(g_SceneEvent.FEEDBACK_SUBMIT_SUCCESS,self,self.getFeedBackList)
end

function BaseView:onCleanup()
    if self.m_imgPath and self.m_imgPath ~= "" then
        cc.TextureCache:getInstance():removeTextureForKey(self.m_imgPath)
    end
    g_EventDispatcher:unregister(g_SceneEvent.FEEDBACK_SUBMIT_SUCCESS,self,self.getFeedBackList)
end

function BaseView:dtor()
    if self.m_imgPath and self.m_imgPath ~= "" then
        cc.TextureCache:getInstance():removeTextureForKey(self.m_imgPath)
    end
    g_EventDispatcher:unregister(g_SceneEvent.FEEDBACK_SUBMIT_SUCCESS,self,self.getFeedBackList)
end

function BaseView:createUI()
    local gameString = cc.exports.GameString

    local topBgSize = cc.size(395,205)
    local contentSizeMax = cc.size(topBgSize.width - 20,topBgSize.height - 20)
    local topInputBg = display.newSprite("creator/help/res/inputBg.png",{capInsets = cc.rect(0,0,10,10),rect = cc.rect(4,4,2,2)})
    topInputBg:setContentSize(topBgSize)
    topInputBg:align(display.LEFT_TOP,-290,200):addTo(self)

    local topPlaceHolderLabel = GameString.createLabel("",g_DefaultFontName, 22,cc.size(topBgSize.width - 20,0))
    topPlaceHolderLabel:align(display.LEFT_TOP,10,topBgSize.height - 5):addTo(topInputBg)
    topPlaceHolderLabel:setTextColor(cc.c4b(0x82,0x91,0x9b,0xff))
    self.topPlaceHolderLabel = topPlaceHolderLabel

    local topScrollView = cc.ScrollView:create(contentSizeMax)
    topScrollView:setIgnoreAnchorPointForPosition(false)
    topScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);--方向  横－竖
    topScrollView:setDelegate()
    topScrollView:align(display.LEFT_TOP,10,topBgSize.height - 10):addTo(topInputBg)

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

    -- display.newSprite("creator/help/res/uploadBg.png"):align(display.CENTER,208,128):addTo(self)
    self.m_uploadImgBtn = ccui.Button:create("creator/help/res/uploadBg.png"):align(display.CENTER,208,128):addTo(self)
    self.m_uploadImgBtn:addClickEventListener(function(sender)
        self:uploadImg()
    end)
    
    local sendBtn = ccui.Button:create("creator/common/button/btn_blue_short_normal.png")
        :addTo(self):align(display.CENTER, cc.p(206, 39))
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

    self.m_listView = ccui.ListView:create()
    self.m_listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL);--方向  横－竖
    self.m_listView:setBounceEnabled(true) 
    self.m_listView:setContentSize(ItemSize) 
    self.m_listView:align(display.LEFT_TOP,-290,-23):addTo(self)

    self.itemsData = {}
    self:updateListView()
end

function BaseView:updateListView()
    self.m_listView:removeAllChildren()
    for i=1,#self.itemsData do
        local item = Item:create()
        item:updateCell(self.itemsData[i])
        self.m_listView:pushBackCustomItem(item)
    end
end

function BaseView:updateSendBtnStatus()
    local content = self.topContent:getString()
    self.sendBtn:setEnabled(false)
    if content ~= "" then
        self.sendBtn:setEnabled(true)
    end
end

function BaseView:setStatusData(data)
    self.itemsData = data
    self:updateListView()
end

function BaseView:sendMsg()
    local content = self.topContent:getString()
    if content ~= "" then
        g_Progress.getInstance():show()
        if self.m_imgPath and self.m_imgPath ~= "" then
            local params =
            {
                ["mod"] = "feedback",
                ["act"] = "setNew",
                ["type"] = self.m_feedBackId,
            };

            params = g_HttpManager:getPostData(params)
            local url = g_HttpManager:getDefaultStaticUrl() .. "?" .. params;
            
            local param = {
                Url = url;
                imgPath = self.m_imgPath;
                content = content;
            }

            g_Progress.getInstance():show()
            Log.d("sendMsg", "feedback,url=" .. url);
            -- 待添加 原生 接口
            NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_UPLOAD_FEED_IMAGE, param, self, self.uploadFbImgResponse)
            return
        end
        
        Log.d("sendMsg", "feedback,url=", self.m_imgPath);
        local param = HttpCmd:getMethod(HttpCmd.s_cmds.SEND_FEEDBACK)
        param.type = self.m_feedBackId
        param.content = content
        param.bitmapData = self.m_imgPath
        param.jpegData = self.m_imgPath
        g_HttpManager:doPost(param, self, self.onSendMsgSuccess, self.onSendMsgFailed);
    end
end

function BaseView:uploadFbImgResponse(response)
    g_Progress.getInstance():dismiss()

    if not self or not self.sendBtn then
        return
    end

    if response and tonumber(response.result) == 0 then
        cc.TextureCache:getInstance():removeTextureForKey(self.m_imgPath)
        self.m_imgPath = ''
        self:onSendMsgSuccess(true, response)
    else
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_network_err"))
        self.sendBtn:setEnabled(true)
    end
end

function BaseView:onSendMsgSuccess(isSuccess, response)
    g_Progress.getInstance():dismiss()
    if not isSuccess or not g_TableLib.isTable(response) then
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_network_err"))
        self.sendBtn:setEnabled(true)
    else
        g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_help_feedback_sucess"))
        self.topContent:setString("")
        self.topEditBox:setText('')
        self.topLastValue = ""
        self.m_imgPath = ""
        self.topPlaceHolderLabel:setVisible(true)
        self.sendBtn:setEnabled(false)
        self.m_uploadImgBtn:loadTextureNormal("creator/help/res/uploadBg.png", ccui.TextureResType.localType)
        g_EventDispatcher:dispatch(g_SceneEvent.FEEDBACK_SUBMIT_SUCCESS)
    end
end

function BaseView:onSendMsgFailed(response)
    g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_network_err"))
end

function BaseView:onCustomEventAll()
    self:setVisible(false)
end

function BaseView:onCustomEventResume(eventName)
    self:setVisible(true)
end

function BaseView:uploadImg()
    local params = {Name = "choseImage_"..tostring(self.m_feedBackId)}
    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_CHOOSE_IMAGE, params, self, self.uploadHeadResponse)
end

function BaseView:uploadHeadResponse(data)
    Log.d("Johnson SettingHeadCtr:uploadHeadResponse data = ",data)
    local jsonData = data
    if g_TableLib.isTable(jsonData) and self and self.m_uploadImgBtn then
        if(tonumber(jsonData.result) == 0) or jsonData.result == true then --iOS 使用true/false来判断
            Log.d("uploadHeadResponse",jsonData.imagePath)
            local btnSize = self.m_uploadImgBtn:getContentSize()
            self.m_uploadImgBtn:ignoreContentAdaptWithSize(false)
            cc.TextureCache:getInstance():removeTextureForKey(self.m_imgPath)
            self.m_imgPath = jsonData.imagePath
            self.m_uploadImgBtn:loadTextureNormal(jsonData.imagePath)
        end
    end
end

function BaseView:getFeedBackList()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.GET_FEEDBACK_LIST)
    g_HttpManager:doPost(param, self, self.onGetFeedbackSuccess);
end

function BaseView:onGetFeedbackSuccess(isSuccess, response)
    if not isSuccess or not g_TableLib.isTable(response) then
        -- g_AlarmTips.getInstance():setTextAndShow(GameString.get("str_login_network_err"))
    else
        local statusData = {}
        for i=1, #response.data do
            local data = response.data[i]
            statusData[i] = {title = data.content, content = data.answer, time = data.mtime}
        end
        self:setStatusData(statusData)
    end
end

return BaseView