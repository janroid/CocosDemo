--[[
    author:{RyanXu}
    time:2019-3-20
    Description: 
]] 

local AccountManager = class("AccountManager")

AccountManager.TAG = "AccountManager";

AccountManager.s_eventFuncMap = {

}

function AccountManager.getInstance()
    if(AccountManager.s_instance == nil) then
        AccountManager.s_instance = AccountManager:create()
    end
    return AccountManager.s_instance
end

function AccountManager.release()
    AccountManager.s_instance:onCleanup()
    AccountManager.s_instance = nil
end

function AccountManager:ctor()
    self:registerEvent()
    self:clear()
end

function AccountManager.clearData()
    if  AccountManager.s_instance then
        AccountManager.s_instance:clear()
    end
end

function AccountManager:clear()
end

function AccountManager:onCleanup()
    self:unRegisterEvent()
end

---注册监听事件
function AccountManager:registerEvent()
    if self.s_eventFuncMap then
        for k,v in pairs(self.s_eventFuncMap) do
            g_EventDispatcher:register(k,self,self[v])
        end
    end
end

---取消事件监听
function AccountManager:unRegisterEvent()
    if g_EventDispatcher then
        g_EventDispatcher:unRegisterAllEventByTarget(self)
    end 
end


function AccountManager:requestUserInfo()
    local params = HttpCmd:getMethod(HttpCmd.s_cmds.USER_MAIN)
    g_HttpManager:doPost(params,self,self.onUserInfoCallBack)
end

function AccountManager:onUserInfoCallBack(isSuccess, data)
    if isSuccess and next(data) ~= nil and not g_TableLib.isEmpty(data) then
        if tonumber(data.win) and tonumber(data.lose) then
            local total = data.win + data.lose
            if total > 0 then
                g_AccountInfo:setWinRate(data.win / total)
            end
        end
        if tonumber(data.money) then
            g_AccountInfo:setMoney(data.money)
        end
        if tonumber(data.exp) then
            g_AccountInfo:setUserExp(data.exp)
        end
    else
        Log.e("AccountManager:onUserInfoCallBack", "error");
    end
end

return AccountManager