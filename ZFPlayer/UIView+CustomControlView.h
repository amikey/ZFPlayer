//
//  ZFPlayerControlView+Custom.h
//  Player
//
//  Created by 任子丰 on 16/10/12.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZFPlayer.h"

@interface UIView (CustomControlView)
@property (nonatomic, weak) id<ZFPlayerControlViewDelagate> delegate;

/** 显示top、bottom、lockBtn*/
- (void)zf_playerShowControlView;
/** 隐藏top、bottom、lockBtn*/
- (void)zf_playerHideControlView;
/** 重置ControlView */
- (void)zf_playerResetControlView;
/** 切换分辨率时候调用此方法*/
- (void)zf_playerResetControlViewForResolution;
/** 取消自动隐藏控制层view */
- (void)zf_playerCancelAutoFadeOutControlView;
/** 小屏播放 */
- (void)zf_playerBottomShrinkPlay;
/** 在cell播放 */
- (void)zf_playerCellPlay;
/** 播放完了 */
- (void)zf_playerPlayEnd;
/** 是否有下载功能 */
- (void)zf_playerHasDownloadFunction:(BOOL)sender;

/** 播放按钮状态 */
- (void)zf_playerPlayBtnState:(BOOL)state;
/** 锁定屏幕方向按钮状态 */
- (void)zf_playerLockBtnState:(BOOL)state;
/** 设置标题 */
- (void)zf_playerSetTitle:(NSString *)title;
/** 设置progress的进度 */
- (void)zf_playerSetProgress:(CGFloat)progress;

/** 设置预览图 */
- (void)zf_playerSetSliderImage:(UIImage *)image ;
/** 加载的菊花 */
- (void)zf_playerActivity:(BOOL)animated;
/** 拖拽快进 快退 */
- (void)zf_playerDraggedTime:(NSInteger)draggedTime totalTime:(NSInteger)totalTime isForward:(BOOL)forawrd;
/** 滑动调整进度结束结束 */
- (void)zf_playerDraggedEnd;
/** 正常播放 */
- (void)zf_playerCurrentTime:(NSInteger)currentTime totalTime:(NSInteger)totalTime sliderValue:(CGFloat)value;
/** progress显示缓冲进度 */
- (void)zf_plyerSetProgress:(CGFloat)progress;
/** 视频加载失败 */
- (void)zf_playerItemStatusFailed:(NSError *)error;

@end
