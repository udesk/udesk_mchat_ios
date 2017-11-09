//
//  UdeskSDKConfig.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/16.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCSDKConfig.h"
#import "UIColor+UMC.h"
#import "UMCUIMacro.h"
#import "UIImage+UMC.h"

@interface UMCSDKConfig()

/** 超链接正则 */
@property (nonatomic, strong, readwrite) NSMutableArray *linkRegexs;
/** 号码正则 */
@property (nonatomic, strong, readwrite) NSMutableArray *numberRegexs;

@end

@implementation UMCSDKConfig

+ (instancetype)sharedConfig {

    static UMCSDKConfig *udConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        udConfig = [[UMCSDKConfig alloc] init];
    });
    
    return udConfig;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setDefaultConfig];
        
        self.numberRegexs = [[NSMutableArray alloc] initWithArray:@[@"0?(13|14|15|18)[0-9]{9}",
                                                                    @"[0-9-()()]{7,18}"]];
        
        self.linkRegexs   = [[NSMutableArray alloc] initWithArray:@[@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"]];
    }
    return self;
}

//默认配置
- (void)setDefaultConfig {

    self.sdkStyle = [UMCSDKStyle defaultStyle];
    self.customerImage = [UIImage umcDefaultCustomerImage];
    self.merchantImage = [UIImage umcContactsMerchantAvatarImage];
}

@end
