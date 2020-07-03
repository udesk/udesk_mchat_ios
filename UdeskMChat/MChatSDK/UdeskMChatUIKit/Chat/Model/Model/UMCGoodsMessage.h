//
//  UMCGoodsMessage.h
//  UdeskMChatExample
//
//  Created by xuchen on 2018/6/27.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"

@interface UMCGoodsMessage : UMCBaseMessage

/** 名称 */
@property (nonatomic, copy, readonly) NSString *name;
/** 链接 */
@property (nonatomic, copy, readonly) NSString *url;
/** 图片 */
@property (nonatomic, copy, readonly) NSString *imgUrl;

/** 消息的文字 */
@property (nonatomic, copy  , readonly) NSAttributedString *cellText;
//文本frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect  textFrame;
//图片frame(包括下方留白)
@property (nonatomic, assign, readonly) CGRect  imageFrame;

@end
