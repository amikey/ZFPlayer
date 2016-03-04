//
//  VideoPlayViewController.m
//  Player
//
//  Created by 任子丰 on 16/3/3.
//  Copyright © 2016年 zhaoqingwen. All rights reserved.
//

#import "VideoPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZFPlayerView.h"

@interface VideoPlayViewController ()
/** 视频URL */
@property (nonatomic, copy) NSString *videoURL;
@property(nonatomic,assign)CGFloat width; // 坐标
@property(nonatomic,assign)CGFloat height; // 坐标
@property (nonatomic, strong) AVPlayer *player; // 播放属性
@property (nonatomic, strong) AVPlayerItem *playerItem; // 播放属性
@property (nonatomic, strong) ZFPlayerView *playerView;
@end

@implementation VideoPlayViewController

-(void)dealloc
{
    NSLog(@"%@释放了",self.class);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    [UIApplication sharedApplication].statusBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {

        [[UIDevice currentDevice] performSelector:@selector(setOrientation:)

                                       withObject:@(UIInterfaceOrientationLandscapeRight)];

    }
    self.videoURL = @"http://baobab.cdn.wandoujia.com/14468618701471.mp4";
    _width = [[UIScreen mainScreen]bounds].size.width;
    _height = [[UIScreen mainScreen]bounds].size.height;
    
    self.playerView = [[ZFPlayerView alloc] initWithFrame:CGRectMake(0, 0, _width, _height) URL:self.videoURL];
    self.playerView.frames = CGRectMake(0, 0, _width, _height);
    typeof(self) __weak weakSelf = self;
    self.playerView.goBackBlock = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:^{}];
    };
    [self.view addSubview:self.playerView];
    
//    [self.playerView  mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.equalTo(self.view);
//        make.height.equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f);
//    }];
    
    [_player play];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"====%zd  %@",fromInterfaceOrientation,self.view);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)ration:(UIBarButtonItem *)sender {
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
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
