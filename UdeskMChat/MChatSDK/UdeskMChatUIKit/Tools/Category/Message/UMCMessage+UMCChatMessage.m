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
#import "UMCHelper.h"

#import "SDWebImageManager.h"
#import "FLAnimatedImage.h"
#import "YYCache.h"

@implementation UMCMessage (UMCChatMessage)

- (instancetype)initWithText:(NSString *)text {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeText;
        self.category = UMCMessageCategoryTypeChat;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.content = text;
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeImage;
        self.direction = UMCMessageDirectionIn;
        self.category = UMCMessageCategoryTypeChat;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        
        //缓存
        [[SDWebImageManager sharedManager].imageCache storeImage:image imageData:nil forKey:self.UUID cacheType:SDImageCacheTypeAll completion:nil];
    }
    
    return self;
}

- (instancetype)initWithGIFImage:(NSData *)gifData {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeImage;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.category = UMCMessageCategoryTypeChat;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        
        //缓存
        YYCache *cache = [[YYCache alloc] initWithName:UMCVoiceCache];
        [cache setObject:gifData forKey:self.UUID];
    }
    
    return self;
}

- (instancetype)initWithVoice:(NSData *)voiceData duration:(NSString *)duration {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeVoice;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.category = UMCMessageCategoryTypeChat;
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
        self.category = UMCMessageCategoryTypeChat;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.productMessage = product;
    }
    return self;
}

- (instancetype)initWithGoodsModel:(UMCGoodsModel *)model {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeGoods;
        self.category = UMCMessageCategoryTypeChat;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.goodsMessage = model;
        self.content = @"";
    }
    
    return self;
}

@end
