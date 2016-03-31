//
//  ZFSessionDownloadOperation.h
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
#import "ZFDownloadSessionTask.h"

/**
 * 说明: ZFSessionDownloadManager 后台下载管理类 单例设计模式
 */

@interface ZFSessionDownloadManager : NSObject

/**
 * 说明: 当前是否是等待下载状态
 */
- (BOOL)waitingDownload;

/**
 * 后台下载配置字符
 */
@property (nonnull ,nonatomic , copy)NSString * bundleIdentifier;

/**
 * 下载对象单例
 */
+ (nonnull instancetype)shared;

/**
 * 说明: 执行下载任务 (存储时使用默认文件名)
 * @param strUrl 下载地址
 * @param savePath 下载缓存路径
 * @param delegate 下载响应代理
 */
- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                      savePath:(nonnull NSString *)savePath
                                      delegate:(nullable id<ZFDownloadDelegate>)delegate;

/**
 * 说明: 执行下载任务
 * @param strUrl 下载地址
 * @param savePath 下载缓存路径
 * @param saveFileName 下载保存文件名
 * @param delegate 下载响应代理
 */

- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                      savePath:(nonnull NSString *)savePath
                                  saveFileName:(nullable NSString *)saveFileName
                                      delegate:(nullable id<ZFDownloadDelegate>)delegate;

/**
 * 说明: 执行下载任务 (存储时使用默认文件名)
 * @param strUrl 下载地址
 * @param savePath 下载缓存路径
 * @param responseBlock 下载响应回调
 * @param processBlock 下载过程回调
 * @param didFinishedBlock 下载完成回调
 */

- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                      savePath:(nonnull NSString *)savePath
                                      response:(nullable ZFResponse)responseBlock
                                       process:(nullable ZFProgress)processBlock
                                   didFinished:(nullable ZFDidFinished)finishedBlock;

/**
 * 说明: 执行下载任务
 * @param strUrl 下载地址
 * @param savePath 下载缓存路径
 * @param saveFileName 下载保存文件名
 * @param responseBlock 下载响应回调
 * @param processBlock 下载过程回调
 * @param didFinishedBlock 下载完成回调
 */

- (nullable ZFDownloadSessionTask *)download:(nonnull NSString *)strUrl
                                      savePath:(nonnull NSString *)savePath
                                  saveFileName:(nullable NSString *)saveFileName
                                      response:(nullable ZFResponse) responseBlock
                                       process:(nullable ZFProgress) processBlock
                                   didFinished:(nullable ZFDidFinished) finishedBlock;

/**
 * 说明：取消所有当前下载任务
 * @param isDelete 是否删除缓存文件
 */

- (void)cancelAllDownloadTaskAndDelFile:(BOOL)isDelete;

/**
 * 说明：取消指定正下载url的下载
 * @param isDelete 是否删除缓存文件
 */

- (void)cancelDownloadWithDownloadUrl:(nonnull NSString *)strUrl deleteFile:(BOOL)isDelete;

/**
 * 说明：取消指定正下载文件名的下载
 * @param isDelete 是否删除缓存文件
 */

- (void)cancelDownloadWithFileName:(nonnull NSString *)fileName deleteFile:(BOOL)isDelete;


/**
 * 说明：替换当前回调通过传递要下载的文件名(当从控制器B进入到控制器C然后在控制器C中进行下载，然后下载过程中突然退出到控制器B，在又进入到控制器C，这个时候还是在下载但是代理对象和之前的那个控制器C不是一个对象所以要替换)
 * @param responseBlock 下载响应回调
 * @param processBlock 下载过程回调
 * @param didFinishedBlock 下载完成回调
 * @param fileName 文件名
 */


- (nullable ZFDownloadSessionTask *)replaceCurrentDownloadOperationBlockResponse:(nullable ZFResponse)responseBlock
                                             process:(nullable ZFProgress)processBlock
                                         didFinished:(nullable ZFDidFinished)didFinishedBlock
                                            fileName:(nonnull NSString *)fileName;

/**
 * 说明：替换当前回调通过传递要下载的文件名(当从控制器B进入到控制器C然后在控制器C中进行下载，然后下载过程中突然退出到控制器B，在又进入到控制器C，这个时候还是在下载但是代理对象和之前的那个控制器C不是一个对象所以要替换)
 * @param delegate 下载回调新代理
 * @param fileName 文件名
 */

- (nullable ZFDownloadSessionTask *)replaceCurrentDownloadOperationDelegate:(nullable id<ZFDownloadDelegate>)delegate
                                       fileName:(nonnull NSString *)fileName;

/**
 * 说明：替换当前所有下载代理(当从控制器B进入到控制器C然后在控制器C中进行下载，然后下载过程中突然退出到控制器B，在又进入到控制器C，这个时候还是在下载但是代理对象和之前的那个控制器C不是一个对象所以要替换)
 * @param responseBlock 下载响应回调
 * @param processBlock 下载过程回调
 * @param didFinishedBlock 下载完成回调
 */

- (nullable ZFDownloadSessionTask *)replaceAllDownloadOperationBlockResponse:(nullable ZFResponse)responseBlock
                                         process:(nullable ZFProgress)processBlock
                                     didFinished:(nullable ZFDidFinished)didFinishedBlock;

/**
 * 说明：替换当前所有下载代理(当从控制器B进入到控制器C然后在控制器C中进行下载，然后下载过程中突然退出到控制器B，在又进入到控制器C，这个时候还是在下载但是代理对象和之前的那个控制器C不是一个对象所以要替换)
 * @param delegate 下载回调新代理
 */

- (nullable ZFDownloadSessionTask *)replaceAllDownloadOperationDelegate:(nullable id<ZFDownloadDelegate>)delegate;


/**
 * 说明：通过要下载的文件名来判断当前是否在进行下载任务
 * @param fileName 正在下载的文件名
 */

- (BOOL)existDownloadOperationTaskWithFileName:(nonnull NSString *)fileName;

/**
 * 说明：通过要下载的文件名来判断当前是否在进行下载任务
 * @param strUrl 正在下载的url
 */

- (BOOL)existDownloadOperationTaskWithUrl:(nonnull NSString *)strUrl;

@end
