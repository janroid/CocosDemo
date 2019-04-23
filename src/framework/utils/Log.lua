--[[
    author:{JanRoid}
    time:2018-11-09 11:45:13
    Description: 日志管理
]]

local Log = {}

Log.s_priveteKey = {
	["__index"]  = "priveteKey"; -- 这个已经过滤了
	["class"]  = "priveteKey";
	["tolua_ubox"]  = "priveteKey";
}

-- debug日志
function Log.d(tag, ...)
    Log.pr("DEBUG",tag, ...)
end

-- 错误日志
function Log.e(tag, ...)
    Log.pr("ERROR",tag, ...)
end

-- 常规性日志
function Log.i(tag, ...)
    Log.pr("INFO", tag, ...)
end

-- socket日志, socket相关打印请使用这个，便于以后过滤忽略socket满屏打印
function Log.s(tag, ...)
	if Log.isCloseSocketInfo() then
		return
	end
    Log.pr("SOCKET", tag, ...)
end

function Log.pr(mtype, tag, ...)
    if DEBUG == 0 then
        return;
    end

    local datePreFix = os.date("%Y-%m-%d %H:%M:%S") or ""
	local info = Log.getData(tag, ...)
	
	if mtype == "ERROR" then
		local traceback = Log._traceback(4)
		info = string.format("[%s]-[%s]-%s%s", tostring(datePreFix), tostring(mtype), tostring(traceback), tostring(info))
	else
		info = string.format("[%s]-[%s]-%s", tostring(datePreFix), tostring(mtype), tostring(info))
	end
	
    -- info = "[" .. tostring(datePreFix) .. "]-[" .. tostring(mtype) .. "]-" .. tostring(info)
	local arr = string.split(info, "\n")
	for _,v in pairs(arr) do
        print(v)
	end
end

function Log.getData(tag, ...)
    tag = tag or ""
    local info = ""
    for _, v in pairs({...}) do
        local tempType = type(v)
        if tempType == "table" then
            local str = Log.loadTable(v);
            info = info..tostring(str);
        elseif tempType == "userdata" then
            info = info .. tempType
        else
            info = info .. tostring(v)
        end

        info = info .. "    "
    end

    return string.format( "[%s]:%s", tag, info )
end


local s_tab = ""
function Log.loadTable(t)
	if type(t) ~= "table" then 
		return t;
	end 

	local tab = s_tab;
	s_tab = s_tab.."    ";
	local temp = "";
	for k,v in pairs(t) do 
		--if v ~= nil then
			if type(v) == "table" then
				if Log.s_priveteKey[k] then -- 打印对象出错
					v = Log.s_priveteKey[k] 
				end
			end

			local key = s_tab;
			if type(k) == "string" then
				key = key.."[\""..tostring(k).."\"] = ";
			else 
				key = key.."["..tostring(k).."] = ";
			end 
			
			if type(v) == "table" then 
				temp = temp..key..Log.loadTable(v);
			elseif type(v) == "nil" then
				temp = temp..key.. "nil" ..";\n";
			else
				temp = temp..key..tostring(v)..";\n";
			end 
		--end
	end 
	s_tab = tab;
	temp = "\n"..s_tab.."{\n"..temp..s_tab.."}\n";
	
	return temp;
end 

--[[
    @desc: 获取调用堆栈信, private function,
	--@level: 该函数Log._traceback与最终想要显示调用处相差的堆栈数 比如：LoginScene:ctor()调用了Log.d(), 堆栈信息包含Log.d()在LoginScene:ctor()内部所在的行号，函数名等等 LoginScene:ctor()-->Log.d()-->Log.pr()-->Log._traceback(),默认level是4
    @return: 调用Log处的位置信息
]]
function Log._traceback(level)
	local tmp = ""
    if not Log.getUseTraceback() then  return tmp end
 
    if DEBUG == 0 then  return tmp end

	local traceback = string.split(debug.traceback("", level), "\n")
	if traceback[3] then
		return string.trim(traceback[3]).."\n";
	end
	return tmp;
end

-- 增加是否需要追溯堆栈信息setter/getter，默认追溯堆栈信息
addProperty(Log, "useTraceback", true)

-- 设置关闭socket日志
function Log.setCloseSocketInfo(close)
	Log.s_closeSocketInfo = close
end

function Log.isCloseSocketInfo()
	return Log.s_closeSocketInfo
end

Log.writeFile = function(tag,...)
	if DEBUG > 1 then
		return;
	end
	local datePreFix = os.date("%Y-%m-%d %H:%M:%S") or "";
	local strInfo = string.format("%s%s%s%s",datePreFix , " : ", Log.getData(tag,...) , "\n");
	local dateFileName=os.date("%Y_%m_%d") or "";
	local fileFullPath = string.format("%s%s%s%s",cc.FileUtils:getInstance():getWritablePath() , "/log_" , dateFileName , ".log");
	local file = io.open(fileFullPath,"a");
	if file then
		file:write(strInfo);
		file:close();
	end
end

return Log