//
//  ZFPlayerView.h
//  Player
//
//  Created by 任子丰 on 16/3/3.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GoBackBlock)(void);

@interface ZFPlayerView : UIView

/** 视频URL */
@property (nonatomic, strong) NSURL *videoURL;
/** 返回按钮Block */
@property (nonatomic, copy) GoBackBlock goBackBlock;
/**
 *  取消延时
 */
- (void)cancelAutoFadeOutControlBar;

@end
