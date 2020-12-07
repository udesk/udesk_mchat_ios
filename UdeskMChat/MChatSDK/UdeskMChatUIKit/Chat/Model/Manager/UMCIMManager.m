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
#import "UMCFileMessage.h"
#import "UMCNavigatesMessage.h"
#import "NSDate+UMC.h"
#import "UMCHelper.h"
#import "UMCImageHelper.h"
#import "UMCBundleHelper.h"
#import "UMCVideoCache.h"
#import "UMCToast.h"
#import "UMCWebViewController.h"

#import "Udesk_YYWebImage.h"

@interface UMCIMManager()<UMCMessageDelegate>

//消息数组
@property (nonatomic, strong, readwrite) NSArray *messagesArray;
//是否还有更多
@property (nonatomic, assign, readwrite) BOOL hasMore;
//满意度调查的配置
@property (nonatomic, strong, readwrite) id surveyResponseObject;

/** 商户ID */
@property (nonatomic, copy  ) NSString             *merchantEuid;
/** sdk配置 */
@property (nonatomic, strong) UMCSDKConfig         *sdkConfig;

@property (nonatomic, strong) NSArray  *navigatesArray;
@property (nonatomic, copy  ) NSString *navDescribe;
@property (nonatomic, copy, readwrite) NSString *menuId;

@property (nonatomic, assign) BOOL isNavigatesStatus;

@end

@implementation UMCIMManager

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantEuid:(NSString *)merchantEuid
{
    self = [super init];
    if (self) {
        
        _sdkConfig = config;
        _merchantEuid = merchantEuid;
        [[UMCDelegate shareInstance] addDelegate:self];
    }
    return self;
}

/** 获取商户详情 */
- (void)fetchMerchantWithMerchantEuid:(NSString *)merchantEuid
                           completion:(void (^)(UMCMerchant *merchant))completion {
    
    [UMCManager getMerchantWithMerchantEuid:merchantEuid completion:completion];
}

/** 标记商户消息为已读 */
- (void)readMerchantsWithMerchantEuid:(NSString *)merchantEuid
                         completion:(void(^)(BOOL result))completion {
    
    [UMCManager readMerchantsWithEuid:merchantEuid completion:completion];
}

/** 获取满意度调查配置 */
- (void)fetchSurveyConfig:(void(^)(BOOL isShowSurvey,BOOL afterSession))completion {
    
    [UMCManager getSurveyOptionsWithMerchantEuid:self.merchantEuid completion:^(id responseObject, NSError *error) {
        
        self.surveyResponseObject = responseObject;
        
    } configHandle:^(BOOL surveyEnabled, BOOL afterSession) {
        
        if (completion) {
            completion(surveyEnabled,afterSession);
        }
    }];
}

/** 获取导航配置 */
- (void)fetchNavigates:(void(^)(void))completion {
    
    @udWeakify(self);
    [UMCManager getNavigatesWithMerchantEuid:self.merchantEuid completion:^(NSString *navDescribe, NSArray<UMCNavigate *> *navigatesArray) {
        @udStrongify(self);
        
        if (!navigatesArray || navigatesArray.count == 0) {
            [self checkProduct];
            self.isNavigatesStatus = NO;
        } else {
            self.isNavigatesStatus = YES;
        }
        
        self.navigatesArray = navigatesArray;
        self.navDescribe = navDescribe;

        [self createNavigateMessageWithId:@"item_0"];
    }];
}

- (void)receiveMessageWithNavigateModel:(UMCNavigate *)model {
    
    if (model.hasNext.boolValue) {
        [self createNavigateMessageWithId:model.navigateId];
    } else {
        self.menuId = model.navigateId;
        self.isNavigatesStatus = NO;
        [self checkProduct];
    }
}

- (void)receiveMessageWithParentId:(NSString *)parentId {
    if (!self.navigatesArray || self.navigatesArray == (id)kCFNull) return ;
    if (self.navigatesArray.count == 0) return;
    
    NSString *lastParentId;
    for (UMCNavigate *navigate in self.navigatesArray) {
        if ([navigate.navigateId isEqualToString:parentId]) {
            lastParentId = navigate.parentId;
            continue;
        }
    }
    if (lastParentId) {
        NSMutableArray *array = [NSMutableArray array];
        for (UMCNavigate *navigate in self.navigatesArray) {
            if ([navigate.parentId isEqualToString:lastParentId]) {
                [array addObject:navigate];
            }
        }
        if (array.count) {
            UMCMessage *message = [[UMCMessage alloc] initWithNavigates:array navDescribe:self.navDescribe];
            message.merchantEuid = self.merchantEuid;
            [self didReceiveMessage:message];
        }
    }
}

