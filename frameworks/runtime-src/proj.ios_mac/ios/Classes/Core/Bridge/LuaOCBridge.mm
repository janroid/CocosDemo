

#import "LuaOCBridge.h"
#import "IPKBridgeCmd.h"
#import "IPKBridgeModel.h"
#import "IosLuaCallManager.h"

@interface LuaOCBridge ()

/**
 cmd-> BridgeModel 映射
 */
@property(nonatomic, strong) NSMutableDictionary <NSString *, IPKBridgeModel *> *cmdBridgeCache;

@property(nonatomic, strong) NSMutableDictionary *mCmdtoLua;
@end

@implementation LuaOCBridge

static LuaOCBridge* _instance = nil;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

#pragma mark - 懒加载
 - (NSMutableDictionary *)mCmdtoLua
{
    if (!_mCmdtoLua) {
       _mCmdtoLua = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _mCmdtoLua;
}
- (NSMutableDictionary *)cmdBridgeCache
{
    if (!_cmdBridgeCache) {
        _cmdBridgeCache = [NSMutableDictionary dictionary];
    }
    return _cmdBridgeCache;
}

- (void)dealloc
{

}

- (void)luaCallOc:(int)key data:(const char*)dataChar{
    NSError  *error  = nil;
    NSString *string = [NSString stringWithUTF8String:dataChar];
    NSData   *data   = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        IosLuaCallManager::getInstance()->systemCallLua(key, error.description.UTF8String);
        return;
    }
    
    NSMutableDictionary *bridgeDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    bridgeDict[@"key"] = @(key);
    IPKBridgeModel *bridgeModel = [IPKBridgeModel bridgeModelWithDict:bridgeDict];
//    if (!bridgeModel.isValid) return;
    
    @try {
        // 保存起来
        self.cmdBridgeCache[bridgeModel.nativeIosMethod] = bridgeModel;
        self.mCmdtoLua[bridgeModel.nativeIosMethod] = @(key);
        [bridgeModel callOCSelectorWithHandle:^(id  _Nullable resultData) {
            IosLuaCallManager::getInstance()->systemCallLua(key, [resultData toJSONString].UTF8String);
        }];
    } @catch (NSException *exception) {
#if DEBUG_MODE
        NSLog(@"出现异常%@",exception);
        [exception raise];
#endif
        IosLuaCallManager::getInstance()->systemCallLua(key, exception.description.UTF8String);
    }
}


- (void)ocCallLua:(NSString *)methodName data:(NSDictionary *)dict
{
//    NSError* error = nil;
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
//    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    const char* sendData = [jsonStr UTF8String];
    
    NSNumber* key = self.mCmdtoLua[methodName];
    if(key == nil) return;
    
    IosLuaCallManager::getInstance()->systemCallLua(key.intValue, dict.toJSONString.UTF8String);
}

@end
