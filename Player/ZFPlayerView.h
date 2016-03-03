//
//  ZFPlayerView.h
//  Player
//
//  Created by 任子丰 on 16/3/3.
//  Copyright © 2016年 zhaoqingwen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GoBackBlock)(void);

@interface ZFPlayerView : UIView
/** 视频URL */
@property (nonatomic, copy) NSString *videoURL;
@property (nonatomic, assign) CGRect frames;
@property (nonatomic, copy) GoBackBlock goBackBlock;
- (instancetype)initWithFrame:(CGRect)frame URL:(NSString *)url;
@end
