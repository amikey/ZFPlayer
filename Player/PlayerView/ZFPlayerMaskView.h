//
//  ZFPlayerMaskView.h
//  Player
//
//  Created by 任子丰 on 16/3/4.
//  Copyright © 2016年 zhaoqingwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFPlayerMaskView : UIView
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISlider *videoSlider;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *horizontalLabel;
+ (instancetype)setupPlayerMaskView;
@end
