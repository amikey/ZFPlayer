//
//  XYPlayer+ZFPlayerMediaPlayback.h
//  Pods-ZFPlayer_Example
//
//  Created by 紫枫 on 2018/7/9.
//

#import "ZFPlayerMediaPlayback.h"

// -----------------------------------------------------------------------------
//  MPMediaPlayback.h

// Posted when the prepared state changes of an object conforming to the MPMediaPlayback protocol changes.
// This supersedes MPMoviePlayerContentPreloadDidFinishNotification.
NSString *const ZFPlayerPlaybackIsPreparedToPlayDidChangeNotification = @"ZFPlayerPlaybackIsPreparedToPlayDidChangeNotification";

// -----------------------------------------------------------------------------
//  MPMoviePlayerController.h
//  Movie Player Notifications

NSString *const ZFPlayerPlaybackPlayTimeDidChangeNotification = @"ZFPlayerPlaybackPlayTimeDidChangeNotification";

NSString *const ZFPlayerPlaybackBufferTimeDidChangeNotification = @"ZFPlayerPlaybackBufferTimeDidChangeNotification";

// Posted when the scaling mode changes.
NSString* const ZFPlayerPlayerScalingModeDidChangeNotification = @"ZFPlayerPlayerScalingModeDidChangeNotification";

// Posted when movie playback ends or a user exits playback.
NSString* const ZFPlayerPlaybackDidFinishNotification = @"ZFPlayerPlaybackDidFinishNotification";

NSString* const  ZFPlayerPlaybackErrorNotification = @"ZFPlayerPlaybackErrorNotification";

NSString* const ZFPlayerPlaybackErrorReasonUserInfoKey = @"ZFPlayerPlaybackErrorReasonUserInfoKey"; // NSNumber (IJKMPMovieFinishReason)

// Posted when the playback state changes, either programatically or by the user.
NSString* const ZFPlayerPlaybackStateDidChangeNotification = @"ZFPlayerPlaybackStateDidChangeNotification";

// Posted when the network load state changes.
NSString* const ZFPlayerLoadStateDidChangeNotification = @"ZFPlayerLoadStateDidChangeNotification";

// Posted when the movie player begins or ends playing video via AirPlay.
NSString* const ZFPlayerIsAirPlayVideoActiveDidChangeNotification = @"ZFPlayerLoadStateDidChangeNotification";
