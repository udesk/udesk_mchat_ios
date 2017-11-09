//
//  UMCSDKManager.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCSDKManager.h"
#import "UMCIMViewController.h"
#import "UMCSDKShow.h"
#import "UIImage+UMC.h"
#import "UMCHelper.h"

@implementation UMCSDKManager {
    
    UMCSDKConfig *_sdkConfig;
    UMCSDKShow *_show;
    NSString *_merchantId;
}

/**
 * 对象方法调用
 */
- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config  merchantId:(NSString *)merchantId {
    
    self = [super init];
    if (self) {
        
        _merchantId = merchantId;
        _sdkConfig = config;
        _show = [[UMCSDKShow alloc] initWithConfig:_sdkConfig];
    }
    return self;
}

/**
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)pushUdeskInViewController:(UIViewController *)viewController
                       completion:(void (^)(void))completion {
    
    if ([UMCHelper isBlankString:_merchantId]) {
        NSLog(@"UMC:请传入正确的商户ID");
        return;
    }
    
    UMCIMViewController *chatViewController = [[UMCIMViewController alloc] initWithSDKConfig:_sdkConfig merchantId:_merchantId];
    [_show presentOnViewController:viewController udeskViewController:chatViewController completion:completion];
    
    chatViewController.UpdateLastMessageBlock = ^(UMCMessage *message) {
        if (self.UpdateLastMessageBlock) {
            self.UpdateLastMessageBlock(message);
        }
    };
}

/**
 未读消息发生改变时
 
 @param completion 回调
 */
- (void)unreadCountDidChange:(void(^)(BOOL isPlus, NSString *count))completion {
    
    _sdkConfig.unreadCountDidChange = completion;
}

- (void)cleanSDKConfigData {
    
    if (!_sdkConfig) {
        return;
    }
    
    _sdkConfig.customerImage = [UIImage umcDefaultCustomerImage];
    _sdkConfig.customerImageURL = nil;
    _sdkConfig.merchantImage = [UIImage umcIMMerchantAvatarImage];
    _sdkConfig.merchantImageURL = nil;
    
    _sdkConfig.imTitle = nil;
    _sdkConfig.product = nil;
}

@end
