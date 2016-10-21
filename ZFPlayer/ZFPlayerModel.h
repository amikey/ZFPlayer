//
//  ZFPlayerModel.h
//  Player
//
//  Created by 任子丰 on 16/10/21.
//  Copyright © 2016年 任子丰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFPlayerModel : NSObject
/** 视频标题 */
@property (nonatomic, copy  ) NSString     *title;
/** 视频播放地址 */
@property (nonatomic, copy  ) NSString     *videoUrl;
/** 视频封面本地图片 */
@property (nonatomic, copy  ) UIImage      *placeholderImage;
/** 视频分辨率 */
@property (nonatomic, strong) NSDictionary *resolutionDic;

// cell播放视频，以下属性必须设置值
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) NSIndexPath  *indexPath;
@property (nonatomic, assign) NSUInteger   cellImageViewTag;

@end
