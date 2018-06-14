//
//  ZFNoramlViewController.m
//  ZFPlayer
//
//  Created by 紫枫 on 2018/3/21.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFNoramlViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/KSMediaPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>

@interface ZFNoramlViewController ()
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *changeBtn;

@end

@implementation ZFNoramlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.playBtn];
    [self.view addSubview:self.changeBtn];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w*9/16;
    self.containerView.frame = CGRectMake(x, y, w, h);
    
    w = 44;
    h = w;
    x = (CGRectGetWidth(self.containerView.frame)-w)/2;
    y = (CGRectGetHeight(self.containerView.frame)-h)/2;
    self.playBtn.frame = CGRectMake(x, y, w, h);
    
    w = 100;
    h = 30;
    x = (CGRectGetWidth(self.view.frame)-w)/2;
    y = CGRectGetMaxY(self.containerView.frame)+100;
    self.changeBtn.frame = CGRectMake(x, y, w, h);
}

- (void)changeVideo:(UIButton *)sender {
//    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
//    [self.player replaceCurrentPlayerManager:playerManager];
    NSString *URLString = [@"https://ylmtst.yejingying.com/asset/video/20180525184959_mW8WVQVd.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.player.currentPlayerManager.assetURL = [NSURL URLWithString:URLString];
    [self.controlView showTitle:@"抖音" coverURLString:@"http://imgsrc.baidu.com/forum/eWH%3D240%2C176/sign=183252ee8bd6277ffb784f351a0c2f1c/5d6034a85edf8db15420ba310523dd54564e745d.jpg" fullScreenMode:ZFFullScreenModePortrait];
}

- (void)playClick:(UIButton *)sender {
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
//    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
//    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
    /// 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.containerView];
    self.player.controlView = self.controlView;
    @weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self.view endEditing:YES];
        [self setNeedsStatusBarAppearanceUpdate];
    };
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        if (self.player.isFullScreen) {
            [self.player enterFullScreen:NO animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.player.orientationObserver.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player stop];
            });
        } else {
            [self.player stop];
        }
    };
    NSString *URLString = [@"http://tb-video.bdstatic.com/videocp/12045395_f9f87b84aaf4ff1fee62742f2d39687f.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    playerManager.assetURL = [NSURL URLWithString:URLString];
    [self.controlView showTitle:@"视频标题" coverURLString:@"http://imgsrc.baidu.com/forum/eWH%3D240%2C176/sign=183252ee8bd6277ffb784f351a0c2f1c/5d6034a85edf8db15420ba310523dd54564e745d.jpg" fullScreenMode:ZFFullScreenModeLandscape];
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
    [self.view endEditing:YES];
    self.player.currentPlayerManager.muted = !self.player.currentPlayerManager.muted;
}

#pragma mark - about keyboard orientation

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
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
        [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_changeBtn setTitle:@"Change video" forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeBtn;
}

@end
