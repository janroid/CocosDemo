//
//  AppController+Extension.m
//  iPoker
//
//  Created by loyalwind on 2019/2/28.
//
//

#import "AppController+Extension.h"
#import "UIDevice+Extension.h"
#import <objc/runtime.h>

#pragma mark - runtime property
#define kRegistedInterfaceOrientation @"registedInterfaceOrientation"

@interface AppController (Runtime)
/** 记录已经添加了观察 */
@property (nonatomic, assign) BOOL registedInterfaceOrientation;

@end

@implementation AppController (Extension)

#pragma mark - 屏幕旋转变化监听
- (void)registeInterfaceOrientationChanged:(void(^)(CGRect frame))handle
{
    // 监听状态栏方向变化结束通知，刘海屏专属
    if (![UIDevice isFringeScreen] || self.registedInterfaceOrientation) return;
    // 记录已经添加了观察
    self.registedInterfaceOrientation = YES;
    // 先更新一次
    [self _adaptationFringeScreen:handle];
    // 添加通知观察
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        // 当前状态栏方向
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        // UIInterfaceOrientationLandscapeLeft: home button on the left
        // UIInterfaceOrientationLandscapeRight: home button on the right
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            [self _adaptationFringeScreen:handle];
        }
    }];
}

// 适配刘海屏
- (void)_adaptationFringeScreen:(void(^)(CGRect))handle
{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if (![UIDevice isFringeScreen]) {
        handle ? handle(frame) : nil;
        return;
    }
    // 当前状态栏方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat fringeHight = 33;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        frame.origin.x = 0;
        frame.size.width -= fringeHight;
    }else if (orientation == UIInterfaceOrientationLandscapeRight){
        frame.origin.x = fringeHight;
        frame.size.width -= fringeHight;
    }
    
    handle ? handle(frame) : nil;
}

#pragma mark - runtime 属性方法
- (void)setRegistedInterfaceOrientation:(BOOL)registed
{
    objc_setAssociatedObject(self, kRegistedInterfaceOrientation, @(registed), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)registedInterfaceOrientation
{
    return [objc_getAssociatedObject(self, kRegistedInterfaceOrientation) boolValue];
}

#pragma mark - 网络状态变化监听
- (void)registeReachabilityStatusChanged:(void(^)(IPKReachabilityStatus status))handle
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        handle ? handle(status) : nil;
    }];
    [manager startMonitoring];
}
@end
