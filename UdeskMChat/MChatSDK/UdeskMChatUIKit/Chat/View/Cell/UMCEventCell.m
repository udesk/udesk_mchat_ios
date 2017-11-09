//
//  UMCEventCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCEventCell.h"
#import "UMCEventMessage.h"
#import "UMCHelper.h"

@interface UMCEventCell()

/**  提示信息Label */
@property (nonatomic, strong) UILabel *eventLabel;

@end

@implementation UMCEventCell

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UMCEventMessage *eventMessage = (UMCEventMessage *)baseMessage;
    if (!eventMessage || ![eventMessage isKindOfClass:[UMCEventMessage class]]) return;
    
    if ([UMCHelper isBlankString:eventMessage.message.content]) {
        return;
    }
    
    if (!eventMessage.message.createdAt) {
        return;
    }
    
    self.eventLabel.text = eventMessage.message.content;
    self.eventLabel.frame = eventMessage.eventLabelFrame;
}

- (UILabel *)eventLabel {
    
    if (!_eventLabel) {
        _eventLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _eventLabel.textColor = [UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1];
        _eventLabel.textAlignment = NSTextAlignmentCenter;
        _eventLabel.font = [UIFont systemFontOfSize:13];
        _eventLabel.layer.masksToBounds = YES;
        _eventLabel.layer.cornerRadius = 3;
        _eventLabel.backgroundColor = [UIColor colorWithRed:0.894f  green:0.894f  blue:0.894f alpha:1];
        [self.contentView addSubview:_eventLabel];
    }
    
    return _eventLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
