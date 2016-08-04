//
//  FilesDownManage.h
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


#import <Foundation/Foundation.h>

#import "CommonHelper.h"
#import "DownloadDelegate.h"
#import "FileModel.h"
#import "ZFHttpRequest.h"

#define kMaxRequestCount  @"kMaxRequestCount"

@interface FilesDownManage : NSObject<ZFHttpRequestDelegate>

@property (nonatomic,assign ) NSInteger          count;
@property (nonatomic,weak   ) id<ZFDownloadDelegate> VCdelegate;//获得下载事件的vc，用在比如多选图片后批量下载的情况，这时需配合 allowNextRequest 协议方法使用
@property (nonatomic,weak   ) id<ZFDownloadDelegate> downloadDelegate;//下载列表delegate

@property (nonatomic,strong ) NSString           *basepath;
@property (nonatomic,strong ) NSString           *TargetSubPath;
@property (nonatomic,strong ) NSMutableArray     *finishedlist;//已下载完成的文件列表（文件对象）

@property (nonatomic,strong ) NSMutableArray     *downinglist;//正在下载的文件列表(ASIHttpRequest对象)
@property (nonatomic,strong ) NSMutableArray     *filelist;
@property (nonatomic,strong ) NSMutableArray     *targetPathArray;

@property (nonatomic,strong ) FileModel          *fileInfo;
@property (nonatomic,assign ) BOOL               isFistLoadSound;//是否第一次加载声音，静音
@property (nonatomic,assign ) NSInteger          maxCount;


+ (FilesDownManage *)sharedFilesDownManage;
//＊＊＊第一次＊＊＊初始化是使用，设置缓存文件夹和已下载文件夹，构建下载列表和已下载文件列表时使用
+ (FilesDownManage *)sharedFilesDownManageWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths;

- (void)clearAllRquests;
- (void)clearAllFinished;
- (void)resumeRequest:(ZFHttpRequest *)request;
- (void)deleteRequest:(ZFHttpRequest *)request;
- (void)stopRequest:(ZFHttpRequest *)request;
- (void)saveFinishedFile;
- (void)deleteFinishFile:(FileModel *)selectFile;
- (void)downFileUrl:(NSString*)url
          filename:(NSString*)name
        filetarget:(NSString *)path
         fileimage:(UIImage *)image
         ;
- (void)startLoad;
- (void)restartAllRquests;

@end


