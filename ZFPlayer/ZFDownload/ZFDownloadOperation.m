//
//  ZFDownloadOperation.m
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

#import "ZFDownloadOperation.h"

@interface ZFDownloadOperation () {
    uint64_t                  _localFileSizeLenght;   //文件尺寸大小
    NSFileHandle              * _fileHandle;         //文件句柄
}

@end

@implementation ZFDownloadOperation

- (void)dealloc {
}

#pragma mark - 重写属性方法 -

- (NSString *)saveFileName {
    if (_saveFileName) {
        return _saveFileName;
    }else{
        return [self.strUrl lastPathComponent];
    }
}

- (NSString *)saveFilePath {
    return [_saveFilePath stringByAppendingString:self.saveFileName];
}

- (uint64_t)downloadLenght {
    return self.recvDataLenght;
}

- (uint64_t)fileTotalLenght {
    return _actualFileSizeLenght;
}

- (void)start {
    __autoreleasing  NSError  * error = nil;
    NSFileManager  * fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:self.saveFilePath]) {
        [fm createFileAtPath:self.saveFilePath contents:nil attributes:nil];
    }else {
        _localFileSizeLenght = [[fm attributesOfItemAtPath:self.saveFilePath error:&error] fileSize];
        NSString  * strRange = [NSString stringWithFormat:kZFRequestRange ,_localFileSizeLenght];
        [self.urlRequest setValue:strRange forHTTPHeaderField:@"Range"];
    }
    
    if(error == nil) {
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.saveFilePath];
        [_fileHandle seekToEndOfFile];
    }else {
        NSLog(@"%@",kZFCalculateFolderSpaceAvailableFailError);
    }
    [super start];
    [self startRequest];
}

#pragma mark - 私有方法

- (uint64_t)calculateFreeDiskSpace{
    uint64_t  freeDiskLen = 0;
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager  * fm   = [NSFileManager defaultManager];
    NSDictionary   * dict = [fm attributesOfFileSystemForPath:docPath error:nil];
    if(dict){
        freeDiskLen = [dict[NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return freeDiskLen;
}

- (NSInteger)getCode {
    NSInteger code = ZFGeneralError;
    NSFileManager * fm = [NSFileManager defaultManager];
    if (self.recvDataLenght > 0 ||
        [[fm attributesOfItemAtPath:self.saveFilePath error:nil] fileSize] > 100) {
        code = ZFCancelDownloadError;
    }
    return code;
}

- (void)removeDownloadFile {
    NSFileManager  * fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:self.saveFilePath]){
        [fm removeItemAtPath:self.saveFilePath error:nil];
    }
}

#pragma mark - 公共处理方法 -

- (void)cancelDownloadTaskAndDeleteFile:(BOOL)isDelete {
    _isDeleted = isDelete;
    if(self.responseData.length > 0 && _fileHandle){
        [_fileHandle writeData:self.responseData];
        [self clearResponseData];
    }
    self.requestStatus = ZFHttpRequestFinished;
    [self cancelledRequest];
    if(isDelete){
        [self removeDownloadFile];
    }
    NSError * error = nil;
    if (!isDelete) {
        error = [NSError errorWithDomain:kZFDomain
                            code:[self getCode]
                        userInfo:@{NSLocalizedDescriptionKey:@"下载已取消"}];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock(self, nil , error , NO);
            self.didFinishedBlock = nil;
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
            [self.delegate ZFDownloadDidFinished:self data:nil error:error success:NO];
        }
    });
    
}

- (void)appExitHandleDownloadFile:(NSNotification *)notify {
    if (self.urlConnection) {
        [self connectionDidFinishLoading:self.urlConnection];
    }
}

- (void)cancelledRequest{
    [super cancelledRequest];
    if (_fileHandle) {
        [_fileHandle synchronizeFile];
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
}

- (void)handleReqeustError:(NSError *)error code:(NSInteger)code {
    if (code != ZFCancelDownloadError) {
        [self removeDownloadFile];
    }
    [super handleReqeustError:error code:code];
}

#pragma mark - 实现网络代理方法 -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    BOOL  isCancel = YES;
    NSError  * error = nil;
    NSInteger code = ZFGeneralError;
    if (![self handleResponseError:response]){
        isCancel = NO;
        _actualFileSizeLenght = response.expectedContentLength + _localFileSizeLenght;
        
        if([self calculateFreeDiskSpace] < _actualFileSizeLenght){
            error = [[NSError alloc]initWithDomain:kZFDomain
                                              code:ZFFreeDiskSpaceLack
                                          userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:kZFFreeDiskSapceError,_actualFileSizeLenght]}];
            [self removeDownloadFile];
            code = ZFFreeDiskSpaceLack;
            isCancel = YES;
            goto ZF1;
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(appExitHandleDownloadFile:)
                                                         name:UIApplicationWillTerminateNotification
                                                       object:nil];
            self.recvDataLenght = _localFileSizeLenght;
            [self clearResponseData];
            goto ZF2;
        }
    }else {
    ZF1:
        [self cancelDownloadTaskAndDeleteFile:NO];
        error = [NSError errorWithDomain:kZFDomain code:code userInfo:@{NSLocalizedDescriptionKey:response.description}];
        
    ZF2:
        dispatch_async(dispatch_get_main_queue() , ^{
            if (self.responseBlock) {
                self.responseBlock(self, error ,!isCancel);
                self.responseBlock = nil;
            }else if (self.delegate &&
                      [self.delegate respondsToSelector:@selector(ZFDownloadResponse:error:ok:)]) {
                [self.delegate ZFDownloadResponse:self error:error ok:!isCancel];
            }
        });
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    self.recvDataLenght += data.length;
    self.orderTimeDataLenght += data.length;
    if(self.responseData.length > kZFWriteSizeLenght && _fileHandle){
        [_fileHandle writeData:self.responseData];
        [self clearResponseData];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressBlock) {
            self.progressBlock(self ,self.recvDataLenght , _actualFileSizeLenght , self.networkSpeed);
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(ZFDownloadProgress:recv:total:speed:)]) {
            [self.delegate ZFDownloadProgress:self recv:self.recvDataLenght total:_actualFileSizeLenght speed:self.networkSpeed];
        }
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(_fileHandle){
        [_fileHandle writeData:self.responseData];
        [self clearResponseData];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock(self, nil , nil, YES);
            self.didFinishedBlock = nil;
        }else if (self.delegate &&
                  [self.delegate respondsToSelector:@selector(ZFDownloadDidFinished:data:error:success:)]) {
            [self.delegate ZFDownloadDidFinished:self data:nil error:nil success:YES];
        }
    });
    
    [self cancelledRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self cancelledRequest];
    [self handleReqeustError:error code:[self getCode]];
}

@end
