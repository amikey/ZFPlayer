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

#import "ZFAVPlayerResourceSupport.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#define VideoScheme @"streaming"

@implementation RequestInfo

- (instancetype)initWithURL:(NSURL*)url startLocation:(long long)startLocation requestLength:(long long)requestLength delegate:(ZFAVPlayerResourceSupport *)delegate {
    self = [self init];
    if (self) {
        _haveDone = NO;
        _url = [url copy];
        _startLocation = startLocation;
        _requestLength = requestLength;
        _downloadLength = 0;
        if (delegate!=nil) {
            self.delegate = delegate;
            NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:NO];
            actualURLComponents.scheme = @"http";
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
            [request addValue:[NSString stringWithFormat:@"bytes=%lld-%lld",_startLocation, (_startLocation+requestLength-1)] forHTTPHeaderField:@"Range"];
            _task = [self.delegate.downLoadSession dataTaskWithRequest:request];
        }
    }
    return self;
}

@end

@implementation LocationFileInfo

- (instancetype)initWithFilePath:(NSString*)filePath {
    self = [self init];
    if (self) {
        _filePath = [filePath copy];
        _startLocation = [[filePath lastPathComponent] integerValue];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSDictionary *fileInfo = [manager attributesOfItemAtPath:filePath error:nil];
        _dataLength = (NSInteger)[fileInfo fileSize];
        _endLocation = _startLocation+_dataLength;
    }
    return self;
}

@end


@implementation ZFAVPlayerResourceSupport

+ (NSURL *) url:(NSURL*) url withCustomScheme:(NSString *)scheme{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = scheme;
    return [components URL];
}

- (AVURLAsset *)urlAsset:(NSDictionary *)options queue:(nullable dispatch_queue_t)queue {
    NSURL *url = [[self class] url:_url withCustomScheme:VideoScheme];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:options];
    [asset.resourceLoader setDelegate:self queue:queue];
    return asset;
}

