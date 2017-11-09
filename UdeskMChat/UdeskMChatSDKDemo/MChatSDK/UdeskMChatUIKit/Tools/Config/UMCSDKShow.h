//
//  UdeskSDKShow.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/26.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class UMCSDKConfig;

@interface UMCSDKShow : NSObject

- (instancetype)initWithConfig:(UMCSDKConfig *)sdkConfig;

- (void)presentOnViewController:(UIViewController *)rootViewController
            udeskViewController:(id)udeskViewController
                     completion:(void (^)(void))completion;

@end
