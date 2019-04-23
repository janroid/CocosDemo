--[[
    业务调用方式：
    require1:加载非包目录下的文件，只支持全路径
    require：加载包内文件时调用，支持相对包的路径
    举例：
    app
    	hall
		    pkg1
		    	init.lua  加载test文件：require("test")，加载a1文件：require("aa.a1"), 
		    	test.lua
		    	aa
		    		a1.lua 加载test文件：require("test")，加载b1文件：require("bb.b1"), 
		    	bb
		    		b1.lua
		    pkg2
		    ...

	import: 用来加载包结构的目录
		加载pak1的包： import("app.scenes.pkg1")
]]