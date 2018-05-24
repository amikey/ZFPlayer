//
//  ZFOrentationObserver.h
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 全屏的模式
typedef NS_ENUM(NSUInteger, ZFFullScreenMode) {
    ZFFullScreenModeLandscape, // 横屏全屏
    ZFFullScreenModePortrait   // 竖屏全屏
};

/// 全屏的模式
typedef NS_ENUM(NSUInteger, ZFRotateType) {
    ZFRotateTypeNormal,    // 普通
    ZFRotateTypeCell,      // cell
    ZFRotateTypeCellSmall  // cell模式小窗口
};

@interface ZFOrientationObserver : NSObject
/// 普通播放
- (instancetype)initWithRotateView:(UIView *)rotateView
                     containerView:(UIView *)containerView;
/// 列表播放
- (void)cellModelRotateView:(UIView *)rotateView
           rotateViewAtCell:(UIView *)cell
              playerViewTag:(NSInteger)playerViewTag;
///
- (void)cellSmallModelRotateView:(UIView *)rotateView
                   containerView:(UIView *)containerView;

/// 小屏状态播放器的容器视图
@property (nonatomic, weak) UIView *containerView;
/// 是否全屏
@property (nonatomic, readonly, getter=isFullScreen) BOOL fullScreen;
/// 锁定屏幕方向
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;
/// 设备方向即将改变
@property (nonatomic, copy, nullable) void(^orientationWillChange)(ZFOrientationObserver *observer, BOOL isFullScreen);
/// 设备方向已经改变
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(ZFOrientationObserver *observer, BOOL isFullScreen);
/// 全屏的模式，默认横屏进入全屏
@property (nonatomic) ZFFullScreenMode fullScreenMode;

@property (nonatomic) float duration; // rotate duration, default is 0.25

/// 锁定屏幕方向
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

/**
 The current orientation of the player.
 Default is UIInterfaceOrientationPortrait.
 
 readonly.
 */
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

- (void)addDeviceOrientationObserver;

- (void)removeDeviceOrientationObserver;

/// 进入横屏全屏状态
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/// 进入竖屏全屏状态
- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated;


@end

NS_ASSUME_NONNULL_END


