local bit = require("framework/utils/BitUtil")
local mathlib = require("framework/utils/MathLib")
local ArrayKit = require("framework/utils/ArrayKit")

local RC4     = {};
RC4.sbox = {};
RC4.mykey = {};
		
--[Comment]
--使用特定key加密特定字符串
RC4.encrypt = function(src, key)
	local mtxt   = RC4.strToChars(src);
	local mkey   = RC4.strToChars(key);
	local result = RC4.calculate(mtxt, mkey);
	return RC4.charsToHex(result);
end
		
--[Comment]
--使用特定key解密制定字符串
RC4.decrypt = function(src, key)
	local mtxt   = RC4.hexToChars(src);
	local mkey   = RC4.strToChars(key);
	local result = RC4.calculate(mtxt, mkey);
	return RC4.charsToStr(result);
end

RC4.initialize = function(pwd)
	local b = 0;
	for a = 1, 256 do
		RC4.mykey[a] = pwd[mathlib.mod(a - 1, #pwd) + 1];
		RC4.sbox[a] = a - 1;
	end

	for a = 1, 256 do
		b = mathlib.mod((b + RC4.sbox[a] + RC4.mykey[a]) , 256);
		RC4.sbox[a], RC4.sbox[b + 1] = RC4.sbox[b + 1], RC4.sbox[a];
	end
end

RC4.calculate = function(plaintxt, psw)
	RC4.initialize(psw);
	local i = 0; 
    local j = 0;
	local k = 0;
    local cipher = {};
    local cipherby = 0;
	for a = 1, #plaintxt do
		i = mathlib.mod((i+1), 256);
		j = mathlib.mod((j+RC4.sbox[i + 1]), 256);
		
        RC4.sbox[i + 1],  RC4.sbox[j + 1] = RC4.sbox[j + 1], RC4.sbox[i + 1];

		local idx = mathlib.mod((RC4.sbox[i + 1]+ RC4.sbox[j + 1]) , 256);
		k = RC4.sbox[idx + 1];
		
        cipherby = bit.bxor(tonumber(plaintxt[a]), k);
		ArrayKit.push(cipher, cipherby);
	end
	return cipher;
end

RC4.charsToHex = function(chars)
	local result = "";
	local hexes  = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"};
	for i = 1, #chars do
		local aa = hexes[tonumber(bit.brshift(chars[i], 4)) + 1];
		local bb = hexes[tonumber(bit.band(chars[i], 0xf)) + 1];
		result = result .. aa .. bb;
	end
	return result;
end

RC4.hexToChars = function(hex) 
	local codes ={};
    for i = 1, (#hex - 1), 2 do
		ArrayKit.push(codes, tonumber("0x"..string.sub(hex, i, i+1)));
	end
	return codes;
end

RC4.charsToStr = function(chars)
	local result = "";
	for i = 1, #chars do
		result = result .. string.char(chars[i]);
	end
	return result;
end

RC4.strToChars = function(str)
	local codes = {};
	for i = 1, string.len(str) do
        local char = string.sub(str, i, i);
        char = string.byte(char);
		ArrayKit.push(codes, char);
	end
	return codes;
end

return RC4