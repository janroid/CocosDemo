//
//  NSObject+Extension.m
//  iPoker
//
//  Created by boyaa on 2018/12/18.
//
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)
#pragma mark - 转换为JSON

- (id)toJSONObject
{
    return [self toJSONObjectWithError:nil];
}
- (id)toJSONObjectWithError:(NSError *__autoreleasing *)error
{
    if ([self isKindOfClass:[NSString class]]) {
        NSData *data = [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    } else if ([self isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:error];
    }
    return self;
}

- (NSData *)toJSONData
{
    return [self toJSONDataWithError:nil];
}

- (NSData *)toJSONDataWithError:(NSError *__autoreleasing *)error
{
    if ([self isKindOfClass:[NSString class]]) {
        return [((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([self isKindOfClass:[NSData class]]) {
        return (NSData *)self;
    }
    
    return [NSJSONSerialization dataWithJSONObject:self.toJSONObject options:kNilOptions error:error];
}

- (NSString *)toJSONString
{
    return [self toJSONStringWithError:nil];
}

- (NSString *)toJSONStringWithError:(NSError *__autoreleasing *)error
{
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)self encoding:NSUTF8StringEncoding];
    }else if ([self isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)self stringValue];
    }
    NSData *data = [self toJSONDataWithError:error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
