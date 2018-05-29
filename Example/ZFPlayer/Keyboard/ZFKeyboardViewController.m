//
//  ZFKeyboardViewController.m
//  ZFPlayer_Example
//
//  Created by 紫枫 on 2018/5/25.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFKeyboardViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import <KTVHTTPCache/KTVHTTPCache.h>

@interface ZFKeyboardViewController ()
@property (nonatomic, strong) ZFPlayerController *player;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong)  UITextField *textField;

@end

@implementation ZFKeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.controlView addSubview:self.textField];
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    playerManager.shouldAutoPlay = YES;
    /// 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager];
    self.player.controlView = self.controlView;
    self.player.containerView = self.containerView;
    __weak typeof(self) weakSelf = self;
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        [weakSelf.textField resignFirstResponder];
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    };
    NSString *URLString = [@"http://tb-video.bdstatic.com/tieba-video/7_517c8948b166655ad5cfb563cc7fbd8e.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *proxyURLString = [KTVHTTPCache proxyURLStringWithOriginalURLString:URLString];
    playerManager.assetURL = [NSURL URLWithString:proxyURLString];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.textField.frame = CGRectMake(0, 0, 200, 35);
    self.textField.center = self.controlView.center;
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
        [_controlView showTitle:@"视频标题" coverURLString:@"http://imgsrc.baidu.com/forum/eWH%3D240%2C176/sign=183252ee8bd6277ffb784f351a0c2f1c/5d6034a85edf8db15420ba310523dd54564e745d.jpg" fullScreenMode:ZFFullScreenModeLandscape];
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

@end