- (void)createNavigateMessageWithId:(NSString *)navigateId {
    if (!self.navigatesArray || self.navigatesArray == (id)kCFNull) return ;
    if (self.navigatesArray.count == 0) return;
    
    NSMutableArray *array = [NSMutableArray array];
    for (UMCNavigate *navigate in self.navigatesArray) {
        if ([navigate.parentId isEqualToString:navigateId]) {
            [array addObject:navigate];
        }
    }
    UMCMessage *message = [[UMCMessage alloc] initWithNavigates:array navDescribe:self.navDescribe];
    message.merchantEuid = self.merchantEuid;
    [self didReceiveMessage:message];
    
    [UMCManager storeMessage:message];
}

/** 获取新消息 */
- (void)fetchNewMessages:(void (^)(void))completion {
    
    [UMCManager getMessagesWithMerchantsEuid:_merchantEuid messageUUID:nil completion:^(NSArray<UMCMessage *> *merchantsArray) {
        self.hasMore = merchantsArray.count;
        self.messagesArray = nil;
        [self addMessageToChatMessageArray:merchantsArray];
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
    
    [UMCManager getMessagesWithMerchantsEuid:_merchantEuid messageUUID:messageUUID completion:^(NSArray<UMCMessage *> *merchantsArray) {
        self.hasMore = merchantsArray.count;
        [self addMessageToChatMessageArray:merchantsArray];
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
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.extras.filename progress:progress completion:completion];
}

/** 发送gif图片消息 */
- (void)sendGIFImageMessage:(NSData *)gifData
                   progress:(void(^)(UMCMessage *message,float percent))progress
                 completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithGIFImage:gifData];
    
    //缓存图片
    [[Udesk_YYWebImageManager sharedManager].cache setImage:[Udesk_YYImage imageWithData:gifData] forKey:message.UUID];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.extras.filename progress:progress completion:completion];
}

/** 发送语音消息 */
- (void)sendVoiceMessage:(NSString *)voicePath
           voiceDuration:(NSString *)voiceDuration
              completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithVoice:[NSData dataWithContentsOfFile:voicePath] duration:voiceDuration];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.extras.filename progress:nil completion:completion];
}

/** 发送视频消息 */
- (void)sendVideoMessage:(NSData *)videoData progress:(void(^)(UMCMessage *message,float percent))progress completion:(void(^)(UMCMessage *message))completion {
    
    //超过发送限制
    if (![self checkFileSizeWithData:videoData alertTitle:UMCLocalizedString(@"udesk_video_big_tips")]) {
        return;
    }
    
    UMCMessage *message = [[UMCMessage alloc] initWithVideo:videoData];
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.extras.filename progress:progress completion:completion];
}

/** 发送文件消息 */
- (void)sendFileMessage:(NSString *)filePath progress:(void(^)(UMCMessage *message,float percent))progress completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithFile:filePath];
    //超过发送限制
    if (![self checkFileSizeWithData:message.sourceData alertTitle:UMCLocalizedString(@"udesk_file_big_tips")]) {
        return;
    }
    [self createMediaMessage:message mediaData:message.sourceData fileName:message.extras.filename progress:progress completion:completion];
}

- (BOOL)checkFileSizeWithData:(NSData *)data alertTitle:(NSString *)alertTitle {
    
    //超过发送限制
    CGFloat size = data.length/1024.f/1024.f;
    if (size > 31.f) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:alertTitle preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_sure") style:UIAlertActionStyleCancel handler:nil]];
            [[UMCHelper currentViewController] presentViewController:alert animated:YES completion:nil];
        });
        return NO;
    }
    return YES;
}

/** 发送商品消息 */
- (void)sendGoodsMessage:(UMCGoodsModel *)goodsModel completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithGoodsModel:goodsModel];
    [self createMessage:message completion:completion];
}

/** 发送导航消息 */
- (void)sendNavigateMessage:(NSString *)text
                 completion:(void(^)(UMCMessage *message))completion {
    
    UMCMessage *message = [[UMCMessage alloc] initWithNavigate:text];
    [self createMessage:message completion:completion];
}

//发送本地文本消息
- (void)sendLocalTextMessage:(NSString *)text {
    if (!text || text == (id)kCFNull) return ;
    if (![text isKindOfClass:[NSString class]]) return ;
    if (text.length == 0) return;

    UMCMessage *message = [[UMCMessage alloc] initWithText:text];
    message.messageStatus = UMCMessageStatusSuccess;
    [self addMessageToChatMessageArray:@[message]];
    
    [UMCManager storeMessage:message];
}

