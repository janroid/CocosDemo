//
//  IPKFBManager.m
//  CardGame
//
//  Created by loyalwind on 2018/11/9.
//

#import "IPKFBManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <objc/runtime.h>

#define kPermissionPublicProfile @"public_profile"
#define kPermissionEmail         @"email"
#define kPermissionUserFriends   @"user_friends"

/** fb分享模型  */
@interface IPKFBShareModel : NSObject
{
@private
    NSData *_imageData;
}
/** 游戏名称 */
@property (nonatomic, copy) NSString *name;
/** 信息 */
@property (nonatomic, copy) NSString *message;
/** 描述 */
@property (nonatomic, copy) NSString *caption;
/** 分享图片路径（picture） */
@property (nonatomic, copy) NSString *picture;
/** 内容url（link）*/
@property (nonatomic, copy) NSString *link;
/** 图片数据 */
@property (nonatomic, readonly) NSData *imageData;
@end

@implementation IPKFBShareModel

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.picture = [dict[@"picture"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.caption = dict[@"caption"];
        self.message = dict[@"message"];
        self.name    = dict[@"name"];
        NSString *urlString = dict[@"link"] ? dict[@"link"] : @"";
        self.link = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

- (NSData *)imageData
{
    @synchronized (self) {
        if (!_imageData) {
            _imageData= [NSData dataWithContentsOfURL:[NSURL URLWithString:self.picture]];
        };
        return _imageData;
    }
}

@end

/**
 facebook请求操作的结果
 */
typedef NS_ENUM(NSInteger, IPKFacebookResult) {
    IPKFacebookResultOk     = 1, /**< facebook的操作成功了:1 */
    IPKFacebookResultError  = 2,/**< facebook的操作出错误了:2*/
    IPKFacebookResultCancel = 3, /**< facebook的操作取消了:3 */
};

/**
 facebook请求操作类型
 */
typedef NS_ENUM(NSInteger, IPKFacebookAimType) {
    IPKFacebookAimTypeLogin      = 0,/**< 登录 */
    IPKFacebookAimTypeShare      = 1,/**< 分享 */
    IPKFacebookAimTypeGetFreinds = 2,/**< 获取好友列表 */
};

@interface IPKFBManager ()<FBSDKSharingDelegate, FBSDKGameRequestDialogDelegate>
/** 操作完成回调block */
@property(nonatomic, copy) IPKHandleBridge handle;
/** fb登录 */
@property(nonatomic, strong) FBSDKLoginManager *fbLogin;
/** 分享数据模型 */
@property(nonatomic, strong) IPKFBShareModel *shareModel;

- (UIViewController *)fromViewController;
@end
/** 是否允许FBSDKWebDialogView 弹框旋转, 默认YES */
//static BOOL allowFBDialogOrientation = YES;

@implementation IPKFBManager

SingleImplementation(Manager)

+ (void)initialize
{
    // 利用运行时，拦截fb旋转弹框
    if ([FBSDK_VERSION_STRING isEqualToString:@"4.35.0"]) {
        Class FBSDKInternalUtility = NSClassFromString(@"FBSDKInternalUtility");
        if (!FBSDKInternalUtility) return;
        Method oldMethod = class_getClassMethod(FBSDKInternalUtility, @selector(shouldManuallyAdjustOrientation));
        if (!oldMethod) return;
        Method newMethod = class_getClassMethod(self, @selector(shouldManuallyAdjustOrientation));
        method_exchangeImplementations(oldMethod, newMethod);
    }
}
+ (BOOL)shouldManuallyAdjustOrientation
{
    return NO;//allowFBDialogOrientation;
}
#pragma mark - 懒加载
- (UIViewController *)fromViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (FBSDKLoginManager *)fbLogin
{
    if (!_fbLogin) {
        _fbLogin = [[FBSDKLoginManager alloc] init];
        _fbLogin.loginBehavior = FBSDKLoginBehaviorNative;
    }
    return _fbLogin;
}
#pragma mark - 登录，登出
+ (void)login:(NSDictionary *)param handle:(nonnull IPKHandleBridge)handle
{
    [[self sharedManager] login:param handle:^(id  _Nullable resultData) {
        handle ? handle(resultData) : nil;
    }];
}
- (void)login:(NSDictionary *)param handle:(nonnull IPKHandleBridge)handle
{
    self.handle = handle;
    FBSDKAccessToken *token = [self _getValidAccessToken:kPermissionPublicProfile];
    if (token){//已经登录过
        [self _dealFBResult:IPKFacebookResultOk extra:@{@"uid":token.userID, @"token":token.tokenString}];
    }else{
        [self _loginForType:IPKFacebookAimTypeLogin extra:nil];
    }
}
+ (void)logout
{
    [[self sharedManager] logout];
}
- (void)logout
{
    [self.fbLogin logOut];
}

#pragma mark - 邀请
+ (void)inviteFriends:(NSDictionary *)params handle:(nonnull IPKHandleBridge)handle
{
    [[self sharedManager] inviteFriends:params handle:handle];
}
- (void)inviteFriends:(NSDictionary *)params handle:(nonnull IPKHandleBridge)handle
{
    self.handle = handle;

    FBSDKGameRequestContent *content = [[FBSDKGameRequestContent alloc] init];
    content.filters = FBSDKGameRequestFilterAppNonUsers;
    content.message = params[@"message"] ? params[@"message"] : @"hello";
    content.data = params[@"data"];
    [FBSDKGameRequestDialog showWithContent:content delegate:self];
}

- (void)fetchInviteList:(NSDictionary *)params handle:(IPKHandleBridge)handle
{
    self.handle = handle;
    FBSDKAccessToken *token = [self _getValidAccessToken:kPermissionUserFriends];
    if (token) {
        [self _getFriendsList];
    }else{
        [self _loginForType:IPKFacebookAimTypeGetFreinds extra:nil];
    }
}

#pragma mark - 代理 FBSDKGameRequestDialogDelegate
- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"%@",results);
    NSString *toIds = [results[@"to"] componentsJoinedByString:@","];
    
    if (!toIds) toIds = @"";
    
    [self _dealFBResult:IPKFacebookResultOk extra:@{@"id":results[@"request"], @"ids":toIds}];
}

