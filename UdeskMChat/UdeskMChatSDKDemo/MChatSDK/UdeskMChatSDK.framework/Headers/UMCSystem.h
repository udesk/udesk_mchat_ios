//
//  UMCSystem.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/20.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMCSystem : NSObject

/** 租户uuid（由你们服务端进行签名返回给你们，*必传） */
@property (nonatomic, copy  ) NSString *UUID;
/** 签名（由你们服务端进行签名返回给你们，*必传） */
@property (nonatomic, copy  ) NSString *sign;
/** 时间戳（由你们服务端返回给你们，*必传） */
@property (nonatomic, copy  ) NSString *timestamp;

- (instancetype)initWithUUID:(NSString *)UUID sign:(NSString *)sign timestamp:(NSString *)timestamp;

@end
