
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 640,
    height = 1136,
    autoscale = "FIXED_HEIGHT",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        --local scaleX, scaleY = framesize.width / 1136, framesize.height / 640
        if ratio < 0.57  then
            return {autoscale = "FIXED_WIDTH"}
        else
            return {autoscale = "FIXED_HEIGHT"}
        end
    end
}



XG_USE_TEST_SCENE = true

XG_USE_FAKE_SERVER = false
XG_SERVER_IP = "127.0.0.1"
--XG_SERVER_IP = "193.112.44.227"
XG_SERVER_PORT = 14001