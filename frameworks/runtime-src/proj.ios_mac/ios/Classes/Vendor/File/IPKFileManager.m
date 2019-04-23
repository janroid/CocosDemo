//
//  IPKFileManager.m
//  iPoker
//
//  Created by boyaa on 2018/12/19.
//

#import "IPKFileManager.h"

#define kSaveDirectory  [NSBundle mainBundle].bundleIdentifier
#define IPKFileMgr [NSFileManager defaultManager]

@implementation IPKFileManager
+ (NSString *)documentDirectory
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)cacheDirectory
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

+ (NSString *)tmpDirectory
{
    return  NSTemporaryDirectory();
}

+ (BOOL)deleteFile:(NSString *)filePath
{
    return [IPKFileMgr removeItemAtPath:filePath error:nil];
}

+ (BOOL)deleteAllFile
{
    return [IPKFileMgr removeItemAtPath:[self saveDirectory] error:nil];
}

+ (NSString *)saveDirectory
{
    NSString *bPath = [NSString stringWithFormat:@"%@/%@/saveAll",[self cacheDirectory], kSaveDirectory];
    BOOL isDirectory = NO;
    [IPKFileMgr fileExistsAtPath:bPath isDirectory:&isDirectory];
    if (!isDirectory) {
        [IPKFileMgr createDirectoryAtPath:bPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return bPath;
}
@end
