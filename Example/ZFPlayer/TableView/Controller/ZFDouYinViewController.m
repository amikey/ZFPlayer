//
//  ZFDouYinViewController.m
//  ZFPlayer_Example
//
//  Created by 紫枫 on 2018/6/4.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFDouYinViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/KSMediaPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import "ZFTableViewCellLayout.h"
#import "ZFTableData.h"
#import "ZFDouYinCell.h"
#import "ZFDouYinControlView.h"
#import "ZFUserCeneterViewController.h"

static NSString *kIdentifier = @"kIdentifier";
@interface ZFDouYinViewController ()  <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFDouYinControlView *controlView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *urls;

@end

@implementation ZFDouYinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"个人中心" style:UIBarButtonItemStylePlain target:self action:@selector(userCenterClick)];

    [self requestData];
    
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
//    KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc] init];
//    ZFIJKPlayerManager *playerManager = [[ZFIJKPlayerManager alloc] init];
    
    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:playerManager containerViewTag:100];
    self.player.assetURLs = self.urls;
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    self.player.controlView = self.controlView;
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    /// 1.0是完全消失时候
    self.player.playerDisapperaPercent = 1.0;
    
    @weakify(self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        [self.player.currentPlayerManager replay];
    };
    
    /// statusBarFrame changed
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layOutControllerViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        self.tableView.contentOffset = CGPointMake(0, 3*self.tableView.frame.size.height);
        [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
            @strongify(self)
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.tableView.rowHeight = self.tableView.frame.size.height;
}

- (void)layOutControllerViews {
    if (self.player.playingIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.player.playingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)requestData {
    self.urls = @[].mutableCopy;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    self.dataSource = @[].mutableCopy;
    NSArray *videoList = [rootDict objectForKey:@"list"];
    for (NSDictionary *dataDic in videoList) {
        ZFTableData *data = [[ZFTableData alloc] init];
        [data setValuesForKeysWithDictionary:dataDic];
        [self.dataSource addObject:data];
        NSString *URLString = [data.video_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:URLString];
        [self.urls addObject:url];
    }
}

- (void)userCenterClick {
    ZFUserCeneterViewController *userVC = [ZFUserCeneterViewController new];
    [self.navigationController pushViewController:userVC animated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    NSInteger index = (NSInteger)self.tableView.contentOffset.y/scrollView.frame.size.height;
    
    NSLog(@"=====%f",self.tableView.contentOffset.y);
    //scroll是与整屏相比的偏移量，肯定是正的
    CGFloat scroll = self.tableView.contentOffset.y - index*scrollView.frame.size.height;
    //与上一个滑动点比较，区分上滑还是下滑
    CGFloat offset = self.tableView.contentOffset.y - scrollView.zf_lastOffsetY;

    if (offset > 0) {
//        //上拉-44是mj_footer的高度，当拖拽超过44的时候会触发mj
//        if (playIndex==_tableView.items.count-1&&scroll>44) {
//            if (_tableView.updating==NO&&_tableView.mj_footer.state != MJRefreshStateNoMoreData) {
//                //判断是否正在刷新，正在刷新就不再进行如下设置，以免重复加载
//                _tableView.updating = YES;
//                //进到这里说明用户正在上拉加载，触发mj,此时要关闭翻页功能否则页面回弹mj_footer就看不到了，setContentOffset也无效
//                self.tableView.pagingEnabled = NO;
//                [self.tableView.mj_footer beginRefreshing];
//            }
//        }
    } else if (offset < 0) {
//        if (_tableView.updating == YES) {
            //如果用户上拉加载时，又进行下滑操作，就要打开翻页功能（可能加载时间长用户不想等又往上翻之前的cell）-这种情况少见但不排除，不做此操作的话，将请求延时十秒就会看到区别，但一旦用户有这种操作就会有闪屏问题，即用户在第10个cell上拉加载了，然后又下滑倒第5个cell，当拿到返回数据之后页面会从5自动滚动到第11个cell，造成闪屏，但在3G网络下经测试抖音也是这样，故就这样吧
//            self.tableView.pagingEnabled = YES;
//        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFDouYinCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    cell.data = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.tableView.frame.size.height;
//}

#pragma mark - ZFTableViewCellDelegate

- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}

#pragma mark - private method

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    [self.player playTheIndexPath:indexPath scrollToTop:scrollToTop];
    [self.controlView resetControlView];
    ZFTableData *data = self.dataSource[indexPath.row];
    [self.controlView showCoverViewWithUrl:data.thumbnail_url];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.pagingEnabled = YES;
        [_tableView registerClass:[ZFDouYinCell class] forCellReuseIdentifier:kIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        /// 停止的时候找出最合适的播放
        @weakify(self)
        _tableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            self.tableView.contentOffset = CGPointMake(0, indexPath.row*self.tableView.frame.size.height);
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        };
    }
    return _tableView;
}

- (ZFDouYinControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFDouYinControlView new];
    }
    return _controlView;
}


@end
