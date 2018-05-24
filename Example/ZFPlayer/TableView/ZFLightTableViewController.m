//
//  ZFLightTableViewController.m
//  ZFPlayer
//
//  Created by 任子丰 on 2018/4/1.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFLightTableViewController.h"
#import "ZFTableViewCell.h"
#import <ZFPlayer/ZFPlayer.h>
#import "ZFPlayerControlView.h"
#import "ZFTableData.h"
#import "ZFTableViewCellLayout.h"

static NSString *kIdentifier = @"kIdentifier";

@interface ZFLightTableViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, strong) ZFAVPlayerManager *playerManager;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSMutableArray *urls;

@end

@implementation ZFLightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = [UIColor redColor];
    [self requestData];
    self.navigationItem.title = @"列表播放";
    
    self.playerManager = [[ZFAVPlayerManager alloc] init];
    self.playerManager.shouldAutoPlay = YES;
    
    /// player
    self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:self.playerManager];
    self.player.controlView = self.controlView;
    self.player.playerViewTag = 100;
    self.player.assetURLs = self.urls;
    
    __weak typeof(self) _self = self;
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        __strong typeof(_self) self = _self;
        if (self.player.playingIndexPath.row < self.urls.count - 1 && !self.player.isFullScreen) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.player.playingIndexPath.row+1 inSection:0];
            [self playTheVideoAtIndexPath:indexPath];
            [self.tableView zf_scrollToRowAtIndexPath:indexPath];
        } else if (self.player.isFullScreen) {
            [self.player enterFullScreen:NO animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.player.orientationObserver.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player stopCurrentPlayingCell];
            });
        }
    };
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat h = CGRectGetMaxY(self.view.frame);
    self.tableView.frame = CGRectMake(0, y, self.view.frame.size.width, h-y);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    __weak typeof(self) _self = self;
    [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        __strong typeof(_self) self = _self;
         [self playTheVideoAtIndexPath:indexPath];
    }];
    ZFTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.shouldPlayIndexPath];
    [cell hideMaskView];
    
    __weak typeof(self) weakSelf = self;
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        [weakSelf.view endEditing:YES];
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    };
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
        ZFTableViewCellLayout *layout = [[ZFTableViewCellLayout alloc] initWithData:data];
        [self.dataSource addObject:layout];
        NSURL *url = [NSURL URLWithString:data.video_url];
        [self.urls addObject:url];
    }
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    cell.layout = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView zf_scrollToRowAtIndexPath:indexPath];
    [self playTheVideoAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFTableViewCellLayout *layout = self.dataSource[indexPath.row];
    return layout.height;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    __weak typeof(self) _self = self;
    [scrollView zf_filterShouldPlayCellWhileScrolling:^(NSIndexPath *indexPath) {
        if ([indexPath compare:self.tableView.shouldPlayIndexPath] != NSOrderedSame) {
            __strong typeof(_self) self = _self;
            /// 显示黑色蒙版
            ZFTableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:self.tableView.shouldPlayIndexPath];
            [cell1 showMaskView];
            /// 隐藏黑色蒙版
            ZFTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell hideMaskView];
        }
    }];
}

/**
 * 松手时已经静止, 只会调用scrollViewDidEndDragging
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // scrollView已经完全静止
    if (!decelerate) {
        [self scrollDidStoppedToPlay];
    }
}

/**
 * 松手时还在运动, 先调用scrollViewDidEndDragging, 再调用scrollViewDidEndDecelerating
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollDidStoppedToPlay];
}

/**
 当点击状态栏滑动顶部时候调用
 */
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self scrollDidStoppedToPlay];
}


- (void)scrollDidStoppedToPlay {
    /// 停止的时候找出最合适的播放
    __weak typeof(self) _self = self;
    [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        __strong typeof(_self) self = _self;
        [self playTheVideoAtIndexPath:indexPath];
    }];
}

- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self.player playTheIndexPath:indexPath];
    ZFTableViewCellLayout *layout = self.dataSource[indexPath.row];
    [self.controlView resetControlView];
    [self.controlView showTitle:layout.data.title
                 coverURLString:layout.data.thumbnail_url
                 fullScreenMode:layout.isVerticalVideo?ZFFullScreenModePortrait:ZFFullScreenModeLandscape];
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[ZFTableViewCell class] forCellReuseIdentifier:kIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.separatorColor = [UIColor darkGrayColor];
        [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [[UITableView appearance] setSeparatorInset:UIEdgeInsetsZero];
        [[UITableViewCell appearance] setSeparatorInset:UIEdgeInsetsZero];
        if ([UITableView instancesRespondToSelector:@selector(setLayoutMargins:)]) {
            [[UITableView appearance] setLayoutMargins:UIEdgeInsetsZero];
            [[UITableViewCell appearance] setLayoutMargins:UIEdgeInsetsZero];
            [[UITableViewCell appearance] setPreservesSuperviewLayoutMargins:NO];
        }
    }
    return _tableView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

@end
