//
//  UMCGoodsMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2018/6/27.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCGoodsMessage.h"
#import "UMCHelper.h"
#import "UMCGoodsCell.h"
#import "UMCSDKConfig.h"
#import "NSAttributedString+UMC.h"
#import <CoreText/CoreText.h>
#import "NSObject+UMC.h"

/** 商品消息图片和气泡水平间距 */
static CGFloat const kUDGoodsImageHorizontalSpacing = 10.0;
/** 商品消息图片和气泡垂直间距 */
static CGFloat const kUDGoodsImageVerticalSpacing = 10.0;

/** 商品消息图片width */
static CGFloat const kUDGoodsImageWidth = 60.0;
/** 商品消息图片height */
static CGFloat const kUDGoodsImageHeight = 60.0;

/** 商品参数距离图片气泡水平间距 */
static CGFloat const kUDGoodsParamsHorizontalSpacing = 10.0;
/** 商品参数距离名称气泡垂直间距 */
static CGFloat const kUDGoodsParamsVerticalSpacing = 10.0;

@interface UMCGoodsMessage()

/** 名称 */
@property (nonatomic, copy, readwrite) NSString *name;
/** 链接 */
@property (nonatomic, copy, readwrite) NSString *url;
/** 图片 */
@property (nonatomic, copy, readwrite) NSString *imgUrl;

/** 消息的文字 */
@property (nonatomic, copy  , readwrite) NSAttributedString *cellText;
//文本frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  textFrame;
//图片frame(包括下方留白)
@property (nonatomic, assign, readwrite) CGRect  imageFrame;

@end

@implementation UMCGoodsMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self layoutGoodsMessage];
    }
    return self;
}

