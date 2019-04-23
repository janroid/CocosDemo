//
//  IPKDeviceTools.h
//  iPoker
//
//  Created by boyaa on 2019/2/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPKDeviceTools : NSObject
+ (NSString *)uuid;
/**
 获取电池信息, 包含key: @"Level", @"State"
 */
+ (NSDictionary *)getBatteryInfo;

/**
 获取设备信息
 */
+ (NSDictionary *)getDeviceInfo;

/**
 震动
 */
+ (void)vibrate;

/**
 获取磁盘空间，两个元素，
 @return 第一个元素是总空间，第二个是剩余空间
 */
+ (NSArray <NSNumber *> *)getDiskSpace;
/** 可以运行内存 */
+ (double)availableMemory;
+ (void)setBindedEmail:(BOOL)bindedEmail;
+ (BOOL)bindedEmail;
@end

NS_ASSUME_NONNULL_END
