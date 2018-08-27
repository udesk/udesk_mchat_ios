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
#import "NSAttributedString+UMC.h"

/** Event垂直距离 */
static CGFloat const kUDEventToVerticalEdgeSpacing = 10;

@interface UMCEventMessage()

/** 提示文字Frame */
@property (nonatomic, assign, readwrite) CGRect eventLabelFrame;
/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *cellText;

@end

@implementation UMCEventMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self layoutEventMessage];
            });
        }
        else {
            [self layoutEventMessage];
        }
    }
    return self;
}

- (void)layoutEventMessage {
    
    CGSize eventSize = [self setRichAttributedCellText:self.message.content];
    self.eventLabelFrame = CGRectMake((kUMCScreenWidth-eventSize.width)/2, CGRectGetMaxY(self.dateFrame)+kUDEventToVerticalEdgeSpacing, eventSize.width, eventSize.height);
    
    self.cellHeight = self.eventLabelFrame.size.height + self.eventLabelFrame.origin.y + kUDEventToVerticalEdgeSpacing;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCEventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

- (CGSize)setRichAttributedCellText:(NSString *)text {
    
    @try {
        
        //配置默认颜色
        text = [NSString stringWithFormat:@"<head><style>img{width:320px !important;}</style></head><span style='color:#999999'>%@</span>",text];
        
        NSDictionary *dic = @{
                              NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,
                              NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)
                              };
        
        self.cellText = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:dic documentAttributes:nil error:nil];
        
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithAttributedString:self.cellText];
        NSRange range = NSMakeRange(0, self.cellText.string.length);
        // 设置字体大小
        [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:range];
        
        NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineSpacing = 6.0f;
        contentParagraphStyle.lineHeightMultiple = 1.0f;
        contentParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        contentParagraphStyle.alignment = NSTextAlignmentLeft;
        
        //富文本末尾会有\n，为了不影响正常显示 这里前端过滤掉
        if (att.length) {
            NSAttributedString *last = [att attributedSubstringFromRange:NSMakeRange(att.length - 1, 1)];
            if ([[last string] isEqualToString:@"\n"]) {
                [att replaceCharactersInRange:NSMakeRange(att.length - 1, 1) withString:@""];
            }
        }
        
        self.cellText = att;
        
        CGSize textSize = [self.cellText getSizeForTextWidth:kUMCScreenWidth-20];
        textSize.height += 17;
        textSize.width += 10;
        
        return textSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
