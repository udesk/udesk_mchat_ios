//
//  UMCVoiceMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCVoiceMessage.h"
#import "UMCVoiceCell.h"
#import "UMCHelper.h"
#import "UMCBundleHelper.h"

/** 语音时长 height */
static CGFloat const kUDVoiceDurationLabelHeight = 15.0;
/** 聊天气泡和其中语音播放图片水平间距 */
static CGFloat const kUDBubbleToAnimationVoiceImageHorizontalSpacing     = 10.0f;
/** 聊天气泡和其中语音播放图片垂直间距 */
static CGFloat const kUDBubbleToAnimationVoiceImageVerticalSpacing     = 11.0f;
/** 语音播放图片 width */
static CGFloat const kUDAnimationVoiceImageViewWidth     = 12.0f;
/** 语音播放图片 height */
static CGFloat const kUDAnimationVoiceImageViewHeight    = 17.0f;
/** 语音气泡最小长度 */
static CGFloat const kUDCellBubbleVoiceMinContentWidth = 50;
/** 语音气泡最大长度 */
static CGFloat const kUDCellBubbleVoiceMaxContentWidth = 150.0;

@interface UMCVoiceMessage()

//语音动画frame
@property (nonatomic, assign, readwrite) CGRect  voiceAnimationFrame;
//语音时长frame
@property (nonatomic, assign, readwrite) CGRect  voiceDurationFrame;

@end

@implementation UMCVoiceMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self getAnimationVoiceImages];
        [self layoutVoiceMessage];
    }
    return self;
}

- (void)layoutVoiceMessage {
    
    CGSize voiceSize = CGSizeMake(kUDCellBubbleVoiceMinContentWidth, kUDAvatarDiameter);
    if (self.message.extras.duration) {
        if ([UMCHelper isPureInt:self.message.extras.duration]) {
            voiceSize = CGSizeMake(kUDCellBubbleVoiceMinContentWidth + self.message.extras.duration.intValue*3.5f, kUDAvatarDiameter);
            if (voiceSize.width>kUDCellBubbleVoiceMaxContentWidth) {
                voiceSize = CGSizeMake(kUDCellBubbleVoiceMaxContentWidth, kUDAvatarDiameter);
            }
        }
    }
    
    switch (self.message.direction) {
        case UMCMessageDirectionIn:
            
            //语音气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDAvatarToBubbleSpacing-voiceSize.width, self.avatarFrame.origin.y, voiceSize.width+kUDBubbleToAnimationVoiceImageHorizontalSpacing, voiceSize.height);
            //语音时长frame
            self.voiceDurationFrame = CGRectMake(self.bubbleFrame.origin.x-kUDAvatarToBubbleSpacing-voiceSize.width, self.bubbleFrame.origin.y+kUDBubbleToAnimationVoiceImageVerticalSpacing, voiceSize.width, kUDVoiceDurationLabelHeight);
            //发送的语音播放动画图片
            self.voiceAnimationFrame = CGRectMake(self.bubbleFrame.size.width-kUDAnimationVoiceImageViewWidth-kUDArrowMarginWidth-kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
            //发送中
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-(kUDSendStatusDiameter*2), self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败
            self.failureFrame = self.loadingFrame;
            
            break;
        case UMCMessageDirectionOut:{
            
            //接收的语音气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, voiceSize.width+kUDBubbleToAnimationVoiceImageHorizontalSpacing, voiceSize.height);
            //接收的语音时长frame
            self.voiceDurationFrame = CGRectMake(self.bubbleFrame.origin.x+kUDAvatarToBubbleSpacing+self.bubbleFrame.size.width, self.bubbleFrame.origin.y+kUDBubbleToAnimationVoiceImageVerticalSpacing, voiceSize.width, kUDVoiceDurationLabelHeight);
            //发送的语音播放动画图片
            self.voiceAnimationFrame = CGRectMake(kUDBubbleToAnimationVoiceImageHorizontalSpacing,kUDBubbleToAnimationVoiceImageVerticalSpacing, kUDAnimationVoiceImageViewWidth, kUDAnimationVoiceImageViewHeight);
            
            break;
        }
            
        default:
            break;
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)getAnimationVoiceImages {
    
    @try {
        
        NSString *imageSepatorName;
        switch (self.message.direction) {
            case UMCMessageDirectionIn:
                imageSepatorName = @"udSender";
                break;
            case UMCMessageDirectionOut:
                imageSepatorName = @"udReceiver";
                break;
            default:
                break;
        }
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 1; i < 4; i ++) {
            UIImage *image = [UIImage imageWithContentsOfFile:UMCBundlePath([imageSepatorName stringByAppendingFormat:@"VoiceNodePlaying00%ld@2x.png", (long)i])];
            if (image)
                [images addObject:image];
        }
        
        self.animationVoiceImage = [UIImage imageWithContentsOfFile:UMCBundlePath([imageSepatorName stringByAppendingString:@"VoiceNodePlaying003@2x.png"])];
        self.animationVoiceImages = images;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
