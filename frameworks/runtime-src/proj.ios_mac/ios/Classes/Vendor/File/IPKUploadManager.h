//
//  IPKUploadManager.h
//  iPoker
//
//  Created by boyaa on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

NS_ASSUME_NONNULL_BEGIN

@interface IPKUploadManager : NSObject

SingleInterface(Manager)

/**
 文件上传 该方法现在还有问题，不要使用

 @param param 上传参数，url, file(文件路径 或者 直接是NSData对象)
 @param handle 回调结果
 */
+ (void)upload:(NSDictionary *)param handle:(IPKHandleBridge)handle;
+ (void)umError:(NSDictionary *)param;
@end

NS_ASSUME_NONNULL_END
