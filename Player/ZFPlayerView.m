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

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};

@interface ZFPlayerView ()
{
    PanDirection panDirection; // 定义一个实例变量，保存枚举值
    CGFloat sumTime; // 用来保存快进的总时长
}
@property(nonatomic,strong)AVPlayer *player; // 播放属性
@property(nonatomic,strong)AVPlayerItem *playerItem; // 播放属性
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic,assign)CGFloat width; // 坐标
@property(nonatomic,assign)CGFloat height; // 坐标
@property(nonatomic,strong)UISlider *slider; // 进度条
@property(nonatomic,strong)UILabel *currentTimeLabel; // 当前播放时间
@property (nonatomic, strong) UIButton *startButton; //开始按钮
@property (nonatomic, strong) UIButton *nextButton; //下一个按钮
@property(nonatomic,strong)UILabel *systemTimeLabel; // 系统时间
@property(nonatomic,strong)UIView *backView; // 上面一层Viewd
@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,strong)UISlider *volumeViewSlider;
@property(nonatomic,strong)UIActivityIndicatorView *activity; // 系统菊花
@property(nonatomic,strong)UIProgressView *progress; // 缓冲条
@property(nonatomic,strong)UIImageView *topView;
@property(nonatomic,strong) UILabel *horizontalLabel; // 水平滑动时显示进度

@property (nonatomic, strong) MSWeakTimer *timer;
@end

@implementation ZFPlayerView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.timer invalidate];
}

- (void)setFrames:(CGRect)frames
{
    self.frame = frames;
    CGFloat width = frames.size.width;
    CGFloat height = frames.size.height;
    self.playerLayer.frame = frames;
    self.backView.frame = frames;
    self.topView.frame = CGRectMake(0, 0, width, height * 0.15);
    self.progress.frame = CGRectMake(102, height-23, width*0.69, 15);
    self.slider.frame = CGRectMake(100, height-30, width*0.7, 15);
    self.currentTimeLabel.frame = CGRectMake(width *0.86, height-32, 100, 20);
    self.startButton.frame = CGRectMake(15, height-38, 30, 30);
    self.nextButton.frame = CGRectMake(60, height-35, 25, 25);
    self.horizontalLabel.frame = CGRectMake(width/2-80, height / 2 + 20, 160, 40);
    self.activity.center = self.backView.center;
}

- (instancetype)initWithFrame:(CGRect)frame URL:(NSString *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        _width = [[UIScreen mainScreen]bounds].size.height;
        _height = [[UIScreen mainScreen]bounds].size.width;
        // 创建AVPlayer
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        self.player = [AVPlayer playerWithPlayerItem:_playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//        self.playerLayer.frame = CGRectMake(0, 0, width, height);
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer addSublayer:self.playerLayer];
        [_player play];
        //AVPlayer播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        
        self.backView = [[UIView alloc] init];
        [self addSubview:_backView];
        _backView.backgroundColor = [UIColor clearColor];
        
        self.topView = [[UIImageView alloc] init];
        self.topView.image = [UIImage imageNamed:@"News_Image_Mask"];
        self.topView.userInteractionEnabled = YES;
        [_backView addSubview:_topView];
        
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
        
        [self createProgress];
        [self createSlider];
        [self createCurrentTimeLabel];
        [self createButton];
        [self backButton];
        [self createTitle];
        [self createHorizontal];
        [self createGesture];
        
        [self customVideoSlider];
        
        self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activity.center = _backView.center;
        [self addSubview:_activity];
        [_activity startAnimating];
        
        //延迟线程
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                _backView.alpha = 0;
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }];
        });
        
        //计时器
//        self.timer =[NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(Stack) userInfo:nil repeats:YES];
        self.timer =[MSWeakTimer scheduledTimerWithTimeInterval:1.0f
                                                         target:self
                                                       selector:@selector(Stack)
                                                       userInfo:nil
                                                        repeats:YES
                                                  dispatchQueue:dispatch_get_main_queue()];
    }
    return self;

}

#pragma mark - 创建UISlider
- (void)createSlider
{
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(100, _height-30, _width*0.7, 15)];
    [self.backView addSubview:_slider];
    [_slider setThumbImage:[UIImage imageNamed:@"iconfont-yuanquan-2"] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    _slider.minimumTrackTintColor = [UIColor colorWithRed:30 / 255.0 green:80 / 255.0 blue:100 / 255.0 alpha:1];
}

#pragma mark - 创建UIProgressView
- (void)createProgress
{
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(102, _height-23, _width*0.69, 15)];
    self.progress.progressTintColor = [UIColor whiteColor];
    self.progress.trackTintColor = [UIColor grayColor];
    [_backView addSubview:_progress];
}

