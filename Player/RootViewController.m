//
//  RootViewController.m
//  Player
//
//  Created by 任子丰 on 15/11/9.
//  Copyright © 2015年 任子丰. All rights reserved.
//

#import "RootViewController.h"
#import "MoviePlayerViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"点击跳转视频" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 150, 100);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)buttonAction
{
    MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
    movie.videoURL = @"http://baobab.cdn.wandoujia.com/14468618701471.mp4";
    [self presentViewController:movie animated:NO completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
