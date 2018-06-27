//
//  ZFNetworkSpeedMonitor.m
//  ZFPlayer
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

#import "ZFNetworkSpeedMonitor.h"
#import "ZFReachabilityManager.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

@interface ZFNetworkSpeedMonitor ()

@property (nonatomic, strong) NSTimer *timer;
/// 上一次下行速率
@property (nonatomic, assign) float lastUpstreamSpped;
/// 上一次下行速率
@property (nonatomic, assign) float lastDownstreamSpped;
/// 上行速率
@property (nonatomic, assign) float upstreamSpped;
/// 下行速率
@property (nonatomic, assign) float downstreamSpped;
/// 速率回调
@property (nonatomic, copy) void(^networkSpeedChangeBlock)(NSString *downloadSpped);

@end

@implementation ZFNetworkSpeedMonitor

- (void)startNetworkSpeedMonitor {
    [self getMonitorDataDetail];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(getCurrentNetworkSpped) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopNetworkSpeedMonitor {
    [self.timer invalidate];
}

- (void)getCurrentNetworkSpped {
    if ([ZFReachabilityManager sharedManager].isReachable) {
        [self getMonitorDataDetail];
        float downstreamSpped = self.downstreamSpped - self.lastDownstreamSpped;
        if (self.networkSpeedChangeBlock) {
            self.networkSpeedChangeBlock([self getSpeedString:downstreamSpped]);
        }
        NSLog(@"download speed：%@",[self getSpeedString:downstreamSpped]);
        self.lastUpstreamSpped = self.upstreamSpped;
        self.lastDownstreamSpped = self.downstreamSpped;
    }
}

// 上传、下载总额流量
- (void)getMonitorDataDetail {
    BOOL success;
    struct ifaddrs *addrs;
    struct ifaddrs *cursor;
    struct if_data *networkStatisc;
    
    long upstreamSpped = 0;
    long downstreamSpped = 0;
    NSString *dataName;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            dataName = [NSString stringWithFormat:@"%s",cursor->ifa_name];
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                networkStatisc = (struct if_data *) cursor->ifa_data;
                upstreamSpped += networkStatisc->ifi_obytes;
                downstreamSpped += networkStatisc->ifi_ibytes;
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    self.upstreamSpped = upstreamSpped;
    self.downstreamSpped = downstreamSpped;
}

- (NSString *)getSpeedString:(float)size {
    if(size >= 1024*1024) { /// 大于1M，则转化成M单位的字符串
        return [NSString stringWithFormat:@"%.1f M/s",size/1024/1024];
    } else if(size >= 1024 && size < 1024*1024) { /// 不到1M,但是超过了1KB，则转化成KB单位
        return [NSString stringWithFormat:@"%.0f kb/s",size/1024];
    } else { /// 剩下的都是小于1K的，则转化成B单位
        return [NSString stringWithFormat:@"%.0f b/s",size];
    }
}

- (void)networkSpeedChangeBlock:(nullable void (^)(NSString *downloadSpped))block {
    self.networkSpeedChangeBlock = block;
}

@end
