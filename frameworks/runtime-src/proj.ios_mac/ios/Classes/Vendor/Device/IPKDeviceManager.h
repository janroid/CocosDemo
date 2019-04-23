//
//  IPKDeviceManager.h
//  iPoker
//
//  Created by loyalwind on 2018/12/19.
//  处理硬件相关的操作，相机，语言，权限等等

#import <Foundation/Foundation.h>
#import "Singleton.h"

NS_ASSUME_NONNULL_BEGIN

@interface IPKDeviceManager : NSObject
SingleInterface(Manager)

/**
 选择图片
 
 @param param 参数
 @param handle 回调处理
 */
+ (void)pickImage:(NSDictionary *)param handle:(IPKHandleBridge)handle;

/**
 上传反馈图片
 
 @param param 参数
 @param handle 回调处理
 */
+ (void)uploadFeedImage:(NSDictionary *)param handle:(IPKHandleBridge)handle;
@end

NS_ASSUME_NONNULL_END
