//
//  AppController+Extension.h
//  iPoker
//
//  Created by loyalwind on 2019/2/28.
//
// 把一些其他的功能加载放到改分类中，分离代码

#import "AppController.h"
#import "AFNetworkReachabilityManager.h"

typedef NS_ENUM(NSInteger, IPKReachabilityStatus) {
    IPKReachabilityStatusUnknown          = AFNetworkReachabilityStatusUnknown,
    IPKReachabilityStatusNotReachable     = AFNetworkReachabilityStatusNotReachable,
    IPKReachabilityStatusReachableViaWWAN = AFNetworkReachabilityStatusReachableViaWWAN,
    IPKReachabilityStatusReachableViaWiFi = AFNetworkReachabilityStatusReachableViaWiFi,
};

@interface AppController (Extension)
/**
 注册屏幕旋转变化监听

 @param handle 回调
 */
- (void)registeInterfaceOrientationChanged:(void(^)(CGRect frame))handle;

/**
 注册网络状态变化监听
 
 @param handle 回调
 */
- (void)registeReachabilityStatusChanged:(void(^)(IPKReachabilityStatus status))handle;
@end
