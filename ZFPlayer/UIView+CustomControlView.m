//
//  ZFPlayerControlView+Custom.m
//  Player
//
//  Created by 任子丰 on 16/10/12.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import "UIView+CustomControlView.h"
#import <objc/runtime.h>

@implementation UIView (CustomControlView)

- (void)setDelegate:(id<ZFPlayerControlViewDelagate>)delegate
{
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<ZFPlayerControlViewDelagate>)delegate
{
   return objc_getAssociatedObject(self, _cmd);
}

@end
