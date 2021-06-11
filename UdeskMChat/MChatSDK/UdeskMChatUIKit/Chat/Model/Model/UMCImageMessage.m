//
//  UMCImageMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCImageMessage.h"
#import "UMCImageCell.h"

/** 聊天气泡和其中的图片水平间距 */
static CGFloat const kUDBubbleToImageHorizontalSpacing = 5.0;
static CGFloat const kUDImageUploadProgressHeight = 15.0;
static CGFloat const kUDImageWidth = 150.0;
static CGFloat const kUDImageHeight = 150.0;

@interface UMCImageMessage()

//图片frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect imageFrame;
@property (nonatomic, assign, readwrite) CGRect  shadowFrame;
@property (nonatomic, assign, readwrite) CGRect  imageLoadingFrame;
@property (nonatomic, assign, readwrite) CGRect  imageProgressFrame;
@property (nonatomic, strong, readwrite) UMC_YYImage *image;

@end

@implementation UMCImageMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        if (self.message.sourceData) {
            self.image = [UMC_YYImage imageWithData:self.message.sourceData];
        }
        [self layoutImageMessage];
    }
    return self;
}

- (void)layoutImageMessage {
    
    CGSize imageSize = CGSizeMake(kUDImageWidth, kUDImageHeight);
    
    switch (self.message.direction) {
        case UMCMessageDirectionIn:{
            
            //图片气泡位置
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToImageHorizontalSpacing*2-kUDMAvatarToBubbleSpacing-imageSize.width, self.avatarFrame.origin.y, imageSize.width+(kUDBubbleToImageHorizontalSpacing*4), imageSize.height+(kUDBubbleToImageHorizontalSpacing*2));
            //图片位置
            self.imageFrame = CGRectMake(0, 0, CGRectGetWidth(self.bubbleFrame), CGRectGetHeight(self.bubbleFrame));
            //阴影
            self.shadowFrame = self.imageFrame;
            //loading
            self.imageLoadingFrame = CGRectMake((CGRectGetWidth(self.imageFrame)-kUDMSendStatusDiameter)/2, (CGRectGetHeight(self.imageFrame)-kUDMSendStatusDiameter)/2-kUDImageUploadProgressHeight, kUDMSendStatusDiameter, kUDMSendStatusDiameter);
            //进度
            self.imageProgressFrame = CGRectMake(0, CGRectGetMaxY(self.imageLoadingFrame)+kUDBubbleToImageHorizontalSpacing, CGRectGetWidth(self.imageFrame), kUDImageUploadProgressHeight);
            //发送中frame
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDMBubbleToSendStatusSpacing-kUDMSendStatusDiameter, self.bubbleFrame.origin.y+kUDMCellBubbleToIndicatorSpacing, kUDMSendStatusDiameter, kUDMSendStatusDiameter);
            //发送失败frame
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UMCMessageDirectionOut: {
            
            //图片气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDMAvatarDiameter+kUDMAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDMAvatarToVerticalEdgeSpacing, imageSize.width+(kUDBubbleToImageHorizontalSpacing*4), imageSize.height+(kUDBubbleToImageHorizontalSpacing*2));
            //图片frame
            self.imageFrame = CGRectMake(0, 0, CGRectGetWidth(self.bubbleFrame), CGRectGetHeight(self.bubbleFrame));
            
            break;
        }
            
        default:
            break;
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDMCellBottomMargin;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
