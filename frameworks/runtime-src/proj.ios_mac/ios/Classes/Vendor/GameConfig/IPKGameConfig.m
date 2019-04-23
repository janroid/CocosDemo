//
//  IPKGameConfig.m
//  iPoker
//
//  Created by loyalwind on 2018/12/19.
//

#import "IPKGameConfig.h"
#import "IPKDeviceTools.h"
#import "UIDevice+Extension.h"

@implementation IPKGameConfig
+ (void)gameInitConfig:(NSDictionary *)dict handle:(IPKHandleBridge)handle
{
    [[[IPKGameConfig alloc] init] gameInitConfig:dict handle:handle];
}

- (void)gameInitConfig:(NSDictionary *)dict handle:(IPKHandleBridge)handle
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
#if DEBUG_MODE
    param[@"IS_DEMO"]      = @(YES);
    param[@"IS_DEBUG"]     = @(YES);
#else
    param[@"IS_DEMO"]      = @(NO);
    param[@"IS_DEBUG"]     = @(NO);
#endif

    param[@"LANGUAGE"]     = @(IPKAreaFB_VN);//infoDic[@"LANGUAGE"];
    param[@"VERSION_CODE"] = infoDic[@"VERSION_CODE"];//lua版本
    param[@"VERSION_NAME"] = infoDic[@"CFBundleShortVersionString"];
    param[@"LOGIN_VER"]    = infoDic[@"LOGIN_VER"];
    param[@"DEVICE_NAME"]  = [UIDevice currentDevice].name;
    param[@"OS_VERSION"]   = [UIDevice currentDevice].systemVersion;

    param[@"OPEN_UUID"]   = [IPKDeviceTools uuid];
    param[@"IS_BIND_EMAIL"] = @([IPKDeviceTools bindedEmail]).stringValue;
    param[@"DEVICE_ID"]   = [UIDevice currentDevice].identifierForVendor.UUIDString; // 以后改成idfa
    param[@"DEVICE_MODEL"] = [UIDevice deviceModel];
    NSArray <NSNumber *> *diskSpace = [IPKDeviceTools getDiskSpace];
    param[@"TOTAL_MEMORY"] = diskSpace.firstObject.stringValue;
    param[@"FREE_MEMORY"]  = diskSpace.lastObject.stringValue;
    // 回调
    handle ? handle(param) : nil;
}

+ (void)guestBindedEmail:(NSDictionary *)dict
{
    [[[IPKGameConfig alloc] init] guestBindedEmail:dict];
}
- (void)guestBindedEmail:(NSDictionary *)dict
{
    BOOL bindedEmail = [dict[@"bindedEmail"] boolValue];
    [IPKDeviceTools setBindedEmail:bindedEmail];
}
@end
