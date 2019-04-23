--[[--ldoc 点击返回键的弹窗
@module KeyBackPop
@author jamesLiang

Date   2019-1-22
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local KeyBackPop = class("KeyBackPop",PopupBase);
BehaviorExtend(KeyBackPop);

function KeyBackPop:ctor()
	PopupBase.ctor(self);
    self:bindCtr(require(".KeyBackCtr"));
    self.m_playWheelAnimArr = {}
	self:init();
end

function KeyBackPop:init()
    self:loadLayout('creator/keyBacktoLogin/keyBackPop.ccreator')
    self.m_title = g_NodeUtils:seekNodeByName(self, "title")
    self.m_describe1 = g_NodeUtils:seekNodeByName(self, "describe1")
    self.m_describe2 = g_NodeUtils:seekNodeByName(self, "describe2")
    self.m_wheelLabel = g_NodeUtils:seekNodeByName(self, "wheelLabel")
    self.m_dailyTaskLabel = g_NodeUtils:seekNodeByName(self, "dailyTaskLabel")
    self.m_newestActLabel = g_NodeUtils:seekNodeByName(self, "newestActLabel")
    self.m_backGame = g_NodeUtils:seekNodeByName(self, "backGame")
    self.m_loginout = g_NodeUtils:seekNodeByName(self, "loginout")

    self.m_title:setString(GameString.get("str_keybackpop_title"))
    self.m_describe1:setString(GameString.get("str_keybackpop_describe1"))
    self.m_describe2:setString(GameString.get("str_keybackpop_describe2"))
    self.m_wheelLabel:setString(GameString.get("str_keybackpop_wheelLabel"))
    self.m_dailyTaskLabel:setString(GameString.get("str_keybackpop_dailyTaskLabel"))
    self.m_newestActLabel:setString(GameString.get("str_keybackpop_newestActLabel"))
    self.m_backGame:setString(GameString.get("str_keybackpop_backGame"))
    self.m_loginout:setString(GameString.get("str_keybackpop_loginout"))

    self.m_btnClose = g_NodeUtils:seekNodeByName(self, "btnClose")
    self.m_popBg = g_NodeUtils:seekNodeByName(self, "popBg")
    self.m_title = g_NodeUtils:seekNodeByName(self, "title")
    self.m_describe1 = g_NodeUtils:seekNodeByName(self, "describe1")
    self.m_describe2 = g_NodeUtils:seekNodeByName(self, "describe2")
    self.m_btnBackGame = g_NodeUtils:seekNodeByName(self, "btnBackGame")
    self.m_btnLginout = g_NodeUtils:seekNodeByName(self, "btnLginout")
    self.m_btnWheel = g_NodeUtils:seekNodeByName(self, "btnWheel")
    self.m_btnDailyTask = g_NodeUtils:seekNodeByName(self, "btnDailyTask")
    self.m_btnNewestAct = g_NodeUtils:seekNodeByName(self, "btnNewestAct")

    for i = 1, 8 do
        self.m_playWheelAnimArr[i] = g_NodeUtils:seekNodeByName(self, "img_flash_light"..i)
        self.m_playWheelAnimArr[i] : setVisible(true)
   end

    self.m_btnClose:addClickEventListener(function(sender)
		self:hidden()
    end)
    self.m_btnBackGame:addClickEventListener(function(sender)
		self:hidden()
    end)

    self.m_popBg:addClickEventListener(function(sender)
		
    end)

    self.m_btnLginout:addClickEventListener(function(sender)
		self:logout()
    end)
    self.m_btnWheel:addClickEventListener(function(sender)
		self:onBtnWheelClick()
    end)
    self.m_btnDailyTask:addClickEventListener(function(sender)
		self:onBtnDailyTaskClick()
    end)
    self.m_btnNewestAct:addClickEventListener(function(sender)
		self:onBtnNewesetActClick()
    end)

end

function KeyBackPop:show()
    PopupBase.show(self)
    self:creatAnimation()
end

function KeyBackPop:hidden()
    PopupBase.hidden(self)
    if self.m_rotationEntry then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_rotationEntry)
        self.m_rotationEntry = nil
    end
end

function KeyBackPop:creatAnimation()
    local i = 1
    local callback = function ()
        for j = 1,8 do
            if j==i then
                self.m_playWheelAnimArr[j]:setVisible(true)
            else
                self.m_playWheelAnimArr[j]:setVisible(false)
            end            
        end           
        i = i+1 > 8 and 1 or i+1
    end
    self.m_rotationEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, 0.05, false)
end

function KeyBackPop:logout()
    self:hidden()
    if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.FACEBOOK then
        NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_LOGOUT_FACEBOOK)
    end
    g_AccountInfo:reset()
    local loginScene = import("app.scenes.login").scene
    cc.Director:getInstance():replaceScene(loginScene:create())
end

function KeyBackPop:onBtnWheelClick()
    self:hidden()
    print("点击幸运转转转")
    g_PopupManager:show(g_PopupConfig.S_POPID.BIG_WHEEL_POP)
end

function KeyBackPop:onBtnDailyTaskClick()
    self:hidden()
    print("点击每日任务")
    g_PopupManager:show(g_PopupConfig.S_POPID.DAILYTASK_POP)
end

function KeyBackPop:onBtnNewesetActClick()
    self:hidden()
    print("点击最新活动")
    local ActivityWebInfo = import("app.scenes.activity").ActivityWebInfo
    local res = g_AccountInfo:getHallIcon()
	if g_TableLib.isTable(res) and res.icon ~= nil and not g_SystemInfo.isWindows() then
		local callJS = ActivityWebInfo:defaultCallJs()
		local webInfo = ActivityWebInfo.new(tostring(res.url))
		webInfo:setCallJS(callJS)
		webInfo:setReCreate(false)
		webInfo:setForcedDisplay(true)
		webInfo:setX(0)
		webInfo:setY(0)
		webInfo:setFull(true)
        g_PopupManager:show(g_PopupConfig.S_POPID.ACTIVITY_WEB_POP, webInfo)
    end
end

return  KeyBackPop