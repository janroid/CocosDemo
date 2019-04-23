//
//  UIDevice+Extension.h
//  
//
//  Created by loyalwind on 2018/5/8.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IPKDeviceType) {
    NOT_AVAILABLE,
    
    IPHONE_2G,
    IPHONE_3G,
    IPHONE_3GS,
    
    IPHONE_4,
    IPHONE_4_CDMA,
    IPHONE_4S,
    
    IPHONE_5,
    IPHONE_5_CDMA_GSM,
    IPHONE_5C,
    IPHONE_5C_CDMA_GSM,
    IPHONE_5S,
    IPHONE_5S_CDMA_GSM,
    
    IPHONE_6,
    IPHONE_6_PLUS,
    IPHONE_6S,
    IPHONE_6S_PLUS,
    IPHONE_SE,
    
    IPHONE_7,
    IPHONE_7_GSM,
    IPHONE_7_PLUS,
    IPHONE_7_PLUS_GSM,
    
    IPHONE_8,
    IPHONE_8_CN,
    IPHONE_8_PLUS,
    IPHONE_8_PLUS_CN,
    
    IPHONE_X,
    IPHONE_X_CN,
    IPHONE_XR,
    IPHONE_XS,
    IPHONE_XS_MAX,
    
    IPOD_TOUCH_1G,
    IPOD_TOUCH_2G,
    IPOD_TOUCH_3G,
    IPOD_TOUCH_4G,
    IPOD_TOUCH_5G,
    IPOD_TOUCH_6G,
    
    IPAD,
    IPAD_2,
    IPAD_2_WIFI,
    IPAD_2_CDMA,
    IPAD_3,
    IPAD_3G,
    IPAD_3_WIFI,
    IPAD_3_WIFI_CDMA,
    IPAD_4,
    IPAD_4_WIFI,
    IPAD_4_GSM_CDMA,
    
    IPAD_MINI,
    IPAD_MINI_WIFI,
    IPAD_MINI_WIFI_CDMA,
    IPAD_MINI_RETINA_WIFI,
    IPAD_MINI_RETINA_WIFI_CDMA,
    IPAD_MINI_3_WIFI,
    IPAD_MINI_3_WIFI_CELLULAR,
    IPAD_MINI_3_WIFI_CELLULAR_CN,
    IPAD_MINI_4_WIFI,
    IPAD_MINI_4_WIFI_CELLULAR,
    
    IPAD_MINI_RETINA_WIFI_CELLULAR_CN,
    
    IPAD_AIR_WIFI,
    IPAD_AIR_WIFI_GSM,
    IPAD_AIR_WIFI_CDMA,
    IPAD_AIR_2_WIFI,
    IPAD_AIR_2_WIFI_CELLULAR,
    
    IPAD_PRO_97_WIFI,
    IPAD_PRO_97_WIFI_CELLULAR,
    
    IPAD_PRO_WIFI,
    IPAD_PRO_WIFI_CELLULAR,
    
    IPAD_PRO_2G_WIFI,
    IPAD_PRO_2G_WIFI_CELLULAR,
    IPAD_PRO_105_WIFI,
    IPAD_PRO_105_WIFI_CELLULAR,
    
    IPAD_5_WIFI,
    IPAD_5_WIFI_CELLULAR,
    
    APPLE_TV_1G,
    APPLE_TV_2G,
    APPLE_TV_3G,
    APPLE_TV_3_2G,
    APPLE_TV_4G,
    
    APPLE_WATCH_38,
    APPLE_WATCH_42,
    APPLE_WATCH_SERIES_2_38,
    APPLE_WATCH_SERIES_2_42,
    APPLE_WATCH_SERIES_1_38,
    APPLE_WATCH_SERIES_1_42,
    
    SIMULATOR,
    
    HARDWARE_MAX
};

typedef NSString * IPKDevicePlatformName;
/**
 * 设备的硬件字符串
 */

UIKIT_EXTERN IPKDevicePlatformName const iPhone1_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone1_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone2_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone3_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone3_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone3_3;
UIKIT_EXTERN IPKDevicePlatformName const iPhone4_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone5_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone5_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone5_3;
UIKIT_EXTERN IPKDevicePlatformName const iPhone5_4;
UIKIT_EXTERN IPKDevicePlatformName const iPhone6_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone6_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone7_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone7_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone8_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone8_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone8_4;
UIKIT_EXTERN IPKDevicePlatformName const iPhone9_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone9_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone9_3;
UIKIT_EXTERN IPKDevicePlatformName const iPhone9_4;
UIKIT_EXTERN IPKDevicePlatformName const iPhone10_1;
UIKIT_EXTERN IPKDevicePlatformName const iPhone10_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone10_3;
UIKIT_EXTERN IPKDevicePlatformName const iPhone10_4;
UIKIT_EXTERN IPKDevicePlatformName const iPhone10_5;
UIKIT_EXTERN IPKDevicePlatformName const iPhone10_6;
UIKIT_EXTERN IPKDevicePlatformName const iPhone11_2;
UIKIT_EXTERN IPKDevicePlatformName const iPhone11_4;
UIKIT_EXTERN IPKDevicePlatformName const iPhone11_6;
UIKIT_EXTERN IPKDevicePlatformName const iPhone11_8;

