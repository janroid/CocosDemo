local NativeCmd = {}

NativeCmd.KEY = {
    NATIVE_CMD_ENGINE_LOADED          = g_GetIndex(),  -- 引擎启动完成
    KEY_GAME_INIT_CONFIG              = g_GetIndex(), -- 获取游戏初始化数据
    KEY_LOGIN_FACEBOOK                = g_GetIndex(),  -- facebook登录
    KEY_LOGOUT_FACEBOOK               = g_GetIndex(),  -- facebook登出
    KEY_INVITE_FRIEND_FACEBOOK        = g_GetIndex(),  -- facebook邀请好友
    KEY_SHARE_FACEBOOK                = g_GetIndex(),  -- facebook分享
    KEY_QUERY_APPLE_PRODUCT           = g_GetIndex(),  -- 查询iTunes后台商品
    KEY_PAY                           = g_GetIndex(),  -- 支付
    KEY_APPLE_CONSUME_PURCHASE        = g_GetIndex(),  -- 检查iOS支付成功后, 但是未发货的, 防止丢单
    KEY_CHOOSE_IMAGE                  = g_GetIndex(),  -- 选择图片
    KEY_CHANGE_HEAD                   = g_GetIndex(), -- 修改头像
    KEY_JUMP_GOOGLE_PLAY              = g_GetIndex(),
    KEY_SET_GOOGLE_PAY_CGI_URL        = g_GetIndex(),  -- 设置google支付发货地址
    KEY_QUERY_GOOGLE_PRODUCT          = g_GetIndex(),  -- 获取google后台商品
    KEY_QUERY_GOOGLE_PRODUCT_DETAIL   = g_GetIndex(),  -- 获取google后台商品详情
    KEY_QUERY_GOOGLE_CONSUME_PURCHASE = g_GetIndex(),  -- 消费订单，防止丢单
    KEY_SHAKE                         = g_GetIndex(),  -- 手机震动
    KEY_UMENG_UPLOAD                  = g_GetIndex(),  -- 友盟上报

    KEY_GUEST_BINDED_EMAIL            = g_GetIndex(),  -- 游客绑定了emial了
    KEY_UPLOAD_FEED_IMAGE             = g_GetIndex(),  -- 上传反馈图片
}
--[[
iOS规则:方法放在iOSMethod中，分为对象方法，和类方法
    对象方法：带 '-', 或者不带均为对象方法，常用于异步方法
    类方法：带 '+'开头 表示调用类方法，通常用于同步方法
    例如：类名.方法名、+类名.方法名
    注意：目前最多只支持方法传递两个参数，self,_cmd除外
]]
NativeCmd.NATIVE_CONFIG = {
    [NativeCmd.KEY.NATIVE_CMD_ENGINE_LOADED] = { classPath = 'com.boyaa.entity.luaManager.LuaCommutication', method = 'onEngineLoaded', iOSMethod = '+AppController.engineLoaded' },
    [NativeCmd.KEY.KEY_GAME_INIT_CONFIG]     = { classPath = 'com.boyaa.entity.luaManager.LuaCommutication', method = 'getDeviceInfo', iOSMethod = '+IPKGameConfig.gameInitConfig:handle:' },
    [NativeCmd.KEY.KEY_LOGIN_FACEBOOK]       = {classPath = 'com.boyaa.entity.facebook.FBManager', method = 'login', iOSMethod = '+ IPKFBManager.login:handle:'},
    [NativeCmd.KEY.KEY_LOGOUT_FACEBOOK]    = { classPath = 'com.boyaa.entity.facebook.FBManager', method = 'logout', iOSMethod = '+IPKFBManager.logout' },
    [NativeCmd.KEY.KEY_INVITE_FRIEND_FACEBOOK] = { classPath = 'com.boyaa.entity.facebook.FBManager', method = 'invite', iOSMethod = '+IPKFBManager.inviteFriends:handle:' },
    [NativeCmd.KEY.KEY_SHARE_FACEBOOK] = { classPath = 'com.boyaa.entity.facebook.FBManager', method = 'share', iOSMethod = '+IPKFBManager.share:handle:'},
    [NativeCmd.KEY.KEY_QUERY_APPLE_PRODUCT]  = {classPath = '', method = '', iOSMethod = '+IPKApplePayManager.queryProduct:handle:'},
    [NativeCmd.KEY.KEY_PAY]                  = {classPath = 'com.boyaa.entity.pay.PayManager', method = 'pay', iOSMethod = '+IPKApplePayManager.pay:handle:'},
    [NativeCmd.KEY.KEY_APPLE_CONSUME_PURCHASE] = {classPath = '', method = '', iOSMethod = '+IPKApplePayManager.consumePurchase:handle:'},
    [NativeCmd.KEY.KEY_CHANGE_HEAD]          = {classPath = 'com.boyaa.entity.images.ImageManage', method = 'doHeadChangeImage', iOSMethod = '+IPKDeviceManager.pickImage:handle:'},
    [NativeCmd.KEY.KEY_CHOOSE_IMAGE]         = {classPath = 'com.boyaa.entity.images.ImageManage', method = 'doHeadChangeImage', iOSMethod = '+IPKDeviceManager.pickImage:handle:'},
    [NativeCmd.KEY.KEY_JUMP_GOOGLE_PLAY]     = {classPath = 'com.boyaa.entity.utils.Utils', method = 'jumpToGooglePlay'},
    [NativeCmd.KEY.KEY_SHAKE]                = {classPath = 'com.boyaa.entity.utils.Utils', method = 'shake'},
    
    [NativeCmd.KEY.KEY_SET_GOOGLE_PAY_CGI_URL]        = {classPath = 'com.boyaa.entity.pay.PayManager', method = 'setPayCGI', iOSMethod = '+IPKApplePayManager.setPayInfo:'},
    [NativeCmd.KEY.KEY_QUERY_GOOGLE_PRODUCT]          = {classPath = 'com.boyaa.entity.pay.PayManager', method = 'queryProduct'},
    [NativeCmd.KEY.KEY_QUERY_GOOGLE_PRODUCT_DETAIL]   = {classPath = 'com.boyaa.entity.pay.PayManager', method = 'queryProductDetail'},
    [NativeCmd.KEY.KEY_QUERY_GOOGLE_CONSUME_PURCHASE] = {classPath = 'com.boyaa.entity.pay.PayManager', method = 'consumePurchase'},
    [NativeCmd.KEY.KEY_UMENG_UPLOAD] = {classPath = 'com.boyaa.entity.umeng.Umeng', method = 'error', iOSMethod = '+IPKUploadManager.umError:'},

    [NativeCmd.KEY.KEY_GUEST_BINDED_EMAIL] = {classPath = 'com.boyaa.entity.luaManager.LuaCommutication', method = 'guestBindedEmail', iOSMethod = '+IPKGameConfig.guestBindedEmail:'},
    [NativeCmd.KEY.KEY_UPLOAD_FEED_IMAGE] = { classPath = 'com.boyaa.entity.http.HttpRequest', method = 'uploadFile', iOSMethod = '+IPKDeviceManager.uploadFeedImage:handle:'},

}

return NativeCmd
