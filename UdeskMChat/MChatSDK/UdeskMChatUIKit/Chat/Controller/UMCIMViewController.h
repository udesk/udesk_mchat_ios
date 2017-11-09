//
//  UMCIMViewController.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMCSDKConfig;
@class UMCMessage;

@interface UMCIMViewController : UIViewController

//更新最后一条消息
@property (nonatomic, copy) void(^UpdateLastMessageBlock)(UMCMessage *message);

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantId:(NSString *)merchantId;

- (void)dismissChatViewController;

@end
