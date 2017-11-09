//
//  UMCEventMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCEventMessage.h"
#import "UMCUIMacro.h"
#import "UMCEventCell.h"
#import "NSString+UMC.h"

/** Event垂直距离 */
static CGFloat const kUDEventToVerticalEdgeSpacing = 10;
/** Event水平距离 */
static CGFloat const kUDEventToHorizontalEdgeSpacing = 8;
/** Event高度 */
static CGFloat const kUDEventHeight = 20;

@interface UMCEventMessage()

/** 提示文字Frame */
@property (nonatomic, assign, readwrite) CGRect eventLabelFrame;

@end

@implementation UMCEventMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self layoutEventMessage];
    }
    return self;
}

- (void)layoutEventMessage {
    
    CGFloat eventWidth = [self getEventContentWidth:self.message.content];
    self.eventLabelFrame = CGRectMake((kUMCScreenWidth-eventWidth)/2, CGRectGetMaxY(self.dateFrame)+kUDEventToVerticalEdgeSpacing, eventWidth, kUDEventHeight);
    
    self.cellHeight = self.eventLabelFrame.size.height + self.eventLabelFrame.origin.y + kUDEventToVerticalEdgeSpacing;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (CGFloat)getEventContentWidth:(NSString *)eventContent {
    
    CGSize size = [eventContent umcSizeForFont:[UIFont systemFontOfSize:13] size:CGSizeMake(kUMCScreenWidth, kUDEventHeight) mode:NSLineBreakByTruncatingTail];
    return size.width+(kUDEventToHorizontalEdgeSpacing*2);
}

@end