- (instancetype)initWithURL:(NSURL*)url {
    self = [self init];
    if (self) {
        _url = [url copy];
        _currentStartOffset = 0;
        _currentLoadingRequestLength = 0;
        _currentLoadingRequestStartOffset = 0;
        _downLoadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _resourceLoadingRequests = [NSMutableArray array];
        _getVideoLengthState = 0;
        _fileManager = [NSFileManager defaultManager];
        _dictionaryPath = [self cacheDictionaryPathWithURL:_url];
        _infoDictionaryPath = [self cacheInfoDictionaryPathWithURL:_url];
        BOOL isDictionaryPath = NO;
        if (![_fileManager fileExistsAtPath:_dictionaryPath isDirectory:&isDictionaryPath] || !isDictionaryPath) {
            [_fileManager createDirectoryAtPath:_dictionaryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        BOOL isInfoDictionaryPath = NO;
        if (![_fileManager fileExistsAtPath:_infoDictionaryPath isDirectory:&isInfoDictionaryPath] || !isInfoDictionaryPath) {
            [_fileManager createDirectoryAtPath:_infoDictionaryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

#pragma mark - 获取视频文件大小

- (void)getVideoFileLength {
    if (_getVideoLengthState != 0) {
        return;
    }
    _getVideoLengthState = 2;
    NSString *infoFilePath = [_infoDictionaryPath stringByAppendingPathComponent:@"info.plist"];
    if ([_fileManager fileExistsAtPath:infoFilePath]) {
        NSDictionary *locationInfoDict = [NSDictionary dictionaryWithContentsOfFile:infoFilePath];
        _videoLength = [[locationInfoDict valueForKey:@"length"] longLongValue];
        _getVideoLengthState = 1;
        [self getLocationFilesInfo];
        long long length = [self requestLengthForStartLocation];
        [self makeRequest:_currentStartOffset requestLength:length];
        [self setRequestData];
    } else {
        NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:_url resolvingAgainstBaseURL:NO];
        actualURLComponents.scheme = @"http";
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[actualURLComponents URL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
        [request setHTTPMethod:@"HEAD"];
        NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //获取视频资源大小结束
            if (error == nil) { //获取成功
                _videoLength = (NSInteger)[response expectedContentLength];
                
                NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@(_videoLength) forKey:@"length"];
                [infoDict writeToFile:[_infoDictionaryPath stringByAppendingPathComponent:@"info.plist"] atomically:YES];
                _getVideoLengthState = 1;
                [self getLocationFilesInfo];
                long long length = [self requestLengthForStartLocation];
                [self makeRequest:_currentStartOffset requestLength:length];
                [self setRequestData];
            } else {
                _getVideoLengthState = 0;
            }
            
        }];
        [task resume];
    }
}

#pragma mark - 给请求设置属性
//给所有请求添加属性
- (void)giveVideoRequestInfos {
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    NSString *mimeType = @"video/mp4";
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    for (AVAssetResourceLoadingRequest *loadingRequest in _resourceLoadingRequests) {
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
        loadingRequest.contentInformationRequest.contentLength = _videoLength;
    }
}
#pragma mark - 给单个请求添加属性

- (void)giveVideoRequestInfo:(AVAssetResourceLoadingRequest*)loadingRequest {
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    NSString *mimeType = @"video/mp4";
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.contentLength = _videoLength;
}

#pragma mark - 开启一个请求

- (void)makeRequest:(long long)startLocation requestLength:(long long)requestLength {
    if (requestLength <= 0) {
        [self setRequestData];
        return;
    }
    
    if (_currentRequestInfo != nil) {
        [_currentRequestInfo.task cancel];
        [_currentRequestInfo setHaveDone:YES];
        _currentRequestInfo = nil;
    }
    _currentRequestInfo  = [[RequestInfo alloc]initWithURL:self.url startLocation:startLocation requestLength:MIN(requestLength, _videoLength-startLocation) delegate:self];
    _currentStartOffset = startLocation;
    NSString *filePath = [_dictionaryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",@(startLocation)]];
    _currentRequestInfo.filePath = filePath;
    if ([_fileManager fileExistsAtPath:_currentRequestInfo.filePath]) {
        [_fileManager removeItemAtPath:filePath error:nil];
    }
    [_fileManager createFileAtPath:filePath contents:nil attributes:nil];
    
    [_currentRequestInfo.task resume];
}

#pragma mark - 给每个请求赋予数据

- (void)setRequestData {
    if (self.dataBlock != NULL) {
        typeof(self) __weak weakself = self;
        self.dataBlock([weakself haveLoadDataRanges],weakself);
    }
    
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    NSMutableArray *requestsCompleted = [NSMutableArray array];  //请求完成的数组
    //每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    for (AVAssetResourceLoadingRequest *loadingRequest in _resourceLoadingRequests) {
        [self giveVideoRequestInfo:loadingRequest];
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest]; //判断此次请求的数据是否处理完全
        if (didRespondCompletely) {
            [requestsCompleted addObject:loadingRequest];  //如果完整，把此次请求放进 请求完成的数组
            [loadingRequest finishLoading];
        }
    }
    
    [_resourceLoadingRequests removeObjectsInArray:requestsCompleted];   //在所有请求的数组中移除已经完成的
}

#pragma mark - 给一个请求分发数据

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest {
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0) {
        startOffset = dataRequest.currentOffset;
    }
    
    NSData *filedata = [self dataFromHaveDownLoad:(NSInteger)startOffset fileLength:dataRequest.requestedLength];
    [dataRequest respondWithData:filedata];
    BOOL didRespondFully = (filedata.length >= dataRequest.requestedLength);
    return didRespondFully;
}

#pragma mark - 获取缓存文件夹路径

- (NSString*)md5EncodeString:(NSString*)string {
    if (string == nil || string.length <= 0) {
        return @"undefine";
    }
    
    const char* str = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

- (NSString*)cacheInfoDictionaryPathWithURL:(NSURL*)url {
    return [DOWNLOAD_CACHE_DATA_INFO_PATH stringByAppendingPathComponent:[self md5EncodeString:[url absoluteString]]];
}

- (NSString*)cacheDictionaryPathWithURL:(NSURL*)url {
    return [DOWNLOAD_CACHE_DATA_FILE_PATH stringByAppendingPathComponent:[self md5EncodeString:[url absoluteString]]];
}

#pragma mark - 播放器代理

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    [_resourceLoadingRequests addObject:loadingRequest];
    if (_getVideoLengthState != 1) {
        long long startOffset = loadingRequest.dataRequest.requestedOffset;
        if (loadingRequest.dataRequest.currentOffset != 0) {
            startOffset = loadingRequest.dataRequest.currentOffset;
        }
        _currentStartOffset = startOffset;
        _currentLoadingRequestLength = loadingRequest.dataRequest.requestedLength;
        _currentLoadingRequestStartOffset = startOffset;
        [self getVideoFileLength];
        
    } else {
        long long startOffset = loadingRequest.dataRequest.requestedOffset;
        
        if (loadingRequest.dataRequest.currentOffset != 0) {
            startOffset = loadingRequest.dataRequest.currentOffset;
        }
        
        if (_currentRequestInfo == nil || _currentRequestInfo.startLocation > startOffset || ((_currentRequestInfo.startLocation+_currentRequestInfo.downloadLength)<(startOffset - 300*1024))) {
            [self getLocationFilesInfo];
            _currentStartOffset = startOffset;
            _currentLoadingRequestLength = loadingRequest.dataRequest.requestedLength;
            _currentLoadingRequestStartOffset = startOffset;
            long long length = [self requestLengthForStartLocation];
            [self makeRequest:_currentStartOffset requestLength:length];
        }
    }
    return YES;
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest {
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest NS_AVAILABLE(10_9, 7_0) {
    [_resourceLoadingRequests removeObject:loadingRequest];
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge {
    
}

#pragma mark - 下载代理

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (_currentRequestInfo.task == dataTask && !_currentRequestInfo.haveDone) {
        NSFileHandle *writeHandle = [NSFileHandle fileHandleForUpdatingAtPath:_currentRequestInfo.filePath];
        [writeHandle seekToEndOfFile];
        [writeHandle writeData:data];
        _currentRequestInfo.downloadLength += data.length;
        if (_currentRequestInfo.requestLength <= _currentRequestInfo.downloadLength) {
            _currentRequestInfo.haveDone = YES;
        }
        [self setRequestData];
        
    } else {
        [dataTask cancel];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (_currentRequestInfo.task == task) {
        [_currentRequestInfo setHaveDone:YES];
        _currentRequestInfo = nil;
        
        [self getLocationFilesInfo];
        [self setRequestData];
        
        if (!error) {
            _currentStartOffset = _currentRequestInfo.startLocation+_currentRequestInfo.downloadLength;
        }
        long long length = [self requestLengthForStartLocation];
        [self makeRequest:_currentStartOffset requestLength:length];
    }
}

#pragma mark 获取本地信息数组

- (void)getLocationFilesInfo {
    if (_locationFiles == nil) {
        _locationFiles = [NSMutableArray array];
    }
    
    [_locationFiles removeAllObjects];
    
    NSArray *filePaths = [_fileManager subpathsOfDirectoryAtPath:_dictionaryPath error:nil];
    NSLog(@"文件夹文件数目：%lld",(long long)filePaths.count);
    for (NSString *filePath in filePaths) {
        BOOL isDirectory = NO;
        NSString *fullFilePath = [_dictionaryPath stringByAppendingPathComponent:filePath];
        if ([_fileManager fileExistsAtPath:fullFilePath isDirectory:&isDirectory] && !isDirectory) {
            [_locationFiles addObject:[[LocationFileInfo alloc] initWithFilePath:fullFilePath]];
        }
    }
    for (NSInteger i = (_locationFiles.count-1); i>0; i--) {
        for (NSInteger j=(i-1); j>=0; j--) {
            if ([(LocationFileInfo*)[_locationFiles objectAtIndex:i] startLocation]<[(LocationFileInfo*)[_locationFiles objectAtIndex:j] startLocation]) {
                [_locationFiles exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

- (long long)requestLengthForStartLocation {
    for (NSInteger i=0; i<_locationFiles.count; i++) {
        LocationFileInfo *fileInfo = [_locationFiles objectAtIndex:i];
        if (fileInfo.startLocation<=_currentStartOffset && (fileInfo.endLocation >= _currentStartOffset)) {//起点属于某段内容中
            _currentStartOffset = fileInfo.endLocation;
        } else if (fileInfo.startLocation > _currentStartOffset) { //在某段之前
            long long length = fileInfo.startLocation - _currentStartOffset;
            length = MIN(length, _currentLoadingRequestStartOffset+_currentLoadingRequestLength-_currentStartOffset);
            return length;
        }
    }
    long long length = _videoLength - _currentStartOffset;
    length = MIN(length, _currentLoadingRequestStartOffset+_currentLoadingRequestLength-_currentStartOffset);
    return length;
}

- (NSMutableData*)dataFromHaveDownLoad:(NSInteger)startLocation fileLength:(NSInteger)length {
    NSMutableData *fileData = [NSMutableData data];
    NSInteger searchLocaiton = startLocation;
    NSInteger needLength = length;
    for (NSInteger i=0; i<_locationFiles.count; i++) {
        LocationFileInfo *fileInfo = [_locationFiles objectAtIndex:i];
        if (_currentRequestInfo!=nil && _currentRequestInfo.startLocation <= searchLocaiton && (_currentRequestInfo.startLocation+_currentRequestInfo.downloadLength) > searchLocaiton) {
            NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:_currentRequestInfo.filePath];
            
            [handle seekToFileOffset:(searchLocaiton -_currentRequestInfo.startLocation)];
            
            NSData *data = [handle readDataOfLength:(int)(MIN(_currentRequestInfo.downloadLength-((searchLocaiton-_currentRequestInfo.startLocation)), needLength))];
            [handle closeFile];
            searchLocaiton += data.length;
            needLength -= data.length;
            [fileData appendData:data];
        } else if (fileInfo.startLocation <= searchLocaiton && (fileInfo.startLocation+fileInfo.dataLength) > searchLocaiton && needLength>0) {
            NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:fileInfo.filePath];
            
            [handle seekToFileOffset:(searchLocaiton -fileInfo.startLocation)];
            
            NSData *data = [handle readDataOfLength:(int)(MIN(fileInfo.dataLength-((searchLocaiton-fileInfo.startLocation)), needLength))];
            [handle closeFile];
            searchLocaiton += data.length;
            needLength -= data.length;
            [fileData appendData:data];
        }
    }
    return fileData;
}

- (NSArray<LocationFileInfo*>*)haveLoadDataRanges {
    NSMutableArray *array = [NSMutableArray arrayWithArray:_locationFiles];
    if (_currentRequestInfo!=nil) {
        LocationFileInfo *currentInfo = [[LocationFileInfo alloc]initWithFilePath:_currentRequestInfo.filePath];
        [array addObject:currentInfo];
    }
    return array;
}

@end
