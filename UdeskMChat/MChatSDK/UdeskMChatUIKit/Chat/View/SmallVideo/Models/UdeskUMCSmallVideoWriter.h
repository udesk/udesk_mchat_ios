//
//  UdeskSmallVideoWriter.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class UdeskUMCSmallVideoWriter;

@protocol UMCSmallVideoWriterDelegate <NSObject>
- (void)smallVideoWriterDidFinishRecording:(UdeskUMCSmallVideoWriter *)recorder status:(BOOL)isCancle;

@end

@interface UdeskUMCSmallVideoWriter : NSObject

@property (nonatomic, weak) id<UMCSmallVideoWriterDelegate> delegate;
@property (nonatomic, strong, readonly) NSURL *recordingURL;

- (instancetype)initWithURL:(NSURL *)URL cropSize:(CGSize)cropSize;

- (void)finishRecording;//正常结束
- (void)cancleRecording;//取消录制

- (void)appendAudioBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)appendVideoBuffer:(CMSampleBufferRef)sampleBuffer;

@end
