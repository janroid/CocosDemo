//
//  IPKBridgeCmd.h
//  iPoker
//
//  Created by loyalwind on 2018/12/17.
//  Lua-OC,OC-Lua 交互的命令字

// 注意写文档注释格式如下

/**
 * xxx
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * fb登录
 * @"FacebookBridge.onFacebookLogin:"
 */
IPKEXTERN_STRING kOnFacebookLogin;
/**
 * fb邀请好友
 * @"FacebookBridge.onInviteFriend:"
 */
IPKEXTERN_STRING kOnInviteFriend;

/**
 * 初始化游戏配置
 * @"LuaOCBridge.gameInitConfig:"
 */
IPKEXTERN_STRING kGameInitConfig;


// ...

NS_ASSUME_NONNULL_END
