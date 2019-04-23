--[[--ldoc desc
@module SettingUI
@author JohnsonZhang

Date   2018-11-8
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local SettingPop = class("SettingPop",PopupBase);
local SettingConfig = require ".SettingConfig"
BehaviorExtend(SettingPop);

SettingPop.IMG_SWITCH_ON = "creator/setting/img_setting_on.png"
SettingPop.IMG_SWITCH_OFF = "creator/setting/img_setting_off.png"
SettingPop.IMG_UNIT_LONG = "creator/setting/voice_progress_unit_long.png"
SettingPop.IMG_UNIT_SHORT = "creator/setting/voice_progress_unit_short.png"
SettingPop.VoiceChangeTimes = 0
function SettingPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require("SettingCtr"));
	self:init();
end

function SettingPop:init()
	-- 加载布局文件
	-- 第一个参数为布局文件，
	-- 第二个参数为boolean，
	--       true：表示当前弹框需要全局缓存，切换场景后不会自动删除，必须手动调用PopupManager:clearPop来删除
	--       false：表示当前弹框只在当前场景有效，其随当前场景销毁而销毁
	-- self:loadLayout("aa.creator",isGlobal);
    self:initScene()
    self:initText()
    self:initVoiceSlider()
    self:setClickListener()
    self:initSwitchStatus()
end

function SettingPop:initScene()
    self:loadLayout('creator/setting/layout_setting.ccreator',true)
    self.m_bg = g_NodeUtils:seekNodeByName(self,"bg") 
    self.m_titleTxt = g_NodeUtils:seekNodeByName(self,"txt_title") 
    self.m_btnClose = g_NodeUtils:seekNodeByName(self,"close") 
    self.m_settingScrollview = g_NodeUtils:seekNodeByName(self,"setting_scrollview") 
    self.m_acountTitle = g_NodeUtils:seekNodeByName(self,"acount_title") 
    self.m_accountName = g_NodeUtils:seekNodeByName(self,"account_name") 
    self.m_btnLogout = g_NodeUtils:seekNodeByName(self,"btn_logout") 
    self.m_btnLogoutTxt = g_NodeUtils:seekNodeByName(self,"btn_logout_txt") 
    self.m_voiceShakeTitle = g_NodeUtils:seekNodeByName(self,"voice_shake_title") 
    self.m_voiceSliderBg = g_NodeUtils:seekNodeByName(self,"voice_slider_bg") 
    self.m_voiceSlider = g_NodeUtils:seekNodeByName(self,"voice_slider") 
    self.m_voiceTitle = g_NodeUtils:seekNodeByName(self,"voice_txt") 
    self.m_bgmTxt = g_NodeUtils:seekNodeByName(self,"bgm_txt") 
    self.m_bgmSwitch = g_NodeUtils:seekNodeByName(self,"bgm_switch") 
    self.m_shakeSwitch = g_NodeUtils:seekNodeByName(self,"shake_switch") 
    self.m_shakeTxt = g_NodeUtils:seekNodeByName(self,"shake_txt") 
    self.m_otherTxt = g_NodeUtils:seekNodeByName(self,"other_txt") 
    self.m_autoSitTxt = g_NodeUtils:seekNodeByName(self,"auto_sit_txt") 
    self.m_autositSwitch = g_NodeUtils:seekNodeByName(self,"autosit_switch") 
    self.m_autoBuyinTxt = g_NodeUtils:seekNodeByName(self,"auto_buyin_txt") 
    self.m_autoBuyinSwitch = g_NodeUtils:seekNodeByName(self,"autobuyin_switch") 
    -- self.m_playTipSwitch = g_NodeUtils:seekNodeByName(self,"playtip_switch") 
    -- self.m_playCountTxt = g_NodeUtils:seekNodeByName(self,"play_count_txt") 
    self.m_clearBg = g_NodeUtils:seekNodeByName(self,"clear_bg") 
    self.m_clearExpandArrow = g_NodeUtils:seekNodeByName(self,"clear_expand_arrow") 
    self.m_clearTxt = g_NodeUtils:seekNodeByName(self,"clear_txt") 
    self.m_scoreBg = g_NodeUtils:seekNodeByName(self,"score_bg") 
    self.m_scoreExpandArrow = g_NodeUtils:seekNodeByName(self,"score_expand_arrow") 
    self.m_scoreTxt = g_NodeUtils:seekNodeByName(self,"score_txt") 
    self.m_checkUpdateBg = g_NodeUtils:seekNodeByName(self,"check_update_bg") 
    
    self.m_privacypolicyBg = g_NodeUtils:seekNodeByName(self, "privacypolicy_bg")
    self.m_privacypolicyArrow = g_NodeUtils:seekNodeByName(self,"privacypolicy_arrow") 
    self.m_privacypolicyTxt = g_NodeUtils:seekNodeByName(self,"privacypolicy_txt")

    self.m_versionNameTxt = g_NodeUtils:seekNodeByName(self,"version_name_txt")
    self.m_voiceSlider:loadBarTexture("creator/hall/blank4x4.png")
    self.m_voiceSlider:setContentSize(cc.size(420,32))
    self.m_settingScrollview:setScrollBarWidth(0)
    self.m_settingScrollview:jumpToTop()
end

function SettingPop:initText()
    self.m_titleTxt:setString(GameString.get("str_setting_title"))
    self.m_acountTitle:setString(GameString.get("str_setting_account_title"))
    self.m_btnLogoutTxt:setString(GameString.get("str_setting_logout"))
    self.m_voiceShakeTitle:setString(GameString.get("str_setting_voice_shake_title"))
    self.m_voiceTitle:setString(GameString.get("str_setting_voice_title"))
    self.m_bgmTxt:setString(GameString.get("str_setting_bgm_title"))
    self.m_shakeTxt:setString(GameString.get("str_setting_shake_title"))
    self.m_otherTxt:setString(GameString.get("str_setting_other_title"))
    self.m_autoSitTxt:setString(GameString.get("str_setting_auto_sit"))
    self.m_autoBuyinTxt:setString(GameString.get("str_setting_auto_buy_in"))
    self.m_privacypolicyTxt:setString(GameString.get("str_privacy_policy_title"))
    self.m_clearTxt:setString(GameString.get("str_setting_clear_cache"))
    self.m_scoreTxt:setString(GameString.get("str_setting_score"))
end

function SettingPop:setClickListener()
    self.m_bg:addClickEventListener(function()end)
    self.m_btnLogout:addClickEventListener(function() self:onLogOutClick() end)
    self.m_bgmSwitch:addClickEventListener(function() self:updateBGMSwitch() end)
    self.m_shakeSwitch:addClickEventListener(function() self:updateShakeSwitch() end)
    self.m_autositSwitch:addClickEventListener(function() self:updateAutositSwitch() end)
    self.m_autoBuyinSwitch:addClickEventListener(function() self:updateAutoBuyInSwitch() end)
    -- self.m_playTipSwitch:addClickEventListener(function() self:updatePlayTipSwitch() end)
    self.m_btnClose:addClickEventListener(function() self:hidden() end)
    self.m_scoreBg:addClickEventListener(function() self:gotoAppStore() end)
    self.m_scoreExpandArrow:addClickEventListener(function() self:gotoAppStore() end)

    self.m_clearBg:addClickEventListener(function() self:clearCache() end)
    self.m_clearExpandArrow:addClickEventListener(function()  self:clearCache() end)

    self.m_privacypolicyBg:addClickEventListener(function () self:showPrivacyPolicyPop() end)
    self.m_privacypolicyArrow:addClickEventListener(function () self:showPrivacyPolicyPop() end)
    self.m_voiceSlider:addEventListener(handler(self, self.onVoiceSliderChanged))
end

function SettingPop:show()
    PopupBase.show(self)
    self.m_versionNameTxt:setString(string.format(GameString.get("str_setting_version_name"),"V"..g_SystemInfo:getVersionName()))
    self.m_accountName:setString(g_StringLib.limitLength(g_AccountInfo:getNickName(),26,500))
    
    self:updateSlider(SettingConfig.getSliderPercent())
    self:initSwitchStatus()
end

function SettingPop:clearCache()
    g_AlarmTips.getInstance():setText(GameString.get("str_setting_clear_cache_tips")):show()
end

function SettingPop:onVoiceSliderChanged(ref,eventType)
    local percent = ref:getPercent()
    self:updateSlider(percent)
    SettingPop.VoiceChangeTimes = SettingPop.VoiceChangeTimes + 1
    -- 拖动过程中每5次调节一次音量，ui刚好加一格音量
    local detal = g_SystemInfo:isIOS() and 5 or 10;
    if eventType == ccui.SliderEventType.percentChanged and SettingPop.VoiceChangeTimes % detal == 0 then
        return
    end
    g_SoundManager:setMusicVolume(percent / 100.00)
    g_SoundManager:setEffectsVolume(percent / 100.00)
    SettingConfig.setSliderPercent(ref:getPercent())
    if eventType == ccui.SliderEventType.slideBallUp or eventType == ccui.SliderEventType.slideBallCancle then
        SettingPop.VoiceChangeTimes = 0
    end
end

function SettingPop:gotoAppStore()
    Log.d("SettingPop","gotoAppStore")
    g_AppManager:gotoAppStore()
end

function SettingPop:showPrivacyPolicyPop()
    g_PopupManager:show(g_PopupConfig.S_POPID.PRIVACY_POLICY_POP)
end

function SettingPop:initVoiceSlider()
    self.lightSliderContainer = cc.Node:create()
    self.itemViewMap = {}
    local sliderSize = self.m_voiceSlider:getContentSize()
    self.lightSliderContainer:setPositionY(sliderSize.height/2)
    local sliderW = sliderSize.width-7
    local unitWidth = sliderW/25
    local y = 0
    local x = 2
    for i = 0, 25 do
        local item = nil
        if i%5 == 0 then
            item = cc.Sprite:create(SettingPop.IMG_UNIT_LONG)
        else
            item =  cc.Sprite:create(SettingPop.IMG_UNIT_SHORT)
        end
        item:setPositionX(x)
        table.insert(self.itemViewMap,item)
        item:setVisible(false)
        self.lightSliderContainer:addChild(item)
        x = x+unitWidth
    end
    self.m_voiceSlider:addChild(self.lightSliderContainer)
end

function SettingPop:updateSlider(percent)
    if percent == 0 then
        self.lightSliderContainer:setVisible(false)
    else
        self.lightSliderContainer:setVisible(true)
    end
    -- local percent = ref:getPercent()
    self.m_voiceSlider:setPercent(percent)
    local sliderSize = self.m_voiceSlider:getContentSize()
    local sliderW = sliderSize.width
    local unitWidth = sliderSize.width/25
    local sliderWidth = percent/100*sliderSize.width
    local unitCount = sliderWidth/unitWidth+1
    for i = 1, #self.itemViewMap do
        if i <= unitCount then
            self.itemViewMap[i]:setVisible(true)
        else
            self.itemViewMap[i]:setVisible(false)
        end
    end
    
end

function SettingPop:initSwitchStatus()
    if SettingConfig.getBGMSwitch() then
        self.m_bgmSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    else
        self.m_bgmSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    end
    if SettingConfig.getShakeSwitch() then
        self.m_shakeSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    else
        self.m_shakeSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    end
    if SettingConfig.getAutoSitSwitch() then
        self.m_autositSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    else
        self.m_autositSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    end
    if SettingConfig.getAutoBuyInSwitch() then
        self.m_autoBuyinSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    else
        self.m_autoBuyinSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    end
    -- if SettingConfig.getPlayTipsSwitch() then
    --     self.m_playTipSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    -- else
    --     self.m_playTipSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    -- end
end

function SettingPop:updateBGMSwitch()
    if SettingConfig.getBGMSwitch() then
        SettingConfig.setBGMSwitch(false)
        if g_SoundManager:isMusicPlaying() then
            g_SoundManager:stopMusic()
        end 
        self.m_bgmSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    else
        if not g_SoundManager:isMusicPlaying() then
            g_SoundManager:playMusic(g_SoundMap.music.BMG, true)
        end
        SettingConfig.setBGMSwitch(true)
        self.m_bgmSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    end
end

function SettingPop:updateShakeSwitch()
    if SettingConfig.getShakeSwitch() then
        SettingConfig.setShakeSwitch(false)
        self.m_shakeSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    else
        SettingConfig.setShakeSwitch(true)
        -- NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_SHAKE)
        cc.Device:vibrate(0.5)
        self.m_shakeSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    end
