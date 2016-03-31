//
//  ZFSessionDownloadOperation.m
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

#import "ZFSessionDownloadManager.h"
#import "ZFDownloadSessionTask.h"
#import "ZFHttpManager.h"


@interface ZFSessionDownloadManager () <NSURLSessionDataDelegate , NSURLSessionDelegate>{
    NSOperationQueue *  _asynQueue;
    NSURLSession     *  _downloadSession;
    NSMutableArray   *  _downloadTaskArr;
    NSMutableDictionary * _resumeDataDictionary;
    NSFileManager    *  _fileManager;
    NSMutableDictionary * _etagDictionary;
    NSString * _resumeDataPath;
}

@end

@implementation ZFSessionDownloadManager

+ (instancetype)shared {
    static ZFSessionDownloadManager * downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [ZFSessionDownloadManager new];
    });
    return downloadManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _asynQueue = [NSOperationQueue new];
        _asynQueue.maxConcurrentOperationCount = kZFDefaultDownloadNumber;
        _downloadTaskArr = [NSMutableArray array];
        _resumeDataDictionary = [NSMutableDictionary dictionary];
        _fileManager = [NSFileManager defaultManager];
        _etagDictionary = [NSMutableDictionary dictionary];
        _resumeDataPath = [NSString stringWithFormat:@"%@/Library/Caches/ZFResumeDataCache/",NSHomeDirectory()];
        BOOL isDirectory = YES;
        if (![_fileManager fileExistsAtPath:_resumeDataPath isDirectory:&isDirectory]) {
            [_fileManager createDirectoryAtPath:_resumeDataPath
          withIntermediateDirectories:YES
                           attributes:@{NSFileProtectionKey:NSFileProtectionNone} error:nil];
        }
    }
    return self;
}

- (void)setBundleIdentifier:(nonnull NSString *)identifier {
    if (_downloadSession == nil) {
        _bundleIdentifier = nil;
        _bundleIdentifier = identifier.copy;
        NSURLSessionConfiguration * configuration;
        if ([NSURLSessionConfiguration respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]){
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_bundleIdentifier];
        }else {
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:_bundleIdentifier];
        }
        configuration.discretionary = YES;
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:_asynQueue];
        
    }
}

- (BOOL)waitingDownload {
    return _asynQueue.operations.count > kZFDefaultDownloadNumber;
}

#pragma mark - 下载对外接口

- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                    delegate:(nullable id<ZFDownloadDelegate>)delegate {
    return [self download:strUrl savePath:savePath saveFileName:nil delegate:delegate];
}


- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    delegate:(nullable id<ZFDownloadDelegate>)delegate {
    ZFDownloadSessionTask  * downloadTask = nil;
    NSString * fileName = nil;
    if (strUrl != nil && ![[ZFHttpManager shared].failedUrls containsObject:strUrl]) {
        fileName = [[ZFHttpManager shared] handleFileName:saveFileName url:strUrl];
        for (ZFDownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
            if ([fileName isEqualToString: tempDownloadTask.saveFileName]){
                __autoreleasing NSError * error = [[ZFHttpManager shared] error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (delegate && [delegate respondsToSelector:@selector(ZFDownloadResponse:error:ok:)]) {
                    [delegate ZFDownloadResponse:tempDownloadTask error:error ok:NO];
                } else if (delegate && [delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
                    [delegate ZFDownloadDidFinished:tempDownloadTask data:nil error:error success:NO];
                }
                return tempDownloadTask;
            }
        }
        if([[ZFHttpManager shared] createFileSavePath:savePath]) {
            
            downloadTask = [ZFDownloadSessionTask new];
            downloadTask.requestType = ZFHttpRequestFileDownload;
            downloadTask.saveFileName = fileName;
            downloadTask.saveFilePath = savePath;
            downloadTask.delegate = delegate;
            downloadTask.strUrl = strUrl;
            downloadTask.delegate = delegate;
            [self startDownload:downloadTask];
        }
    }else {
        __autoreleasing NSError * error = [[ZFHttpManager shared] error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
        if (delegate &&
            [delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
            [delegate ZFDownloadDidFinished:downloadTask data:nil error:error success:NO];
        }
    }
    return downloadTask;
    
}

- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                    response:(nullable ZFResponse)responseBlock
                                     process:(nullable ZFProgress)processBlock
                                 didFinished:(nullable ZFDidFinished)finishedBlock {
    return nil;
}

- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    response:(nullable ZFResponse) responseBlock
                                     process:(nullable ZFProgress) processBlock
                                 didFinished:(nullable ZFDidFinished) finishedBlock {
    ZFDownloadSessionTask  * downloadTask = nil;
    NSString * fileName = nil;
    if (strUrl != nil && ![[ZFHttpManager shared].failedUrls containsObject:strUrl]) {
        fileName = [[ZFHttpManager shared] handleFileName:saveFileName url:strUrl];
        for (ZFDownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
            if ([fileName isEqualToString:tempDownloadTask.saveFileName]){
                __autoreleasing NSError * error = [[ZFHttpManager shared] error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (responseBlock) {
                    responseBlock(tempDownloadTask, error, NO);
                } else if (finishedBlock) {
                    finishedBlock(tempDownloadTask ,nil, error, NO);
                }
                return tempDownloadTask;
            }
        }
        if([[ZFHttpManager shared] createFileSavePath:savePath]) {
            downloadTask = [ZFDownloadSessionTask new];
            downloadTask.requestType = ZFHttpRequestFileDownload;
            downloadTask.saveFileName = fileName;
            downloadTask.saveFilePath = savePath;
            downloadTask.progressBlock = processBlock;
            downloadTask.responseBlock = responseBlock;
            downloadTask.strUrl = strUrl;
            downloadTask.didFinishedBlock = ^(ZFBaseOperation *operation,
                                                   NSData *data,
                                                   NSError *error,
                                                   BOOL isSuccess) {
                if (!isSuccess && error.code == 404) {
                    [[ZFHttpManager shared].failedUrls addObject:strUrl];
                }
                if (finishedBlock) {
                    finishedBlock(operation , data , error , isSuccess);
                }
            };
            [self startDownload:downloadTask];
        }
    }else {
        __autoreleasing NSError * error = [[ZFHttpManager shared] error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
        if (responseBlock) {
            responseBlock(downloadTask , error , NO);
        }else if (finishedBlock) {
            finishedBlock(downloadTask , nil , error , NO);
        }
    }
    return downloadTask;
}

#pragma mark - 私有方法

- (NSString *)getResumeDataFilePath:(NSString *)fileName {
    if (fileName && fileName.length > 0) {
        return [NSString stringWithFormat:@"%@%@",_resumeDataPath , fileName];
    }
    return nil;
}


- (void)startDownload:(ZFDownloadSessionTask *)downloadTask {
    if (_downloadSession) {
        NSString * resumeDataFilePath = [self getResumeDataFilePath:downloadTask.saveFileName];
        if (resumeDataFilePath && [_fileManager fileExistsAtPath:resumeDataFilePath]) {
            NSData * resumeData = [NSData dataWithContentsOfFile:resumeDataFilePath];
            downloadTask.downloadTask = [_downloadSession downloadTaskWithResumeData:resumeData];
        }else {
            NSURL * url = [NSURL URLWithString:downloadTask.strUrl];
            NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
            downloadTask.downloadTask = [_downloadSession downloadTaskWithRequest:urlRequest];
        }
        [downloadTask startSpeedTimer];
        [downloadTask.downloadTask resume];
        [_downloadTaskArr addObject:downloadTask];
    }
}

- (void)cancelDownloadTask:(BOOL)isDelete task:(ZFDownloadSessionTask *)task {
    if (!isDelete) {
        [task.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            // 存储恢复下载数据在didCompleteWithError处理
        }];
    }else {
        [task cancelDownloadTaskAndDeleteFile:isDelete];
    }
}

#pragma mark - 下载过程对外接口

- (nullable ZFDownloadSessionTask *)downloadOperationWithFileName:(nonnull NSString *)fileName {
    ZFDownloadSessionTask * downloadTask = nil;
    for (ZFDownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
        if([tempDownloadTask.saveFileName isEqualToString:fileName]) {
            downloadTask = tempDownloadTask;
            break;
        }
    }
    return downloadTask;
}

- (void)cancelAllDownloadTaskAndDelFile:(BOOL)isDelete {
    for (ZFDownloadSessionTask * task in _downloadTaskArr) {
        [self cancelDownloadTask:isDelete task:task];
    }
}

- (void)cancelDownloadWithDownloadUrl:(nonnull NSString *)strUrl deleteFile:(BOOL)isDelete {
    for(ZFDownloadSessionTask * task in _downloadTaskArr){
        if ([task.strUrl isEqualToString:strUrl]) {
            [self cancelDownloadTask:isDelete task:task];
            break;
        }
    }
}

- (void)cancelDownloadWithFileName:(nonnull NSString *)fileName deleteFile:(BOOL)isDelete {
    for(ZFDownloadSessionTask * task in _downloadTaskArr){
        if([task.saveFileName isEqualToString:fileName]){
            [self cancelDownloadTask:isDelete task:task];
            break;
        }
    }
}

- (ZFDownloadSessionTask *)replaceCurrentDownloadOperationBlockResponse:(nullable ZFResponse)responseBlock
                                             process:(nullable ZFProgress)processBlock
                                         didFinished:(nullable ZFDidFinished)didFinishedBlock
                                            fileName:(nonnull NSString *)fileName {
    for (ZFDownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.saveFileName isEqualToString:fileName]){
            downloadTask.delegate = nil;
            downloadTask.progressBlock = processBlock;
            downloadTask.responseBlock = responseBlock;
            downloadTask.didFinishedBlock = didFinishedBlock;
            return downloadTask;
        }
    }
    return nil;
}

- (ZFDownloadSessionTask *)replaceCurrentDownloadOperationDelegate:(nullable id<ZFDownloadDelegate>)delegate
                                       fileName:(nonnull NSString *)fileName {
    for (ZFDownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.saveFileName isEqualToString:fileName]){
            downloadTask.progressBlock = nil;
            downloadTask.responseBlock = nil;
            downloadTask.didFinishedBlock = nil;
            downloadTask.delegate = delegate;
            return downloadTask;
        }
    }
    return nil;
}

- (ZFDownloadSessionTask *)replaceAllDownloadOperationBlockResponse:(nullable ZFResponse)responseBlock
                                         process:(nullable ZFProgress)processBlock
                                     didFinished:(nullable ZFDidFinished)didFinishedBlock {
    if (_downloadTaskArr.count > 0) {
        for (ZFDownloadSessionTask * downloadTask in _downloadTaskArr) {
            downloadTask.delegate = nil;
            downloadTask.progressBlock = processBlock;
            downloadTask.responseBlock = responseBlock;
            downloadTask.didFinishedBlock = didFinishedBlock;
        }
        return nil;
    }
    return nil;
}

- (ZFDownloadSessionTask *)replaceAllDownloadOperationDelegate:(nullable id<ZFDownloadDelegate>)delegate {
    if (_downloadTaskArr.count > 0) {
        for (ZFDownloadSessionTask * downloadTask in _downloadTaskArr) {
            downloadTask.progressBlock = nil;
            downloadTask.responseBlock = nil;
            downloadTask.didFinishedBlock = nil;
            downloadTask.delegate = delegate;
        }
        return nil;
    }
    return nil;
}


- (BOOL)existDownloadOperationTaskWithFileName:(nonnull NSString *)fileName {
    BOOL  result = NO;
    for (ZFDownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.saveFileName isEqualToString:fileName]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)existDownloadOperationTaskWithUrl:(nonnull NSString *)strUrl {
    BOOL  result = NO;
    for (ZFDownloadSessionTask * downloadTask in _downloadTaskArr) {
        if([downloadTask.strUrl isEqualToString:strUrl]){
            result = YES;
            break;
        }
    }
    return result;
}


- (ZFDownloadSessionTask *)getCurrentDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
    ZFDownloadSessionTask * ZFdownloadTask = nil;
    for (ZFDownloadSessionTask * tempDownloadTask in _downloadTaskArr) {
        if ([tempDownloadTask.downloadTask isEqual:downloadTask]) {
            ZFdownloadTask = tempDownloadTask;
            break;
        }
    }
    return ZFdownloadTask;
}

