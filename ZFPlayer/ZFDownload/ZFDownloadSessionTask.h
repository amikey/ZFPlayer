//
//  ZFDownloadSessionTask.h
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

/**
 * 说明: ZFDownloadSessionTask  单个后台下载任务类
 */

@interface ZFDownloadSessionTask : ZFDownloadOperation

/**
 * 当前后台下载任务对象
 */
@property (nonatomic , strong)NSURLSessionDownloadTask * downloadTask;

/**
 * 函数说明: 取消当前下载任务
 * @param: isDelete 取消下载任务的同时是否删除下载缓存的文件
 */

- (void)cancelDownloadTaskAndDeleteFile:(BOOL)isDelete;

/**
 * 函数说明: 处理下载应答
 * @param: response 下载应答对象
 */

- (void)handleResponse:(NSURLResponse *)response;
@end
