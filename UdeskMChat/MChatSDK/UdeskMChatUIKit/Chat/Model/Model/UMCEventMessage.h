//
//  UMCEventMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"

@interface UMCEventMessage : UMCBaseMessage

/** 提示文字Frame */
@property (nonatomic, assign, readonly) CGRect eventLabelFrame;
/** 消息的文字 */
@property (nonatomic, copy  , readonly) NSAttributedString *cellText;

@end
