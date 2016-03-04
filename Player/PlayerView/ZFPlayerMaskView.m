//
//  ZFPlayerMaskView.m
//  Player
//
//  Created by 任子丰 on 16/3/4.
//  Copyright © 2016年 zhaoqingwen. All rights reserved.
//

#import "ZFPlayerMaskView.h"

@implementation ZFPlayerMaskView

-(void)awakeFromNib
{
    // 设置slider
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"iconfont-yuanquan-2"] forState:UIControlStateNormal];
    UIGraphicsBeginImageContextWithOptions((CGSize){ .7, .7 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //设置slider
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
    
    // 设置快进快退label
    self.horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Management_Mask"]];
    self.horizontalLabel.hidden = YES; //先隐藏
    
}

+ (instancetype)setupPlayerMaskView
{
    return [[NSBundle mainBundle] loadNibNamed:@"ZFPlayerMaskView" owner:nil options:nil].lastObject;
}


@end
