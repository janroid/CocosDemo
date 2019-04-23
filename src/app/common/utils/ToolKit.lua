

local ToolKit = {};

--[Comment]
--RC4解码
ToolKit.rc4_decrypt = function(str,key)
    local ret = "";
    if key ~= nil and str ~= nil then
        local RC4 = require("RC4");
        ret = RC4.decrypt(str,key);
    end
    return ret;
end


--[Comment]
--RC4編碼
ToolKit.rc4_encrypt = function(str,key)
    local ret = "";
    if key ~= nil and str ~= nil then
        local RC4 = require("RC4");
        ret = RC4.encrypt(str,key);
    end
    return ret;
end

return ToolKit