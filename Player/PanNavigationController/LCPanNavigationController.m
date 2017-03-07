//
//  LCPanNavigationController.m
//  PanBackDemo
//
//  Created by clovelu on 5/30/14.
//
//

#import "LCPanNavigationController.h"
#import "LCPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UIView+Snapshot.h"
#import <objc/runtime.h>

#define SYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
// 屏幕的宽
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

static const NSString *contentImageKey  = @"contentImageKey";
static const NSString *barImageKey      = @"barImageKey";
static const NSString *contentFrameKey  = @"contentFrameKey";

typedef void (^_FDViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (FDFullscreenPopGesturePrivate)

@property (nonatomic, copy) _FDViewControllerWillAppearInjectBlock fd_willAppearInjectBlock;

@end

@implementation UIViewController (FDFullscreenPopGesturePrivate)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(fd_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)fd_viewWillAppear:(BOOL)animated
{
    // Forward to primary implementation.
    [self fd_viewWillAppear:animated];

    if (self.fd_willAppearInjectBlock) {
        self.fd_willAppearInjectBlock(self, animated);
    }
}

- (_FDViewControllerWillAppearInjectBlock)fd_willAppearInjectBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setFd_willAppearInjectBlock:(_FDViewControllerWillAppearInjectBlock)block
{
    objc_setAssociatedObject(self, @selector(fd_willAppearInjectBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


@interface LCPanNavigationController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) LCPanGestureRecognizer *pan;
@property (strong, nonatomic) NSMutableArray *shotStack;

@property (strong, nonatomic) UIImageView *previousMirrorView;
@property (strong, nonatomic) UIImageView *previousBarMirrorView;
@property (strong, nonatomic) UIView *previousOverLayView;
@property (assign, nonatomic) BOOL animatedFlag;

@property (readonly, nonatomic) UIView *controllerWrapperView;
@property (weak, nonatomic) UIView *barBackgroundView;
@property (weak, nonatomic) UIView *barBackIndicatorView;

@property (assign, nonatomic) CGFloat showViewOffsetScale;
@property (assign, nonatomic) CGFloat showViewOffset;

@property (nonatomic, assign) CGFloat lastOffset;

@end

@implementation LCPanNavigationController

- (void)fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController
{
    if (!self.zf_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _FDViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setNavigationBarHidden:viewController.zf_prefersNavigationBarHidden animated:animated];
        }
    };
    
    appearingViewController.fd_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.fd_willAppearInjectBlock) {
        disappearingViewController.fd_willAppearInjectBlock = block;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allowPopMaxOffset = 120;
    self.zf_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    if (SYSTEM_VERSION >= 7) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    _pan = [[LCPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    _pan.delegate = self;
    _pan.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:_pan];
    
    _shotStack = [NSMutableArray array];
    _previousMirrorView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _previousMirrorView.backgroundColor = [UIColor clearColor];
    
    _previousOverLayView = [[UIView alloc] initWithFrame:_previousMirrorView.bounds];
    _previousOverLayView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _previousOverLayView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [_previousMirrorView addSubview:_previousOverLayView];
    
    
    _previousBarMirrorView = [[UIImageView alloc] initWithFrame:self.navigationBar.bounds];
    _previousBarMirrorView.backgroundColor = [UIColor clearColor];
    
    self.showViewOffsetScale = 1 / 3.0;
    self.showViewOffset = self.showViewOffsetScale * self.view.frame.size.width;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *previousViewController = [self.viewControllers lastObject];
    
    if (previousViewController) {
        UIView *snapshotView = [UIApplication sharedApplication].keyWindow;
        [self contentImageSnapshot:snapshotView];
    }
    // Handle perferred navigation bar appearance.
    [self fd_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    // 动画标识，在动画的情况下，禁掉右滑手势
    [self startAnimated:animated];
    
    [super pushViewController:viewController animated:animated];
}

- (void)contentImageSnapshot:(UIView *)snapshot {
    NSMutableDictionary *shotInfo = [NSMutableDictionary dictionary];
    UIImage *barImage = [self barSnapshot];
    UIImage *contentImage = [snapshot snapshot];
    shotInfo[contentImageKey] = contentImage;
    shotInfo[barImageKey] = barImage;
    shotInfo[contentFrameKey] = [NSValue valueWithCGRect:snapshot.frame];
    [self.shotStack addObject:shotInfo];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
{
    [self.shotStack removeLastObject];
    
    [self startAnimated:animated];
    
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    // TODO: shotStack handle
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    [self.shotStack removeAllObjects];
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark -
#pragma mark Pan

- (void)pan:(UIPanGestureRecognizer *)pan
{
    UIGestureRecognizerState state = pan.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            self.lastOffset = 0;
            NSDictionary *shotInfo = [self.shotStack lastObject];
            UIImage *contentImage = shotInfo[contentImageKey];
            UIImage *barImage = shotInfo[barImageKey];
            CGRect rect = [shotInfo[contentFrameKey] CGRectValue];
            
            self.previousMirrorView.image = contentImage;
            self.previousMirrorView.frame = rect;
            self.previousMirrorView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0);
            [self.controllerWrapperView insertSubview:self.previousMirrorView belowSubview:self.visibleViewController.view];
            
            self.previousOverLayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
            
            self.previousBarMirrorView.image = barImage;
            self.previousBarMirrorView.frame = self.navigationBar.bounds;
            self.previousBarMirrorView.alpha = 0;
            [self.navigationBar addSubview:self.previousBarMirrorView];
            [self startPanBack];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            CGPoint translationPoint = [self.pan translationInView:self.view];

            if (translationPoint.x < 0) translationPoint.x = 0;
            
            CGFloat k = translationPoint.x / ScreenWidth;
            self.lastOffset = translationPoint.x;
            [self barTransitionWithAlpha:1 - k];
            self.previousBarMirrorView.alpha = k;
            
            self.previousMirrorView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset + translationPoint.x * self.showViewOffsetScale, 0);
            
            self.previousOverLayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3 * (1 - k)];
            self.visibleViewController.view.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,translationPoint.x, 0);
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            CGPoint velocity = [self.pan velocityInView:self.view];
            BOOL reset = velocity.x < 0;
            if (self.allowPopMaxOffset > self.lastOffset) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    [self barTransitionWithAlpha:1];
                    self.visibleViewController.view.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL finished) {
                    self.previousMirrorView.transform = CGAffineTransformIdentity;
                    
                    self.previousMirrorView.image = nil;
                    
                    self.previousBarMirrorView.image = nil;
                    self.previousBarMirrorView.alpha = 0;
                    [self.previousMirrorView removeFromSuperview];
                    [self.previousBarMirrorView removeFromSuperview];
                    
                    self.barBackgroundView = nil;
                    
                    [self finshPanBackWithReset:reset];
                }];
                
                return ;
            }
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            [UIView animateWithDuration:0.4 animations:^{
                
                CGFloat alpha = reset ? 1.f : 0.f;
                [self barTransitionWithAlpha:alpha];
                self.previousBarMirrorView.alpha = 1 - alpha;
                self.previousMirrorView.transform = reset ? CGAffineTransformTranslate(CGAffineTransformIdentity, -self.showViewOffset, 0) : CGAffineTransformIdentity;
                self.visibleViewController.view.transform = reset ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, ScreenWidth, 0);
                self.previousOverLayView.backgroundColor = reset ? [[UIColor grayColor] colorWithAlphaComponent:0.2] : [UIColor clearColor];
                
            } completion:^(BOOL finished) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                [self barTransitionWithAlpha:1];
                
                self.visibleViewController.view.transform = CGAffineTransformIdentity;
                self.previousMirrorView.transform = CGAffineTransformIdentity;
                self.previousMirrorView.image = nil;

                self.previousBarMirrorView.image = nil;
                self.previousBarMirrorView.alpha = 0;

                [self.previousMirrorView removeFromSuperview];
                [self.previousBarMirrorView removeFromSuperview];
                
                self.barBackgroundView = nil;
                
                [self finshPanBackWithReset:reset];
                
                if (!reset) {
                    [self popViewControllerAnimated:NO];
                }
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark GestureRecognizer Delegate

