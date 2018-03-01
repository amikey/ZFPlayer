//
//  ZFFullScreenTransition.h
//  ZFPlayer
//
//  Created by 任子丰 on 2017/8/29.
//  Copyright © 2017年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrentationObserver.h"

typedef NS_ENUM(NSInteger,ZFTransitionType) {
    ZFTransitionTypePresent = 0,
    ZFTransitionTypeDismiss  = 1
};

@interface ZFFullScreenTransition : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithTransitionType:(ZFTransitionType)transitionType fullScreenMode:(ZFFullScreenMode)fullScreenMode playerView:(UIView *)playerView containerView:(UIView *)containerView;

@end
