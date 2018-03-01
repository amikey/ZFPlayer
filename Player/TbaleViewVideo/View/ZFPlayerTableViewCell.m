//
//  ZFPlayerTableViewCell.m
//  Player
//
//  Created by 任子丰 on 2018/3/1.
//  Copyright © 2018年 任子丰. All rights reserved.
//

#import "ZFPlayerTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface ZFPlayerTableViewCell ()

@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation ZFPlayerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.picImageView];
        [self.picImageView addSubview:self.playBtn];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.picImageView.frame = self.contentView.bounds;
    self.playBtn.frame = CGRectMake(0, 0, 50, 50);
    self.playBtn.center = self.picImageView.center;
}

- (void)setModel:(ZFVideoModel *)model {
    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:model.coverForFeed] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];
}

- (void)play:(UIButton *)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        // 代码添加playerBtn到imageView上
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"video_list_cell_big_icon"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIImageView *)picImageView {
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] init];
        _picImageView.userInteractionEnabled = YES;
        _picImageView.tag = 100;
    }
    return _picImageView;
}

@end
