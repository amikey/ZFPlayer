//
//  ZFHttpManager.m
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

#import "ZFHttpManager.h"
#import <MobileCoreServices/MobileCoreServices.h>

const NSInteger kZFDefaultDownloadNumber = 3;

@interface ZFHttpManager () {
    NSOperationQueue     * _httpOperationQueue;
    NSOperationQueue     * _fileDownloadOperationQueue;
    Reachability         * _internetReachability;
    
    NSMutableArray       * _fileDataArr;
    NSMutableArray       * _uploadParamArr;
    NSMutableData        * _uploadPostData;
}


@end

@implementation ZFHttpManager

+ (nonnull instancetype)shared {
    static  ZFHttpManager * zfHttpManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zfHttpManager = [[ZFHttpManager alloc] init];
    });
    return zfHttpManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _httpOperationQueue = [NSOperationQueue new];
        _httpOperationQueue.maxConcurrentOperationCount = 20;
        _failedUrls = [NSMutableSet set];
        _encoderType = NSUTF8StringEncoding;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _contentType = @"application/x-www-form-urlencoded";
    }
    return self;
}



#pragma mark - 网络状态监听 -
- (void)registerNetworkStatusMoniterEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    _internetReachability = [Reachability reachabilityForInternetConnection];
    [_internetReachability startNotifier];
    [self updateInterfaceWithReachability:_internetReachability];
}

- (void)updateInterfaceWithReachability:(Reachability*)internetReachability{
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    self.networkStatus = netStatus;
    switch (netStatus) {
        case NotReachable:{
            for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
                [downloadOperation cancelDownloadTaskAndDeleteFile:NO];
            }
            for (ZFBaseOperation * httpOperation in _httpOperationQueue.operations) {
                [httpOperation cancelledRequest];
            }
            [[[UIAlertView alloc]initWithTitle:nil
                                       message:@"当前网络不可用请检查网络设置"
                                      delegate:nil cancelButtonTitle:@"确定"
                             otherButtonTitles:nil, nil] show];
        }
            break;
        case ReachableViaWiFi:
            NSLog(@"====当前网络状态为Wifi=======");
            break;
        case ReachableViaWWAN:
            NSLog(@"====当前网络状态为3G=======");
            break;
    }
}

- (void)reachabilityChanged:(NSNotification *)notifiy{
    Reachability* curReach = [notifiy object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

#pragma mark - get请求 -

- (nullable ZFHttpOperation *)get:(nonnull NSString *)strUrl
               didFinished:(nullable ZFDidFinished)finishedBlock {
    return [self get:strUrl process:nil didFinished:finishedBlock];
}

- (nullable ZFHttpOperation *)get:(nonnull NSString *)strUrl
                   process:(nullable ZFProgress) processBlock
               didFinished:(nullable ZFDidFinished)finishedBlock {
    ZFHttpOperation * getOperation = nil;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        getOperation = [ZFHttpOperation new];
        getOperation.requestType = ZFHttpRequestGet;
        getOperation.progressBlock = processBlock;
        getOperation.strUrl = strUrl;
        __weak typeof(self) weakSelf = self;
        getOperation.didFinishedBlock = ^(ZFBaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
            if (!isSuccess && error.code == 404) {
                [weakSelf.failedUrls addObject:strUrl];
            }
            if (finishedBlock) {
                finishedBlock(operation , data , error , isSuccess);
            }
        };
        [self setHttpOperation:getOperation];
        [_httpOperationQueue addOperation:getOperation];
    }else {
        if (finishedBlock) {
            __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
            finishedBlock(nil , nil , error , NO);
        }
    }
    return getOperation;
}

#pragma mark - post请求 -

- (nullable ZFHttpOperation *)post:(nonnull NSString *)strUrl
                      param:(nullable NSString *)param
                didFinished:(nullable ZFDidFinished)finishedBlock {
    return [self post:strUrl param:param process:nil didFinished:finishedBlock];
}

- (nullable ZFHttpOperation *)post:(nonnull NSString *)strUrl
                      param:(nullable NSString *)param
                    process:(nullable ZFProgress) processBlock
                didFinished:(nullable ZFDidFinished)finishedBlock {
    ZFHttpOperation * postOperation = nil ;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        postOperation = [ZFHttpOperation new];
        postOperation.requestType = ZFHttpRequestPost;
        postOperation.progressBlock = processBlock;
        postOperation.postParam = param;
        postOperation.strUrl = strUrl;
        __weak typeof(self) weakSelf = self;
        postOperation.didFinishedBlock = ^(ZFBaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
            if (!isSuccess && error.code == 404) {
                [weakSelf.failedUrls addObject:strUrl];
            }
            if (finishedBlock) {
                finishedBlock(operation , data , error , isSuccess);
            }
        };
        [self setHttpOperation:postOperation];
        [_httpOperationQueue addOperation:postOperation];
    }else {
        if (finishedBlock) {
            __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
            finishedBlock(nil , nil , error , NO);
        }
    }

    return postOperation;
}

