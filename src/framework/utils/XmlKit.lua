--[Comment]
--XML工具类，提供XML的安全解析编码操作
local XmlKit = {};

--[Comment]
--解析XML，
--flag 是否解析成功标识
--ret 解析后的对象, 已经将根节点items去除
XmlKit.decode = function(str)
    local ret = nil;
    local flag = xpcall(function()  
        local xml = import("XmlSimple").newParser();
        local node = xml:ParseXmlText(str);
        if node then
            ret = XmlKit.decodeNode(node);
            if ret.items then
                ret = ret.items;
            end
        end
    end, function(err)
        Log.d("error", tostring(err));
        Log.d("error", debug.traceback());
    end);
    return flag, ret;
end

--[Comment]
--将解析出来的xml转换为table {name = value}
XmlKit.decodeNode = function(node)
    local ret = {};
    local num = node:numChildren();
    if num == 0 then
        ret = node:value();
    else
        for i = 1, num do
            local child = node:children()[i];
            local name = child:getName();
            local table = XmlKit.decodeNode(child);
            if ret[name] then
                local tmp = ret[name];
                if #tmp == 0 then
                    ret[name] = {};
                    ret[name][1] = tmp;
                    ret[name][2] = table;
                else
                    ret[name][#tmp + 1] = table;
                end
                
            else
                ret[name] = table;
            end
        end
    end
    return ret;
end

--[Comment]
--TODO
XmlKit.encode = function(t)
    --TODO
end

--[Comment]
--xml解析demo
--function test22()
--    local str = "<match><sk_key_str>MATCHSTATUS_2015-11-20-00-10-00_16</sk_key_str><iswm>0</iswm><mtype>13</mtype><mid>16</mid><time>1447949400</time><pic>比赛测试3</pic><img>advance</img><num>0</num><bm>0</bm><st>11-2000:10</st><ip>192.168.202.85</ip><port>7172</port><rt>0</rt><rit>0</rit><am>0</am><isend>0</isend><hasReuslt>1</hasReuslt><lig>1</lig><ticketBuyIn>0</ticketBuyIn><isSupportRebuy>1</isSupportRebuy><isRecomMatch>0</isRecomMatch><name>比赛测试3</name><field>16</field><rank>0</rank></match>";
--    local flag, tab = XmlKit.decode(str);
--end
return XmlKit
