//
//  ZFDownloadObject.m
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

#import "ZFDownloadObject.h"
#import <CommonCrypto/CommonDigest.h>
const static double k1MB = 1024 * 1024;

@implementation ZFDownloadObject 

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadSpeed = @"0KB/s";
        _downloadState = ZFNone;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_etag forKey:@"etag"];
    [aCoder encodeObject:_fileName forKey:@"fileName"];
    [aCoder encodeObject:_downloadPath forKey:@"downloadPath"];
    [aCoder encodeInt64:_totalLenght forKey:@"totalLenght"];
    [aCoder encodeInt64:_currentDownloadLenght forKey:@"currentDownloadLenght"];
    [aCoder encodeInteger:_downloadState forKey:@"downloadState"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _etag = [aDecoder decodeObjectForKey:@"fileName"];
        _downloadSpeed = @"0KB/s";
        _fileName = [aDecoder decodeObjectForKey:@"fileName"];
        _downloadPath = [aDecoder decodeObjectForKey:@"downloadPath"];
        _currentDownloadLenght = [aDecoder decodeInt64ForKey:@"currentDownloadLenght"];
        _totalLenght = [aDecoder decodeInt64ForKey:@"totalLenght"];
        _downloadState = _totalLenght != 0 ? (self.currentDownloadLenght == self.totalLenght ? ZFDownloadCompleted : ZFDownloadCanceled) : ZFNone;
        _downloadState = [aDecoder decodeIntegerForKey:@"downloadState"];
    }
    return self;
}

+ (NSString *)cacheDirectory {
    return [NSString stringWithFormat:@"%@/Documents/ZFDownloadObjectCache/",NSHomeDirectory()];
}

+ (NSString *)cachePlistDirectory {
    return [NSString stringWithFormat:@"%@/Documents/ZFCachePlistDirectory/",NSHomeDirectory()];
}

+ (NSString *)cachePlistPath {
    return [NSString stringWithFormat:@"%@ZFDownloadCache.plist",[ZFDownloadObject cachePlistDirectory]];
}

+ (NSString *)videoDirectory {
    return [NSString stringWithFormat:@"%@/Documents/ZFVideos/",NSHomeDirectory()];
}

+ (ZFDownloadObject *)readDiskCache:(NSString *)downloadPath {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[ZFDownloadObject getCachedFileName:downloadPath]];
}

+ (NSArray *)readDiskAllCache {
    NSMutableArray * downloadObjectArr = [NSMutableArray array];
    NSMutableDictionary * cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[ZFDownloadObject cachePlistPath]];
    if (cacheDictionary != nil) {
        NSArray * allKeys = [cacheDictionary allKeys];
        for (NSString * path in allKeys) {
            [downloadObjectArr addObject:[ZFDownloadObject readDiskCache:path]];
        }
    }
    return downloadObjectArr;
}

+ (NSString *)getCachedFileName:(NSString *)name {
    NSMutableString * cachedFileName = [NSMutableString string];
    if (name != nil) {
        const char * cStr = name.UTF8String;
        unsigned char buffer[CC_MD5_DIGEST_LENGTH];
        memset(buffer, 0x00, CC_MD5_DIGEST_LENGTH);
        CC_MD5(cStr, (CC_LONG)(strlen(cStr)), buffer);
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [cachedFileName appendFormat:@"%02x",buffer[i]];
        }
        return [NSString stringWithFormat:@"%@%@",[ZFDownloadObject cacheDirectory],cachedFileName];
    }
    return [NSString stringWithFormat:@"%@ZF",[ZFDownloadObject cacheDirectory]];
}

- (float)downloadProcessValue {
    return (double)_currentDownloadLenght / ((double)_totalLenght == 0 ? 1 : _totalLenght);
}

- (NSString *)currentDownloadLenghtToString {
    return [NSString stringWithFormat:@"%.1fMB",(double)_currentDownloadLenght / k1MB];
}

- (NSString *)totalLenghtToString {
    return [NSString stringWithFormat:@"%.1fMB",(double)_totalLenght / k1MB];
}

- (NSString *)downloadProcessText {
    return [NSString stringWithFormat:@"%@/%@",self.totalLenghtToString , self.currentDownloadLenghtToString];
}

- (void)createCacheDirectory:(NSString *)path {
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if (![fm fileExistsAtPath:path isDirectory:&isDirectory]) {
        [fm createDirectoryAtPath:path
      withIntermediateDirectories:YES
                       attributes:@{NSFileProtectionKey:NSFileProtectionNone} error:nil];
    }
}

- (void)writeDiskCache {
    if (_downloadPath != nil) {
        [self createCacheDirectory:[ZFDownloadObject cacheDirectory]];
        [NSKeyedArchiver archiveRootObject:self
                                    toFile:[ZFDownloadObject getCachedFileName:_fileName]];//_downloadPath
        [self createCacheDirectory:[ZFDownloadObject cachePlistDirectory]];
        NSMutableDictionary * cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[ZFDownloadObject cachePlistPath]];
        if (cacheDictionary == nil) {
            cacheDictionary = [NSMutableDictionary dictionary];
        }
        [cacheDictionary setObject:@"ZF" forKey:_fileName];//_downloadPath
        [cacheDictionary writeToFile:[ZFDownloadObject cachePlistPath] atomically:YES];
    }
}

- (void)removeFromDisk {
    NSFileManager * fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[ZFDownloadObject getCachedFileName:_fileName]]) {//_downloadPath
        [fm removeItemAtPath:[ZFDownloadObject getCachedFileName:_fileName] error:nil];//_downloadPath
        NSMutableDictionary * cacheDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:[ZFDownloadObject cachePlistPath]];
        if (cacheDictionary != nil) {
            [cacheDictionary removeObjectForKey:_fileName];//_downloadPath
            [cacheDictionary writeToFile:[ZFDownloadObject cachePlistPath] atomically:YES];
        }
        if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@%@",[ZFDownloadObject videoDirectory],_fileName]]) {
            [fm removeItemAtPath:[NSString stringWithFormat:@"%@%@",[ZFDownloadObject videoDirectory],_fileName] error:nil];
        }
    }
}

@end
