//
//  UMCIMManager.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UMCSDKConfig.h"

@class UMCGoodsModel;

@interface UMCIMManager : NSObject

//消息数组
@property (nonatomic, strong, readonly) NSArray *messagesArray;
//是否还有更多
@property (nonatomic, assign, readonly) BOOL hasMore;
//满意度调查的配置
@property (nonatomic, strong, readonly) id surveyResponseObject;

@property (nonatomic, copy  ) void(^ReloadMessagesBlock)(void);
@property (nonatomic, copy  ) void(^DidReceiveInviteSurveyBlock)(NSString *merchantEuid);

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantId:(NSString *)merchantId;

/** 单个商户详情 */
- (void)fetchMerchantWithMerchantId:(NSString *)merchantId
                         completion:(void (^)(UMCMerchant *merchant))completion;

/** 标记商户消息已读 */
- (void)readMerchantsWithMerchantId:(NSString *)merchantId
                         completion:(void(^)(BOOL result))completion;

/** 获取满意度调查配置 */
- (void)fetchSurveyConfig:(void(^)(BOOL isShowSurvey,BOOL afterSession))completion;

/** 获取新消息 */
- (void)fetchNewMessages:(void (^)(void))completion;

/** 获取消息记录 */
- (void)fetchMessages:(void(^)(void))completion;

/** 下一页消息记录 */
- (void)nextMessages:(void (^)(void))completion;

/** 发送文本消息 */
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UMCMessage *message))completion;

/** 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image
                progress:(void(^)(UMCMessage *message,float percent))progress
              completion:(void(^)(UMCMessage *message))completion;

/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData
                   progress:(void(^)(UMCMessage *message,float percent))progress
                 completion:(void(^)(UMCMessage *message))completion;

/**  发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath
           voiceDuration:(NSString *)voiceDuration
              completion:(void(^)(UMCMessage *message))completion;

/** 发送视频消息 */
- (void)sendVideoMessage:(NSData *)videoData
                progress:(void(^)(UMCMessage *message,float percent))progress
              completion:(void(^)(UMCMessage *message))completion;

/** 发送商品消息 */
- (void)sendGoodsMessage:(UMCGoodsModel *)goodsModel completion:(void(^)(UMCMessage *message))completion;

//更新缓存
- (void)updateCache:(UMCMessage *)oldMessage newMessage:(UMCMessage *)newMessage;

@end