- (void)createMessage:(UMCMessage *)message completion:(void(^)(UMCMessage *message))completion {
    if (!message || message == (id)kCFNull) return ;
    
    if (self.isNavigatesStatus && message.contentType != UMCMessageContentTypeNavigate) {
        [UMCToast showToast:UMCLocalizedString(@"udesk_navigate_required") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    //转换成要展示的model
    [self addMessageToChatMessageArray:@[message]];
    
    [UMCManager createMessageWithMerchantsEuid:self.merchantEuid menuId:self.menuId message:message completion:^(UMCMessage *newMessage) {
    
        [self updateCache:message newMessage:newMessage];
        if (completion) {
            completion(message);
        }
    }];
}

- (void)createMediaMessage:(UMCMessage *)message mediaData:(NSData *)mediaData fileName:(NSString *)fileName progress:(void(^)(UMCMessage *message,float percent))progress completion:(void(^)(UMCMessage *message))completion {
    if (!message || message == (id)kCFNull) return ;
    
    if (self.isNavigatesStatus && message.contentType != UMCMessageContentTypeNavigate) {
        [UMCToast showToast:UMCLocalizedString(@"udesk_navigate_required") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
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
            [UMCManager createMessageWithMerchantsEuid:self.merchantEuid menuId:self.menuId message:message completion:^(UMCMessage *newMessage) {
                
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

- (void)addMessageToChatMessageArray:(NSArray *)messages {
    if (!messages || messages == (id)kCFNull) return ;
    if (![messages isKindOfClass:[NSArray class]]) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.messagesArray];
            for (UMCMessage *message in messages) {
                UMCBaseMessage *baseMsg = [self umcChatMessageWithMessage:message];
                if (baseMsg) {
                    [array addObject:baseMsg];
                }
            }
            
            NSMutableArray *empty = [NSMutableArray array];
            for (UMCBaseMessage *msg in array) {
                if (msg && ![self checkMessage:msg existInList:empty]) {
                    [empty addObject:msg];
                }
            }
            
            array = [empty copy];
            NSArray *messageList = [array sortedArrayUsingComparator:^NSComparisonResult(UMCBaseMessage * obj1, UMCBaseMessage * obj2) {
                if (obj2.message.createdAt && obj1.message.createdAt) {
                    NSDate *date2 = [NSDate dateWithString:obj2.message.createdAt format:kUMCDateFormat];
                    NSDate *date1 = [NSDate dateWithString:obj1.message.createdAt format:kUMCDateFormat];
                    return [date1 compare:date2];
                }
                return NSOrderedSame;
            }];
            
            self.messagesArray = [messageList copy];
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
    
    [UMCManager createProductWithMerchantsEuid:self.merchantEuid menuId:self.menuId product:self.sdkConfig.product completion:nil];
}

#pragma mark - @protocol UMCManagerDelegate
- (void)didReceiveMessage:(UMCMessage *)message {
    if (!message || message == (id)kCFNull) return ;
    
    if ([message.merchantEuid isEqualToString:self.merchantEuid]) {
        
        //撤回消息
        if (message.category == UMCMessageCategoryTypeEvent) {

            if (message.eventType == UMCEventContentTypeRollback) {
                [self handleRollbackMessage:message];
            }
            else if (message.eventType == UMCEventContentTypeFeedbacks) {
                [self handleFeedbacksMessage:message];
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

- (void)handleRollbackMessage:(UMCMessage *)message {
    
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

- (void)handleFeedbacksMessage:(UMCMessage *)message {
    
    [UMCManager fetchFeedbacksWithMerchantEuid:self.merchantEuid completion:^(NSString *feedbacksURL) {
        
        UMCWebViewController *webVC = [[UMCWebViewController alloc] initWithURL:[NSURL URLWithString:feedbacksURL]];
        [[UMCHelper currentViewController].navigationController pushViewController:webVC animated:YES];
    }];
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
                case UMCMessageContentTypeFile: {
                    
                    UMCFileMessage *fileMessage = [[UMCFileMessage alloc] initWithMessage:message];
                    return fileMessage;
                }
                case UMCMessageContentTypeNavigate: {
                    
                    if (message.direction == UMCMessageDirectionIn) {
                        UMCTextMessage *textMessage = [[UMCTextMessage alloc] initWithMessage:message];
                        return textMessage;
                    } else {
                        UMCNavigatesMessage *navigateMessage = [[UMCNavigatesMessage alloc] initWithMessage:message];
                        return navigateMessage;
                    }
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
