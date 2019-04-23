local XmlSimple = {}

function XmlSimple.newParser()

    local XmlParser = {};

    function XmlParser:ToXmlString(value)
        value = string.gsub(value, "&", "&amp;"); -- '&' -> "&amp;"
        value = string.gsub(value, "<", "&lt;"); -- '<' -> "&lt;"
        value = string.gsub(value, ">", "&gt;"); -- '>' -> "&gt;"
        value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
        value = string.gsub(value, "([^%w%&%;%p%\t% ])",
            function(c)
                return string.format("&#x%X;", string.byte(c))
            end);
        return value;
    end

    function XmlParser:FromXmlString(value)
        value = string.gsub(value, "&#x([%x]+)%;",
            function(h)
                return string.char(tonumber(h, 16))
            end);
        value = string.gsub(value, "&#([0-9]+)%;",
            function(h)
                return string.char(tonumber(h, 10))
            end);
        value = string.gsub(value, "&quot;", "\"");
        value = string.gsub(value, "&apos;", "'");
        value = string.gsub(value, "&gt;", ">");
        value = string.gsub(value, "&lt;", "<");
        value = string.gsub(value, "&amp;", "&");
        return value;
    end

    function XmlParser:ParseArgs(node, s)
        string.gsub(s, "([%w_]+)%s*=%s*([\"'])(.-)%2", function(w, _, a)
            node:addProperty(w, self:FromXmlString(a))
        end)
    end

    function XmlParser:ParseXmlText(xmlText)
        local stack = {}
        local top = XmlSimple.newNode()
        table.insert(stack, top)
        local ni, c, label, xarg, empty
        local i, j = 1, 1

        local result = true;
        while true do
            ni, j, c, label, xarg, empty = string.find(xmlText, "<(/?)([%w_:]+)(.-)(/?)>", i)
            if not ni then break end

            local text = string.sub(xmlText, i, ni - 1);
            if not string.find(text, "^%s*$") then
                local lVal = (top:value() or "") .. self:FromXmlString(text)
                stack[#stack]:setValue(lVal)
            end
            if empty == "/" then -- empty element tag
                local lNode = XmlSimple.newNode(label)
                self:ParseArgs(lNode, xarg)
                top:addChild(lNode)
            elseif c == "" then -- start tag
                local lNode = XmlSimple.newNode(label)
                self:ParseArgs(lNode, xarg)
                table.insert(stack, lNode)
		        top = lNode
            else -- end tag
                local toclose = table.remove(stack) -- remove top

                top = stack[#stack]
                if #stack < 1 then
                    --error("XmlParser: nothing to close with " .. label)
                    result = false;
                    break;
                end
                if toclose:getName() ~= label then
                   -- error("XmlParser: trying to close " .. toclose.name .. " with " .. label)
                    result = false;
                    break;
                end
                top:addChild(toclose)
            end
            i = j + 1
        end
        local text = string.sub(xmlText, i);
        if #stack > 1 then
            --error("XmlParser: unclosed " .. stack[#stack]:getName())
            result = false;
        end
        if result then
            return top
        end
        return nil;
    end

    function XmlParser:loadFile(xmlFilename, base)
    	if not xmlFilename then
    		return nil;
    	end 
    	
    	base = base or "";
        path = base .. xmlFilename;
	
        local hFile, err = io.open(path, "r");

        if hFile and not err then
            local xmlText = hFile:read("*a"); -- read file content
            io.close(hFile);
            return self:ParseXmlText(xmlText), nil;
        else
            print(err)
            return nil
        end
    end

    return XmlParser
end

function XmlSimple.newNode(name)
    local node = {}
    node.___value = nil
    node.___name = name
    node.___children = {}
    node.___props = {}

    function node:value() return self.___value end
    function node:setValue(val) self.___value = val end
    function node:getName() return self.___name end
    function node:setName(name) self.___name = name end
    function node:children() return self.___children end
    function node:numChildren() return #self.___children end
    function node:addChild(child)
        if self[child:getName()] ~= nil then
            local s = self[child:getName()];
            if type(self[child:getName()].name) == "function" then
                local tempTable = {}
                table.insert(tempTable, self[child:getName()])
                self[child:getName()] = tempTable
            end
            table.insert(self[child:getName()], child)
        else
            self[child:getName()] = child
        end
        table.insert(self.___children, child)
    end

    function node:properties() return self.___props end
    function node:numProperties() return #self.___props end
    function node:addProperty(name, value)
        local lName = "@" .. name
        if self[lName] ~= nil then
            if type(self[lName]) == "string" then
                local tempTable = {}
                table.insert(tempTable, self[lName])
                self[lName] = tempTable
            end
            table.insert(self[lName], value)
        else
            self[lName] = value
        end
        table.insert(self.___props, { name = name, value = self[name] })
    end

    return node
end
return XmlSimple