//
//  ZFOrentationObserver.m
//  ZFPlayer
//
//  Created by 任子丰 on 2017/12/5.
//  Copyright © 2017年 任子丰. All rights reserved.
//

#import "ZFOrentationObserver.h"
#import "ZFFullScreenViewController.h"
#import "ZFFullScreenTransition.h"
#import "AppDelegate.h"

@interface ZFOrentationObserver ()<UIViewControllerTransitioningDelegate>

@property (nonatomic, weak, readwrite) UIView *view;
///
@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;
/// 当前设备的方向
@property (nonatomic, readwrite) UIDeviceOrientation currentOrientation;
/// 全屏的控制器
@property (nonatomic, weak) ZFFullScreenViewController *fullScrrenVC;

@end

@implementation ZFOrentationObserver

- (instancetype)initWithRotateViewView:(UIView *)rotateView containerView:(UIView *)containerView {
    self = [super init];
    if (self) {
        _view = rotateView;
        _containerView = containerView;
        self.fullScreenMode = ZFFullScreenModeLandscape;
        [self observerDeviceOrientation];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)observerDeviceOrientation {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceOrientationChange {
    /// 如果是竖屏状态全屏，直接return
    if (self.fullScreenMode == ZFFullScreenModePortrait) return;
    if (UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        self.currentOrientation = [UIDevice currentDevice].orientation;
    } else {
        self.currentOrientation = UIDeviceOrientationUnknown;
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)self.currentOrientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            [self enterLandscapeFullScreen:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            [self enterLandscapeFullScreen:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            [self enterLandscapeFullScreen:UIInterfaceOrientationLandscapeRight];
        }
            break;
        default: break;
    }
}

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation {
    if (self.fullScreenMode == ZFFullScreenModePortrait) return;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (self.fullScreen) return;
        if (self.orientationWillChange) {
            self.orientationWillChange(self, self.isFullScreen);
        }
        ZFFullScreenViewController *fullScrrenVC = [[ZFFullScreenViewController alloc] init];
        fullScrrenVC.orientation = orientation;
        fullScrrenVC.fullScreenMode = self.fullScreenMode;
        fullScrrenVC.transitioningDelegate = self;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.window.rootViewController presentViewController:fullScrrenVC animated:YES completion:^{
            
        }];
        self.fullScreen = YES;
        self.fullScrrenVC = fullScrrenVC;
    } else {
        if (!self.fullScreen) return;
        if (self.orientationWillChange) {
            self.orientationWillChange(self, self.isFullScreen);
        }
        [self.fullScrrenVC dismissViewControllerAnimated:YES completion:^{
            self.fullScreen = NO;
            if (self.orientationChanged) {
                self.orientationChanged(self, self.isFullScreen);
            }
        }];
    }
}

/// 进入竖屏全屏状态
- (void)enterPortraitFullScreen:(BOOL)fullScreen {
    if (self.fullScreenMode == ZFFullScreenModeLandscape) return;
    if (fullScreen) {
        if (self.fullScreen) return;
        if (self.orientationWillChange) {
            self.orientationWillChange(self, self.isFullScreen);
        }
        ZFFullScreenViewController *fullScrrenVC = [[ZFFullScreenViewController alloc] init];
        fullScrrenVC.orientation = UIInterfaceOrientationPortrait;
        fullScrrenVC.fullScreenMode = self.fullScreenMode;
        fullScrrenVC.transitioningDelegate = self;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.window.rootViewController presentViewController:fullScrrenVC animated:YES completion:^{
            
        }];
        self.fullScreen = YES;
        self.fullScrrenVC = fullScrrenVC;
        if (self.orientationChanged) {
            self.orientationChanged(self, self.isFullScreen);
        }
    } else {
        if (!self.fullScreen) return;
        if (self.orientationWillChange) {
            self.orientationWillChange(self, self.isFullScreen);
        }
        [self.fullScrrenVC dismissViewControllerAnimated:YES completion:^{
            self.fullScreen = NO;
            if (self.orientationChanged) {
                self.orientationChanged(self, self.isFullScreen);
            }
        }];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [ZFFullScreenTransition transitionWithTransitionType:ZFTransitionTypePresent fullScreenMode:self.fullScreenMode playerView:self.view containerView:self.containerView];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [ZFFullScreenTransition transitionWithTransitionType:ZFTransitionTypeDismiss fullScreenMode:self.fullScreenMode playerView:self.view containerView:self.containerView];
}

@end
