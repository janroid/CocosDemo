--[[--ldoc desc
@module SettingHeadCtr
@author MenuZhang
Date   2018-10-25
]]
local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local SettingHeadCtr = class("SettingHeadCtr",PopupCtr);
BehaviorExtend(SettingHeadCtr);

---配置事件监听函数
SettingHeadCtr.s_eventFuncMap =  {
	[g_SceneEvent.UPLOAD_USER_HEAD_ICON] = "uploadHead",
	[g_SceneEvent.MODIFY_USER_INFO] = "onModifyUserInfo",
}

function SettingHeadCtr:ctor()
	PopupCtr.ctor(self)
end

function SettingHeadCtr:dtor()
	PopupCtr.dtor(self)
end

function SettingHeadCtr:uploadHead()
	local params ={}
	params =g_HttpManager:getPostData(params)
	local uploadPic = g_PhpInfo.getUploadPic()
	local url = uploadPic .. "?" .. params;
	local param = {
        isNeedUpload = 1;
        Url = url
	}
    NativeEvent.getInstance():callNative(NativeCmd.KEY.KEY_CHANGE_HEAD,param,self,self.uploadHeadResponse)
end

function SettingHeadCtr:uploadHeadResponse(data)
	-- Log.d("Johnson SettingHeadCtr:uploadHeadResponse data = ",data)
	local jsonData = data
	if g_TableLib.isTable(jsonData) then
		local result = 100;
		local url = "";
		local key = "";
		local fname = "";
		if(jsonData.result ~= nil) then
			result = jsonData.result
		end
		if(jsonData.url ~= nil) then
			url = jsonData.url
		end
		if(jsonData.key ~= nil) then
			key = jsonData.key
		end

		if(tonumber(result) == 0) then

			local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_UPLOADPIC)
			params.url = url
			params.key = key

			-- Log.d("Johnson", "post uploadpic,url=" .. url);
			g_Progress.getInstance():show()
			g_HttpManager:doPost(params, self, function(self, isSuccess, ret)
				-- Log.d("Johnson", "post uploadpic end,ret=" .. ret);
				if(isSuccess and tonumber(ret) == 1) then
					g_AccountInfo:setSmallPic(url)
					g_AccountInfo:setMiddlePic(url)
					g_AccountInfo:setBigPic(url)
					g_EventDispatcher:dispatch(g_SceneEvent.UPLOAD_USER_HEAD_ICON_SUCCESS)
					g_AlarmTips.getInstance():setText(GameString.get("str_head_img_upload_success")):show()
				else
					g_AlarmTips.getInstance():setText(GameString.get("str_head_img_upload_failed")):show()
				end
				g_Progress.getInstance():dismiss()
			end,function()
				g_Progress.getInstance():dismiss()
				g_AlarmTips.getInstance():setText(GameString.get("str_head_img_upload_failed")):show()
			end);
		elseif (tostring(result) == "-5") then
			g_AlarmTips.getInstance():setText(string.format(GameString.get("str_head_img_upload_limit"), jsonData.size or "200K")):show()
		end
	end
end

function SettingHeadCtr:onModifyUserInfo(nickName, sex, img)
	local postData = HttpCmd:getMethod(HttpCmd.s_cmds.USER_MODIFYINFO)
	postData.nick   = nickName;
	postData.s      = sex;
	postData.pic    = img;
	g_HttpManager:doPost(postData, self, function(self, isSuccess, data)
		g_EventDispatcher:dispatch(g_SceneEvent.MODIFY_USER_INFO_SUCCESS,postData)
		--g_AlarmTips.getInstance():setText(GameString.get("str_head_img_upload_success")):show()
	end);
end


return SettingHeadCtr