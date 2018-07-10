//
//  UMCCustomButtonConfig.m
//  UdeskMChatExample
//
//  Created by xuchen on 2018/6/28.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCCustomButtonConfig.h"

@implementation UMCCustomButtonConfig

- (instancetype)initWithTitle:(NSString *)title clickBlock:(CustomButtonClickBlock)clickBlock
{
    self = [super init];
    if (self) {
        
        _title = title;
        _clickBlock = clickBlock;
    }
    return self;
}

@end
