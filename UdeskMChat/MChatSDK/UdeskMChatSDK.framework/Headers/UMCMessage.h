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
    UMCMessageContentTypeVideo,         //视频
    UMCMessageContentTypeFile,          //文件
    UMCMessageContentTypeProduct,       //咨询对象
    UMCMessageContentTypeGoods,         //商品消息
    UMCMessageContentTypeNavigate,      //导航消息
};

typedef NS_ENUM(NSUInteger, UMCEventContentType) {
    UMCEventContentTypeSurvey,          //满意度调查
    UMCEventContentTypeSystem,          //系统消息
    UMCEventContentTypeRollback,        //撤回消息
    UMCEventContentTypeFeedbacks,       //留言消息
};

typedef NS_ENUM(NSUInteger, UMCMessageStatus) {
    UMCMessageStatusFailed,             //发送失败
    UMCMessageStatusSuccess,            //发送成功
    UMCMessageStatusSending,            //发送中
};

@interface UMCGoodsParamModel : NSObject

/** 文本 */
@property (nonatomic, copy  ) NSString *text;
/** 颜色 */
@property (nonatomic, copy  ) NSString *color;
/** 加粗 (1加粗-0不加粗) */
@property (nonatomic, strong) NSNumber *fold;
/** 换行（该段文本结束后换行，1换行-0不换行） */
@property (nonatomic, strong) NSNumber *udBreak;
/** 字体大小（单位px） */
@property (nonatomic, strong) NSNumber *size;

@end

@interface UMCGoodsModel : NSObject

/** 名称（必传） */
@property (nonatomic, copy) NSString *name;
/** 链接（必传） */
@property (nonatomic, copy) NSString *url;
/** 图片（必传） */
@property (nonatomic, copy) NSString *imgUrl;
/** 其他文本参数 */
@property (nonatomic, strong) NSArray<UMCGoodsParamModel *>  *params;

@end

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
@property (nonatomic, copy) NSString *duration;
/** 文件名称 */
@property (nonatomic, copy) NSString *filename;
/** 文件大小 */
@property (nonatomic, copy) NSString *filesize;
/** 文件类型 */
@property (nonatomic, copy) NSString *fileext;

@end

@interface UMCNavigate : NSObject

//导航id
@property (nonatomic, copy  ) NSString     *navigateId;
@property (nonatomic, copy  ) NSString     *parentId;
@property (nonatomic, copy  ) NSString     *itemName;
@property (nonatomic, copy  ) NSNumber     *hasNext;

@end

@interface UMCMessage : NSObject

/** 消息附属 */
@property (nonatomic, strong) UMCMessageExtras *extras;
/** 咨询对象 */
@property (nonatomic, strong) UMCProduct *productMessage;
/** 商品消息 */
@property (nonatomic, strong) UMCGoodsModel *goodsMessage;
/** 消息类型 */
@property (nonatomic, assign) UMCMessageCategoryType category;
/** 消息内容类型 */
@property (nonatomic, assign) UMCMessageContentType contentType;
/** 事件内容类型 */
@property (nonatomic, assign) UMCEventContentType eventType;
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
/** 资源数据（image/voice/video/file） */
@property (nonatomic, strong) NSData   *sourceData;

/** 导航栏引导语 */
@property (nonatomic, copy  ) NSString *navDescribe;
/** 导航消息 */
@property (nonatomic, strong) NSArray<UMCNavigate *> *navigates;
/** 导航是否可用 */
@property (nonatomic, assign) BOOL navEnabled;

@end
