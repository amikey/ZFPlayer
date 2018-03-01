//
//  ZFPlayerTableViewCell.h
//  Player
//
//  Created by 任子丰 on 2018/3/1.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFPlayer.h"
#import "ZFVideoModel.h"

@interface ZFPlayerTableViewCell : UITableViewCell
/** model */
@property (nonatomic, strong) ZFVideoModel *model;
@property (nonatomic, strong) UIImageView *picImageView;

/** 播放按钮block */
@property (nonatomic, copy) void(^playBlock)(UIButton *);

@end
