//
//  IPKBridgeModel.h
//  iPoker
//
//  Created by loyalwind on 2018/12/18.
//  OC,Lua交互桥接模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPKBridgeModel : NSObject

/** 快速创建一个bridge */
+ (instancetype)bridgeModelWithDict:(NSDictionary *)dict;

/** 快速创建一个bridge */
- (instancetype)initWithDict:(NSDictionary *)dict;

/** 目标命令key */
@property(nonatomic, assign) int key;
/** 类/对象，方法映射 */
@property(nonatomic, copy, readonly) NSString *nativeIosMethod;
/** Lua->OC, OC->Lua 参数 */
@property(nonatomic, strong) id params;

/**
 nativeIosMethod 是否有效
 @return 
 */
- (BOOL)isValid;

/**
 调用OC的方法

 @param handle IPKHandleBridge 回调,同步异步均可
 */
- (void)callOCSelectorWithHandle:(IPKHandleBridge)handle;

@end

NS_ASSUME_NONNULL_END
