local PopupBase = import("app.common.popup").PopupBase
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local SafeBoxPasswordPop = class("SafeBoxPasswordPop",PopupBase);
BehaviorExtend(SafeBoxPasswordPop);

---配置事件监听函数
SafeBoxPasswordPop.s_eventFuncMap =  {

}

function SafeBoxPasswordPop:ctor()
	PopupBase.ctor(self)
	self:bindCtr(require(".SafeBoxPassword.SafeBoxPasswordCtr"))
	self:init()
end
function SafeBoxPasswordPop:onEnter()
	PopupBase.onEnter(self, true)
end
function SafeBoxPasswordPop:onExit()
	PopupBase.onExit(self, true)
end


function SafeBoxPasswordPop:init()
	self.m_root = g_NodeUtils:getRootNodeInCreator('creator/safeBox/safeBoxPassword.ccreator')
	self:addChild(self.m_root)

	self:findView()
end

---刷新界面
function SafeBoxPasswordPop:updateView(data)
	data = checktable(data);
end

function SafeBoxPasswordPop:findView()
	self.mark = g_NodeUtils:seekNodeByName(self.m_root, "mark")
	self.mark:setVisible(false)

	local shiled = g_NodeUtils:seekNodeByName(self.m_root, "shiled")
	shiled:setTouchEnabled(true)
	shiled:setSwallowTouches(true)
	--設置字符串
	local title = g_NodeUtils:seekNodeByName(self.m_root, "title")
	title:setString(GameString.get("enter_psd"))
	title:setLocalZOrder(10)
	local tips = g_NodeUtils:seekNodeByName(self.m_root, "tips")
	tips:setString(GameString.get("safeBox_tips3"))
	tips:setDimensions(458,0)
	local forget_label = g_NodeUtils:seekNodeByName(self.m_root, "forget_label")
	forget_label:setString(GameString.get("forgot_psd"))
	local confirm_label = g_NodeUtils:seekNodeByName(self.m_root, "confirm_label")
	confirm_label:setString(GameString.get("confirm_btn"))

	self.m_passwdInput = g_NodeUtils:seekNodeByName(self.m_root, "editbox")
	self.m_passwdInput:setPlaceHolder(GameString.get("psd_tip1"))
	self.m_passwdInput:registerScriptEditBoxHandler(function(event,sender) 
            self:editboxHandle(event,sender) 
        end)
	self.m_passwdInput:setMaxLength(16)

	---------------btn点击事件-------------
	local confirm_btn = g_NodeUtils:seekNodeByName(self.m_root, "confirm_btn")
	confirm_btn:addClickEventListener(function (sender)
			self:onConfirmBtnClick()
		end)

	local forgot_btn = g_NodeUtils:seekNodeByName(self.m_root, "forgot_btn")
	forgot_btn:addClickEventListener(function (sender)
			self:onForgotPasswordBtnClick()
		end)

	local close_btn = g_NodeUtils:seekNodeByName(self.m_root, "close_btn")
	close_btn:addClickEventListener(function (sender)
			self:onCloseBtnClick()
		end)
	
	self.m_confirm_btn = confirm_btn
end

--验证密码是否正确
function SafeBoxPasswordPop:verifyPassword()
	return false
end

--验证密码格式是否正确
function SafeBoxPasswordPop:isPassWordValid(password)
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

function SafeBoxPasswordPop:editboxHandle(event,sender)
	if event == "began" then
        
    elseif event == "ended" then
        local password = sender:getText()
    	self.mark:setVisible(password ~= "")
        if password == "" then return end
        self.is_psd_valid = self:isPassWordValid(password)
        if self.is_psd_valid then
        	self.mark:setTexture("creator/common/dialog/right.png")
        else
        	self.mark:setTexture("creator/common/dialog/wrong.png")
        	g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip1"))
        end
    elseif event == "return" then
        
    elseif event == "changed" then
        
    end
end



function SafeBoxPasswordPop:onConfirmBtnClick()
	if not self.is_psd_valid then
		g_AlarmTips.getInstance():setTextAndShow(GameString.get("psd_tip1"))
		return
	end
	
	local params = HttpCmd:getMethod(HttpCmd.s_cmds.MOBILEBANK_BANKCHECKPSW)
	params.token = g_AccountInfo:getBankToken()
	params.password = projectx.lcc_getMD5Hash(projectx.lcc_getMD5Hash(g_StringLib.trim(self.m_passwdInput:getText())))

    g_HttpManager:doPost(params,self,self.onBankCheckpswResponse);
	self.m_confirm_btn:setEnabled(false)
end

function  SafeBoxPasswordPop:onBankCheckpswResponse(isSuccess, data)
	Log.d("HallSceneCtr:onGetBankDataReponse ",data,isSuccess)
	self.m_confirm_btn:setEnabled(true)
	if isSuccess then
		local tag = tonumber(data.tag)
		if tag == 1 then
			self:onCloseBtnClick()
			g_PopupManager:show(g_PopupConfig.S_POPID.SAFE_BOX_POP)
		elseif tag == 0 then
			g_AlarmTips.getInstance():setText(GameString.get("psd_error")):show()
		else

		end
	end
end

function SafeBoxPasswordPop:onForgotPasswordBtnClick()
	local helpType = import('app.scenes.help').ShowType
	g_PopupManager:show(g_PopupConfig.S_POPID.HELP_POP,helpType.showTypeHall,nil,4)
end

function SafeBoxPasswordPop:onCloseBtnClick()
	g_PopupManager:clearPop(g_PopupConfig.S_POPID.SAFE_BOX_PASSWORD_POP)
end

-- function SafeBoxPasswordPop:hidden()
-- 	PopupBase.hidden(self)
-- 	-- self:onCleanup()
-- end

return SafeBoxPasswordPop