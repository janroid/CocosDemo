/****************************************************************************
 Copyright (c) 2010-2013 cocos2d-x.org
 Copyright (c) 2013-2016 Chukong Technologies Inc.
 Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#import "AppController.h"
#import "cocos2d.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "AppController+Extension.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <UMCommon/UMCommon.h>
#import <UMAnalytics/MobClick.h>

@interface AppController()
@property(nonatomic, strong) UIImageView *luanchImgView;
/** 是否支持所有方向, 默认NO */
@property (nonatomic, assign, getter=isSupportedAllOrientations) BOOL supportedAllOrientations;
@end


/**
 用于标记是否支持所有方向，修复iPad 横屏使用相册奔溃bug
 @param supportedAllOrientations YES/NO
 */
extern "C" void IPKSetSupportedAllOrientations(BOOL supportedAllOrientations){
    AppController *delegate = (AppController *)[UIApplication sharedApplication].delegate;
    delegate.supportedAllOrientations = supportedAllOrientations;
}
@implementation AppController

@synthesize window;

// cocos2d application instance， 不要删除这个，不然会奔溃的
static AppDelegate s_sharedApplication;

#pragma mark -
#pragma mark Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 1.必须先初始化 cocos2d::Application
    cocos2d::Application *app = [self initializeCocosApp];
    
    // Override point for customization after application launch.
    // 2.必须在cocos2d::Application run之前初始化根控制器
    [self setupRootViewController];
    
    // 3.添加启动图片
    [self setupLaunchImage];
    
    // iOS11 解决SafeArea的问题
    if (@available(iOS 11, *)) {
//        if ([UIDevice isFringeScreen]) {
//            UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
    }
    // 添加其他初始化代码
    // ...
    // 添加网络状态变化通知
    [self registeReachabilityStatusChanged:^(IPKReachabilityStatus status) {
        NSLog(@"IPKReachabilityStatus--%ld",(long)status);
    }];
    
    // FBSDK 初始化处理
    [self setupFBLaunchingWithOptions:launchOptions];
    // 添加推送通知
    
    // 友盟统计
    [self setupUMeng];
    
    // 必须在初始化根控制器之后，return YES 前调用才可以运行 cocos2d::Application, 为了防止被写错位置，使用','表达式
    return ([self runCocosApp:app], YES);
}

/**
 初始化窗口
 */
- (void)setupRootViewController
{
    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self registeInterfaceOrientationChanged:^(CGRect frame) {
        window.frame = frame;
    }];
    // Use RootViewController to manage CCEAGLView
    _viewController = [[RootViewController alloc] init];
//    _viewController.wantsFullScreenLayout = YES;
    
    // Set RootViewController to window
    // use this method on ios6
    [window setRootViewController:_viewController];
    
    [window makeKeyAndVisible];
    [UIApplication sharedApplication].statusBarHidden = YES;
    // 设置关闭自动息屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)setupLaunchImage
{
    NSString *imgName = @"";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        imgName = @"Default-iPhone-Landscape-736h@3x.png";
    }else {
        imgName = @"Default-iPad-Landscape-768h@2x.png";
    }
    UIImage *launchImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName ofType:nil]];
    if (!launchImg) {
        launchImg = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"startScreen.jpg" ofType:nil]];
    }
    UIImageView *imgView = [[UIImageView alloc] initWithImage:launchImg];
    imgView.frame = window.bounds;
    
    self.luanchImgView = imgView;
    [window addSubview:imgView];
}

- (void)setupFBLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:[UIApplication sharedApplication] didFinishLaunchingWithOptions:launchOptions];
    NSURL *launchUrl = launchOptions[UIApplicationLaunchOptionsURLKey];
    // 延迟处理深度链接
    if (launchUrl == nil) {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (url) [[UIApplication sharedApplication] openURL:url];
        }];
    }else{
        // 异步处理，避免卡主程序
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:launchUrl];
        });
    }
}
- (cocos2d::Application *)initializeCocosApp
{
    cocos2d::Application *app = cocos2d::Application::getInstance();
    
    // Initialize the GLView attributes
    app->initGLContextAttrs();
    cocos2d::GLViewImpl::convertAttrs();
    return app;
}

- (int)runCocosApp:(cocos2d::Application *)app
{
    // IMPORTANT: Setting the GLView should be done after creating the RootViewController
    cocos2d::GLView *glview = cocos2d::GLViewImpl::createWithEAGLView((__bridge void *)_viewController.view);
    cocos2d::Director::getInstance()->setOpenGLView(glview);
    
    //run the cocos2d-x game scene
    return app->run();
}

- (void)setupUMeng
{
    [UMConfigure initWithAppkey:@"5cb85c4761f56412c100087a" channel:@"App Store"];
    [MobClick setScenarioType:E_UM_GAME];
#if DEBUG_MODE
    [MobClick setCrashReportEnabled:NO];
    [UMConfigure setLogEnabled:YES];
#endif
}
- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->pause(); */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    // We don't need to call this method any more. It will interrupt user defined game pause&resume logic
    /* cocos2d::Director::getInstance()->resume(); */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::Application::getInstance()->applicationDidEnterBackground();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::Application::getInstance()->applicationWillEnterForeground();
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

//iOS 9 之前版本
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//    NSLog(@"跳转到URL schema中配置的地址 4.2以后-->%@",url);//跳转到URL schema中配置的
//    NSString *bundleID = NSBundle.mainBundle.infoDictionary[(__bridge_transfer NSString *)kCFBundleIdentifierKey];
     BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
    return handled;
}
//iOS 9 及更高版本
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    // Add any custom logic here.
    return handled;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.supportedAllOrientations) {
        return UIInterfaceOrientationMaskAll;
    }else {
        return UIInterfaceOrientationMaskLandscape;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc
{
#if __has_feature(objc_arc)
#else
    [window release];
    [_viewController release];
    [super dealloc];
#endif
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)engineLoaded
{
    AppController *delegate = [UIApplication sharedApplication].delegate;
    [delegate.luanchImgView removeFromSuperview];
    delegate.luanchImgView = nil;
}
@end
