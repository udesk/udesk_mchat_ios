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
#import "UMCToast.h"

@interface UMCSDKManager()

@property (nonatomic, strong) UMCSDKShow *show;
@property (nonatomic, copy  ) NSString *merchantEuid;

@end

@implementation UMCSDKManager

- (instancetype)initWithMerchantEuid:(NSString *)merchantEuid {
    
    self = [super init];
    if (self) {
        
        _merchantEuid = merchantEuid;
    }
    return self;
}

- (UMCSDKShow *)show {
    if (!_show) {
        _show = [[UMCSDKShow alloc] initWithConfig:self.sdkConfig];
    }
    return _show;
}

- (UMCSDKConfig *)sdkConfig {
    if (!_sdkConfig) {
        _sdkConfig = [UMCSDKConfig sharedConfig];
    }
    return _sdkConfig;
}

/**
 * 在一个ViewController中Push出一个客服聊天界面
 * @param viewController 在这个viewController中push出客服聊天界面
 */
- (void)pushUdeskInViewController:(UIViewController *)viewController
                       completion:(void (^)(void))completion {
    
    if ([UMCHelper isBlankString:_merchantEuid]) {
        NSLog(@"UMC:请传入正确的商户ID");
        return;
    }
    
    //把会话设置为已读
    [self readIMSession];
    [UMCManager createCustomerWithMerchantEuid:self.merchantEuid completion:^(NSError *error) {
        if (error) {
            [UMCToast showToast:@"创建用户失败!" duration:1 window:[UIApplication sharedApplication].keyWindow];
            return;
        }
        UMCIMViewController *chatViewController = [[UMCIMViewController alloc] initWithSDKConfig:_sdkConfig merchantEuid:_merchantEuid];
        [self.show presentOnViewController:viewController udeskViewController:chatViewController completion:completion];
        
        chatViewController.UpdateLastMessageBlock = ^(UMCMessage *message) {
            if (self.UpdateLastMessageBlock) {
                self.UpdateLastMessageBlock(message);
            }
        };
    }];
}

- (void)readIMSession {
    
    //设置已读
    [UMCManager readMerchantsWithEuid:self.merchantEuid completion:^(BOOL result) {
        if (result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil userInfo:nil];
        }
    }];
}

@end
