//
//  IPKDeviceManager.m
//  iPoker
//
//  Created by loyalwind on 2018/12/19.
//

#import "IPKDeviceManager.h"
#import "IPKImagePicker.h"

@interface IPKDeviceManager()<UIActionSheetDelegate>
@property(nonatomic, strong) NSDictionary *currentParam;
@property(nonatomic, copy) IPKHandleBridge currentHandle;
@property(nonatomic, strong) IPKImagePicker *imagePicker;

@end

@implementation IPKDeviceManager
SingleImplementation(Manager)

#pragma mark - 懒加载
- (IPKImagePicker *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[IPKImagePicker alloc] init];
    }
    return _imagePicker;
}


+ (void)pickImage:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    [[IPKDeviceManager sharedManager] pickImage:param handle:handle];
}

- (void)pickImage:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"Operation Option" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf(self);
        [self.imagePicker showPiker:IPKImagePickerTypeLibrary param:param handle:^(id  _Nullable resultData) {
            handle ? handle(resultData) : nil;
            weakSelf.imagePicker = nil;
        }];
    }];
    [alertVc addAction:albumAction];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf(self);
        [self.imagePicker showPiker:IPKImagePickerTypeCamera param:param handle:^(id  _Nullable resultData) {
            handle ? handle(resultData) : nil;
            weakSelf.imagePicker = nil;
        }];
    }];
    [alertVc addAction:cameraAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    [alertVc addAction:cancelAction];

    // 在 iPad 的 UIAlertControllerStyleActionSheet时需要设置
//    UIPopoverPresentationController *ppc = alertVc.popoverPresentationController;
//    ppc.sourceView = [UIApplication sharedApplication].keyWindow;
//    ppc.sourceRect = CGRectMake(0, 0, 1, 1);
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];

//    _currentParam = param;
//    _currentHandle = handle;
}
+ (void)uploadFeedImage:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    [[IPKDeviceManager sharedManager] uploadFeedImage:param handle:handle];
}
- (void)uploadFeedImage:(NSDictionary *)param handle:(IPKHandleBridge)handle
{
    NSString *url = param[@"Url"];
    NSString *content = param[@"content"];
    NSString *filePath = param[@"imgPath"] ? param[@"imgPath"] : @"";
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (url.length == 0 || content.length == 0 || !isExist) {
        handle ? handle(@{@"result": @"-5", @"error" : @"请检查Url、content、imgPath"}) : nil;
        return;
    }
    url = [NSString stringWithFormat:@"%@&content=%@", url, content];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.imagePicker upload:url file:filePath handle:handle];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex){ //取消
        return;
    }
    IPKImagePickerType type = IPKImagePickerTypeLibrary;// Album
    if (buttonIndex == actionSheet.firstOtherButtonIndex) { //Camera
        type = IPKImagePickerTypeCamera;
    }
    weakSelf(self);
    [self.imagePicker showPiker:type param:_currentParam handle:^(id  _Nullable resultData) {
        [weakSelf _safeCallHandle:resultData];
        weakSelf.imagePicker = nil;
    }];
}
- (void)_safeCallHandle:(id)args
{
    if (self.currentHandle) {
        self.currentHandle(args);
        self.currentHandle = nil;
    }
}
@end
