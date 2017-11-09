//
//  UMCMessage+UMCChatMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UdeskMChatSDK/UdeskMChatSDK.h>

@interface UMCMessage (UMCChatMessage)

- (instancetype)initWithProductMessage:(UMCProduct *)product;
- (instancetype)initTextChatMessage:(NSString *)text;
- (instancetype)initImageChatMessage:(UIImage *)image;
- (instancetype)initGIFImageChatMessage:(NSData *)gifData;
- (instancetype)initVoiceChatMessage:(NSData *)voiceData duration:(NSString *)duration;

@end
