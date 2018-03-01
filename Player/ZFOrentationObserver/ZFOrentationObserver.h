//
//  ZFOrentationObserver.h
//  ZFPlayer
//
//  Created by 任子丰 on 2017/12/5.
//  Copyright © 2017年 任子丰. All rights reserved.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 全屏的模式
typedef NS_ENUM(NSUInteger, ZFFullScreenMode) {
    ZFFullScreenModePortrait, // 竖屏全屏
    ZFFullScreenModeLandscape // 横屏全屏
};

@interface ZFOrentationObserver : NSObject

- (instancetype)initWithRotateViewView:(UIView *)rotateView containerView:(UIView *)containerView;
/// 小屏状态播放器的容器视图
@property (nonatomic, weak, readwrite) UIView *containerView;
/// 是否全屏
@property (nonatomic, assign, readonly, getter=isFullScreen) BOOL fullScreen;
/// 设备方向即将改变
@property (nonatomic, copy, readwrite, nullable) void(^orientationWillChange)(ZFOrentationObserver *observer, BOOL isFullScreen);
/// 设备方向已经改变
@property (nonatomic, copy, readwrite, nullable) void(^orientationChanged)(ZFOrentationObserver *observer, BOOL isFullScreen);
/// 全屏的模式，默认横屏进入全屏
@property (nonatomic, assign) ZFFullScreenMode fullScreenMode;
/// 进入横屏全屏状态
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation;
/// 进入竖屏全屏状态
- (void)enterPortraitFullScreen:(BOOL)fullScreen;

@end

NS_ASSUME_NONNULL_END


