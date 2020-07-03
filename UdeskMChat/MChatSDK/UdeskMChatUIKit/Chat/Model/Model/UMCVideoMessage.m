//
//  UMCVideoMessage.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/16.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCVideoMessage.h"
#import "UMCVideoCell.h"
#import "UMCVideoCache.h"
#import "UMCVideoUtil.h"
#import "UMCImageHelper.h"
#import "UMCHelper.h"
#import "UIImage+UMC.h"

/** 播放按钮宽度 */
const CGFloat kUDVideoPlayButtonWidth = 48;
/** 播放按钮高度 */
const CGFloat kUDVideoPlayButtonHeight = 48;
/** 下载按钮宽度 */
const CGFloat kUDVideoDownloadButtonWidth = 48;
/** 下载按钮高度 */
const CGFloat kUDVideoDownloadButtonHeight = 48;

/** 视频时间宽度 */
const CGFloat kUDVideoDurationWidth = 30;
/** 视频时间高度 */
const CGFloat kUDVideoDurationHeight = 20;
/** 视频时间水平边缘间隙 */
const CGFloat kUDVideoDurationHorizontalEdgeSpacing = 5;
/** 视频时间垂直边缘间隙 */
const CGFloat kUDVideoDurationVerticalEdgeSpacing = 5;

/** 下载进度宽度 */
const CGFloat kUDVideoUploadProgressWidth = 48;
/** 下载进度高度 */
const CGFloat kUDVideoUploadProgressHeight = 48;

@interface UMCVideoMessage()

/** 视频文件frame */
@property (nonatomic, assign, readwrite) CGRect videoFrame;
/** 视频文件名称frame */
@property (nonatomic, assign, readwrite) CGRect videoNameFrame;
/** 视频文件大小frame */
@property (nonatomic, assign, readwrite) CGRect videoSizeLaeblFrame;
/** 视频文件进度条frame */
@property (nonatomic, assign, readwrite) CGRect videoProgressFrame;
/** 视频文件百分比frame */
@property (nonatomic, assign, readwrite) CGRect videoProgressPercentFrame;

@property (nonatomic, assign, readwrite) CGRect previewFrame;
@property (nonatomic, assign, readwrite) CGRect playFrame;
@property (nonatomic, assign, readwrite) CGRect downloadFrame;
@property (nonatomic, assign, readwrite) CGRect videoDurationFrame;

@property (nonatomic, assign, readwrite) CGRect uploadProgressFrame;

@property (nonatomic, strong, readwrite) UIImage *previewImage;
@property (nonatomic, copy  , readwrite) NSString *videoDuration;

@end

@implementation UMCVideoMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self layoutVideoMessage];
    }
    return self;
}

- (void)layoutVideoMessage {

    if ([[UMCVideoCache sharedManager] containsObjectForKey:self.message.UUID]) {
        NSString *path = [[UMCVideoCache sharedManager] filePathForkey:self.message.UUID];
        NSURL *URL = [NSURL fileURLWithPath:path];
        self.previewImage = [UMCVideoUtil videoPreViewImageWithURL:URL.absoluteString];
        self.videoDuration = [UMCVideoUtil videoTimeFromDurationSecond:[UMCVideoUtil videoDurationWithURL:URL.absoluteString]];
        
        if (!self.previewImage) {
            [self serviceVideoData];
        }
    }
    else {
        [self serviceVideoData];
    }
    
    CGSize previewSize = CGSizeMake(150, 150);
    if (self.previewImage) {
        previewSize = [UMCImageHelper udImageSize:self.previewImage];
    }
    
    switch (self.message.direction) {
        case UMCMessageDirectionIn:{
            
            self.previewFrame = CGRectMake(self.avatarFrame.origin.x-kUDAvatarToBubbleSpacing-previewSize.width, self.avatarFrame.origin.y, previewSize.width, previewSize.height);
            //发送中
            self.loadingFrame = CGRectMake(self.previewFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.previewFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UMCMessageDirectionOut:{
            
            //视频
            self.previewFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, previewSize.width, previewSize.height);
            
            break;
        }
            
        default:
            break;
    }
    
    self.playFrame = CGRectMake((CGRectGetWidth(self.previewFrame)-kUDVideoPlayButtonWidth)/2, (CGRectGetHeight(self.previewFrame)-kUDVideoPlayButtonWidth)/2, kUDVideoPlayButtonWidth, kUDVideoPlayButtonHeight);
    self.downloadFrame = CGRectMake((CGRectGetWidth(self.previewFrame)-kUDVideoDownloadButtonWidth)/2, (CGRectGetHeight(self.previewFrame)-kUDVideoDownloadButtonHeight)/2, kUDVideoDownloadButtonWidth, kUDVideoDownloadButtonHeight);
    self.videoDurationFrame = CGRectMake(CGRectGetWidth(self.previewFrame)-kUDVideoDurationWidth-kUDVideoDurationHorizontalEdgeSpacing, CGRectGetHeight(self.previewFrame)-kUDVideoDurationHeight-kUDVideoDurationHorizontalEdgeSpacing, kUDVideoDurationWidth, kUDVideoDurationHeight);
    self.uploadProgressFrame = CGRectMake((CGRectGetWidth(self.previewFrame)-kUDVideoUploadProgressWidth)/2, (CGRectGetHeight(self.previewFrame)-kUDVideoUploadProgressHeight)/2, kUDVideoUploadProgressWidth, kUDVideoUploadProgressHeight);
    
    //cell高度
    self.cellHeight = self.previewFrame.size.height+self.previewFrame.origin.y+kUDCellBottomMargin;
}

- (void)serviceVideoData {
    
    self.previewImage = [UMCVideoUtil videoPreViewImageWithURL:self.message.content] ? : [UIImage umcDefaultLoadingImage];
    self.videoDuration = [UMCVideoUtil videoTimeFromDurationSecond:[UMCVideoUtil videoDurationWithURL:self.message.content]];
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
