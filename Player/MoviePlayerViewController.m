//
//  MoviePlayerViewController.m
//  Player
//
//  Created by 任子丰 on 15/11/7.
//  Copyright © 2015年 任子丰. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved
};

@interface MoviePlayerViewController ()
{
    PanDirection panDirection; // 定义一个实例变量，保存枚举值
    CGFloat sumTime; // 用来保存快进的总时长
}
@property(nonatomic,strong)AVPlayer *player; // 播放属性
@property(nonatomic,strong)AVPlayerItem *playerItem; // 播放属性
@property(nonatomic,assign)CGFloat width; // 坐标
@property(nonatomic,assign)CGFloat height; // 坐标
@property(nonatomic,strong)UISlider *slider; // 进度条
@property(nonatomic,strong)UILabel *currentTimeLabel; // 当前播放时间
@property(nonatomic,strong)UILabel *systemTimeLabel; // 系统时间
@property(nonatomic,strong)UIView *backView; // 上面一层Viewd
@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,strong)UISlider *volumeViewSlider;
@property(nonatomic,strong)UIActivityIndicatorView *activity; // 系统菊花
@property(nonatomic,strong)UIProgressView *progress; // 缓冲条
@property(nonatomic,strong)UIView *topView;
@property (nonatomic, strong) UILabel *horizontalLabel; // 水平滑动时显示进度

@end

@implementation MoviePlayerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _width = [[UIScreen mainScreen]bounds].size.height;
    _height = [[UIScreen mainScreen]bounds].size.width;
    // 创建AVPlayer
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoURL]];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = CGRectMake(0, 0, _width, _height);
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:playerLayer];
    [_player play];
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _width, _height)];
    [self.view addSubview:_backView];
    _backView.backgroundColor = [UIColor clearColor];
    
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _width, _height * 0.15)];
    _topView.backgroundColor = [UIColor blackColor];
    _topView.alpha = 0.5;
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
    _activity.center = _backView.center;
    [self.view addSubview:_activity];
    [_activity startAnimating];
    
    //延迟线程
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5 animations:^{
            
            _backView.alpha = 0;
        }];
        
    });
    
    //计时器
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(Stack) userInfo:nil repeats:YES];
//    self.modalPresentationCapturesStatusBarAppearance = YES;
    
}
#pragma mark - 横屏代码
- (BOOL)shouldAutorotate{
    return NO;
} //NS_AVAILABLE_IOS(6_0);当前viewcontroller是否支持转屏

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscape;
} //当前viewcontroller支持哪些转屏方向

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden
{
    return NO; // 返回NO表示要显示，返回YES将hiden
}
#pragma mark - 创建UISlider
- (void)createSlider
{
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(100, _height-30, _width*0.7, 15)];
    [self.backView addSubview:_slider];
    [_slider setThumbImage:[UIImage imageNamed:@"iconfont-yuan.png"] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    _slider.minimumTrackTintColor = [UIColor colorWithRed:30 / 255.0 green:80 / 255.0 blue:100 / 255.0 alpha:1];
    
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
    
//    NSLog(@"dragedSeconds:%ld",dragedSeconds);
    
    //转换成CMTime才能给player来控制播放进度
    
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    
    [_player pause];
    
    [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
        
        [_player play];
        
    }];
    
    }
}
#pragma mark - 创建UIProgressView
- (void)createProgress
{
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(102, _height-23, _width*0.69, 15)];
    [_backView addSubview:_progress];
}
#pragma mark -
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

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
- (void)customVideoSlider {
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
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
    } else {
        [_activity startAnimating];
    }
    
}
#pragma mark - 播放和下一首按钮
- (void)createButton
{
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(15, _height-38, 30, 30);
    [self.backView addSubview:startButton];
    if (_player.rate == 1.0) {
    
    [startButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    } else {
        [startButton setBackgroundImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];

    }
    [startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(60, _height-35, 25, 25);
    [self.backView addSubview:nextButton];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"nextPlayer@3x.png"] forState:UIControlStateNormal];
    
    
}
#pragma mark - 播放暂停按钮方法
- (void)startAction:(UIButton *)button
{
    if (button.selected) {
        [_player play];
        [button setBackgroundImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];

    } else {
        [_player pause];
        [button setBackgroundImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];

    }
    button.selected =!button.selected;
    
}
#pragma mark - 返回按钮方法
- (void)backButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(15, 20, 30, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"iconfont-back.png"] forState:UIControlStateNormal];
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
    self.horizontalLabel.backgroundColor = [UIColor blackColor];
    self.horizontalLabel.alpha = 0.6;
    self.horizontalLabel.textAlignment = NSTextAlignmentCenter;
    self.horizontalLabel.text = @"<< 00:00 / --:--";
    // 一上来先隐藏
    self.horizontalLabel.hidden = YES;
    [self.view addSubview:_horizontalLabel];
}
#pragma mark - 创建手势
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];

    //获取系统音量
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 添加平移手势，用来控制音量和快进快退
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    [self.view addGestureRecognizer:pan];
}
#pragma mark - 轻拍方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (_backView.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            
            _backView.alpha = 0;
        }];
    } else if (_backView.alpha == 0){
        [UIView animateWithDuration:0.5 animations:^{
            
            _backView.alpha = 1;
        }];
    }
    if (_backView.alpha == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _backView.alpha = 0;
            }];
            
        });

    }
}
#pragma mark - 滑动调整音量大小
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if(event.allTouches.count == 1){
//        //保存当前触摸的位置
//        CGPoint point = [[touches anyObject] locationInView:self.view];
//        _startPoint = point;
//    }
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    if(event.allTouches.count == 1){
//        //计算位移
//        CGPoint point = [[touches anyObject] locationInView:self.view];
//        //        float dx = point.x - startPoint.x;
//        float dy = point.y - _startPoint.y;
//        int index = (int)dy;
//        if(index>0){
//            if(index%5==0){//每10个像素声音减一格
//                NSLog(@"%.2f",_systemVolume);
//                if(_systemVolume>0.1){
//                    _systemVolume = _systemVolume-0.05;
//                    [_volumeViewSlider setValue:_systemVolume animated:YES];
//                    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }
//            }
//        }else{
//            if(index%5==0){//每10个像素声音增加一格
//                NSLog(@"+x ==%d",index);
//                NSLog(@"%.2f",_systemVolume);
//                if(_systemVolume>=0 && _systemVolume<1){
//                    _systemVolume = _systemVolume+0.05;
//                    [_volumeViewSlider setValue:_systemVolume animated:YES];
//                    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }
//            }
//        }
//        //亮度调节
//        //        [UIScreen mainScreen].brightness = (float) dx/self.view.bounds.size.width;
//    }
//}


- (void)moviePlayDidEnd:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)backButtonAction
{
    [_player pause];
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - 平移手势方法
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self.view];
    
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
                    // 隐藏视图
                    self.horizontalLabel.hidden = YES;
                    
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
