//
//  UMCTextCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCTextCell.h"
#import "UMCTextMessage.h"
#import "UMCHelper.h"
#import "UMCMenuHelper.h"
#import "UMCBundleHelper.h"
#import "UMCUIMacro.h"
#import "UIView+UMC.h"

#import "UDTTTAttributedLabel.h"

@interface UMCTextCell()<UDTTTAttributedLabelDelegate>

@property (nonatomic, strong) UDTTTAttributedLabel *textContentLabel;

@end

@implementation UMCTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _textContentLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _textContentLabel.numberOfLines = 0;
    _textContentLabel.delegate = self;
    _textContentLabel.textAlignment = NSTextAlignmentLeft;
    _textContentLabel.userInteractionEnabled = true;
    _textContentLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_textContentLabel];
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressContentLabelAction:)];
    [recognizer setMinimumPressDuration:0.4f];
    [self.bubbleImageView addGestureRecognizer:recognizer];
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UMCTextMessage *textMessage = (UMCTextMessage *)baseMessage;
    if (!textMessage || ![textMessage isKindOfClass:[UMCTextMessage class]]) return;
    
    if ([UMCHelper isBlankString:textMessage.message.content]) {
        self.textContentLabel.text = @"";
    }
    else {
        self.textContentLabel.text = textMessage.cellText;
    }
    
    //设置frame
    self.textContentLabel.frame = textMessage.textFrame;
    
    @try {
        
        //正则号吗
        [textMessage linkText:self.textContentLabel.text];
        
        //获取文字中的可选中的元素
        if (textMessage.numberRangeDic.count > 0) {
            NSString *longestKey = @"";
            for (NSString *key in textMessage.numberRangeDic.allKeys) {
                //找到最长的key
                if (key.length > longestKey.length) {
                    longestKey = key;
                }
            }
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                [self.textContentLabel addLinkToPhoneNumber:longestKey withRange:[textMessage.numberRangeDic[longestKey] rangeValue]];
            }
        }
        
        //设置高亮
        for (NSString *richContent in textMessage.matchArray) {
            
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
                NSString *url = [[richContent stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [self.textContentLabel addLinkToURL:[NSURL URLWithString:url] withRange:[textMessage.richURLDictionary[richContent] rangeValue]];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
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

//长按复制
- (void)longPressContentLabelAction:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        @try {
            
            if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
                return;
            
            NSArray *popMenuTitles = [[UMCMenuHelper appearance] popMenuTitles];
            NSMutableArray *menuItems = [[NSMutableArray alloc] init];
            for (int i = 0; i < popMenuTitles.count; i ++) {
                NSString *title = popMenuTitles[i];
                SEL action = nil;
                switch (i) {
                    case 0: {
                        if (self.baseMessage.message.contentType == UMCMessageContentTypeText) {
                            action = @selector(copyed:);
                        }
                        break;
                    }
                        
                    default:
                        break;
                }
                if (action) {
                    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:title action:action];
                    if (item) {
                        [menuItems addObject:item];
                    }
                }
            }
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:menuItems];
            
            CGRect targetRect = [self convertRect:self.baseMessage.bubbleFrame
                                         fromView:self];
            
            [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
            [menu setMenuVisible:YES animated:YES];
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    });
}

#pragma mark - 复制
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:));
}

- (void)copyed:(id)sender {
    
    [[UIPasteboard generalPasteboard] setString:self.textContentLabel.text];
    [self resignFirstResponder];
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
