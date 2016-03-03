//
//  MoviePlayerViewController.m
//  Player
//
//  Created by 任子丰 on 15/11/7.
//  Copyright © 2015年 任子丰. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import "ZFPlayerView.h"

@interface MoviePlayerViewController ()

@property (nonatomic, assign) CGFloat width; // 坐标
@property (nonatomic, assign) CGFloat height; // 坐标
@property (nonatomic, strong) ZFPlayerView *playerView;

@end

@implementation MoviePlayerViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _width = [[UIScreen mainScreen]bounds].size.height;
    _height = [[UIScreen mainScreen]bounds].size.width;
    
    self.playerView = [[ZFPlayerView alloc] initWithFrame:CGRectMake(0, 0, _width, _height) URL:self.videoURL];
    self.playerView.frames = CGRectMake(0, 0, _width, _height);
    typeof(self) __weak weakSelf = self;
    self.playerView.goBackBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{}];
    };
    [self.view addSubview:self.playerView];
    
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"====%zd",fromInterfaceOrientation);
    self.playerView.frame = self.view.bounds;
}
#pragma mark - 横屏代码
- (BOOL)shouldAutorotate{
    return YES;
} //NS_AVAILABLE_IOS(6_0);当前viewcontroller是否支持转屏

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscape;
} //当前viewcontroller支持哪些转屏方向

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