#pragma mark - 文件上传 -

- (nullable ZFHttpOperation *)upload:(nonnull NSString *)strUrl
                        param:(nullable NSDictionary *)paramDict
                  didFinished:(nullable ZFDidFinished)finishedBlock {
    return [self upload:strUrl
                  param:paramDict
                process:nil
            didFinished:finishedBlock];
}
/**
 说明:文件上传开始
 strUrl:上传路径
 param:上传附带参数
 callBack：上传结束回调
 */
- (nullable ZFHttpOperation *)upload:(nonnull NSString *)strUrl
                        param:(nullable NSDictionary *)paramDict
                      process:(nullable ZFProgress) processBlock
                  didFinished:(nullable ZFDidFinished)finishedBlock {
    [self setPostParamDict:paramDict];
    [self buildMultipartFormDataPostBody];
    ZFHttpOperation * uploadOperation = nil ;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        uploadOperation = [ZFHttpOperation new];
        [self setHttpOperation:uploadOperation];
        uploadOperation.requestType = ZFHttpRequestFileUpload;
        uploadOperation.progressBlock = processBlock;
        uploadOperation.strUrl = strUrl;
        uploadOperation.postParam = _uploadPostData;
        __weak typeof(self) weakSelf = self;
        uploadOperation.didFinishedBlock = ^(ZFBaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
            [_uploadParamArr removeAllObjects];
            [_fileDataArr removeAllObjects];
            [_uploadPostData resetBytesInRange:NSMakeRange(0, _uploadPostData.length)];
            [_uploadPostData setLength:0];
            if (!isSuccess && error.code == 404) {
                [weakSelf.failedUrls addObject:strUrl];
            }
            if (finishedBlock) {
                finishedBlock(operation , data , error , isSuccess);
            }
        };
        NSString * charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
        uploadOperation.contentType = [NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, kZFUploadCode];
        [_httpOperationQueue addOperation:uploadOperation];
    }else {
        if (finishedBlock) {
            __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
            finishedBlock(nil , nil , error , NO);
        }
    }
    return uploadOperation;
}

#pragma mark - 文件下载 -

