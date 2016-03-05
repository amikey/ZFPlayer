//
//  ZFPlayerMaskView.m
//  Player
//
//  Created by 任子丰 on 16/3/4.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "ZFPlayerMaskView.h"

@interface ZFPlayerMaskView ()
/** 渐变层*/
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
/** bottomView*/
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;

@end

@implementation ZFPlayerMaskView

-(void)dealloc
{
    NSLog(@"%@释放了",self.class);
}

-(void)awakeFromNib
{
    // 设置slider
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
//    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 1.0f);
//    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    //设置slider
//    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
//    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
    
    [self insertSubview:self.progressView belowSubview:self.videoSlider];
    self.videoSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
    
    self.progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    self.progressView.trackTintColor = [UIColor clearColor];
    
    //初始化渐变层
    self.gradientLayer = [CAGradientLayer layer];
    [self.bottomImageView.layer addSublayer:self.gradientLayer];
    
    //设置渐变颜色方向
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(0, 1);
    //设定颜色组
    self.gradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                  (__bridge id)[UIColor blackColor].CGColor];
    //设定颜色分割点
    self.gradientLayer.locations = @[@(0.0f) ,@(1.0f)];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.gradientLayer.frame = self.bottomImageView.bounds;
}

+ (instancetype)setupPlayerMaskView
{
    return [[NSBundle mainBundle] loadNibNamed:@"ZFPlayerMaskView" owner:nil options:nil].lastObject;
}


@end
