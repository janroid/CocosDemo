//
//  IPKImagePicker.h
//  iPoker
//
//  Created by loyalwind on 2018/12/19.
//  图片选择器

#import <Foundation/Foundation.h>


typedef NS_ENUM(short int, IPKImagePickerType) {
    IPKImagePickerTypeLibrary = 0,
    IPKImagePickerTypeCamera  = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface IPKImagePicker : NSObject
- (void)showPiker:(IPKImagePickerType)type param:(NSDictionary *)param handle:(IPKHandleBridge)handle;
- (void)upload:(NSString *)url file:(NSString *)file handle:(IPKHandleBridge)handle;

@end

NS_ASSUME_NONNULL_END
