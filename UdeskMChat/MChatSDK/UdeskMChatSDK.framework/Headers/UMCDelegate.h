//
//  UMCDelegate.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/24.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UMCMessage;

@protocol UMCMessageDelegate <NSObject>

@optional
/**
 *  接收消息代理
 *
 *  @param message 接收的消息
 */
- (void)didReceiveMessage:(UMCMessage *)message;

@end

@interface UMCDelegate : NSObject

+ (UMCDelegate *)shareInstance;

- (void)addDelegate:(id<UMCMessageDelegate>)delegate;

- (void)removeDelegate:(id<UMCMessageDelegate>)delegate;

@end
