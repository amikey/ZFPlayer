//
//  CommonHelper.h
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

@interface CommonHelper : NSObject

+ (uint64_t)getFreeDiskspace;
+ (uint64_t)getTotalDiskspace;
+ (NSString *)getDiskSpaceInfo;
// 下载文件存储的目录
+ (NSString *)getCachePath;
//将文件大小转化成M单位或者B单位
+ (NSString *)getFileSizeString:(NSString *)size;
//经文件大小转化成不带单位ied数字
+ (float)getFileSizeNumber:(NSString *)size;
+ (NSDate *)makeDate:(NSString *)birthday;
+ (NSString *)dateToString:(NSDate*)date;
+ (NSString *)getTempFolderPathWithBasepath:(NSString *)name;//得到临时文件存储文件夹的路径
+ (NSArray *)getTargetFloderPathWithBasepath:(NSString *)name subpatharr:(NSArray *)arr;
+ (NSString *)getTargetPathWithBasepath:(NSString *)name subpath:(NSString *)subpath;
+ (BOOL)isExistFile:(NSString *)fileName;//检查文件名是否存在
+ (NSString *)md5StringForData:(NSData*)data;
+ (NSString *)md5StringForString:(NSString*)str;
//传入文件总大小和当前大小，得到文件的下载进度
+ (CGFloat) getProgress:(long long)totalSize currentSize:(long long)currentSize;

@end