- (void)customVideoSlider {
    UIGraphicsBeginImageContextWithOptions((CGSize){ .7, .7 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //设置slider
    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

#pragma mark - 播放和下一首按钮

- (void)createButton
{
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startButton.frame = CGRectMake(15, _height-38, 30, 30);
    [self.backView addSubview:self.startButton];
    if (_player.rate == 1.0) {
        [self.startButton setImage:[UIImage imageNamed:@"kr-video-player-pause"] forState:UIControlStateNormal];
    } else {
        [self.startButton setImage:[UIImage imageNamed:@"kr-video-player-play"] forState:UIControlStateNormal];
        
    }
    [self.startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.frame = CGRectMake(60, _height-35, 25, 25);
    [self.backView addSubview:self.nextButton];
    [self.nextButton setImage:[UIImage imageNamed:@"nextPlayer.png"] forState:UIControlStateNormal];
    
}

#pragma mark - 创建播放时间
- (void)createCurrentTimeLabel
{
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_width *0.86, _height-32, 100, 20)];
    [self.backView addSubview:_currentTimeLabel];
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font = [UIFont systemFontOfSize:12];
    _currentTimeLabel.text = @"00:00/00:00";
    
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        //        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:NO];
    }
}


#pragma mark - 计时器事件
- (void)Stack
{
    if (_playerItem.duration.timescale != 0) {
        
        _slider.maximumValue = 1;//音乐总共时长
        _slider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度
        
        //当前时长进度progress
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        //    NSLog(@"%d",_playerItem.duration.timescale);
        //    NSLog(@"%lld",_playerItem.duration.value/1000 / 60);
        
        //duration 总时长
        
        NSInteger durMin = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", proMin, proSec, durMin, durSec];
    }
    if (_player.status == AVPlayerStatusReadyToPlay) {
        [_activity stopAnimating];
        // 加载完成后，再添加拖拽手势
        // 添加平移手势，用来控制音量和快进快退
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        [self addGestureRecognizer:pan];
    } else {
        [_activity startAnimating];
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
#pragma mark - 返回按钮方法
- (void)backButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(15, 20, 25, 25);
    [button setImage:[UIImage imageNamed:@"gobackBtn"] forState:UIControlStateNormal];
    [_topView addSubview:button];
    [button addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 创建标题
- (void)createTitle
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(80, 20, 250, 30)];
    [_backView addSubview:label];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)createHorizontal {
    // 水平滑动显示的进度label
    self.horizontalLabel = [[UILabel alloc]initWithFrame:CGRectMake(_width/2-80, _height / 2 + 20, 160, 40)];
    self.horizontalLabel.textColor = [UIColor whiteColor];
    self.horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Management_Mask"]];
    self.horizontalLabel.textAlignment = NSTextAlignmentCenter;
    self.horizontalLabel.text = @">> 00:00 / --:--";
    // 一上来先隐藏
    self.horizontalLabel.hidden = YES;
    [self.backView addSubview:_horizontalLabel];
    
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
    if (_backView.alpha == 0){
        [UIView animateWithDuration:0.5 animations:^{
            
            _backView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }];
    }
    if (_backView.alpha == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _backView.alpha = 0;
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }];
            
        });
        
    }
}

- (void)moviePlayDidEnd:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:^{}];
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
//    [self dismissViewControllerAnimated:YES completion:^{}];
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
                panDirection = PanDirectionHorizontalMoved;
                // 取消隐藏
                self.horizontalLabel.hidden = NO;
                // 模拟点击
                [self tapAction];
                // 给sumTime初值
                CMTime time = self.player.currentTime;
                sumTime = time.value/time.timescale;
                NSLog(@"===%f",sumTime);
            }
            else if (x < y){ // 垂直移动
                panDirection = PanDirectionVerticalMoved;
                // 显示音量控件
                
                // 开始滑动的时候，状态改为正在控制音量
                
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (panDirection) {
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
            switch (panDirection) {
                case PanDirectionHorizontalMoved:{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        // 隐藏视图
                        self.horizontalLabel.hidden = YES;
                    });
                    
                    //转换成CMTime才能给player来控制播放进度
                    
                    CMTime dragedCMTime = CMTimeMake(sumTime, 1);
                    
                    [_player pause];
                    
                    [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
                        // ⚠️在滑动结束后，视屏要跳转
                        [_player play];
                        
                    }];
                    
                    // 把sumTime滞空，不然会越加越多
                    sumTime = 0;
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
    sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (sumTime > totalMovieDuration) {
        sumTime = totalMovieDuration;
    }else if (sumTime < 0){
        sumTime = 0;
    }
    
    // 当前快进的时间
    NSString *nowTime = [self durationStringWithTime:(int)sumTime];
    // 总时间
    NSString *durationTime = [self durationStringWithTime:(int)totalMovieDuration];
    // 给label赋值
    self.horizontalLabel.text = [NSString stringWithFormat:@"%@ %@ / %@",style, nowTime, durationTime];
    
    
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
