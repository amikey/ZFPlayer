//
//  ZFBaseOperation.m
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

#import "ZFBaseOperation.h"
#import "ZFHttpManager.h"

NSTimeInterval const kZFRequestTimeout = 60;
NSTimeInterval const kZFDownloadSpeedDuring = 1.5;
CGFloat        const kZFWriteSizeLenght = 1024 * 1024;
NSString  * const  kZFDomain = @"ZFHTTP_OPERATION";
NSString  * const  kZFInvainUrlError = @"无效的url:%@";
NSString  * const  kZFCalculateFolderSpaceAvailableFailError = @"计算文件夹存储空间失败";
NSString  * const  kZFErrorCode = @"错误码:%ld";
NSString  * const  kZFFreeDiskSapceError = @"磁盘可用空间不足需要存储空间:%llu";
NSString  * const  kZFRequestRange = @"bytes=%lld-";
NSString  * const  kZFUploadCode = @"ZF";

@interface ZFBaseOperation () {
    NSTimer * _speedTimer;
}

@end

@implementation ZFBaseOperation

#pragma mark - 重写属性方法 -
- (void)setStrUrl:(NSString *)strUrl {
    _strUrl = nil;
    _strUrl = strUrl.copy;
    NSString * newUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                              (CFStringRef)_strUrl,
                                                                                              (CFStringRef)@"!$&'()*-,-./:;=?@_~%#[]",
                                                                                              NULL,
                                                                                              kCFStringEncodingUTF8));
    _urlRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:newUrl]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = kZFRequestTimeout;
        _requestType = ZFHttpRequestGet;
        _requestStatus = ZFHttpRequestNone;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
        _responseData = [NSMutableData data];
    }
    return self;
}

- (void)dealloc{
    [self cancelledRequest];
}


#pragma mark - 重写队列操作方法 -

- (void)start {
    if ([NSURLConnection canHandleRequest:self.urlRequest]) {
        self.urlRequest.timeoutInterval = self.timeoutInterval;
        self.urlRequest.cachePolicy = self.cachePolicy;
        [_urlRequest setValue:self.contentType forHTTPHeaderField: @"Content-Type"];
        switch (self.requestType) {
            case ZFHttpRequestGet:
            case ZFHttpRequestFileDownload:{
                [_urlRequest setHTTPMethod:@"GET"];
            }
                break;
            case ZFHttpRequestPost:
            case ZFHttpRequestFileUpload:{
                [_urlRequest setHTTPMethod:@"POST"];
                if([ZFHttpManager shared].cookie && [ZFHttpManager shared].cookie.length > 0) {
                    [_urlRequest setValue:[ZFHttpManager shared].cookie forHTTPHeaderField:@"Cookie"];
                }
                if (self.postParam != nil) {
                    NSData * paramData = nil;
                    if ([self.postParam isKindOfClass:[NSData class]]) {
                        paramData = (NSData *)self.postParam;
                    }else if ([self.postParam isKindOfClass:[NSString class]]) {
                        paramData = [((NSString *)self.postParam) dataUsingEncoding:self.encoderType allowLossyConversion:YES];
                    }
                    if (paramData) {
                        [_urlRequest setHTTPBody:paramData];
                        [_urlRequest setValue:[NSString stringWithFormat:@"%zd", paramData.length] forHTTPHeaderField: @"Content-Length"];
                    }
                }
            }
                break;
            default:
                break;
        }
        if(self.urlConnection == nil){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.urlConnection = [[NSURLConnection alloc]initWithRequest:_urlRequest delegate:self startImmediately:NO];
        }
    }else {
        [self handleReqeustError:nil code:ZFGeneralError];
    }
}

- (BOOL)isExecuting {
    return _requestStatus == ZFHttpRequestExecuting;
}

- (BOOL)isCancelled {
    return _requestStatus == ZFHttpRequestCanceled ||
    _requestStatus == ZFHttpRequestFinished;
}

- (BOOL)isFinished {
    return _requestStatus == ZFHttpRequestFinished;
}

- (BOOL)isConcurrent{
    return YES;
}


#pragma mark - 公共方法 -

