//
//  FirstViewController.m
//  Player
//
//  Created by 任子丰 on 15/11/9.
//  Copyright © 2015年 任子丰. All rights reserved.
//

#import "FirstViewController.h"
#import "LocalMoviePlayerViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    LocalMoviePlayerViewController *movie = (LocalMoviePlayerViewController *)segue.destinationViewController;
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
    movie.videoURL = videoURL;
}


@end
