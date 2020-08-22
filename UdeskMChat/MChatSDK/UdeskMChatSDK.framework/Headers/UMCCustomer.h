//
//  UMCCustomer.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/20.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMCCustomer : NSObject

/// 用户的唯一标示（注意：仅限传字母和数字的组合，*必传）
@property (nonatomic, copy) NSString *euid;
/// 用户昵称（*必传）
@property (nonatomic, copy) NSString *name;
/// 公司名称
@property (nonatomic, copy) NSString *org;
/// 用户描述
@property (nonatomic, copy) NSString *customerDescription;
/// 用户标签，用逗号分隔 如："帅气,漂亮"
@property (nonatomic, copy) NSString *tags;
/// 手机号（唯一值，不同用户不允许重复，重复会导致创建用户失败！！！）
@property (nonatomic, copy) NSString *cellphone;
/// 邮箱（唯一值，不同用户不允许重复，重复会导致创建用户失败！！！）
@property (nonatomic, copy) NSString *email;

/// 用户自定义字段
@property (nonatomic, strong) NSDictionary *customField;

- (instancetype)initWithEuid:(NSString *)euid name:(NSString *)name;

@end
