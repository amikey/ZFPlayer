
<p align="center">
<img src="https://github.com/renzifeng/ZFPlayer/raw/master/log.png" alt="ZFPlayer" title="ZFPlayer" width="557"/>
</p>

<p align="center">
<a href="https://travis-ci.org/renzifeng/ZFPlayer"><img src="https://travis-ci.org/renzifeng/ZFPlayer.svg?branch=master"></a>
<a href="https://img.shields.io/cocoapods/v/ZFPlayer.svg"><img src="https://img.shields.io/cocoapods/v/ZFPlayer.svg"></a>
<a href="https://img.shields.io/cocoapods/v/ZFPlayer.svg"><img src="https://img.shields.io/github/license/renzifeng/ZFPlayer.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/ZFPlayer"><img src="https://img.shields.io/cocoapods/p/ZFPlayer.svg?style=flat"></a>
<a href="http://weibo.com/zifeng1300"><img src="https://img.shields.io/badge/weibo-@%E4%BB%BB%E5%AD%90%E4%B8%B0-yellow.svg?style=flat"></a>
</p>

Before this, you used ZFPlayer, are you worried about encapsulating avplayer instead of using or modifying the source code to support other players, the control layer is not easy to customize, and so on? In order to solve these problems, I have wrote this player joke, for player SDK you can follow the <ZFPlayerMediaPlayback> protocol, for control view you can follow the <ZFPlayerMediaControl> protocol, can achieve the custom player and custom control layer.

在此之前你使用ZFPlayer，是不是在烦恼封装的是avplayer而放弃使用或者修改源码来支持其他播放器，控制层不好自定义等等问题。为了解决这些问题，我特意写了这个播放器壳子，播放器SDK只要遵守<ZFPlayerMediaPlayback>协议，控制层只要遵守<ZFPlayerMediaControl>协议，完全可以实现自定义播放器和自定义控制层。

![ZFPlayer.png](https://upload-images.jianshu.io/upload_images/635942-7f0c5bb8b22f0b27.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Requirements

* iOS 7+
* Xcode 8+

## Installation


ZFPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ZFPlayer'
```

## Usage

####  ZFPlayerController
Main classes, two initialization methods, normal mode initialization and list style initialization (tableView, collection)

normal mode initialization 

```objc
ZFPlayerController *player = [ZFPlayerController playerWithPlayerManager:playerManager];
ZFPlayerController *player = [[ZFPlayerController alloc] initwithPlayerManager:playerManager];
```

list style initialization

```objc
ZFPlayerController *player = [ZFPlayerController playerWithScrollView:tableView playerManager:playerManager];
ZFPlayerController *player = [ZFPlayerController alloc] initWithScrollView:tableView playerManager:playerManager];
```

#### ZFPlayerMediaPlayback
For the playerMnager,you must follow `ZFPlayerMediaPlayback` protocol to and create a playerManager class that encapsulates any player SDK，such as `AVPlayer`,`ijkplayer`, `KSYMediaPlayer`and so on，you can reference the `ZFAVPlayerManager`class.

```objc
Class<ZFPlayerMediaPlayback> *playerManager = ...;
```

#### ZFPlayerMediaControl
This class is used to display the control layer, and you must follow the ZFPlayerMediaControl protocol, you can reference the `ZFPlayerControlView` class.


```objc
UIView<ZFPlayerMediaControl> *controlView = ...;
player.controlView = controlView;
```
#### containerView
To see the video, you have to make a container view of the player, which is the same as the player view frame.

```objc
player.containerView = <your custom player container view>
```
#### normal mode

```objc
/// playerManager
ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
playerManager.shouldAutoPlay = YES;
/// player
self.player = [ZFPlayerController playerWithPlayerManager:playerManager];
self.player.controlView = self.controlView;
self.player.containerView = self.containerView;
__weak typeof(self) weakSelf = self;
self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
    [weakSelf.view endEditing:YES];
    [weakSelf setNeedsStatusBarAppearanceUpdate];
};
playerManager.assetURL = [NSURL URLWithString:...];
```

#### list style

```objc
/// playerManager
self.playerManager = [[ZFAVPlayerManager alloc] init];
self.playerManager.shouldAutoPlay = YES;

/// player
self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:self.playerManager];
self.player.controlView = self.controlView;
self.player.playerViewTag = 100;
self.player.assetURLs = self.urls;
```

## Author

renzifeng, zifeng1300@gmail.com

## License

ZFPlayer is available under the MIT license. See the LICENSE file for more info.


