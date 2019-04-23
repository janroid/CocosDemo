--[[--ldoc desc
@module MailBoxCtr
@author JohnsonZhang
Date   2018-10-30
]]

local PopupCtr = import("app.common.popup").PopupCtr;
local BehaviorExtend = import("framework.behavior").BehaviorExtend;
local HttpCmd = import("app.config.config").HttpCmd

local MailBoxCtr = class("MailBoxCtr",PopupCtr);
BehaviorExtend(MailBoxCtr);

---配置事件监听函数
MailBoxCtr.s_eventFuncMap =  {
    [g_SceneEvent.MAILBOX_EVENT_GET]		 	= "onMailRead";  --领取邮件奖励
    -- [g_SceneEvent.MAILBOX_EVENT_CHECK]		 	= "onMailCheck";  --查看邮件详情
    -- [g_SceneEvent.MAILBOX_EVENT_SIGN]		 	= "onMailSign";  --邮件实物奖励填写资料
    [g_SceneEvent.MAILBOX_EVENT_REQUEST_DATA]	= "requestMailBoxData";  --邮件实物奖励填写资料
    [g_SceneEvent.MAILBOX_EVENT_GET_ATTACH]	    = "getAttachHandle";  --领取附件奖励
}

function MailBoxCtr:ctor()
    PopupCtr.ctor(self);
end

function MailBoxCtr:onCleanup()
	PopupCtr.onCleanup(self);
end

function MailBoxCtr:requestMailBoxData()
    Log.d("MailBoxCtr:requestMailBoxData ")
    g_Progress.getInstance():show()
    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MSG_GET)
    g_HttpManager:doPost( param, self, self.onRequestMailMsgCallBack);
end

function MailBoxCtr:onRequestMailMsgCallBack(isSuccess, data)
    g_Progress.getInstance():dismiss()
    if isSuccess then
        -- Log.d("MailBoxCtr:onRequestMailBoxDataCallBack data = ",data)
        self:parseData(data)
        local parsedData = {}
        parsedData.mailData = self.m_mailData
        parsedData.sysData = self.m_sysData

        self:updateView(g_SceneEvent.MAILBOX_EVENT_REQUEST_DATA_SUCCESS,parsedData)
    else
        g_AlarmTips.getInstance():setText(GameString.get("str_login_network_err")):show()
    end
    
end

function MailBoxCtr:parseData(data)
    self.m_mailData = {}
    self.m_sysData = {}
    Log.d("zkzkparseData =  ",data)
    local template =  g_AppManager:getMessageTemplate()
    if data and #data > 0 then
        for i = 1, #data do
            local msg = data[i];
            local getDate = msg and msg.d or 0
            -- 过滤七天外的所有邮件
            local within7Days = (os.time()-getDate) <= 7 * 24 * 3600
            if within7Days then
                local parseData = {}
                parseData.m_id = string.format("%.0f", msg.a or 0); -- 消息ID
                parseData.m_msgType = msg.b or "";--消息类型，101表示邀请，102表示赠送礼物，103表示索要礼物；201表示公告，202表示活动，203表示更新；301表示支付完成
                parseData.m_hasReaded =(msg.c == 1); --消息是否已读，0表示未读，1表示已读
                parseData.m_date = msg.d or 0; -- 收到消息的时间
                parseData.m_msgParam = msg.e or ""; -- 消息参数，读取消息内容时需要用到
                parseData.m_templateID = msg.f or 0; -- 消息的模版ID，读取消息内容时需要用到
                parseData.m_fbId = msg.g or 0; -- 来源用户的FB平台siteuid，（仅在j=1时有效）
                parseData.m_dollId = msg.h or 0; -- 预留（为了兼容移动旧包）
                parseData.m_userId = msg.i or 0; -- 来源用户的玩家mid，（仅在j=1时有效）
                parseData.m_fromType = msg.j or 0; -- 来源类型，0-系统，1-玩家
                parseData.m_titleTemp = msg.k or 0; -- 消息标题的模板ID
                parseData.m_attaches = msg.l or {}; --附件奖励，格式json，例如:{'money':100,'prop':1,'exp':20}
                parseData.m_hasGetAttaches = (msg.m == 1); -- 附件奖励状态，0-未领取，1-已领取
                -- parseData.m_msgTitle = msg.n or ""; -- 消息标题参数,格式与[e:消息参数]一样
                parseData.m_time = msg.o or ""; -- 获得消息时间格式
                parseData.m_img = msg.img or "";  --图片url

                local fmtDate = os.date(GameString.get("str_mail_get_date_fmt"), getDate)
                parseData.m_timeNew = fmtDate or parseData.m_time
                
                if type(template) ~= "table" then
                    return;
                end

                local content;
                if template and template.msgtype ~= nil then
                    for _, msgs in ipairs(template.msgtype) do
                        if tonumber(msgs.id) == msg.b then
                            for _, item in ipairs(msgs) do
                                if tonumber(item.a) == msg.f then
                                    content = item.b;
                                    parseData.event = tonumber(item.event);
                                    parseData.eventTitle = item.eventTitle;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end

                local title;
                if template and template.msgtitle ~= nil then
                    for _, titles in ipairs(template.msgtitle) do
                        if titles.id == "-1" then
                            for _, item in ipairs(titles) do
                                if tonumber(item.a) == msg.k then
                                    title = item.b;
                                    break;
                                end
                            end
                            break;
                        end
                    end
                end
                local message = self:parseMessage(content, msg.e)
                if not message or message =="" then
                   local s = 20
                end
                parseData.m_message = message;
                parseData.m_giftUrl = self:parseGiftUrl(msg.e)
                parseData.m_msgTitle = self:parseMessage(title, msg.n);
                -- 来源类型，0-系统，1-玩家 已读状态的通知在系统消息
                if (parseData.m_fromType == 0 ) and (g_TableLib.isEmpty(parseData.m_attaches) and not parseData.m_hasGetAttaches) then
                    table.insert( self.m_sysData, parseData )
                else
                    table.insert( self.m_mailData, parseData )
                end
                -- Log.d("parseData =  ",parseData)
            end
        end
    end
