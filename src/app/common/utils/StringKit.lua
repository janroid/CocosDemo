local StringKit = {};

--[Comment]
--将字符串str中"{0}"替换成字符串sub
StringKit.substitute = function(str,...)
    local arg = {...}
    local ret = str;
    if str ~= nil then
       for i = 1, #arg do
            local repl = tostring(arg[i]);
            local repl2 = string.gsub(repl, "%%", "%%%%");
--            if(repl2 ~= repl) then--检查要替换的字符串里有没有%，有的话就提示
--                EventDispatcher.getInstance():dispatch(UIEvent.s_event, UIEvent.s_cmd.OPEN_DIALOG,
--                {
--                    title = "StringKit.substitute",
--                    message = "data has %:" .. repl,
--                    confirm = "confirm",
--                });
--            end
            ret = string.gsub(ret, "{"..(i - 1).."}", repl2);
        end
    end
   return ret;
end

--[Comment]
--字符串分割，默认使用"."作为分隔符
StringKit.split = function(str, sep)
    sep = sep or "."
    local t={} ; 
    local i=1
    for str in string.gmatch(str, "([^"..sep.."]+)") do
        if str ~= nil then
            t[i] = str
            i = i + 1
        end
    end
    return t
end

--[Comment]
--数组拼接
StringKit.join = function(t, sep)
    sep = sep or "."
    local str = "";
    if t ~= nil then
        for i = 1, #t do
            if type(t[i]) == "table" then
                str = str .. sep .. "{" .. StringKit.join(t[i], sep) .."}";
            else
                str = str .. sep..tostring(t[i]);
            end
        end
    end
    if sep ~= "" and StringKit.indexOf(str, sep) == 1 then
        str = string.sub(str, 2);
    end
    return str;
end