- (nullable ZFDownloadOperation *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                    delegate:(nullable id<ZFDownloadDelegate>)delegate {
    return [self download:strUrl savePath:savePath saveFileName:nil delegate:delegate];
}


- (nullable ZFDownloadOperation *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    delegate:(nullable id<ZFDownloadDelegate>)delegate {
    
    ZFDownloadOperation  * downloadOperation = nil;
    NSString * fileName = nil;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        fileName = [self handleFileName:saveFileName url:strUrl];
        for (ZFDownloadOperation * tempDownloadOperation in _fileDownloadOperationQueue.operations) {
            if ([fileName isEqualToString:tempDownloadOperation.saveFileName]){
                __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (delegate && [delegate respondsToSelector:@selector(ZFDownloadResponse:error:ok:)]) {
                    [delegate ZFDownloadResponse:tempDownloadOperation error:error ok:NO];
                } else if (delegate && [delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
                    [delegate ZFDownloadDidFinished:tempDownloadOperation data:nil error:error success:NO];
                }
                return tempDownloadOperation;
            }
        }
        if([self createFileSavePath:savePath]) {
            downloadOperation = [ZFDownloadOperation new];
            downloadOperation.requestType = ZFHttpRequestGet;
            downloadOperation.saveFileName = fileName;
            downloadOperation.saveFilePath = savePath;
            downloadOperation.delegate = delegate;
            downloadOperation.strUrl = strUrl;
            [self setHttpOperation:downloadOperation];
            [_fileDownloadOperationQueue addOperation:downloadOperation];
        }
    }else {
        __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
        if (delegate &&
            [delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
            [delegate ZFDownloadDidFinished:downloadOperation data:nil error:error success:NO];
        }
    }
    return downloadOperation;
}

/**
 参数说明：
 url:下载路径
 savePath:文件本地存储路径
 delegate:下载状态监控代理
 */
- (nullable ZFDownloadOperation *)download:(nonnull NSString *)strUrl
                           savePath:(nonnull NSString *)savePath
                            response:(nullable ZFResponse) responseBlock
                            process:(nullable ZFProgress) processBlock
                        didFinished:(nullable ZFDidFinished) finishedBlock {
    
    return [self download:strUrl
                 savePath:savePath
             saveFileName:nil
                 response:responseBlock
                  process:processBlock
              didFinished:finishedBlock];
}

/**
 参数说明：
 url:下载路径
 savePath:文件本地存储路径
 savefileName:下载要存储的文件名
 delegate:下载状态监控代理
 */
- (nullable ZFDownloadOperation *)download:(nonnull NSString *)strUrl
                                    savePath:(nonnull NSString *)savePath
                                saveFileName:(nullable NSString *)saveFileName
                                    response:(nullable ZFResponse) responseBlock
                                     process:(nullable ZFProgress) processBlock
                                 didFinished:(nullable ZFDidFinished) finishedBlock {

    ZFDownloadOperation  * downloadOperation = nil;
    NSString * fileName = nil;
    if (strUrl != nil && ![_failedUrls containsObject:strUrl]) {
        fileName = [self handleFileName:saveFileName url:strUrl];
        for (ZFDownloadOperation * tempDownloadOperation in _fileDownloadOperationQueue.operations) {
            if ([fileName isEqualToString:tempDownloadOperation.saveFileName]){
                __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:已经在下载中",fileName]];
                if (responseBlock) {
                    responseBlock(tempDownloadOperation, error, NO);
                } else if (finishedBlock) {
                    finishedBlock(tempDownloadOperation ,nil, error, NO);
                }
                return tempDownloadOperation;
            }
        }
        if([self createFileSavePath:savePath]) {
            downloadOperation = [ZFDownloadOperation new];
            downloadOperation.requestType = ZFHttpRequestGet;
            downloadOperation.saveFileName = fileName;
            downloadOperation.saveFilePath = savePath;
            downloadOperation.progressBlock = processBlock;
            downloadOperation.responseBlock = responseBlock;
            downloadOperation.strUrl = strUrl;
            __weak typeof(self) weakSelf = self;
            downloadOperation.didFinishedBlock = ^(ZFBaseOperation *operation,
                                                   NSData *data,
                                                   NSError *error,
                                                   BOOL isSuccess) {
                if (!isSuccess && error.code == 404) {
                    [weakSelf.failedUrls addObject:strUrl];
                }
                if (finishedBlock) {
                    finishedBlock(operation , data , error , isSuccess);
                }
            };
            [self setHttpOperation:downloadOperation];
            [_fileDownloadOperationQueue addOperation:downloadOperation];
        }
    }else {
        __autoreleasing NSError * error = [self error:[NSString stringWithFormat:@"%@:请求失败",strUrl]];
        if (responseBlock) {
            responseBlock(downloadOperation , error , NO);
        }else if (finishedBlock) {
            finishedBlock(downloadOperation , nil , error , NO);
        }
    }
    return downloadOperation;
}



#pragma mark - 文件上传工具方法 -

/*
 说明:添加上传文件数据,可多次调用添加上传多个文件
 data:可以是二进制数据也可以是本地文件路径
 fileName:文件名称
 mimeType:文件类型如图片(image/jpeg)
 key：关键字名称这个必须和服务端对应
 */
- (void)addUploadFileData:(nonnull NSObject *)data
             withFileName:(nonnull NSString *)fileName
                 mimeType:(nonnull NSString *)mimeType
                   forKey:(nonnull NSString *)key {
    
    if (_fileDataArr == nil) {
        _fileDataArr = [NSMutableArray array];
    }
    if (!mimeType) {
        mimeType = @"application/octet-stream";
    }
    
    NSMutableDictionary *fileInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    [fileInfo setValue:key forKey:@"key"];
    [fileInfo setValue:fileName forKey:@"fileName"];
    [fileInfo setValue:mimeType forKey:@"contentType"];
    [fileInfo setValue:data forKey:@"data"];
    
    [_fileDataArr addObject:fileInfo];
}

/**
 说明:添加上传文件路径，可多次调用添加上传多个文件
 filePath：文件路径
 key：关键字名称这个必须和服务端对应
 */
- (void)addUploadFile:(nonnull NSString *)filePath
               forKey:(nonnull NSString *)key {
    NSFileManager  * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:filePath]){
        NSString  * fileName = filePath.lastPathComponent;
        NSString  * mimeType = [self mimeTypeForFileAtPath:filePath];
        [self addUploadFileData:filePath withFileName:fileName mimeType:mimeType forKey:key];
    }
}

#pragma mark - 文件下载工具方法 -

- (BOOL)waitingDownload {
    return _fileDownloadOperationQueue.operations.count > kZFDefaultDownloadNumber;
}

- (nullable NSString *)handleFileName:(NSString *)saveFileName url:(NSString *)strUrl {
    if (!_fileDownloadOperationQueue) {
        _fileDownloadOperationQueue = [NSOperationQueue new];
        _fileDownloadOperationQueue.maxConcurrentOperationCount = kZFDefaultDownloadNumber;
    }
    NSString * fileName = saveFileName;
    if(saveFileName){
        NSString * format = [self fileFormatWithUrl:strUrl];
        if(format && ![format isEqualToString:[NSString stringWithFormat:@".%@",
                                    [[saveFileName componentsSeparatedByString:@"."] lastObject]]]){
            fileName = [NSString stringWithFormat:@"%@%@",saveFileName,format];
        }
    }
    return fileName;
}

//返回指定文件名下载对象
- (nullable ZFDownloadOperation *)downloadOperationWithFileName:(nonnull NSString *)fileName {
    ZFDownloadOperation * downloadOperation = nil;
    for (ZFDownloadOperation * tempDownloadOperation in _fileDownloadOperationQueue.operations) {
        if([tempDownloadOperation.saveFileName isEqualToString:fileName]){
            downloadOperation = tempDownloadOperation;
            break;
        }
    }
    return downloadOperation;
}

/**
 note:该方法必须在开始下载之前调用
 说明：
 设置最大下载数量
 */
- (void)setMaxDownloadQueueCount:(NSUInteger)count {
    _fileDownloadOperationQueue.maxConcurrentOperationCount = count;
}

/**
 说明:返回下载中心最大同时下载操作个数
 */
- (NSInteger)currentDownloadCount {
    return _fileDownloadOperationQueue.maxConcurrentOperationCount;
}

/**
 说明：
 取消所有正下载并是否取消删除文件
 */
- (void)cancelAllDownloadTaskAndDelFile:(BOOL)isDelete {
    for (ZFDownloadOperation * operation in _fileDownloadOperationQueue.operations) {
        [operation cancelDownloadTaskAndDeleteFile:isDelete];
    }
}

/**
 说明：
 取消指定正下载url的下载
 */
- (void)cancelDownloadWithDownloadUrl:(nonnull NSString *)strUrl deleteFile:(BOOL)isDelete {
    for(ZFDownloadOperation * operation in _fileDownloadOperationQueue.operations){
        if ([operation.strUrl isEqualToString:strUrl]) {
            [operation cancelDownloadTaskAndDeleteFile:isDelete];
            break;
        }
    }
}

/**
 说明：
 取消指定正下载文件名的下载
 */
- (void)cancelDownloadWithFileName:(nonnull NSString *)fileName deleteFile:(BOOL)isDelete {
    for(ZFDownloadOperation * operation in _fileDownloadOperationQueue.operations){
        if([operation.saveFileName isEqualToString:fileName]){
            [operation cancelDownloadTaskAndDeleteFile:isDelete];
            break;
        }
    }
}


/**
 说明：
 替换当前代理通过要下载的文件名
 使用情景:(当从控制器B进入到控制器C然后在控制器C中进行下载，然后下载过程中突然退出到控制器B，
 在又进入到控制器C，这个时候还是在下载但是代理对象和之前的那个控制器C不是一个对象所以要替换)
 */


- (ZFDownloadOperation *)replaceCurrentDownloadOperationBlockResponse:(nullable ZFResponse)responseBlock
                                             process:(nullable ZFProgress)processBlock
                                         didFinished:(nullable ZFDidFinished)didFinishedBlock
                                            fileName:(nonnull NSString *)fileName {
    for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.saveFileName isEqualToString:fileName]){
            downloadOperation.delegate = nil;
            downloadOperation.progressBlock = processBlock;
            downloadOperation.responseBlock = responseBlock;
            downloadOperation.didFinishedBlock = didFinishedBlock;
            return downloadOperation;
        }
    }
    return nil;
}

