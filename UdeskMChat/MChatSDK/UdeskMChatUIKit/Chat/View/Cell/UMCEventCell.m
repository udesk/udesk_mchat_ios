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
#import "UDTTTAttributedLabel.h"
#import "UMCUIMacro.h"
#import "UIView+UMC.h"
#import "UMCBundleHelper.h"

@interface UMCEventCell()<UITextViewDelegate>

/**  提示信息Label */
@property (nonatomic, strong) UITextView *eventTextView;

@end

@implementation UMCEventCell

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UMCEventMessage *eventMessage = (UMCEventMessage *)baseMessage;
    if (!eventMessage || ![eventMessage isKindOfClass:[UMCEventMessage class]]) return;
    
    if ([UMCHelper isBlankString:eventMessage.message.content]) {
        self.eventTextView.text = @"";
    }
    else {
        self.eventTextView.attributedText = eventMessage.cellText;
    }
    
    self.eventTextView.frame = eventMessage.eventLabelFrame;
}

- (UITextView *)eventTextView {
    
    if (!_eventTextView) {
        _eventTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _eventTextView.textAlignment = NSTextAlignmentCenter;
        _eventTextView.layer.masksToBounds = YES;
        _eventTextView.layer.cornerRadius = 3;
        _eventTextView.backgroundColor = [UIColor colorWithRed:0.894f  green:0.894f  blue:0.894f alpha:1];
        _eventTextView.delegate = self;
        _eventTextView.editable = NO;
        [self.contentView addSubview:_eventTextView];
    }
    
    return _eventTextView;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    //可在此做业务需求的跳转
    return YES;//返回YES，直接跳转Safari
}

- (void)attributedLabel:(UDTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    if ([url.absoluteString rangeOfString:@"://"].location == NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url.absoluteString]]];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)attributedLabel:(UDTTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@\n可能是一个电话号码，你可以",phoneNumber] preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (kUMCIsPad) {
        [sheet setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [sheet popoverPresentationController];
        popPresenter.sourceView = self.contentView;
        popPresenter.sourceRect = CGRectMake(self.contentView.umcCenterX, 74, 1, 1);
    }
    
    [sheet addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_cancel") style:UIAlertActionStyleCancel handler:nil]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_call") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phoneNumber]]];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_copy") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = phoneNumber;
    }]];
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