--[Comment]
--字符串反转
StringKit.reverse = function(str)
    local ret = str;
    if str ~= nil then
        local arr = StringKit.toArray(str);
        for i = 1, #arr / 2 do
            arr[i], arr[#arr - i + 1] = arr[#arr - i + 1], arr[i];
        end
        ret = StringKit.join(arr, "");
    end
    return ret;
end

--[Comment]
--将字符串转化为数组
StringKit.toArray = function(str)
    local arr = {};
    if str ~= nil then
        local len = string.len(str);
        for i = 1, len do
            local sub = string.sub(str, i, i);
            if sub ~= nil then
                table.insert(arr, sub)
            end
        end
    end
    return arr;
end

--[Comment]
-- 去除string中的所有空格
-- @param s：要处理的字符串
-- return 返回处理后的string
StringKit.trim = function(s)
    if not s then
        return s;
    end
    local a = string.gsub(s," ","");
    return a;
end

--[Comment]
-- 计算中英文混合字符串的长度(空格算一个字符)，原因：由于string.len()方法，中文字符占3个长度
-- @param s: 中英文混合字符串
-- return len: 总长度，enLen: 英文(包括数字，字母，英文符号，空格)所占长度，chLen: 中文所占长度
StringKit.len = function(s)
    if s == nil then
        return 0,0,0;
    end
    local n = string.len(s);
    local a,b = string.gsub(s,"[%a%d%p%s]","");
      
    local m = string.len(a)/3;
      
    return m+b,b,m;
end

--[Comment]
-- 判断是否为邮箱
StringKit.isEmail = function(str)
    if string.len(str or "") < 6 then return false end 
     local b,e = string.find(str or "", '@') 
     local bstr = "" 
     local estr = "" 
     if b then 
         bstr = string.sub(str, 1, b-1) 
         estr = string.sub(str, e+1, -1) 
     else 
         return false 
     end 
  
     -- check the string before '@' 
     local p1,p2 = string.find(bstr, "[%w_.-]+") 
     if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end 
      
     -- check the string after '@' 
     if string.find(estr, "^[%.]+") then return false end 
     if string.find(estr, "%.[%.]+") then return false end 
     if string.find(estr, "@") then return false end 
     if string.find(estr, "[%.]+$") then return false end 
  
     _,count = string.gsub(estr, "%.", "") 
     if (count < 1 ) or (count > 3) then 
         return false 
     end 
  
     return true
end

--[Comment]
--验证手机号码
StringKit.checkPhoneNumValid = function( phoneNumber )
    local _,count = string.gsub(phoneNumber,"%d","");
    if count == string.len(phoneNumber) and string.len(phoneNumber) > 0 then return true; end
    return false;
end

--[Comment]
--返回指定子串的下标
StringKit.indexOf = function(str, sub)
    local index = -1;
    if str ~= nil and sub ~= nil then
        index = string.find(str, sub);
    end
    return index;
end

--[Comment]
--utf8字符串截取
StringKit.utf8_substring = function(str, first, num)
	local ret = "";
	local n = string.len(str);
	local offset = 1;
	local cp;
	local b, e;
	local i = 1;
	while i <= n do
		if not b and offset >= first then
			b = i;
		end
		if not e and offset >= first + num then
			e = i;
			break;
		end
		cp = string.byte(str, i);
		if cp >=0xF0 then
			i = i + 4;
		elseif cp >= 0xE0 then
			i = i + 3;
		elseif cp >= 0xC0 then
			i = i + 2;
		else
			i = i + 1;
		end
        offset = offset + 1;
	end
	if not b then
		return "";
	end

	if not e then
		e = n + 1;
	end
	ret = string.sub(str, b, e - b);
	return ret;
end

--[Comment]
--utf8字符串 字符个数
StringKit.utfstrlen = function (str)
    local _, cnt = string.gsub(str, "[^\128-\193]", "");
    return cnt;
end

--[Comment]
--把字符中的xml标签去掉
StringKit.removeXmlTag = function(str)
    local i = 1;
    local bInTag = false;
    local s = "";
    for i=1,string.len(str) do
        local ch = string.sub(str, i, i);
        if(ch == "<") then
            bInTag = true;
        elseif(ch == ">") then
            bInTag = false;
        else
            if(not bInTag) then
                s = s .. ch;
            end
        end
    end
    return s;
end

--[Comment]
--Unicode字符转换为UTF8串
StringKit.utf16_2_utf8 = function(codeUnicode)
	--[[
	Unicode编码(16进制)　║　UTF-8 字节流(二进制)
	000000 - 00007F　║　0xxxxxxx
　　000080 - 0007FF　║　110xxxxx 10xxxxxx
　　000800 - 00FFFF　║　1110xxxx 10xxxxxx 10xxxxxx
　　010000 - 10FFFF　║　11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
	--]]
    local s = nil;
	if(codeUnicode <= 0x7f) then
        s = string.char(codeUnicode);
	elseif(codeUnicode <= 0x7ff) then
		local val1 = bit.bor(0xc0, bit.brshift(codeUnicode, 6));
		local val2 = bit.bor(0x80, bit.band(codeUnicode, 0x3f));
		s = string.char(val1) .. string.char(val2);
	elseif(codeUnicode <= 0xffff) then
		local val1 = bit.bor(0xe0, bit.brshift(codeUnicode, 12));
		local val2 = bit.bor(0x80, bit.brshift(bit.band(codeUnicode, 0xfc0), 6));
		local val3 = bit.bor(0x80, bit.band(codeUnicode, 0x3f));
        s = string.char(val1) .. string.char(val2) .. string.char(val3);
	elseif(codeUnicode <= 0x10ffff) then
		local val1 = bit.bor(0xf0, bit.brshift(codeUnicode, 18));
		local val2 = bit.bor(0x80, bit.brshift(bit.band(codeUnicode, 0x3f000), 12));
		local val3 = bit.bor(0x80, bit.brshift(bit.band(codeUnicode, 0xfc0), 6));
		local val4 = bit.bor(0x80, bit.band(codeUnicode, 0x3f));
		s = string.char(val1) .. string.char(val2) .. string.char(val3) .. string.char(val4);
	else
    end
	return s;
end

--[Comment]
--把\u开头的字符转换为字符串
StringKit.convertSlashU = function(str)
    local i = 1;
    local nLen = string.len(str);
    local s = "";
    while(i <= nLen) do
        local ch = string.sub(str, i, i);
        if(ch == "\\" and i+1 <= nLen and string.sub(str, i+1, i+1) == "u") then
            ch = "0x" .. string.sub(str, i+2, i+5);
            ch = tonumber(ch);
            ch = StringKit.utf16_2_utf8(ch);
            s = s .. ch;
            i = i + 6;
        else
            s = s .. ch;
            i = i + 1;
        end
    end
    return s;
end

--[Comment]
--字符串中是否只有数字和字符
StringKit.isOnlyNumberOrChar = function(str)
    local t = ""
    local len = string.len(str);
    for str in string.gmatch(str,"[%w]") do
        t = t .. str
    end
    if len ~= string.len(t) then
        return false;
    else
        return true;
    end
end

--[Comment]
--字符串中是否只有数字
StringKit.isOnlyNumber = function(str)
    local t = ""
    local len = string.len(str);
    for str in string.gmatch(str,"[%d]") do
        t = t .. str
    end
    if len ~= string.len(t) then
        return false;
    else
        return true;
    end
end

return StringKit