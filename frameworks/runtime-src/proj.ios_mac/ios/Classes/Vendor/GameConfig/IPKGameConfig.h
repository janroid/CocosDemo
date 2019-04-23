//
//  IPKGameConfig.h
//  iPoker
//
//  Created by loyalwind on 2018/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPKGameConfig : NSObject

/**
 初始化游戏配置

 @param dict 参数，无用途
 @param handle 回调到lLua
 */
+ (void)gameInitConfig:(NSDictionary *)dict handle:(IPKHandleBridge)handle;
+ (void)guestBindedEmail:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
