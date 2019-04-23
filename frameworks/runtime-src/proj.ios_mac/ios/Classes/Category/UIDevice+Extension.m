//
//  UIDevice+PKExtension.m
//  
//
//  Created by loyalwind on 2018/5/8.
//

#import "UIDevice+Extension.h"
#import <sys/utsname.h>

NSString * const iPhone1_1 = @"iPhone1,1";
NSString * const iPhone1_2 = @"iPhone1,2";
NSString * const iPhone2_1 = @"iPhone2,1";
NSString * const iPhone3_1 = @"iPhone3,1";
NSString * const iPhone3_2 = @"iPhone3,2";
NSString * const iPhone3_3 = @"iPhone3,3";
NSString * const iPhone4_1 = @"iPhone4,1";
NSString * const iPhone5_1 = @"iPhone5,1";
NSString * const iPhone5_2 = @"iPhone5,2";
NSString * const iPhone5_3 = @"iPhone5,3";
NSString * const iPhone5_4 = @"iPhone5,4";
NSString * const iPhone6_1 = @"iPhone6,1";
NSString * const iPhone6_2 = @"iPhone6,2";
NSString * const iPhone7_1 = @"iPhone7,1";
NSString * const iPhone7_2 = @"iPhone7,2";
NSString * const iPhone8_1 = @"iPhone8,1";
NSString * const iPhone8_2 = @"iPhone8,2";
NSString * const iPhone8_4 = @"iPhone8,4";
NSString * const iPhone9_1 = @"iPhone9,1";
NSString * const iPhone9_2 = @"iPhone9,2";
NSString * const iPhone9_3 = @"iPhone9,3";
NSString * const iPhone9_4 = @"iPhone9,4";
NSString * const iPhone10_1 = @"iPhone10,1";
NSString * const iPhone10_2 = @"iPhone10,2";
NSString * const iPhone10_3 = @"iPhone10,3";
NSString * const iPhone10_4 = @"iPhone10,4";
NSString * const iPhone10_5 = @"iPhone10,5";
NSString * const iPhone10_6 = @"iPhone10,6";
NSString * const iPhone11_2 = @"iPhone11,2";
NSString * const iPhone11_4 = @"iPhone11,4";
NSString * const iPhone11_6 = @"iPhone11,6";
NSString * const iPhone11_8 = @"iPhone11,8";

NSString * const iPod1_1 = @"iPod1,1";
NSString * const iPod2_1 = @"iPod2,1";
NSString * const iPod3_1 = @"iPod3,1";
NSString * const iPod4_1 = @"iPod4,1";
NSString * const iPod5_1 = @"iPod5,1";
NSString * const iPod7_1 = @"iPod7,1";

NSString * const iPad1_1 = @"iPad1,1";
NSString * const iPad1_2 = @"iPad1,2";
NSString * const iPad2_1 = @"iPad2,1";
NSString * const iPad2_2 = @"iPad2,2";
NSString * const iPad2_3 = @"iPad2,3";
NSString * const iPad2_4 = @"iPad2,4";
NSString * const iPad2_5 = @"iPad2,5";
NSString * const iPad2_6 = @"iPad2,6";
NSString * const iPad2_7 = @"iPad2,7";
NSString * const iPad3_1 = @"iPad3,1";
NSString * const iPad3_2 = @"iPad3,2";
NSString * const iPad3_3 = @"iPad3,3";
NSString * const iPad3_4 = @"iPad3,4";
NSString * const iPad3_5 = @"iPad3,5";
NSString * const iPad3_6 = @"iPad3,6";
NSString * const iPad4_1 = @"iPad4,1";
NSString * const iPad4_2 = @"iPad4,2";
NSString * const iPad4_3 = @"iPad4,3";
NSString * const iPad4_4 = @"iPad4,4";
NSString * const iPad4_5 = @"iPad4,5";
NSString * const iPad4_6 = @"iPad4,6";
NSString * const iPad4_7 = @"iPad4,7";
NSString * const iPad4_8 = @"iPad4,8";
NSString * const iPad4_9 = @"iPad4,9";
NSString * const iPad5_1 = @"iPad5,1";
NSString * const iPad5_2 = @"iPad5,2";
NSString * const iPad5_3 = @"iPad5,3";
NSString * const iPad5_4 = @"iPad5,4";
NSString * const iPad6_3 = @"iPad6,3";
NSString * const iPad6_4 = @"iPad6,4";
NSString * const iPad6_7 = @"iPad6,7";
NSString * const iPad6_8 = @"iPad6,8";
NSString * const iPad6_11 = @"iPad6,11";
NSString * const iPad6_12 = @"iPad6,12";

