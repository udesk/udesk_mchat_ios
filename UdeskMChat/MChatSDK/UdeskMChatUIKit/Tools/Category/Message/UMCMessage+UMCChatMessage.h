//
//  UMCMessage+UMCChatMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UdeskMChatSDK/UdeskMChatSDK.h>
@class UMCGoodsModel;
@class UMCNavigate;

@interface UMCMessage (UMCChatMessage)

- (instancetype)initWithProductMessage:(UMCProduct *)product;
- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithGIFImage:(NSData *)gifData;
- (instancetype)initWithVoice:(NSData *)voiceData duration:(NSString *)duration;
- (instancetype)initWithVideo:(NSData *)videoData;
- (instancetype)initWithFile:(NSString *)filePath;
- (instancetype)initWithGoodsModel:(UMCGoodsModel *)model;
- (instancetype)initWithNavigate:(NSString *)text;
- (instancetype)initWithNavigates:(NSArray *)navigates navDescribe:(NSString *)navDescribe;

@end
