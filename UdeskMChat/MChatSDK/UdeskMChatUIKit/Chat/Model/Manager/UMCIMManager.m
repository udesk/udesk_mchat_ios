//
//  UMCIMManager.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCIMManager.h"
#import "UMCMessage+UMCChatMessage.h"
#import "UMCTextMessage.h"
#import "UMCImageMessage.h"
#import "UMCVoiceMessage.h"
#import "UMCEventMessage.h"
#import "UMCGoodsMessage.h"
#import "NSDate+UMC.h"
#import "UMCHelper.h"
#import "UMCImageHelper.h"
#import "UMCBundleHelper.h"

#import "SDWebImageManager.h"
#import "YYCache.h"

@interface UMCIMManager()<UMCMessageDelegate>

//消息数组
@property (nonatomic, strong, readwrite) NSArray *messagesArray;
//是否还有更多
@property (nonatomic, assign, readwrite) BOOL hasMore;
//满意度调查的配置
@property (nonatomic, strong, readwrite) id surveyResponseObject;

/** 商户ID */
@property (nonatomic, copy  ) NSString             *merchantId;
/** sdk配置 */
@property (nonatomic, strong) UMCSDKConfig         *sdkConfig;

@end

@implementation UMCIMManager

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantId:(NSString *)merchantId
{
    self = [super init];
    if (self) {
        
        _sdkConfig = config;
        _merchantId = merchantId;
        [self checkProduct];
        [[UMCDelegate shareInstance] addDelegate:self];
    }
    return self;
}

/** 获取商户详情 */
- (void)fetchMerchantWithMerchantId:(NSString *)merchantId
                         completion:(void (^)(UMCMerchant *merchant))completion {
    
    [UMCManager getMerchantWithMerchantId:merchantId completion:completion];
}

/** 标记商户消息为已读 */
- (void)readMerchantsWithMerchantId:(NSString *)merchantId
                         completion:(void(^)(BOOL result))completion {
    
    [UMCManager readMerchantsWithEuid:merchantId completion:completion];
}

/** 获取满意度调查配置 */
- (void)fetchSurveyConfig:(void(^)(BOOL isShowSurvey,BOOL afterSession))completion {
    
    [UMCManager getSurveyOptionsWithMerchantId:self.merchantId completion:^(id responseObject, NSError *error) {
        
        self.surveyResponseObject = responseObject;
        
    } configHandle:^(BOOL surveyEnabled, BOOL afterSession) {
        
        if (completion) {
            completion(surveyEnabled,afterSession);
        }
    }];
}

/** 获取新消息 */
- (void)fetchNewMessages:(void (^)(void))completion {
    
    [UMCManager getMessagesWithMerchantsEuid:_merchantId messageUUID:nil completion:^(NSArray<UMCMessage *> *merchantsArray) {
        self.hasMore = merchantsArray.count;
        self.messagesArray = nil;
        [self updateMerchantMessagesArray:merchantsArray];
    }];
}

/** 获取消息记录 */
- (void)fetchMessages:(void (^)(void))completion {
    
    [self serverMessages:completion];
}

/** 下一页消息记录 */
- (void)nextMessages:(void (^)(void))completion {
    
    [self serverMessages:completion];
}

- (void)serverMessages:(void (^)(void))completion {
    
    NSString *messageUUID;
    NSArray *array = [self.messagesArray valueForKey:@"messageId"];
    if (array && array.count>0) {
        messageUUID = array.firstObject;
    }
    
    [UMCManager getMessagesWithMerchantsEuid:_merchantId messageUUID:messageUUID completion:^(NSArray<UMCMessage *> *merchantsArray) {
        self.hasMore = merchantsArray.count;
        [self updateMerchantMessagesArray:merchantsArray];
    }];
}

- (void)updateMerchantMessagesArray:(NSArray *)messagesArrat {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
        for (UMCMessage *message in messagesArrat) {
            UMCBaseMessage *baseMsg = [self umcChatMessageWithMessage:message];
            if (baseMsg) {
                [array insertObject:baseMsg atIndex:0];
            }
        }
        
        self.messagesArray = [array copy];
        [self reloadMessages];
    });
}

