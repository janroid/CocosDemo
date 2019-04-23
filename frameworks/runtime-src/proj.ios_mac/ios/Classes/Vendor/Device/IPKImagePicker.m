//
//  IPKImagePicker.m
//  iPoker
//
//  Created by loyalwind on 2018/12/19.
//

#import "IPKImagePicker.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIImage+Extension.h"
#import "IPKFileManager.h"
#import "AFNetworking.h"

#define kUploadImageMaxFileSize 0.2*1000*1000 // 限制300KB，理论上这些基本业务应该够了
#define IPKBoundary @"*****"
#define IPKEncode(string) [string dataUsingEncoding:NSUTF8StringEncoding]
#define IPKNewLine [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]

extern void IPKSetSupportedAllOrientations(BOOL supportedAllOrientations);

/**
 主要是为了适配iPad iPhone 相册横竖屏旋转问题
 */
@interface IPKImagePickerController : UIImagePickerController

@end
@implementation IPKImagePickerController
- (instancetype)init
{
    if (self = [super init]) {
        self.allowsEditing = YES;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) { // iPhone 上只支持竖屏
        return UIInterfaceOrientationMaskPortrait;
    }else{ // iPad 上只支持横屏
        return UIInterfaceOrientationMaskLandscape;
    }
}

@end

@interface IPKImagePicker ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLSessionTaskDelegate>
@property(nonatomic, strong) IPKImagePickerController *imagePickerVc;
@property(nonatomic, strong) NSDictionary *param;
@property(nonatomic, copy) IPKHandleBridge handle;
@property(nonatomic, assign) IPKImagePickerType pickerType;

@end

@implementation IPKImagePicker


- (IPKImagePickerController *)imagePickerVc
{
    if (!_imagePickerVc) {
        _imagePickerVc = [[IPKImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
    }
    return _imagePickerVc;
}

- (void)showPiker:(IPKImagePickerType)type param:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    self.pickerType = type;
    self.param      = param.copy;
    self.handle     = handle;
    BOOL result = NO;
    if (type == IPKImagePickerTypeLibrary) { // 检测相册库权限
        float version = [UIDevice currentDevice].systemVersion.floatValue;
        if (version >= 8.0) {
            result = [self _permissionPhontosCheckAfteriOS8];
        }else{
            result = [self _permissionPhontosCheckBeforeiOS8];
        }
    }else{ // 检测相机库权限
        result = [self _permissionCameraCheck];
    }
    
    if(result){
        [self _openImgChooseController];
    }
}
#pragma mark - <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    IPKSetSupportedAllOrientations(NO); // 记录不再支持所有方向
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self _safeCallHandle:@{@"result":@(NO)}];
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    // 压缩处理
    NSData *data   = [editImage compressQualityWithMaxLength:kUploadImageMaxFileSize];
    
    // 写入文件
    NSString *name = _param[@"Name"] ? _param[@"Name"] : @"head_tmp";
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpeg",[IPKFileManager saveDirectory], name];
    BOOL success   = [data writeToFile:path atomically:YES];
    if ([_param[@"isNeedUpload"] boolValue] && _param[@"Url"]) {// 立马上传图片
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        [self _upload:_param[@"Url"] file:path];
    }else{
        //回调
        [self _safeCallHandle:@{@"result":@(success), @"imagePath":path}];
    }
    IPKSetSupportedAllOrientations(NO); // 记录不再支持所有方向
    // 消失
    [picker dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
}
- (void)upload:(NSString *)url file:(NSString *)file handle:(IPKHandleBridge)handle
{
    self.handle = handle;
    [self _uploadFeed:url file:file];
}

- (void)_upload:(NSString *)url file:(NSString *)file
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // 1.设置请求头
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", IPKBoundary] forHTTPHeaderField:@"Content-Type"];
    
    // 2.拼接请求体
    NSMutableData *body = [NSMutableData data];
    // 文件参数
    // 分割线
    [body appendData:IPKEncode(@"--")];
    [body appendData:IPKEncode(IPKBoundary)];
    [body appendData:IPKNewLine];
    
    // 文件参数名
    [body appendData:IPKEncode([NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"icon.jpg\""])];
    [body appendData:IPKNewLine];
    
    // 文件的类型
    [body appendData:IPKEncode([NSString stringWithFormat:@"Content-Type: image/jpeg"])];
    [body appendData:IPKNewLine];
    
    // 文件数据
    [body appendData:IPKNewLine];
    [body appendData:[NSData dataWithContentsOfFile:file]];
    [body appendData:IPKNewLine];
    
    // 结束标记
    /*
     --分割线--\r\n
     */
    [body appendData:IPKEncode(@"--")];
    [body appendData:IPKEncode(IPKBoundary)];
    [body appendData:IPKEncode(@"--")];
    [body appendData:IPKNewLine];
    
    // 1.创建Session
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // 2.根据Session创建Task
    /*
     第一个参数: 需要请求的地址/请求头/请求体
     第二个参数: 是需要数据的二进制数据, 但是这个数据时拼接之后的数据
     */
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{ // 回到主线程进行刷新ui
            if (error) {
                NSLog(@"%@",error);
                [self _safeCallHandle:@{@"result":@(-5), @"error": error.localizedDescription}];
            }else{
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data.toJSONObject];
                dict[@"result"] = @(0);
                [self _safeCallHandle:dict];
            }
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        });
    }];
        
    // 3.执行Task
    [task resume];
}