NSString * const iPad7_1 = @"iPad7,1";
NSString * const iPad7_2 = @"iPad7,2";
NSString * const iPad7_3 = @"iPad7,3";
NSString * const iPad7_4 = @"iPad7,4";

NSString * const AppleTV1_1 = @"AppleTV1,1";
NSString * const AppleTV2_1 = @"AppleTV2,1";
NSString * const AppleTV3_1 = @"AppleTV3,1";
NSString * const AppleTV3_2 = @"AppleTV3,2";
NSString * const AppleTV5_3 = @"AppleTV5,3";

NSString * const Watch1_1 = @"Watch1,1";
NSString * const Watch1_2 = @"Watch1,2";
NSString * const Watch2_3 = @"Watch2,3";
NSString * const Watch2_4 = @"Watch2,4";
NSString * const Watch2_6 = @"Watch2,6";
NSString * const Watch2_7 = @"Watch2,7";

NSString * const i386_Sim    = @"i386";
NSString * const x86_64_Sim  = @"x86_64";

static NSDictionary * __deviceMap = nil;

@implementation UIDevice (Extension)

+ (void)initialize
{
    __deviceMap = @{
                    iPhone1_1 : @"iPhone 2G",
                    iPhone1_2 : @"iPhone 3G",
                    iPhone2_1 : @"iPhone 3GS",
                    
                    iPhone3_1 : @"iPhone 4",
                    iPhone3_2 : @"iPhone 4",
                    iPhone3_3 : @"iPhone 4 CDMA",
                    iPhone4_1 : @"iPhone 4s",
                    
                    iPhone5_1 : @"iPhone 5",
                    iPhone5_2 : @"iPhone 5 CDMA_GSM",
                    iPhone5_3 : @"iPhone 5c",
                    iPhone5_4 : @"iPhone 5c CDMA_GSM",
                    iPhone6_1 : @"iPhone 5s",
                    iPhone6_2 : @"iPhone 5s CDMA_GSM",
                    
                    iPhone7_1 : @"iPhone 6 Plus",
                    iPhone7_2 : @"iPhone 6",
                    iPhone8_1 : @"iPhone 6s",
                    iPhone8_2 : @"iPhone 6s Plus",
                    iPhone8_4 : @"iPhone SE",
                    iPhone9_1 : @"iPhone 7",
                    iPhone9_3 : @"iPhone 7 GSM",
                    iPhone9_2 : @"iPhone 7 Plus",
                    iPhone9_4 : @"iPhone 7 Plus_GSM",
                    
                    iPhone10_1 : @"iPhone 8 CN",
                    iPhone10_2 : @"iPhone 8 Plus_CN",
                    iPhone10_3 : @"iPhone X CN",
                    iPhone10_4 : @"iPhone 8",
                    iPhone10_5 : @"iPhone 8 Plus",
                    iPhone10_6 : @"iPhone X",
                    iPhone11_2 : @"iPhone Xs",       // (model A2097, A2098)
                    iPhone11_4 : @"iPhone Xs_Max",   // (model A1921, A2103)
                    iPhone11_6 : @"iPhone Xs_Max",   // (model A2104)
                    iPhone11_8 : @"iPhone Xr",       // (model A1882, A1719, A2105)
                    
                    iPod1_1 : @"iPod Touch 1G",
                    iPod2_1 : @"iPod Touch 2G",
                    iPod3_1 : @"iPod Touch 3G",
                    iPod4_1 : @"iPod Touch 4G",
                    iPod5_1 : @"iPod Touch 5G",
                    iPod7_1 : @"iPod Touch 6G",
                    
                    iPad1_1 : @"iPad",
                    iPad1_2 : @"iPad 3G",
                    iPad2_1 : @"iPad 2 WIFI",
                    iPad2_2 : @"iPad 2",
                    iPad2_3 : @"iPad 2 CDMA",
                    iPad2_4 : @"iPad 2",
                    iPad2_5 : @"iPad Mini WIFI",
                    iPad2_6 : @"iPad Mini",
                    iPad2_7 : @"iPad Mini WIFI_CDMA",
                    iPad3_1 : @"iPad 3 WIFI",
                    iPad3_2 : @"iPad 3 WIFI_CDMA",
                    iPad3_3 : @"iPad 3",
                    iPad3_4 : @"iPad 4 WIFI",
                    iPad3_5 : @"iPad 4",
                    iPad3_6 : @"iPad 4 GSM_CDMA",
                    iPad4_1 : @"iPad Air WIFI",
                    iPad4_2 : @"iPad Air WIFI_GSM",
                    iPad4_3 : @"iPad Air WIFI_CDMA",
                    iPad4_4 : @"iPad Mini RETINA_WIFI",
                    iPad4_5 : @"iPad Mini RETINA_WIFI_CDMA",
                    iPad4_6 : @"iPad Mini RETINA_WIFI_CELLULAR_CN",
                    iPad4_7 : @"iPad Mini 3 WIFI",
                    iPad4_8 : @"iPad Mini 3 WIFI_CELLULAR",
                    iPad4_9 : @"iPad Mini 3 WIFI_CELLULAR_CN",
                    iPad5_1 : @"iPad Mini 4 WIFI",
                    iPad5_2 : @"iPad Mini 4 WIFI_CELLULAR",
                    
                    iPad5_3 : @"iPad Air 2 WIFI",
                    iPad5_4 : @"iPad Air 2 WIFI_CELLULAR",
                    
                    iPad6_3 : @"iPad Pro 9.7 WIFI",
                    iPad6_4 : @"iPad Pro 9.7 WIFI_CELLULAR",
                    
                    iPad6_7 : @"iPad Pro WIFI",
                    iPad6_8 : @"iPad Pro WIFI_CELLULAR",
                    
                    iPad6_11 : @"iPad 5 WIFI",
                    iPad6_12 : @"iPad 5 WIFI_CELLULAR",
                    
                    iPad7_1 : @"iPad Pro 2G WIFI",
                    iPad7_2 : @"iPad Pro 2G WIFI_CELLULAR",
                    iPad7_3 : @"iPad Pro 10.5 WIFI",
                    iPad7_4 : @"iPad Pro 10.5 WIFI_CELLULAR",
                    
                    AppleTV1_1 : @"APPLE_TV_1G",
                    AppleTV2_1 : @"APPLE_TV_2G",
                    AppleTV3_1 : @"APPLE_TV_3G",
                    AppleTV3_2 : @"APPLE_TV_3_2G",
                    AppleTV5_3 : @"APPLE_TV_4G",
                    
                    Watch1_1 : @"APPLE_WATCH_38",
                    Watch1_2 : @"APPLE_WATCH_42",
                    Watch2_3 : @"APPLE_WATCH_SERIES_2_38",
                    Watch2_4 : @"APPLE_WATCH_SERIES_2_42",
                    Watch2_6 : @"APPLE_WATCH_SERIES_1_38",
                    Watch2_7 : @"APPLE_WATCH_SERIES_1_42",
                    
                    i386_Sim : @"iPhone Simulator",
                    x86_64_Sim : @"iPhone Simulator",
        };
}

