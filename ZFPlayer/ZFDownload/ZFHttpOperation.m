//
//  ZFHttpOperation.m
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

#import "ZFHttpOperation.h"
#import "ZFHttpManager.h"
@interface ZFHttpOperation ()  {
    
}

@end

@implementation ZFHttpOperation

#pragma mark - 重写操作方法 -

- (void)start {
    [super start];
    [self startRequest];
}

- (void)cancelledRequest{
    [super cancelledRequest];
}

#pragma mark - 实现网络代理方法 -

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (![self handleResponseError:response]) {
        NSHTTPURLResponse  *  headerResponse = (NSHTTPURLResponse *)response;
        NSDictionary * fields = [headerResponse allHeaderFields];
        NSString * newCookie = fields[@"Set-Cookie"];
        if (newCookie) {
            if([ZFHttpManager shared].cookie == nil){
                [ZFHttpManager shared].cookie = newCookie.copy;
            }else if ([ZFHttpManager shared].cookie != newCookie){
                [ZFHttpManager shared].cookie = nil;
                [ZFHttpManager shared].cookie = newCookie.copy;
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    if (self.requestType == ZFHttpRequestGet) {
        self.recvDataLenght += data.length;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(self, self.recvDataLenght , self.responseDataLenght , self.networkSpeed);
            }
        });
    }
}

- (void)connection:(NSURLConnection *)connection
           didSendBodyData:(NSInteger)bytesWritten
         totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    
    if (self.requestType == ZFHttpRequestFileUpload) {
        [self startSpeedTimer];
        self.orderTimeDataLenght += bytesWritten;
        self.recvDataLenght += bytesWritten;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressBlock) {
                self.progressBlock(self, self.recvDataLenght , totalBytesWritten , self.networkSpeed);
            }
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.didFinishedBlock) {
            self.didFinishedBlock(self ,self.responseData , nil, YES);
         }
        self.didFinishedBlock = nil;
    });
    [self cancelledRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.delegate = nil;
    [self cancelledRequest];
    [self handleReqeustError:error code:ZFGeneralError];
}

@end
