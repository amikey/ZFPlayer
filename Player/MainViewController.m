//
//  MainViewController.m
//  Player
//
//  Created by 任子丰 on 16/3/6.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "MainViewController.h"
#import "MoviePlayerViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(void)awakeFromNib
{
    self.selectedIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

// 哪些页面支持自动转屏
- (BOOL)shouldAutorotate{
    
    UINavigationController *nav = self.viewControllers[self.selectedIndex];
    if ([nav.topViewController isKindOfClass:[MoviePlayerViewController class]]) {
        NSUserDefaults *settingsData = [NSUserDefaults standardUserDefaults];
        NSString *hspData = [settingsData objectForKey:@"lockScreen"];
        if([hspData isEqualToString:@"1"]){
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

//当前viewcontroller支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{

    UINavigationController *nav = self.viewControllers[self.selectedIndex];
    if ([nav.topViewController isKindOfClass:[MoviePlayerViewController class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
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
