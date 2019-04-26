local HttpReceive = class("HttpReceive")

function HttpReceive:ctor()
    
end

function HttpReceive:receive(cmd,obj,func)
    if cmd == g_HttpCmd.GetConfig then
        self:receiveGetConfig(obj,func)
    end
end

function HttpReceive:receiveGetConfig(obj, func)
    local tab = {
        iplist = {"172.0.0.1",8000}
    }

    if func then
        if obj then
            func(obj, true, tab)
        else
            func(true, tab)
        end
    end
end

return HttpReceive