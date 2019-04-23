--[[--ldoc desc
@module SafeBoxPop
@author MenuZhang

Date   2018-10-25
]]
local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local SafeBoxPop = class("SafeBoxPop",PopupBase);
local StoreConfig = import('app.scenes.store').StoreConfig
BehaviorExtend(SafeBoxPop);

function SafeBoxPop:ctor()
	PopupBase.ctor(self);
	self:bindCtr(require(".SafeBoxCtr"))
	self:init()
end

---配置事件监听函数
SafeBoxPop.s_eventFuncMap =  {
	-- [g_SceneEvent.SAFE_BOX_EVENT_GET_DATA_SUCCESS] = "getBankDataSuccess";
	[g_SceneEvent.SAFE_BOX_EVENT_SAVE_MONEY_SUCCESS] = "onSaveMoneySuccess";
	[g_SceneEvent.SAFE_BOX_EVENT_DRAW_MONEY_SUCCESS] = "onDrawMoneySuccess";
	[g_SceneEvent.SAFE_BOX_SET_PASSWORD_SUCCESS] = "updatePasswordIcon";
}


function SafeBoxPop:init()
	self.m_carryMoney = g_AccountInfo:getMoney() or 0
	self.m_bankMoney = g_AccountInfo:getBankMoney() or 0
	self.m_optionMoney = 0 --正在操作的钱
	self.m_optionState = 1 -- 当前的操作{"存钱", "取钱"}

	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/safeBox/safeBox.ccreator')
	self:addChild(self.m_root)
	self:findView()
end

function SafeBoxPop:show() 
	PopupBase.show(self)
	self:updateView()
end

function SafeBoxPop:findView()
	local shiled = g_NodeUtils:seekNodeByName(self.m_root, "shiled")
	shiled:move(0,0)
	shiled:setContentSize(display.size)
	shiled:setTouchEnabled(true)
	shiled:setSwallowTouches(true)

	self.confirm_btn_lbl = g_NodeUtils:seekNodeByName(self.m_root, "confirm_btn_lbl")
	self.m_carryMoneyLabel = g_NodeUtils:seekNodeByName(self.m_root, "carry_money_label")
	self.m_safeMoneyLabel = g_NodeUtils:seekNodeByName(self.m_root, "safe_money_label")
	self.money_label = g_NodeUtils:seekNodeByName(self.m_root, "money_label")
	self.title_bg = g_NodeUtils:seekNodeByName(self.m_root, "title_bg")

	--設置字符串
	self.confirm_btn_lbl:setString(GameString.get("confirm_btn"))
	local toggle_label1 = g_NodeUtils:seekNodeByName(self.m_root, "toggle_label1")
	toggle_label1:setString(GameString.get("save"))
	local toggle_label2 = g_NodeUtils:seekNodeByName(self.m_root, "toggle_label2")
	toggle_label2:setString(GameString.get("take_out"))
	local label1 = g_NodeUtils:seekNodeByName(self.m_root, "assert_in_game_title")
	label1:setString(GameString.get("safeBox_tips4"))
	local label2 = g_NodeUtils:seekNodeByName(self.m_root, "assert_in_box_title")
	label2:setString(GameString.get("safeBox_tips5"))
	local delete_btn_label = g_NodeUtils:seekNodeByName(self.m_root, "delete_btn_label")
	delete_btn_label:setString(GameString.get("delete_btn"))

	-----------------btn点击事件-----------
	local keypad_layout = g_NodeUtils:seekNodeByName(self.m_root, "keypad_layout")
	for i=1,10 do
		local btn = ccui.Button:create("creator/safeBox/res/number_btn.png","creator/safeBox/res/number_light_btn.png",ccui.TextureResType.localType)
		btn:addClickEventListener(function (sender)
			self:onKeyBtnClick(sender, i)
		end)
		local x, y = 50+(12+100)*math.mod(i-1,5), 146-(33+(12+66)*math.floor((i-1)/5))
		btn:setPosition(x, y):addTo(keypad_layout)
		btn:setTitleFontSize(28)
		local str = i == 10 and 0 or i
		btn:setTitleText(str)
	end
	self.btnDelete = g_NodeUtils:seekNodeByName(self.m_root, "delete_btn")
	self.btnDelete:addClickEventListener(function (sender)
			self:onDeleteBtnClick()
		end)

	self.btnConfirm = g_NodeUtils:seekNodeByName(self.m_root, "confirm_btn")
	self.btnConfirm:addClickEventListener(function (sender)
			self:onConfirmBtnClick()
		end)

	self.btnPassword = g_NodeUtils:seekNodeByName(self.m_root, "password_btn")
	self.btnPassword:addClickEventListener(function (sender)
			self:onOptionBtnClick()
		end)

	self.m_btnClose = g_NodeUtils:seekNodeByName(self.m_root, "close_btn")
	self.m_btnClose:addClickEventListener(function (sender)
			self:onCloseBtnClick()
		end)

	for i=1,2 do
		local toggle = g_NodeUtils:seekNodeByName(self.m_root, "toggle"..i)
		toggle:addClickEventListener(function (sender)
				self:onStateBtnClick(i)
			end)
		self["toggle"..i] = toggle
	end
	self.toggle1:setEnabled(false)

