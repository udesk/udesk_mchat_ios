//
//  UMCSDKManager.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UMCSDKConfig.h"
#import "UMCIMViewController.h"

@interface UMCSDKManager : NSObject

//更新最后一条消息
@property (nonatomic, copy) void(^UpdateLastMessageBlock)(UMCMessage *message);

@property (nonatomic, strong) UMCSDKConfig *sdkConfig;

/**
 * 对象方法调用
 */
- (instancetype)initWithMerchantEuid:(NSString *)merchantEuid;

/**
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)pushUdeskInViewController:(UIViewController *)viewController
                       completion:(void (^)(void))completion;

@end
