//
//  IPKFacebookLogin.h
//  CardGame
//
//  Created by loyalwind on 2018/11/9.
//  处理facebook有关的操作

#import <Foundation/Foundation.h>
#import "Singleton.h"

NS_ASSUME_NONNULL_BEGIN
/**
 处理完成的回调Block
 @param success 是否成功
 @param resultData 回调参数
 */
typedef void(^IPKHandleCompletion)(BOOL success, id _Nullable resultData);

@interface IPKFBManager : NSObject

SingleInterface(Manager);

/**
 开始登陆
 @param param 参数，不用传也可以
 @param compeletion 登陆完成的回调
 */
+ (void)login:(NSDictionary *)param handle:(IPKHandleBridge)handle;

/**
 退出登陆
 */
+ (void)logout;

/**
 分享
 @param params 分享参数
 @param completion 回调
 */
+ (void)share:(NSDictionary *)params handle:(IPKHandleBridge)handle;

/**
 邀请fb好友
 @param params 邀请参数
 @param completion 回调
 */
+ (void)inviteFriends:(NSDictionary *)params handle:(IPKHandleBridge)handle;
//
///**
// 获取可以邀请好友的列表
// @param completion 回调
// */
//- (void)fetchInviteList:(NSDictionary *)params handle:(IPKHandleBridge)handle;

@end

NS_ASSUME_NONNULL_END
