//
//  UMCCustomer.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/20.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMCCustomer : NSObject

/** 用户的唯一标示（注意：仅限传字母和数字的组合，*必传） */
@property (nonatomic, copy  ) NSString *euid;
/** 用户昵称 */
@property (nonatomic, copy  ) NSString *name;

- (instancetype)initWithEuid:(NSString *)euid name:(NSString *)name;

@end