#define MIN_TAN_VALUE tan(M_PI/6)

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count < 2) return NO;
    if (self.animatedFlag) return NO;
    if (![self enablePanBack]) return NO; // 询问当前viewconroller 是否允许右滑返回
    
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.controllerWrapperView]; 
    if (touchPoint.x < 0 || touchPoint.y < 10) return NO;
    
    UIViewController *topViewController = self.topViewController; // 询问左侧多少以内不允许滑动手势
    if (touchPoint.x < topViewController.zf_interactivePopMaxAllowedInitialDistanceToLeftEdge) {
        return NO;
    }

    CGPoint translation = [gestureRecognizer translationInView:self.view];
    if (translation.x <= 0) return NO;
    
    // 是否是右滑
    BOOL succeed = fabs(translation.y / translation.x) < MIN_TAN_VALUE;
    
    return succeed;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer != self.pan) return NO;
    if (self.pan.state != UIGestureRecognizerStateBegan) return NO;
    
    if (otherGestureRecognizer.state != UIGestureRecognizerStateBegan) {

        return YES;
    }

    CGPoint touchPoint = [self.pan beganLocationInView:self.controllerWrapperView];

    // 点击区域判断 如果在左边 50 以内, 强制手势后退
    if (touchPoint.x < 50) {
        [self cancelOtherGestureRecognizer:otherGestureRecognizer];
        return YES;
    }
    
    // 如果是scrollview 判断scrollview contentOffset 是否为0，是 cancel scrollview 的手势，否cancel自己
    if ([[otherGestureRecognizer view] isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)[otherGestureRecognizer view];
        if (scrollView.contentOffset.x <= 0) {
            
            [self cancelOtherGestureRecognizer:otherGestureRecognizer];
            return YES;
        }
    }

    return NO;
}