end

function MailBoxCtr:parseMessage(tpl, str)
    if not tpl or not str then return; end
    local reg = "<#([^#]+)##([^#]+)#>";
    for k, m in string.gmatch(str, reg) do
        local key = k;
        local value = string.gsub(m, "%%", "%%%%");
        value = string.gsub(value,","," ");
        -- if LocalService.currentLocaleId() == "ar" then
        --     local len = string.len(tpl);
        --     local i,j = string.find(tpl, "{" .. key .. "}");
        --     local str1 = "";
        --     local str2 = "";
        --     if i ~= nil and i > 1 then
        --         str1 = string.sub(tpl,1,i-1);
        --     end
        --     if j ~= nil and j < len then
        --         str2 = string.sub(tpl,j+1);
        --     end
        --     tpl = str1 .. value .. str2;
        -- else
            tpl = string.gsub(tpl, "{" .. key .. "}", value);
        -- end
    end
    return tpl;
end

function MailBoxCtr:parseGiftUrl(str)
    if not str then return nil; end
    local reg = "<#([^#]+)##([^#]+)#>";
    for k, m in string.gmatch(str, reg) do
        local key = k;
        if k=="gift" then
            local value = string.gsub(m, "%%", "%%%%");
            value = string.gsub(value,","," ");
            
            local giftData = g_Model:getData(g_ModelCmd.GIFT_ALL_DATA) -- 炮響福到

            if g_TableLib.isEmpty(giftData) then
                return nil
            end
            local giftId = 0
            for i,v in ipairs(giftData) do
                if v.name==value then
                    giftId = v.id
                end
            end
            
            if giftId==0 then
                return nil
            end

            local pre = g_AccountInfo:getGiftSWFURL()
            local map = g_Model:getData(g_ModelCmd.GIFT_ID_FILE_MAPPING);
            local url = "";
            local name = tostring(giftId);
            if type(pre) ~= "string" then
                pre = "";
            end
            if map and map[name] then
                url = pre .. map[name] .. ".png";
            else
                url = pre .. tostring(name) .. ".png";
            end

            return url
        end
        
    end
    return nil
end


-- 消息已读
function MailBoxCtr:setMessageReaded(evt)
    local msg = evt.m_data; 
    local function callback(obj, isSuccess, response)
        Log.d("MailBoxCtr:setMessageReaded  response =    ",response)
        if tonumber(response) == 1 then
            msg.m_hasReaded = true;
            evt:updateCell(evt.m_data)
        end  
    end

    local param = HttpCmd:getMethod(HttpCmd.s_cmds.MSG_SETREAD)
    if msg then
        param.id = msg.m_id
        g_HttpManager:doPost(param,self,callback);
    end
end

-- 领取附件 id = -1 领取全部
function MailBoxCtr:getAttachHandle(evt)
    local id 
    local callback
    if tonumber(evt) == -1 then
        id = -1
        callback  = function(self,response)
            -- 待實現
        end
    else
        local msg = evt.m_data;
        if msg then
            id =msg.m_id 
        end
        
        callback  = function(self, isSuccess, data)
            Log.d("MailBoxCtr:getAttachHandle",data,flag)
            if isSuccess and tonumber(data[1].ret) == 1 then
                msg.m_hasGetAttaches = true;
                evt:updateCell(evt.m_data)
                self:updateView(g_SceneEvent.MAILBOX_EVENT_GET_ATTACH_SUCCESS,msg.m_attaches)
            else
                -- self:updateView(g_SceneEvent.MAILBOX_EVENT_GET_ATTACH_SUCCESS,msg.m_attaches)
                g_AlarmTips.getInstance():setText(GameString.get("str_mail_get_reward_failed")):show()
            end
        end
    end

    local params = HttpCmd:getMethod(HttpCmd.s_cmds.MSG_REWARD)
    params.id = id
    g_HttpManager:doPost(params, self, callback);
end

function MailBoxCtr:onGetAttach(response)
    local data, flag =  g_JsonUtil.decode(response)
    Log.d("MailBoxCtr:onGetAttach",data,flag)
end


-- 读取消息
function MailBoxCtr:onMailRead(evt)
    Log.d("MailBoxCtr:onMailGet ",evt.m_data)
    self:setMessageReaded(evt)
end

return MailBoxCtr