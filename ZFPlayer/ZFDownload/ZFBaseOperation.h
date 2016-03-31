//
//  ZFBaseOperation.h
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
#import <UIKit/UIKit.h>

extern  NSTimeInterval const kZFRequestTimeout;
extern  NSTimeInterval const kZFDownloadSpeedDuring;
extern  CGFloat   const kZFWriteSizeLenght;

extern  NSString * const _Nullable kZFDomain;
extern  NSString * const _Nullable kZFInvainUrlError;
extern  NSString * const _Nullable kZFCalculateFolderSpaceAvailableFailError;
extern  NSString * const _Nullable kZFErrorCode;
extern  NSString * const _Nullable kZFFreeDiskSapceError;
extern  NSString * const _Nullable kZFRequestRange;
extern  NSString * const _Nullable kZFUploadCode;

/**
 * ZFHttpRequestStatus  网络请求状态枚举标识
 */

typedef NS_OPTIONS(NSUInteger, ZFHttpRequestStatus) {
    ZFHttpRequestNone = 1 << 0,
    ZFHttpRequestExecuting = 1 << 1,
    ZFHttpRequestCanceled = 1 << 2,
    ZFHttpRequestFinished = 1 << 3
};

/**
 * ZFHttpRequestStatus  网络请求类型枚举标识
 */

typedef NS_OPTIONS(NSUInteger, ZFHttpRequestType) {
    ZFHttpRequestGet = 1 << 4,
    ZFHttpRequestPost = 1 << 5,
    ZFHttpRequestFileDownload = 1 << 6,
    ZFHttpRequestFileUpload = 1 << 7
};


/**
 * ZFHttpRequestStatus  网络请求错误枚举标识
 */

typedef NS_OPTIONS(NSUInteger, ZFHttpErrorType) {
    ZFFreeDiskSpaceLack = 2 << 0,
    ZFGeneralError = 2 << 1,
    ZFCancelDownloadError = 2 << 2,
    ZFNetWorkError = 2 << 3
};

@class ZFBaseOperation;
@class ZFDownloadOperation;

/**
 * ZFDownloadDelegate  网络下载回调代理
 */

@protocol  ZFDownloadDelegate<NSObject>

@optional

/**
 * 下载应答回调方法
 * @param: operation 当前下载操作对象
 * @param: error 响应错误对象
 * @param: isOK 是否可以下载
 */

- (void)ZFDownloadResponse:(nonnull ZFDownloadOperation *)operation
                      error:(nullable NSError *)error
                         ok:(BOOL)isOK;

/**
 * 下载过程回调方法
 * @param: operation 当前下载操作对象
 * @param: recvLength 当前接收下载字节数
 * @param: totalLength 总字节数
 * @param: speed 下载速度
 */

- (void)ZFDownloadProgress:(nonnull ZFDownloadOperation *)operation
                       recv:(uint64_t)recvLength
                      total:(uint64_t)totalLength
                      speed:(nullable NSString *)speed;

/**
 * 下载结束回调方法
 * @param: operation 当前下载操作对象
 * @param: data 当前接收数据 （在requestType = ZFHttpRequestGet 该参数才有用 否则为nil）
 * @param: error 下载错误对象
 * @param: success 下载是否成功
 */

- (void)ZFDownloadDidFinished:(nonnull ZFDownloadOperation *)operation
                          data:(nullable NSData *)data
                         error:(nullable NSError *)error
                       success:(BOOL)isSuccess;

@end


/**
 * 下载结束回调块
 * @param: operation 当前下载操作对象
 * @param: data 当前接收数据 （在requestType = ZFHttpRequestGet 该参数才有用 否则为nil）
 * @param: error 下载错误对象
 * @param: success 下载是否成功
 */

typedef void (^ZFDidFinished) (ZFBaseOperation * _Nullable operation ,NSData * _Nullable data ,  NSError * _Nullable  error , BOOL isSuccess);

/**
 * 下载应答回调块
 * @param: operation 当前下载操作对象
 * @param: error 响应错误对象
 * @param: isOK 是否可以下载
 */

