//
//  ZFPlayerView.m
//  Player
//
//  Created by 任子丰 on 16/3/3.
//  Copyright © 2016年 zhaoqingwen. All rights reserved.
//

#import "ZFPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MSWeakTimer/MSWeakTimer.h>
#import "ZFPlayerMaskView.h"
#import <Masonry/Masonry.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};

@interface ZFPlayerView ()

/** 播放属性 */
@property (nonatomic, strong) AVPlayer *player;
/** 播放属性 */
@property (nonatomic, strong) AVPlayerItem *playerItem;
/** playerLayer */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
/** 滑杆 */
@property (nonatomic, strong) UISlider *volumeViewSlider;
/** 计时器 */
@property (nonatomic, strong) MSWeakTimer *timer;
/** 蒙版View */
@property (nonatomic, strong) ZFPlayerMaskView *maskView;
/**  用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat sumTime;
/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) PanDirection panDirection;

@end

@implementation ZFPlayerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.timer invalidate];
}

-(void)layoutSubviews
{
    NSLog(@"layoutSubviews");
    self.playerLayer.frame = self.bounds;
}


-(void)setVideoURL:(NSURL *)videoURL
{
    // 创建AVPlayer
//    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"150511_JiveBike" withExtension:@"mov"];
//    NSURL *URL = [NSURL URLWithString:videoURL];
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];

    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:self.playerLayer];
    [_player play];
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    self.maskView = [ZFPlayerMaskView setupPlayerMaskView];
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    if (self.player.rate == 1.0) {
        [self.maskView.startBtn setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
    } else {
        [self.maskView.startBtn setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
    }

    // slider 滑动事件
    [self.maskView.videoSlider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    // 播放按钮点击事件
    [self.maskView.startBtn addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    // 返回按钮
    [self.maskView.backBtn addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];

    
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    
    [self createGesture];
    
    [self.maskView.activity startAnimating];
    
    //延迟线程
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    });
    
    //计时器
    self.timer =[MSWeakTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(Stack)
                                                   userInfo:nil
                                                    repeats:YES
                                              dispatchQueue:dispatch_get_main_queue()];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        //        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.maskView.progressView setProgress:timeInterval / totalDuration animated:NO];
    }
}

#pragma mark - 计时器事件
- (void)Stack
{
    if (_playerItem.duration.timescale != 0) {
        
        self.maskView.videoSlider.maximumValue = 1;//音乐总共时长
        self.maskView.videoSlider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度
        
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        
        //duration 总时长
        NSInteger durMin = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟
        
        self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        self.maskView.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
    if (_player.status == AVPlayerStatusReadyToPlay) {
        [self.maskView.activity stopAnimating];
        // 加载完成后，再添加拖拽手势
        // 添加平移手势，用来控制音量和快进快退
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        [self addGestureRecognizer:pan];
    } else {
        [self.maskView.activity startAnimating];
    }
    
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 播放暂停按钮方法
- (void)startAction:(UIButton *)button
{
    if (button.selected) {
        [_player play];
        [button setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
        
    } else {
        [_player pause];
        [button setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        
    }
    button.selected =!button.selected;
}

#pragma mark - 创建手势

- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    
    [self addGestureRecognizer:tap];
    
    //获取系统音量
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

#pragma mark - slider滑动事件

- (void)progressSlider:(UISlider *)slider
{
    //拖动改变视频播放进度
    if (_player.status == AVPlayerStatusReadyToPlay) {
        
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        
        //    NSLog(@"%f", total);
        
        NSInteger dragedSeconds = floorf(total * slider.value);
        
        //        // 取消隐藏
        //        self.horizontalLabel.hidden = NO;
        //        // 模拟点击
        //        [self tapAction];
        //        [self horizontalMoved:slider.value];
        //    NSLog(@"dragedSeconds:%ld",dragedSeconds);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        [_player pause];
        
        [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
            
            [_player play];
            
        }];
        
    }
}

#pragma mark - 轻拍方法

- (void)tapAction
{
    if (self.maskView.alpha == 0){
        [UIView animateWithDuration:0.5 animations:^{
            
            self.maskView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }];
    }
    if (self.maskView.alpha == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                
                self.maskView.alpha = 0;
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }];
            
        });
        
    }
}

- (void)moviePlayDidEnd:(id)sender
{
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}

- (void)backButtonAction
{
    [_player pause];
    if (self.goBackBlock) {
        self.goBackBlock();
    }
}

#pragma mark - 平移手势方法
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            NSLog(@"x:%f  y:%f",veloctyPoint.x, veloctyPoint.y);
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.panDirection = PanDirectionHorizontalMoved;
                // 取消隐藏
                self.maskView.horizontalLabel.hidden = NO;
                // 模拟点击
                [self tapAction];
                // 给sumTime初值
                CMTime time = self.player.currentTime;
                self.sumTime = time.value/time.timescale;
                NSLog(@"===%f",self.sumTime);
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 显示音量控件
                
                // 开始滑动的时候，状态改为正在控制音量
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        // 隐藏视图
                        self.maskView.horizontalLabel.hidden = YES;
                    });
                    
                    //转换成CMTime才能给player来控制播放进度
                    
                    CMTime dragedCMTime = CMTimeMake(self.sumTime, 1);
                    
                    [_player pause];
                    
                    [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
                        // ⚠️在滑动结束后，视屏要跳转
                        [_player play];
                        
                    }];
                    
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，隐藏音量控件
                    // 且，把状态改为不再控制音量
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - pan垂直移动的方法
- (void)verticalMoved:(CGFloat)value
{
    // 更改系统的音量
    self.volumeViewSlider.value -= value / 10000; // 越小幅度越小
    //亮度
    //[UIScreen mainScreen].brightness = 10;
}

#pragma mark - pan水平移动的方法
- (void)horizontalMoved:(CGFloat)value
{
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) {
        style = @"<<";
    }
    else if (value > 0){
        style = @">>";
    }
    
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) {
        self.sumTime = totalMovieDuration;
    }else if (self.sumTime < 0){
        self.sumTime = 0;
    }
    
    // 当前快进的时间
    NSString *nowTime = [self durationStringWithTime:(int)self.sumTime];
    // 总时间
    NSString *durationTime = [self durationStringWithTime:(int)totalMovieDuration];
    // 给label赋值
    self.maskView.horizontalLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",style, nowTime, durationTime];
    
    
}

#pragma mark - 根据时长求出字符串
- (NSString *)durationStringWithTime:(int)time
{
    // 获取分钟
    NSString *min = [NSString stringWithFormat:@"%02d",time / 60];
    // 获取秒数
    NSString *sec = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@", min, sec];
}



@end
