--[[
    用于保存游戏中和平台相关的数据
    author:{author}
    time:2018-10-25 16:01:41
]]

local GameConfig = {}

GameConfig.API = 1

GameConfig.LOGIN_URL = "https://pclpvnik02.boyaagame.com/"
GameConfig.LOGIN_URL_DEMO = "https://ipk-demo-9.boyaa.com/"

GameConfig.SPECIAL_CGI                    = "https://pclpvnik02.boyaagame.com/mobilespecial_java.php"
GameConfig.SPECIAL_CGI_DEMO               = "https://ipk-demo-9.boyaa.com/mobilespecial_java.php"
GameConfig.PLAYSTOREPUBLICKEY  = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyMGhY7hPyVwKZlmWEeBhTNRx3auDGTnIl8a842gyoK8dAXm3mtjQDqeU5lPNWp7EjpWek72sfROwDPv1SY2YfQDM3rCpFu6lM6zhnjvp6boWPB6DIpDT71qRwU7YGkq43oDSOTFx7shT2oOdzWX3wgNRFJtthqN/exc6rIBBm9zOGNDduUjc4+GJB5A1e64RdM4efp9l1Iu+O5FGFJrF+m0pVJqpgFC9hU1vC5a5BtZCXFirYZQX0ulxRZYOmhXW101NAZXIiiNrlVWYbc6LTQO8a33wLtDRTJQ6/DvXindmeVQSG9xQ4hxmNIVN/z3CYbTqNn4InlnZch8rZZyDEwIDAQAB";
GameConfig.ANDROID_VER        = "";

GameConfig.APP_ID       = 'ipk11009'
GameConfig.APPID_DEMO   = "ipk21009"

GameConfig.SUB_VER = "" --某个语言的子版本，id1=印尼1，id2=印尼2，vn1=越南1，vn2=越南2

-- 热更新
GameConfig.UPDATE_URL = "https://pclpvnik11.boyaagame.com/mobilespecial.php"; --外网热更新检测地址
GameConfig.UPDATE_URL_DEMO = "https://ipk-demo-9.boyaa.com/mobilespecial.php"; --内网热更新检测地址
GameConfig.REGIONAL_ID = "vn"; --区域标识，根据cms后台定的

-- 商定包地址
GameConfig.STORE_URL_IOS = 'https://itunes.apple.com/app/id722784550';
GameConfig.STORE_URL_ANDROID = "market://details?id=air.com.coalaa.itexasvn";

-- fb分享
GameConfig.FB_APPLINK_URL = "https://pclpvnik11.boyaagame.com/api/facebook/applink";

return GameConfig