end

function SettingPop:updateAutositSwitch()
    if SettingConfig.getAutoSitSwitch() then
        SettingConfig.setAutoSitSwitch(false)
        self.m_autositSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    else
        SettingConfig.setAutoSitSwitch(true)
        self.m_autositSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    end
end

function SettingPop:updateAutoBuyInSwitch()
    if SettingConfig.getAutoBuyInSwitch() then
        SettingConfig.setAutoBuyInSwitch(false)
        self.m_autoBuyinSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
    else
        SettingConfig.setAutoBuyInSwitch(true)
        self.m_autoBuyinSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
    end
end

-- function SettingPop:updatePlayTipSwitch()
--     if SettingConfig.getPlayTipsSwitch() then
--         SettingConfig.setPlayTipsSwitch(false)
--         self.m_playTipSwitch:loadTextures(SettingPop.IMG_SWITCH_OFF,SettingPop.IMG_SWITCH_OFF)
--     else
--         SettingConfig.setPlayTipsSwitch(true)
--         self.m_playTipSwitch:loadTextures(SettingPop.IMG_SWITCH_ON,SettingPop.IMG_SWITCH_ON)
--     end
-- end

function SettingPop:onLogOutClick()
    g_AlertDialog.getInstance()
        :setTitle(GameString.get("str_logout_title"))
        :setContent(GameString.get("str_logout_content"))
        :setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
        :setLeftBtnTx(GameString.get("str_logout_btn_cancel"))
        :setRightBtnTx(GameString.get("str_logout_btn_confirm"))
        :setRightBtnFunc(function()
            self:doLogic(g_SceneEvent.SETTING_LOGOUT)
        end)
        :show()
end

function SettingPop:onEnter()

end

function SettingPop:onEnterTransitionDidFinish()

end

function SettingPop:onExit()

end

function SettingPop:onExitTransitionDidStart()

end

function SettingPop:onCleanup()
	PopupBase.onCleanup(self)

end

---刷新界面
function SettingPop:updateView(data)
	data = checktable(data);
end

return SettingPop;