- (void)removeDownloadTask:(ZFDownloadSessionTask *)downloadTask {
    downloadTask.delegate = nil;
    downloadTask.downloadTask = nil;
    downloadTask.responseBlock = nil;
    downloadTask.didFinishedBlock = nil;
    downloadTask.progressBlock = nil;
    [_downloadTaskArr removeObject:downloadTask];
}


- (void)saveDownloadFile:(NSString *)path downloadTask:(ZFDownloadSessionTask *)downloadTask {
    if (path) {
        if ([_fileManager fileExistsAtPath:downloadTask.saveFilePath isDirectory:NULL]) {
            NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:downloadTask.saveFilePath];
            [fileHandle seekToEndOfFile];
            NSData * data = [NSData dataWithContentsOfFile:path];
            if (data) {
                [fileHandle writeData:data];
                [fileHandle synchronizeFile];
                [fileHandle closeFile];
            }
        }else {
            [_fileManager moveItemAtPath:path toPath:downloadTask.saveFilePath error:NULL];
        }
    }
}

- (void)saveDidFinishDownloadTask:(NSURLSessionDownloadTask *)downloadTask
                            toUrl:(NSURL *)location {
    ZFDownloadSessionTask * ZFdownloadTask = [self getCurrentDownloadTask:downloadTask];
    if (ZFdownloadTask) {
        ZFdownloadTask.actualFileSizeLenght = downloadTask.countOfBytesExpectedToReceive;
        ZFdownloadTask.recvDataLenght = downloadTask.countOfBytesReceived;
        ZFdownloadTask.requestStatus = ZFHttpRequestFinished;
        [self saveDownloadFile:location.path downloadTask:ZFdownloadTask];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ZFdownloadTask.delegate &&
                [ZFdownloadTask.delegate respondsToSelector:@selector(ZFDownloadProgress:recv:total:speed:)]) {
                [ZFdownloadTask.delegate ZFDownloadProgress:ZFdownloadTask
                                                          recv:downloadTask.countOfBytesReceived
                                                         total:downloadTask.countOfBytesExpectedToReceive
                                                         speed:ZFdownloadTask.networkSpeed];
                if ([ZFdownloadTask.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
                    [ZFdownloadTask.delegate ZFDownloadDidFinished:ZFdownloadTask
                                                                 data:nil
                                                                error:nil
                                                              success:YES];
                }
            }else {
                if (ZFdownloadTask.progressBlock) {
                    ZFdownloadTask.progressBlock(ZFdownloadTask ,
                                                   downloadTask.countOfBytesReceived ,
                                                   downloadTask.countOfBytesExpectedToReceive ,
                                                   ZFdownloadTask.networkSpeed);
                }
                if (ZFdownloadTask.didFinishedBlock) {
                    ZFdownloadTask.didFinishedBlock(ZFdownloadTask , nil , nil , YES);
                }
            }
            [self removeDownloadTask:ZFdownloadTask];
        });
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    [self saveDidFinishDownloadTask:downloadTask toUrl:location];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    ZFDownloadSessionTask * ZFdownloadTask = [self getCurrentDownloadTask:(NSURLSessionDownloadTask *)task];
    if (ZFdownloadTask.delegate &&
        [ZFdownloadTask.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error &&
                [error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"cancelled"]) {
                NSData * resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                if (resumeData) {
                    [resumeData writeToFile:[self getResumeDataFilePath:ZFdownloadTask.saveFileName] atomically:YES];
                }
                if (ZFdownloadTask.delegate &&
                    [ZFdownloadTask.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
                    [ZFdownloadTask.delegate ZFDownloadDidFinished:ZFdownloadTask
                                                                 data:nil
                                                                error:error
                                                              success:NO];
                }else {
                    if (ZFdownloadTask.didFinishedBlock) {
                        ZFdownloadTask.didFinishedBlock(ZFdownloadTask , nil , error , NO);
                    }
                }
                [self removeDownloadTask:ZFdownloadTask];
            }
        });
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    ZFDownloadSessionTask * ZFdownloadTask = [self getCurrentDownloadTask:downloadTask];
    ZFdownloadTask.recvDataLenght += bytesWritten;
    ZFdownloadTask.orderTimeDataLenght += bytesWritten;
    if (ZFdownloadTask.actualFileSizeLenght < 10) {
        ZFdownloadTask.actualFileSizeLenght = totalBytesExpectedToWrite;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
       if (ZFdownloadTask.delegate &&
           [ZFdownloadTask.delegate respondsToSelector:@selector(ZFDownloadProgress:recv:total:speed:)]) {
           [ZFdownloadTask.delegate ZFDownloadProgress:ZFdownloadTask
                                                     recv:totalBytesWritten
                                                    total:totalBytesExpectedToWrite
                                                    speed:ZFdownloadTask.networkSpeed];
       }else {
           if (ZFdownloadTask.progressBlock) {
               ZFdownloadTask.progressBlock(ZFdownloadTask ,
                                              totalBytesWritten ,
                                              totalBytesExpectedToWrite ,
                                              ZFdownloadTask.networkSpeed);
           }
       }
    });
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    ZFDownloadSessionTask * ZFdownloadTask = [self getCurrentDownloadTask:downloadTask];
    ZFdownloadTask.orderTimeDataLenght = fileOffset;
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    ZFDownloadSessionTask * ZFdownloadTask = [self getCurrentDownloadTask:(NSURLSessionDownloadTask *)dataTask];
    [ZFdownloadTask handleResponse:response];
    if (ZFdownloadTask.requestStatus == ZFHttpRequestFinished) {
        [self removeDownloadTask:ZFdownloadTask];
    }
}
@end
