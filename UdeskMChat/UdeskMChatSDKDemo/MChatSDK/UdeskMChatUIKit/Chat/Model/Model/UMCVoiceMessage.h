//
//  UMCVoiceMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"

@interface UMCVoiceMessage : UMCBaseMessage

/** 语音播放image */
@property (nonatomic, strong) UIImage         *animationVoiceImage;
/** 语音播放动画图片数组 */
@property (nonatomic, strong) NSMutableArray  *animationVoiceImages;
//语音动画frame
@property (nonatomic, assign, readonly) CGRect  voiceAnimationFrame;
//语音时长frame
@property (nonatomic, assign, readonly) CGRect  voiceDurationFrame;

@end
