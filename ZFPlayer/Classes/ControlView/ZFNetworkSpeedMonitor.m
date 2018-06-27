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

@implementation ZFMonitorData

@end

@interface ZFNetworkSpeedMonitor ()

@property (nonatomic, strong) NSTimer *timer;
@property (assign, nonatomic) float tempWWANReceived;
@property (assign, nonatomic) float tempWWANSend;
@property (assign, nonatomic) float tempWifiReceived;
@property (assign, nonatomic) float tempWifiSend;

@property (nonatomic, copy) void(^networkSpeedChangeBlock)(NSString *downloadSpped);



@end

@implementation ZFNetworkSpeedMonitor

- (void)startSpeedMonitor {
    [self currentFlow];
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(getCurrentNetSpped) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopSpeedMonitor {
    [self.timer invalidate];
}

- (void)getCurrentNetSpped {
    // 上传、下载
    //不需要连通网络获取的是总的数据
    ZFReachabilityStatus networkReachabilityStatus = [ZFReachabilityManager sharedManager].networkReachabilityStatus;
    ZFMonitorData *monitor = [self getMonitorDataDetail];
    switch (networkReachabilityStatus) {
        case ZFReachabilityStatusReachableViaWiFi: {
            float wifiReceived = monitor.wifiReceived - self.tempWifiReceived;
            if (self.networkSpeedChangeBlock) {
                self.networkSpeedChangeBlock([self getSpeedString:wifiReceived]);
            }
            NSLog(@"wifi下载速度：%@",[self getSpeedString:wifiReceived]);
        }
            break;
        case ZFReachabilityStatusReachableVia2G:
        case ZFReachabilityStatusReachableVia3G:
        case ZFReachabilityStatusReachableVia4G: {
            float wwanReceived = monitor.wifiReceived - self.tempWWANSend;
            if (self.networkSpeedChangeBlock) {
                self.networkSpeedChangeBlock([self getSpeedString:wwanReceived]);
            }
        }
            break;
        default: {
            NSLog(@"无网络");

        }
            break;
    }

    [self currentFlow];
}


// 赋值当前流量
- (void)currentFlow {
    ZFMonitorData *monitor = [self getMonitorDataDetail];
    self.tempWifiSend = monitor.wifiSend;
    self.tempWifiReceived = monitor.wifiReceived;
    self.tempWWANSend = monitor.wwanSend;
    self.tempWWANReceived = monitor.wwanReceived;
}


// 上传、下载总额流量
- (ZFMonitorData *)getMonitorDataDetail {
    BOOL success;
    struct ifaddrs *addrs;
    struct ifaddrs *cursor;
    struct if_data *networkStatisc;
    long tempWiFiSend = 0;
    long tempWiFiReceived = 0;
    long tempWWANSend = 0;
    long tempWWANReceived = 0;
    NSString *dataName;
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            dataName = [NSString stringWithFormat:@"%s",cursor->ifa_name];
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                if ([dataName hasPrefix:@"en"]) {
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    tempWiFiSend += networkStatisc->ifi_obytes;
                    tempWiFiReceived += networkStatisc->ifi_ibytes;
                }
                if ([dataName hasPrefix:@"pdp_ip"]) {
                    networkStatisc = (struct if_data *) cursor->ifa_data;
                    tempWWANSend += networkStatisc->ifi_obytes;
                    tempWWANReceived += networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    ZFMonitorData *monitorData = [ZFMonitorData new];
    monitorData.wifiSend = tempWiFiSend;
    monitorData.wifiReceived = tempWiFiReceived;
    monitorData.wwanSend = tempWWANSend;
    monitorData.wwanReceived = tempWWANReceived;
    return monitorData;
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
