//
//  UMCMenuHelper.m
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCMenuHelper.h"
#import "UMCBundleHelper.h"

@interface UMCMenuHelper ()

@property (nonatomic, strong) NSArray *popMenuTitles;

@end

@implementation UMCMenuHelper

+ (instancetype)appearance {
    static UMCMenuHelper *configurationHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        configurationHelper = [[UMCMenuHelper alloc] init];
    });
    return configurationHelper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.popMenuTitles = @[UMCLocalizedString(@"udesk_copy")];
    }
    return self;
}

- (void)setupPopMenuTitles:(NSArray *)popMenuTitles {
    self.popMenuTitles = popMenuTitles;
}

@end
