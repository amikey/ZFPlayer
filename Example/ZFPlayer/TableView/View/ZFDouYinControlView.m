//
//  ZFDouYinControlView.m
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/6/4.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFDouYinControlView.h"
#import <ZFPlayer/UIView+ZFFrame.h>
#import <ZFPlayer/UIImageView+ZFCache.h>
#import <ZFPlayer/ZFUtilities.h>
#import "ZFLoadingView.h"

@interface ZFDouYinControlView ()
/// 封面图
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIButton *playBtn;

/// 加载loading
@property (nonatomic, strong) ZFLoadingView *activity;

@end

@implementation ZFDouYinControlView
@synthesize player = _player;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.activity];
        [self addSubview:self.playBtn];
        [self resetControlView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.coverImageView.frame = self.player.currentPlayerManager.view.bounds;
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    
    min_w = 44;
    min_h = 44;
    self.activity.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.activity.center = self.center;
    
    min_w = 44;
    min_h = 44;
    self.playBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.playBtn.center = self.center;
}

- (void)resetControlView {
    self.playBtn.hidden = YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state {
    if (state == ZFPlayerLoadStatePrepare) {
        self.coverImageView.hidden = NO;
    } else if (state == ZFPlayerLoadStatePlaythroughOK) {
        self.coverImageView.hidden = YES;
    }
    if (state == ZFPlayerLoadStateStalled || state == ZFPlayerLoadStatePrepare) {
        [self.activity startAnimating];
    } else {
        [self.activity stopAnimating];
    }
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    if (self.player.currentPlayerManager.isPlaying) {
        [self.player.currentPlayerManager pause];
         self.playBtn.hidden = NO;
    } else {
        [self.player.currentPlayerManager play];
        self.playBtn.hidden = YES;
    }
}

- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
    [player.currentPlayerManager.view insertSubview:self.coverImageView atIndex:0];
}

- (void)showCoverViewWithUrl:(NSString *)coverUrl {
    [self.coverImageView setImageWithURLString:coverUrl placeholder:[UIImage imageNamed:@"loading_bgView"]];
}

- (ZFLoadingView *)activity {
    if (!_activity) {
        _activity = [[ZFLoadingView alloc] init];
        _activity.lineWidth = 0.8;
        _activity.duration = 1;
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.userInteractionEnabled = NO;
        [_playBtn setImage:[UIImage imageNamed:@"new_allPlay_44x44_"] forState:UIControlStateNormal];
    }
    return _playBtn;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.backgroundColor = [UIColor blackColor];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

@end
