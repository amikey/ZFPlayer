# ZFPlayer
## 基于AVPlayer，实现了各大视频软件的功能
* 支持横、竖屏切换，在全屏播放模式下还可以锁定屏幕方向
* 支持本地视频、网络视频播放
* 左侧1/2位置上下滑动调节屏幕亮度（模拟器调不了亮度，请在真机调试）
* 右侧1/2位置上下滑动调节音量（模拟器调不了音量，请在真机调试）
* 左右滑动调节播放进度

使用需要安装cocopods

	$ cd ZFPlayer
	$ pod install
	
Open the "Player.xcworkspace"

### 用法（支持IB和代码）
##### IB用法
直接拖UIView到IB上，宽高比为16：9，代码部分只需要实现

```objc
self.playerView.videoURL = self.videoURL;
// 返回按钮事件
__weak typeof(self) weakSelf = self;
self.playerView.goBackBlock = ^{
	[weakSelf.navigationController popViewControllerAnimated:YES];
};

```

##### 代码实现（Masonry）用法

```objc
self.playerView = [ZFPlayerView setupZFPlayer];
[self.view addSubview:self.playerView];
[self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
 	make.left.top.right.equalTo(self.view);
	make.height.equalTo(self.playerView.mas_width).multipliedBy(9.0f/16.0f);
}];
self.playerView.videoURL = self.videoURL;
// 返回按钮事件
__weak typeof(self) weakSelf = self;
self.playerView.goBackBlock = ^{
	[weakSelf.navigationController popViewControllerAnimated:YES];
};
```

### 图片效果演示
![图片效果演示](https://github.com/renzifeng/ZFPlayer/raw/master/screen.gif)

![声音调节演示](https://github.com/renzifeng/ZFPlayer/raw/master/volume.png)

![亮度调节演示](https://github.com/renzifeng/ZFPlayer/raw/master/brightness.png)

### ps：本人最近swift做的项目，朋友们给点建议吧：
[知乎日报Swift](https://github.com/renzifeng/ZFZhiHuDaily)

# 期待
- 如果在使用过程中遇到BUG，或发现功能不够用，希望你能Issues我,或者微博联系我：[@任子丰](https://weibo.com/zifeng1300)
- 如果觉得好用请Star!