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

@interface UMCIMManager : NSObject

//消息数组
@property (nonatomic, strong, readonly) NSArray *messagesArray;
//是否还有更多
@property (nonatomic, assign, readonly) BOOL hasMore;

@property (nonatomic, copy  ) void(^ReloadMessagesBlock)(void);

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantId:(NSString *)merchantId;

/** 单个商户详情 */
- (void)fetchMerchantWithMerchantId:(NSString *)merchantId
                         completion:(void (^)(UMCMerchant *merchant))completion;

/** 标记商户消息已读 */
- (void)readMerchantsWithMerchantId:(NSString *)merchantId
                         completion:(void(^)(BOOL result))completion;

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
              completion:(void(^)(UMCMessage *message))completion;

/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData
                 completion:(void(^)(UMCMessage *message))completion;

/**  发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath
           voiceDuration:(NSString *)voiceDuration
              completion:(void(^)(UMCMessage *message))completion;

@end
