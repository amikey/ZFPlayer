//
//  ZFDownloadingCell.h
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "ZFDownloadObject.h"
#import "ZFPlayer.h"

@protocol ZFOffLineVideoCellDelegate <NSObject>

- (void)videoDownload:(NSError *)error index:(NSInteger)index strUrl:(NSString *)strUrl;
- (void)updateDownloadValue:(ZFDownloadObject *)downloadObject index:(NSInteger)index;
- (void)videoPlayerIndex:(NSInteger)index;
@end

@interface ZFDownloadingCell : UITableViewCell <ZFDownloadDelegate>

@property (nonatomic , weak)id<ZFOffLineVideoCellDelegate> delegate;
@property (nonatomic , assign)NSInteger index;

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
- (void)displayCell:(ZFDownloadObject *)object index:(NSInteger)index;

@end
