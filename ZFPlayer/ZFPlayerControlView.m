//
//  ZFPlayerControlView.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerControlView.h"
#import <Masonry/Masonry.h>
#import "ZFPlayer.h"

@interface ZFPlayerControlView ()
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView          *progressView;
/** 滑杆 */
@property (nonatomic, strong) UISlider                *videoSlider;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong) UIButton                *lockBtn;
/** 快进快退label */
@property (nonatomic, strong) UILabel                 *horizontalLabel;
/** 系统菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *activity;
/** 返回按钮*/
@property (nonatomic, strong) UIButton                *backBtn;
/** 重播按钮 */
@property (nonatomic, strong) UIButton                *repeatBtn;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *bottomImageView;
/** topView */
@property (nonatomic, strong) UIImageView             *topImageView;

@end

@implementation ZFPlayerControlView

- (void)dealloc
{
    //NSLog(@"%@释放了",self.class);
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self addSubview:self.lockBtn];
        [self addSubview:self.topImageView];
        [self addSubview:self.bottomImageView];
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.progressView];
        [self.bottomImageView addSubview:self.videoSlider];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        
        [self addSubview:self.backBtn];
        [self addSubview:self.activity];
        [self addSubview:self.repeatBtn];
        [self addSubview:self.horizontalLabel];
        // 添加子控件的约束
        [self makeSubViewsConstraints];
        
        [self.activity stopAnimating];
        self.horizontalLabel.hidden = YES;
        self.repeatBtn.hidden = YES;
    }
    return self;
}

- (void)makeSubViewsConstraints
{
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(5);
        make.width.height.mas_equalTo(30);
        make.bottom.mas_equalTo(-5);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing).offset(2);
        make.centerY.equalTo(self.startBtn);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.mas_equalTo(-5);
        make.centerY.equalTo(self.startBtn);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.mas_leading).offset(-2);
        make.centerY.equalTo(self.startBtn);;
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(8);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-8);
        make.centerY.equalTo(self.startBtn);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(8);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-8);
        make.centerY.equalTo(self.currentTimeLabel).offset(-0.25);
    }];
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(0);
    }];

    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.top.mas_equalTo(5);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.horizontalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
    }];
    
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.center.equalTo(self);
    }];
}


#pragma mark - Public Method

/** 重置ControlView */
- (void)resetControlView
{
    self.videoSlider.value = 0;
    self.progressView.progress = 0;
    self.currentTimeLabel.text = @"00:00";
    self.totalTimeLabel.text = @"00:00";
}

- (void)showControlView
{
    self.topImageView.alpha = 1;
    self.bottomImageView.alpha = 1;
    self.lockBtn.alpha = 1;
}

- (void)hideControlView
{
    self.topImageView.alpha = 0;
    self.bottomImageView.alpha = 0;
    self.lockBtn.alpha = 0;
}

#pragma mark - getter

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"play_back_full")] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        _topImageView.image = [UIImage imageNamed:ZFPlayerSrcName(@"top_shadow")];
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView
{
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        _bottomImageView.image = [UIImage imageNamed:ZFPlayerSrcName(@"bottom_shadow")];
    }
    return _bottomImageView;
}

- (UIButton *)lockBtn
{
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"unlock-nor")] forState:UIControlStateNormal];
        [_lockBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"lock-nor")] forState:UIControlStateSelected];
    }
    return _lockBtn;
}

- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-play")] forState:UIControlStateNormal];
        [_startBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-pause")] forState:UIControlStateSelected];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _currentTimeLabel;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progress = .0f;
        _progressView.progressTintColor    = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        _progressView.trackTintColor       = [UIColor clearColor];
    }
    return _progressView;
}

- (UISlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider = [[UISlider alloc] init];
        // 设置slider
        [_videoSlider setThumbImage:[UIImage imageNamed:ZFPlayerSrcName(@"slider")] forState:UIControlStateNormal];
        
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6];
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.text = @"00:00";
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12.0f];
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-fullscreen")] forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}

- (UILabel *)horizontalLabel
{
    if (!_horizontalLabel) {
        _horizontalLabel = [[UILabel alloc] init];
        _horizontalLabel.textColor = [UIColor whiteColor];
        _horizontalLabel.textAlignment = NSTextAlignmentCenter;
        // 设置快进快退label
        _horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:ZFPlayerSrcName(@"Management_Mask")]];
    }
    return _horizontalLabel;
}

- (UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

- (UIButton *)repeatBtn
{
    if (!_repeatBtn) {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"repeat_video")] forState:UIControlStateNormal];
    }
    return _repeatBtn;
}

@end
