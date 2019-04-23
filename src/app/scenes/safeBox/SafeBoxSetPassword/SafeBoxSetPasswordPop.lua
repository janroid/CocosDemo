local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd
local StoreConfig = import("app.scenes.store").StoreConfig

local SafeBoxSetPasswordPop = class("SafeBoxSetPasswordPop",PopupBase);
BehaviorExtend(SafeBoxSetPasswordPop);

---配置事件监听函数
SafeBoxSetPasswordPop.s_eventFuncMap =  {

}

function SafeBoxSetPasswordPop:ctor()
	PopupBase.ctor(self)
	self:bindCtr(require(".SafeBoxSetPassword.SafeBoxSetPasswordCtr"))
	self:init()
end


function SafeBoxSetPasswordPop:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/safeBox/safeBoxSetPassword.ccreator')
	self:addChild(self.m_root)

	self:findView()
end

---刷新界面
function SafeBoxSetPasswordPop:updateView(data)
	data = checktable(data);
end

function SafeBoxSetPasswordPop:findView()
	local shiled = g_NodeUtils:seekNodeByName(self.m_root, "shiled")
	shiled:setTouchEnabled(true)
	shiled:setSwallowTouches(true)

	self.mark1 = g_NodeUtils:seekNodeByName(self.m_root, "mark1")
	self.mark1:setVisible(false)
	self.mark2 = g_NodeUtils:seekNodeByName(self.m_root, "mark2")
	self.mark2:setVisible(false)

	--設置字符串
	local title = g_NodeUtils:seekNodeByName(self.m_root, "title")
	title:setString(GameString.get("set_psd"))
	title:setLocalZOrder(10)
	local confirm_label = g_NodeUtils:seekNodeByName(self.m_root, "confirm_label")
	confirm_label:setString(GameString.get("confirm_btn"))

	local password_edit1 = g_NodeUtils:seekNodeByName(self.m_root, "password_edit1")
	password_edit1:setPlaceHolder(GameString.get("psd_tip1"))
	password_edit1:registerScriptEditBoxHandler(function(event,sender) 
            self:editboxHandle(event,sender) 
        end)
	self.password_edit1 = password_edit1

	local password_edit2 = g_NodeUtils:seekNodeByName(self.m_root, "password_edit2")
	password_edit2:setPlaceHolder(GameString.get("psd_tip2"))
	password_edit2:registerScriptEditBoxHandler(function(event,sender) 
            self:editboxHandle(event,sender)
        end)
	self.password_edit2 = password_edit2

	local confirm_btn = g_NodeUtils:seekNodeByName(self.m_root, "confirm_btn")
	confirm_btn:addClickEventListener(function (sender)
			self:onConfirmBtnClick()
		end)

	local close_btn = g_NodeUtils:seekNodeByName(self.m_root, "close_btn")
	close_btn:addClickEventListener(function (sender)
			self:onCloseBtnClick()
		end)
	
	self.m_confirmBtn = confirm_btn
	self.m_confirmBtn:setEnabled(false)
end


function SafeBoxSetPasswordPop:isTwoPassWordSame()
	local psd1 = self.password_edit1:getText()
	local psd2 = self.password_edit2:getText()
	return psd1 == psd2
end

function SafeBoxSetPasswordPop:isPassWordValid(password)
	if password == nil then
        return false
    end
    local len = string.len(password)
    if len < 6 or len > 16 then
    	return false
    end
    for i = 1, len do
        local ch = string.sub(password, i, i)
        if not ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z') or (ch >= '0' and ch <= '9')) then
            return false
        end
    end
    return true
end

