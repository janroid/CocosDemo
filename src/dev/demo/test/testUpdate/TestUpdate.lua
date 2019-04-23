local desc = {
	title = "本版本号为1.0.0";
	time = "2019-3-3 16:30";
	name = "Loyalwind";
}

local UpdateDemo = {}

function UpdateDemo.getDescription()
	local ret = string.format("title :%s \n time :%s \n name :%s \n",desc.title, desc.time, desc.name)
	print(ret)
	return ret
end

return UpdateDemo
