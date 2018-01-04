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
#import "NSDate+UMC.h"
#import "UMCHelper.h"

#import "SDWebImageManager.h"
#import "YYCache.h"

@interface UMCIMManager()<UMCMessageDelegate>

//消息数组
@property (nonatomic, strong, readwrite) NSArray *messagesArray;
//是否还有更多
@property (nonatomic, assign, readwrite) BOOL hasMore;

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

/** 获取新消息 */
- (void)fetchNewMessages:(void (^)(void))completion {
    
    [UMCManager getMessagesWithMerchantsEuid:_merchantId messageUUID:nil completion:^(NSArray<UMCMessage *> *merchantsArray) {
        self.hasMore = merchantsArray.count;
        self.messagesArray = nil;
        [self appendServerMessages:merchantsArray];
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
    
    NSArray *array = [self.messagesArray valueForKey:@"messageId"];
    [UMCManager getMessagesWithMerchantsEuid:_merchantId messageUUID:array.firstObject completion:^(NSArray<UMCMessage *> *merchantsArray) {
        self.hasMore = merchantsArray.count;
        [self appendServerMessages:merchantsArray];
    }];
}

/** 发送文本消息 */
- (void)sendTextMessage:(NSString *)text
             completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initTextChatMessage:text];
    [self createMessage:message completion:completion];
}

/** 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initImageChatMessage:image];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [self createMediaMessage:message mediaData:data completion:completion];
}

/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData
                 completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initGIFImageChatMessage:gifData];
    
    [self createMediaMessage:message mediaData:gifData completion:completion];
}

/** 发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath
           voiceDuration:(NSString *)voiceDuration
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initVoiceChatMessage:[NSData dataWithContentsOfFile:voicePath] duration:voiceDuration];
    
    [self createMediaMessage:message mediaData:[NSData dataWithContentsOfFile:voicePath] completion:completion];
}

- (void)createMessage:(UMCMessage *)message completion:(void(^)(UMCMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    
    //转换成要展示的model
    [self appendReceiveMsg:message];
    
    [UMCManager createMessageWithMerchantsEuid:self.merchantId message:message completion:^(UMCMessage *newMessage) {
        
        [self updateCache:message newMessage:newMessage];
        if (completion) {
            completion(message);
        }
    }];
}

- (void)createMediaMessage:(UMCMessage *)message mediaData:(NSData *)mediaData completion:(void(^)(UMCMessage *message))completion {
    
    if (!message || message == (id)kCFNull) return ;
    
    //转换成要展示的model
    [self appendReceiveMsg:message];
    
    //上传文件
    [UMCManager uploadFile:mediaData fileName:message.UUID completion:^(NSString *address, NSError *error) {
        
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
            
            UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:oldMessage.UUID];
            [[SDWebImageManager sharedManager].imageCache removeImageForKey:oldMessage.UUID withCompletion:nil];
            [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:newMessage.UUID completion:nil];
            
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

- (void)appendServerMessages:(NSArray *)messages {
    
    if (messages.count < 1) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *mMessages = [NSMutableArray arrayWithArray:[[self.messagesArray reverseObjectEnumerator] allObjects]];
        @try {
         
            for (UMCMessage *message in messages) {
                UMCBaseMessage *baseMsg = [self umcChatMessageWithMessage:message];
                if (baseMsg) {
                    [mMessages addObject:baseMsg];
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.messagesArray = [[[mMessages reverseObjectEnumerator] allObjects] copy];
            [self reloadMessages];
        });
    });
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
    
    if ([message.merchantEuid isEqualToString:self.merchantId]) {
        //转换成要展示的model
        [self appendReceiveMsg:message];
    }
}

- (void)appendReceiveMsg:(UMCMessage *)message {
    
    @try {
     
        NSMutableArray *mMessages = [NSMutableArray arrayWithArray:self.messagesArray];
        UMCBaseMessage *baseMsg = [self umcChatMessageWithMessage:message];
        if (baseMsg) {
            [mMessages addObject:baseMsg];
        }
        self.messagesArray = [mMessages copy];
        [self reloadMessages];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (UMCBaseMessage *)umcChatMessageWithMessage:(UMCMessage *)message {
    
    switch (message.category) {
        case UMCMessageCategoryTypeEvent:{
            
            UMCEventMessage *eventMessage = [[UMCEventMessage alloc] initWithMessage:message];
            return eventMessage;
            
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

