//
//  Singleton.h
//  ipoker_v1.0
//
//  Created by loyalwindPeng on 2017/8/10.
//  Copyright © 2017年 BOYAA. All rights reserved.
//  单例宏

#ifndef Singleton_h
#define Singleton_h

#define SingleInterface(name) +(instancetype)shared##name;
#if __has_feature(objc_arc)
// ARC下
#define SingleImplementation(name) +(instancetype)shared##name\
{\
    return [[self alloc] init];\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static id __instance;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        __instance = [super allocWithZone:zone];\
    });\
    return __instance;\
}\
-(id)copyWithZone:(NSZone *)zone\
{\
    return self;\
}\
-(id)mutableCopyWithZone:(NSZone *)zone\
{\
    return self;\
}

#else
// MRC下
#define SingleImplementation(name) +(instancetype)shared##name\
{\
    return [[self alloc] init];\
}\
+ (instancetype)allocWithZone:(struct _NSZone *)zone\
{\
    static id __instance;\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        __instance = [super allocWithZone:zone];\
    });\
    return __instance;\
}\
- (id)copyWithZone:(NSZone *)zone\
{\
    return self;\
}\
- (id)mutableCopyWithZone:(NSZone *)zone\
{\
    return self;\
}\
- (oneway void)release\
{}\
- (instancetype)retain\
{\
    return self;\
}\
- (NSUInteger)retainCount\
{\
    return MAXFLOAT;\
}\
+ (id)copyWithZone:(struct _NSZone *)zone\
{\
    return [self shared##name];\
}\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone\
{\
    return [self shared##name];\
}
#endif
/**
- (instancetype)init
{
    static BOOL hasInited = NO;
    if (hasInited) return self;
    if (self = [super init]){
        hasInited = YES;
        请自己去重写init方法,在该地方初始化一次性的东西
        coding..
    }
    return self;
}*/
#endif /* Singleton_h */
