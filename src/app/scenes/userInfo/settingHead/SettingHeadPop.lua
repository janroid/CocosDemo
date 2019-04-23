local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend
local BehaviorMap = import("app.common.behavior").BehaviorMap
local SettingHeadPop = class("SettingHeadPop",PopupBase);
local NetImageView = import("app.common.customUI").NetImageView


---配置事件监听函数
SettingHeadPop.s_eventFuncMap =  {
	[g_SceneEvent.UPLOAD_USER_HEAD_ICON_SUCCESS] = "uploadHeadSuccess";
	[g_SceneEvent.MODIFY_USER_INFO_SUCCESS] = "modifyInfoSuccess";
	[g_SceneEvent.UPGRADE_ACCOUNT_HIDE_UPGRADE_BTN] = "hideUpgradeBtn";
}

function SettingHeadPop:ctor()
	PopupBase.ctor(self)
	self:bindCtr(require(".settingHead.SettingHeadCtr"))
	self:init()
end


function SettingHeadPop:onCleanup()
	PopupBase.onCleanup(self)
	self.m_idxHead = nil
end

function SettingHeadPop:init()
	self:loadLayout('creator/userInfo/settingHead.ccreator')
	self:initScene()
	self:initChooseHeadView()
	self:initHeadIcon()
end

function SettingHeadPop:show()
	PopupBase.show(self)
	self.m_idxHead = nil
	if self.seletHead then
		self.seletHead:removeSelf();
		self.seletHead = nil
	end
	
	local headIcon = g_AccountInfo:getSmallPic()
	if string.contains(tostring(headIcon), "21.jpg") then
		headIcon = 21
	elseif string.contains(tostring(headIcon), "22.jpg") then
		headIcon = 22
	end
	if tonumber(headIcon) then
		self:highLight(self.m_headBtnMap[tonumber(headIcon)])
	end
	self:initString()
	self:updateView()
end

function SettingHeadPop:initScene()
	self.m_headIcon = g_NodeUtils:seekNodeByName(self.m_root,"head")
	self.m_headview = g_NodeUtils:seekNodeByName(self.m_root,"headview")
	self.m_close = g_NodeUtils:seekNodeByName(self.m_root,"close")
	-- 性别选择
	self.m_manToggle = g_NodeUtils:seekNodeByName(self.m_root,"manToggle")
	self.m_womanToggle = g_NodeUtils:seekNodeByName(self.m_root,"womanToggle")
	self.m_sexIcon = g_NodeUtils:seekNodeByName(self.m_root,"sexIcon")

	self.m_btnSave = g_NodeUtils:seekNodeByName(self.m_root,"btn_save")
	self.m_nameBox = g_NodeUtils:seekNodeByName(self.m_root,"nameBox")
	self.m_btnSaveTxt = g_NodeUtils:seekNodeByName(self.m_root,"btn_save_txt")
	self.m_toggleManTxt = g_NodeUtils:seekNodeByName(self.m_root,"toggle_man_txt")
	self.m_toggleWomanTxt = g_NodeUtils:seekNodeByName(self.m_root,"toggle_woman_txt")
	self.m_awardChips = g_NodeUtils:seekNodeByName(self.m_root,"award_chips")
	self.m_bindMailTxt = g_NodeUtils:seekNodeByName(self.m_root,"bind_mail_txt")
	self.m_womanToggleClickArea = g_NodeUtils:seekNodeByName(self.m_root,"woman_toggle_click_area")
	self.m_manToggleClickArea = g_NodeUtils:seekNodeByName(self.m_root,"man_toggle_click_area")
	self.m_btnMail = g_NodeUtils:seekNodeByName(self.m_root,"mailBtn")

	self.m_close:addClickEventListener(function (sender)
		self:onCloseheadBtnClick()
	end)
	self.m_btnMail:addClickEventListener(function (sender)
		if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.GUEST then
			self:onOpenAcountUpgradePop()
		else 
			g_PopupManager:show(g_PopupConfig.S_POPID.CHANGE_PWD_POP)
		end
	end)
	self.m_btnSave:addClickEventListener(function (sender)
		self:onSubmit()
	end)
	self.m_womanToggleClickArea:addClickEventListener(function (sender)
		self.m_manToggle:setSelected(false)
		self.m_womanToggle:setSelected(true)
		self.m_sexIcon:setTexture("creator/userInfo/head/women.png")
	end)
	self.m_manToggleClickArea:addClickEventListener(function (sender)
		self.m_manToggle:setSelected(true)
		self.m_womanToggle:setSelected(false)
		self.m_sexIcon:setTexture("creator/userInfo/head/men.png")
	end)
end

function SettingHeadPop:initHeadIcon()
	BehaviorExtend(self.m_headIcon)
	self.m_headIcon:bindBehavior(BehaviorMap.HeadIconBehavior)
end

