//
//  ZFKeyboardViewController.m
//  ZFPlayer_Example
//
//  Created by 紫枫 on 2018/5/25.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFKeyboardViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/KSMediaPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>

@interface ZFKeyboardViewController ()
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation ZFKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.playBtn];
    [self.controlView addSubview:self.textField];
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
//    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
    /// 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.containerView];
    self.player.controlView = self.controlView;
    __weak typeof(self) weakSelf = self;
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        [weakSelf.textField resignFirstResponder];
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    };
    NSString *URLString = [@"http://tb-video.bdstatic.com/videocp/12045395_f9f87b84aaf4ff1fee62742f2d39687f.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    playerManager.assetURL = [NSURL URLWithString:URLString];
    
    [self.controlView showTitle:@"视频标题" coverURLString:@"http://imgsrc.baidu.com/forum/eWH%3D240%2C176/sign=183252ee8bd6277ffb784f351a0c2f1c/5d6034a85edf8db15420ba310523dd54564e745d.jpg" fullScreenMode:ZFFullScreenModeLandscape];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w*9/16;
    self.containerView.frame = CGRectMake(x, y, w, h);
    
    self.textField.frame = CGRectMake(0, 0, 200, 35);
    self.textField.center = self.controlView.center;
    
    
    w = 44;
    h = w;
    x = (CGRectGetWidth(self.containerView.frame)-w)/2;
    y = (CGRectGetHeight(self.containerView.frame)-h)/2;
    self.playBtn.frame = CGRectMake(x, y, w, h);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField resignFirstResponder];
}

#pragma mark - about keyboard orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    /// the keyborad support orientations
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor orangeColor];
        _textField.placeholder = @"Click on the input";
    }
    return _textField;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor orangeColor];
    }
    return _containerView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"new_allPlay_44x44_"] forState:UIControlStateNormal];
    }
    return _playBtn;
}

@end
