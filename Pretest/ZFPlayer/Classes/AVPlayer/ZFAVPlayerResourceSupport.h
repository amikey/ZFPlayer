//
//  ZFAVPlayerResourceSupport.m
//  ZFPlayer
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
#import <AVFoundation/AVFoundation.h>
#define DOWNLOAD_CACHE_DATA_FILE_PATH ([NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/CacheVideos/Files"])
#define DOWNLOAD_CACHE_DATA_INFO_PATH ([NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/CacheVideos/Infos"])
NS_ASSUME_NONNULL_BEGIN

@class RequestInfo;
@class ZFAVPlayerResourceSupport;

@interface RequestInfo : NSObject

@property (nonatomic, assign) BOOL haveDone;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURLSessionDataTask *task;
@property (nonatomic, assign, readonly) long long startLocation;
@property (nonatomic, assign, readonly) long long requestLength;
@property (nonatomic, assign) long long downloadLength;
@property (nonatomic, weak) ZFAVPlayerResourceSupport *delegate;
@property (nonatomic, copy) NSString *filePath;

- (instancetype)initWithURL:(NSURL*)url startLocation:(long long)startLocation requestLength:(long long)requestLength delegate:(ZFAVPlayerResourceSupport *)delegate;

@end

@interface LocationFileInfo : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign, readonly) long long startLocation;
@property (nonatomic, assign, readonly) long long dataLength;
@property (nonatomic, assign, readonly) long long endLocation;

- (instancetype)initWithFilePath:(NSString*)filePath;

@end

@class ZFAVPlayerResourceSupport;

typedef void(^HaveLoadDataBlock)(NSArray<__kindof LocationFileInfo*>* dataRanges,ZFAVPlayerResourceSupport *support);

@interface ZFAVPlayerResourceSupport : NSObject <AVAssetResourceLoaderDelegate,NSURLSessionDataDelegate>

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, strong, readonly) RequestInfo *currentRequestInfo;
@property (nonatomic, assign, readonly) long long currentStartOffset;
@property (nonatomic, assign, readonly) long long currentLoadingRequestLength;
@property (nonatomic, assign, readonly) long long currentLoadingRequestStartOffset;
@property (nonatomic, assign, readonly) long long videoLength;
@property (nonatomic, assign, readonly) BOOL getVideoLengthState;//0未获取1获取成功2正在获取
@property (nonatomic, strong, readonly) NSURLSession *downLoadSession;
@property (nonatomic, strong, readonly) NSMutableArray *resourceLoadingRequests;
@property (nonatomic, copy) NSString *dictionaryPath;
@property (nonatomic, copy) NSString *infoDictionaryPath;
@property (nonatomic, strong, readonly) NSFileManager *fileManager;
//当获取得到数据时执行的Block
@property (nonatomic, copy) HaveLoadDataBlock dataBlock;

@property (nonatomic, strong, readonly)NSMutableArray *locationFiles;

- (instancetype)initWithURL:(NSURL*)url;

- (AVURLAsset *)urlAsset:(nullable NSDictionary *)options queue:(nullable dispatch_queue_t)queue;

@end

NS_ASSUME_NONNULL_END