- (void)calculateNetworkSpeed {
    float downloadSpeed = (float)_orderTimeDataLenght / (kZFDownloadSpeedDuring * 1024.0);
    _networkSpeed = [NSString stringWithFormat:@"%.1fKB/s", downloadSpeed];
    if (downloadSpeed >= 1024.0) {
        downloadSpeed = ((float)_orderTimeDataLenght / 1024.0) / (kZFDownloadSpeedDuring * 1024.0);
        _networkSpeed = [NSString stringWithFormat:@"%.1fMB/s",downloadSpeed];
    }
    _orderTimeDataLenght = 0;
}


- (void)clearResponseData {
    [self.responseData resetBytesInRange:NSMakeRange(0, self.responseData.length)];
    [self.responseData setLength:0];
}

- (void)startRequest {
    NSRunLoop * urnLoop = [NSRunLoop currentRunLoop];
    [_urlConnection scheduleInRunLoop:urnLoop forMode:NSDefaultRunLoopMode];
    [self willChangeValueForKey:@"isExecuting"];
    _requestStatus = ZFHttpRequestExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    [_urlConnection start];
    [urnLoop run];
}

- (void)addDependOperation:(ZFBaseOperation *)operation {
    [self addDependency:operation];
}

- (void)startSpeedTimer {
    if (!_speedTimer && (_requestType == ZFHttpRequestFileUpload ||
                         _requestType == ZFHttpRequestFileDownload ||
                         _requestType == ZFHttpRequestGet)) {
        _speedTimer = [NSTimer scheduledTimerWithTimeInterval:kZFDownloadSpeedDuring
                                                       target:self
                                                     selector:@selector(calculateNetworkSpeed)
                                                     userInfo:nil
                                                      repeats:YES];
        [self calculateNetworkSpeed];
    }
}

- (BOOL)handleResponseError:(NSURLResponse * )response {
    BOOL isError = NO;
    NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
    if(headerResponse.statusCode >= 400){
        isError = YES;
        self.requestStatus = ZFHttpRequestFinished;
        if (self.requestType != ZFHttpRequestFileDownload) {
            [self cancelledRequest];
            NSError * error = [NSError errorWithDomain:kZFDomain
                                                  code:ZFGeneralError
                                              userInfo:@{NSLocalizedDescriptionKey:
                                                             [NSString stringWithFormat:kZFErrorCode,
                                                              (long)headerResponse.statusCode]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.didFinishedBlock) {
                    self.didFinishedBlock(self, nil , error , NO);
                    self.didFinishedBlock = nil;
                }else if (self.delegate &&
                          [self.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
                    if (headerResponse.statusCode == 404) {
                        [[ZFHttpManager shared].failedUrls addObject: self.strUrl];
                    }
                    [self.delegate ZFDownloadDidFinished:(ZFDownloadOperation *)self data:nil error:error success:NO];
                }
            });
        }
    }else {
        _responseDataLenght = headerResponse.expectedContentLength;
        [self startSpeedTimer];
    }
    return isError;
}

- (void)endRequest {
    self.didFinishedBlock = nil;
    self.progressBlock = nil;
    [self cancelledRequest];
}

- (void)cancelledRequest{
    if (_urlConnection) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _requestStatus = ZFHttpRequestFinished;
        [self willChangeValueForKey:@"isCancelled"];
        [self willChangeValueForKey:@"isFinished"];
        [_urlConnection cancel];
        _urlConnection = nil;
        [self didChangeValueForKey:@"isCancelled"];
        [self didChangeValueForKey:@"isFinished"];
        if (_requestType == ZFHttpRequestFileUpload ||
            _requestType == ZFHttpRequestFileDownload) {
            if (_speedTimer) {
                [_speedTimer invalidate];
                [_speedTimer fire];
                _speedTimer = nil;
            }
        }
    }
}

- (void)handleReqeustError:(NSError *)error code:(NSInteger)code {
    if(error == nil){
        error = [[NSError alloc]initWithDomain:kZFDomain
                                          code:code
                                      userInfo:@{NSLocalizedDescriptionKey:
                                                     [NSString stringWithFormat:kZFInvainUrlError,self.strUrl]}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock (self, nil, error , NO);
            self.didFinishedBlock = nil;
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
            [self.delegate ZFDownloadDidFinished:(ZFDownloadOperation *)self data:nil error:error success:NO];
        }
    });
    
}

@end
