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

/** 类方法创建，改方法适用于代码创建View */
+ (instancetype)setupZFPlayer;

@end
