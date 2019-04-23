-- require("json");
--[Comment]
--JSON工具类，提供JSON的安全解析编码操作
local JsonKit = {};

JsonKit.use_cjson = true;
--[Comment]
--解析JSON，
--flag 是否解析成功标识
--ret 解析后的对象
JsonKit.decode = function(str)
    if not str then return nil end;
    
    if string.len(str) < 1 then return nil end;
    -- if(JsonKit.cjson == nil and JsonKit.use_cjson) then
    --     pcall(function()
    --             JsonKit.cjson = require("cjson");
    --         end
    --     );
    --     if JsonKit.cjson == nil then
    --         JsonKit.use_cjson = false;
    --     end
    -- end
    local ret = nil;
    local flag,err = pcall(function()
        if(JsonKit.use_cjson) then
            ret = cjson.decode(str);
        else
            ret = json.decode(str);
        end
    end);
    if(not flag) then
        Log.d("gwjgwj", "JsonKit error:" ..  err);
    end
    return ret, flag;
end

--[Comment]
--编码JSON
--flag 是否编码成功标识
--ret 编码后的JSON String
JsonKit.encode = function(t)
    local str = nil;
    local flag = pcall(function() str = json.encode(t) end);
    return str, flag;
end

return JsonKit