
local PopupLayer = require "scenes.layers.PopupLayer"

local testGetUrl =  "https://ipk-demo-cdn.boyaa.com/bigfile-ws/mbapk/assets200_203.zip"
--local downPngUrl =  "https://graph.facebook.com/466332220520275/picture?type=large"--"http://www.cocos2d-x.org/attachments/802/cocos2dx_landscape.png"
local downPngUrl =  "https://ipk-demo-cdn.boyaa.com/bigfile-ws/mbapk/assets200_203.zip"--"http://www.cocos2d-x.org/attachments/802/cocos2dx_landscape.png"

local downBigFileUrl =  "http://download.cocos.com/CocosCreator/v1.9.3/CocosCreator_v1.9.3.setup.7z"

--local testPostUrl =  "http://127.0.0.1:8082"
local identifier_png = "cocos2dx_landscape.png"
local identifier_bigFile = "identifier_bigFile"


local TestDownload = class("TestDownload", PopupLayer)

function TestDownload:ctor()
	PopupLayer.ctor(self)
	self.m_downloader = cc.Downloader.new()
	
	self:init()




end

function TestDownload:dtor()

end

function TestDownload:init()

	self.m_colorLayer:setOpacity(255)
	local writablePath = cc.FileUtils:getInstance():getWritablePath()


	local menuRequest = cc.Menu:create()
    menuRequest:setPosition(cc.p(0,0))
    self:addChild(menuRequest)

	local function onDownloadFileClicked()

		for i = 1,1 do
			local name = "task_img"..i
			local path = writablePath .. "/"..i.."img.png"
			--self.m_downloader:createDownloadDataTask(downPngUrl, name )
			self.m_downloader:createDownloadFileTask(downPngUrl, path,name )
		end
		--self:test2()

		self.m_labelStatus:setString("waiting...")
	end

	local labelGet  = cc.Label:createWithSystemFont("Test Download Image", "", 30)
    labelGet:setAnchorPoint(cc.p(0.5, 0.5))
    local itemGet  =  cc.MenuItemLabel:create(labelGet)
    itemGet:registerScriptTapHandler(onDownloadFileClicked)
    itemGet:setPosition(display.width / 2, display.height/2)
	menuRequest:addChild(itemGet)
	

	self.m_labelStatus = cc.Label:createWithSystemFont("", "", 30)
	self.m_labelStatus:setPosition(display.width / 2,display.height/2-50)
	self:addChild(self.m_labelStatus)


	local function onTaskSuccess(task)
		--if task.identifier == "task_img" then
			self.m_labelStatus:setString("image download success ..")
			print(task.identifier)
			local sprite = cc.Sprite:create(task.storagePath)
			sprite:setPosition(display.center.x+math.random(0,200),display.center.y+200)
			self:addChild(sprite);
		
	end
	local function onProgress(task, bytesReceived, totalBytesReceived, totalBytesExpected)
		if task.identifier == "task_img" then
			self.m_labelStatus:setString("image download progress " .. tostring(math.floor(totalBytesReceived/totalBytesExpected*100)))
		elseif task.identifier == "task_no_exist" then
			self.m_labelStatus:setString("txt download progress " .. tostring(math.floor(totalBytesReceived/totalBytesExpected*100)))
		end
	end
	local function onTaskError(task, errorCode, errorCodeInternal, errorStr)
		if task.identifier == "task_img" then
			self.m_labelStatus:setString("image download error: "..errorStr)
		elseif task.identifier == "task_no_exist" then
			self.m_labelStatus:setString("txt download error: "..errorStr)
		end

		print("identifier = ",task.identifier ,"onTaskError errorCode =",errorCode,"errorCodeInternal=",errorCodeInternal,"errorStr=",errorStr)
	end
	self.m_downloader:setOnFileTaskSuccess(onTaskSuccess)
	self.m_downloader:setOnTaskProgress(onProgress)
	self.m_downloader:setOnTaskError(onTaskError)

end


function TestDownload:test2()

	local url = "https://graph.facebook.com/466332220520275/picture?type=large"
	local xhr = cc.XMLHttpRequest:new();
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER;  --cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url);
	local function onDownloadImage()
	if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
		local fileData = xhr.response;
		local size = table.getn(fileData);
		
		
		local fullFileName = "E:/cocos/IPoker_cocos_d/simulator/win32" .. "/test.jpg";
		local file = io.open(fullFileName,"wb");
		-- file:write(fileData)
		for i = 1, size do
			file:write(string.char(fileData[i]));
		end 
		file:close();

	    print("start download finish url = ",url,"fullFileName = ",fullFileName);


	else 

	end
end 
xhr:registerScriptHandler(onDownloadImage);
xhr:send();

end
return TestDownload
