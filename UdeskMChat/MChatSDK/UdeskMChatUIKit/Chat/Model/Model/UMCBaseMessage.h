//
//  UMCBaseMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UdeskMChatSDK/UdeskMChatSDK.h>

/** 头像距离屏幕水平边沿距离 */
extern const CGFloat kUDAvatarToHorizontalEdgeSpacing;
/** 头像距离屏幕垂直边沿距离 */
extern const CGFloat kUDAvatarToVerticalEdgeSpacing;
/** 头像与聊天气泡之间的距离 */
extern const CGFloat kUDAvatarToBubbleSpacing;
/** 聊天气泡和Indicator的间距 */
extern const CGFloat kUDCellBubbleToIndicatorSpacing;
/** 聊天头像大小 */
extern const CGFloat kUDAvatarDiameter;
/** 时间高度 */
extern const CGFloat kUDChatMessageDateCellHeight;
/** 发送状态大小 */
extern const CGFloat kUDSendStatusDiameter;
/** 发送状态与气泡的距离 */
extern const CGFloat kUDBubbleToSendStatusSpacing;
/** 时间 Y */
extern const CGFloat kUDChatMessageDateLabelY;
/** 气泡箭头宽度 */
extern const CGFloat kUDArrowMarginWidth;
/** 底部留白 */
extern const CGFloat kUDCellBottomMargin;

@interface UMCBaseMessage : NSObject

/** 消息气泡frame */
@property (nonatomic, assign) CGRect     bubbleFrame;
/** 头像frame */
@property (nonatomic, assign) CGRect     avatarFrame;
/** 发送失败图片frame */
@property (nonatomic, assign) CGRect     failureFrame;
/** 发送中frame */
@property (nonatomic, assign) CGRect     loadingFrame;
/** 时间frame */
@property (nonatomic, assign) CGRect     dateFrame;
/** 消息ID */
@property (nonatomic, copy  ) NSString   *messageId;
/** cell高度 */
@property (nonatomic, assign) CGFloat  cellHeight;
/** 消息model */
@property (nonatomic, strong) UMCMessage *message;

- (instancetype)initWithMessage:(UMCMessage *)message;

/**
 *  通过重用的名字初始化cell
 *  @return 初始化了一个cell
 */
- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer;

@end
