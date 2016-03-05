//
//  SecondViewController.m
//  Player
//
//  Created by 任子丰 on 16/3/3.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "SecondViewController.h"
#import "NetMoviePlayerViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = @[@"http://baobab.wdjcdn.com/14562919706254.mp4",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                        @"http://baobab.wdjcdn.com/1455782903700jy.mp4",
                        @"http://baobab.wdjcdn.com/14564977406580.mp4",
                        @"http://baobab.wdjcdn.com/1456316686552The.mp4",
                        @"http://baobab.wdjcdn.com/1456480115661mtl.mp4",
                        @"http://baobab.wdjcdn.com/1456665467509qingshu.mp4",
                        @"http://baobab.wdjcdn.com/1455614108256t(2).mp4",
                        @"http://baobab.wdjcdn.com/1456317490140jiyiyuetai_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",
                        @"http://baobab.wdjcdn.com/1456734464766B(13).mp4"];
   // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"netListCell"];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NetMoviePlayerViewController *movie = (NetMoviePlayerViewController *)segue.destinationViewController;
//    NSURL *URL = [NSURL URLWithString:@"http://baobab.cdn.wandoujia.com/14468618701471.mp4"];
//    NSURL *URL = [NSURL URLWithString:@"http://baobab.wdjcdn.com/1456653443902B.mp4"];
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSURL *URL = [NSURL URLWithString:self.dataSource[indexPath.row]];
    movie.videoURL = URL;
}


@end