function SafeBoxSetPasswordPop:editboxHandle(event,sender)
	if event == "ended" then
		self.is_psd_same = false
		self.is_psd_valid = false
		local text = sender:getText()
		if text == "" then return end

		if sender == self.password_edit1 then
			self.mark1:setVisible(true)
			if self:isPassWordValid(text) then
				self.mark1:setTexture("creator/common/dialog/right.png")

				local psd2 = self.password_edit2:getText()
				if psd2 == "" then return end
				if psd2 == text then
					self.is_psd_same = true
					self.is_psd_valid = self:isPassWordValid(text)
					self.is_psd_same_and_valid = true
					self.mark2:setTexture("creator/common/dialog/right.png")
					self.m_confirmBtn:setEnabled(true)
				else
					self.mark2:setTexture("creator/common/dialog/wrong.png")
					g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip3"))
					self.m_confirmBtn:setEnabled(false)
				end
			else
				self.mark1:setTexture("creator/common/dialog/wrong.png")
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip1"))
				self.m_confirmBtn:setEnabled(false)
			end
		elseif sender == self.password_edit2 then
			self.mark2:setVisible(true)
			if self:isPassWordValid(text) then
				self.mark2:setTexture("creator/common/dialog/right.png")
				local psd1 = self.password_edit1:getText()
				dump(psd1, text,  text== psd1)
				if psd1 == text then
					self.is_psd_same = true
					self.is_psd_valid = self:isPassWordValid(text)
					self.mark2:setTexture("creator/common/dialog/right.png")
					self.m_confirmBtn:setEnabled(true)
				else
					self.mark2:setTexture("creator/common/dialog/wrong.png")
					g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip3"))
					self.m_confirmBtn:setEnabled(false)
				end
			else
				self.mark2:setTexture("creator/common/dialog/wrong.png")
				g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip1"))
				self.m_confirmBtn:setEnabled(false)
			end
		end
    end
end

function SafeBoxSetPasswordPop:onConfirmBtnClick()
	if self.is_psd_same then
		-- local alert = g_alertView:create(str)
		-- self:add(alert)
		local vip = g_AccountInfo:getVip()
		local level = g_AccountInfo:getUserLevel()
		if tonumber(vip) > 0 or tonumber(level) >= 7 then
			local params = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_SETPSW)
			params.token = g_AccountInfo:getBankToken()
			params.password1 = projectx.lcc_getMD5Hash(projectx.lcc_getMD5Hash(g_StringLib.trim(self.password_edit1:getText())))
			params.password2 = projectx.lcc_getMD5Hash(projectx.lcc_getMD5Hash(g_StringLib.trim(self.password_edit2:getText())))

			g_HttpManager:doPost(params, self, self.setPasswordSuccess);
		else
			self:onCloseBtnClick()
			g_AlertDialog.getInstance()
			:setContent(GameString.get("str_safe_box_vip_level_tips"))
			:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
			:setCenterBtnTx(GameString.get("str_become_vip"))
			:setCenterBtnFunc(function()
				g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_VIP_PAGE)
			end)
			:setTitle(GameString.get("tips"))
			:show()
		end
	else
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip3"))
	end
end

function SafeBoxSetPasswordPop:setPasswordSuccess(isSuccess, data)
	self:onCloseBtnClick()
	Log.d("SafeBoxSetPasswordPop:setPasswordSuccess  response = ",data)

	local tag = data.tag
	local str = ""
	if tag == 1 then
		g_AccountInfo:setIsSetBankPassword(true)
		str = GameString.get("safeBox_tips2")
		g_PopupManager:hidden(g_PopupConfig.S_POPID.SAFE_BOX_POP)
	else
		g_AccountInfo:setIsSetBankPassword(false)
		str = GameString.get("psd_tip1")
	end
	g_EventDispatcher:dispatch(g_SceneEvent.SAFE_BOX_SET_PASSWORD_SUCCESS)
	g_AlertDialog.getInstance()
	:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
	:setContent(str)
	:setTitle(GameString.get("tips"))
	:setCenterBtnTx(GameString.get("confirm_btn"))
	:setCenterBtnFunc(
	function ()
		if tag == 1 then
			g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_PASSWORD_POP)
		end
	end)
	:show()
end

function SafeBoxSetPasswordPop:onCloseBtnClick()
	g_PopupManager:clearPop(g_PopupConfig.S_POPID.SAFE_BOX_SET_PASSWORD_POP)
end

-- function SafeBoxSetPasswordPop:hidden()
-- 	PopupBase.hidden(self)
-- 	self:onCleanup()
-- end

return SafeBoxSetPasswordPop