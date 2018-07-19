//
//  ZFScrollViewController.m
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/7/19.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFScrollViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/KSMediaPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import "ZFTableData.h"
#import "ZFDouYinScrollView.h"

@interface ZFScrollViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) ZFDouYinScrollView *scrollView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *urls;

@end

@implementation ZFScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self requestData];
    
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];

    /// player的tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.scrollView playerManager:playerManager containerViewTag:100];
    self.player.assetURLs = self.urls;
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
//    self.player.controlView = self.controlView;
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    /// 1.0是完全消失时候
    self.player.playerDisapperaPercent = 1.0;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
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


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset_y = scrollView.contentOffset.y;
    
    if (offset_y > (self.scrollView.frame.size.height * (self.dataSource.count - 1))) {
//        if (self.isLoading) {
//            return;
//        }
        NSLog(@"拉到底部了");
        
//        self.isLoading = YES;
//        [self.dataDelegate pullNewData]; //如果拉到了底部，则去拉取新数据
        return;
    }
   
//    if (self.currentIndexOfImageView > self.dataArray.count - 1) {
//        return;
//    }
    
    
    /// 向上滑动
    if (scrollView.zf_scrollDerection == ZFPlayerScrollDerectionUp) {
        
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height * self.dataSource.count);
}

- (ZFDouYinScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[ZFDouYinScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}


@end
