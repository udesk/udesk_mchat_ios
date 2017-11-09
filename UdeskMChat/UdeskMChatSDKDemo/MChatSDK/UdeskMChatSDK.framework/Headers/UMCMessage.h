//
//  UMCMessage.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UMCMessageDirection) {
    UMCMessageDirectionIn, //发送
    UMCMessageDirectionOut, //接收
};

typedef NS_ENUM(NSUInteger, UMCMessageCategoryType) {
    UMCMessageCategoryTypeChat,          //普通消息
    UMCMessageCategoryTypeEvent,         //事件
};

typedef NS_ENUM(NSUInteger, UMCMessageContentType) {
    UMCMessageContentTypeText,          //文字
    UMCMessageContentTypeImage,         //图片
    UMCMessageContentTypeVoice,         //语音
    UMCMessageContentTypeProduct,       //咨询对象
};

typedef NS_ENUM(NSUInteger, UMCMessageStatus) {
    UMCMessageStatusFailed,             //发送失败
    UMCMessageStatusSuccess,            //发送成功
    UMCMessageStatusSending,            //发送中
};

@interface UMCProductExtras : NSObject

/** 自定义商品信息标题 */
@property (nonatomic, copy  ) NSString     *title;
/** 自定义商品信息内容 */
@property (nonatomic, copy  ) NSString     *content;

@end

@interface UMCProduct : NSObject

/** 图片地址 */
@property (nonatomic, copy  ) NSString     *image;
/** 标题 */
@property (nonatomic, copy  ) NSString     *title;
/** 商品链接 */
@property (nonatomic, copy  ) NSString     *url;
/** 自定义商品信息 */
@property (nonatomic, strong) NSArray<UMCProductExtras *>  *extras;

@end

@interface UMCMessageExtras : NSObject

//语音时长
@property (nonatomic, copy  ) NSString     *duration;

@end

@interface UMCMessage : NSObject

/** 消息附属 */
@property (nonatomic, strong) UMCMessageExtras *extras;
/** 咨询对象 */
@property (nonatomic, strong) UMCProduct *productMessage;
/** 消息类型 */
@property (nonatomic, assign) UMCMessageCategoryType category;
/** 消息内容类型 */
@property (nonatomic, assign) UMCMessageContentType contentType;
/** 消息方向 */
@property (nonatomic, assign) UMCMessageDirection direction;
/** 消息状态 */
@property (nonatomic, assign) UMCMessageStatus messageStatus;
/** 消息id */
@property (nonatomic, copy  ) NSString *UUID;
/** 消息内容 */
@property (nonatomic, copy  ) NSString *content;
/** 消息时间 */
@property (nonatomic, copy  ) NSString *createdAt;
/** 消息所属的商户 */
@property (nonatomic, copy  ) NSString *merchantEuid;

@end
