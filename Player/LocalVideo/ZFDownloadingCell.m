//
//  ZFDownloadingCell.m
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

#import "ZFDownloadingCell.h"
#import "UIView+ZFViewProperty.h"

@implementation ZFDownloadingCell {
    UIButton                  * _downloadArrowButton;
    ZFDownloadObject          * _downloadObject;
    BOOL                        _hasDownloadAnimation;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.downloadBtn.clipsToBounds = true;
    [self.downloadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addDownloadAnimation {
    if(_downloadArrowButton){
        [UIView animateWithDuration:1.2 animations:^{
            _downloadArrowButton.y = _downloadArrowButton.height;
        }completion:^(BOOL finished) {
            _downloadArrowButton.y = -_downloadArrowButton.height;
            [self addDownloadAnimation];
        }];
    }
}

- (void)startDownloadAnimation {
    if (_downloadArrowButton == nil) {
        _downloadArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadArrowButton.enabled = false;
        _downloadArrowButton.frame = _downloadBtn.bounds;
        [_downloadArrowButton setTitle:@"↓" forState:UIControlStateNormal];
        [_downloadArrowButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _downloadArrowButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    if (!_hasDownloadAnimation) {
        _hasDownloadAnimation = true;
        _downloadArrowButton.y = -_downloadArrowButton.height;
        [_downloadBtn addSubview:_downloadArrowButton];
        [self addDownloadAnimation];
    }
}

- (void)removeDownloadAnimtion {
    _hasDownloadAnimation = false;
    if (_downloadArrowButton != nil) {
        [_downloadArrowButton removeFromSuperview];
        _downloadArrowButton = nil;
    }
}

- (void)updateDownloadValue {
    self.fileNameLabel.text = _downloadObject.fileName;
    self.progress.progress = _downloadObject.downloadProcessValue;
    self.progressLabel.text = _downloadObject.downloadProcessText;
    NSString * strSpeed = _downloadObject.downloadSpeed;
    if (_downloadObject.downloadState != ZFDownloading) {
        [self removeDownloadAnimtion];
    }else {
        [self startDownloadAnimation];
    }
    switch (_downloadObject.downloadState) {
        case ZFDownloadWaitting:
            [self.downloadBtn setTitle:@"🕘" forState:UIControlStateNormal];
            strSpeed = @"等待";
            break;
        case ZFDownloading:
            [self.downloadBtn setTitle:@"" forState:UIControlStateNormal];
            break;
        case ZFDownloadCanceled:
            [self.downloadBtn setTitle:@"■" forState:UIControlStateNormal];
            strSpeed = @"暂停";
            break;
        case ZFDownloadCompleted:
            [self.downloadBtn setTitle:@"▶" forState:UIControlStateNormal];
            strSpeed = @"完成";
        case ZFNone:
            break;
    }
    _speedLabel.text = strSpeed;
}


- (IBAction)clickDownload:(UIButton *)sender {
    switch (_downloadObject.downloadState) {
        case ZFDownloading:
            _downloadObject.downloadState = ZFDownloadCanceled;
#if ZFBackgroundDownload
            [[ZFSessionDownloadManager shared] cancelDownloadWithFileName:_downloadObject.fileName deleteFile:NO];
#else
            [[ZFHttpManager shared] cancelDownloadWithFileName:_downloadObject.fileName deleteFile:NO];
#endif
            break;
        case ZFDownloadCanceled:{
            _downloadObject.downloadState = ZFDownloadWaitting;
#if ZFBackgroundDownload
            ZFDownloadSessionTask * downloadTask = [[ZFSessionDownloadManager shared] download:_downloadObject.downloadPath
                                                                                          savePath:[ZFDownloadObject videoDirectory]
                                                                                      saveFileName:_downloadObject.fileName delegate:self];
            downloadTask.index = self.index;
            
#else
            ZFDownloadOperation * operation = [[ZFHttpManager shared] download:_downloadObject.downloadPath
                                                                          savePath:[ZFDownloadObject videoDirectory]
                                                                      saveFileName:_downloadObject.fileName delegate:self];
            operation.index = self.index;
#endif
            [self updateDownloadValue];
        }
            break;
        case ZFDownloadWaitting:
            break;
        case ZFDownloadCompleted:
            if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerIndex:)]) {
                [_delegate videoPlayerIndex:_index];
            }
            break;
        default:
            break;
    }
}

- (void)displayCell:(ZFDownloadObject *)object index:(NSInteger)index {
    self.index = index;
    _downloadObject = object;
    if (_downloadObject.downloadState == ZFNone ||
        _downloadObject.downloadState == ZFDownloading ) {
        _downloadObject.downloadState = ZFDownloadWaitting;
    }
#if ZFBackgroundDownload
    ZFDownloadSessionTask * downloadTask = [[ZFSessionDownloadManager shared] replaceCurrentDownloadOperationDelegate:self fileName:_downloadObject.fileName];
    if ([[ZFSessionDownloadManager shared] existDownloadOperationTaskWithFileName:_downloadObject.fileName]) {
        if (_downloadObject.downloadState == ZFDownloadCanceled) {
            _downloadObject.downloadState = ZFDownloadWaitting;
        }
    }
    downloadTask.index = index;
#else
    ZFDownloadOperation * operation = [[ZFHttpManager shared] replaceCurrentDownloadOperationDelegate:self fileName:_downloadObject.fileName];
    if ([[ZFHttpManager shared] existDownloadOperationTaskWithFileName:_downloadObject.fileName]) {
        if (_downloadObject.downloadState == ZFDownloadCanceled) {
            _downloadObject.downloadState = ZFDownloadWaitting;
        }
    }
    operation.index = index;
#endif
    [self updateDownloadValue];
    [self removeDownloadAnimtion];
}

- (void)saveDownloadState:(ZFDownloadOperation *)operation {
    _downloadObject.currentDownloadLenght = operation.recvDataLenght;
    _downloadObject.totalLenght = operation.fileTotalLenght;
    [_downloadObject writeDiskCache];
}

//ZFDownloadSessionTask : ZFDownloadOperation

#pragma mark - ZFDownloadDelegate -
- (void)ZFDownloadResponse:(nonnull ZFDownloadOperation *)operation
                      error:(nullable NSError *)error
                         ok:(BOOL)isOK {
    if (isOK) {
        if (self.index == operation.index) {
            _downloadObject.downloadState = ZFDownloading;
            _downloadObject.currentDownloadLenght = operation.recvDataLenght;
            _downloadObject.totalLenght = operation.fileTotalLenght;
            [self updateDownloadValue];
        }else {
            ZFDownloadObject * tempDownloadObject = [ZFDownloadObject readDiskCache:operation.strUrl];
            if (tempDownloadObject != nil) {
                tempDownloadObject.downloadState = ZFDownloading;
                tempDownloadObject.currentDownloadLenght = operation.recvDataLenght;
                tempDownloadObject.totalLenght = operation.fileTotalLenght;
                [tempDownloadObject writeDiskCache];
                if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadValue: index:)]) {
                    [_delegate updateDownloadValue:tempDownloadObject index:operation.index];
                }
            }
        }
    }else {
        _downloadObject.downloadState = ZFNone;
        if (_delegate &&
            [_delegate respondsToSelector:@selector(videoDownload:index:strUrl:)]) {
            [_delegate videoDownload:error index:_index strUrl:operation.strUrl];
        }
    }
}

