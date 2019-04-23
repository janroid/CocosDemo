//
//  UIImage+Rotation.h
//  deliveryLockers
//
//  Created by zhaohs on 16/3/7.
//  Copyright © 2016年 zhaohs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotation)

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

/**
 修复图片被系统旋转的问题(因为大于2M ,从相册或拍照取出的图片，会被自动旋转90°）

 @param aImage 相册，拍照的图片
 @return 返回一个修复方向的图片
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
