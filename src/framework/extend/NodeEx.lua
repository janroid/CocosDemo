


-- 删除对象
local function delete(obj)
  	do
	    local destory =
	    function(c)
			if c.class then
				if c.class.dtor then
				  c.class.dtor(obj)
			   end
	  
			   c = c.class.super
			  else
				if c.dtor then
				  c.dtor(obj)
				end
				c = c.super
			  end
	    end
    	destory(obj);
  	end
end

-- 删除对象的子节点
local function deleteWithChildren(node)
  	if node then
	    local chidren = node:getChildren()
	    for k,v in pairs(chidren) do
	      	deleteWithChildren(v)
	    end
    	delete(node)
  	end
end

return {delete = delete, deleteWithChildren = deleteWithChildren };