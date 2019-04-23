--[[
    用于保存游戏中和平台相关的数据
    author:{author}
    time:2018-10-25 16:01:41
]]

local GameConfig = {}

GameConfig.API = 1

GameConfig.LOGIN_URL = "https://mvlpthik01.boyaagame.com/"
GameConfig.LOGIN_URL_DEMO = "https://ipk-demo-1.boyaa.com/"

GameConfig.SPECIAL_CGI                    = "https://mvlpthik01.boyaagame.com/mobilespecial_java.php"
GameConfig.SPECIAL_CGI_DEMO               = "https://ipk-demo-1.boyaa.com/mobilespecial_java.php"
GameConfig.PLAYSTOREPUBLICKEY  = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtQicpTrLevQwdCAjsEF1bEs3JHqxeP6wWQ4x9IsAyZH1ayKGnEuvFgWGvvQfSi86C9BY2bPrr4YO4TclkWuj6i3HiQoaJkKNNGZkkR/MxbgW0ewlEzRC6TYGDr1TZ1RbV9ZlvA7F23ZGcD/ynkIn6EqVO3nC4gHGtNgNW3eMkj7L+1SV4ixpYGlD5M5tTW16mRY/5IbQzzn4E1XK847KcW+EtjF4Vd9TDr5Ygz6JbtMjrLNP2LnmBs0wDyCdZL0k+6JftIn1YwTtWjTYj3nisON1QsrwvCD8yn9MsJk5kZmcGPSL4Z5BC3fDidO2mr/22KCzBMDCauGk6MRm0nZVFwIDAQAB";
GameConfig.ANDROID_VER        = "";

GameConfig.APP_ID       = 'ipk10001'
GameConfig.APPID_DEMO   = "ipk20001"

GameConfig.SUB_VER = "" --某个语言的子版本，id1=印尼1，id2=印尼2，vn1=越南1，vn2=越南2

-- 热更新
GameConfig.UPDATE_URL = "https://pclpthik01-static.boyaagame.com/mobilespecial.php" --外网热更新检测地址
GameConfig.UPDATE_URL_DEMO = "https://ipk-demo-1.boyaa.com/mobilespecial.php" --内网热更新检测地址
GameConfig.REGIONAL_ID = "th"; --区域标识，根据cms后台定的

-- 商定包地址
GameConfig.STORE_URL_IOS = "https://itunes.apple.com/app/780321861"
GameConfig.STORE_URL_ANDROID = "market://details?id=com.coalaa.itexaspro.cn"

-- fb分享
GameConfig.FB_APPLINK_URL = "http://pclpthik01.boyaagame.com/api/facebook/applink"

return GameConfig