- (void)ZFDownloadProgress:(nonnull ZFDownloadOperation *)operation
                       recv:(uint64_t)recvLength
                      total:(uint64_t)totalLength
                      speed:(nullable NSString *)speed {
    if (operation.index == self.index) {
        if (_downloadObject.totalLenght < 10) {
            _downloadObject.totalLenght = totalLength;
        }
        _downloadObject.currentDownloadLenght = recvLength;
        _downloadObject.downloadSpeed = speed;
        _downloadObject.downloadState = ZFDownloading;
        [self updateDownloadValue];
        [self startDownloadAnimation];
    }
}

- (void)ZFDownloadDidFinished:(nonnull ZFDownloadOperation *)operation
                          data:(nullable NSData *)data
                         error:(nullable NSError *)error
                       success:(BOOL)isSuccess {
    if (isSuccess) {
        if (self.index == operation.index) {
            _downloadObject.downloadState = ZFDownloadCompleted;
            [self saveDownloadState:operation];
        }else {
            ZFDownloadObject * tempDownloadObject = [ZFDownloadObject readDiskCache:operation.strUrl];
            if (tempDownloadObject != nil) {
                tempDownloadObject.downloadState = ZFDownloadCompleted;
                tempDownloadObject.currentDownloadLenght = operation.recvDataLenght;
                tempDownloadObject.totalLenght = operation.fileTotalLenght;
                [tempDownloadObject writeDiskCache];
                if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadValue:index:)]) {
                    [_delegate updateDownloadValue:tempDownloadObject index:operation.index];
                }
            }
        }
    }else {
        
        ZFDownloadObject * tempDownloadObject;
        if (self.index == operation.index) {
            _downloadObject.downloadState = ZFDownloadCanceled;
        }else {
            tempDownloadObject = [ZFDownloadObject readDiskCache:operation.strUrl];
            if (tempDownloadObject != nil) {
                tempDownloadObject.downloadState = ZFDownloadCanceled;
            }
        }
        if (error != nil &&
            error.code == ZFCancelDownloadError &&
            !operation.isDeleted) {
            if (self.index == operation.index) {
                [self saveDownloadState:operation];
            }else {
                if (tempDownloadObject != nil) {
                    tempDownloadObject.currentDownloadLenght = operation.recvDataLenght;
                    tempDownloadObject.totalLenght = operation.fileTotalLenght;
                    [tempDownloadObject writeDiskCache];
                }
                
            }
            [self saveDownloadState:operation];
        }else {
            [[[UIAlertView alloc] initWithTitle:@"下载失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        if (tempDownloadObject != nil) {
            if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadValue:index:)]) {
                [_delegate updateDownloadValue:tempDownloadObject index:operation.index];
            }
        }
    }
    if (self.index == operation.index) {
        [self updateDownloadValue];
    }
}


@end
