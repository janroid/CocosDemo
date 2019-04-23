//
//  IPKBridgeModel.m
//  iPoker
//
//  Created by boyaa on 2018/12/18.
//

#import "IPKBridgeModel.h"

/**
 Lua 调用 OC 的方法类型

 - IPKBridgeMethodTypeObject: 对象方法
 - IPKBridgeMethodTypeClass: 类方法
 - IPKBridgeMethodTypeInvalid: 无效的方法
 */
typedef NS_ENUM(short int, IPKBridgeMethodType) {
    IPKBridgeMethodTypeObject  = 1,
    IPKBridgeMethodTypeClass   = 2,
    IPKBridgeMethodTypeInvalid = 3,
};

@interface IPKBridgeModel ()
/** 目标类 */
@property(nonatomic, assign, readonly) Class targetClass;
/** 目标类的实例对象 */
@property(nonatomic, strong) id target;
/** 目标方法 */
@property(nonatomic, assign, readonly) SEL action;
/** 初始化是传递的参数 */
@property(nonatomic, strong) NSDictionary *dict;
/** 方法类型 */
@property(nonatomic, assign) IPKBridgeMethodType methodType;
@end

@implementation IPKBridgeModel

+ (instancetype)bridgeModelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        _dict   = dict.copy;
        _key    = [dict[@"key"] intValue];
        _params = [dict[@"_params"] copy];
        _nativeIosMethod = dict[@"_nativeIosMethod"];
        [self _parseTargetAction];
    }
    
    return self;
}

- (void)callOCSelectorWithHandle:(IPKHandleBridge)handle
{
    weakSelf(self);
    [self _safeCallOCSelectorWithHandle:^(id  _Nullable resultData) {
        // 情况对象的引用
        weakSelf.target = nil;
        // 注意：一定要添加这行代码，不然会导致OC没有回调到Lua
        handle ? handle(resultData) : nil;
    }];
}

- (BOOL)isValid
{
    BOOL valid = NO;
    if (_methodType == IPKBridgeMethodTypeObject) {
        valid = [_targetClass instancesRespondToSelector:_action];
        if (!valid){
            NSLog(@"未找到方法：-[%@ %@]",NSStringFromClass(_targetClass), NSStringFromSelector(_action));
        }
    }else if (_methodType == IPKBridgeMethodTypeClass) {
        valid = [_targetClass respondsToSelector:_action];
        if (!valid) {
            NSLog(@"未找到方法：+[%@ %@]",NSStringFromClass(_targetClass), NSStringFromSelector(_action));
        }
    }else{
        valid = NO;
        NSLog(@"这个 nativeIosMethod 格式不正确，请检查：%@", _nativeIosMethod);
    }
    return valid;
}


#pragma mark - private method
- (void)_safeCallOCSelectorWithHandle:(IPKHandleBridge)handle
{
    if (!self.isValid) return;
    // 到时再增加方法参数类型判断
//    NSMethodSignature *signature = [_target methodSignatureForSelector:_action];
//    // -2，去除默认参数self,_cmd
//    NSUInteger extra = signature.numberOfArguments - 2;
// 取消编译器提示-Wdeprecated-declarations类型的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSLog(@"Lua call OC方法 %@",_nativeIosMethod);
    if (_methodType == IPKBridgeMethodTypeObject) {
        _target = [[_targetClass alloc] init];
        [_target performSelector:_action withObject:_params withObject:handle];
    }else if(_methodType == IPKBridgeMethodTypeClass){
        [_targetClass performSelector:_action withObject:_params withObject:handle];
    }
    
#pragma clang diagnostic pop
}

- (void)_parseTargetAction
{
    if ([_nativeIosMethod rangeOfString:@"."].location == NSNotFound) {
        self.methodType = IPKBridgeMethodTypeInvalid;
        return;
    }
    // 去除空格
    NSString *nativeString = [_nativeIosMethod stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 方法反射
    NSArray <NSString *> *callPaths = [nativeString componentsSeparatedByString:@"."];
    
    // 断言保护
//    NSAssert(callPaths.count == 2, @"这个 nativeIosMethod 格式不正确，请检查：%@", _nativeIosMethod);
    
    NSString *targetString = callPaths.firstObject;
    NSString *actionString = callPaths.lastObject;
    
    // '+'开头表示类方法，其他默认是对象方法
    if ([targetString hasPrefix:@"+"]) {
        self.methodType = IPKBridgeMethodTypeClass;
        targetString = [targetString stringByReplacingOccurrencesOfString:@"+" withString:@""];
    }else if ([targetString hasPrefix:@"-"]) {
        self.methodType = IPKBridgeMethodTypeObject;
        targetString = [targetString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }else{
        self.methodType = IPKBridgeMethodTypeObject;
    }
    _targetClass = NSClassFromString(targetString);
    _action = NSSelectorFromString(actionString);
}
@end