/** 发送文本消息 */
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithText:text];
    [self createMessage:message completion:completion];
}

/** 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithImage:image];
    
    NSData *data = [UMCImageHelper imageWithOriginalImage:[UMCImageHelper fixOrientation:image] quality:0.5];
    [self createMediaMessage:message mediaData:data fileName:[message.UUID stringByAppendingString:@".jpg"] completion:completion];
}

/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData
                 completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithGIFImage:gifData];
    [self createMediaMessage:message mediaData:gifData fileName:[message.UUID stringByAppendingString:@".gif"] completion:completion];
}

/** 发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath
           voiceDuration:(NSString *)voiceDuration
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithVoice:[NSData dataWithContentsOfFile:voicePath] duration:voiceDuration];
    [self createMediaMessage:message mediaData:[NSData dataWithContentsOfFile:voicePath] fileName:[message.UUID stringByAppendingString:@".aac"] completion:completion];
}

/** 发送商品消息 */
- (void)sendGoodsMessage:(UMCGoodsModel *)goodsModel completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithGoodsModel:goodsModel];
    [self createMessage:message completion:completion];
}

- (void)createMessage:(UMCMessage *)message completion:(void(^)(UMCMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    
    //转换成要展示的model
    [self addMessageToChatMessageArray:@[message]];
    
    [UMCManager createMessageWithMerchantsEuid:self.merchantId message:message completion:^(UMCMessage *newMessage) {
    
        [self updateCache:message newMessage:newMessage];
        if (completion) {
            completion(message);
        }
    }];
}

- (void)createMediaMessage:(UMCMessage *)message mediaData:(NSData *)mediaData fileName:(NSString *)fileName completion:(void(^)(UMCMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    
    //转换成要展示的model
    [self addMessageToChatMessageArray:@[message]];
    
    //上传文件
    [UMCManager uploadFile:mediaData fileName:fileName completion:^(NSString *address, NSError *error) {
        
        if (!error) {
            
            message.content = address;
            [UMCManager createMessageWithMerchantsEuid:self.merchantId message:message completion:^(UMCMessage *newMessage) {
                
                [self updateCache:message newMessage:newMessage];
                if (completion) {
                    completion(message);
                }
            }];
        }
    }];
}

//更新缓存
- (void)updateCache:(UMCMessage *)oldMessage newMessage:(UMCMessage *)newMessage {
    
    oldMessage.createdAt = newMessage.createdAt;
    oldMessage.messageStatus = newMessage.messageStatus;
    //更换uuid
    for (UMCBaseMessage *baseMessage in self.messagesArray) {
        if ([baseMessage.messageId isEqualToString:oldMessage.UUID]) {
            baseMessage.messageId = newMessage.UUID;
        }
    }
    
    switch (oldMessage.contentType) {
        case UMCMessageContentTypeImage:{
            
            [[SDWebImageManager sharedManager].imageCache queryImageForKey:oldMessage.UUID options:SDWebImageRetryFailed context:nil completion:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
                
                [[SDWebImageManager sharedManager].imageCache removeImageForKey:oldMessage.UUID cacheType:SDImageCacheTypeAll completion:nil];
                [[SDWebImageManager sharedManager].imageCache storeImage:image imageData:nil forKey:newMessage.UUID cacheType:SDImageCacheTypeAll completion:nil];
            }];
            break;
        }
        case UMCMessageContentTypeVoice:{
         
            YYCache *cache = [[YYCache alloc] initWithName:UMCVoiceCache];
            NSData *data = (NSData *)[cache objectForKey:oldMessage.UUID];
            [cache removeObjectForKey:oldMessage.UUID];
            [cache setObject:data forKey:newMessage.UUID];
            
            break;
        }
        default:
            break;
    }
    
    oldMessage.UUID = newMessage.UUID;
}

- (void)addMessageToChatMessageArray:(NSArray *)messages {
    if (messages.count < 1) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        @synchronized(self) {
            NSMutableArray *mMessages = [NSMutableArray arrayWithArray:self.messagesArray];
            for (UMCMessage *message in messages) {
                UMCBaseMessage *baseMsg = [self umcChatMessageWithMessage:message];
                if (baseMsg) {
                    [mMessages addObject:baseMsg];
                }
            }
            
            //数组去重
            NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:self.messagesArray];
            for (UMCBaseMessage *msg in mMessages) {
                if (![self checkMessage:msg existInList:tmpArray]) {
                    [tmpArray addObject:msg];
                }
            }
            
            self.messagesArray = [tmpArray copy];
            [self reloadMessages];
        }
    });
}