end

---刷新界面
function SafeBoxPop:updateView(data)
	data = checktable(data);

	self.m_carryMoney = g_AccountInfo:getMoney()
	-- self.m_bankMoney = 100000
	self.m_carryMoneyLabel:setString('$'..g_MoneyUtil.skipMoney(self.m_carryMoney))
	self.m_safeMoneyLabel:setString('$'..g_MoneyUtil.skipMoney(self.m_bankMoney))
	self:updatePasswordIcon()
	
	self.m_optionMoney = 0
	self.money_label:setString("0")
end

function SafeBoxPop:updatePasswordIcon()
	if g_AccountInfo:getIsSetBankPassword() then
		self.btnPassword:loadTextures ("creator/safeBox/res/lock.png","creator/safeBox/res/lock.png")
	else
		self.btnPassword:loadTextures ("creator/safeBox/res/unlock.png","creator/safeBox/res/unlock.png")
	end
end

---------------响应按钮点击事件
function SafeBoxPop:onStateBtnClick(index)
	if index == self.m_optionState then return end
	self["toggle"..self.m_optionState]:setEnabled(true)
	self.m_optionState = index
	self["toggle"..self.m_optionState]:setEnabled(false)

	local x, y = self["toggle"..self.m_optionState]:getPosition()
	self.title_bg:moveTo({x = x, y = y, time = 0.15})

	self.m_optionMoney = 0
	self.money_label:setString("0")

	GameString.get("save")
	local key = index == 1 and "save" or "take_out"
	self.confirm_btn_lbl:setString(GameString.get(key))
end

--isSave 是否存钱
function SafeBoxPop:checkMoney(money, isSave)
	-- 是存钱还是取钱
	if isSave then
		return money <= self.m_carryMoney and money or self.m_carryMoney
	else
		return money <= self.m_bankMoney and money or self.m_bankMoney
	end
end

function SafeBoxPop:onKeyBtnClick(sender, index)
	index = index == 10 and 0 or index
	local money = self.m_optionMoney
	if money == 0 then
		money = index
	else
		money = money * 10 + index
	end
	money = self:checkMoney(money, self.m_optionState == 1)

	local str = g_MoneyUtil.skipMoney(money)
	self.money_label:setString(str)
	self.m_optionMoney = money
end

function SafeBoxPop:onDeleteBtnClick()
	local flag = math.floor(self.m_optionMoney/10)
	if flag == 0 then
		self.m_optionMoney = 0
	else
		self.m_optionMoney = flag
	end
	local str = g_MoneyUtil.skipMoney(self.m_optionMoney)
	self.money_label:setString(str)
end

function SafeBoxPop:onConfirmBtnClick()
	if self.m_optionState == 2 and self.m_bankMoney == 0 then
		g_AlarmTips.getInstance():setText(GameString.get("safeBox_bank_no_money")):show()
		return
	end
	if self.m_optionMoney == 0 then
		g_AlarmTips.getInstance():setText(GameString.get("str_login_private_bank_input_money_label")):show()
		return
	end
	self.money_label:setString("0")
	if self.m_optionState == 1 then --存錢
		g_EventDispatcher:dispatch(g_SceneEvent.SAFE_BOX_EVENT_SAVE_MONEY,self.m_optionMoney)
    else
		g_EventDispatcher:dispatch(g_SceneEvent.SAFE_BOX_EVENT_DRAW_MONEY,self.m_optionMoney)
	end
	self.m_optionMoney = 0
end

