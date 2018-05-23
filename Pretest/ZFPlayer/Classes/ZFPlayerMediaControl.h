//
//  ZFPlayerMediaControl.h
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
#import "ZFPlayerMediaPlayback.h"
#import "ZFOrientationObserver.h"
#import "ZFPlayerGestureControl.h"
#import "ZFReachabilityManager.h"
@class ZFPlayerController;

NS_ASSUME_NONNULL_BEGIN

@protocol ZFPlayerMediaControl <NSObject>

@required

- (void)videoPlayer:(ZFPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL;

@optional

#pragma mark - 播放之前/状态

/// 播放状态
- (void)videoPlayer:(ZFPlayerController *)videoPlayer playStateChanged:(ZFPlayerPlaybackState)state;

/// 加载状态
- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state;

#pragma mark - 进度

/**
 Call it when the playback changed
 
 @param videoPlayer the player
 @param currentTime the current play time
 @param totalTime the video total time
 */
- (void)videoPlayer:(ZFPlayerController *)videoPlayer
        currentTime:(NSTimeInterval)currentTime
          totalTime:(NSTimeInterval)totalTime;

/**
 Call it When buffer progress changed.
 */
- (void)videoPlayer:(ZFPlayerController *)videoPlayer
         bufferTime:(NSTimeInterval)bufferTime
          totalTime:(NSTimeInterval)totalTime;

/**
 Call it When you are dragging to change the video progress.
 */
- (void)videoPlayer:(ZFPlayerController *)videoPlayer
       draggingTime:(NSTimeInterval)seekTime
          totalTime:(NSTimeInterval)totalTime;

/**
 Call it when play end.
 */
- (void)videoPlayerPlayEnd:(ZFPlayerController *)videoPlayer;

#pragma mark - 锁屏
/**
 Call it when set videoPlayer.lockedScreen.
 */
- (void)lockedVideoPlayer:(ZFPlayerController *)videoPlayer lockedScreen:(BOOL)locked;

#pragma mark - 屏幕旋转

/**
 Call it when the fullScreen maode will changed.
 */
- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationWillChange:(ZFOrientationObserver *)observer;

/**
 Call it when the fullScreen maode did changed.
 */
- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer;

#pragma mark - The network changed

/**
 Call when the network changed
 */
- (void)videoPlayer:(ZFPlayerController *)videoPlayer reachabilityChanged:(ZFReachabilityStatus)status;

#pragma mark - 手势

/**
 Call when the gesture condition
 */
- (BOOL)gestureTriggerCondition:(ZFPlayerGestureControl *)gestureControl
                    gestureType:(ZFPlayerGestureType)gestureType
              gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                          touch:(UITouch *)touch;

/**
 Call when the gesture single tapped
 */
- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl;

/**
 Call when the gesture double tapped
 */
- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl;

/**
 Call when the gesture begin panGesture
 */
- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location;

/**
 Call when the gesture paning
 */
- (void)gestureChangedPan:(ZFPlayerGestureControl *)gestureControl
             panDirection:(ZFPanDirection)direction
              panLocation:(ZFPanLocation)location
             withVelocity:(CGPoint)velocity;

/**
 Call when the end panGesture
 */
- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl
           panDirection:(ZFPanDirection)direction
            panLocation:(ZFPanLocation)location;

/**
 Call when the pinchGesture changed
 */
- (void)gesturePinched:(ZFPlayerGestureControl *)gestureControl
                 scale:(float)scale;

#pragma mark - scrollview

/**
 Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
 */
- (void)playerWillAppearInScrollView:(ZFPlayerController *)videoPlayer;

/**
 Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
 */
- (void)playerAppearHalfInScrollView:(ZFPlayerController *)videoPlayer;

/**
 Call it when `tableView` or` collectionView` is about to appear. Because scrollview may be scrolled.
 */
- (void)playerDidAppearInScrollView:(ZFPlayerController *)videoPlayer;

/**
 Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
 */
- (void)playerWillDisappearInScrollView:(ZFPlayerController *)videoPlayer;

/**
 Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
 */
- (void)playerDisappearHalfInScrollView:(ZFPlayerController *)videoPlayer;

/**
 Call it when `tableView` or` collectionView` is about to disappear. Because scrollview may be scrolled.
 */
- (void)playerDidDisappearInScrollView:(ZFPlayerController *)videoPlayer;

@end

NS_ASSUME_NONNULL_END

