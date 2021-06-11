//
//  UdeskSmallVideoBottomView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMCSmallVideoBottomView;
@protocol UMCSmallVideoBottomViewDelegate <NSObject>

- (void)udSmallVideo:(UMCSmallVideoBottomView *)smallVideoView zoomLens:(CGFloat)scaleNum;

- (void)udSmallVideo:(UMCSmallVideoBottomView *)smallVideoView isRecording:(BOOL)recording;

- (void)udSmallVideo:(UMCSmallVideoBottomView *)smallVideoView captureCurrentFrame:(BOOL)capture;

@end

@interface UMCSmallVideoBottomView : UIView

@property (nonatomic, weak  )id <UMCSmallVideoBottomViewDelegate> delegate;

@property (nonatomic, assign) NSInteger duration;

@end
