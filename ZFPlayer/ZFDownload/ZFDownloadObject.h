//
//  ZFDownloadObject.h
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

#define ZFCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"ZFVideos"]
// 保存文件名
#define ZFFileName(url)  [[url componentsSeparatedByString:@"/"] lastObject]
// 文件的存放路径（caches）
#define ZFFileFullpath(url) [ZFCachesDirectory stringByAppendingPathComponent:url]

typedef NS_ENUM(NSUInteger, ZFDownloadState) {
    ZFNone,
    ZFDownloading,
    ZFDownloadCompleted,
    ZFDownloadCanceled,
    ZFDownloadWaitting
};

@interface ZFDownloadObject : NSObject<NSCoding>

@property (nonatomic , copy) NSString * fileName;
@property (nonatomic , copy) NSString * downloadSpeed;
@property (nonatomic , copy) NSString * downloadPath;
@property (nonatomic , assign) UInt64 totalLenght;
@property (nonatomic , assign) UInt64 currentDownloadLenght;
@property (nonatomic , assign , readonly) float downloadProcessValue;
@property (nonatomic , assign) ZFDownloadState downloadState;
@property (nonatomic , copy , readonly)NSString * currentDownloadLenghtToString;
@property (nonatomic , copy , readonly)NSString * totalLenghtToString;
@property (nonatomic , copy , readonly)NSString * downloadProcessText;
@property (nonatomic , copy) NSString * etag;
+ (NSString *)cacheDirectory;
+ (NSString *)cachePlistDirectory;
+ (NSString *)cachePlistPath;
+ (NSString *)videoDirectory;

+ (ZFDownloadObject *)readDiskCache:(NSString *)downloadPath;

+ (NSArray *)readDiskAllCache;

- (void)writeDiskCache;

- (void)removeFromDisk;
@end
