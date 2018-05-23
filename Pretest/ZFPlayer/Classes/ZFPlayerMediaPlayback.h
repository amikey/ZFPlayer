//
//  ZFMediaPlayback.h
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
#import "ZFPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZFPlayerPlaybackState) {
    ZFPlayerPlayStateUnknown = 0,
    ZFPlayerPlayStatePlaying,
    ZFPlayerPlayStatePaused,
    ZFPlayerStateInterrupted,
    ZFPlayerStateSeekingForward,
    ZFPlayerStateSeekingBackward,
    ZFPlayerPlayStatePlayFailed,
    ZFPlayerPlayStatePlayStopped
};

typedef NS_OPTIONS(NSUInteger, ZFPlayerLoadState) {
    ZFPlayerLoadStateUnknown        = 0,
    ZFPlayerLoadStatePrepare        = 1 << 0,
    ZFPlayerLoadStatePlayable       = 1 << 1,
    ZFPlayerLoadStatePlaythroughOK  = 1 << 2, // Playback will be automatically started in this state when shouldAutoplay is YES
    ZFPlayerLoadStateStalled        = 1 << 3, // Playback will be automatically paused in this state, if started
};

typedef NS_ENUM(NSInteger, ZFPlayerScalingMode) {
    ZFPlayerScalingModeNone,       // No scaling
    ZFPlayerScalingModeAspectFit,  // Uniform scale until one dimension fits
    ZFPlayerScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    ZFPlayerScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};

@protocol ZFPlayerMediaPlayback <NSObject>

/// 必须继承<ZFPlayerView>
@property (nonatomic) ZFPlayerView *view;
/* indicates whether or not audio output of the player is muted. Only affects audio muting for the player instance and not for the device. */

/// the player volume
@property (nonatomic) float volume;

@property (nonatomic, getter=isMuted) BOOL muted;
/// 0.5...2
@property (nonatomic) float rate;

@property (nonatomic) BOOL shouldAutoPlay;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;
@property (nonatomic, readonly) NSTimeInterval bufferTime;
@property (nonatomic, readonly) NSTimeInterval seekTime;
/// 是否正在播放
@property (nonatomic, readonly) BOOL isPlaying;

@property (nonatomic) ZFPlayerScalingMode scalingMode;

/**
 @abstract 查询视频准备是否完成
 @discussion isPreparedToPlay处理逻辑
 
 * 如果isPreparedToPlay为TRUE，则可以调用[ZFPlayerMediaPlayback play]接口开始播放;
 * 如果isPreparedToPlay为FALSE，直接调用[ZFPlayerMediaPlayback play]，则在play内部自动调用[ZFPlayerMediaPlayback prepareToPlay]接口。
 @see prepareToPlay
 */
// Returns YES if prepared for playback.
@property (nonatomic, readonly) BOOL isPreparedToPlay;
/// the play asset
@property (nonatomic) NSURL *assetURL;
/// the video size
@property (nonatomic, readonly) CGSize presentationSize;
/// the playback state
@property (nonatomic, readonly) ZFPlayerPlaybackState playState;
@property (nonatomic, readonly) ZFPlayerLoadState loadState;

/// 开始准备播放
@property (nonatomic, copy, nullable) void(^playerPrepareToPlay)(id asset, NSURL *assetURL);
/// 播放进度改变
@property (nonatomic, copy, nullable) void(^playerPlayTimeChanged)(id asset, NSTimeInterval currentTime, NSTimeInterval duration);
/// buffer
@property (nonatomic, copy, nullable) void(^playerBufferTimeChanged)(id asset, NSTimeInterval bufferTime, NSTimeInterval duration);
//// 状态改变
@property (nonatomic, copy, nullable) void(^playerPlayStatChanged)(id asset, ZFPlayerPlaybackState playState);
//// 加载状态改变
@property (nonatomic, copy, nullable) void(^playerLoadStatChanged)(id asset, ZFPlayerLoadState loadState);
/// 播放完了
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id asset);

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)replay;
- (void)stop;

- (UIImage *)thumbnailImageAtCurrentTime;

/// 更换当前的播放地址
- (void)replaceCurrentAssetURL:(NSURL *)assetURL;

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end

NS_ASSUME_NONNULL_END
