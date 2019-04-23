local curlUtils = require("dev.demo.curl.curlUtils")

local function createScene()
    local scene = display.newScene()
    display.runScene(scene)

    
    local newNode = display.newNode()
    newNode:setContentSize(display.size)
    newNode:addTo(scene):align(display.LEFT_BOTTOM,0,0)

    local Items = {"下载","暂停","取消","断点续传"}
    local label = GameString.createLabel("init",  "fonts/arial.ttf", 20)
    label:setColor(cc.c3b(255,0,0))
    label:addTo(newNode):align(display.CENTER,1 / 2 * display.width,display.cy + 250)

    local function updatelabel(content)
        label:setString(content)
    end

    local labels = {}
    local downID = nil
    local pauseDownload = false
    local writablePath = device.writablePath
    math.randomseed(os.time())
    local saveFileName = "testView_temp_" .. tostring(math.random( 0,10000))
    -- saveFileName = "testView_temp_7836"
    local savePath = writablePath .. saveFileName;
    local url = "https://codeload.github.com/githubMayajie/cocos2d-x/zip/v3"
    -- local url = "https://curl.haxx.se/docs/manpage.html" --该网站支持断点续传参数，上面的git地址不支持
    for i,v in ipairs(Items) do
        local item = ccui.Button:create()
        item:setContentSize(cc.size(100,40))
		item:setTitleText(v)		
		item:setTitleColor(cc.WHITE)--cc.c3b(_r,_g,_b))
		item:setTitleFontSize(30)
        item:setPressedActionEnabled(true)
        item:addTo(newNode):align(display.CENTER, i / 5 * display.width,display.cy + 100)
		item:addClickEventListener(function(sender)
            if i == 1 then
                downID = curlUtils.downBigFile(url,savePath,updatelabel)
            elseif i == 2 then
                pauseDownload = not pauseDownload;
                curlUtils.pause_resume_downloadImage(downID,pauseDownload)
            elseif i == 3 then
                curlUtils.cancelDownload(downID)
            elseif i == 4 then
                curlUtils.rangeDownload(url,savePath,updatelabel)
            end
        end)
    end

    if true then
        local Items = {"上传","暂停","取消","断点续传（需要server支持）"}
        local label = GameString.createLabel("init",  "fonts/arial.ttf", 20)
        label:setColor(cc.c3b(255,0,0))
        label:addTo(newNode):align(display.CENTER,1 / 2 * display.width,display.cy - 250)
    
        local function updatelabel(content)
            print(content)
            label:setString(content)
        end
    
        local labels = {}
        local downID = nil
        local pauseDownload = false
        local writablePath = device.writablePath
        math.randomseed(os.time())
        local saveFileName = "CocosCreator_v1.9.3.setup.7z"
        -- local saveFileName = "CMakeLists.txt"
        -- local savePath = writablePath .. saveFileName;
        local savePath = cc.FileUtils:getInstance():fullPathForFilename(saveFileName)   
        local url = "http://127.0.0.1:8080/upload" --上传地址
        for i,v in ipairs(Items) do
            local item = ccui.Button:create()
            item:setContentSize(cc.size(100,40))
            item:setTitleText(v)		
            item:setTitleColor(cc.WHITE)--cc.c3b(_r,_g,_b))
            item:setTitleFontSize(30)
            item:setPressedActionEnabled(true)
            item:addTo(newNode):align(display.CENTER, i / 5 * display.width,display.cy - 100)
            item:addClickEventListener(function(sender)
                if i == 1 then
                    downID = curlUtils.uploadFile(url,"file",saveFileName,savePath,updatelabel)
                elseif i == 2 then
                    pauseDownload = not pauseDownload;
                    curlUtils.pause_resume_downloadImage(downID,pauseDownload)
                elseif i == 3 then
                    curlUtils.cancelDownload(downID)
                elseif i == 4 then
                    
                end
            end)
        end
    end
end

createScene()