//
//  UMCVoiceRecord.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef BOOL(^UMCPrepareRecorderCompletion)(void);
typedef void(^UMCStartRecorderCompletion)(void);
typedef void(^UMCStopRecorderCompletion)(void);
typedef void(^UMCTooShortRecorderFailue)(void);
typedef void(^UMCPauseRecorderCompletion)(void);
typedef void(^UMCResumeRecorderCompletion)(void);
typedef void(^UMCCancellRecorderDeleteFileCompletion)(void);
typedef void(^UMCRecordProgress)(float progress);
typedef void(^UMCPeakPowerForChannel)(float peakPowerForChannel);

static CGFloat kUMCVoiceRecorderTotalTime = 60;

@interface UMCVoiceRecord : NSObject

/**
 *  录制语音
 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

/**
 *  录音到最大时长callback结束录音
 */
@property (nonatomic, copy) UMCStopRecorderCompletion maxTimeStopRecorderCompletion;
/**
 *  时间太短
 */
@property (nonatomic, copy) UMCTooShortRecorderFailue tooShortRecorderFailue;
/**
 *  录音进度callback
 */
@property (nonatomic, copy) UMCRecordProgress recordProgress;
/**
 *  分贝
 */
@property (nonatomic, copy) UMCPeakPowerForChannel peakPowerForChannel;
/**
 *  语音文件地址
 */
@property (nonatomic, copy, readonly) NSString *recordPath;
/**
 *  语音时长
 */
@property (nonatomic, copy) NSString *recordDuration;
/**
 *  语音最长时间 默认60秒最大
 */
@property (nonatomic) float maxRecordTime;
/**
 *  当前语音时间
 */
@property (nonatomic, readonly) NSTimeInterval currentTimeInterval;

/**
 *  准备录音
 *
 *  @param completion 准备完成callback
 */
- (void)prepareRecordingCompletion:(UMCPrepareRecorderCompletion)completion;
/**
 *  录音开始
 *
 *  @param startRecorderCompletion 录音开始callback
 */
- (void)startRecordingWithStartRecorderCompletion:(UMCStartRecorderCompletion)startRecorderCompletion;
/**
 *  暂停录音
 *
 *  @param pauseRecorderCompletion 暂停callback
 */
- (void)pauseRecordingWithPauseRecorderCompletion:(UMCPauseRecorderCompletion)pauseRecorderCompletion;
/**
 *  恢复录音
 *
 *  @param resumeRecorderCompletion 恢复callback
 */
- (void)resumeRecordingWithResumeRecorderCompletion:(UMCResumeRecorderCompletion)resumeRecorderCompletion;
/**
 *  停止录音
 *
 *  @param stopRecorderCompletion 停止callback
 */
- (void)stopRecordingWithStopRecorderCompletion:(UMCStopRecorderCompletion)stopRecorderCompletion;
/**
 *  取消录音
 *
 *  @param cancelledDeleteCompletion 取消callback
 */
- (void)cancelledDeleteWithCompletion:(UMCCancellRecorderDeleteFileCompletion)cancelledDeleteCompletion;
/**
 *  录音失败
 *
 *  @param tooShortRecorderFailue tooShortRecorderFailue
 */
- (void)tooShortRecordWithFailue:(UMCTooShortRecorderFailue)tooShortRecorderFailue;

@end
