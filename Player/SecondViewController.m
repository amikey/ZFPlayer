//
//  SecondViewController.m
//  Player
//
//  Created by 任子丰 on 16/3/3.
//  Copyright © 2016年 zhaoqingwen. All rights reserved.
//

#import "SecondViewController.h"


@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeRight] forKey:@"orientation"];
    //强制横屏
    
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//        
//        [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
//         
//                                       withObject:@(UIInterfaceOrientationLandscapeRight)];
//        
//    }
    
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