- (ZFDownloadOperation *)replaceCurrentDownloadOperationDelegate:(nullable id<ZFDownloadDelegate>)delegate
                                       fileName:(nonnull NSString *)fileName {
    for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.saveFileName isEqualToString:fileName]){
            downloadOperation.progressBlock = nil;
            downloadOperation.responseBlock = nil;
            downloadOperation.didFinishedBlock = nil;
            downloadOperation.delegate = delegate;
            return downloadOperation;
        }
    }
    return nil;
}

//替换所有当前下载代理
- (ZFDownloadOperation *)replaceAllDownloadOperationBlockResponse:(nullable ZFResponse)responseBlock
                                         process:(nullable ZFProgress)processBlock
                                     didFinished:(nullable ZFDidFinished)didFinishedBlock {
    if (_fileDownloadOperationQueue.operations.count > 0) {
        for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
            downloadOperation.delegate = nil;
            downloadOperation.progressBlock = processBlock;
            downloadOperation.responseBlock = responseBlock;
            downloadOperation.didFinishedBlock = didFinishedBlock;
        }
        return nil;
    }
    return nil;
}

- (ZFDownloadOperation *)replaceAllDownloadOperationDelegate:(nullable id<ZFDownloadDelegate>)delegate {
    if (_fileDownloadOperationQueue.operations.count > 0) {
        for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
            downloadOperation.progressBlock = nil;
            downloadOperation.responseBlock = nil;
            downloadOperation.didFinishedBlock = nil;
            downloadOperation.delegate = delegate;
        }
        return nil;
    }
    return nil;
}


