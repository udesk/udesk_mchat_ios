//
//  UMCMerchant.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UMCMessage;

@interface UMCMerchant : NSObject

/** 外部标识 */
@property (nonatomic, copy  ) NSString *euid;
/** 名称 */
@property (nonatomic, copy  ) NSString *name;
/** 通讯账号 */
@property (nonatomic, copy  ) NSString *imUsername;
/** 未读消息数 */
@property (nonatomic, copy  ) NSString *unreadCount;
/** 商户头像 */
@property (nonatomic, copy  ) NSString *logoURL;
/** 商户是否在工作时间 */
@property (nonatomic, assign) BOOL     onDuty;
/** 用户是否被拉黑 */
@property (nonatomic, assign) BOOL     isBlocked;
/** 商户非工作时间提示语 */
@property (nonatomic, copy  ) NSString *offDutyTips;
/** 最后一条消息 */
@property (nonatomic, strong) UMCMessage *lastMessage;

@end
