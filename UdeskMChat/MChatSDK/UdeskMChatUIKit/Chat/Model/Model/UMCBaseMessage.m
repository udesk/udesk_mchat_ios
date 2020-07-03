//
//  UMCBaseMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"
#import "UIImage+UMC.h"
#import "UMCUIMacro.h"
#import "NSDate+UMC.h"
#import "UMCSDKConfig.h"
#import "UMCGoodsCell.h"

/** 头像距离屏幕水平边沿距离 */
const CGFloat kUDAvatarToHorizontalEdgeSpacing = 8.0;
/** 头像距离屏幕垂直边沿距离 */
const CGFloat kUDAvatarToVerticalEdgeSpacing = 15.0;
/** 头像与聊天气泡之间的距离 */
const CGFloat kUDAvatarToBubbleSpacing = 8.0;
/** 聊天气泡和Indicator的间距 */
const CGFloat kUDCellBubbleToIndicatorSpacing = 5.0;
/** 聊天头像大小 */
const CGFloat kUDAvatarDiameter = 40.0;
/** 时间高度 */
const CGFloat kUDChatMessageDateCellHeight = 10.0f;
/** 发送状态大小 */
const CGFloat kUDSendStatusDiameter = 20.0;
/** 发送状态与气泡的距离 */
const CGFloat kUDBubbleToSendStatusSpacing = 10.0;
/** 时间 Y */
const CGFloat kUDChatMessageDateLabelY   = 10.0f;
/** 气泡箭头宽度 */
const CGFloat kUDArrowMarginWidth        = 10.5f;
/** 底部留白 */
const CGFloat kUDCellBottomMargin = 10.0;

@interface UMCBaseMessage()

/** date高度 */
@property (nonatomic, assign) CGFloat    dateHeight;
/** 消息发送人昵称 */
@property (nonatomic, copy  ) NSString   *nickName;
/** 聊天气泡图片 */
@property (nonatomic, strong) UIImage    *bubbleImage;
/** 重发图片 */
@property (nonatomic, strong) UIImage    *failureImage;
/** 消息发送人头像 */
@property (nonatomic, copy  , readwrite) NSString   *avatarURL;
/** 消息发送人头像 */
@property (nonatomic, strong, readwrite) UIImage  *avatarImage;

@end

@implementation UMCBaseMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super init];
    if (self) {
        
        _message = message;
        _messageId = message.UUID;
        
        [self defaultLayout];
    }
    return self;
}

- (void)defaultLayout {
    
    [self layoutDate];
    [self layoutAvatar];
    
    //重发按钮图片
    self.failureImage = [UIImage umcDefaultRefreshImage];
    
    _cellHeight += _dateHeight;
    _cellHeight += kUDCellBottomMargin;
}

//时间
- (void)layoutDate {
    
    _dateHeight = 0;
    
    NSString *time = [[NSDate dateWithString:self.message.createdAt format:kUMCDateFormat] umcStyleDate];
    if (time.length == 0) return;
    
    _dateFrame = CGRectMake(0, kUDChatMessageDateLabelY, kUMCScreenWidth-(kUDAvatarToHorizontalEdgeSpacing*2+kUDAvatarDiameter), kUDChatMessageDateCellHeight);
    _dateHeight = kUDChatMessageDateCellHeight;
}

//头像
- (void)layoutAvatar {
    
    if (self.message.category == UMCMessageCategoryTypeChat) {
        
        //布局
        if (self.message.direction == UMCMessageDirectionOut) {
            //客服头像frame
            self.avatarFrame = CGRectMake(kUDAvatarToHorizontalEdgeSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
        }
        else if (self.message.direction == UMCMessageDirectionIn) {
            
            self.avatarFrame = CGRectMake(kUMCScreenWidth-kUDAvatarToHorizontalEdgeSpacing-kUDAvatarDiameter, self.dateFrame.origin.y+self.dateFrame.size.height+ kUDAvatarToVerticalEdgeSpacing, kUDAvatarDiameter, kUDAvatarDiameter);
        }
    }    
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
