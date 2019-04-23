//
//  UIImage+Extension.m
//  iPoker
//
//  Created by loyalwind on 2018/12/18.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)
+ (UIImage *)imageWithName:(NSString *)name
{
    UIImage *image = nil;
//    if (iOS7Later) { // 处理iOS7的情况
//        NSString *newName = [name stringByAppendingString:@"_os7"];
//        image = [UIImage imageNamed:newName];
//    }
    
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

/**
 *  根据图片返回对应字符串
 */
- (NSString *)toBase64String
{
    NSData *data = UIImageJPEGRepresentation(self, 1.0f);
    return [data base64EncodedStringWithOptions:kNilOptions];
}

+ (NSData *)imageData:(UIImage *)myimage;
{
    NSData *data = UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024) {
        if (data.length>4*1024*1024) {//4M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.2);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.5);
        }else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    return data;
}

+ (UIImage *)imageNamed:(NSString *)name withScale:(CGFloat)scale
{
    UIImage *image = [UIImage imageNamed:name];
    return [UIImage imageWithCGImage:image.CGImage scale:scale orientation:UIImageOrientationUp];
}

+ (UIImage *)resizedImage:(UIImage *)image
{
//    UIImage *image = [UIImage imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
- (UIImage *)scaleImageWithWidth:(CGFloat)width
{
    if (width <= 0) {
        return nil;
    }
    
    CGFloat height = self.size.height / self.size.width * width;
    
    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:(CGRect){CGPointZero, size}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
- (UIImage *)generateThumbnail_100x100
{
    return [self generateImageScaleToSize:CGSizeMake(100, 100)];
}

- (UIImage *)generateImageScaleToSize:(CGSize)size
{
    if (self == nil) {
        return self;
    }
    CGSize scaledSize = size;
    
    CGFloat widthFactor = size.width / self.size.width;
    CGFloat heightFactor = size.height / self.size.height;
    CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
    scaledSize.width = self.size.width * scaleFactor;
    scaledSize.height = self.size.height * scaleFactor;
    
    UIGraphicsBeginImageContext(scaledSize);
    
    [self drawInRect:CGRectMake(0, 0, scaledSize.width, scaledSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage *)scaleImage_200Kb_WithWidth:(CGFloat)width
{
    UIImage *image = [self scaleImageWithWidth:width];
    NSData *data = UIImageJPEGRepresentation(image,1.0);
    if (data.length > 200 * 1024) {
        data = [UIImage imageData:image];
        return [[UIImage alloc] initWithData:data];
    }else{
        return image;
    }
}

+ (UIImage *)createQRcodeImageWithString:(NSString *)string size:(CGFloat)size
{
    if (string.length == 0) return nil;
    // 1.创建过滤器
    CIFilter *filter =  [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复默认
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data == nil) return nil;
    
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    
    // 5.显示二维码
    return [self createNonInterpolatedUIImageFormCIImage:outputImage size:size];
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image size:(CGFloat)size
{
    if (!image || size <= 0)return nil;
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef csRef = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapCxtRef = CGBitmapContextCreate(nil, width, height, 8, 0, csRef, (CGBitmapInfo)kCGImageAlphaNone);
    CGImageRef imageRef = [CIContext.context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapCxtRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapCxtRef, scale, scale);
    CGContextDrawImage(bitmapCxtRef, extent, imageRef);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bitmapCxtRef);
    UIImage *returnImage = [UIImage imageWithCGImage:scaledImageRef];
    
    // 3.释放内存
    CGContextRelease(bitmapCxtRef);
    CGImageRelease(imageRef);
    CGImageRelease(scaledImageRef);
    CGColorSpaceRelease(csRef);
    
    return returnImage;
}

@end


@implementation UIImage (Zip)
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength
{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) { // 二分法优化图片处理方式
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

- (NSData *)compressSizeWithMaxLength:(NSUInteger)maxLength
{
    UIImage *resultImage = self;
    NSData *data = UIImageJPEGRepresentation(resultImage, 1);
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
            // Use NSUInteger to prevent white blank
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)), (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        UIGraphicsBeginImageContext(size);
            // Use image to draw (drawInRect:), image is larger but more compression time
            // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    return data;
}

- (NSData *)compressWithMaxLength:(NSUInteger)maxLength
{
        // 1.质量压缩
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(self, compression);
        //NSLog(@"Before compressing quality, image size = %ld KB",data.length/1024);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) { // 二分法优化图片处理方式
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, compression);
            //NSLog(@"Compression = %.1f", compression);
            //NSLog(@"In compressing quality loop, image size = %ld KB", data.length / 1024);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    
        //NSLog(@"After compressing quality, image size = %ld KB", data.length / 1024);
    if (data.length < maxLength) return data;
    UIImage *resultImage = [UIImage imageWithData:data];
    
        // 2.尺寸压缩
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
            //NSLog(@"Ratio = %.1f", ratio);
            // Use NSUInteger to prevent white blank
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)), (NSUInteger)(resultImage.size.height * sqrtf(ratio)));
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
            //NSLog(@"In compressing size loop, image size = %ld KB", data.length / 1024);
    }
        //NSLog(@"After compressing size loop, image size = %ld KB", data.length / 1024);
    return data;
}

@end