- (void)cancelOtherGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSSet *touchs = [self.pan.event touchesForGestureRecognizer:otherGestureRecognizer];
    [otherGestureRecognizer touchesCancelled:touchs withEvent:self.pan.event];
}


#pragma mark -
#pragma mark Custom

- (void)startAnimated:(BOOL)animated
{
    self.animatedFlag = YES;
    
    NSTimeInterval delay = animated ? 0.8 : 0.1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(finishedAnimated) object:nil];
    [self performSelector:@selector(finishedAnimated) withObject:nil afterDelay:delay];
}

- (void)finishedAnimated
{
    self.animatedFlag = NO;
}

- (void)barTransitionWithAlpha:(CGFloat)alpha
{
    UINavigationItem *topItem = self.navigationBar.topItem;
    
    UIView *topItemTitleView = topItem.titleView;

    if (!topItemTitleView) { // 找titleview
        UIView *defaultTitleView = nil;
        @try {
            defaultTitleView = [topItem valueForKey:@"_defaultTitleView"];
        }
        @catch (NSException *exception) {
            defaultTitleView = nil;
        }
        
        topItemTitleView = defaultTitleView;
    }
    
    topItemTitleView.alpha = alpha;

    if (!topItem.leftBarButtonItems.count) { // 找后退按钮Item
        UINavigationItem *backItem = self.navigationBar.backItem;
        UIView *backItemBackButtonView = nil;
        
        @try {
            backItemBackButtonView = [backItem valueForKey:@"_backButtonView"];
        }
        @catch (NSException *exception) {
            backItemBackButtonView = nil;
        }
        backItemBackButtonView.alpha = alpha;
        self.barBackIndicatorView.alpha = alpha;
    }
    
    
    [topItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
        barButtonItem.customView.alpha = alpha;
    }];
    
    [topItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *barButtonItem, NSUInteger idx, BOOL *stop) {
        barButtonItem.customView.alpha = alpha;
    }];
}

#pragma mark -
#pragma mark GET

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    return self.pan;
}

- (UIView *)controllerWrapperView
{
    return self.visibleViewController.view.superview;
}

- (UIView *)barBackgroundView
{
    if (_barBackgroundView) return _barBackgroundView;
    
    for (UIView *subview in self.navigationBar.subviews) {
        if (!subview.hidden && subview.frame.size.height >= self.navigationBar.frame.size.height
            && subview.frame.size.width >= self.navigationBar.frame.size.width) {
            _barBackgroundView = subview;
            break;
        }
    }
    return _barBackgroundView;
}

- (UIView *)barBackIndicatorView
{
    if (!_barBackIndicatorView) {
        for (UIView *subview in self.navigationBar.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")]) {
                _barBackIndicatorView = subview;
                break;
            }
        }
        
    }
    return _barBackIndicatorView;
}

- (UIImage *)barSnapshot
{
    self.barBackgroundView.hidden = YES;
    UIImage *viewImage = [self.navigationBar snapshot];
    self.barBackgroundView.hidden = NO;
    return viewImage;
}

#pragma mark -
#pragma mark LCPanBackProtocol

- (BOOL)enablePanBack
{
    BOOL enable = YES;
    
    if (self.visibleViewController.zf_interactivePopDisabled) {
        enable = NO;
    }
    return enable;
}

- (void)startPanBack
{
    if ([self.visibleViewController respondsToSelector:@selector(startPanBack:)]) {
        UIViewController<LCPanBackProtocol> * viewController = (UIViewController<LCPanBackProtocol> *)self.visibleViewController;
        [viewController startPanBack:self];
    }
}

- (void)finshPanBackWithReset:(BOOL)reset
{
    if (reset) {
        [self resetPanBack];
    } else {
        [self finshPanBack];
    }
}

- (void)finshPanBack
{
    if ([self.visibleViewController respondsToSelector:@selector(finshPanBack:)]) {
        UIViewController<LCPanBackProtocol> * viewController = (UIViewController<LCPanBackProtocol> *)self.visibleViewController;
        [viewController finshPanBack:self];
    }
}

- (void)resetPanBack
{
    if ([self.visibleViewController respondsToSelector:@selector(resetPanBack:)]) {
        UIViewController<LCPanBackProtocol> * viewController = (UIViewController<LCPanBackProtocol> *)self.visibleViewController;
        [viewController resetPanBack:self];
    }
}

@end


@implementation UIViewController (PanGesture)

- (void)setZf_interactivePopDisabled:(BOOL)zf_interactivePopDisabled {
    objc_setAssociatedObject(self, @selector(zf_interactivePopDisabled), @(zf_interactivePopDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)zf_interactivePopDisabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (CGFloat)zf_interactivePopMaxAllowedInitialDistanceToLeftEdge
{
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self, _cmd) floatValue];
#endif
}

- (void)setZf_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)distance
{
    SEL key = @selector(zf_interactivePopMaxAllowedInitialDistanceToLeftEdge);
    objc_setAssociatedObject(self, key, @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)zf_prefersNavigationBarHidden
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setZf_prefersNavigationBarHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, @selector(zf_prefersNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