typedef void (^ZFResponse)(ZFBaseOperation * _Nullable operation , NSError * _Nullable error ,BOOL isOK);

/**
 * 下载过程回调块
 * @param: operation 当前下载操作对象
 * @param: recvLength 当前接收下载字节数
 * @param: totalLength 总字节数
 * @param: speed 下载速度
 */

typedef void (^ZFProgress) (ZFBaseOperation * _Nullable operation ,uint64_t recvLength , uint64_t totalLength , NSString * _Nullable speed);


/**
 * 说明: ZFBaseOperation http网络操作对象基类,封装了底层通用操作细节共上层网络操作服务
 */
@interface ZFBaseOperation : NSOperation <NSURLConnectionDataDelegate , NSURLConnectionDelegate>

/**
 * 网络参数编码类型
 */
@property (nonatomic , assign) NSUInteger     encoderType;

/**
 * 网络请求超时时长
 */
@property (nonatomic , assign) NSTimeInterval timeoutInterval;

/**
 * 网络请求缓存策略
 */
@property (nonatomic , assign) NSURLRequestCachePolicy cachePolicy;

/**
 * 网络请求Url
 */
@property (nonatomic , copy , nonnull) NSString * strUrl;

/**
 * 网络请求内容类型
 */
@property (nonatomic , copy , nonnull) NSString * contentType;

/**
 * POST网络请求参数
 */
@property (nonatomic , copy , nonnull) NSObject * postParam;

/**
 * http网络请求类型
 */
@property (nonatomic , assign) ZFHttpRequestType requestType;

/**
 * http网络请求对象
 */
@property (nonatomic , strong , nullable)NSMutableURLRequest     * urlRequest;

/**
 * http网络请求连接对象
 */
@property (nonatomic , strong , nullable)NSURLConnection         * urlConnection;

/**
 * http网络请求状态
 */
@property (nonatomic , assign)ZFHttpRequestStatus      requestStatus;

/**
 * http网络请求应答数据对象
 */
@property (nonatomic , strong , nullable)NSMutableData           * responseData;

/**
 * http网络请求应答数据对象长度
 */
@property (nonatomic , assign)uint64_t    responseDataLenght;

/**
 * http网络请求定时获取的数据长度
 */
@property (nonatomic , assign)uint64_t    orderTimeDataLenght;

/**
 * http网络请求接收的数据长度
 */
@property (nonatomic , assign)uint64_t    recvDataLenght;

/**
 * http网络下载时下载速度
 */

@property (nonatomic , strong , nullable)NSString  * networkSpeed;

/**
 * 下载完成回调块对象
 */
@property (nonatomic , copy , nullable )ZFDidFinished didFinishedBlock;

/**
 * 下载过程回调块对象
 */
@property (nonatomic , copy , nullable)ZFProgress progressBlock;

/**
 * 下载应答回调块对象
 */
@property (nonatomic, copy , nullable)ZFResponse responseBlock;

/**
 * 下载操作代理对象
 */
@property (nonatomic , weak)id<ZFDownloadDelegate> delegate;

/**
 * 说明: 清空http 应答数据
 */
- (void)clearResponseData;


/**
 * 说明: 开始http请求
 */
- (void)startRequest;

/**
 * 说明: 开始http请求开启网速监控时钟
 */
- (void)startSpeedTimer;

/**
 * 说明: 结束http请求
 */
- (void)endRequest;

/**
 * 说明: 取消http请求
 */
- (void)cancelledRequest;

/**
 * 通用处理http应答错误
 * @param: response 当前网络操作应答对象
 */
- (BOOL)handleResponseError:(nullable NSURLResponse * )response;

/**
 * 添加依赖下载队列
 * @param: downloadOperation 将要添加的下载队列对象
 */
- (void)addDependOperation:(nonnull ZFBaseOperation *)operation;

/**
 * 通用处理http请求过程错误
 * @param: error 当前网络错误对象
 * @param: code  错误代码
 */
- (void)handleReqeustError:(nullable NSError *)error code:(NSInteger)code;

/**
 * 说明: 计算网络速度
 */
- (void)calculateNetworkSpeed;


@end
