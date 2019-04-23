
#import <Foundation/Foundation.h>

@interface LuaOCBridge : NSObject

+ (instancetype) shareInstance;

/**
 Lua -> cpp -> OC
 
 @param key key
 @param dataChar 传递的参数
 */
- (void)luaCallOc:(int)key data:(const char *)dataChar;

/**
 OC -> cpp -> Lua
 
 @param methodName 方法名
 @param dict 传递的参数 NSDictionary
 */
- (void)ocCallLua:(NSString *)methodName data:(NSDictionary *)dict;

@end