/**
 说明：
 通过要下载的文件名来判断当前是否在进行下载任务
 */
- (BOOL)existDownloadOperationTaskWithFileName:(nonnull NSString *)fileName {
    BOOL  result = NO;
    for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.saveFileName isEqualToString:fileName]){
            result = YES;
            break;
        }
    }
    return result;
}

- (BOOL)existDownloadOperationTaskWithUrl:(nonnull NSString *)strUrl {
    BOOL  result = NO;
    for (ZFDownloadOperation * downloadOperation in _fileDownloadOperationQueue.operations) {
        if([downloadOperation.strUrl isEqualToString:strUrl]){
            result = YES;
            break;
        }
    }
    return result;
}

#pragma mark - 公共方法 -

- (void)cancelHttpRequestWithUrl:(nonnull NSString *)url {
    for (ZFBaseOperation * operation in _httpOperationQueue.operations) {
        if ([operation.strUrl isEqualToString:url]) {
            [operation endRequest];
        }
    }
}

- (nullable NSString *)fileFormatWithUrl:(nonnull NSString *)downloadUrl {
    NSArray  * strArr = [downloadUrl componentsSeparatedByString:@"."];
    if(strArr && strArr.count > 0){
        NSString * suffix = strArr.lastObject;
        if (suffix.length > 7) {
            return nil;
        }
        return [NSString stringWithFormat:@".%@",strArr.lastObject].lowercaseString;
    }else{
        return nil;
    }
}

- (nonnull NSString*)createHttpParam:(nonnull NSDictionary *)paramDictionary {
    NSString *postString=@"";
    for(NSString *key in [paramDictionary allKeys]){
        NSString *value = [paramDictionary objectForKey:key];
        postString = [postString stringByAppendingFormat:@"%@=%@&",key,value];
    }
    if([postString length] > 1){
        postString = [postString substringToIndex:[postString length]-1];
    }
    return postString;
}

#pragma mark - 私有方法 -

- (__autoreleasing NSError *)error:(nonnull NSString *)message {
    __autoreleasing NSError  * error = [[NSError alloc]initWithDomain:kZFDomain
                                                                 code:ZFGeneralError
                                                             userInfo:@{NSLocalizedDescriptionKey:
                                                                            message}];
    return error;
}

