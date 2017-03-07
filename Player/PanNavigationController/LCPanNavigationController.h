//
//  LCPanNavigationController.h
//  PanBackDemo
//
//  Created by clovelu on 5/30/14.
//
//

#import <UIKit/UIKit.h>

@interface LCPanNavigationController : UINavigationController
@property (readonly, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
// 当滑动偏移量达到一个数值时候才允许pop，默认120
@property (nonatomic, assign) CGFloat allowPopMaxOffset;

@property (nonatomic, assign) BOOL zf_viewControllerBasedNavigationBarAppearanceEnabled;
@end

@protocol LCPanBackProtocol <NSObject>
- (void)startPanBack:(LCPanNavigationController *)panNavigationController;
- (void)finshPanBack:(LCPanNavigationController *)panNavigationController;
- (void)resetPanBack:(LCPanNavigationController *)panNavigationController;
@end



@interface UIViewController (PanGesture)
/// 关闭某个控制器的pop手势，默认开启pop手势，关闭手势时需返回YES
@property (nonatomic, assign) BOOL zf_interactivePopDisabled;
/// Max allowed initial distance to left edge when you begin the interactive pop
/// gesture. 0 by default, which means it will ignore this limit.
@property (nonatomic, assign) CGFloat zf_interactivePopMaxAllowedInitialDistanceToLeftEdge;
/// Indicate this view controller prefers its navigation bar hidden or not,
/// checked when view controller based navigation bar's appearance is enabled.
/// Default to NO, bars are more likely to show.
@property (nonatomic, assign) BOOL zf_prefersNavigationBarHidden;

@end
