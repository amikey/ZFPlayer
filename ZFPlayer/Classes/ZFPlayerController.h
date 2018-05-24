//
//  ZFPlayer.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFPlayerMediaPlayback.h"
#import "ZFOrientationObserver.h"
#import "ZFPlayerMediaControl.h"
#import "ZFPlayerGestureControl.h"
#import "ZFFloatView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFPlayerController : NSObject

/// To see the video frames must set the contrainerView
@property (nonatomic, strong) UIView *containerView;

/// The currentPlayerManager must follow `ZFPlayerMediaPlayback` protocol
@property (nonatomic, strong, readonly) id<ZFPlayerMediaPlayback> currentPlayerManager;

/// The custom controlView must follow `ZFPlayerMediaControl` protocol
@property (nonatomic, strong) UIView<ZFPlayerMediaControl> *controlView;

/*!
 @method            playerWithPlayerManager:
 @abstract          Create an ZFPlayerController that plays a single audiovisual item.
 @param             playerManager must follow `ZFPlayerMediaPlayback` protocol
 @result            An instance of ZFPlayerController
 */
+ (instancetype)playerWithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager;

/*!
 @method            playerWithPlayerManager:
 @abstract          Create an ZFPlayerController that plays a single audiovisual item.
 @param             playerManager must follow `ZFPlayerMediaPlayback` protocol
 @result            An instance of ZFPlayerController
 */
- (instancetype)initwithPlayerManager:(id<ZFPlayerMediaPlayback>)playerManager;

/*!
 @method            playerWithScrollView:playerManager:
 @abstract          Create an ZFPlayerController that plays a single audiovisual item. Use in `tableView` or `collectionView`
 @param             scrollView is `tableView` or `collectionView`
 @param             playerManager must follow `ZFPlayerMediaPlayback` protocol
 @result            An instance of ZFPlayerController
 */
+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPlayerMediaPlayback>)playerManager;

/*!
 @method            playerWithScrollView:playerManager:
 @abstract          Create an ZFPlayerController that plays a single audiovisual item. Use in `tableView` or `collectionView`
 @param             scrollView is `tableView` or `collectionView`
 @param             playerManager must follow `ZFPlayerMediaPlayback` protocol
 @result            An instance of ZFPlayerController
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<ZFPlayerMediaPlayback>)playerManager;

@end


@interface ZFPlayerController (ZFPlayerTimeControl)

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;
@property (nonatomic, readonly) NSTimeInterval bufferTime;
@property (nonatomic, readonly) NSTimeInterval seekTime;
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) float bufferProgress;

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end

@interface ZFPlayerController (ZFPlayerPlaybackControl)

/// 0...1  the system volume
@property (nonatomic) float volume;
/// 0...1
@property (nonatomic, assign) float brightness;

/// 移动网络自动播放 default NO
@property (nonatomic, getter=isWWANAutoPlay) BOOL WWANAutoPlay;

/// 当前播放的下标，仅限一维数组
@property (nonatomic, assign) NSInteger currentPlayIndex;

/**
 If Yes, player will be called pause method When Received `UIApplicationWillResignActiveNotification` notification.
 default is YES.
 */
@property (nonatomic) BOOL pauseWhenAppResignActive;

/// 播放完了
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id asset);

- (void)playTheNext;

- (void)playThePrevious;

/// 播放某一个
- (void)playTheIndex:(NSInteger)index;

/*!
 @method           replaceCurrentPlayerManager:
 @abstract         Replaces the player's current playeranager with the specified player item.
 @param            manager must follow `ZFPlayerMediaPlayback` protocol
 @discussion       The playerManager that will become the player's current playeranager.
 */
- (void)replaceCurrentPlayerManager:(id<ZFPlayerMediaPlayback>)manager;

@end

@interface ZFPlayerController (ZFPlayerOrientationRotation)

@property (nonatomic, readonly) ZFOrientationObserver *orientationObserver;


/// When Orientation is LandscapeLeft or LandscapeRight, this value is YES.
@property (nonatomic, readonly) BOOL isFullScreen;

/// Lock the screen orientation
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/// The statusbar hidden
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

/**
 The current orientation of the player.
 Default is UIInterfaceOrientationPortrait.
 */
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

/**
 The block invoked When player will rotate.
 */
@property (nonatomic, copy, nullable) void(^orientationWillChange)(ZFPlayerController *player, BOOL isFullScreen);

/**
 The block invoked when player rotated.
 */
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(ZFPlayerController *player, BOOL isFullScreen);

- (void)addDeviceOrientationObserver;

- (void)removeDeviceOrientationObserver;

/// 进入横屏全屏状态
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/// 进入竖屏全屏状态
- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated;

/// 根据视频比例来判断全屏模式
- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated;


@end

@interface ZFPlayerController (ZFPlayerViewGesture)

/**
 @constant gestureControl
 @abstract An instance of ZFPlayerGestureControl
 */
@property (nonatomic, readonly) ZFPlayerGestureControl *gestureControl;

@property (nonatomic, assign) ZFPlayerDisableGestureTypes disableGestureTypes;

@end

@interface ZFPlayerController (ZFPlayerScrollView)

@property (nonatomic, readonly, nullable) UIScrollView *scrollView;

/// 列表播放滑出屏幕后，小窗时候的播放器的容器视图
@property (nonatomic, readonly, nullable) ZFFloatView *smallFloatView;

/// 正在播放的indexPath
@property (nonatomic, nullable) NSIndexPath *playingIndexPath;

@property (nonatomic) NSInteger playerViewTag;

/// 当前播放的cell移除屏幕时候是否停止播放，defalut is YES
@property (nonatomic) BOOL stopWhileNotVisible;

/// 小窗口是否显示
@property (nonatomic, readonly) BOOL isSmallFloatViewShow;

/**
 if tableView or collectionView has only one section , use sectionAssetURLs
 if normal model set this can use `playTheNext` `playThePrevious` `playTheIndex:`
 */
@property (nonatomic, copy) NSArray <NSURL *>*assetURLs;

/**
 if tableView or collectionView has more section, use sectionAssetURLs
 */
@property (nonatomic, copy) NSArray <NSArray <NSURL *>*>*sectionAssetURLs;

- (void)stopCurrentPlayingCell;

- (void)playTheIndexPath:(NSIndexPath *)indexPath;

@end


NS_ASSUME_NONNULL_END