- (void)gameRequestDialog:(FBSDKGameRequestDialog *)gameRequestDialog didFailWithError:(NSError *)error
{
    [self _dealFBResult:IPKFacebookResultError extra:@{@"error":error.localizedDescription}];
}

- (void)gameRequestDialogDidCancel:(FBSDKGameRequestDialog *)gameRequestDialog
{
    [self _dealFBResult:IPKFacebookResultCancel extra:nil];
}

#pragma mark - 分享
+ (void)share:(NSDictionary *)params handle:(nonnull IPKHandleBridge)handle
{
    [[self sharedManager] share:params handle:handle];
}
- (void)share:(NSDictionary *)params handle:(nonnull IPKHandleBridge)handle
{
    self.handle = handle;
    FBSDKAccessToken *token = [self _getValidAccessToken:kPermissionPublicProfile];
    if (token) { // 已经登录过了
        [self _sharePhotoContent:params];
    }else{
        [self _loginForType:IPKFacebookAimTypeShare extra:params];
    }
}

#pragma mark - 代理 FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [self _dealFBResult:IPKFacebookResultOk extra:@{@"file":self.shareModel.picture}];
    self.shareModel = nil;
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [self _dealFBResult:IPKFacebookResultError extra:@{@"error":error.localizedDescription}];
    self.shareModel = nil;
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    [self _dealFBResult:IPKFacebookResultCancel extra:nil];
    self.shareModel = nil;
}

#pragma mark - priviate method
/**
 分享到facebook
 @param params 分享参数
 */
- (void)_sharePhotoContent:(NSDictionary *)params
{
    IPKFBShareModel *shareModel = [IPKFBShareModel modelWithDict:params];
    self.shareModel = shareModel;
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    properties[@"og:type"]        = @"game";
    properties[@"og:title"]       = shareModel.name;//params[@"name"];
    properties[@"og:description"] = shareModel.message;//params[@"message"];
    properties[@"og:image"]       = shareModel.picture;//params[@"picture"];
    properties[@"og:url"]         = shareModel.link;//params[@"link"];

    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];

    FBSDKShareOpenGraphAction *action = [FBSDKShareOpenGraphAction actionWithType:@"games.saves" object:object key:@"game"];
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    content.previewPropertyName = @"game";
    content.action = action;

    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    shareDialog.mode = [self _installedFacebook] ? FBSDKShareDialogModeNative : FBSDKShareDialogModeAutomatic;
    shareDialog.fromViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [shareDialog show];
    // 另一种分享方式
