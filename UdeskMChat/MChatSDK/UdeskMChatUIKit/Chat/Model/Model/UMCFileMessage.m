//
//  UMCFileMessage.m
//  UdeskMChat
//
//  Created by xuchen on 2020/7/2.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCFileMessage.h"
#import "UMCFileCell.h"
#import "UIImage+UMC.h"
#import "NSString+UMC.h"

/** 文件Icon */
static CGFloat const kUMCFileIconSize = 32.0;
/** 文件size */
static CGFloat const kUMCFileSizeWidth = 60.0;
/** 文件size */
static CGFloat const kUMCFileSizeHeight = 15.0;
/** 垂直间距 */
static CGFloat const kUMCFileSizeToVerticalSpacing = 5.0;
/** 水平间距 */
static CGFloat const kUMCFileHorizontalSpacing = 10.0;
/** 垂直间距 */
static CGFloat const kUMCFileVerticalSpacing = 8.0;

@interface UMCFileMessage()

@property (nonatomic, assign, readwrite) CGRect iconFrame;
@property (nonatomic, assign, readwrite) CGRect nameFrame;
@property (nonatomic, assign, readwrite) CGRect sizeFrame;
@property (nonatomic, assign, readwrite) CGRect proressFrame;
@property (nonatomic, strong, readwrite) UIImage *fileIcon;

@end

@implementation UMCFileMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self parseFileIcon];
        [self layoutFileMessage];
    }
    return self;
}

- (void)layoutFileMessage {
    
    CGSize nameSize = [self.message.extras.filename umcSizeForFont:[UIFont systemFontOfSize:13] size:CGSizeMake(150, 35) mode:NSLineBreakByWordWrapping];
    CGFloat bubbleWidth = nameSize.width+kUMCFileIconSize+(kUMCFileHorizontalSpacing*4);
    
    switch (self.message.direction) {
        case UMCMessageDirectionIn:{
            
            //图片气泡位置
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-bubbleWidth, self.avatarFrame.origin.y, bubbleWidth, nameSize.height+kUMCFileSizeHeight+(kUMCFileVerticalSpacing*2)+kUMCFileSizeToVerticalSpacing);
            //icon位置
            self.iconFrame = CGRectMake(kUMCFileHorizontalSpacing, kUMCFileVerticalSpacing, kUMCFileIconSize, kUMCFileIconSize);
            //label位置
            self.nameFrame = CGRectMake(CGRectGetMaxX(self.iconFrame)+kUMCFileHorizontalSpacing, kUMCFileVerticalSpacing, CGRectGetWidth(self.bubbleFrame)-(kUMCFileHorizontalSpacing*3)-kUMCFileIconSize, nameSize.height);
            //size位置
            self.sizeFrame = CGRectMake(CGRectGetMaxX(self.iconFrame)+kUMCFileHorizontalSpacing, CGRectGetMaxY(self.nameFrame)+kUMCFileSizeToVerticalSpacing, kUMCFileSizeWidth, kUMCFileSizeHeight);
            //进度条
            self.proressFrame = CGRectMake(5, CGRectGetHeight(self.bubbleFrame)-2, bubbleWidth-kUDArrowMarginWidth-5, 5);
            //发送中frame
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            //发送失败frame
            self.failureFrame = self.loadingFrame;
            
            break;
        }
        case UMCMessageDirectionOut: {
            
            //图片气泡frame
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, bubbleWidth, nameSize.height+kUMCFileSizeHeight+(kUMCFileVerticalSpacing*2)+kUMCFileSizeToVerticalSpacing);
            //icon位置
            self.iconFrame = CGRectMake(kUMCFileHorizontalSpacing, kUMCFileVerticalSpacing, kUMCFileIconSize, kUMCFileIconSize);
            //label位置
            self.nameFrame = CGRectMake(CGRectGetMaxX(self.iconFrame)+kUMCFileHorizontalSpacing, kUMCFileVerticalSpacing, CGRectGetWidth(self.bubbleFrame)-(kUMCFileHorizontalSpacing*3)-kUMCFileIconSize, nameSize.height);
            //size位置
            self.sizeFrame = CGRectMake(CGRectGetMaxX(self.iconFrame)+kUMCFileHorizontalSpacing, CGRectGetMaxY(self.nameFrame)+kUMCFileSizeToVerticalSpacing, kUMCFileSizeWidth, kUMCFileSizeHeight);
            
            break;
        }
            
        default:
            break;
    }
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (void)parseFileIcon {
    
    NSString *fileType = [[self.message.extras.filename componentsSeparatedByString:@"."] lastObject];
    
    if ([fileType isEqualToString:@"csv"] || [fileType isEqualToString:@"xls"] || [fileType isEqualToString:@"xlsx"]) {
        if (self.message.direction == UMCMessageDirectionIn) {
            self.fileIcon = [UIImage umcDefaultFileSendExcel];
        } else {
            self.fileIcon = [UIImage umcDefaultFileReceiveExcel];
        }
    } else if ([fileType isEqualToString:@"doc"] || [fileType isEqualToString:@"docx"]) {
        if (self.message.direction == UMCMessageDirectionIn) {
            self.fileIcon = [UIImage umcDefaultFileSendWord];
        } else {
            self.fileIcon = [UIImage umcDefaultFileReceiveWord];
        }
    } else if ([fileType isEqualToString:@"ppt"] || [fileType isEqualToString:@"pptx"]) {
        if (self.message.direction == UMCMessageDirectionIn) {
            self.fileIcon = [UIImage umcDefaultFileSendPPT];
        } else {
            self.fileIcon = [UIImage umcDefaultFileReceivePPT];
        }
    } else if ([fileType isEqualToString:@"pdf"]) {
        if (self.message.direction == UMCMessageDirectionIn) {
            self.fileIcon = [UIImage umcDefaultFileSendPDF];
        } else {
            self.fileIcon = [UIImage umcDefaultFileReceivePDF];
        }
    } else if ([fileType isEqualToString:@"txt"]) {
        if (self.message.direction == UMCMessageDirectionIn) {
            self.fileIcon = [UIImage umcDefaultFileSendTxt];
        } else {
            self.fileIcon = [UIImage umcDefaultFileReceiveTxt];
        }
    } else {
        if (self.message.direction == UMCMessageDirectionIn) {
            self.fileIcon = [UIImage umcDefaultFileSendOther];
        } else {
            self.fileIcon = [UIImage umcDefaultFileReceiveOther];
        }
    }
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UMCFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
