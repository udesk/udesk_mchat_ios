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
#import "UMCVideoMessage.h"
#import "NSDate+UMC.h"
#import "UMCHelper.h"
#import "UMCImageHelper.h"
#import "UMCBundleHelper.h"
#import "UMCVideoCache.h"

#import "Udesk_YYWebImage.h"

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

/** 发送文本消息 */
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithText:text];
    [self createMessage:message completion:completion];
}

/** 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image
                progress:(void(^)(UMCMessage *message,float percent))progress
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithImage:image];
    
    [[Udesk_YYWebImageManager sharedManager].cache setImage:[Udesk_YYImage imageWithData:message.sourceData] forKey:message.UUID];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.fileName progress:progress completion:completion];
}

/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData
                   progress:(void(^)(UMCMessage *message,float percent))progress
                 completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithGIFImage:gifData];
    
    //缓存图片
    [[Udesk_YYWebImageManager sharedManager].cache setImage:[Udesk_YYImage imageWithData:gifData] forKey:message.UUID];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.fileName progress:progress completion:completion];
}

/** 发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath
           voiceDuration:(NSString *)voiceDuration
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithVoice:[NSData dataWithContentsOfFile:voicePath] duration:voiceDuration];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.fileName progress:nil completion:completion];
}

/** 发送视频消息 */
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(UMCMessage *message,float percent))progress completion:(void(^)(UMCMessage *message))completion {
    
    //超过发送限制
    CGFloat size = videoData.length/1024.f/1024.f;
    if (size > 31.f) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:UMCLocalizedString(@"udesk_video_big_tips") preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_sure") style:UIAlertActionStyleCancel handler:nil]];
            [[UMCHelper currentViewController] presentViewController:alert animated:YES completion:nil];
        });
        return;
    }
    
    UMCMessage *message = [[UMCMessage alloc] initWithVideo:videoData];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.fileName progress:progress completion:completion];
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

- (void)createMediaMessage:(UMCMessage *)message mediaData:(NSData *)mediaData fileName:(NSString *)fileName progress:(void(^)(UMCMessage *message,float percent))progress completion:(void(^)(UMCMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    
    //转换成要展示的model
    [self addMessageToChatMessageArray:@[message]];
    
    //上传文件
    [UMCManager uploadFile:mediaData fileName:fileName progress:^(float percent) {
      
        if (progress) {
            progress(message,percent);
        }
        
    } completion:^(NSString *address, NSError *error) {
        
        if (!error) {
            message.content = address;
            [UMCManager createMessageWithMerchantsEuid:self.merchantId message:message completion:^(UMCMessage *newMessage) {
                
                [self updateCache:message newMessage:newMessage];
                if (completion) {
                    completion(message);
                }
            }];
        } else {
            message.messageStatus = UMCMessageStatusFailed;
            if (completion) {
                completion(message);
            }
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
            
            Udesk_YYImage *image = (Udesk_YYImage *)[[Udesk_YYWebImageManager sharedManager].cache getImageForKey:oldMessage.UUID];
            
            [[Udesk_YYWebImageManager sharedManager].cache removeImageForKey:oldMessage.UUID];
            [[Udesk_YYWebImageManager sharedManager].cache setImage:image forKey:newMessage.content];
            break;
        }
        case UMCMessageContentTypeVoice:{
         
            Udesk_YYCache *cache = [[Udesk_YYCache alloc] initWithName:UMCVoiceCache];
            NSData *data = (NSData *)[cache objectForKey:oldMessage.UUID];
            [cache removeObjectForKey:oldMessage.UUID];
            [cache setObject:data forKey:newMessage.UUID];
            
            break;
        }
        case UMCMessageContentTypeVideo:{
            
            if ([[UMCVideoCache sharedManager] containsObjectForKey:oldMessage.UUID]) {
                NSString *path = [[UMCVideoCache sharedManager] filePathForkey:oldMessage.UUID];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
                [[UMCVideoCache sharedManager] storeVideo:data videoId:newMessage.UUID];
                [[UMCVideoCache sharedManager] udRemoveObjectForKey:oldMessage.UUID];
            }
            
            break;
        }
        default:
            break;
    }
    
    oldMessage.UUID = newMessage.UUID;
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
            
            if ([UMCHelper isBlankString:message.content]) {
                return nil;
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
                    
                    if ([UMCHelper isBlankString:message.content]) {
                        return nil;
                    }
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
                case UMCMessageContentTypeVideo: {
                    
                    UMCVideoMessage *videoMessage = [[UMCVideoMessage alloc] initWithMessage:message];
                    return videoMessage;
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
