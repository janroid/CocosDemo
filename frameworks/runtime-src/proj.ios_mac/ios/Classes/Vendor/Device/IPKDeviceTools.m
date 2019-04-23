//
//  IPKDeviceTools.m
//  iPoker
//
//  Created by boyaa on 2019/2/27.
//

#import "IPKDeviceTools.h"
#import "FrogOpenUDID.h"
#import "CHKeychain.h"
#import "AFNetworkReachabilityManager.h"
#import <sys/utsname.h>
//#import <sys/sysctl.h>
#import <mach/mach.h>
#import <dlfcn.h>
#import <AVFoundation/AVFoundation.h>
#import "UIDevice+Extension.h"

#define UUIDKEY @"UUIDKEY"
#define EMAILBINDKEY @"EMAILBINDKEY"

@implementation IPKDeviceTools
#pragma mark - 获取设备基本信息
+ (NSDictionary *)getDeviceInfo
{
    UIDevice *device                = [UIDevice currentDevice];
    NSArray <NSNumber *> *diskSpace = [self getDiskSpace];
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    
    NSMutableDictionary *deviceInfo = [NSMutableDictionary dictionary];
    
    deviceInfo[@"uuid"]           = [self uuid];
    deviceInfo[@"deviceId"]       = [UIDevice currentDevice].identifierForVendor.UUIDString;//device.name;//设备名称
    
    deviceInfo[@"versionName"]    = [[NSBundle mainBundle] objectForInfoDictionaryKey :@"CFBundleShortVersionString"];
    deviceInfo[@"machineId"]      = device.model;
    deviceInfo[@"releaseVersion"] = device.systemVersion;
    deviceInfo[@"networkType"]    = @(status).stringValue;
    deviceInfo[@"phoneModel"]     = [self getMechineType];
    deviceInfo[@"totalMemory"]    = diskSpace.firstObject.stringValue;
    deviceInfo[@"freeMemory"]     = diskSpace.lastObject.stringValue;
    NSLog(@"getDeviceInfo %@",deviceInfo);
    return deviceInfo;
}

+ (NSString *)getMechineType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *mechineStr = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([mechineStr hasPrefix:@"iPhone"]) {
        return @"iPhone";
    }
    else if([mechineStr hasPrefix:@"iPad"]){
        return @"iPad";
    }
    else if([mechineStr hasPrefix:@"iPod"]){
        return @"iPod";
    }
    return @"iPhone";
}

#pragma mark - 获取设备UUID
+ (NSString *)uuid
{
    NSString *openUDID = [CHKeychain load:UUIDKEY];
    if (openUDID) {
        NSLog(@"----CHKeychain, openUDID = %@", openUDID);
    } else {
        openUDID = [FrogOpenUDID value];
        [CHKeychain save:UUIDKEY data:openUDID];
        NSLog(@"----FrogOpenUDID, openUDID = %@", openUDID);
    }
    return openUDID;
}
#pragma mark - 获取电池信息
+ (NSDictionary *)getBatteryInfo
{
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    return @{@"Level": @(device.batteryLevel * 100), @"State":@(device.batteryState)};
}

+ (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - 内存信息相关
+ (NSArray <NSNumber *> *)getDiskSpace
{
    double totalSpace = 0.0f;
    double totalFreeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:paths.lastObject error: &error];
    if (attributes) {
        NSNumber *fileSystemSizeInBytes = [attributes objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [attributes objectForKey:NSFileSystemFreeSize];
        totalSpace = fileSystemSizeInBytes.unsignedLongLongValue/(1024.0f*1024.0f*1024.0f);
        totalFreeSpace = freeFileSystemSizeInBytes.unsignedLongLongValue/(1024.0f*1024.0f*1024.0f);
        NSLog(@"Memory Capacity of %f GB with %f GB Free memory available.", totalSpace, totalFreeSpace);
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return @[@(totalSpace), @(totalFreeSpace)];
}

+ (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

+ (void)setBindedEmail:(BOOL)bindedEmail
{
    [CHKeychain save:EMAILBINDKEY data:@(bindedEmail)];
}

+ (BOOL)bindedEmail
{
    return [[CHKeychain load:EMAILBINDKEY] boolValue];
}
@end