//    UIImage *image = [UIImage imageWithData:shareModel.imageData];
//    //FBPHOTOSHARE
//    FBSDKSharePhoto *sharePhoto = [FBSDKSharePhoto photoWithImage:image userGenerated:YES];
//    sharePhoto.caption = shareModel.message;
//
//    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
//    content.contentURL = [NSURL URLWithString:shareModel.link];
//    content.photos = @[sharePhoto];
//
//    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
//    shareDialog.shareContent = content;
//    shareDialog.delegate = self;
//    shareDialog.mode = [self _installedFacebook] ? FBSDKShareDialogModeNative : FBSDKShareDialogModeAutomatic;
//    shareDialog.fromViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
//    [shareDialog show];
}

- (BOOL)_installedFacebook
{
    NSArray *schemes = @[@"fbauth2", @"fbapi", @"fb-messenger-share-api", @"fbshareextension"];
    BOOL canOpen = NO;
    for (NSString *scheme in schemes) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://",scheme]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpen = YES;
            break;
        }
    }
    return canOpen;
}

/**
 获取好友列表
 */
- (void)_getFriendsList
{
    weakSelf(self);
    // me/friends 另外一个参数
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/invitable_friends" parameters:@{@"fields": @"id,name,picture"}];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            [weakSelf _dealFBResult:IPKFacebookResultError extra:@{@"error" : error.localizedDescription}];
            return;
        }
        
        if (!result) {
            [weakSelf _dealFBResult:IPKFacebookResultError extra:nil];
            return;
        }

        NSData *data = [NSJSONSerialization dataWithJSONObject:result[@"data"] options:NSJSONWritingPrettyPrinted error:nil];
        NSString *friends = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (!friends) friends = @"";
        [weakSelf _dealFBResult:IPKFacebookResultOk extra:@{@"data":friends}];
    }];
}

/**
 去获取授权
 @param type 获取授权的目的类型
 @param extra 额外参数
 */
- (void)_loginForType:(IPKFacebookAimType)type extra:(NSDictionary *)extra
{
    weakSelf(self);
    NSArray *permission = @[kPermissionPublicProfile];//@[kPermissionPublicProfile, kPermissionEmail, kPermissionUserFriends];
    [self.fbLogin logInWithReadPermissions:permission fromViewController:self.fromViewController handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        if (error) { //登录出错了
            NSLog(@"Error: %@", error.userInfo);
            [weakSelf.fbLogin logOut];
            [weakSelf _dealFBResult:IPKFacebookResultError extra:@{@"error":error.localizedDescription}];
            return;
        }
        
        if (result.isCancelled) {//登录取消了
            [weakSelf.fbLogin logOut];
            [weakSelf _dealFBResult:IPKFacebookResultCancel extra:nil];
            return;
        }
        
        FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
        if (![token.permissions containsObject:kPermissionPublicProfile]){
            [weakSelf.fbLogin logOut];
            [weakSelf _dealFBResult:IPKFacebookResultError extra:@{@"error":@"token未包含public_profile权限"}];
            return;
        }
        if (IPKFacebookAimTypeShare == type) { // 为了分享的登录
            [weakSelf _sharePhotoContent:extra];
        }else if (IPKFacebookAimTypeLogin == type){  // 为了登录
            [weakSelf _dealFBResult:IPKFacebookResultOk extra:@{@"uid":token.userID, @"token":token.tokenString}];
        }else {  // 为了获取还有列表
            if ([token.permissions containsObject:kPermissionUserFriends]) {
                [weakSelf _getFriendsList];
            }else {
                [weakSelf _dealFBResult:IPKFacebookResultError extra:nil];
            }
        }
    }];
}

/**
 用于处理facebook的各自操作结果回调
 @param fbResult 操作结果: IPKFacebookResult
 @param extra 额外参数: NSDictionary *
 */
- (void)_dealFBResult:(IPKFacebookResult)fbResult extra:(NSDictionary *)extra
{
    if (!self.handle) return;
    
    NSMutableDictionary *param = nil;
    if (extra) {
        param = [NSMutableDictionary dictionaryWithDictionary:extra];
    }else{
        param = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    param[@"result"] = @(fbResult);
    self.handle(param);
    self.handle = nil;
}

- (FBSDKAccessToken *)_getValidAccessToken:(NSString *)permission
{
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if ([token.permissions containsObject:permission] && !token.isExpired) {
        return token;
    }
    [self logout];
    return nil;
}
@end
