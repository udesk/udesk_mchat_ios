//
//  UMCTextMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCTextMessage.h"
#import "UMCTextCell.h"
#import "UMCHelper.h"
#import "UMCSDKConfig.h"
#import "NSAttributedString+UMC.h"
#import <CoreText/CoreText.h>

/** 聊天气泡和其中的文字水平间距 */
static CGFloat const kUDBubbleToTextHorizontalSpacing = 10.0;

/** 聊天气泡和其中的文字垂直间距 */
CGFloat kUDBubbleToTextVerticalTopSpacing = 12.0;
/** 聊天气泡和其中的文字垂直间距 */
CGFloat kUDBubbleToTextVerticalBottomSpacing = 10.0;


@interface UMCTextMessage()

//文本frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  textFrame;
/** 消息的文字属性 */
@property (nonatomic, strong, readwrite) NSDictionary *cellTextAttributes;
/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *cellText;

@end

@implementation UMCTextMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self layoutTextMessage];
    }
    return self;
}

- (void)layoutTextMessage {
    
    if (kUMCSystemVersion >= 11.0) {
        /** 聊天气泡和其中的文字垂直间距 */
        kUDBubbleToTextVerticalTopSpacing = 10.0;
        /** 聊天气泡和其中的文字垂直间距 */
        kUDBubbleToTextVerticalBottomSpacing = 12.0;
    }
    
    @try {
        
        if (!self.message.content || [NSNull isEqual:self.message.content]) return;
        if ([UMCHelper isBlankString:self.message.content]) return;
        
        CGSize textSize = CGSizeMake(100, 50);
        
        if (self.message.contentType == UMCMessageContentTypeText) {
            
            textSize = [self setAttributedCellText:self.message.content messageFrom:self.message.direction];
            switch (self.message.direction) {
                case UMCMessageDirectionIn:{
                    
                    //文本气泡frame
                    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-kUDBubbleToTextHorizontalSpacing*2-kUDAvatarToBubbleSpacing-textSize.width, self.avatarFrame.origin.y, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+kUDBubbleToTextVerticalTopSpacing+kUDBubbleToTextVerticalBottomSpacing);
                    //文本frame
                    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing, kUDBubbleToTextVerticalTopSpacing, textSize.width, textSize.height);
                    //加载中frame
                    self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
                    
                    //加载失败frame
                    self.failureFrame = self.loadingFrame;
                    
                    break;
                }
                case UMCMessageDirectionOut:{
                    
                    //接收文字气泡frame
                    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, textSize.width+(kUDBubbleToTextHorizontalSpacing*3), textSize.height+kUDBubbleToTextVerticalTopSpacing+kUDBubbleToTextVerticalBottomSpacing);
                    //接收文字frame
                    self.textFrame = CGRectMake(kUDBubbleToTextHorizontalSpacing+kUDArrowMarginWidth, kUDBubbleToTextVerticalTopSpacing, textSize.width, textSize.height);
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            //cell高度
            self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)linkText:(NSString *)content {
    
    @try {
        
        NSMutableDictionary *richURLDictionary = [NSMutableDictionary dictionary];
        NSMutableArray *richContetnArray = [NSMutableArray array];
        
        for (NSString *linkRegex in [UMCSDKConfig sharedConfig].linkRegexs) {
            
            NSRange range = [content rangeOfString:linkRegex options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSValue *value = [NSValue valueWithRange:range];
                NSString *key = [content substringWithRange:range];
                if (value && key) {
                    [richURLDictionary setValue:value forKey:key];
                    [richContetnArray addObject:key];
                }
            }
        }
        
        self.matchArray = [NSArray arrayWithArray:richContetnArray];
        self.richURLDictionary = [NSDictionary dictionaryWithDictionary:richURLDictionary];
        
        NSMutableDictionary *numberDictionary = [NSMutableDictionary dictionary];
        for (NSString *linkRegex in [UMCSDKConfig sharedConfig].numberRegexs) {
            
            NSRange range = [content rangeOfString:linkRegex options:NSNumericSearch|NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                NSValue *value = [NSValue valueWithRange:range];
                NSString *key = [content substringWithRange:range];
                if (value && key) {
                    [numberDictionary setValue:value forKey:key];
                }
            }
        }
        self.numberRangeDic = [NSDictionary dictionaryWithDictionary:numberDictionary];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (CGSize)setAttributedCellText:(NSString *)text messageFrom:(UMCMessageDirection)messageFrom {
    
    @try {
        
        if ([UMCHelper isBlankString:text]) {
            return CGSizeMake(50, 50);
        }
        
        NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineSpacing = 6.0f;
        contentParagraphStyle.lineHeightMultiple = 1.0f;
        contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        contentParagraphStyle.alignment = NSTextAlignmentLeft;
        NSMutableDictionary *contentAttributes
        = [[NSMutableDictionary alloc]
           initWithDictionary:@{
                                NSParagraphStyleAttributeName : contentParagraphStyle,
                                NSFontAttributeName : [UMCSDKConfig sharedConfig].sdkStyle.messageContentFont
                                }];
        if (messageFrom == UMCMessageDirectionIn) {
            [contentAttributes setObject:(__bridge id)[UMCSDKConfig sharedConfig].sdkStyle.customerTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        } else {
            [contentAttributes setObject:(__bridge id)[UMCSDKConfig sharedConfig].sdkStyle.agentTextColor.CGColor forKey:(__bridge id)kCTForegroundColorAttributeName];
        }
        
        NSDictionary *cellTextAttributes = [[NSDictionary alloc] initWithDictionary:contentAttributes];
        self.cellText = [[NSAttributedString alloc] initWithString:text attributes:cellTextAttributes];
        
        CGSize textSize = [self.cellText getSizeForTextWidth:kUMCScreenWidth>320?235:180];
        
        if ([UMCHelper stringContainsEmoji:[self.cellText string]]) {
            NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:cellTextAttributes];
            CGFloat oneLineTextHeight = [oneLineText getHeightTextWidth:kUMCScreenWidth>320?235:180];
            NSInteger textLines = ceil(textSize.height / oneLineTextHeight);
            textSize.height += 8 * textLines;
        }
    
//        textSize.height += 2;
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
    
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