function SafeBoxPop:onSaveMoneySuccess(data)
	if not g_TableLib.isEmpty(data) then
		if data.tag==0 then
			self:hidden()
			-- 不是VIP  等级< 7 级
			g_AlertDialog.getInstance()
			:setContent(GameString.get("str_safe_box_vip_level_tips"))
			:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
			:setCenterBtnTx(GameString.get("str_become_vip"))
			:setCenterBtnFunc(function()
				g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_VIP_PAGE)
			end)
			:setTitle(GameString.get("tips"))
			:show()
		elseif data.tag==1 then
			self.m_bankMoney = data.bankmoney
			local gameMoney = data.gameMoney
			self.m_carryMoney = gameMoney
			g_AccountInfo:setBankMoney(self.m_bankMoney)
			g_AccountInfo:setMoney(gameMoney)
			self:updateView()
			g_AlarmTips.getInstance():setText(GameString.get("str_login_save_money_success")):show()
		elseif(data.tag==-3) then
			g_AlarmTips.getInstance():setText(GameString.get("str_save_bank_money_fail")):show()
		else
			g_AlarmTips.getInstance():setText(GameString.get("str_login_network_err")):show()
		end
	end
end

function SafeBoxPop:onDrawMoneySuccess(data)
	if not g_TableLib.isEmpty(data) then
		if data.tag==0 then
			self:hidden()
			-- VIP < 7 级
			g_AlertDialog.getInstance()
			:setContent(GameString.get("str_safe_box_vip_level_tips"))
			:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
			:setCenterBtnTx(GameString.get("str_become_vip"))
			:setCenterBtnFunc(function()
				g_PopupManager:show(g_PopupConfig.S_POPID.POP_STORE,StoreConfig.STORE_POP_UP_VIP_PAGE)
			end)
			:setTitle(GameString.get("tips"))
			:show()
		elseif data.tag==1 then
			self.m_bankMoney = data.bankmoney
			local gameMoney = data.gameMoney
			self.m_carryMoney = gameMoney
			g_AccountInfo:setBankMoney(self.m_bankMoney)
			g_AccountInfo:setMoney(gameMoney)
			self:updateView()
			g_AlarmTips.getInstance():setText(GameString.get("str_login_draw_money_success")):show()
		elseif(data.tag==-3) then
			g_AlarmTips.getInstance():setText(GameString.get("str_not_sufficien_funds")):show()
		elseif data.tag == -5 then
			g_PopupManager:hidden(g_PopupConfig.S_POPID.SAFE_BOX_POP)
			g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_PASSWORD_POP)
		end
	end
end

function SafeBoxPop:onOptionBtnClick()
	local vip = g_AccountInfo:getVip()
	local level = g_AccountInfo:getUserLevel()
	if g_AccountInfo:getIsSetBankPassword() then -- 是否设置密码
		self:showSelectView()
	else
		if tonumber(vip) > 0 or tonumber(level) >=7 then
			g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_SET_PASSWORD_POP)
		else
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
	end
end

function SafeBoxPop:showSelectView()
	local str = GameString.get("safeBox_tips1")
	local title_str = GameString.get("safeBox_psd")
	local btn1_title = GameString.get("cancel_psd")
	local btn2_title = GameString.get("change_psd")

	g_AlertDialog.getInstance()
	:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.TWO_BUTTON)
	:setContent( GameString.get("safeBox_tips1"))
	:setTitle( GameString.get("safeBox_psd"))
	:setLeftBtnTx(GameString.get("cancel_psd"))
	:setRightBtnTx(GameString.get("change_psd"))
	:setRightBtnFunc(function ()
		g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_SET_PASSWORD_POP)
	end)
	:setLeftBtnFunc(function ()
		self:doCancelPassword()
	end)
	:show()
end

function SafeBoxPop:onChangePasswordBtnClick()
	g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_SET_PASSWORD_POP)
end

function SafeBoxPop:onCloseBtnClick()
	self:hidden()
end

function SafeBoxPop:doCancelPassword()

	local params = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_CANCELPSW)
	params.token = g_AccountInfo:getBankToken()
    g_HttpManager:doPost(params, self, self.onCancelPassword);
end

function  SafeBoxPop:onCancelPassword(isSuccess, data)
	if isSuccess then 
		if data.tag == 0 then
			g_AccountInfo:setIsSetBankPassword(false)
			self:updatePasswordIcon()
			g_AlertDialog.getInstance()
			:setShowBtnsIndex(g_AlertDialog.S_BUTTON_TYPE.ONE_BUTTON)
			:setContent( GameString.get("str_bank_password_cancel_success"))
			:setTitle( GameString.get("tips"))
			:show()
			-- Model.getData(ModelKeys.USER_DATA)["bank_password"]=false;
			-- EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.PRIVATE_BANK_UPDATE_SET_PASSWORD_ICON);
		elseif data.tag == -7 then
			g_PopupManager:hidden(g_PopupConfig.S_POPID.SAFE_BOX_POP)
			g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_PASSWORD_POP)
		else
			g_AlarmTips.getInstance():setText(GameString.get("str_bank_password_cancel_fail")):show()
		end    
	end
end

return SafeBoxPop;