UIKIT_EXTERN IPKDevicePlatformName const iPod1_1;
UIKIT_EXTERN IPKDevicePlatformName const iPod2_1;
UIKIT_EXTERN IPKDevicePlatformName const iPod3_1;
UIKIT_EXTERN IPKDevicePlatformName const iPod4_1;
UIKIT_EXTERN IPKDevicePlatformName const iPod5_1;
UIKIT_EXTERN IPKDevicePlatformName const iPod7_1;

UIKIT_EXTERN IPKDevicePlatformName const iPad1_1;
UIKIT_EXTERN IPKDevicePlatformName const iPad1_2;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_1;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_2;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_3;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_4;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_5;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_6;
UIKIT_EXTERN IPKDevicePlatformName const iPad2_7;
UIKIT_EXTERN IPKDevicePlatformName const iPad3_1;
UIKIT_EXTERN IPKDevicePlatformName const iPad3_2;
UIKIT_EXTERN IPKDevicePlatformName const iPad3_3;
UIKIT_EXTERN IPKDevicePlatformName const iPad3_4;
UIKIT_EXTERN IPKDevicePlatformName const iPad3_5;
UIKIT_EXTERN IPKDevicePlatformName const iPad3_6;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_1;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_2;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_3;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_4;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_5;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_6;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_7;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_8;
UIKIT_EXTERN IPKDevicePlatformName const iPad4_9;
UIKIT_EXTERN IPKDevicePlatformName const iPad5_1;
UIKIT_EXTERN IPKDevicePlatformName const iPad5_2;
UIKIT_EXTERN IPKDevicePlatformName const iPad5_3;
UIKIT_EXTERN IPKDevicePlatformName const iPad5_4;
UIKIT_EXTERN IPKDevicePlatformName const iPad6_3;
UIKIT_EXTERN IPKDevicePlatformName const iPad6_4;
UIKIT_EXTERN IPKDevicePlatformName const iPad6_7;
UIKIT_EXTERN IPKDevicePlatformName const iPad6_8;
UIKIT_EXTERN IPKDevicePlatformName const iPad7_1;
UIKIT_EXTERN IPKDevicePlatformName const iPad7_2;
UIKIT_EXTERN IPKDevicePlatformName const iPad7_3;
UIKIT_EXTERN IPKDevicePlatformName const iPad7_4;
UIKIT_EXTERN IPKDevicePlatformName const iPad6_11;
UIKIT_EXTERN IPKDevicePlatformName const iPad6_12;
UIKIT_EXTERN IPKDevicePlatformName const AppleTV1_1;
UIKIT_EXTERN IPKDevicePlatformName const AppleTV2_1;
UIKIT_EXTERN IPKDevicePlatformName const AppleTV3_1;
UIKIT_EXTERN IPKDevicePlatformName const AppleTV3_2;
UIKIT_EXTERN IPKDevicePlatformName const AppleTV5_3;
UIKIT_EXTERN IPKDevicePlatformName const Watch1_1;
UIKIT_EXTERN IPKDevicePlatformName const Watch1_2;
UIKIT_EXTERN IPKDevicePlatformName const Watch2_3;
UIKIT_EXTERN IPKDevicePlatformName const Watch2_4;
UIKIT_EXTERN IPKDevicePlatformName const Watch2_6;
UIKIT_EXTERN IPKDevicePlatformName const Watch2_7;
UIKIT_EXTERN IPKDevicePlatformName const i386_Sim;
UIKIT_EXTERN IPKDevicePlatformName const x86_64_Sim;

@interface UIDevice (Extension)
/** 平台名字 */
+ (IPKDevicePlatformName)platformName;
/** 是否为刘海屏 */
+ (BOOL)isFringeScreen;
/** 返回设备类型 */
+ (IPKDeviceType)deviceType;
/** 设备名
 
 *  例如：iPhone 6, iPad Pro, iPad Mini, iPod touch
 */
+ (NSString *)deviceModel;
@end