- (BOOL)checkMessage:(UMCBaseMessage *)msg existInList:(NSArray *)array {
    for (UMCBaseMessage *tmp in array) {
        if ([tmp.message.UUID isEqualToString:msg.message.UUID]) {
            return YES;
        }
    }
    return  NO;
}

- (void)reloadMessages {
    
    if (self.ReloadMessagesBlock) {
        self.ReloadMessagesBlock();
    }
}

//检查咨询对象
- (void)checkProduct {
    
    if (!self.sdkConfig.product) {
        return;
    }
    
    if (![self.sdkConfig.product isKindOfClass:[UMCProduct class]]) {
        return;
    }
    
    [UMCManager createProductWithMerchantsEuid:self.merchantId product:self.sdkConfig.product completion:nil];
}

#pragma mark - @protocol UMCManagerDelegate
- (void)didReceiveMessage:(UMCMessage *)message {
    if (!message || message == (id)kCFNull) return ;
    
    if ([message.merchantEuid isEqualToString:self.merchantId]) {
        
        //撤回消息
        if (message.category == UMCMessageCategoryTypeEvent && message.eventType == UMCEventContentTypeRollback) {
            for (UMCBaseMessage *baseMessage in self.messagesArray) {
                if ([baseMessage.message.UUID isEqualToString:message.UUID]) {
                    
                    NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
                    if ([array containsObject:baseMessage]) {
                        [array removeObject:baseMessage];
                        self.messagesArray = array;
                    }
                    message.content = UMCLocalizedString(@"udesk_rollback");
                }
            }
        }
        
        //转换成要展示的model
        [self addMessageToChatMessageArray:@[message]];
        
        if (message.category == UMCMessageCategoryTypeEvent && message.eventType == UMCEventContentTypeSurvey) {
            
            if (self.DidReceiveInviteSurveyBlock) {
                self.DidReceiveInviteSurveyBlock(message.merchantEuid);
            }
        }
    }
}

- (UMCBaseMessage *)umcChatMessageWithMessage:(UMCMessage *)message {
    
    switch (message.category) {
        case UMCMessageCategoryTypeEvent:{
            
            //撤回消息
            if (message.eventType == UMCEventContentTypeRollback) {
                message.content = UMCLocalizedString(@"udesk_rollback");
            }
            
            if (message.eventType != UMCEventContentTypeSurvey) {
                UMCEventMessage *eventMessage = [[UMCEventMessage alloc] initWithMessage:message];
                return eventMessage;
            }
            
            break;
        }
        case UMCMessageCategoryTypeChat:{
            
            switch (message.contentType) {
                case UMCMessageContentTypeText:{
                    
                    UMCTextMessage *textMessage = [[UMCTextMessage alloc] initWithMessage:message];
                    return textMessage;
                    break;
                }
                case UMCMessageContentTypeImage:{
                    
                    UMCImageMessage *imageMessage = [[UMCImageMessage alloc] initWithMessage:message];
                    return imageMessage;
                    break;
                }
                case UMCMessageContentTypeVoice: {
                    
                    UMCVoiceMessage *voiceMessage = [[UMCVoiceMessage alloc] initWithMessage:message];
                    return voiceMessage;
                    break;
                }
                case UMCMessageContentTypeGoods: {
                    
                    UMCGoodsMessage *goodsMessage = [[UMCGoodsMessage alloc] initWithMessage:message];
                    return goodsMessage;
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
        default:
            break;
    }
    
    return nil;
}

@end
