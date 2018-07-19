//
//  ZFDouYinScrollView.m
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/7/19.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFDouYinScrollView.h"

@interface ZFDouYinScrollView ()

@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) UIView *thirdView;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation ZFDouYinScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
//        self.delegate = self;
//        [self addSubview:self.firstView];
//        [self addSubview:self.secondView];
//        [self addSubview:self.thirdView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)updateForUrls:(NSMutableArray *)urls withCurrentIndex:(NSInteger)index {
    self.urls = urls;
    self.currentIndex = index;
    self.contentOffset = CGPointMake(0, self.frame.size.height * index);
    
}

- (void)setUrls:(NSArray *)urls {
    _urls = urls;
    if (urls.count >= 1) {
        CGRect firstFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.firstView.frame = firstFrame;
        [self addSubview:self.firstView];
    }
    if (urls.count >= 2) {
        CGRect secondFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
        self.secondView.frame = secondFrame;
        [self addSubview:self.secondView];
    }
    
    if (urls.count >= 3) {
        CGRect thirdFrame = CGRectMake(0, self.frame.size.height*2, self.frame.size.width, self.frame.size.height);
        self.thirdView.frame = thirdFrame;
        [self addSubview:self.thirdView];
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * urls.count);
//    self.contentOffset = CGPointMake(0, self.frame.size.height * self.currentIndex);
}


- (UIView *)firstView {
    if (!_firstView) {
        _firstView = [UIView new];
    }
    return _firstView;
}


- (UIView *)secondView {
    if (!_secondView) {
        _secondView = [UIView new];
    }
    return _secondView;
}

- (UIView *)thirdView {
    if (!_thirdView) {
        _thirdView = [UIView new];
    }
    return _thirdView;
}


@end
