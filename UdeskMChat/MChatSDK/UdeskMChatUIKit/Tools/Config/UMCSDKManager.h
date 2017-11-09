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

@interface UMCSDKManager : NSObject

//更新最后一条消息
@property (nonatomic, copy) void(^UpdateLastMessageBlock)(UMCMessage *message);

/**
 * 对象方法调用
 */
- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config  merchantId:(NSString *)merchantId;

/**
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)pushUdeskInViewController:(UIViewController *)viewController
                       completion:(void (^)(void))completion;

/**
 未读消息发生改变时 (count是数量，isPlus为yes是收到未读消息需要增加未读消息数，反之减少未读消息数)

 @param completion 回调
 */
- (void)unreadCountDidChange:(void(^)(BOOL isPlus, NSString *count))completion;

//做清除缓存数据操作
- (void)cleanSDKConfigData;

@end