- (void)layoutGoodsMessage {
    
    @try {
        
        if (!self.message.goodsMessage || [NSNull isEqual:self.message.goodsMessage]) return;
        if (![self.message.goodsMessage isKindOfClass:[UMCGoodsModel class]]) return ;
        
        NSDictionary *goodsDic = [self.message.goodsMessage dictionaryFromModel];
        if (!goodsDic || goodsDic == (id)kCFNull) return ;
        if (![goodsDic isKindOfClass:[NSDictionary class]]) return ;
        [self setupGoodsDataWithDictionary:goodsDic];
        
        CGFloat labelWidth = kUMCScreenWidth>320?170:140;
        CGFloat bubbleWidth = kUMCScreenWidth>320?280:230;
        
        CGSize textSize = [self getGoodsMessageSizeWithMaxWidth:labelWidth];
        
        if (self.message.direction == UMCMessageDirectionIn) {
            //图片
            self.imageFrame = CGRectMake(kUDGoodsImageHorizontalSpacing, kUDGoodsImageVerticalSpacing, kUDGoodsImageWidth, kUDGoodsImageHeight);
            //文本frame
            self.textFrame = CGRectMake(CGRectGetMaxX(self.imageFrame) + kUDGoodsParamsHorizontalSpacing, kUDGoodsParamsVerticalSpacing, textSize.width, textSize.height+5);
            //文本气泡frame
            CGFloat bubbleHeight = MAX(kUDGoodsImageHeight+kUDGoodsImageVerticalSpacing, CGRectGetMaxY(self.textFrame));
            self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x-kUDArrowMarginWidth-bubbleWidth, self.avatarFrame.origin.y, bubbleWidth, bubbleHeight+kUDGoodsParamsVerticalSpacing);
            //加载中frame
            self.loadingFrame = CGRectMake(self.bubbleFrame.origin.x-kUDBubbleToSendStatusSpacing-kUDSendStatusDiameter, self.bubbleFrame.origin.y+kUDCellBubbleToIndicatorSpacing, kUDSendStatusDiameter, kUDSendStatusDiameter);
            
            //加载失败frame
            self.failureFrame = self.loadingFrame;
            //cell高度
            self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setupGoodsDataWithDictionary:(NSDictionary *)dictionary {
    
    @try {
     
        if ([dictionary.allKeys containsObject:@"url"]) {
            self.url = dictionary[@"url"];
        }
        
        if ([dictionary.allKeys containsObject:@"name"]) {
            self.name = dictionary[@"name"];
            [self setGoodsNameAttributedStringWithName:self.name];
        }
        
        if ([dictionary.allKeys containsObject:@"imgUrl"]) {
            self.imgUrl = dictionary[@"imgUrl"];
        }
        
        if ([dictionary.allKeys containsObject:@"params"]) {
            NSArray *params = dictionary[@"params"];
            if (![params isKindOfClass:[NSArray class]]) return ;
            
            [self setupParamsWithArray:params];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)setGoodsNameAttributedStringWithName:(NSString *)name {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 5;
    
    NSDictionary *dic = @{
                          NSForegroundColorAttributeName:[UMCSDKConfig sharedConfig].sdkStyle.goodsNameTextColor,
                          NSFontAttributeName:[UMCSDKConfig sharedConfig].sdkStyle.goodsNameFont,
                          NSParagraphStyleAttributeName:paragraphStyle
                          };
    
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] init];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[name stringByAppendingString:@"\n"] attributes:dic];
    [mAttributedString appendAttributedString:attributedString];
    self.cellText = attributedString;
}

- (void)setupParamsWithArray:(NSArray *)array {
    
    NSMutableAttributedString *mAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.cellText];
    for (NSDictionary *param in array) {
        
        NSMutableDictionary *attributed = [NSMutableDictionary dictionary];
        UIColor *defaultColor = [UIColor umcColorWithHexString:@"#ffffff"];
        //字体颜色
        if ([param.allKeys containsObject:@"color"]) {
            NSString *colorString = param[@"color"];
            if (![colorString isKindOfClass:[NSString class]]) {
                [attributed setObject:defaultColor forKey:NSForegroundColorAttributeName];
            }
            else {
                UIColor *color = [UIColor umcColorWithHexString:colorString];
                if (color) {
                    [attributed setObject:color forKey:NSForegroundColorAttributeName];
                }
                else {
                    [attributed setObject:defaultColor forKey:NSForegroundColorAttributeName];
                }
            }
        }
        else {
            if (defaultColor) {
                [attributed setObject:defaultColor forKey:NSForegroundColorAttributeName];
            }
        }
        
        //字体
        CGFloat textSize = 12;
        if ([param.allKeys containsObject:@"size"]) {
            NSNumber *size = param[@"size"];
            if ([size isKindOfClass:[NSNumber class]]){
                textSize = size.floatValue;
            }
        }
        
        UIFont *textFont = [UIFont systemFontOfSize:textSize];
        if ([param.allKeys containsObject:@"fold"]) {
            NSNumber *fold = param[@"fold"];
            if ([fold isKindOfClass:[NSNumber class]]){
                if (fold.boolValue) {
                    textFont = [UIFont boldSystemFontOfSize:textSize];
                }
            }
        }
        
        [attributed setObject:textFont forKey:NSFontAttributeName];
        
        NSString *content = @"";
        //文本
        if ([param.allKeys containsObject:@"text"]) {
            NSString *text = param[@"text"];
            if ([text isKindOfClass:[NSString class]]) {
                content = text;
            }
        }
        
        //换行
        if ([param.allKeys containsObject:@"break"]) {
            NSNumber *udBreak = param[@"break"];
            if ([udBreak isKindOfClass:[NSNumber class]]) {
                if (udBreak.boolValue) {
                    content = [content stringByAppendingString:@"\n"];
                }
            }
        }
        
        //处理间隙
        NSUInteger index = [array indexOfObject:param];
        if (index != 0) {
            NSDictionary *previousParam = [array objectAtIndex:index-1];
            NSNumber *previousBreak = @0;
            if ([previousParam.allKeys containsObject:@"break"]) {
                previousBreak = previousParam[@"break"];
                if (![previousBreak isKindOfClass:[NSNumber class]]) {
                    previousBreak = @0;
                }
            }
            if (!previousBreak.boolValue) {
                content = [NSString stringWithFormat:@"    %@",content];
            }
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content attributes:attributed];
        [mAttributedString appendAttributedString:attributedString];
    }
    
    self.cellText = [mAttributedString copy];
}

- (CGSize)getGoodsMessageSizeWithMaxWidth:(CGFloat)maxWidth {
    
    CGSize textSize = [self.cellText getSizeForTextWidth:maxWidth];
    
    if ([UMCHelper stringContainsEmoji:[self.cellText string]]) {
        NSAttributedString *oneLineText = [[NSAttributedString alloc] initWithString:@"haha" attributes:nil];
        CGFloat oneLineTextHeight = [oneLineText getHeightTextWidth:maxWidth];
        NSInteger textLines = ceil(textSize.height / oneLineTextHeight);
        textSize.height += 8 * textLines;
    }
    return textSize;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    
    return [[UMCGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
