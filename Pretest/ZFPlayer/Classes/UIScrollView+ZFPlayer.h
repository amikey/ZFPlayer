//
//  UIScrollView+ZFPlayer.h
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
#import "ZFPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

/*
 * The scroll derection of tableview.
 * 滚动类型
 */
typedef NS_ENUM(NSUInteger, ZFPlayerScrollDerection) {
    ZFPlayerScrollDerectionNone = 0,
    ZFPlayerScrollDerectionUp = 1, // 向上滚动
    ZFPlayerScrollDerectionDown = 2 // 向下滚动
};

@interface UIScrollView (ZFPlayer)

@property (nonatomic) BOOL enableDirection;

/// 正在播放的indexPath
@property (nonatomic, strong, nullable) NSIndexPath *playingIndexPath;
/// 应该播放的indexPath, 点亮的那个
@property (nonatomic, strong, nullable) NSIndexPath *shouldPlayIndexPath;

/// 移动网络自动播放 default NO
@property (nonatomic, getter=isWWANAutoPlay) BOOL WWANAutoPlay;

@property (nonatomic) NSInteger playerViewTag;

/// 是否有视频在播放
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic) ZFPlayerScrollDerection scrollDerection;

/// 当前播放的cell移除屏幕时候是否停止播放，defalut is YES
@property (nonatomic) BOOL stopWhileNotVisible;

/// 播放器即将显示
@property (nonatomic, copy, nullable) void(^playerWillAppearInScrollView)(NSIndexPath *indexPath);
/// 播放器显示一半
@property (nonatomic, copy, nullable) void(^playerAppearHalfInScrollView)(NSIndexPath *indexPath);
/// 播放器完全显示
@property (nonatomic, copy, nullable) void(^playerDidAppearInScrollView)(NSIndexPath *indexPath);
/// 播放器即将消失
@property (nonatomic, copy, nullable) void(^playerWillDisappearInScrollView)(NSIndexPath *indexPath);
/// 播放器消失一半
@property (nonatomic, copy, nullable) void(^playerDisappearHalfInScrollView)(NSIndexPath *indexPath);
/// 播放器完全消失
@property (nonatomic, copy, nullable) void(^playerDidDisappearInScrollView)(NSIndexPath *indexPath);

/// 停止滑动时候筛选应该播放的cell（用来滑动停止时候播放）
- (void)zf_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// 滚时候筛选应该播放的cell（可以使用这个来筛选高亮的cell）
- (void)zf_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// 根据index获取当前的cell
- (UIView *)zf_getCellForIndexPath:(NSIndexPath *)indexPath;

/// 滑动
- (void)zf_scrollToRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)zf_scrollViewDidScroll;

@end

NS_ASSUME_NONNULL_END
