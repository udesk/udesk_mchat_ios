//
//  UMCVoiceCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCVoiceCell.h"
#import "UMCVoiceMessage.h"
#import "UMCAudioPlayerHelper.h"
#import "UMCHelper.h"
#import "UMCSDKConfig.h"

#import "Udesk_YYCache.h"

#define VoicePlayHasInterrupt @"VoicePlayHasInterrupt"

@interface UMCVoiceCell()<UDAudioPlayerHelperDelegate> {
    
    BOOL contentVoiceIsPlaying;
}

/** 语音时长 */
@property (nonatomic, strong) UILabel *voiceDurationTextLabel;
/** 语音动画图片 */
@property (nonatomic, strong) UIImageView *voiceAnimationImageView;

@end

@implementation UMCVoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initVoiceBubbleGesture];
    }
    return self;
}

- (void)initVoiceBubbleGesture {
    
    //长按手势
    UITapGestureRecognizer *tapPressBubbleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoicePlay:)];
    tapPressBubbleGesture.cancelsTouchesInView = false;
    [self.bubbleImageView addGestureRecognizer:tapPressBubbleGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVAudioPlayerDidFinishPlay) name:VoicePlayHasInterrupt object:nil];
    contentVoiceIsPlaying = NO;
}

- (void)tapVoicePlay:(UITapGestureRecognizer *)tap {
    
    //获取语音文件
    NSData *voiceData = [self getVoiceData];
    
    UMCAudioPlayerHelper *playerHelper = [UMCAudioPlayerHelper shareInstance];
    
    if (!contentVoiceIsPlaying) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VoicePlayHasInterrupt object:nil];
        contentVoiceIsPlaying = YES;
        [self.voiceAnimationImageView startAnimating];
        playerHelper.delegate = self;
        [playerHelper playAudioWithVoiceData:voiceData];
    }
    else {
        
        [self AVAudioPlayerDidFinishPlay];
    }
}

- (void)AVAudioPlayerDidFinishPlay {
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self.voiceAnimationImageView stopAnimating];
    contentVoiceIsPlaying = NO;
    [[UMCAudioPlayerHelper shareInstance] stopAudio];
}

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    
    [self.voiceAnimationImageView stopAnimating];
    contentVoiceIsPlaying = NO;
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UMCVoiceMessage *voiceMessage = (UMCVoiceMessage *)baseMessage;
    if (!voiceMessage || ![voiceMessage isKindOfClass:[UMCVoiceMessage class]]) return;
    
    //语音时长
    if ([UMCHelper isPureInt:voiceMessage.message.extras.duration]) {
     
        if (voiceMessage.message.extras.duration.floatValue == 0 ) {
            
            //获取语音文件
            NSData *voiceData = [self getVoiceData];
            AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
            //语音时长
            NSString *voiceDuration = [NSString stringWithFormat:@"%.f",play.duration];
            self.voiceDurationTextLabel.text = [NSString stringWithFormat:@"%.f\'\'", voiceDuration.floatValue];
        }
        else {
            self.voiceDurationTextLabel.text = [NSString stringWithFormat:@"%.f\'\'", voiceMessage.message.extras.duration.floatValue];
        }
    }
    
    //语音播放动画
    self.voiceAnimationImageView.hidden = NO;
    self.voiceAnimationImageView.image = voiceMessage.animationVoiceImage;
    self.voiceAnimationImageView.animationImages = voiceMessage.animationVoiceImages;
    
    //语音播放图片
    self.voiceAnimationImageView.frame = voiceMessage.voiceAnimationFrame;
    self.voiceDurationTextLabel.frame = voiceMessage.voiceDurationFrame;
    
    //昵称
    if (voiceMessage.message.direction == UMCMessageDirectionOut) {
        
        self.voiceDurationTextLabel.textColor = [UMCSDKConfig sharedConfig].sdkStyle.agentVoiceDurationColor;
        self.voiceDurationTextLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    else {
        self.voiceDurationTextLabel.textColor = [UMCSDKConfig sharedConfig].sdkStyle.customerVoiceDurationColor;
        self.voiceDurationTextLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (NSData *)getVoiceData {
    
    @try {
        
        UMCVoiceMessage *voiceMessage = (UMCVoiceMessage *)self.baseMessage;
        if (!voiceMessage || ![voiceMessage isKindOfClass:[UMCVoiceMessage class]]) return nil;
        
        Udesk_YYCache *cache = [[Udesk_YYCache alloc] initWithName:UMCVoiceCache];
        if ([cache containsObjectForKey:voiceMessage.message.UUID]) {
            NSData *voiceData = (NSData *)[cache objectForKey:voiceMessage.message.UUID];
            
            return voiceData;
        }
        
        NSString *content = [voiceMessage.message.content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc]initWithString:content];
        NSData *voiceData = [NSData dataWithContentsOfURL:url];
        
        return voiceData;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VoicePlayHasInterrupt object:nil];
}

- (UILabel *)voiceDurationTextLabel {
    
    if (!_voiceDurationTextLabel) {
        _voiceDurationTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _voiceDurationTextLabel.font = [UIFont systemFontOfSize:14.f];
        _voiceDurationTextLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_voiceDurationTextLabel];
    }
    return _voiceDurationTextLabel;
}

- (UIImageView *)voiceAnimationImageView {
    
    if (!_voiceAnimationImageView) {
        _voiceAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _voiceAnimationImageView.animationDuration = 1.0;
        _voiceAnimationImageView.userInteractionEnabled = YES;
        [_voiceAnimationImageView stopAnimating];
        [self.bubbleImageView addSubview:_voiceAnimationImageView];
    }
    return _voiceAnimationImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