function SettingHeadPop:initChooseHeadView()
	local headlayot = self.m_headview:getInnerContainer()
	self.m_headBtnMap = {}

	for i = 0,22 do
		local head = g_HeadConfig.HEAD_IMGS[i]
		-- Log.d(i,head)
		local nomStr = head.path    
		-- Log.d("Johnson setupUI i posI",i,head.posI)
		local bg = ccui.ImageView:create("creator/userInfo/sysHead/imgface_no.png", ccui.TextureResType.localType)
		bg:setAnchorPoint(cc.p(0,0))
		bg:setContentSize(cc.size(112,112)) 
		local headBtn = ccui.Button:create(nomStr,nomStr,ccui.TextureResType.localType)
		headBtn:addChild(bg)
		
		headBtn:ignoreContentAdaptWithSize(false)
		headBtn:setContentSize(cc.size(112,112))
		local x, y = 20+(30+100)*math.mod(head.posI-1,4), -(33+(70+66)*math.floor((head.posI-1)/4))+730
		headBtn:setPosition(x, y):addTo(headlayot)
		headBtn:setAnchorPoint(cc.p(0,0))

		if i == 0 then
			headBtn:addClickEventListener(function (sender)
				self:uploadHead()
			end)
		else
			headBtn:addClickEventListener(function (sender)
				self:updateIcon(head.index)
				self.m_idxHead = head.index
				
				self:highLight(headBtn)
			end)
		end
		self.m_headBtnMap[i] = headBtn
	end
	self.m_headview:jumpToTop()
end

function SettingHeadPop:highLight(view)
	if not view then return end
	if self.seletHead then
		self.seletHead:removeFromParent();
	end
	
	self.seletHead = ccui.ImageView:create("creator/userInfo/sysHead/imgface_selet.png", ccui.TextureResType.localType)
	self.seletHead:setAnchorPoint(cc.p(0,0))
	self.seletHead:setPosition(-5, -5)
	self.seletHead:setContentSize(cc.size(113,113))
	view:addChild(self.seletHead)
end

function SettingHeadPop:initString()
	self.m_nameBox:setText(g_AccountInfo:getNickName())
	self.m_btnSaveTxt:setString(GameString.get("str_setting_head_pop_save"))
	self.m_toggleManTxt:setString(GameString.get("str_setting_head_pop_male"))
	self.m_toggleWomanTxt:setString(GameString.get("str_setting_head_pop_female")) 
	self.m_awardChips:setString(GameString.get("str_setting_head_pop_award_chips"))
	if g_AccountInfo:getLoginFrom() == g_AccountInfo.S_LOGIN_FROM.GUEST then
		self.m_bindMailTxt:setString(GameString.get("str_setting_head_pop_bind_mail"))
	else
		self.m_awardChips:setVisible(false)
		self.m_bindMailTxt:setString(GameString.get("str_setting_head_pop_mail_change_pwd"))
	end
end


function SettingHeadPop:updateIcon(pic)
	local headIconPic = pic or g_AccountInfo:getSmallPic()
	self.m_headIcon:setHeadIcon(headIconPic)
end

---刷新界面
function SettingHeadPop:updateView()
	local sex = g_AccountInfo:getSex()
	if sex == "f" then 
		self.m_sexIcon:setTexture("creator/userInfo/head/women.png")
		self.m_womanToggle:setSelected(true)
		self.m_manToggle:setSelected(false)
	else
		self.m_sexIcon:setTexture("creator/userInfo/head/men.png")
		self.m_manToggle:setSelected(true)
		self.m_womanToggle:setSelected(false)
	end	
	self:updateIcon()
end

function SettingHeadPop:onCloseheadBtnClick()
	Log.d("SettingHeadPop:onCloseheadBtnClick")
	self:hidden()
end

function SettingHeadPop:uploadHead()
	g_EventDispatcher:dispatch(g_SceneEvent.UPLOAD_USER_HEAD_ICON)
end

function SettingHeadPop:uploadHeadSuccess()
    -- Log.d("SettingHeadPop:onPhotoResponse json_data = ",data)
	self:updateIcon()
	g_EventDispatcher:dispatch(g_SceneEvent.UPDATE_USER_HEAD_ICON)

end

function SettingHeadPop:onSubmit()
    -- local sel = self.m_groupSex:getResult();

    local sex = self.m_manToggle:isSelected() and "m" or "f";
	local img;
	local nickName = self.m_nameBox:getText()

    if self.m_idxHead ~=nil then
        img = self.m_idxHead;
    else
        img = g_AccountInfo:getSmallPic();
	end
	if g_StringLib.isEmpty(nickName) then
		g_AlarmTips.getInstance():setText(GameString.get("str_setting_head_pop_nick_error")):show()
	else
		g_EventDispatcher:dispatch(g_SceneEvent.MODIFY_USER_INFO,nickName,sex,img)
	end
end

function SettingHeadPop:modifyInfoSuccess(data)
	-- Log.d("Johnson  SettingHeadPop:modifyInfoSuccess data ",data)
	local nickName = data.nick
	local sex = data.s
	local img = data.pic
	if img ~= g_AccountInfo:setSmallPic() then
		g_AccountInfo:setSmallPic(img)
		g_AccountInfo:setMiddlePic(img)
		g_AccountInfo:setBigPic(img)
		g_EventDispatcher:dispatch(g_SceneEvent.UPLOAD_USER_HEAD_ICON_SUCCESS)
	end
	g_AccountInfo:setSex(sex)
	g_AccountInfo:setNickname(nickName)
	g_EventDispatcher:dispatch(g_SceneEvent.UPLOAD_USER_HEAD_ICON_SUCCESS)
	-- 保存用户昵称
	cc.UserDefault:getInstance():setStringForKey(g_UserDefaultCMD.GUEST_NICKNAME,nickName)
	self:hidden()
end

function SettingHeadPop:onOpenAcountUpgradePop()
	g_PopupManager:show(g_PopupConfig.S_POPID.ACCOUNT_UPGRADE_POP)
end

function SettingHeadPop:hideUpgradeBtn()
	self.m_awardChips:setVisible(false)
	self.m_bindMailTxt:setString(GameString.get("str_setting_head_pop_mail_change_pwd"))
end

return SettingHeadPop