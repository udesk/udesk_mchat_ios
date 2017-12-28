//
//  UdeskVoiceRecodView.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCVoiceRecordView.h"
#import "UMCSpectrumView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+UMC.h"
#import "UMCUIMacro.h"
#import "UMCSDKConfig.h"
#import "UMCBundleHelper.h"
#import "UMCVoiceRecordHelper.h"

@interface UMCVoiceRecordView()<AVAudioRecorderDelegate,MZTimerLabelDelegate> {
    
    UILabel  *tipLabel;
    UIButton *deleteButton;
    UIButton *recordButton;
    UMCSpectrumView *spectrumView;
    BOOL        isInDeleteButton;
    float  recordTime;
}

@property (nonatomic, strong) UMCVoiceRecordHelper    *voiceRecordHelper;//管理录音工具对象
@property (nonatomic, assign) BOOL isMaxTime;

@end

@implementation UMCVoiceRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UMCSDKConfig sharedConfig].sdkStyle.recordViewColor;
        
        recordTime = 0.0f;
        
        spectrumView = [[UMCSpectrumView alloc] initWithFrame:CGRectMake((kUMCScreenWidth-170)/2,32,150, 20)];
        spectrumView.stopwatch.delegate = self;
        __weak UMCSpectrumView * weakSpectrum = spectrumView;
        
        @udWeakify(self);
        spectrumView.itemLevelCallback = ^() {
            @udStrongify(self);
            self.voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
                
                weakSpectrum.level = peakPowerForChannel;
            };
            
        };
        
        spectrumView.hidden = YES;
        
        [self addSubview:spectrumView];
        
        tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, CGRectGetMaxX(self.frame),30)];
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.font = [UIFont systemFontOfSize:18];
        tipLabel.text = UMCLocalizedString(@"udesk_hold_to_talk");
        [tipLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:tipLabel];
        
        recordButton = [[UIButton alloc]initWithFrame:CGRectMake((kUMCScreenWidth-100)/2, 77, 100, 100)];
        
        [recordButton setBackgroundImage:[UIImage umcDefaultRecordVoiceImage] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage umcDefaultRecordVoiceHighImage] forState:UIControlStateHighlighted];
        
        //开始
        [recordButton addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        //完成
        [recordButton addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
        //取消
        [recordButton addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchUpOutside];
        //移出
        [recordButton addTarget:self action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        [recordButton addTarget:self action:@selector(btnTouchUp:withEvent:) forControlEvents:UIControlEventTouchDragOutside];
        
        [self addSubview:recordButton];
        
        
        deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(kUMCScreenWidth-40-25, 25, 40, 40)];
        deleteButton.hidden = YES;
        [deleteButton setImage:[UIImage umcDefaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
        
        [self addSubview:deleteButton];
    }
    return self;
}

-(void)timerLabel:(UMCTimerLabel *)timerLabel countingTo:(NSTimeInterval)time timertype:(UDTimerLabelType)timerType {
    
    if (!isnan(time)) {
        recordTime = time;
    }
}

- (void)btnTouchUp:(UIButton *)sender withEvent:(UIEvent *)event {
    
    [recordButton setBackgroundImage:[UIImage umcDefaultRecordVoiceHighImage] forState:UIControlStateNormal];
    
    UITouch *touch = [[event allTouches] anyObject];
    
    CGPoint location = [touch locationInView:sender];
    
    CGRect newButton = CGRectMake(location.x+sender.frame.origin.x, location.y+sender.frame.origin.y,100, 100);
    
    BOOL deletePoint = CGRectIntersectsRect(deleteButton.frame,newButton);
    
    if (deletePoint) {
        
        spectrumView.hidden = YES;
        tipLabel.hidden = NO;
        deleteButton.hidden = NO;
        tipLabel.text = UMCLocalizedString(@"udesk_release_to_cancel");
        [deleteButton setImage:[UIImage umcDefaultDeleteRecordVoiceHighImage] forState:UIControlStateNormal];
        
        isInDeleteButton = YES;
    }
    else {
        
        [self showSpectrum];
        tipLabel.text = UMCLocalizedString(@"udesk_hold_to_talk");
        [deleteButton setImage:[UIImage umcDefaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
        
        isInDeleteButton = NO;
    }
}

- (void)recordCancel:(UIButton *)button
{
    [self hideSpectrum];
    if (isInDeleteButton) {
        
        [self cancelRecord];
    }
    else {
        [self finishRecord];
    }
}

- (void)recordStart:(UIButton *)button
{
    if ([self canRecord]) {
        
        @udWeakify(self);
        [self.voiceRecordHelper prepareRecordingCompletion:^BOOL{
            
            @udStrongify(self);
            [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:nil];
            
            return YES;
        }];
        
        self.isMaxTime = NO;
        [self showSpectrum];
        [spectrumView.stopwatch start];
    }
}

- (void)recordFinish:(UIButton *)button
{
    [self hideSpectrum];
    if (isInDeleteButton) {
        
        [self cancelRecord];
    }
    else {
        [self finishRecord];
    }
}

- (void)cancelRecord {
    
    [spectrumView.stopwatch reset];
    [spectrumView.stopwatch pause];
    
    [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
}

- (void)hideSpectrum {
    
    spectrumView.hidden = YES;
    tipLabel.text = UMCLocalizedString(@"udesk_hold_to_talk");
    tipLabel.hidden = NO;
    deleteButton.hidden = YES;
    [deleteButton setImage:[UIImage umcDefaultDeleteRecordVoiceImage] forState:UIControlStateNormal];
}

- (void)showSpectrum {
    
    spectrumView.hidden = NO;
    tipLabel.hidden = YES;
    deleteButton.hidden = NO;
}

- (void)finishRecord {
    
    //最大时间了，为了解决重复发送
    if (self.isMaxTime) {
        
        [spectrumView.stopwatch reset];
        [spectrumView.stopwatch pause];
        
        return;
    }
    
    [spectrumView.stopwatch pause];
    if (recordTime >1.5f) {
        
        @try {
            @udWeakify(self);
            [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
                @udStrongify(self);
                @try {
                    [self.delegate finishRecordedWithVoicePath:self.voiceRecordHelper.recordPath withAudioDuration:[NSString stringWithFormat:@"%.f", recordTime]];
                } @catch (NSException *exception) {
                } @finally {
                }
            }];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    if (recordTime <= 1.5f) {
        @try {
            
            [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
            [self.delegate speakDurationTooShort];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    
    [spectrumView.stopwatch reset];
}

//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if (kUMCSystemVersion >= 7.0)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:UMCLocalizedString(@"udesk_microphone_denied")
                                                   delegate:nil
                                          cancelButtonTitle:UMCLocalizedString(@"udesk_close")
                                          otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}

#pragma mark - 录制语音
- (UMCVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        
        @udWeakify(self);
        _voiceRecordHelper = [[UMCVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            @udStrongify(self);
            [self hideSpectrum];
            [self finishRecord];
            self.isMaxTime = YES;
        };
        
        _voiceRecordHelper.maxRecordTime = kUMCVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

@end
