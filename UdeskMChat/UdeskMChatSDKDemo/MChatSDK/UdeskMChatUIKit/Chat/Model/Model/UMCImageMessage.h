//
//  UMCImageMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"

@interface UMCImageMessage : UMCBaseMessage

//图片frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect imageFrame;

@end
