//
//  MoviePlayerViewController.m
//  Player
//
//  Created by 任子丰 on 15/11/7.
//  Copyright © 2015年 任子丰. All rights reserved.
//

#import "NetMoviePlayerViewController.h"
#import "ZFPlayerView.h"

@interface NetMoviePlayerViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet ZFPlayerView *playerView;

@end

@implementation NetMoviePlayerViewController

-(void)dealloc
{
    NSLog(@"%@释放了",self.class);
    [self.playerView cancelAutoFadeOutControlBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -49, 0);
    
    self.playerView.videoURL = self.videoURL;
     __weak typeof(self) weakSelf = self;
    self.playerView.goBackBlock = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };

}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor  = [UIColor whiteColor];
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.view.backgroundColor = [UIColor blackColor];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"netCell"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//#pragma mark - 横屏代码
//- (BOOL)shouldAutorotate{
//    return YES;
//} //NS_AVAILABLE_IOS(6_0);当前viewcontroller是否支持转屏
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    
//    return UIInterfaceOrientationMaskLandscape;
//} //当前viewcontroller支持哪些转屏方向
//
//-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return UIInterfaceOrientationLandscapeRight;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