/** 平台名字 */
+ (IPKDevicePlatformName)platformName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}


+ (BOOL)isFringeScreen
{
#if TARGET_IPHONE_SIMULATOR //模拟器
    CGSize size = [UIScreen mainScreen].bounds.size;
    BOOL result = CGSizeEqualToSize(CGSizeMake(375.f, 812.f),size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f),size) || // iPhone X, iPhone XS
                  CGSizeEqualToSize(CGSizeMake(414.f, 896.f),size) || CGSizeEqualToSize(CGSizeMake(896.f, 414.f),size);   // iPhone XR,iPhone XS MAX
    return result;
#else // 真机
    IPKDevicePlatformName hardware = [self platformName];
    BOOL result = [hardware isEqualToString:iPhone10_3] || [hardware isEqualToString:iPhone10_6] || // iPhone X
                  [hardware isEqualToString:iPhone11_4] || [hardware isEqualToString:iPhone11_6] || // iPhone XS MAX
                  [hardware isEqualToString:iPhone11_2] || [hardware isEqualToString:iPhone11_8];   // iPhone XS, iPhone XR
    return result;
#endif
}

+ (IPKDeviceType)deviceType
{
    IPKDevicePlatformName hardware = [self platformName];
    
    NSString *deviceInfo = __deviceMap[hardware];
    if (deviceInfo == nil) deviceInfo = @"NOT_AVAILABLE";
    NSLog(@"Your device hardware string is: %@", deviceInfo);
    
    if ([hardware isEqualToString:iPhone1_1])    return IPHONE_2G;
    if ([hardware isEqualToString:iPhone1_2])    return IPHONE_3G;
    if ([hardware isEqualToString:iPhone2_1])    return IPHONE_3GS;
    
    if ([hardware isEqualToString:iPhone3_1])    return IPHONE_4;
    if ([hardware isEqualToString:iPhone3_2])    return IPHONE_4;
    if ([hardware isEqualToString:iPhone3_3])    return IPHONE_4_CDMA;
    if ([hardware isEqualToString:iPhone4_1])    return IPHONE_4S;
    
    if ([hardware isEqualToString:iPhone5_1])    return IPHONE_5;
    if ([hardware isEqualToString:iPhone5_2])    return IPHONE_5_CDMA_GSM;
    if ([hardware isEqualToString:iPhone5_3])    return IPHONE_5C;
    if ([hardware isEqualToString:iPhone5_4])    return IPHONE_5C_CDMA_GSM;
    if ([hardware isEqualToString:iPhone6_1])    return IPHONE_5S;
    if ([hardware isEqualToString:iPhone6_2])    return IPHONE_5S_CDMA_GSM;
    
    if ([hardware isEqualToString:iPhone7_1])    return IPHONE_6_PLUS;
    if ([hardware isEqualToString:iPhone7_2])    return IPHONE_6;
    if ([hardware isEqualToString:iPhone8_1])    return IPHONE_6S;
    if ([hardware isEqualToString:iPhone8_2])    return IPHONE_6S_PLUS;
    if ([hardware isEqualToString:iPhone8_4])    return IPHONE_SE;
    if ([hardware isEqualToString:iPhone9_1])    return IPHONE_7;
    if ([hardware isEqualToString:iPhone9_3])    return IPHONE_7_GSM;
    if ([hardware isEqualToString:iPhone9_2])    return IPHONE_7_PLUS;
    if ([hardware isEqualToString:iPhone9_4])    return IPHONE_7_PLUS_GSM;
    
    if ([hardware isEqualToString:iPhone10_1])    return IPHONE_8_CN;
    if ([hardware isEqualToString:iPhone10_2])    return IPHONE_8_PLUS_CN;
    if ([hardware isEqualToString:iPhone10_3])    return IPHONE_X_CN;
    if ([hardware isEqualToString:iPhone10_4])    return IPHONE_8;
    if ([hardware isEqualToString:iPhone10_5])    return IPHONE_8_PLUS;
    if ([hardware isEqualToString:iPhone10_6])    return IPHONE_X;
    
    if ([hardware isEqualToString:iPhone11_2])    return IPHONE_XS;
    if ([hardware isEqualToString:iPhone11_4])    return IPHONE_XS_MAX;
    if ([hardware isEqualToString:iPhone11_6])    return IPHONE_XS_MAX;
    if ([hardware isEqualToString:iPhone11_8])    return IPHONE_XR;
    
    if ([hardware isEqualToString:iPod1_1])      return IPOD_TOUCH_1G;
    if ([hardware isEqualToString:iPod2_1])      return IPOD_TOUCH_2G;
    if ([hardware isEqualToString:iPod3_1])      return IPOD_TOUCH_3G;
    if ([hardware isEqualToString:iPod4_1])      return IPOD_TOUCH_4G;
    if ([hardware isEqualToString:iPod5_1])      return IPOD_TOUCH_5G;
    if ([hardware isEqualToString:iPod7_1])      return IPOD_TOUCH_6G;
    
    if ([hardware isEqualToString:iPad1_1])      return IPAD;
    if ([hardware isEqualToString:iPad1_2])      return IPAD_3G;
    if ([hardware isEqualToString:iPad2_1])      return IPAD_2_WIFI;
    if ([hardware isEqualToString:iPad2_2])      return IPAD_2;
    if ([hardware isEqualToString:iPad2_3])      return IPAD_2_CDMA;
    if ([hardware isEqualToString:iPad2_4])      return IPAD_2;
    if ([hardware isEqualToString:iPad2_5])      return IPAD_MINI_WIFI;
    if ([hardware isEqualToString:iPad2_6])      return IPAD_MINI;
    if ([hardware isEqualToString:iPad2_7])      return IPAD_MINI_WIFI_CDMA;
    if ([hardware isEqualToString:iPad3_1])      return IPAD_3_WIFI;
    if ([hardware isEqualToString:iPad3_2])      return IPAD_3_WIFI_CDMA;
    if ([hardware isEqualToString:iPad3_3])      return IPAD_3;
    if ([hardware isEqualToString:iPad3_4])      return IPAD_4_WIFI;
    if ([hardware isEqualToString:iPad3_5])      return IPAD_4;
    if ([hardware isEqualToString:iPad3_6])      return IPAD_4_GSM_CDMA;
    if ([hardware isEqualToString:iPad4_1])      return IPAD_AIR_WIFI;
    if ([hardware isEqualToString:iPad4_2])      return IPAD_AIR_WIFI_GSM;
    if ([hardware isEqualToString:iPad4_3])      return IPAD_AIR_WIFI_CDMA;
    if ([hardware isEqualToString:iPad4_4])      return IPAD_MINI_RETINA_WIFI;
    if ([hardware isEqualToString:iPad4_5])      return IPAD_MINI_RETINA_WIFI_CDMA;
    if ([hardware isEqualToString:iPad4_6])      return IPAD_MINI_RETINA_WIFI_CELLULAR_CN;
    if ([hardware isEqualToString:iPad4_7])      return IPAD_MINI_3_WIFI;
    if ([hardware isEqualToString:iPad4_8])      return IPAD_MINI_3_WIFI_CELLULAR;
    if ([hardware isEqualToString:iPad4_9])      return IPAD_MINI_3_WIFI_CELLULAR_CN;
    if ([hardware isEqualToString:iPad5_1])      return IPAD_MINI_4_WIFI;
    if ([hardware isEqualToString:iPad5_2])      return IPAD_MINI_4_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:iPad5_3])      return IPAD_AIR_2_WIFI;
    if ([hardware isEqualToString:iPad5_4])      return IPAD_AIR_2_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:iPad6_3])      return IPAD_PRO_97_WIFI;
    if ([hardware isEqualToString:iPad6_4])      return IPAD_PRO_97_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:iPad6_7])      return IPAD_PRO_WIFI;
    if ([hardware isEqualToString:iPad6_8])      return IPAD_PRO_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:iPad6_11])     return IPAD_5_WIFI;
    if ([hardware isEqualToString:iPad6_12])     return IPAD_5_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:iPad7_1])      return IPAD_PRO_2G_WIFI;
    if ([hardware isEqualToString:iPad7_2])      return IPAD_PRO_2G_WIFI_CELLULAR;
    if ([hardware isEqualToString:iPad7_3])      return IPAD_PRO_105_WIFI;
    if ([hardware isEqualToString:iPad7_4])      return IPAD_PRO_105_WIFI_CELLULAR;
    
    if ([hardware isEqualToString:AppleTV1_1])   return APPLE_TV_1G;
    if ([hardware isEqualToString:AppleTV2_1])   return APPLE_TV_2G;
    if ([hardware isEqualToString:AppleTV3_1])   return APPLE_TV_3G;
    if ([hardware isEqualToString:AppleTV3_2])   return APPLE_TV_3_2G;
    if ([hardware isEqualToString:AppleTV5_3])   return APPLE_TV_4G;
    
    if ([hardware isEqualToString:Watch1_1])     return APPLE_WATCH_38;
    if ([hardware isEqualToString:Watch1_2])     return APPLE_WATCH_42;
    if ([hardware isEqualToString:Watch2_3])     return APPLE_WATCH_SERIES_2_38;
    if ([hardware isEqualToString:Watch2_4])     return APPLE_WATCH_SERIES_2_42;
    if ([hardware isEqualToString:Watch2_6])     return APPLE_WATCH_SERIES_1_38;
    if ([hardware isEqualToString:Watch2_7])     return APPLE_WATCH_SERIES_1_42;
    
    if ([hardware isEqualToString:i386_Sim])     return SIMULATOR;
    if ([hardware isEqualToString:x86_64_Sim])   return SIMULATOR;
    
    return NOT_AVAILABLE;
}

+ (NSString *)deviceModel
{
    static NSString *name = nil;
    if (!name) {
        IPKDevicePlatformName hardware = [self platformName];
        name = __deviceMap[hardware];
        if (!name) name = hardware;
    }
    return name;
}
@end
