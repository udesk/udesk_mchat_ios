//
//  UMCMessage+UMCChatMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCMessage+UMCChatMessage.h"
#import "NSDate+UMC.h"
#import "UMCUIMacro.h"

#import "SDWebImageManager.h"
#import "FLAnimatedImage.h"
#import "YYCache.h"

@implementation UMCMessage (UMCChatMessage)

- (instancetype)initTextChatMessage:(NSString *)text {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeText;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.content = text;
    }
    
    return self;
}

- (instancetype)initImageChatMessage:(UIImage *)image {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeImage;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        
        //缓存
        [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:self.UUID completion:nil];
    }
    
    return self;
}

- (instancetype)initGIFImageChatMessage:(NSData *)gifData {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeImage;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        
        //缓存
        YYCache *cache = [[YYCache alloc] initWithName:UMCVoiceCache];
        [cache setObject:gifData forKey:self.UUID];
    }
    
    return self;
}

- (instancetype)initVoiceChatMessage:(NSData *)voiceData duration:(NSString *)duration {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeVoice;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        
        UMCMessageExtras *extras = [UMCMessageExtras new];
        extras.duration = duration;
        self.extras = extras;
        
        //缓存
        YYCache *cache = [[YYCache alloc] initWithName:UMCVoiceCache];
        [cache setObject:voiceData forKey:self.UUID];
    }
    
    return self;
}

- (instancetype)initWithProductMessage:(UMCProduct *)product {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeProduct;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.productMessage = product;
    }
    return self;
}

@end
