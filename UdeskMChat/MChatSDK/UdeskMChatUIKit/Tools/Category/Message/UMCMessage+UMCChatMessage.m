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
#import "UMCVideoCache.h"

#import "Udesk_YYCache.h"
#import "UMCImageHelper.h"

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
        self.sourceData = [UMCImageHelper imageWithOriginalImage:[UMCImageHelper fixOrientation:image] quality:0.5];
        UMCMessageExtras *extras = [UMCMessageExtras new];
        extras.filename = [self.UUID stringByAppendingString:@".jpg"];
        self.extras = extras;
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
        self.sourceData = gifData;
        UMCMessageExtras *extras = [UMCMessageExtras new];
        extras.filename = [self.UUID stringByAppendingString:@".gif"];
        self.extras = extras;
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
        extras.filename = [self.UUID stringByAppendingString:@".wav"];
        self.extras = extras;
        
        self.sourceData = voiceData;
        
        //缓存
        Udesk_YYCache *cache = [[Udesk_YYCache alloc] initWithName:UMCVoiceCache];
        [cache setObject:voiceData forKey:self.UUID];
    }
    
    return self;
}

- (instancetype)initWithVideo:(NSData *)videoData {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeVideo;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.category = UMCMessageCategoryTypeChat;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.sourceData = videoData;
        UMCMessageExtras *extras = [UMCMessageExtras new];
        extras.filename = [self.UUID stringByAppendingString:@".mp4"];
        self.extras = extras;
        
        //缓存
        [[UMCVideoCache sharedManager] storeVideo:videoData videoId:self.UUID];
    }
    
    return self;
}

- (instancetype)initWithFile:(NSString *)filePath {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeFile;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.category = UMCMessageCategoryTypeChat;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.sourceData = [NSData dataWithContentsOfFile:filePath];
        
        UMCMessageExtras *extras = [[UMCMessageExtras alloc] init];
        NSArray *array = [filePath componentsSeparatedByString:@"/"];
        NSString *fileName = [array lastObject];
        extras.filename = [fileName stringByRemovingPercentEncoding];
        
        CGFloat size = self.sourceData.length/1024.f/1024.f;
        extras.filesize = [NSString stringWithFormat:@"%.2fM",size];
        if (size < 1) {
            extras.filesize = [NSString stringWithFormat:@"%.2fK",size*1024.f];
        }
        
        extras.fileext = [[extras.filename componentsSeparatedByString:@"."] lastObject];
        
        self.extras = extras;
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

- (instancetype)initWithNavigates:(NSArray *)navigates navDescribe:(NSString *)navDescribe {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeNavigate;
        self.category = UMCMessageCategoryTypeChat;
        self.direction = UMCMessageDirectionOut;
        self.messageStatus = UMCMessageStatusSuccess;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.navigates = navigates;
        self.navDescribe = navDescribe;
        self.content = navDescribe;
        self.navEnabled = YES;
    }
    
    return self;
}

- (instancetype)initWithNavigate:(NSString *)text {
    
    self = [super init];
    if (self) {
        
        self.UUID = [[NSUUID UUID] UUIDString];
        self.contentType = UMCMessageContentTypeNavigate;
        self.category = UMCMessageCategoryTypeChat;
        self.direction = UMCMessageDirectionIn;
        self.messageStatus = UMCMessageStatusSending;
        self.createdAt = [[NSDate date] stringWithFormat:kUMCDateFormat];
        self.content = text;
    }
    
    return self;
}

@end