- (void)_uploadFeed:(NSString *)url file:(NSString *)file
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
        // 1.设置请求头
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", IPKBoundary] forHTTPHeaderField:@"Content-Type"];
    
        // 2.拼接请求体
    NSMutableData *body = [NSMutableData data];
        // 文件参数
        // 分割线
    [body appendData:IPKEncode(@"--")];
    [body appendData:IPKEncode(IPKBoundary)];
    [body appendData:IPKNewLine];
    
        // 文件参数名
    [body appendData:IPKEncode([NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"icon.jpg\""])];
    [body appendData:IPKNewLine];
    
        // 文件的类型
    [body appendData:IPKEncode([NSString stringWithFormat:@"Content-Type: image/jpeg"])];
    [body appendData:IPKNewLine];
    
        // 文件数据
    [body appendData:IPKNewLine];
    [body appendData:[NSData dataWithContentsOfFile:file]];
    [body appendData:IPKNewLine];
    
        // 结束标记
    /*
     --分割线--\r\n
     */
    [body appendData:IPKEncode(@"--")];
    [body appendData:IPKEncode(IPKBoundary)];
    [body appendData:IPKEncode(@"--")];
    [body appendData:IPKNewLine];
    
        // 1.创建Session
        //    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // 2.根据Session创建Task
    /*
     第一个参数: 需要请求的地址/请求头/请求体
     第二个参数: 是需要数据的二进制数据, 但是这个数据时拼接之后的数据
     */
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{ // 回到主线程进行刷新ui
            if (error) {
                NSLog(@"%@",error);
                [self _safeCallHandle:@{@"result":@"-5", @"error": error.localizedDescription}];
            }else{
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data.toJSONObject];
                int ret = [dict[@"ret"] intValue];
                dict[@"result"] = @(ret);
                if (ret == 0) {
                    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
                }
                [self _safeCallHandle:dict];
            }
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        });
    }];
    
        // 3.执行Task
    [task resume];
}
#pragma mark - private method
//相册检查权限 iOS 8 之前
- (BOOL)_permissionPhontosCheckBeforeiOS8
{
    BOOL result = NO;
    ALAuthorizationStatus status0 = [ALAssetsLibrary authorizationStatus];
    if (status0 == ALAuthorizationStatusRestricted) { // 受限制
        
    }else if (status0 == ALAuthorizationStatusAuthorized){ // 同意授权
        result = YES;
    }else if (status0 == ALAuthorizationStatusDenied){ // 拒绝
        [self _showOpenPhotosFailure];
    }else if (status0 == ALAuthorizationStatusNotDetermined){ // 还未决定
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            // 用户点击 "OK"
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _openImgChooseController];
            });
        } failureBlock:^(NSError *error) { // 用户点击 不允许访问
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _showOpenPhotosFailure];
            });
        }];
    }
    
    return result;
}

//相册检查权限 iOS 8 之后
- (BOOL)_permissionPhontosCheckAfteriOS8
{
    BOOL result = NO;
    PHAuthorizationStatus status0 = [PHPhotoLibrary authorizationStatus];
    if (status0 == PHAuthorizationStatusRestricted) { // 受限制
        
    }else if (status0 == PHAuthorizationStatusAuthorized){ // 同意授权
        result = YES;
    }else if (status0 == PHAuthorizationStatusDenied){ // 拒绝
        [self _showOpenPhotosFailure];
    }else if (status0 == PHAuthorizationStatusNotDetermined){ // 还未决定
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self _openImgChooseController];
                }else{
                    [self _showOpenPhotosFailure];
                }
            });
        }];
    }
    return result;
}

//检查相机权限
- (BOOL)_permissionCameraCheck
{
    BOOL result = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus ==AVAuthorizationStatusRestricted){
        NSLog(@"Restricted");
    }else if(authStatus == AVAuthorizationStatusDenied){
        NSLog(@"Denied");     //应该是这个，如果不允许的话
        [self _showOpenCameraFailure];
    }
    else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问
        NSLog(@"Authorized");
        result = YES;
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                //点击允许访问时调用,用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _openImgChooseController];
                });
            }
        }];
    }
    return result;
}

- (void)_openImgChooseController
{
    if(self.pickerType == IPKImagePickerTypeLibrary || ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        self.imagePickerVc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{
        self.imagePickerVc.sourceType        = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerVc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        self.imagePickerVc.cameraDevice      = UIImagePickerControllerCameraDeviceFront;
        self.imagePickerVc.videoQuality      = UIImagePickerControllerQualityTypeLow;
    }
    IPKSetSupportedAllOrientations(YES); // 记录支持所有方向
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:self.imagePickerVc animated:NO completion:nil];
}

- (void)_showOpenPhotosFailure
{
    NSString *tips = @"打不开相机啦o(>﹏<)o \n 可以在\"设置-隐私-相册\"中打开权限。";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:tips delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [self _safeCallHandle:@{@"result":@(NO)}];
}

- (void)_showOpenCameraFailure
{
    NSString *tips = @"打不开相机啦o(>﹏<)o \n 可以在\"设置-隐私-相机\"中打开权限。";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:tips delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    [self _safeCallHandle:@{@"result":@(NO)}];
}

- (void)_safeCallHandle:(id)args
{
    if (self.handle) {
        self.handle(args);
        self.handle = nil;
    }
}

- (void)dealloc
{
    NSLog(@"---")
}
@end