- (void)setHttpOperation:(ZFBaseOperation *)httpOperation {
    httpOperation.encoderType = _encoderType;
    httpOperation.cachePolicy = _cachePolicy;
    httpOperation.contentType = _contentType;
    httpOperation.timeoutInterval = _timeoutInterval;
}

- (BOOL)createFileSavePath:(nonnull NSString *)savePath {
    BOOL  result = YES;
    if(savePath != nil && savePath.length > 0){
        NSFileManager  * fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:savePath]){
            __autoreleasing NSError *error = nil;
            [fm createDirectoryAtPath:savePath
          withIntermediateDirectories:YES
                           attributes:@{NSFileProtectionKey : NSFileProtectionNone}
                                error:&error];
            if(error){
                result = NO;
            }
        }
    }else{
        result = NO;
    }
    return result;
}

#pragma mark - 上传文件私有方法

- (nullable NSString *)mimeTypeForFileAtPath:(nullable NSString *)path{
    if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return  (__bridge NSString *)MIMEType;
}


- (void)appendPostString:(nullable NSString *)string{
    if(_uploadPostData == nil){
        _uploadPostData = [NSMutableData data];
    }
    [_uploadPostData appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}


- (void)setPostParamDict:(nullable NSDictionary *)paramDict{
    
    if (paramDict == nil) {
        return;
    }
    if (_uploadParamArr == nil) {
        _uploadParamArr = [NSMutableArray array];
    }else{
        [_uploadParamArr removeAllObjects];
    }
    NSArray  * keyArr = paramDict.allKeys;
    if(keyArr){
        for (NSString * strKey in keyArr) {
            NSMutableDictionary *keyValuePair = [NSMutableDictionary dictionaryWithCapacity:2];
            [keyValuePair setValue:strKey forKey:@"key"];
            [keyValuePair setValue:[[paramDict objectForKey:strKey] description] forKey:@"value"];
            [_uploadParamArr addObject:keyValuePair];
        }
    }
}

- (void)appendPostData:(nullable NSData *)data{
    if ([data length] == 0) {
        return;
    }
    if(_uploadPostData == nil){
        _uploadPostData = [NSMutableData data];
    }
    [_uploadPostData appendData:data];
}

- (void)appendPostDataFromFile:(nullable NSString *)file {
    if(_uploadPostData == nil){
        _uploadPostData = [NSMutableData data];
    }
    NSFileManager  * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:file]){
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:file];
        [stream open];
        NSUInteger bytesRead;
        while ([stream hasBytesAvailable]) {
            unsigned char buffer[1024 * 256];
            bytesRead = [stream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == 0) {
                break;
            }
            [_uploadPostData appendData:[NSData dataWithBytes:buffer length:bytesRead]];
        }
        [stream close];
    }
}

- (void)buildMultipartFormDataPostBody {
    if(_uploadParamArr == nil){
        _uploadParamArr = [NSMutableArray array];
    }
    NSString *stringBoundary = kZFUploadCode;
    [self appendPostString:[NSString stringWithFormat:@"--%@\r\n",stringBoundary]];
    NSUInteger i = 0;
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    // 设置文件数据
    for (NSDictionary *val in _fileDataArr) {
        
        [self appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", val[@"key"], val[@"fileName"]]];
        [self appendPostString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", val[@"contentType"]]];
        
        id data = val[@"data"];
        if ([data isKindOfClass:[NSString class]]) {
            [self appendPostDataFromFile:data];
        } else {
            [self appendPostData:data];
        }
        [self appendPostString:@"\r\n"];
        i++;
        //添加分隔符在边界除了最后一个元素
        if (i != [_fileDataArr count]) {
            [self appendPostString:endItemBoundary];
        }
    }
    [self appendPostString:endItemBoundary];
    //设置普通参数
    i = 0;
    for (NSDictionary *val in _uploadParamArr) {
        [self appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",val[@"key"]]];
        [self appendPostString:val[@"value"]];
        [self appendPostString:@"\r\n"];
        i++;
        //添加分隔符在边界除了最后一个元素
        if (i != _uploadParamArr.count) {
            [self appendPostString:endItemBoundary];
        }
    }
    [self appendPostString:[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary]];
}

@end
