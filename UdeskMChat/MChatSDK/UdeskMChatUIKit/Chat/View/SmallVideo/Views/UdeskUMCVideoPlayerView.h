//
//  UdeskVideoPlayerView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskUMCVideoPlayerView;

typedef enum : NSUInteger {
    UdeskVideoPlayerStatusUnknown,
    UdeskVideoPlayerStatusReadyToPlay,
    UdeskVideoPlayerStatusFailed,
    UdeskVideoPlayerStatusFinished
} UdeskVideoPlayerStatusEnum;

typedef enum : NSUInteger {
    UdeskVideoPlayerTimeString, // string 类型 00:004
    UdeskVideoPlayerTimeNum  // num 类型 4
} UdeskVideoPlayerTimeEnum;

@protocol UdeskUMCVideoPlayerViewDelegate <NSObject>

@optional;
- (void)videoPlayerView:(UdeskUMCVideoPlayerView *)playerView playerStatus:(UdeskVideoPlayerStatusEnum)status;
- (void)videoPlayerView:(UdeskUMCVideoPlayerView *)playerView currentSecond:(CGFloat)second timeString:(NSString *)timeString;

@end


@interface UdeskUMCVideoPlayerView : UIView

@property (nonatomic, weak)id <UdeskUMCVideoPlayerViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSString *)url;

- (NSString *)videoDurationTime:(UdeskVideoPlayerTimeEnum)timeEnum ;//!< 获取总时长

- (void)play;
- (void)pause;
- (void)cyclePlayVideo;

@end
