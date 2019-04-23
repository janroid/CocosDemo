//
//  IPKFileManager.h
//  iPoker
//
//  Created by boyaa on 2018/12/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IPKFileManager : NSObject
+ (NSString *)documentDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)tmpDirectory;

+ (NSString *)saveDirectory;
+ (BOOL)deleteFile:(NSString *)filePath;
+ (BOOL)deleteAllFile;
@end

NS_ASSUME_NONNULL_END
